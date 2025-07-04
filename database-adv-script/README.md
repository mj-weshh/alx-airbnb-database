# Advanced SQL Queries — Airbnb Clone Database

This directory contains advanced SQL queries including joins and subqueries implemented in the Airbnb Clone backend system. These queries are used to extract meaningful and connected insights across multiple related entities such as Users, Bookings, Properties, and Reviews.

## Table of Contents
1. [Join Queries](#join-queries)
2. [Subquery Examples](#subquery-examples)
3. [Aggregations and Window Functions](#aggregations-and-window-functions)

## Join Queries

### 1. INNER JOIN — Bookings and Users

**Objective**: Retrieve all bookings and the corresponding user who made each booking.

**Why it's useful**:
- Tracks which user made each booking
- Supports generation of reports like booking histories, billing, etc.
- Helps in analyzing user booking patterns

**Query Example**:
```sql
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
    bookings b
INNER JOIN 
    users u ON b.user_id = u.user_id;
```

## Subquery Examples

### 1. Non-Correlated Subquery — High-Rated Properties

**Objective**: Find all properties with an average rating greater than 4.0.

**Why it's useful**:
- Identifies top-rated properties for promotional features
- Helps in quality control by highlighting well-performing properties
- Can be used to create "Top Picks" or "Guest Favorites" sections

**Query Example**:
```sql
SELECT 
    p.property_id,
    p.name AS property_name,
    p.location,
    p.pricepernight
FROM 
    properties p
WHERE 
    p.property_id IN (
        SELECT r.property_id
        FROM reviews r
        GROUP BY r.property_id
        HAVING AVG(r.rating) > 4.0
    )
ORDER BY p.name;
```

### 2. Correlated Subquery — Frequent Bookers

**Objective**: Identify users who have made more than 3 bookings.

**Why it's useful**:
- Helps in customer relationship management
- Identifies loyal customers for loyalty programs
- Provides insights into user engagement and retention

**Query Example**:
```sql
SELECT 
    u.user_id,
    u.first_name,
    u.last_name,
    u.email,
    (
        SELECT COUNT(*)
        FROM bookings b
        WHERE b.user_id = u.user_id
    ) AS booking_count
FROM 
    users u
WHERE 
    (SELECT COUNT(*) FROM bookings b WHERE b.user_id = u.user_id) > 3
ORDER BY 
    booking_count DESC, 
    u.last_name, 
    u.first_name;
```

## Aggregations and Window Functions

### 1. Total Bookings per User

**Objective**: Calculate the total number of bookings for each user, including those with no bookings.

**Why it's useful**:
- Identifies most active users
- Helps in user segmentation and marketing targeting
- Provides insights into user booking behavior

**Query Example**:
```sql
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
```

### 2. Ranking Properties by Total Bookings

**Objective**: Rank properties based on their total number of bookings, with proper handling of ties.

**Why it's useful**:
- Identifies most popular properties
- Helps in performance analysis and pricing strategy
- Can be used for featured property selection

**Query Example**:
```sql
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
SELECT 
    property_id,
    property_name,
    total_bookings,
    DENSE_RANK() OVER (ORDER BY total_bookings DESC) AS booking_rank
FROM 
    property_booking_counts
ORDER BY 
    booking_rank, property_name;
```
