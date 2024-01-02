use park_now;
CREATE INDEX idx_user_id ON user_car(user_id);
CREATE INDEX idx_car_id ON user_car (car_id);
CREATE INDEX idx_user_id ON reviews(user_id);
CREATE INDEX idx_parking_id ON reviews (parking_id);
CREATE INDEX idx_user_id ON reservation(user_id);
CREATE INDEX idx_parking_id ON reservation (parking_id);
CREATE INDEX idx_user_id ON favourites(user_id);
CREATE INDEX idx_parking_id ON favourites (parking_id);
