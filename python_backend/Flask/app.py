from flask import Flask, request, jsonify
from flask_bcrypt import Bcrypt
from sqlalchemy import create_engine,text
from sqlalchemy.orm import sessionmaker,joinedload
from create_mysqldatabase import Base, User,Favourite,UserCar,Car,Reservation,Review,Parking
from datetime import timedelta
from flask_jwt_extended import jwt_required, get_jwt_identity,create_access_token
from sqlalchemy.exc import IntegrityError,SQLAlchemyError
from flask import Flask, jsonify, request
from datetime import datetime, timedelta
from flask_jwt_extended import JWTManager, create_access_token
from flask_cors import CORS
from pymongo import MongoClient
import json


app = Flask(__name__)
CORS(app) 
bcrypt = Bcrypt(app)
app.config['JWT_SECRET_KEY'] = 'your_jwt_secret_key' 
jwt = JWTManager(app)


with open('config.json', 'r') as config_file:
    config = json.load(config_file)

db_user = config.get('DB_USER')
db_password = config.get('DB_PASSWORD')
db_host = config.get('DB_HOST')
db_name = config.get('DB_NAME')


connection_string = f'mysql+pymysql://{db_user}:{db_password}@{db_host}/{db_name}'


# Database setup
engine = create_engine(connection_string)
Base.metadata.bind = engine
DBSession = sessionmaker(bind=engine)
session = DBSession()

@app.route('/signup', methods=['POST'])
def signup():
    data = request.json
    username = data.get('username')
    email = data.get('email')
    password = data.get('password')
    phone_number = data.get('phone_number')

    # Check if user already exists
    existing_user = session.query(User).filter_by(email=email).first()
    if existing_user:
        return jsonify({'message': 'User already exists'}), 409

    # Hash the password
    hashed_password = bcrypt.generate_password_hash(password).decode('utf-8')

    # Create new user
    new_user = User(
        username=username,
        email=email,
        password=hashed_password,
        phone_number=phone_number,
    )
    session.add(new_user)
    session.commit()

    return jsonify({'message': 'User created successfully'}), 201

@app.route('/login', methods=['POST'])
def login():
    data = request.json
    email = data.get('email')
    password = data.get('password')

    # Assuming you have a session and User model set up as in the previous examples
    user = session.query(User).filter_by(email=email).first()

    if user and bcrypt.check_password_hash(user.password, password):
        # Create JWT token
       
        access_token = create_access_token(identity=user.id, expires_delta=timedelta(hours=1))
        print(access_token)
        return jsonify({'message': 'Login successful', 'access_token': access_token}), 200
    else:
        return jsonify({'message': 'Invalid username or password'}), 401



@app.route('/favourites', methods=['GET', 'DELETE'])
@jwt_required()
def favourites():
    user_id = int(get_jwt_identity()) 
    try:
        if request.method == 'GET':
            # Join with the Parking table to access the parking details
            favourites = session.query(Favourite)\
                .join(Parking, Favourite.parking_id == Parking.id)\
                .filter(Favourite.user_id == user_id)\
                .all()
                                                                       
            favourite_parkings = [{'id': fav.parking_id, 'name': f"parking_{fav.parking_id}"} for fav in favourites]
           
            return jsonify({
                'message': 'Successfully retrieved favourites',
                'user_id': user_id,
                'favourites': favourite_parkings
            }), 200

        elif request.method == 'DELETE':
            parking_id_to_delete = request.json.get('parking_id')

            if not parking_id_to_delete:
                return jsonify({'message': 'Parking ID is required for deletion'}), 400

            favourite_to_delete = session.query(Favourite)\
                .filter(Favourite.user_id == user_id, Favourite.parking_id == parking_id_to_delete)\
                .first()

            if not favourite_to_delete:
                return jsonify({'message': 'Favourite parking not found'}), 404

            session.delete(favourite_to_delete)
            session.commit()

            return jsonify({
                'message': 'Successfully deleted favourite',
                'parking_id': parking_id_to_delete
            }), 200

    except Exception as e:
        # Log the error for debugging purposes
        print(f"An error occurred: {e}")
        return jsonify({'message': f'An error occurred while processing your request: {e}'}), 500



