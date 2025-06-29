-- Airbnb Clone - Database Seeding Script
-- Description: Inserts realistic sample data into all tables.

-- Users
INSERT INTO User (user_id, first_name, last_name, email, password_hash, phone_number, role, created_at) VALUES
('u1', 'Alice', 'Johnson', 'alice@example.com', 'hashed_password1', '0712345678', 'guest', CURRENT_TIMESTAMP),
('u2', 'Bob', 'Smith', 'bob@example.com', 'hashed_password2', '0798765432', 'host', CURRENT_TIMESTAMP),
('u3', 'Clara', 'Lee', 'clara@example.com', 'hashed_password3', NULL, 'admin', CURRENT_TIMESTAMP);

-- Properties
INSERT INTO Property (property_id, host_id, name, description, location, pricepernight, created_at, updated_at) VALUES
('p1', 'u2', 'Oceanview Retreat', 'A lovely house by the beach.', 'Mombasa, Kenya', 5000.00, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
('p2', 'u2', 'Mountain Cabin', 'Rustic cabin in the hills.', 'Naivasha, Kenya', 3500.00, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);

-- Bookings
INSERT INTO Booking (booking_id, property_id, user_id, start_date, end_date, total_price, status, created_at) VALUES
('b1', 'p1', 'u1', '2025-07-01', '2025-07-05', 20000.00, 'confirmed', CURRENT_TIMESTAMP),
('b2', 'p2', 'u1', '2025-08-10', '2025-08-15', 17500.00, 'pending', CURRENT_TIMESTAMP);

-- Payments
INSERT INTO Payment (payment_id, booking_id, amount, payment_date, payment_method) VALUES
('pay1', 'b1', 20000.00, CURRENT_TIMESTAMP, 'stripe'),
('pay2', 'b2', 17500.00, CURRENT_TIMESTAMP, 'paypal');

-- Reviews
INSERT INTO Review (review_id, property_id, user_id, rating, comment, created_at) VALUES
('r1', 'p1', 'u1', 5, 'Amazing stay, beautiful view and very clean!', CURRENT_TIMESTAMP),
('r2', 'p2', 'u1', 4, 'Cozy cabin but Wi-Fi was spotty.', CURRENT_TIMESTAMP);

-- Messages
INSERT INTO Message (message_id, sender_id, recipient_id, message_body, sent_at) VALUES
('m1', 'u1', 'u2', 'Hi, is the cabin available next weekend?', CURRENT_TIMESTAMP),
('m2', 'u2', 'u1', 'Yes, it is! Feel free to book.', CURRENT_TIMESTAMP);
