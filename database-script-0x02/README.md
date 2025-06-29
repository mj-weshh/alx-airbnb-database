# Airbnb Clone - Database Seed Script

## Overview

This SQL script is designed to populate the Airbnb Clone database with realistic sample data. The data represents common entities and interactions in a rental marketplace application, such as users, properties, bookings, payments, reviews, and messages.

The purpose of this seeding script is to simulate a functional environment for development and testing. It ensures that all relationships are correctly established and reflects real-world usage patterns to validate database integrity and system behavior.

## Seeded Tables and Data

### 1. Users

Three users are added:
- A guest user
- A host user
- An admin user

Each user has a unique `user_id`, contact information, role, and timestamp for account creation.

### 2. Properties

Two properties are added:
- "Oceanview Retreat" in Mombasa, Kenya
- "Mountain Cabin" in Naivasha, Kenya

Both properties are owned by the same host (`u2`) and include attributes such as name, description, location, and price per night.

### 3. Bookings

Two bookings are made by the guest user (`u1`) for the listed properties:
- One confirmed booking
- One pending booking

Each booking includes start and end dates, total price, and booking status.

### 4. Payments

Each booking has an associated payment:
- Payment methods include Stripe and PayPal
- Amounts match the total price of the bookings

### 5. Reviews

The guest has left reviews for both properties:
- One 5-star review with a positive comment
- One 4-star review with constructive feedback

### 6. Messages

Messages between the guest and the host simulate a real conversation regarding property availability.

## Notes

- UUIDs (`u1`, `p1`, `b1`, etc.) are simplified for readability. In production environments, these would typically be generated automatically using `UUID()` or similar functions.
- Timestamps are generated using `CURRENT_TIMESTAMP` to reflect the time of insertion.
- All foreign key relationships are respected in the seeding order.
- The script can be executed using most relational database systems that support SQL (e.g., PostgreSQL, MySQL).

## Usage

Run this script after creating the database schema to populate the tables with initial data for development or testing purposes.

```bash
psql -U your_user -d your_database -f seed.sql
