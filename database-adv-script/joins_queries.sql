-- INNER JOIN: Retrieve all bookings and the respective users who made those bookings
SELECT 
    b.booking_id,
    b.start_date,
    b.end_date,
    b.total_price,
    b.status,
    u.user_id,
    u.first_name,
    u.last_name,
    u.email
FROM 
    Booking b
INNER JOIN 
    User u ON b.user_id = u.user_id;


-- LEFT JOIN: Retrieve all properties and their reviews, including properties that have no reviews
SELECT 
    p.property_id,
    p.name AS property_name,
    p.description,
    p.location,
    r.review_id,
    r.rating,
    r.comment
FROM 
    Property p
LEFT JOIN 
    Review r ON p.property_id = r.property_id;


-- FULL OUTER JOIN: Retrieve all users and all bookings, even if the user has no booking or a booking is not linked to a user
-- NOTE: MySQL does not support FULL OUTER JOIN directly, so we simulate it using UNION

-- Users and their bookings (even if no booking exists)
SELECT 
    u.user_id,
    u.first_name,
    u.last_name,
    b.booking_id,
    b.start_date,
    b.end_date,
    b.total_price
FROM 
    User u
LEFT JOIN 
    Booking b ON u.user_id = b.user_id

UNION

-- Bookings and their users (even if user doesn't exist)
SELECT 
    u.user_id,
    u.first_name,
    u.last_name,
    b.booking_id,
    b.start_date,
    b.end_date,
    b.total_price
FROM 
    Booking b
LEFT JOIN 
    User u ON b.user_id = u.user_id;

SELECT 
    p.property_id,
    p.name AS property_name,
    p.description,
    p.location,
    r.review_id,
    r.rating,
    r.comment
FROM 
    Property p
LEFT JOIN 
    Review r ON p.property_id = r.property_id;
ORDER BY 
    p.property_id;

-- Users and their bookings (even if no booking exists)
SELECT 
    u.user_id,
    u.first_name,
    u.last_name,
    b.booking_id,
    b.start_date,
    b.end_date,
    b.total_price
FROM 
    User u
LEFT JOIN 
    Booking b ON u.user_id = b.user_id

UNION

-- Bookings and their users (even if user doesn't exist)
SELECT 
    u.user_id,
    u.first_name,
    u.last_name,
    b.booking_id,
    b.start_date,
    b.end_date,
    b.total_price
FROM 
    Booking b
LEFT JOIN 
    User u ON b.user_id = u.user_id;
