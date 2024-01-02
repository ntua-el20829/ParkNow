create database park_now;
use park_now;


create table user(
id int primary key auto_increment,
username varchar(30) unique not null,
email varchar(50) unique not null,
password varchar(15) not null,
phone_number char(10) not null,
birthday date not null
);


create table car(
id int primary key auto_increment,
license_plate char(8) unique
);


create table user_car(
user_id int,
car_id int,
foreign key(car_id) references car(id),
foreign key(user_id) references user(id),
primary key(user_id,car_id)
);


create table parking(
id int primary key,
name varchar(40),
capacity int,
fee int,
number_of_spots_left int
/*credit card fields*/
);


create table reviews(
id int primary key auto_increment,
review text not null,
number_of_stars int not null,
user_id int,
parking_id int,
foreign key(user_id) references user(id),
foreign key(parking_id) references parking(id)
);


create table favourites(
user_id int,
parking_id int,
foreign key (user_id) references user(id),
foreign key (parking_id) references parking(id)
);


create table reservation(
id int primary key auto_increment,
user_id int,
parking_id int,
license_plate char(8),
accepted_transaction bool, 
is_valid bool,
received_notification bool,
time_of_arrival DATETIME,
estimated_departure_time DATETIME,
total_fee int,

  /* check if valid using backend ...  */
foreign key (user_id) references user(id),
foreign key (parking_id) references parking(id)
);

