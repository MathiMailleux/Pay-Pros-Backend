-- ============================================
-- TODO LIST DATABASE SETUP
-- MySQL Database Schema
-- ============================================

-- Drop database if exists (optional - use with caution)
-- DROP DATABASE IF EXISTS todo_db;

-- Create database
CREATE DATABASE IF NOT EXISTS todo_db
CHARACTER SET utf8mb4
COLLATE utf8mb4_unicode_ci;

-- Use the database
USE todo_db;

-- ============================================
-- TABLES
-- ============================================

-- Users table
CREATE TABLE IF NOT EXISTS users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    email VARCHAR(191) UNIQUE NOT NULL,
    name VARCHAR(191) NOT NULL,
    password VARCHAR(191) NOT NULL,
    createdAt DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
    updatedAt DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3) ON UPDATE CURRENT_TIMESTAMP(3),
    INDEX idx_email (email)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Tasks table
CREATE TABLE IF NOT EXISTS tasks (
    id INT AUTO_INCREMENT PRIMARY KEY,
    title VARCHAR(191) NOT NULL,
    description TEXT,
    dueDate DATETIME(3),
    status ENUM('PENDING', 'COMPLETED') NOT NULL DEFAULT 'PENDING',
    userId INT NOT NULL,
    createdAt DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
    updatedAt DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3) ON UPDATE CURRENT_TIMESTAMP(3),
    INDEX idx_userId (userId),
    INDEX idx_status (status),
    INDEX idx_createdAt (createdAt),
    CONSTRAINT fk_task_user 
        FOREIGN KEY (userId) 
        REFERENCES users(id) 
        ON DELETE CASCADE 
        ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================
-- PRISMA MIGRATIONS TABLE (Optional)
-- This is created automatically by Prisma
-- ============================================

