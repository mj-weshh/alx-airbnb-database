-- =============================================
-- SETUP: Ensure we're in a transaction for safe testing
-- =============================================
SET autocommit = 0;
START TRANSACTION;

-- =============================================
-- Original Query (Before Optimization)
-- =============================================
SELECT *
FROM bookings b
JOIN users u ON b.user_id = u.user_id
JOIN properties p ON b.property_id = p.property_id
LEFT JOIN payments pay ON b.booking_id = pay.booking_id
WHERE b.start_date >= '2023-01-01'
  AND b.status = 'confirmed'
ORDER BY b.created_at DESC;

-- =============================================
-- EXPLAIN ANALYZE for Original Query
-- =============================================
EXPLAIN ANALYZE
SELECT *
FROM bookings b
JOIN users u ON b.user_id = u.user_id
JOIN properties p ON b.property_id = p.property_id
LEFT JOIN payments pay ON b.booking_id = pay.booking_id
WHERE b.start_date >= '2023-01-01'
  AND b.status = 'confirmed'
ORDER BY b.created_at DESC;

-- =============================================
-- Optimized Query
-- =============================================
-- Create recommended index if it doesn't exist
CREATE INDEX IF NOT EXISTS idx_bookings_optimized 
    ON bookings(start_date, status, created_at, user_id, property_id);

-- Optimized query with explicit column selection and pagination
SELECT 
    -- Booking details
    b.booking_id,
    b.start_date,
    b.end_date,
    b.total_price,
    b.status,
    b.created_at,
    
    -- User details
    u.user_id,
    u.first_name,
    u.last_name,
    u.email,
    
    -- Property details
    p.property_id,
    p.name AS property_name,
    p.location,
    p.pricepernight,
    
    -- Payment details
    pay.payment_id,
    pay.amount,
    pay.payment_date,
    pay.payment_method
FROM 
    bookings b
    -- Force index usage for the date range and status filter
    USE INDEX (idx_bookings_optimized)  -- Suggests the optimizer to use this index
    
    -- Join users (has primary key on user_id)
    INNER JOIN users u ON b.user_id = u.user_id AND u.role = 'guest'  -- Filter users by role
    
    -- Join properties (has primary key on property_id)
    INNER JOIN properties p ON b.property_id = p.property_id AND p.pricepernight > 0  -- Ensure valid pricing
    
    -- Left join payments (not all bookings may have payments yet)
    LEFT JOIN (
        SELECT 
            booking_id, 
            payment_id, 
            amount, 
            payment_date, 
            payment_method 
        FROM 
            payments 
        WHERE 
            payment_status = 'completed'  -- Only include completed payments
    ) pay ON b.booking_id = pay.booking_id
WHERE 
    b.start_date >= '2023-01-01'
    AND b.status = 'confirmed'
    -- Additional filter to limit the result set
    AND b.created_at >= '2023-01-01'
ORDER BY 
    b.created_at DESC
-- Add pagination
LIMIT 20 OFFSET 0;

-- =============================================
-- EXPLAIN ANALYZE for Optimized Query
-- =============================================
EXPLAIN ANALYZE
SELECT 
    b.booking_id, b.start_date, b.end_date, b.total_price, b.status, b.created_at,
    u.user_id, u.first_name, u.last_name, u.email,
    p.property_id, p.name AS property_name, p.location, p.pricepernight,
    pay.payment_id, pay.amount, pay.payment_date, pay.payment_method
FROM 
    bookings b FORCE INDEX (idx_bookings_optimized)
    INNER JOIN users u ON b.user_id = u.user_id AND u.role = 'guest'  -- Filter users by role
    INNER JOIN properties p ON b.property_id = p.property_id AND p.pricepernight > 0  -- Ensure valid pricing
    LEFT JOIN (
        SELECT 
            booking_id, 
            payment_id, 
            amount, 
            payment_date, 
            payment_method 
        FROM 
            payments 
        WHERE 
            payment_status = 'completed'  -- Only include completed payments
    ) pay ON b.booking_id = pay.booking_id
WHERE 
    b.start_date >= '2023-01-01'
    AND b.status = 'confirmed'
    AND b.created_at >= '2023-01-01'
ORDER BY 
    b.created_at DESC
LIMIT 20;

-- =============================================
-- Cleanup: Rollback any changes made during testing
-- =============================================
ROLLBACK;
SET autocommit = 1;
