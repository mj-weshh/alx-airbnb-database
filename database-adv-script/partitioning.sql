-- =============================================
-- Table Partitioning for Airbnb Database
-- =============================================
-- This script implements monthly range partitioning on the bookings table
-- to improve query performance for date-based queries.

-- =============================================
-- Step 1: Create a new partitioned table
-- =============================================
SET @preparedStatement = (SELECT IF(
    (SELECT COUNT(*) FROM INFORMATION_SCHEMA.TABLES 
     WHERE TABLE_SCHEMA = DATABASE() 
     AND TABLE_NAME = 'bookings_partitioned') > 0,
    'DROP TABLE bookings_partitioned',
    'SELECT ''Table does not exist'''
));

PREPARE stmt FROM @preparedStatement;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- Create the partitioned table with the same structure as the original
CREATE TABLE bookings_partitioned (
    booking_id UUID NOT NULL,
    property_id UUID NOT NULL,
    user_id UUID NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    total_price DECIMAL(10, 2) NOT NULL,
    status ENUM('pending', 'confirmed', 'canceled') NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (booking_id, start_date),  -- Include partition key in primary key
    KEY idx_bookings_property_id (property_id),
    KEY idx_bookings_user_id (user_id),
    KEY idx_bookings_dates (start_date, end_date),
    KEY idx_bookings_user_status (user_id, status),
    CONSTRAINT fk_booking_property FOREIGN KEY (property_id) 
        REFERENCES properties(property_id) ON DELETE CASCADE,
    CONSTRAINT fk_booking_user FOREIGN KEY (user_id) 
        REFERENCES users(user_id) ON DELETE CASCADE
) 
PARTITION BY RANGE (TO_DAYS(start_date)) (
    PARTITION p_202201 VALUES LESS THAN (TO_DAYS('2022-02-01')),
    PARTITION p_202202 VALUES LESS THAN (TO_DAYS('2022-03-01')),
    PARTITION p_202203 VALUES LESS THAN (TO_DAYS('2022-04-01')),
    PARTITION p_202204 VALUES LESS THAN (TO_DAYS('2022-05-01')),
    PARTITION p_202205 VALUES LESS THAN (TO_DAYS('2022-06-01')),
    PARTITION p_202206 VALUES LESS THAN (TO_DAYS('2022-07-01')),
    PARTITION p_202207 VALUES LESS THAN (TO_DAYS('2022-08-01')),
    PARTITION p_202208 VALUES LESS THAN (TO_DAYS('2022-09-01')),
    PARTITION p_202209 VALUES LESS THAN (TO_DAYS('2022-10-01')),
    PARTITION p_202210 VALUES LESS THAN (TO_DAYS('2022-11-01')),
    PARTITION p_202211 VALUES LESS THAN (TO_DAYS('2022-12-01')),
    PARTITION p_202212 VALUES LESS THAN (TO_DAYS('2023-01-01')),
    PARTITION p_202301 VALUES LESS THAN (TO_DAYS('2023-02-01')),
    PARTITION p_202302 VALUES LESS THAN (TO_DAYS('2023-03-01')),
    PARTITION p_202303 VALUES LESS THAN (TO_DAYS('2023-04-01')),
    PARTITION p_202304 VALUES LESS THAN (TO_DAYS('2023-05-01')),
    PARTITION p_202305 VALUES LESS THAN (TO_DAYS('2023-06-01')),
    PARTITION p_202306 VALUES LESS THAN (TO_DAYS('2023-07-01')),
    PARTITION p_202307 VALUES LESS THAN (TO_DAYS('2023-08-01')),
    PARTITION p_202308 VALUES LESS THAN (TO_DAYS('2023-09-01')),
    PARTITION p_202309 VALUES LESS THAN (TO_DAYS('2023-10-01')),
    PARTITION p_202310 VALUES LESS THAN (TO_DAYS('2023-11-01')),
    PARTITION p_202311 VALUES LESS THAN (TO_DAYS('2023-12-01')),
    PARTITION p_202312 VALUES LESS THAN (TO_DAYS('2024-01-01')),
    PARTITION p_future VALUES LESS THAN MAXVALUE
);

-- =============================================
-- Step 2: Copy data from original table to partitioned table
-- =============================================
-- Note: This operation may take time for large tables
-- Consider running during off-peak hours
INSERT INTO bookings_partitioned
SELECT * FROM bookings;

