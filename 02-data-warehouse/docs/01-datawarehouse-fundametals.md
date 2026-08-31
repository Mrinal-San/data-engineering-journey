# Data Warehousing & Dimensional Modeling

## 1. Prerequisites (Review from `01-data-modeling/doc`)
Before diving into Data Warehousing, it is essential to have a solid grasp of foundational data modeling concepts:
*   **Entity-Relationship (ER) Modeling:** Understanding entities (objects/concepts), attributes (properties), and relationships (1:1, 1:N, M:N).
*   **Keys:** The role of Primary Keys (PK) for unique identification and Foreign Keys (FK) for linking tables.
*   **Normalization:** The process of structuring a relational database to reduce data redundancy and improve data integrity (1NF, 2NF, 3NF). *Note: While source systems are normalized, Data Warehouses often intentionally denormalize data.*
*   **Relational Database Concepts:** Basic understanding of tables, joins, and SQL operations.

---

## 2. What is a Data Warehouse (DWH)?

A Data Warehouse is a centralized repository that stores current and historical data from multiple operational systems. It is optimized for reporting, analytics, and business intelligence (BI).

### **The Business Perspective**
*   **Single Source of Truth (SSOT):** It breaks down data silos by combining data from various departments (e.g., Sales, HR, Finance) into one unified view.
*   **Decision Making:** It empowers executives and business users to make data-driven decisions by analyzing trends over time.
*   **Historical Context:** Unlike operational apps that only care about the *current* state of a customer, a DWH remembers the *entire history* of customer interactions.

### **The Technical Perspective**
*   **Optimized for Reads:** Designed specifically for complex analytical queries and aggregations across massive datasets, rather than fast transactional writes.
*   **Data Integration (ETL/ELT):** Data is Extracted from various sources, Transformed (cleaned, conformed, and structured), and Loaded into the warehouse.
*   **Subject-Oriented, Time-Variant, Non-Volatile:** Data is organized by business subjects (e.g., "Sales", "Customers"), includes historical timestamps, and is generally read-only once written.

---

## 3. Data Warehouse Architecture

A modern Data Warehouse typically follows a multi-tier architecture to process data from source to consumption:

1.  **Source Systems:** The operational systems, CRMs (e.g., Salesforce), ERPs, and flat files where raw data originates.
2.  **Staging Area:** A temporary storage layer where raw data is landed before applying complex transformations. This minimizes the impact on source systems.
3.  **Core Data Warehouse:** The centralized, integrated storage layer where historical and transformed data resides.
4.  **Data Marts (Optional):** Smaller, subset data warehouses focused on a specific business line or department (e.g., a "Marketing Data Mart").
5.  **Analytics / BI Layer:** The front-end tools (e.g., Tableau, PowerBI, Looker) where end-users run reports and visualize data.

---

## 4. OLTP vs. OLAP

Understanding the difference between operational databases and analytical databases is crucial:

| Feature | OLTP (Online Transaction Processing) | OLAP (Online Analytical Processing) |
| :--- | :--- | :--- |
| **Primary Purpose** | Run everyday day-to-day business operations. | Analyze business metrics for decision-making. |
| **Typical Users** | Frontline workers, automated applications. | Data Analysts, Business Intelligence, Executives. |
| **Data Structure** | Highly normalized (3NF) to prevent redundancy. | Denormalized (Star/Snowflake schema) for read efficiency. |
| **Query Types** | Simple, fast, row-level `INSERT`, `UPDATE`, `DELETE`. | Complex, heavy `SELECT` queries with aggregations and joins. |
| **Data Scope** | Current, up-to-date snapshot of the business. | Historical data over months or years (Time-variant). |
| **Performance Metric**| Transaction throughput (speed of writes). | Query response time (speed of reads on massive data). |

---

## 5. DWH Storage Technology

Traditional row-based databases (like standard PostgreSQL or MySQL) struggle with analytical workloads. Modern Data Warehouses use specialized technologies:

*   **Columnar Storage:** Instead of storing data row-by-row, data is stored column-by-column. Since analytical queries often select specific columns (e.g., `SUM(revenue)`) rather than entire rows, columnar storage drastically reduces disk I/O and improves query speed.
*   **MPP (Massively Parallel Processing):** DWH systems distribute query workloads across multiple compute nodes simultaneously (a "share-nothing" architecture), allowing them to process petabytes of data in seconds.
*   **Cloud Data Warehouses:** Modern platforms separate **storage** from **compute**, allowing organizations to scale them independently. Examples include:
    *   *Snowflake*
    *   *Google BigQuery*
    *   *Amazon Redshift*

---

## 6. Fact Tables and Dimensional Modeling

**Dimensional Modeling** (introduced by Ralph Kimball) is the standard technique for structuring data in a Data Warehouse. It divides data into two main types of tables: **Facts** and **Dimensions**, typically forming a **Star Schema**.

### **Fact Tables**
Fact tables store the **quantitative measurements** (metrics) of a business process.
*   **Characteristics:** They are usually massive, narrow tables containing foreign keys and numerical metrics.
*   **Examples:** `Sales_Amount`, `Quantity_Sold`, `Discount_Applied`.
*   **Types of Facts:**
    *   *Additive:* Can be summed across any dimension (e.g., Sales Amount).
    *   *Semi-Additive:* Can be summed across some dimensions but not others (e.g., Account Balance cannot be summed across Time).
    *   *Non-Additive:* Cannot be summed at all (e.g., Ratios, Percentages).

### **Dimension Tables**
Dimension tables store the **descriptive context** (the "Who, What, Where, When, and Why") surrounding a business event.
*   **Characteristics:** They are usually wider tables (many columns) with fewer rows compared to fact tables, containing heavy text and attributes used for grouping and filtering.
*   **Examples:** `Dim_Customer` (Name, Address, Segment), `Dim_Product` (SKU, Category, Brand), `Dim_Date` (Year, Quarter, Month, Holiday_Flag).
*   **SCD (Slowly Changing Dimensions):** Techniques used to manage how descriptive attributes change over time (e.g., if a customer moves to a new city, do we overwrite the old city or keep a historical record?).
