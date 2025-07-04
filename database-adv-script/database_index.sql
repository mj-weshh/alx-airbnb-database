-- Database Indexing Strategy for Airbnb Database
-- This file contains recommended indexes to improve query performance
-- along with EXPLAIN ANALYZE examples demonstrating their impact

-- =============================================
-- 1. PERFORMANCE ANALYSIS QUERIES
-- =============================================

-- Example 1: Before and after indexing for user booking history
-- Before indexing (commented out - uncomment to test)
/*
EXPLAIN ANALYZE
SELECT b.*, u.first_name, u.last_name
FROM bookings b
JOIN users u ON b.user_id = u.user_id
WHERE u.last_name = 'Smith' 
  AND b.status = 'confirmed';
  
-- Expected output would show full table scans on both tables
-- After creating idx_users_name and idx_bookings_user_status, the same query:
*/
EXPLAIN ANALYZE
SELECT b.*, u.first_name, u.last_name
FROM bookings b
JOIN users u ON b.user_id = u.user_id
WHERE u.last_name = 'Smith' 
  AND b.status = 'confirmed';

-- Example 2: Property search by location and price range
-- Before indexing (commented out - uncomment to test)
/*
EXPLAIN ANALYZE
SELECT * FROM properties
WHERE location LIKE '%New York%'
  AND pricepernight BETWEEN 50 AND 200;
*/

-- After creating idx_properties_location and idx_properties_price
EXPLAIN ANALYZE
SELECT * FROM properties
WHERE location LIKE '%New York%'
  AND pricepernight BETWEEN 50 AND 200;

-- Example 3: Date range query on bookings
-- Before indexing (commented out - uncomment to test)
/*
EXPLAIN ANALYZE
SELECT * FROM bookings
WHERE start_date >= '2023-01-01' 
  AND end_date <= '2023-12-31';
*/

-- After creating idx_bookings_dates
EXPLAIN ANALYZE
SELECT * FROM bookings
WHERE start_date >= '2023-01-01' 
  AND end_date <= '2023-12-31';

-- =============================================
-- 2. RECOMMENDED INDEXES
-- =============================================

-- 1. Indexes for the users table
-- Note: user_id is already indexed as it's a PRIMARY KEY
-- Note: email already has an index (idx_users_email)

-- Index for searching users by name (common in user lookups)
CREATE INDEX idx_users_name ON users(last_name, first_name);

-- 2. Indexes for the properties table
-- Note: property_id is already indexed as it's a PRIMARY KEY
-- Note: host_id already has an index (idx_properties_host_id)

-- Index for location-based searches
CREATE INDEX idx_properties_location ON properties(location);

-- Index for price-based filtering and sorting
CREATE INDEX idx_properties_price ON properties(pricepernight);

-- 3. Indexes for the bookings table
-- Note: booking_id is already indexed as it's a PRIMARY KEY
-- Note: property_id and user_id already have indexes (idx_bookings_property_id, idx_bookings_user_id)

-- Composite index for common booking lookups by user and status
CREATE INDEX idx_bookings_user_status ON bookings(user_id, status);

-- Index for date range queries
CREATE INDEX idx_bookings_dates ON bookings(start_date, end_date);

-- 4. Indexes for the reviews table
-- Note: review_id is already indexed as it's a PRIMARY KEY
-- Note: property_id and user_id already have indexes (idx_reviews_property_id, idx_reviews_user_id)

-- Index for rating-based queries
CREATE INDEX idx_reviews_rating ON reviews(rating);

-- 5. Index for the messages table
-- Note: message_id is already indexed as it's a PRIMARY KEY
-- Note: sender_id and recipient_id already have indexes (idx_messages_sender_id, idx_messages_recipient_id)

-- Composite index for message threading/conversation views
CREATE INDEX idx_messages_conversation ON messages(
    LEAST(sender_id, recipient_id), 
    GREATEST(sender_id, recipient_id), 
    sent_at
);

-- 6. Index for the payments table
-- Note: payment_id is already indexed as it's a PRIMARY KEY
-- Note: booking_id already has an index (idx_payments_booking_id)

-- Index for payment date lookups
CREATE INDEX idx_payments_date ON payments(payment_date);

-- Index for payment method analysis
CREATE INDEX idx_payments_method ON payments(payment_method);

-- Note: The following indexes are already present in the schema:
-- CREATE INDEX idx_users_email ON users(email);
-- CREATE INDEX idx_properties_host_id ON properties(host_id);
-- CREATE INDEX idx_bookings_property_id ON bookings(property_id);
-- CREATE INDEX idx_bookings_user_id ON bookings(user_id);
-- CREATE INDEX idx_payments_booking_id ON payments(booking_id);
-- CREATE INDEX idx_reviews_property_id ON reviews(property_id);
-- CREATE INDEX idx_reviews_user_id ON reviews(user_id);
-- CREATE INDEX idx_messages_sender_id ON messages(sender_id);
-- CREATE INDEX idx_messages_recipient_id ON messages(recipient_id);
