# Database Normalization Report

## Objective
Ensure the Airbnb Clone database schema adheres to the **Third Normal Form (3NF)** to eliminate redundancy, enhance data integrity, and optimize relational design.


## Step-by-Step Normalization Process


### 1. First Normal Form (1NF)
**Goal**: Eliminate repeating groups and ensure atomicity.

- All attributes in the schema are atomic (e.g., no multi-valued fields or nested tables).  
- Every table has a **primary key**.  
- No repeating groups exist.

**Example**: In the `Property` table, the amenities are not stored as a comma-separated list, avoiding a multi-valued attribute. If needed, we’d use a separate `Amenities` table with a many-to-many relationship.

---

### 2. Second Normal Form (2NF)
**Goal**: Eliminate partial dependencies (i.e., ensure that non-key attributes are fully dependent on the entire primary key).

All tables have **single-column primary keys**, so partial dependencies are not an issue.  
No table has attributes that depend only on part of a composite key (since composite keys are not used).

**Example**: In the `Booking` table, attributes like `total_price` and `status` depend fully on `booking_id`, not on `property_id` or `user_id` separately.

---

### 3. Third Normal Form (3NF)
**Goal**: Eliminate transitive dependencies (i.e., non-key attributes must depend only on the primary key).

All non-key attributes are **only dependent on the primary key** of their respective tables.

## Example Table Checks

### User Table
- All attributes directly describe the user.
- No transitive dependencies.
- Already in 3NF.

### Property Table
- `host_id` is a foreign key to `User`.
- All property-specific attributes are atomic and dependent on `property_id`.
- In 3NF.

### Booking Table
- Attributes like `start_date`, `end_date`, `total_price`, `status` all relate only to `booking_id`.
- In 3NF.

### Payment Table
- Depends on `booking_id` (1:1 relationship).
- All fields relate to the payment only.
- In 3NF.

### Review Table
- `rating`, `comment`, etc., are all dependent only on `review_id`.
- In 3NF.

### Message Table
- `sender_id`, `recipient_id`, `message_body`, `sent_at` are all atomic and relate to `message_id`.
- In 3NF.

## Final Assessment

All tables in the schema are **fully normalized to 3NF**.  
- No partial or transitive dependencies remain.
- Data is logically structured and minimal redundancy exists.
- Schema is scalable and efficient for querying and maintenance.

## Notes
- If we later introduce amenities or categories (e.g., property types), these should be extracted into their own lookup tables to maintain 3NF.
- If additional complex attributes are added (e.g., address as a string), consider normalization into separate tables (e.g., `Address`) if appropriate.

**Normalization Complete: Schema is in 3NF**