@app.route('/my_cars', methods=['GET','POST','DELETE'])
@jwt_required()
def my_cars():
    current_user = get_jwt_identity()
    user_id = current_user

    if request.method == 'GET':
        # Retrieve the user's cars
        user_vehicles = session.query(Car).join(UserCar).filter(UserCar.user_id == user_id).all()
        vehicles_list = [{'id': vehicle.id, 'license_plate': vehicle.license_plate} for vehicle in user_vehicles]
        return jsonify({'user_id': user_id, 'vehicles': vehicles_list}), 200

    elif request.method == 'POST':
        # Register a new vehicle
        data = request.json
        license_plate = data.get('license_plate')

        if not license_plate:
            return jsonify({'message': 'License plate is required'}), 400

        # Check if the vehicle already exists
        existing_vehicle = session.query(Car).filter_by(license_plate=license_plate).first()

        if existing_vehicle:
            # Check if this user already has this car
            if session.query(UserCar).filter_by(user_id=user_id, car_id=existing_vehicle.id).first():
                return jsonify({'message': 'Vehicle already registered to this user'}), 409
            # If the car exists but is not registered to this user
            new_user_car = UserCar(user_id=user_id, car_id=existing_vehicle.id)
            session.add(new_user_car)
        else:
            # Create a new vehicle and register it to the user
            new_vehicle = Car(license_plate=license_plate)
            session.add(new_vehicle)
            session.flush()  # Populate new_vehicle with its new ID
            new_user_car = UserCar(user_id=user_id, car_id=new_vehicle.id)
            session.add(new_user_car)

        try:
            session.commit()
            return jsonify({'message': 'Vehicle registered successfully', 'license_plate': license_plate}), 201
        except IntegrityError:
            session.rollback()
            return jsonify({'message': 'Failed to register vehicle'}), 500
    
    
    
    elif request.method == 'DELETE':
        # Delete a vehicle
        data = request.json
        car_id = data.get('car_id')
        
        if not car_id:
            return jsonify({'message': 'Car ID is required'}), 400

        # Check if the car exists and belongs to the current user
        user_car = session.query(UserCar).filter_by(user_id=user_id, car_id=car_id).first()

        if user_car:
            # Delete the association and the car if no other users own it
            session.delete(user_car)
            
            # Check if no other associations exist for this car
            if not session.query(UserCar).filter_by(car_id=car_id).first():
                car = session.query(Car).filter_by(id=car_id).first()
                if car:
                    session.delete(car)
            
            try:
                session.commit()
                return jsonify({'message': 'Vehicle deleted successfully'}), 200
            except SQLAlchemyError:
                session.rollback()
                return jsonify({'message': 'Failed to delete vehicle'}), 500
        else:
            return jsonify({'message': 'Vehicle not found or not owned by user'}), 404



@app.route('/delete_account', methods=['DELETE'])
@jwt_required()
def delete_account():
    current_user = get_jwt_identity()
    user_id = current_user

    # Start a transaction
    try:
        # Disable foreign key checks
        session.execute(text('SET FOREIGN_KEY_CHECKS=0;'))

        # Find and delete related records first
       
        session.query(Reservation).filter(Reservation.user_id == user_id).delete(synchronize_session=False)
        session.query(Favourite).filter(Favourite.user_id == user_id).delete(synchronize_session=False)
        session.query(Review).filter(Review.user_id == user_id).delete(synchronize_session=False)
        session.query(UserCar).filter(UserCar.user_id == user_id).delete(synchronize_session=False)
    

        # Now, find and delete the user account
        user_to_delete = session.query(User).filter(User.id == user_id).first()
        if not user_to_delete:
            return jsonify({'message': 'User not found'}), 404

        session.delete(user_to_delete)

        # Commit changes
        session.commit()

        # Re-enable foreign key checks
        session.execute(text('SET FOREIGN_KEY_CHECKS=1;'))

        return jsonify({'message': 'Account deleted successfully'}), 200
    except Exception as e:
        # Rollback the changes on error and re-enable foreign key checks
        session.rollback()
        session.execute(text('SET FOREIGN_KEY_CHECKS=1;'))
        # Log the error for debugging
        print(str(e))
        return jsonify({'message': 'Could not delete account'}), 500
    finally:
        session.execute(text('SET FOREIGN_KEY_CHECKS=1;')) # To assure that it is going to be set again correctly ...
        


@app.route('/edit_info', methods=['PUT']) 
@jwt_required() 
def update_info():
    current_user = get_jwt_identity()
    user_id = current_user

    # Retrieve the data to update from the request
    data = request.json
    new_username = data.get('username')
    new_password = data.get('password')
    new_email = data.get('email')
    new_phone_number = data.get('phone_number')

    try:
        # Find the user in the database
        user = session.query(User).filter(User.id == user_id).first()
        if not user:
            return jsonify({'message': 'User not found'}), 404

        # Update user fields if new values are provided
        if new_username:
            user.username = new_username
        if new_password:
            hashed_password = bcrypt.generate_password_hash(new_password).decode('utf-8')
            user.password = hashed_password
        if new_email:
            user.email = new_email
        if new_phone_number:
            user.phone_number = new_phone_number
        

        # Commit the changes to the database
        session.commit()

        return jsonify({'message': 'User information updated successfully'}), 200

    except Exception as e:
        # Rollback in case of any error
        session.rollback()
        # Log the error for debugging
        print(str(e))
        return jsonify({'message': 'Failed to update user information', 'error': str(e)}), 500
       


