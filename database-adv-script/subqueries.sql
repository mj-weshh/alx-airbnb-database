-- Subqueries for Airbnb Database
-- This file contains examples of both non-correlated and correlated subqueries

-- 1. Non-Correlated Subquery
-- Retrieves all properties with an average rating greater than 4.0
-- This query first identifies property_ids with high average ratings
-- and then fetches the complete property details for those properties
SELECT 
    p.property_id,
    p.name AS property_name,
    p.location,
    p.pricepernight,
    p.description
FROM 
    properties p
WHERE 
    p.property_id IN (
        -- Subquery to find properties with average rating > 4.0
        SELECT 
            r.property_id
        FROM 
            reviews r
        GROUP BY 
            r.property_id
        HAVING 
            AVG(r.rating) > 4.0
    )
ORDER BY 
    p.name;

-- 2. Correlated Subquery
-- Retrieves all users who have made more than 3 bookings
-- This query uses a correlated subquery to count bookings for each user
-- and filters users based on the booking count
SELECT 
    u.user_id,
    u.first_name,
    u.last_name,
    u.email,
    (
        -- Correlated subquery that counts bookings for each user
        SELECT 
            COUNT(*)
        FROM 
            bookings b
        WHERE 
            b.user_id = u.user_id
    ) AS booking_count
FROM 
    users u
WHERE 
    (
        -- The same correlated subquery used in the WHERE clause
        SELECT 
            COUNT(*)
        FROM 
            bookings b
        WHERE 
            b.user_id = u.user_id
    ) > 3
ORDER BY 
    booking_count DESC, 
    u.last_name, 
    u.first_name;