-- =============================================
-- Step 3: Create a procedure to add new monthly partitions
-- =============================================
DELIMITER //
CREATE PROCEDURE add_monthly_partition()
BEGIN
    DECLARE next_month DATE;
    DECLARE next_month_start DATE;
    DECLARE next_month_name VARCHAR(10);
    
    -- Get the first day of next month
    SET next_month = DATE_FORMAT(DATE_ADD(CURDATE(), INTERVAL 1 MONTH), '%Y-%m-01');
    SET next_month_start = DATE_ADD(next_month, INTERVAL 1 MONTH);
    SET next_month_name = CONCAT('p_', DATE_FORMAT(next_month, '%Y%m'));
    
    -- Add the new partition
    SET @sql = CONCAT('ALTER TABLE bookings_partitioned REORGANIZE PARTITION p_future INTO (
        PARTITION ', next_month_name, ' VALUES LESS THAN (TO_DAYS(\'', 
        next_month_start, '\')),
        PARTITION p_future VALUES LESS THAN MAXVALUE
    )');
    
    PREPARE stmt FROM @sql;
    EXECUTE stmt;
    DEALLOCATE PREPARE stmt;
    
    SELECT CONCAT('Added partition ', next_month_name, ' for dates before ', next_month_start) AS result;
END //
DELIMITER ;

-- =============================================
-- Step 4: Create a procedure to drop old partitions
-- =============================================
DELIMITER //
CREATE PROCEDURE drop_old_partitions(IN months_to_keep INT)
BEGIN
    DECLARE done INT DEFAULT FALSE;
    DECLARE part_name VARCHAR(50);
    DECLARE part_date DATE;
    DECLARE cutoff_date DATE;
    DECLARE cur CURSOR FOR 
        SELECT PARTITION_NAME, 
               STR_TO_DATE(SUBSTRING_INDEX(SUBSTRING_INDEX(PARTITION_DESCRIPTION, '(', -1), ')', 1), '%Y-%m-%d') as part_date
        FROM INFORMATION_SCHEMA.PARTITIONS 
        WHERE TABLE_SCHEMA = DATABASE() 
        AND TABLE_NAME = 'bookings_partitioned' 
        AND PARTITION_NAME != 'p_future'
        ORDER BY PARTITION_ORDINAL_POSITION;
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;
    
    -- Calculate the cutoff date
    SET cutoff_date = DATE_SUB(CURDATE(), INTERVAL months_to_keep MONTH);
    
    OPEN cur;
    read_loop: LOOP
        FETCH cur INTO part_name, part_date;
        IF done OR part_date IS NULL THEN
            LEAVE read_loop;
        END IF;
        
        IF part_date < cutoff_date THEN
            -- Drop the old partition
            SET @sql = CONCAT('ALTER TABLE bookings_partitioned DROP PARTITION ', part_name);
            PREPARE stmt FROM @sql;
            EXECUTE stmt;
            DEALLOCATE PREPARE stmt;
            
            SELECT CONCAT('Dropped partition: ', part_name, ' (data before ', part_date, ')') AS message;
        END IF;
    END LOOP;
    CLOSE cur;
END //
DELIMITER ;

-- =============================================
-- Step 5: Create a view for backward compatibility
-- =============================================
CREATE OR REPLACE VIEW bookings AS
SELECT * FROM bookings_partitioned;

-- =============================================
-- Step 6: Create a procedure to switch to the partitioned table
-- =============================================
DELIMITER //
CREATE PROCEDURE switch_to_partitioned()
BEGIN
    DECLARE CONTINUE HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;
    
    START TRANSACTION;
    
    -- Rename original table
    RENAME TABLE bookings TO bookings_old, bookings_partitioned TO bookings;
    
    -- Recreate the view to point to the new table
    DROP VIEW IF EXISTS bookings;
    CREATE VIEW bookings AS SELECT * FROM bookings_partitioned;
    
    -- Verify data integrity
    SET @original_count = (SELECT COUNT(*) FROM bookings_old);
    SET @new_count = (SELECT COUNT(*) FROM bookings);
    
    IF @original_count = @new_count THEN
        COMMIT;
        SELECT 'Successfully switched to partitioned table' AS message;
    ELSE
        ROLLBACK;
        SELECT CONCAT('Data count mismatch. Original: ', @original_count, ', New: ', @new_count) AS error;
    END IF;
END //
DELIMITER ;

-- =============================================
-- Step 7: Example queries to demonstrate partitioning
-- =============================================

-- Example 1: Query that benefits from partitioning
-- This query will only scan the relevant partitions
EXPLAIN PARTITIONS
SELECT * FROM bookings
WHERE start_date BETWEEN '2023-01-01' AND '2023-01-31';

-- Example 2: Query with date range that spans multiple partitions
EXPLAIN PARTITIONS
SELECT 
    DATE_FORMAT(start_date, '%Y-%m') AS month,
    COUNT(*) AS booking_count,
    SUM(total_price) AS total_revenue
FROM bookings
WHERE start_date BETWEEN '2023-01-01' AND '2023-06-30'
GROUP BY DATE_FORMAT(start_date, '%Y-%m')
ORDER BY month;

-- Example 3: Query that doesn't use partitioning (full scan)
-- This will scan all partitions
EXPLAIN PARTITIONS
SELECT * FROM bookings
WHERE status = 'confirmed';

-- =============================================
-- Step 8: Maintenance procedures
-- =============================================
-- To add a new partition for next month:
-- CALL add_monthly_partition();

-- To drop partitions older than 12 months:
-- CALL drop_old_partitions(12);

-- To switch to the partitioned table (after verifying data):
-- CALL switch_to_partitioned();

-- =============================================
-- Notes:
-- 1. The original table will be renamed to bookings_old after switching
-- 2. Keep the old table for a while to ensure everything works
-- 3. Drop the old table when confident: DROP TABLE bookings_old;
-- 4. Schedule monthly maintenance to add new partitions and drop old ones
-- =============================================