@app.route('/my_reviews', methods=['GET','POST'])
@jwt_required()
def my_reviews():
 current_user = get_jwt_identity()
 user_id = current_user
 if request.method == 'GET':   
    
    try:
        # Query the database for reviews made by the user
        user_reviews = session.query(Review).filter(Review.user_id == user_id).all()

        # Format the reviews into a list of dictionaries
        reviews_list = []
        for review in user_reviews:
            reviews_list.append({
                'review_id': review.id,
                'parking_id': review.parking_id,
                'review_text': review.review,
                'number_of_stars': review.number_of_stars
            })

        return jsonify({
            'message': 'Successfully retrieved reviews',
            'user_id': user_id,
            'reviews': reviews_list
        }), 200

    except Exception as e:
        # Log the error for debugging
        print(str(e))
        return jsonify({'message': 'Failed to retrieve reviews', 'error': str(e)}), 500

 elif request.method == 'POST':
     try:
            data = request.json
            new_review_text = data.get('review_text')
            new_number_of_stars = data.get('number_of_stars')
            parking_id = data.get('parking_id')  # Assuming you pass parking_id

            new_review = Review(
                user_id=user_id,
                parking_id=parking_id,
                review=new_review_text,
                number_of_stars=new_number_of_stars
            )
            session.add(new_review)
            session.commit()

            return jsonify({'message': 'Review added successfully'}), 201
     except Exception as e:
            session.rollback()
            print(str(e))
            return jsonify({'message': 'Failed to add review', 'error': str(e)}), 500
    


@app.route('/my_history', methods=['GET'])
@jwt_required()
def my_history():
    current_user = get_jwt_identity()
    user_id = current_user

    try:
        # Query for user's reservations and related data
        user_reservations = session.query(
            Reservation,
            Car.license_plate,
            Parking.name,
            Parking.fee,
            Favourite.user_id,
            Review.number_of_stars
        ).outerjoin(Car, Car.license_plate == Reservation.license_plate)\
        .join(Parking, Parking.id == Reservation.parking_id)\
        .outerjoin(Favourite, (Favourite.parking_id == Parking.id) & (Favourite.user_id == user_id))\
        .outerjoin(Review, (Review.parking_id == Parking.id) & (Review.user_id == user_id))\
        .filter(Reservation.user_id == user_id).all()

        history = []
        for reservation, license_plate, parking_name, fee, favourite_user_id, stars in user_reservations:
            history.append({
                'total_fee': fee,
                'license_plate': license_plate,
                'parking_name': parking_name,
                'time_of_arrival': reservation.time_of_arrival.isoformat() if reservation.time_of_arrival else None,
                'time_of_departure': reservation.estimated_departure_time.isoformat() if reservation.estimated_departure_time else None,
                'is_favourite': 1 if favourite_user_id else 0,
                'number_of_stars': stars if stars is not None else 0
            })

        return jsonify({
            'message': 'Successfully retrieved parking history',
            'user_id': user_id,
            'history': history
        }), 200

    except Exception as e:
        # Log the error for debugging
        print(str(e))
        return jsonify({'message': 'Failed to retrieve parking history', 'error': str(e)}), 500




@app.route('/my_parked_cars', methods=['GET'])
@jwt_required()
def my_parked_cars():
    current_user = get_jwt_identity()
    user_id = current_user

    try:
        # Query for active reservations and related car data for the current user
        active_reservations = session.query(
            Reservation,
            Car.license_plate,
            Parking.name
        ).join(Car, Car.license_plate == Reservation.license_plate)\
        .join(Parking, Parking.id == Reservation.parking_id)\
        .filter(Reservation.user_id == user_id, Reservation.is_valid == True)\
        .all()

        parked_cars = []
        for reservation, license_plate, parking_name in active_reservations:
            parked_cars.append({
                'license_plate': license_plate,
                'parking_name': parking_name,
                'time_of_arrival': reservation.time_of_arrival.isoformat() if reservation.time_of_arrival else None,
                'estimated_departure_time': reservation.estimated_departure_time.isoformat() if reservation.estimated_departure_time else None,
                'total_fee': reservation.total_fee
            })

        return jsonify({
            'message': 'Successfully retrieved parked cars',
            'user_id': user_id,
            'parked_cars': parked_cars
        }), 200

    except Exception as e:
        # Log the error for debugging
        print(str(e))
        return jsonify({'message': 'Failed to retrieve parked cars', 'error': str(e)}), 500

    