CREATE TABLE IF NOT EXISTS _prisma_migrations (
    id VARCHAR(36) PRIMARY KEY,
    checksum VARCHAR(64) NOT NULL,
    finished_at DATETIME(3),
    migration_name VARCHAR(255) NOT NULL,
    logs TEXT,
    rolled_back_at DATETIME(3),
    started_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
    applied_steps_count INT UNSIGNED NOT NULL DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================
-- INDEXES FOR PERFORMANCE
-- ============================================

-- Additional indexes for common queries
CREATE INDEX IF NOT EXISTS idx_task_user_status ON tasks(userId, status);
CREATE INDEX IF NOT EXISTS idx_task_dueDate ON tasks(dueDate);

-- ============================================
-- SAMPLE DATA (Optional - Comment out if not needed)
-- ============================================

-- Sample user (password is 'Test123!')
-- INSERT INTO users (email, name, password) VALUES 
-- ('john@example.com', 'John Doe', '$2b$10$YourHashedPasswordHere');

-- Sample tasks (uncomment and update userId after creating user)
-- INSERT INTO tasks (title, description, dueDate, status, userId) VALUES
-- ('Complete project documentation', 'Write comprehensive documentation for the TODO app', '2024-12-31 23:59:59', 'PENDING', 1),
-- ('Review code', 'Review and test all endpoints', '2024-12-25 18:00:00', 'PENDING', 1),
-- ('Deploy to production', 'Deploy application to production server', '2024-12-30 12:00:00', 'PENDING', 1);

-- ============================================
-- VIEWS (Optional - for reporting)
-- ============================================

-- View to get task statistics per user
CREATE OR REPLACE VIEW user_task_stats AS
SELECT 
    u.id AS userId,
    u.name AS userName,
    u.email AS userEmail,
    COUNT(t.id) AS totalTasks,
    SUM(CASE WHEN t.status = 'COMPLETED' THEN 1 ELSE 0 END) AS completedTasks,
    SUM(CASE WHEN t.status = 'PENDING' THEN 1 ELSE 0 END) AS pendingTasks,
    SUM(CASE WHEN t.dueDate < NOW() AND t.status = 'PENDING' THEN 1 ELSE 0 END) AS overdueTasks
FROM users u
LEFT JOIN tasks t ON u.id = t.userId
GROUP BY u.id, u.name, u.email;

-- ============================================
-- STORED PROCEDURES (Optional)
-- ============================================

DELIMITER //

-- Procedure to get user task summary
CREATE PROCEDURE IF NOT EXISTS GetUserTaskSummary(IN user_id INT)
BEGIN
    SELECT 
        COUNT(*) AS total_tasks,
        SUM(CASE WHEN status = 'COMPLETED' THEN 1 ELSE 0 END) AS completed,
        SUM(CASE WHEN status = 'PENDING' THEN 1 ELSE 0 END) AS pending,
        SUM(CASE WHEN dueDate < NOW() AND status = 'PENDING' THEN 1 ELSE 0 END) AS overdue
    FROM tasks
    WHERE userId = user_id;
END //

-- Procedure to clean old completed tasks
CREATE PROCEDURE IF NOT EXISTS CleanOldCompletedTasks(IN days_old INT)
BEGIN
    DELETE FROM tasks 
    WHERE status = 'COMPLETED' 
    AND updatedAt < DATE_SUB(NOW(), INTERVAL days_old DAY);
    
    SELECT ROW_COUNT() AS deleted_tasks;
END //

DELIMITER ;

-- ============================================
-- TRIGGERS (Optional)
-- ============================================

-- Trigger to prevent updating tasks of other users (additional security)
DELIMITER //

CREATE TRIGGER IF NOT EXISTS before_task_update
BEFORE UPDATE ON tasks
FOR EACH ROW
BEGIN
    -- Validate that essential fields are not null
    IF NEW.title IS NULL OR NEW.title = '' THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Task title cannot be empty';
    END IF;
END //

DELIMITER ;

-- ============================================
-- GRANTS (Optional - Create dedicated user)
-- ============================================

-- Create application user (run as root)
-- CREATE USER IF NOT EXISTS 'todo_app'@'localhost' IDENTIFIED BY 'secure_password_here';
-- GRANT SELECT, INSERT, UPDATE, DELETE ON todo_db.* TO 'todo_app'@'localhost';
-- FLUSH PRIVILEGES;

-- ============================================
-- VERIFICATION QUERIES
-- ============================================

-- Show all tables
SHOW TABLES;

-- Show users table structure
DESCRIBE users;

-- Show tasks table structure
DESCRIBE tasks;

-- Show table relationships
SELECT 
    TABLE_NAME,
    COLUMN_NAME,
    CONSTRAINT_NAME,
    REFERENCED_TABLE_NAME,
    REFERENCED_COLUMN_NAME
FROM INFORMATION_SCHEMA.KEY_COLUMN_USAGE
WHERE TABLE_SCHEMA = 'todo_db'
AND REFERENCED_TABLE_NAME IS NOT NULL;

-- ============================================
-- CLEANUP (Optional - use with extreme caution)
-- ============================================

-- To drop all tables (DANGEROUS - only for development reset)
-- SET FOREIGN_KEY_CHECKS = 0;
-- DROP TABLE IF EXISTS tasks;
-- DROP TABLE IF EXISTS users;
-- DROP TABLE IF EXISTS _prisma_migrations;
-- SET FOREIGN_KEY_CHECKS = 1;

-- ============================================
-- NOTES
-- ============================================

/*
IMPORTANT NOTES:

1. PREFERRED METHOD: Use Prisma migrations instead of this file
   - Run: npx prisma migrate dev
   - Prisma will create and manage tables automatically

2. USE THIS FILE ONLY IF:
   - You need to create the database manually
   - You want to understand the database structure
   - You need to set up database in production without Prisma CLI

3. PASSWORD HASHING:
   - Never store plain text passwords
   - Use bcrypt with at least 10 rounds
   - Example in Node.js: bcrypt.hash(password, 10)

4. CHARACTER SET:
   - utf8mb4 supports full Unicode including emojis
   - utf8mb4_unicode_ci provides case-insensitive sorting

5. INDEXES:
   - Created on frequently queried columns
   - Improves query performance
   - Use EXPLAIN to analyze query performance

6. FOREIGN KEYS:
   - ON DELETE CASCADE: When user is deleted, their tasks are deleted
   - ON UPDATE CASCADE: If user ID changes, tasks are updated

7. DATETIME(3):
   - Stores milliseconds precision
   - Required for Prisma compatibility
   - Format: YYYY-MM-DD HH:MM:SS.mmm

8. ENGINE=InnoDB:
   - Supports transactions
   - Supports foreign keys
   - Better for concurrent operations

TROUBLESHOOTING:

- If you get "Table already exists" error:
  Comment out the table creation or use DROP TABLE first

- If foreign key constraint fails:
  Make sure parent table (users) is created before child table (tasks)

- If character encoding issues:
  SET NAMES utf8mb4;
  SET CHARACTER SET utf8mb4;
*/

