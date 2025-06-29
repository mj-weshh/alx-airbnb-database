# 📘 Entity and Relationship Definition

## 🔹 Entities and Their Attributes

### **1. User**
- `user_id`: UUID, **Primary Key**
- `first_name`: VARCHAR, **NOT NULL**
- `last_name`: VARCHAR, **NOT NULL**
- `email`: VARCHAR, **UNIQUE, NOT NULL**
- `password_hash`: VARCHAR, **NOT NULL**
- `phone_number`: VARCHAR, *nullable*
- `role`: ENUM('guest', 'host', 'admin'), **NOT NULL**
- `created_at`: TIMESTAMP, **DEFAULT CURRENT_TIMESTAMP**

---

### **2. Property**
- `property_id`: UUID, **Primary Key**
- `host_id`: UUID, **Foreign Key → User(user_id)**
- `name`: VARCHAR, **NOT NULL**
- `description`: TEXT, **NOT NULL**
- `location`: VARCHAR, **NOT NULL**
- `pricepernight`: DECIMAL, **NOT NULL**
- `created_at`: TIMESTAMP, **DEFAULT CURRENT_TIMESTAMP**
- `updated_at`: TIMESTAMP, **ON UPDATE CURRENT_TIMESTAMP**

---

### **3. Booking**
- `booking_id`: UUID, **Primary Key**
- `property_id`: UUID, **Foreign Key → Property(property_id)**
- `user_id`: UUID, **Foreign Key → User(user_id)**
- `start_date`: DATE, **NOT NULL**
- `end_date`: DATE, **NOT NULL**
- `total_price`: DECIMAL, **NOT NULL**
- `status`: ENUM('pending', 'confirmed', 'canceled'), **NOT NULL**
- `created_at`: TIMESTAMP, **DEFAULT CURRENT_TIMESTAMP**

---

### **4. Payment**
- `payment_id`: UUID, **Primary Key**
- `booking_id`: UUID, **Foreign Key → Booking(booking_id)**
- `amount`: DECIMAL, **NOT NULL**
- `payment_date`: TIMESTAMP, **DEFAULT CURRENT_TIMESTAMP**
- `payment_method`: ENUM('credit_card', 'paypal', 'stripe'), **NOT NULL**

---

### **5. Review**
- `review_id`: UUID, **Primary Key**
- `property_id`: UUID, **Foreign Key → Property(property_id)**
- `user_id`: UUID, **Foreign Key → User(user_id)**
- `rating`: INTEGER, **CHECK BETWEEN 1–5, NOT NULL**
- `comment`: TEXT, **NOT NULL**
- `created_at`: TIMESTAMP, **DEFAULT CURRENT_TIMESTAMP**

---

### **6. Message**
- `message_id`: UUID, **Primary Key**
- `sender_id`: UUID, **Foreign Key → User(user_id)**
- `recipient_id`: UUID, **Foreign Key → User(user_id)**
- `message_body`: TEXT, **NOT NULL**
- `sent_at`: TIMESTAMP, **DEFAULT CURRENT_TIMESTAMP**

---

## 🔗 Relationships Between Entities

| **Entity A** | **Entity B** | **Relationship Type** | **Description** |
|--------------|--------------|------------------------|------------------|
| User         | Property     | 1 : N                  | A host (User) can list many Properties |
| User         | Booking      | 1 : N                  | A guest (User) can make multiple Bookings |
| User         | Review       | 1 : N                  | A User can leave multiple Reviews |
| User         | Message      | 1 : N                  | A User can send and receive multiple Messages |
| Property     | Booking      | 1 : N                  | A Property can be booked many times |
| Property     | Review       | 1 : N                  | A Property can have many Reviews |
| Booking      | Payment      | 1 : 1                  | A Booking has one corresponding Payment |


# ER Diagram for Airbnb Clone

Use this layout to design your ERD visually in Draw.io or any diagramming tool of your choice.

+-------------+                    +-----------------+        
|   User      |<--(host_id)--------|     Property    |        
+-------------+                    +-----------------+        
| user_id (PK)|--------+           | property_id (PK)|        
| first_name  |        |           | host_id (FK)    |        
| last_name   |        |           | name            |        
| email       |        |           | location        |        
| password    |        |           | price_per_night |        
| phone       |        |           | ...             |        
+-------------+        |           +-----------------+        
                       |                                   
                       |                                   
              +--------v--------+                          
              |    Booking      |                          
              +-----------------+                          
              | booking_id (PK) |                          
              | user_id (FK)    |                          
              | property_id(FK) |                          
              | start_date      |                          
              | end_date        |                          
              | total_price     |                          
              | status          |                          
              +--------+--------+                          
                       |                                   
                       |                                   
              +--------v-------+                          
              |    Payment     |                          
              +----------------+                          
              | payment_id (PK)|                          
              | booking_id (FK)|                          
              | amount         |                          
              | payment_method |                          
              | payment_date   |                          
              +----------------+                          

+-------------+           +------------------+             
|   Review    |<----------|     Property     |             
+-------------+           +------------------+             
| review_id   |                                  
| user_id (FK)|                                  
| property_id |                                  
| rating      |                                  
| comment     |                                  
| created_at  |                                  
+-------------+                                  

+-------------+           +-------------+                 
|  Message    |<--------->|    User     |                 
+-------------+           +-------------+                 
| message_id  |           | user_id (PK)|                 
| sender_id   |-----------|             |                 
| recipient_id|-----------|             |                 
| message_body|                                         
| sent_at     |                                         
+-------------+                                         

**Note** : Arrows indicate foreign key relationships.

- `User` can be both **sender** and **recipient** in the `Message` entity.
- `Property` belongs to a `User` (as **host**).
- `Booking` is made by a `User` for a `Property`.
- `Payment` is tied to a `Booking`.
- `Review` is created by a `User` for a `Property`.
