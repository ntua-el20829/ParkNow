from sqlalchemy import create_engine, Column, Integer, String, Date, ForeignKey, Boolean, Text, Index, text, DateTime
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import relationship
from sqlalchemy.orm import sessionmaker
from pymongo import MongoClient
from datetime import datetime, timedelta
from sqlalchemy.orm import declarative_base
import json

client = MongoClient()

mongo_db = client['park_now']

collection = mongo_db['parkings']

with open('config.json', 'r') as config_file:
    config = json.load(config_file)

db_user = config.get('DB_USER')
db_password = config.get('DB_PASSWORD')
db_host = config.get('DB_HOST')
db_name = config.get('DB_NAME')


connection_string = f'mysql+pymysql://{db_user}:{db_password}@{db_host}/{db_name}'


Base = declarative_base()
db = create_engine(connection_string)

class User(Base):
    __tablename__ = 'user'

    id = Column(Integer, primary_key=True, autoincrement=True)
    username = Column(String(30), unique=True, nullable=False)
    email = Column(String(50), unique=True, nullable=False)
    password = Column(String(255), nullable=False)
    phone_number = Column(String(10), nullable=False)
    cars = relationship("Car", secondary='user_car', overlaps="cars")
    reviews = relationship("Review")
    favourites = relationship("Parking", secondary='favourites', overlaps="favourites")
    reservations = relationship("Reservation")

class Car(Base):
    __tablename__ = 'car'

    id = Column(Integer, primary_key=True, autoincrement=True)
    license_plate = Column(String(8), unique=True, nullable=False)

    owners = relationship("User", secondary='user_car', overlaps="cars")

class UserCar(Base):
    __tablename__ = 'user_car'

    user_id = Column(Integer, ForeignKey('user.id'), primary_key=True)
    car_id = Column(Integer, ForeignKey('car.id'), primary_key=True)

    # Add indexes
    __table_args__ = (
        Index('idx_user_id', 'user_id'),
        Index('idx_car_id', 'car_id'),
    )

class Parking(Base):
    __tablename__ = 'parking'

    id = Column(Integer, primary_key=True,autoincrement=True)
    name = Column(String(40))
    capacity = Column(Integer)
    fee = Column(Integer)
    number_of_spots_left = Column(Integer)

    reviews = relationship("Review")
    favourites = relationship("User", secondary='favourites', overlaps="favourites")
    reservations = relationship("Reservation")

class Review(Base):
    __tablename__ = 'reviews'

    id = Column(Integer, primary_key=True, autoincrement=True)
    review = Column(Text, nullable=False)
    number_of_stars = Column(Integer, nullable=False)
    user_id = Column(Integer, ForeignKey('user.id'))
    parking_id = Column(Integer, ForeignKey('parking.id'))

    # Add indexes
    __table_args__ = (
        Index('idx_user_id', 'user_id'),
        Index('idx_parking_id', 'parking_id'),
    )

class Favourite(Base):
    __tablename__ = 'favourites'

    user_id = Column(Integer, ForeignKey('user.id'), primary_key=True)
    parking_id = Column(Integer, ForeignKey('parking.id'), primary_key=True)

    # Add indexes
    __table_args__ = (
        Index('idx_user_id', 'user_id'),
        Index('idx_parking_id', 'parking_id'),
    )

class Reservation(Base):
    __tablename__ = 'reservation'

    id = Column(Integer, primary_key=True, autoincrement=True)
    user_id = Column(Integer, ForeignKey('user.id'))
    parking_id = Column(Integer, ForeignKey('parking.id'))
    license_plate = Column(String(8))
    accepted_transaction = Column(Boolean,default=False)
    is_valid = Column(Boolean,default=False)
    checked = Column(Boolean,default=False)
    received_notification = Column(Boolean, default=False)  # New field
    time_of_arrival = Column(DateTime)  # New field
    estimated_departure_time = Column(DateTime)  # New field to store current time + X hours
    total_fee = Column(Integer)
    # Add indexes
    __table_args__ = (
        Index('idx_user_id', 'user_id'),
        Index('idx_parking_id', 'parking_id'),
    )

Base.metadata.create_all(db)

documents = collection.find()
Session = sessionmaker(bind=db)
session = Session()
session.execute(text('SET FOREIGN_KEY_CHECKS=0;'))

for document in documents:
    existing_parking = session.query(Parking).filter_by(id=document['_id']).first()
    if existing_parking is None:
    # Insert new parking record
        parking = Parking(id=document['_id'], name=document['name'], capacity=document['capacity'], fee=document['fee'],
                      number_of_spots_left=document['capacity'])
        session.add(parking)
        session.commit()


session.execute(text('SET FOREIGN_KEY_CHECKS=1;'))
session.close()
