# E-Commerce Database Setup & Management with Python (`psycopg2`)

A comprehensive step-by-step guide on establishing a connection between **Python** and a **PostgreSQL** database using the `psycopg2` adapter. This project demonstrates how to programmatically construct a relational database schema for an **E-Commerce platform**, populate it with seed data, execute validation queries, and properly handle resource cleanup.

---

## How to Run

1. **Start PostgreSQL**: Make sure your local or remote PostgreSQL server is running.
2. **Configure Credentials**: Update `DB_HOST`, `DB_USER`, `DB_PASS`, and `DB_PORT` in your script to match your environment.
3. **Execute Script / Notebook**: Run the Python script or Jupyter Notebook sequentially cell by cell.

---

## Overview

This guide details how to build an end-to-end relational database infrastructure for an e-commerce backend using Python. The execution pipeline handles:
- Connection establishment to PostgreSQL.
- Database provisioning (`ecommerce`).
- Relational schema layout with Primary Keys, Foreign Keys, Default values, and Check constraints.
- Seed data insertion for users, categories, products, orders, and order items.
- Querying and resource management.

---

## Prerequisites & Installation

### Requirements
- **Python 3.8+**
- **PostgreSQL Server** (locally installed or accessible via IP)

### Install Dependencies
To interact with PostgreSQL from Python, install `psycopg2` (or `psycopg2-binary` for pre-compiled binaries):

```bash
pip install psycopg2
```

---

## Database Configuration

Define connection parameters before initiating database sessions:

```python
DB_HOST = "127.0.0.1"      # Database host address
DB_PORT = "5432"          # Default PostgreSQL port
DB_NAME = "postgres"      # Initial connection target (default system DB)
DB_USER = "postgres"      # Database user username
DB_PASS = "your_password" # Database user password
```

---

## Database Schema Architecture

The relational model consists of **5 main tables** designed to support basic e-commerce operations:

```
+------------------+         +------------------+         +------------------+
|      users       |         |    categories    |         |     products     |
+------------------+         +------------------+         +------------------+
| id (PK)          |         | id (PK)          |         | id (PK)          |
| full_name        |         | name             |         | category_id (FK) |
| email (UNIQUE)   |         +------------------+         | name             |
| created_at       |                  ^                   | price            |
+------------------+                  |                   | stock            |
         ^                            |                   | created_at       |
         |                            +-------------------+------------------+
         |                                                         ^
         |                                                         |
+--------+---------+                                     +---------+--------+
|      orders      |                                     |   order_items    |
+------------------+                                     +------------------+
| id (PK)          |                                     | id (PK)          |
| user_id (FK)     |                                     | order_id (FK)    |
| status           |                                     | product_id (FK)  |
| total_amount     |                                     | quantity (>0)    |
| created_at       |                                     | unit_price (>=0) |
+------------------+                                     +------------------+
         ^                                                         |
         +---------------------------------------------------------+
```

### Table Structure & Constraints

1. **`users`**: Stores user identity and account details.
   - `id`: Primary Key (`INT`)
   - `full_name`: User name (`VARCHAR(255)`)
   - `email`: Unique email address (`VARCHAR(255)`, `UNIQUE`)
   - `created_at`: Registration timestamp (`TIMESTAMP`, `DEFAULT CURRENT_TIMESTAMP`)

2. **`categories`**: Catalog category definitions.
   - `id`: Primary Key (`INT`)
   - `name`: Category name (`VARCHAR(255)`)

3. **`products`**: Inventory catalog items.
   - `id`: Primary Key (`INT`)
   - `category_id`: Foreign Key referencing `categories(id)`
   - `name`: Item name (`VARCHAR(255)`)
   - `price`: Product price (`DECIMAL`)
   - `stock`: Inventory count (`INTEGER`)
   - `created_at`: Listing timestamp (`TIMESTAMP`, `DEFAULT CURRENT_TIMESTAMP`)

4. **`orders`**: User order transactions.
   - `id`: Primary Key (`INT`)
   - `user_id`: Foreign Key referencing `users(id)`
   - `status`: Order status (`VARCHAR(100)`, `DEFAULT 'pending'`)
   - `total_amount`: Total order monetary amount (`DECIMAL`)
   - `created_at`: Order placement timestamp (`TIMESTAMP`, `DEFAULT CURRENT_TIMESTAMP`)

5. **`order_items`**: Line items per order.
   - `id`: Primary Key (`INT`)
   - `order_id`: Foreign Key referencing `orders(id)`
   - `product_id`: Foreign Key referencing `products(id)`
   - `quantity`: Item quantity (`INTEGER`, `CHECK (quantity > 0)`)
   - `unit_price`: Item unit price (`DECIMAL`, `CHECK (unit_price >= 0)`)

---

## Step-by-Step Execution Workflow

### 1. Dependencies & Connection Initialization

Establish an initial connection to the default `postgres` database to obtain execution privileges for database management tasks.

```python
import psycopg2

try:
    conn = psycopg2.connect(
        host=DB_HOST,
        dbname=DB_NAME,
        user=DB_USER,
        password=DB_PASS
    )
    cur = conn.cursor()
    # Set session autocommit to True to run DDL statements like CREATE DATABASE
    conn.set_session(autocommit=True)
    print("Successfully connected to PostgreSQL server.")
except psycopg2.Error as e:
    print("Error connecting to server:", e)
```

---

### 2. Database Creation & Reconnection

Create the project database `ecommerce`, close the default connection, and re-connect directly to the new `ecommerce` database.

