## PostgreSQL Quick Guide

A concise guide to common PostgreSQL commands, syntax, and concepts.

**Key Differences from MySQL:**

- **Strings:** Use **single quotes** only (e.g., `'Hello World'`).
- **Identifiers:** (Table/column names) are case-insensitive unless you wrap them in **double quotes** (e.g., `"myColumn"`).
- **Switching DBs:** There is no `USE db_name;` command. In the `psql` terminal, use the `\c db_name` meta-command.
- **Auto-Increment:** Use the `SERIAL` or `GENERATED AS IDENTITY` keyword.
- **Concatenation:** The standard SQL `||` operator is preferred (e.g., `first_name || ' ' || last_name`).

---

### `psql` Command Line Basics

`psql` is the interactive terminal for PostgreSQL.

**Connecting:**

```bash
# Connect to a specific database as a specific user
psql -d myDB -U myUser -h localhost
```

**Common Meta-Commands (start with `\`):**

- `\l`: List all databases.
- `\c db_name`: Connect to a different database.
- `\dt`: List all tables in the current database.
- `\d table_name`: Describe a table (columns, indexes, constraints).
- `\dn`: List all schemas.
- `\df`: List all functions.
- `\du`: List all users (roles).
- `\timing`: Toggles query execution time display.
- `\e`: Open the last query in your text editor.
- `\q`: Quit `psql`.

---

### Database & Role Management

Manage databases and user permissions.

```sql
-- Create a new database
CREATE DATABASE myDB;

-- Delete a database
DROP DATABASE myDB;

-- Create a new user (role) with login permission
CREATE ROLE myUser WITH LOGIN PASSWORD 'my_password';

-- Grant privileges for a user on a table
GRANT ALL ON employees TO myUser;

-- Grant privileges to connect to a database
GRANT CONNECT ON DATABASE myDB TO myUser;
```

---

### Tables & Data Types

Create, modify, and delete tables.

```sql
-- Create a table with common data types
CREATE TABLE employees (
    employee_id SERIAL PRIMARY KEY, -- Auto-incrementing primary key
    first_name VARCHAR(50) NOT NULL,
    hourly_pay NUMERIC(5, 2) DEFAULT 10.00, -- Equivalent to DECIMAL
    hire_date DATE DEFAULT CURRENT_DATE,
    created_at TIMESTAMP DEFAULT NOW()
);

-- Modify an existing table
ALTER TABLE employees
    ADD COLUMN email VARCHAR(100) UNIQUE,
    RENAME COLUMN hire_date TO joined_date,
    ALTER COLUMN hourly_pay TYPE NUMERIC(6, 2),
    DROP COLUMN some_old_column;

-- Rename a table
ALTER TABLE employees RENAME TO workers;

-- Delete a table
DROP TABLE employees;
```

**Note:** PostgreSQL does not support reordering columns (like `AFTER` or `FIRST`). You must recreate the table.

---

### Constraints

Rules to ensure data integrity, best defined at creation.

```sql
CREATE TABLE products (
    product_id SERIAL PRIMARY KEY,
    product_name VARCHAR(50) UNIQUE NOT NULL,
    price NUMERIC(6, 2) DEFAULT 0,
    category_id INT,

    -- Check constraint
    CONSTRAINT chk_price CHECK (price >= 0),

    -- Foreign key constraint with actions
    CONSTRAINT fk_category
        FOREIGN KEY(category_id)
        REFERENCES categories(category_id)
        ON DELETE SET NULL -- or ON DELETE CASCADE
);

-- Add a constraint to an existing table
ALTER TABLE employees
ADD CONSTRAINT chk_hourly_pay CHECK(hourly_pay >= 10.00);
```

---

### Manipulating Data (CRUD)

The four basic data operations: Create, Read, Update, Delete.

```sql
-- CREATE (Insert)
-- Insert a single row (best practice to name columns)
INSERT INTO employees (first_name, last_name, hourly_pay)
VALUES ('Akib', 'Ahmed', 25.90);

-- Insert multiple rows
INSERT INTO employees (first_name, last_name, hourly_pay) VALUES
('Sakib', 'Ahmed', 20.10),
('Rakib', 'Ahmed', 16.40);

-- READ (Select)
SELECT * FROM employees;

-- UPDATE (Update)
UPDATE employees
SET hourly_pay = 27.50, email = 'akib@mail.com'
WHERE employee_id = 1;

-- DELETE (Delete)
DELETE FROM employees
WHERE employee_id = 1;
```

---

### Transactions

Ensure that a group of SQL statements either all succeed or all fail together.

```sql
-- Start a transaction block
BEGIN;

-- Make changes
UPDATE employees SET hourly_pay = 99.00 WHERE employee_id = 2;
DELETE FROM employees WHERE employee_id = 3;

-- To undo the changes in this block
ROLLBACK;

-- To make the changes permanent
COMMIT;
```

---

### Querying: Filtering & Sorting

Use `SELECT` to retrieve data with complex conditions.

```sql
SELECT
    first_name || ' ' || last_name AS full_name,
    hourly_pay,
    joined_date
FROM employees
WHERE
    (hourly_pay > 20 OR job IS NULL)
    AND first_name ILIKE 'a%' -- ILIKE is case-insensitive LIKE
ORDER BY
    joined_date DESC,
    first_name ASC
LIMIT 10 OFFSET 5; -- Skip 5 rows, fetch the next 10 (for pagination)
```

---

### Querying: Aggregation

Summarize data using aggregate functions and `GROUP BY`.

```sql
SELECT
    job,
    COUNT(employee_id) AS "employee_count",
    AVG(hourly_pay) AS avg_pay,
    SUM(hourly_pay) AS total_payroll
FROM employees
WHERE joined_date > '2023-01-01'
GROUP BY job
HAVING COUNT(employee_id) > 2 -- Filter groups, not rows
ORDER BY avg_pay DESC;

-- Use ROLLUP to get a grand total row
SELECT job, SUM(hourly_pay)
FROM employees
GROUP BY ROLLUP(job); -- Will add a final row with the total sum
```

---

### Querying: Joins

Combine rows from two or more tables.

```sql
-- INNER JOIN: Returns only matching rows from both tables
SELECT e.first_name, t.amount
FROM employees AS e
INNER JOIN transactions AS t ON e.employee_id = t.employee_id;

-- LEFT JOIN: Returns all rows from the left (employees) table,
-- and matching rows from the right (transactions) table.
SELECT e.first_name, t.amount
FROM employees AS e
LEFT JOIN transactions AS t ON e.employee_id = t.employee_id;

-- SELF JOIN: Join a table to itself
SELECT a.first_name AS employee, b.first_name AS supervisor
FROM employees AS a
LEFT JOIN employees AS b ON a.supervisor_id = b.employee_id;
```

---

### Querying: Combining

Combine the results of multiple `SELECT` statements.

```sql
-- UNION: Combines results and removes duplicates
SELECT first_name, last_name FROM employees
UNION
SELECT first_name, last_name FROM customers;

-- UNION ALL: Combines results and keeps all duplicates
SELECT first_name, last_name FROM employees
UNION ALL
SELECT first_name, last_name FROM customers;

-- Sub-query: Use a query result as a condition
SELECT * FROM employees
WHERE hourly_pay > (SELECT AVG(hourly_pay) FROM employees);

-- Common Table Expression (CTE): A temporary, named result set
WITH highest_payers AS (
    SELECT * FROM employees WHERE hourly_pay > 50
)
SELECT * FROM highest_payers WHERE joined_date < '2024-01-01';
```

---

### Database Objects

Reusable SQL components.

#### Views

A virtual table based on a `SELECT` query.

```sql
-- Create a read-only view
CREATE VIEW v_high_earners AS
SELECT employee_id, first_name, hourly_pay
FROM employees
WHERE hourly_pay > 30;

-- Query the view like a table
SELECT * FROM v_high_earners;
```

#### Indexes

Speed up data retrieval on frequently queried columns.

```sql
-- Create an index
CREATE INDEX idx_employees_last_name
ON employees(last_name);

-- Create a multi-column index
CREATE INDEX idx_employees_name
ON employees(last_name, first_name);

-- Drop an index
DROP INDEX idx_employees_last_name;
```

#### Stored Functions

Reusable blocks of code. In Postgres, these are typically functions that return a value or a table.

```sql
-- Create a function in the plpgsql language
CREATE OR REPLACE FUNCTION find_employee_by_id(id INT)
RETURNS SETOF employees AS $$
BEGIN
    RETURN QUERY
    SELECT * FROM employees WHERE employee_id = id;
END;
$$ LANGUAGE plpgsql;

-- Call the function
SELECT * FROM find_employee_by_id(1);
```

#### Triggers

A function that automatically runs when an event (INSERT, UPDATE, DELETE) occurs on a table.

This is a two-step process:

```sql
-- 1. Create the trigger FUNCTION
CREATE OR REPLACE FUNCTION log_last_update()
RETURNS TRIGGER AS $$
BEGIN
    -- NEW refers to the row being inserted or updated
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- 2. Bind the function to a table with a TRIGGER
CREATE TRIGGER trg_employees_update
BEFORE UPDATE ON employees
FOR EACH ROW
EXECUTE FUNCTION log_last_update();
```

---

### Advanced Features

#### JSONB

Store and query JSON data efficiently.

```sql
CREATE TABLE products (id SERIAL, data JSONB);
INSERT INTO products (data)
VALUES ('{"name": "Coffee", "tags": ["hot", "drink"]}');

-- Query a JSON key (->> returns as text)
SELECT * FROM products WHERE data->>'name' = 'Coffee';

-- Check if a JSON array contains a value
SELECT * FROM products WHERE data @> '{"tags": ["hot"]}';
```

#### Window Functions

Perform aggregate calculations over a "window" of rows without collapsing them.

```sql
-- Get each employee's salary AND the average salary for their job
SELECT
    first_name,
    job,
    hourly_pay,
    AVG(hourly_pay) OVER (PARTITION BY job) AS avg_job_pay,
    RANK() OVER (ORDER BY hourly_pay DESC) AS pay_rank
FROM employees;
```
