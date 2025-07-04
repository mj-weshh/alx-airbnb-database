-- Advanced SQL Aggregations and Window Functions
-- This file contains examples of aggregation queries and window functions for the Airbnb database

-- 1. Total Bookings per User
-- Calculates the total number of bookings for each user, including users with zero bookings
SELECT 
    u.user_id,
    COALESCE(COUNT(b.booking_id), 0) AS total_bookings
FROM 
    users u
LEFT JOIN 
    bookings b ON u.user_id = b.user_id
GROUP BY 
    u.user_id
ORDER BY 
    total_bookings DESC;

-- 2. Ranking Properties by Total Bookings
-- Ranks all properties based on their total number of bookings, with properties sharing the same
-- number of bookings receiving the same rank (using DENSE_RANK to handle ties properly)
WITH property_booking_counts AS (
    -- CTE to calculate total bookings per property
    SELECT 
        p.property_id,
        p.name AS property_name,
        COUNT(b.booking_id) AS total_bookings
    FROM 
        properties p
    LEFT JOIN 
        bookings b ON p.property_id = b.property_id
    GROUP BY 
        p.property_id, p.name
)
-- Example using DENSE_RANK (ties get same rank, no gaps in ranking)
SELECT 
    property_id,
    property_name,
    total_bookings,
    DENSE_RANK() OVER (ORDER BY total_bookings DESC) AS booking_rank
FROM 
    property_booking_counts
ORDER BY 
    booking_rank, property_name;

-- 3. Row Numbering for Properties by Total Bookings
-- Assigns a unique row number to each property based on total bookings
-- Unlike RANK or DENSE_RANK, ROW_NUMBER always produces sequential numbers without gaps or duplicates
WITH property_booking_counts AS (
    SELECT 
        p.property_id,
        p.name AS property_name,
        COUNT(b.booking_id) AS total_bookings
    FROM 
        properties p
    LEFT JOIN 
        bookings b ON p.property_id = b.property_id
    GROUP BY 
        p.property_id, p.name
)
SELECT 
    property_id,
    property_name,
    total_bookings,
    ROW_NUMBER() OVER (ORDER BY total_bookings DESC) AS row_num
FROM 
    property_booking_counts
ORDER BY 
    row_num;