@app.route('/parking/<int:parking_id>', methods=['GET'])
@jwt_required()
def get_parking_details(parking_id):
    current_user = get_jwt_identity()  
    user_id = current_user

    try:
        parking = session.query(Parking).get(parking_id)
        
        if parking:
            isFavorite = False
            existing_favourite = session.query(Favourite).filter_by(user_id=user_id, parking_id=parking_id).first()
            if existing_favourite:
                isFavorite = True
                
            parking_details = {
                'id': parking.id,
                'name': parking.name,
                'total_spots': parking.capacity,
                'available_spots': parking.number_of_spots_left,
                'fee': parking.fee,
                'isFavorite': isFavorite
            }

            return jsonify({
                'message': 'Successfully retrieved parking details',
                'parking': parking_details
            }), 200
        else:
            return jsonify({'message': 'Parking not found'}), 404
    except Exception as e:
        print(str(e))
        return jsonify({'message': 'Failed to retrieve parking details', 'error': str(e)}), 500
   

@app.route('/add_to_favourites', methods=['POST'])
@jwt_required()
def add_to_favourites():
    current_user = get_jwt_identity()
    user_id = current_user
    data = request.json
    parking_id = data.get('parking_id')

  
    existing_favourite = session.query(Favourite).filter_by(user_id=user_id, parking_id=parking_id).first()
    if existing_favourite:
        return jsonify({'message': 'Already in favourites'}), 409

    new_favourite = Favourite(user_id=user_id, parking_id=parking_id)
    session.add(new_favourite)
    try:
        session.commit()
        return jsonify({'message': 'Added to favourites'}), 201
    except Exception as e:
        session.rollback()
        print(str(e))
        return jsonify({'message': 'Failed to add to favourites', 'error': str(e)}), 500



@app.route('/nearest_parkings', methods=['POST'])
@jwt_required()
def nearest_parkings():
    # Extract the coordinates from the request
    client = MongoClient()
    db = client['park_now']
    collection = db['parkings']
    data = request.get_json()
    lat = data.get('latitude')
    lng = data.get('longitude')
     
    if not lat or not lng:
        return jsonify({"message": "Missing latitude or longitude"}), 400

    coordinates = [lng, lat]  # Ensure coordinates are in [longitude, latitude] order
    print(coordinates)
    try:
        # Query for nearest parkings
        nearest_parkings = collection.find(
            {
                "coordinates": {
                    "$near": {
                        "$geometry": {
                            "type": "Point",
                            "coordinates": coordinates
                        },
                        "$maxDistance": 5000  # Adjust the max distance as needed
                    }
                }
            }
        ).limit(10)  # Adjust the limit as needed

        # Convert the query result to a list of dictionaries
        parkings_list = list(nearest_parkings)
        print(parkings_list)
       
        nearest_parkings.close()

        return jsonify({"nearest_parkings": parkings_list}), 200

    except Exception as e:
        print(str(e))
        return jsonify({'message': 'Failed to retrieve nearest parkings', 'error': str(e)}), 500
    

@app.route('/reserve', methods=['POST'])
@jwt_required()
def reserve_parking():
    current_user = get_jwt_identity()
    user_id = current_user
    data = request.get_json()
    parking_id = data.get('parking_id')
    license_plate = data.get('license_plate')
    hours = data.get('hours')  # The number of hours to reserve

    if not parking_id or not license_plate or not hours:
        return jsonify({'message': 'Missing required data'}), 400

    # Start a transaction
    try:
        # Use the session to begin a transaction
        session.begin()

        # Check if the parking spot is available
        parking = session.query(Parking).filter_by(id=parking_id).with_for_update().first()
        if not parking or parking.number_of_spots_left <= 0:
            session.rollback()  # Rollback the transaction
            return jsonify({'message': 'Parking not available or full'}), 404

        # Calculate estimated departure time
        time_of_arrival = datetime.now()
        estimated_departure_time = time_of_arrival + timedelta(hours=hours)

        # Create a new reservation record
        new_reservation = Reservation(
            user_id=user_id,
            parking_id=parking_id,
            license_plate=license_plate,
            time_of_arrival=time_of_arrival,
            estimated_departure_time=estimated_departure_time,
            total_fee=parking.fee * hours,
            is_valid=True
        )
        
        session.add(new_reservation)

        # Update the number of spots left in the parking
        parking.number_of_spots_left -= 1

        # Commit the transaction
        session.commit()

        return jsonify({'message': 'Parking reserved successfully'}), 201

    except SQLAlchemyError as e:
        # Rollback the transaction in case of any error
        session.rollback()
        print(str(e))
        return jsonify({'message': 'Failed to reserve parking', 'error': str(e)}), 500


session.close()


if __name__ == '__main__':
    app.run(debug=True)
