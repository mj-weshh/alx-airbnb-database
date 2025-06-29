# Airbnb Clone – Database Schema Documentation

Welcome to the Airbnb Clone project! This README provides a detailed explanation of the database schema used to support core functionalities such as user management, property listings, bookings, payments, reviews, and messaging.

## Objective

The primary goal of this schema is to design a **normalized, scalable, and relational** database that can:

- Efficiently manage data related to users, properties, and transactions.
- Ensure data integrity and consistency through the use of constraints.
- Support seamless backend operations for a full-featured rental marketplace.

## Entity Breakdown

### 1. `users`
This table stores information about all platform users—guests, hosts, and admins.

**Key Attributes:**
- `user_id`: Primary key (UUID)
- `email`: Unique identifier for login
- `role`: Enum to distinguish between guest, host, and admin
- `password_hash`, `phone_number`, `created_at`

### 2. `properties`
Houses all property listings posted by hosts.

**Key Attributes:**
- `property_id`: Primary key (UUID)
- `host_id`: Foreign key referencing `users(user_id)`
- `description`, `location`, `pricepernight`
- Includes timestamps for creation and last update

### 3. `bookings`
Captures all booking records between guests and hosts.

**Key Attributes:**
- `booking_id`: Primary key (UUID)
- `property_id`, `user_id`: Foreign keys referencing relevant users and properties
- `start_date`, `end_date`, `total_price`
- `status`: Enum to track booking lifecycle (pending, confirmed, canceled)

### 4. `payments`
Handles payment records tied to bookings.

**Key Attributes:**
- `payment_id`: Primary key (UUID)
- `booking_id`: Foreign key referencing `bookings(booking_id)`
- `amount`, `payment_method`, `payment_date`

### 5. `reviews`
Captures user-generated reviews for properties.

**Key Attributes:**
- `review_id`: Primary key (UUID)
- `property_id`, `user_id`: Foreign keys
- `rating`: Integer from 1 to 5
- `comment`, `created_at`

### 6. `messages`
Facilitates private messaging between users.

**Key Attributes:**
- `message_id`: Primary key (UUID)
- `sender_id`, `recipient_id`: Foreign keys referencing `users(user_id)`
- `message_body`, `sent_at`

## Integrity & Constraints

- **Primary Keys**: Uniquely identify every record in the database.
- **Foreign Keys**: Maintain referential integrity between related tables.
- **Enums**: Ensure valid status values for fields like `role`, `payment_method`, and `booking status`.
- **Indexing**: Strategic indexing on foreign keys and frequently queried fields like `email`, `property_id`, and `booking_id` for optimal performance.

## Normalization

The schema is fully normalized up to **Third Normal Form (3NF)** to:
- Eliminate redundant data
- Ensure functional dependency
- Maintain data consistency across joins

## Use Cases Supported

- Registering and authenticating users
- Posting and managing property listings
- Searching and booking available properties
- Handling secure and traceable payments
- Leaving and reading reviews
- Real-time messaging between platform users
