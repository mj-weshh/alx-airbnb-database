# Advanced SQL Join Queries — Airbnb Clone Database

This file documents three key types of SQL joins implemented in the Airbnb Clone backend system. These join queries are used to extract meaningful and connected insights across multiple related entities such as Users, Bookings, Properties, and Reviews.

## Task Breakdown

### 1. INNER JOIN — Bookings and Users

**Objective**: Retrieve all bookings and the corresponding user who made each booking.

**Why it's useful**:
- Tracks which user made each booking.
- Supports generation of reports like booking histories, billing, etc.

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
    Booking b
INNER JOIN 
    User u ON b.user_id = u.user_id;
