# PostgreSQL Setup Guide

This guide explains how to download the LEGO SQL data and load it into a PostgreSQL database using `psql`.

## 1. Download the LEGO Data

First, download the data from the following location in the repository:

```text
01-data-warehouse/sql
```

Inside this directory, you should find the LEGO SQL file:

```text
lego.sql
```

The `lego.sql` file contains the SQL statements required to create and populate the LEGO dataset, including approximately 8 tables.

---

## 2. Make Sure PostgreSQL Is Installed

Before loading the data, make sure PostgreSQL is installed on your machine.

Verify that `psql` is available:

```bash
psql --version
```

You should see something similar to:

```text
psql (PostgreSQL 16.x)
```

If `psql` is not recognized, install PostgreSQL and make sure the PostgreSQL `bin` directory is included in your system's PATH.

---

## 3. Start PostgreSQL

Make sure your PostgreSQL server is running.

You can verify the connection using:

```bash
psql -U postgres
```

You may be prompted for your PostgreSQL password.

---

## 4. Create a Database for the LEGO Data

After connecting to PostgreSQL, create a new database:

```sql
CREATE DATABASE lego;
```

Then connect to the new database:

```sql
\c lego
```

You should see a message similar to:

```text
You are now connected to database "lego".
```

---

## 5. Load `lego.sql` into PostgreSQL

There are two recommended ways to load the SQL file.

### Option A — Load the file from inside `psql`

First, connect to the LEGO database:

```bash
psql -U postgres -d lego
```

Then run:

```sql
\i /path/to/lego.sql
```

For example, if the file is in your current directory:

```sql
\i lego.sql
```

If the file is located somewhere else, provide the complete path.

### Linux / macOS example

```sql
\i /home/username/project/01-data-warehouse/sql/lego.sql
```

### Windows example

```sql
\i 'C:/Users/username/project/01-data-warehouse/sql/lego.sql'
```

> **Tip:** On Windows, using `/` instead of `\` in the file path usually makes the `\i` command easier to use.

---

## 6. Alternative: Load the SQL File Directly from the Terminal

You can also load the file without entering `psql` first.

From your terminal:

```bash
psql -U postgres -d lego -f lego.sql
```

Or provide the complete path:

```bash
psql -U postgres -d lego -f /path/to/lego.sql
```

For Windows:

```bash
psql -U postgres -d lego -f "C:\Users\username\project\01-data-warehouse\sql\lego.sql"
```

If PostgreSQL asks for a password, enter the password for your PostgreSQL user.

---

## 7. Verify That the Tables Were Loaded

Connect to the LEGO database:

```bash
psql -U postgres -d lego
```

Inside `psql`, run:

```sql
\dt
```

This displays all tables in the database.

You should see approximately 8 LEGO-related tables.

Example:

```text
          List of tables
 Schema |          Name         | Type  |  Owner
--------+-----------------------+-------+----------
 public | lego_colors           | table | postgres
 public | lego_inventories      | table | postgres
 public | lego_inventory_parts  | table | postgres
 ...
```

---

## 8. View the Structure of a Table

To see the columns and data types of a table:

```sql
\d table_name
```

For example:

```sql
\d lego_colors
```

For more detailed information:

```sql
\d+ lego_colors
```

---

## 9. View the Data

To display the data inside a table:

```sql
SELECT * FROM table_name;
```

For example:

```sql
SELECT * FROM lego_colors;
```

If a table contains a lot of rows, it is better to limit the output:

```sql
SELECT * FROM lego_colors LIMIT 10;
```

This displays only the first 10 rows.

---

## 10. Useful `psql` Commands

Here are some useful commands for exploring the LEGO database:

| Command | Description |
|---|---|
| `\l` | List all databases |
| `\c lego` | Connect to the LEGO database |
| `\dt` | List all tables |
| `\d table_name` | Show table structure |
| `\d+ table_name` | Show detailed table structure |
| `\dn` | List schemas |
| `\du` | List PostgreSQL users/roles |
| `\q` | Exit `psql` |

---

## 11. Check the Number of Rows

To check how many records a table contains:

```sql
SELECT COUNT(*) FROM table_name;
```

For example:

```sql
SELECT COUNT(*) FROM lego_colors;
```

---

## Complete Setup Example

If `lego.sql` is located in:

```text
01-data-warehouse/sql/lego.sql
```

You can use the following workflow:

### Step 1 — Open a terminal

Navigate to the SQL directory:

```bash
cd 01-data-warehouse/sql
```

### Step 2 — Create the database

```bash
psql -U postgres
```

Then:

```sql
CREATE DATABASE lego;
\q
```

### Step 3 — Load the data

From the `01-data-warehouse/sql` directory:

```bash
psql -U postgres -d lego -f lego.sql
```

### Step 4 — Connect to the database

```bash
psql -U postgres -d lego
```

### Step 5 — Verify the tables

```sql
\dt
```

### Step 6 — Explore a table

```sql
\d table_name
```

### Step 7 — View some data

```sql
SELECT * FROM table_name LIMIT 10;
```

---

## Troubleshooting

### `psql: command not found`

PostgreSQL may not be installed, or the `psql` executable may not be in your PATH.

Check your PostgreSQL installation and add its `bin` directory to your PATH.

---

### `database "lego" already exists`

The database has already been created.

You can simply connect to it:

```bash
psql -U postgres -d lego
```

---

### `relation does not exist`

If you get an error such as:

```text
ERROR: relation "table_name" does not exist
```

Make sure that:

1. You are connected to the correct database.
2. The `lego.sql` file was successfully loaded.
3. The table name is correct.

Check the available tables:

```sql
\dt
```

---

### Permission denied / authentication failed

Make sure you are using the correct PostgreSQL username and password:

```bash
psql -U postgres -d lego
```

If your PostgreSQL installation uses a different user, replace `postgres` with your PostgreSQL username.

---

## Final Check

After loading the data, run:

```bash
psql -U postgres -d lego
```

Then:

```sql
\dt
```

If the LEGO tables are listed, the dataset has been successfully loaded into PostgreSQL.

You can then use SQL queries to explore and analyze the LEGO data.