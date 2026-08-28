# Amazon Sales Database Setup & Management with Python (`psycopg2`)

## How to Run
To get started with this project, clone the repository to your local machine:
```bash
git clone https://github.com/Mrinal-San/data-engineering-journey.git
```

## Overview
This project automates the creation, normalization, and population of a PostgreSQL database for Amazon Sales data. It uses Python's `pandas` library to read and process raw CSV sales data, extracting distinct entities (products, categories, users, prices, and reviews) to adhere to relational database principles. The `psycopg2` adapter is then used to connect to a local PostgreSQL instance, dynamically create the schema, and insert the processed data into respective tables.

## Prerequisites & Installation
Before running the script, ensure you have PostgreSQL installed and running on your local machine. You will also need Python installed with the following packages.

Install the required Python packages using `pip`:
```bash
pip install psycopg2 pandas
```

## Database Configuration
The connection to the PostgreSQL database is established using the following default configuration parameters. Make sure to update the `DB_PASS` with your actual PostgreSQL password if necessary:
* **Host**: `127.0.0.1` (Localhost)
* **Port**: `5432`
* **Database Name**: `amazon_sales`
* **User**: `postgres`
* **Password**: `your_pass`

## Database Schema Architecture
The raw Amazon sales data is normalized into a relational structure consisting of five primary tables.
```
+---------------------------+
|    product_categories     |
+---------------------------+
| category_id (PK)          |
| category_name             |
+---------------------------+
             ^
             |
             | category_id (FK)
             |
+------------+--------------+
|          products         |
+---------------------------+
| product_id (PK)           |
| product_name              |
| category_id (FK)          |
| about_product             |
| img_link                  |
| product_link              |
+------------+--------------+
             |
             |
       +-----+----------------------+
       |                            |
       | product_id (FK)            | product_id (FK)
       v                            v
+----------------------+    +---------------------------+
|   product_prices     |    |          reviews          |
+----------------------+    +---------------------------+
| price_id (PK)        |    | review_id (PK)            |
| product_id (FK)      |    | product_id (FK)            |
| actual_price         |    | user_id (FK)               |
| discounted_price     |    | review_title              |
| discount_percentage  |    | review_content            |
+----------------------+    | rating                    |
                            | rating_count              |
                            +-------------+-------------+
                                          |
                                          | user_id (FK)
                                          v
                               +----------------------+
                               |      customers       |
                               +----------------------+
                               | user_id (PK)         |
                               | user_name            |
                               +----------------------+

```
### Table Structure & Constraints

**1. `product_categories`**
* `category_id INT`: Unique identifier for the category.
* `category_name VARCHAR`: The full category path (e.g., Computers&Accessories|...).

**2. `customers`**
* `user_id VARCHAR`: Unique identifier for the user.
* `user_name VARCHAR`: Comma-separated list of user names associated with the reviews.

**3. `products`**
* `product_id VARCHAR`: The primary identifier for the product (e.g., ASIN).
* `product_name VARCHAR`: The name or title of the product.
* `category_id INT NOT NULL`: Foreign key reference to the product category.
* `about_product VARCHAR`: Description and features of the product.
* `img_link VARCHAR`: URL to the product image.
* `product_link VARCHAR`: URL to the product page on Amazon.

**4. `product_prices`**
* `price_id INT`: Unique identifier for the price record.
* `product_id VARCHAR NOT NULL`: Reference to the associated product.
* `actual_price VARCHAR NOT NULL`: Original price of the product.
* `discounted_price VARCHAR NOT NULL`: Price after discount.
* `discount_percentage VARCHAR NOT NULL`: The percentage of the discount applied.

**5. `reviews`**
* `review_id VARCHAR`: Unique identifier for the review.
* `product_id VARCHAR NOT NULL`: Reference to the reviewed product.
* `user_id VARCHAR NOT NULL`: Reference to the user who posted the review.
* `review_title VARCHAR`: The title of the review.
* `review_content VARCHAR`: The detailed text of the review.
* `rating VARCHAR`: The numerical rating given (e.g., 4.2).
* `rating_count VARCHAR`: Total number of ratings the product has received.

## Step-by-Step Execution Workflow
1. **Database Initialization**: The script connects to the default `postgres` database to drop the existing `amazon_sales` database (if it exists) and create a fresh instance.
2. **Data Extraction**: Loads the raw Amazon sales dataset from a CSV file using `pandas`.
3. **Data Transformation**: 
   * Generates unique sequential IDs (`category_id`, `price_id`) using `pandas.factorize()`.
   * Splits the main dataframe into smaller subsets matching the target table structures (`products`, `product_categories`, `customers`, `reviews`, `product_prices`).
4. **Schema Creation**: Executes `CREATE TABLE IF NOT EXISTS` queries for all five tables using `psycopg2`.
5. **Data Loading**: Iterates through the transformed pandas DataFrames row by row and inserts the records into the respective PostgreSQL tables using parameterized SQL `INSERT` queries.

## Error Handling & Best Practices
* **Connection Management**: The script utilizes `try...except...finally` blocks during database creation to ensure that cursors and connections are properly closed even if an execution error occurs.
* **Autocommit Mode**: `conn.set_session(autocommit=True)` is used specifically during the database creation step since PostgreSQL does not allow `CREATE DATABASE` commands inside a transaction block.
* **Idempotency**: The inclusion of `DROP DATABASE IF EXISTS` and `CREATE TABLE IF NOT EXISTS` ensures the script can be rerun multiple times without failing due to pre-existing structures.
* **Exception Catching**: Implementations of `try...except` are used when reading files (e.g., prompting "enter the file path" if the CSV is missing or misconfigured).