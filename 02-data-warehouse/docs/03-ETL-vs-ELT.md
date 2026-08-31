# ETL vs. ELT

This document provides a comprehensive overview of fundamental data engineering and data warehousing concepts: **ETL vs ELT**, **Data Marts**, and **Slowly Changing Dimensions (SCD)**. 

---

Both ETL and ELT are data integration processes that move data from source systems to a target system (like a Data Warehouse or Data Lake). The difference lies in **when** and **where** the data transformation occurs.

### ETL (Extract, Transform, Load)
In ETL, data is extracted from the source, transformed in a middle-tier staging server or processing engine, and *then* loaded into the target data warehouse.
* **Best for:** On-premise databases with limited compute power, complex transformations requiring specialized tools (like Informatica or Talend), and strict data compliance where sensitive data (PII) must be masked before entering the warehouse.

### ELT (Extract, Load, Transform)
In ELT, raw data is extracted and loaded directly into the target system. The transformation happens *inside* the data warehouse using its own compute power.
* **Best for:** Modern cloud data warehouses (Snowflake, BigQuery, Redshift) that have massive, scalable compute power. It allows analysts to access raw data quickly and use SQL-based tools (like dbt) to transform data.

### Example Scenario
Imagine an e-commerce company extracting daily sales data from a MySQL database.
* **ETL Approach:** A Python script (or Apache Spark) extracts the raw sales data. While in transit (in memory/Spark), the script aggregates the total sales per user and removes credit card details. Only the clean, aggregated data is loaded into the warehouse.
* **ELT Approach:** Fivetran (an ingestion tool) extracts the raw sales data and dumps it exactly as-is into Snowflake. Once the raw data is in Snowflake, a scheduled SQL query runs inside Snowflake to aggregate the data and hide credit card details into a new, clean view for business users.

---

## 2. Data Mart

A **Data Mart** is a curated subset of a Data Warehouse that is designed to serve a specific department, team, or business line (e.g., Sales, HR, Finance). 

While an Enterprise Data Warehouse (EDW) holds all the data for the entire organization, it can be overwhelmingly large, complex to navigate, and slow to query. A data mart provides a simplified, highly optimized, and secure view of only the data that a specific team needs.

### Example Scenario
A global retail company has a massive 500TB Data Warehouse containing data about supply chain logistics, employee payroll, marketing campaigns, and store sales.
* **The Problem:** The Marketing team just wants to analyze the ROI of their recent Facebook ads. Querying the entire EDW is slow, and they have to sift through hundreds of irrelevant tables.
* **The Solution (Data Mart):** The data engineering team builds a **"Marketing Data Mart"**. This mart only contains three tables: `Ad_Spend`, `Campaign_Metrics`, and `Customer_Conversions`. It updates nightly. Now, the Marketing team's Tableau dashboards connect directly to this tiny, lightning-fast Data Mart instead of the massive EDW.

---

## 3. Slowly Changing Dimensions (SCD)

In data warehousing, dimension tables store descriptive attributes (like Customers, Products, or Stores). However, these attributes change over time (a customer moves to a new city, a product's category changes). **Slowly Changing Dimensions (SCD)** are the strategies used to manage and track these changes.

There are several types of SCDs, but Types 1, 2, and 3 are the most common.

### Example Scenario:
Customer **John Doe** lives in **New York**. 
* Original Record: `| ID: 1 | Name: John Doe | City: New York |`

John decides to move to **California**. How do we handle this in the database?

#### SCD Type 1: Overwrite (No History)
The old data is simply overwritten with the new data. You lose the historical context.
* **Result:** `| ID: 1 | Name: John Doe | City: California |`
* *Use when:* Tracking history doesn't matter (e.g., correcting a typo in a name).

#### SCD Type 2: Add a New Row (Full History)
This is the most common method. The old record is marked as inactive (or given an end date), and a brand new row is inserted for the new data.
* **Result:** 
  * Row A: `| ID: 1 | Name: John Doe | City: New York | Is_Active: False | Start_Date: 2022-01-01 | End_Date: 2026-08-31 |`
  * Row B: `| ID: 2 | Name: John Doe | City: California | Is_Active: True | Start_Date: 2026-08-31 | End_Date: 9999-12-31 |`
* *Use when:* You need to perfectly reconstruct history (e.g., matching old sales to the state John lived in *at the time of the sale*).

#### SCD Type 3: Add a New Column (Partial History)
Instead of adding a new row, a new column is added to track the previous value.
* **Result:** `| ID: 1 | Name: John Doe | Current_City: California | Previous_City: New York |`
* *Use when:* You only care about the *current* state and the *immediate previous* state, but not the entire historical journey.