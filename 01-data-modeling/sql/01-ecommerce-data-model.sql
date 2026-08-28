-- Create Database
CREATE DATABASE ecommerce

-- Connect to the database
-- In psql (SQL shell), you can connect to the database using the following command:
-- \l -> to list all databases
-- \c ecommerce -> to connect to the database
-- \dt -> to list all tables in the connected database
-- \d table_name -> to describe the structure of a specific table
-- \q -> to quit the psql shell

-- =========================================
-- 1. Users Table
-- =========================================
CREATE TABLE users (
        id INT PRIMARY KEY, 
        full_name VARCHAR(255) NOT NULL, 
        email VARCHAR(255) NOT NULL UNIQUE, 
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    );

-- =========================================
-- 2. Categories Table
-- =========================================
CREATE TABLE categories (
        id INT PRIMARY KEY, 
        name VARCHAR(255) NOT NULL
    );

-- =========================================
-- 3.Products Table
-- =========================================
 CREATE TABLE products (
        id INT PRIMARY KEY, 
        category_id INT NOT NULL, 
        name VARCHAR(255) NOT NULL, 
        price DECIMAL NOT NULL, 
        stock INTEGER, 
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, 
        
        CONSTRAINT fk_product_category 
        FOREIGN KEY (category_id) 
        REFERENCES categories(id)
    );

-- =========================================
-- 4. Orders Table
-- =========================================
CREATE TABLE orders (
        id INT PRIMARY KEY, 
        user_id INTEGER NOT NULL, 
        status VARCHAR(100) NOT NULL DEFAULT 'pending', 
        total_amount DECIMAL NOT NULL, 
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, 
        
        CONSTRAINT fk_order_user 
        FOREIGN KEY (user_id) 
        REFERENCES users(id)
    );

-- =========================================
-- 5. Order Items Table
-- =========================================
CREATE TABLE order_items (
        id INT PRIMARY KEY,
        order_id INTEGER NOT NULL,
        product_id INTEGER NOT NULL,
        quantity INTEGER NOT NULL,
        unit_price DECIMAL NOT NULL,

        CONSTRAINT fk_order_item_order
        FOREIGN KEY (order_id)
        REFERENCES orders(id),

        CONSTRAINT fk_order_item_product
        FOREIGN KEY (product_id)
        REFERENCES products(id),

        CONSTRAINT chk_quantity
        CHECK (quantity >= 0),

        CONSTRAINT chk_unit_price
        CHECK (unit_price >= 0)
    );

-- =========================================
-- 6. Insert Sample Data into Users Table
-- =========================================
INSERT INTO users (id, full_name, email)
        VALUES
        (1, 'Krish Makwana', 'krish07@dataengineering.com'),
        (2, 'Bhupendra Singh', 'bhupendra28@dataengineering.com'),
        (3, 'Tirth Patel', 'tirth16@dataengineering.com'),
        (4, 'Kris Patel', 'kris37@dataengineering.com');

-- =========================================
-- 7. Insert Sample Data into Categories Table
-- =========================================
INSERT INTO categories (id, name)
        VALUES
        (1, 'Electronics'),
        (2, 'Fashion'),
        (3, 'Furniture'),
        (4, 'Sport');

-- =========================================
-- 8. Insert Sample Data into Products Table
-- =========================================
INSERT INTO products (id, category_id, name, price, stock)
        VALUES
        (1, 1, 'Laptop', 88000.90, 10),
        (2, 1, 'Mouse', 800.50, 50),
        (3, 2, 'T-Shirt', 399.00, 100),
        (4, 4, 'Badminton Shuttlecocks', 199.00, 50),
        (5, 3, 'Dining Chair', 999.00, 20),
        (6, 4, 'Table Tennis Ball', 199.00, 60);

-- =========================================
-- 9. Insert Sample Data into Orders Table
-- =========================================
 INSERT INTO orders (id, user_id, status, total_amount)
        VALUES
        (1, 1, 'processing', 88801.40),
        (2, 2, 'pending', 789.00),
        (3, 4, 'shipped', 199.00);

-- =========================================
-- 10. Insert Sample Data into Order Items Table
-- =========================================
 INSERT INTO order_items (id, order_id, product_id, quantity, unit_price)
        VALUES
        (1, 1, 1, 1, 88000.90),
        (2, 1, 2, 1, 800.50),
        (3, 2, 3, 2, 399.00),
        (4, 3, 4, 1, 199.00);

-- =========================================
-- 11. Validate the  Users table
-- =========================================
 SELECT * FROM users;