```python
# Create target database
try:
    cur.execute("CREATE DATABASE ecommerce")
    print("Database 'ecommerce' created successfully.")
except psycopg2.Error as e:
    print("Unable to create Database (may already exist):", e)

# Update database target name
DB_NAME = 'ecommerce'

# Close current connection
try:
    conn.close()
except psycopg2.Error as e:
    print("Error closing connection:", e)

# Reconnect to newly created database
try:
    conn = psycopg2.connect(
        host=DB_HOST,
        dbname=DB_NAME,
        user=DB_USER,
        password=DB_PASS
    )
    cur = conn.cursor()
    conn.set_session(autocommit=True)
    print("Successfully connected to 'ecommerce' database.")
except psycopg2.Error as e:
    print("Error connecting to 'ecommerce':", e)
```

---

### 3. Table Schema Definition (DDL)

Execute SQL queries to construct tables with key constraints and integrity checks.

```python
# 1. Users Table
try:
    cur.execute("""
        CREATE TABLE users (
            id INT PRIMARY KEY, 
            full_name VARCHAR(255) NOT NULL, 
            email VARCHAR(255) NOT NULL UNIQUE, 
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        );
    """)
except psycopg2.Error as e:
    print("Create Users Table Failed:", e)

# 2. Categories Table
try:
    cur.execute("""
        CREATE TABLE categories (
            id INT PRIMARY KEY, 
            name VARCHAR(255) NOT NULL
        );
    """)
except psycopg2.Error as e:
    print("Create Categories Table Failed:", e)

# 3. Products Table
try:
    cur.execute("""
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
    """)
except psycopg2.Error as e:
    print("Create Products Table Failed:", e)

# 4. Orders Table
try:
    cur.execute("""
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
    """)
except psycopg2.Error as e:
    print("Create Orders Table Failed:", e)

# 5. Order Items Table
try:
    cur.execute("""
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
            CHECK (quantity > 0),

            CONSTRAINT chk_unit_price
            CHECK (unit_price >= 0)
        );
    """)
except psycopg2.Error as e:
    print("Create Order Items Table Failed:", e)
```

---

### 4. Data Ingestion & Seeding (DML)

Populate the database with dummy initial datasets for demonstration.

```python
# Seed Users
try:
    cur.execute("""
        INSERT INTO users (id, full_name, email)
        VALUES
        (1, 'Krish Makwana', 'krish07@dataengineering.com'),
        (2, 'Bhupendra Singh', 'bhupendra28@dataengineering.com'),
        (3, 'Tirth Patel', 'tirth16@dataengineering.com'),
        (4, 'Kris Patel', 'kris37@dataengineering.com');
    """)
except psycopg2.Error as e:
    print("Inserting Data into Users Failed:", e)

# Seed Categories
try:
    cur.execute("""
        INSERT INTO categories (id, name)
        VALUES
        (1, 'Electronics'),
        (2, 'Fashion'),
        (3, 'Furniture'),
        (4, 'Sport');
    """)
except psycopg2.Error as e:
    print("Inserting Data into Categories Failed:", e)

# Seed Products
try:
    cur.execute("""
        INSERT INTO products (id, category_id, name, price, stock)
        VALUES
        (1, 1, 'Laptop', 88000.90, 10),
        (2, 1, 'Mouse', 800.50, 50),
        (3, 2, 'T-Shirt', 399.00, 100),
        (4, 4, 'Badminton Shuttlecocks', 199.00, 50),
        (5, 3, 'Dining Chair', 999.00, 20),
        (6, 4, 'Table Tennis Ball', 199.00, 60);
    """)
except psycopg2.Error as e:
    print("Inserting Data into Products Failed:", e)

# Seed Orders
try:
    cur.execute("""
        INSERT INTO orders (id, user_id, status, total_amount)
        VALUES
        (1, 1, 'processing', 88801.40),
        (2, 2, 'pending', 789.00),
        (3, 4, 'shipped', 199.00);
    """)
except psycopg2.Error as e:
    print("Inserting Data into Orders Failed:", e)

# Seed Order Items
try:
    cur.execute("""
        INSERT INTO order_items (id, order_id, product_id, quantity, unit_price)
        VALUES
        (1, 1, 1, 1, 88000.90),
        (2, 1, 2, 1, 800.50),
        (3, 2, 3, 2, 399.00),
        (4, 3, 4, 1, 199.00);
    """)
except psycopg2.Error as e:
    print("Inserting Data into Order Items Failed:", e)
```

---

### 5. Data Validation & Inspection

Validate data by reading records using the cursor's `fetchone()` iteration pattern.

```python
try:
    cur.execute("SELECT * FROM users;")
    row = cur.fetchone()
    print("--- User Records ---")
    while row:
        print(row)
        row = cur.fetchone()
except psycopg2.Error as e:
    print("Error fetching Data:", e)
```

---

### 6. Resource Cleanup & Connection Teardown

Always release resources by explicitly closing cursor and connection handles.

```python
# Close the cursor and database connection
cur.close()
conn.close()
print("Cursor and Database connection successfully closed.")
```

---

## Error Handling & Best Practices

1. **Exception Management (`psycopg2.Error`)**:
   Wrap all database transactions and DDL/DML statements in `try-except` blocks to prevent script termination when encountering existing relations or duplicate primary key errors.

2. **Autocommit Mode (`autocommit = True`)**:
   PostgreSQL requires statements like `CREATE DATABASE` to be executed outside of explicit transaction blocks. Setting `conn.set_session(autocommit=True)` ensures queries execute immediately without manual `conn.commit()` calls.

3. **Referential Integrity**:
   Table creation order matters due to foreign key constraints:
   - `users` & `categories` must exist before creating `products` and `orders`.
   - `orders` & `products` must exist before creating `order_items`.

4. **Parameterized Queries (Production Note)**:
   For production applications, parameterized queries (e.g., `cur.execute("SELECT * FROM users WHERE id = %s", (user_id,))`) should be used to prevent SQL injection vulnerabilities.