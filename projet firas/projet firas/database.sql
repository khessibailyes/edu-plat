-- ============================================================
--  Educational & Management Platform - Database Schema
-- ============================================================

CREATE DATABASE IF NOT EXISTS edu_platform
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_unicode_ci;

USE edu_platform;

-- ─────────────────────────────────────────────
--  Table: users
-- ─────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS users (
    id          INT UNSIGNED    AUTO_INCREMENT PRIMARY KEY,
    full_name   VARCHAR(120)    NOT NULL,
    email       VARCHAR(180)    NOT NULL UNIQUE,
    password    VARCHAR(255)    NOT NULL,
    role        ENUM('admin','teacher','student') NOT NULL DEFAULT 'student',
    created_at  TIMESTAMP       DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- ─────────────────────────────────────────────
--  Table: messages
-- ─────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS messages (
    id          INT UNSIGNED    AUTO_INCREMENT PRIMARY KEY,
    sender_id   INT UNSIGNED    NOT NULL,
    receiver_id VARCHAR(20)     NOT NULL COMMENT '''all'' or a user id',
    content     TEXT            NOT NULL,
    type        ENUM('private','public') NOT NULL DEFAULT 'private',
    timestamp   TIMESTAMP       DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (sender_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB;

-- ─────────────────────────────────────────────
--  Table: products
-- ─────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS products (
    id              INT UNSIGNED    AUTO_INCREMENT PRIMARY KEY,
    product_name    VARCHAR(200)    NOT NULL,
    price           DECIMAL(10,2)   NOT NULL,
    stock_quantity  INT UNSIGNED    NOT NULL DEFAULT 0
) ENGINE=InnoDB;

-- ─────────────────────────────────────────────
--  Table: documents
-- ─────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS documents (
    id          INT UNSIGNED    AUTO_INCREMENT PRIMARY KEY,
    teacher_id  INT UNSIGNED    NOT NULL,
    file_path   VARCHAR(500)    NOT NULL,
    description TEXT,
    upload_date TIMESTAMP       DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (teacher_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB;

-- ─────────────────────────────────────────────
--  View: products sorted by price ASC
-- ─────────────────────────────────────────────
CREATE OR REPLACE VIEW view_products_by_price AS
    SELECT id, product_name, price, stock_quantity
    FROM   products
    ORDER  BY price ASC;

-- ─────────────────────────────────────────────
--  View: users listed alphabetically
-- ─────────────────────────────────────────────
CREATE OR REPLACE VIEW view_users_alphabetical AS
    SELECT id, full_name, email, role, created_at
    FROM   users
    ORDER  BY full_name ASC;

-- ─────────────────────────────────────────────
--  View: products with quantity between 10 and 30
-- ─────────────────────────────────────────────
CREATE OR REPLACE VIEW view_products_mid_stock AS
    SELECT id, product_name, price, stock_quantity
    FROM   products
    WHERE  stock_quantity >= 10
      AND  stock_quantity <= 30;

-- ─────────────────────────────────────────────
--  Seed: default admin account
--  Password: Admin@1234  (bcrypt hash)
-- ─────────────────────────────────────────────
INSERT IGNORE INTO users (full_name, email, password, role) VALUES
('Administrator', 'admin@edu.local',
 '$2y$12$/vb02R0G2WD7H0z8tiIn6ebWrkiPcW98XWWZGN1SbJaDL7vev55fW',
 'admin');

-- ─────────────────────────────────────────────
--  Seed: sample products
-- ─────────────────────────────────────────────
INSERT INTO products (product_name, price, stock_quantity) VALUES
('Mathematics Textbook',  29.99,  5),
('Physics Workbook',      19.99, 15),
('Chemistry Lab Guide',   34.50, 10),
('Biology Atlas',         45.00, 30),
('History Compendium',    22.00, 50),
('Literature Anthology',  18.75, 25),
('Programming Handbook',  55.00,  8),
('Art & Design Manual',   40.00, 20);
