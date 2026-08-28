-- Create Database
CREATE DATABASE amazon_sales

-- Connect to the database
-- In psql (SQL shell), you can connect to the database using the following command:
-- \l -> to list all databases
-- \c ecommerce -> to connect to the database
-- \dt -> to list all tables in the connected database
-- \d table_name -> to describe the structure of a specific table
-- \q -> to quit the psql shell

-- =========================================
-- 1. Product_categories Table
-- =========================================
CREATE TABLE IF NOT EXISTS product_categories(
    category_id INT PRIMARY KEY,
    category_name VARCHAR(255)
    );

-- =========================================
-- 2. Customers Table
-- =========================================
CREATE TABLE IF NOT EXISTS customers (
    user_id VARCHAR(255) PRIMARY KEY,
    user_name VARCHAR(255)
    );

-- =========================================
-- 3.Products Table
-- =========================================
CREATE TABLE IF NOT EXISTS products(
    product_id VARCHAR(255) PRIMARY KEY,
    product_name VARCHAR(255),
    category_id INT NOT NULL,
    about_product VARCHAR(255),
    img_link VARCHAR(255),
    product_link VARCHAR(255),

    CONSTRAINT fk_product_category 
        FOREIGN KEY (category_id) 
        REFERENCES product_categories(category_id)
    );

-- =========================================
-- 4. product_prices Table
-- =========================================
CREATE TABLE IF NOT EXISTS product_prices (
    price_id INT PRIMARY KEY,
    product_id VARCHAR(255) NOT NULL,
    actual_price VARCHAR(255) NOT NULL,
    discounted_price VARCHAR(255) NOT NULL,
    discount_percentage VARCHAR(255) NOT NULL,

    CONSTRAINT fk_price_product
        FOREIGN KEY (product_id)
        REFERENCES products(product_id)
);

-- =========================================
-- 5. Reviews Table
-- =========================================
CREATE TABLE IF NOT EXISTS reviews (
    review_id VARCHAR(255) PRIMARY KEY,
    product_id VARCHAR(255) NOT NULL,
    user_id VARCHAR(255) NOT NULL,
    review_title VARCHAR(500),
    review_content TEXT,
    rating DECIMAL(3,2),
    rating_count INT,

    CONSTRAINT fk_review_product
        FOREIGN KEY (product_id)
        REFERENCES products(product_id),

    CONSTRAINT fk_review_user
        FOREIGN KEY (user_id)
        REFERENCES customers(user_id)
);

-- =========================================
-- 6. Insert Data into product_categories Table
-- =========================================
INSERT INTO product_categories(
    category_id, category_name)
    VALUES 
    (%s, %s)

-- =========================================
-- 7. Insert Data into Customers Table
-- =========================================
 INSERT INTO customers(
    user_id, user_name)
    VALUES 
    (%s, %s)

-- =========================================
-- 8. Insert Data into Products Table
-- =========================================
INSERT INTO products(
    product_id, product_name, category_id, about_product, img_link, product_link)
    VALUES 
    (%s, %s, %s, %s, %s, %s)

-- =========================================
-- 9. Insert Data into Product_prices Table
-- =========================================
 INSERT INTO product_prices(
    price_id, product_id, actual_price, discounted_price, discount_percentage)
    VALUES 
    (%s, %s, %s, %s, %s)

-- =========================================
-- 10. Insert Data into Reviews Table
-- =========================================
INSERT INTO reviews(
    review_id, product_id, user_id, review_title, review_content, rating, rating_count)
    VALUES 
    (%s, %s, %s, %s, %s, %s, %s)

-- =========================================
-- 11. Validate the  Users table
-- =========================================
 SELECT * FROM Product_categories;