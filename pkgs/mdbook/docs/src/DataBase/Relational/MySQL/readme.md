## MySQL Usage Guide

### DATABASE

Creating, using, and managing databases.

```sql
-- Create a new database named myDB
CREATE DATABASE myDB; 

-- Switch to the newly created database
USE myDB; 

-- Delete the myDB database
DROP DATABASE myDB; 

-- Set the myDB database to read-only mode
ALTER DATABASE myDB READ ONLY = 1; 

-- Reset the read-only mode of the myDB database
ALTER DATABASE myDB READ ONLY = 0; 
```

### TABLES

Creating and modifying tables to organize data.

```sql
-- Create an 'employees' table with specified columns
CREATE TABLE employees(
    employee_id INT,
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    hourly_pay DECIMAL(5, 2),
    hire_date DATE
);

-- Retrieve all data from the 'employees' table
SELECT * FROM employees; 

-- Rename the 'employees' table to 'workers'
RENAME TABLE employees TO workers; 

-- Delete the 'employees' table
DROP TABLE employees; 
```

#### Altering Tables

```sql
-- Add a new column 'phone_number' to the 'employees' table
ALTER TABLE employees
ADD phone_number VARCHAR(15);

-- Rename the 'phone_number' column to 'email'
ALTER TABLE employees
RENAME COLUMN phone_number TO email;

-- Change the data type of the 'email' column
ALTER TABLE employees
MODIFY COLUMN email VARCHAR(100);

-- Change the position of the 'email' column
ALTER TABLE employees
MODIFY email VARCHAR(100) AFTER last_name;

-- Move the 'email' column to the first position
ALTER TABLE employees
MODIFY email VARCHAR(100) FIRST;

-- Delete the 'email' column
ALTER TABLE employees
DROP COLUMN email;
```

### INSERT ROW

Inserting data into tables.

```sql
-- Insert a single row into the 'employees' table
INSERT INTO employees VALUES(1, "Akib", "Ahmed", 25.90, "2024-04-06");

-- Insert multiple rows into the 'employees' table
INSERT INTO employees VALUES 
(2, "Sakib", "Ahmed", 20.10, "2024-04-06"),
(3, "Rakib", "Ahmed", 16.40, "2024-04-06"),
(4, "Mula", "Ahmed", 10.90, "2024-04-06"),
(5, "Kodhu", "Ahmed", 19.70, "2024-04-06"),
(6, "Lula", "Ahmed", 23.09, "2024-04-06");

-- Insert specific fields into the 'employees' table
INSERT INTO employees (employee_id, first_name, last_name) VALUES(6, "Munia", "Khatun");
```

### SELECT

Retrieving data from tables.

```sql
-- Retrieve all data from the 'employees' table
SELECT * FROM employees;

-- Retrieve specific fields from the 'employees' table
SELECT first_name, last_name FROM employees;

-- Retrieve data from the 'employees' table based on a condition
SELECT * FROM employees WHERE employee_id <= 2;

-- Retrieve data where the 'hire_date' column is NULL
SELECT * FROM employees WHERE hire_date IS NULL;

-- Retrieve data where the 'hire_date' column is not NULL
SELECT * FROM employees WHERE hire_date IS NOT NULL;
```

### UPDATE & DELETE

Modifying and deleting data.

```sql
-- Update data in the 'employees' table based on a condition
UPDATE employees
SET hourly_pay = 10.3, hire_date = "2024-01-05"
WHERE employee_id = 7;

-- Update all rows in the 'employees' table for the 'hourly_pay' column
UPDATE employees
SET hourly_pay = 10.3;

-- Delete rows from the 'employees' table where 'hourly_pay' is NULL
DELETE FROM employees
WHERE hourly_pay IS NULL;

-- Delete the 'date_time' column from the 'employees' table
ALTER TABLE employees
DROP COLUMN date_time;
```

### AUTO-COMMIT, COMMIT & ROLLBACK

Managing transactions.

```sql
-- Turn off auto-commit mode
SET AUTOCOMMIT = OFF;

-- Manually save changes made in the current transaction
COMMIT;

-- Delete all data from the 'employees' table
DELETE FROM employees;

-- Roll back changes made in the current transaction
ROLLBACK;
```

### DATE & TIME

Working with date and time data.

```sql
-- Add a 'join_time' column to the 'employees' table
ALTER TABLE employees
ADD COLUMN join_time TIME;

-- Update the 'join_time' column with the current time
UPDATE employees
SET join_time = CURRENT_TIME();

-- Update the 'hire_date' column based on a condition
UPDATE employees
SET hire_date = CURRENT_DATE() + 1
WHERE hourly_pay >= 20;

-- Add a 'date_time' column to the 'employees' table
ALTER TABLE employees
ADD COLUMN date_time DATETIME;

-- Update the 'date_time' column with the current date and time
UPDATE employees
SET date_time = NOW();

-- Change the name of the 'hire_date' column to 'hire_date'
ALTER TABLE employees
CHANGE COLUMN hire_date hire_date DATE;
```

### CONSTRAINTS

Ensuring data integrity with constraints.

#### UNIQUE

```sql
-- Create a 'products' table with a unique constraint on the 'product_name' column
CREATE TABLE products(
    product_id INT,
    product_name VARCHAR(50) UNIQUE,
    product_price DECIMAL(4,2)
);

-- Add a unique constraint to the 'product_name' column in the 'products' table
ALTER TABLE products
ADD CONSTRAINT UNIQUE(product_name);

-- Insert data into the 'products' table
INSERT INTO products VALUES
(1, "tea", 15.9),
(2, "coffee", 20.89),
(3, "lemon", 10.10);
```

#### NOT NULL

```sql
-- Create a 'products' table with a NOT NULL constraint on the 'product_price' column
CREATE TABLE products(
    product_id INT,
    product_name VARCHAR(50) UNIQUE,
    product_price DECIMAL(4,2) NOT NULL
);

-- Update the 'product_price' column to be NOT NULL
ALTER TABLE products
MODIFY product_price DECIMAL(4,2) NOT NULL;

-- Insert data into the 'products' table with a NOT NULL column
INSERT INTO products VALUES(4, "mango", 0);
```

#### CHECK

```sql
-- Create an 'employees' table with a check constraint on the 'hourly_pay' column
CREATE TABLE employees(
    employee_id INT,
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    hourly_pay DECIMAL(5, 2),
    hire_date DATE,
    CONSTRAINT chk_hourly_pay CHECK (hourly_pay >= 10)
);

-- Add a check constraint to the 'hourly_pay' column
ALTER TABLE employees
ADD CONSTRAINT chk_hourly_pay CHECK(hourly_pay >= 10);

-- Insert data into the 'employees' table
INSERT INTO employees VALUES(7, "Kutta", "Mizan", 10.0, CURRENT_DATE(), CURRENT_TIME());
```

#### DEFAULT

```sql
-- Create a 'products' table with a default value for the 'product_price' column
CREATE TABLE products(
    product_id INT,
    product_name VARCHAR(50) UNIQUE,
    product_price DECIMAL(4,2) DEFAULT 0
);

-- Set the default value for the 'product_price' column
ALTER TABLE products
ALTER product_price SET DEFAULT 0;

-- Insert data into the 'products' table with a default value
INSERT INTO products (product_id, product_name) VALUES(5, "soda");

-- Create a 'transactions' table with a default value for the 'transaction_date' column
CREATE TABLE transactions(
    transaction_id INT,
    amount DECIMAL(5,2),
    transaction_date DATETIME DEFAULT NOW()
);
```

#### PRIMARY KEY

```sql
-- Create a table for transactions with a primary key
CREATE TABLE transactions(
    transaction_id INT PRIMARY KEY,
    amount DECIMAL(4,2),
    transaction_date DATETIME
);

-- Add a primary key constraint
ALTER TABLE transactions
ADD CONSTRAINT PRIMARY KEY(transaction_id);

-- Set auto-increment for the primary key
ALTER TABLE transactions AUTO_INCREMENT = 1000;

-- Insert data into the transactions table
INSERT INTO transactions(amount) VALUES (54.20);

-- Select all data from the transactions table
SELECT * FROM transactions;
```

#### AUTO_INCREMENT

```sql
-- Create a table for transactions with an auto-increment primary key
CREATE TABLE transactions(
    transaction_id INT PRIMARY KEY AUTO_INCREMENT,
    amount DECIMAL(5,2),
    transaction_date DATETIME DEFAULT NOW()
);

-- Set the default increment level
ALTER TABLE transactions AUTO_INCREMENT = 1000;

-- Insert data into the transactions table, auto-increment starts from 1000
INSERT INTO transactions(amount) VALUES (45.20), (23.40), (98.00), (43.45);

-- Select all data from the transactions table
SELECT * FROM transactions;
```

#### FOREIGN KEY

```sql
-- Create a table for customers with a primary key
CREATE TABLE customers(
    customer_id INT PRIMARY KEY AUTO_INCREMENT,
    first_name VARCHAR(50),
    last_name VARCHAR(50)
);

-- Create a table for

 transactions with a foreign key constraint
CREATE TABLE transactions(
    transaction_id INT PRIMARY KEY AUTO_INCREMENT,
    amount DECIMAL(5,2),
    transaction_date DATETIME DEFAULT NOW(),
    customer_id INT,
    FOREIGN KEY(customer_id) REFERENCES customers(customer_id)
);

-- Add a foreign key constraint to the transactions table
ALTER TABLE transactions
ADD CONSTRAINT fk_customer_key
FOREIGN KEY(customer_id) REFERENCES customers(customer_id);

-- Insert data into the transactions table with customer_id
INSERT INTO transactions(amount, customer_id) VALUES (34.34, 1), (123.4, 3), (32.32, 1), (12.00, 2);
```

### JOIN

Combining data from multiple tables.

```sql
-- Inner join transactions and customers tables
SELECT * 
FROM transactions 
INNER JOIN customers
ON transactions.customer_id = customers.customer_id;

-- Select specific fields from joined tables
SELECT transaction_id, transaction_date, first_name, last_name
FROM transactions 
INNER JOIN customers
ON transactions.customer_id = customers.customer_id;

-- Left join transactions and customers tables
SELECT *
FROM transactions 
LEFT JOIN customers
ON transactions.customer_id = customers.customer_id;

-- Right join transactions and customers tables
SELECT *
FROM transactions 
RIGHT JOIN customers
ON transactions.customer_id = customers.customer_id;
```

### FUNCTIONS

Built-in SQL functions.

```sql
-- Count the number of transactions
SELECT COUNT(amount) AS "Transaction count" FROM transactions;

-- Find the maximum amount
SELECT MAX(amount) AS max_dollar FROM transactions;

-- Find the minimum amount
SELECT MIN(amount) AS min_dollar FROM transactions;

-- Find the average amount
SELECT AVG(amount) AS avg_dollar FROM transactions;

-- Calculate the total amount
SELECT SUM(amount) AS sum_of_dollar FROM transactions;

-- Concatenate first_name and last_name into a new column
SELECT CONCAT(first_name, " ", last_name) as full_name FROM customers;
```

### AND, OR & NOT

Combining conditions in SQL queries.

```sql
-- Add a job column to the employees table
ALTER TABLE employees
ADD COLUMN job VARCHAR(50) AFTER hourly_pay;

-- Update job data based on employee_id
UPDATE employees
SET job = "Programmer" 
WHERE employee_id = 1;

-- Select employees with specific conditions
SELECT * FROM employees
WHERE employee_id >= 2 AND employee_id <= 6 AND job = "vendor";

-- Select employees with specific conditions using OR
SELECT * FROM employees
WHERE job = "programmer" OR job = "vendor";

-- Select employees with specific conditions using NOT
SELECT * FROM employees
WHERE NOT job = "programmer" AND NOT job = "vendor";

-- Select employees within a certain hourly pay range
SELECT * FROM employees
WHERE hourly_pay BETWEEN 15 AND 26;

-- Select employees with specific jobs using IN
SELECT * FROM employees
WHERE job IN("programmer", "vendor", "doctor");
```

### WILD-CARDS

Using wildcards for pattern matching.

```sql
-- Select employees with first name ending with "hu"
SELECT * FROM employees
WHERE first_name LIKE "%hu";

-- Select employees hired on a specific day (07)
SELECT * FROM employees
WHERE hire_date LIKE "____-__-07";

-- Select employees with job ending with "e" followed by another character
SELECT * FROM employees
WHERE job LIKE "%e_";
```

### ORDER BY

Sorting query results.

```sql
-- Select employees ordered by hourly pay in ascending order
SELECT * FROM employees
ORDER BY hourly_pay ASC;

-- Select employees ordered by hire date in descending order
SELECT * FROM employees
ORDER BY hire_date DESC;

-- Select transactions ordered by amount in descending order and customer_id in ascending order
SELECT * FROM transactions
ORDER BY amount DESC, customer_id ASC;
```

### LIMIT

Limiting the number of records returned.

```sql
-- Select the first 3 customers
SELECT * FROM customers
LIMIT 3;

-- Select the last 3 customers ordered by customer_id
SELECT * FROM customers
ORDER BY customer_id DESC LIMIT 3;

-- Select 2 customers starting from the 1st position (pagination)
SELECT * FROM customers
LIMIT 0,2;
```

### UNION

Combining results from multiple SELECT statements.

```sql
-- Combine unique first and last names from employees and customers
SELECT first_name, last_name FROM employees
UNION
SELECT first_name, last_name FROM customers;

-- Combine all first and last names from employees and customers, including duplicates
SELECT first_name, last_name FROM employees
UNION ALL
SELECT first_name, last_name FROM customers;
```

### SELF JOIN

Joining a table to itself.

```sql
-- Add a referral_id column to the customers table
ALTER TABLE customers
ADD COLUMN referral_id INT;

-- Update referral_id for customers
UPDATE customers
SET referral_id = 1
WHERE customer_id = 2;

-- Self join to show referred customers
SELECT a.customer_id, a.first_name, a.last_name,
       CONCAT(b.first_name, " ", b.last_name) AS "referred_by"
FROM customers AS a
INNER JOIN customers AS b
ON a.referral_id = b.customer_id;

-- Add a supervisor_id column to the employees table
ALTER TABLE employees
ADD supervisor_id INT;

-- Update supervisor_id for employees
UPDATE employees
SET supervisor_id = 7 
WHERE employee_id BETWEEN 2 and 6;

-- Update supervisor_id for a specific employee
UPDATE employees
SET supervisor_id = 1 
WHERE employee_id = 7;

-- Self join to show employees and their supervisors
SELECT a.employee_id, a.first_name, a.last_name,
       CONCAT(b.first_name, " ", b.last_name) AS "reports to"
FROM employees AS a
INNER JOIN employees AS b
ON a.supervisor_id = b.employee_id;
```

### VIEWS

Creating and using virtual tables.

```sql
-- Create a view based on the employees table
CREATE VIEW employee_attendance AS
SELECT first_name, last_name
FROM employees;

-- Retrieve data from the view
SELECT * FROM employee_attendance
ORDER BY last_name ASC;

-- Create a view for customer emails
CREATE VIEW customer_emails AS
SELECT email
FROM customers;

-- Insert data into the customers table and view the changes in the view
INSERT INTO customers
VALUES(6, "Musa", "Rahman", NULL, "musa@mail.com");
SELECT * FROM customers;
SELECT * FROM customer_emails;
```

### INDEX

Improving query performance with indexes.

```sql
-- Show indexes for the customers table
SHOW INDEXES FROM customers;

-- Create an index on the last_name column
CREATE INDEX last_name_index
ON customers(last_name);

-- Use the index to speed up search
SELECT * FROM customers
WHERE last_name = "Chan";

-- Create a multi-column index
CREATE INDEX last_name_first_name_idx
ON customers(last_name, first_name);

-- Drop an index
ALTER TABLE customers
DROP INDEX last_name_index;

-- Benefit from the multi-column index during search
SELECT * FROM customers
WHERE last_name = "Chan" AND first_name = "Kuki";
```

### SUB-QUERY

Using sub-queries to nest queries within queries.

```sql
-- Get the average hourly pay
SELECT AVG(hourly_pay) FROM employees;

-- Use a sub-query to get the average hourly pay within a larger query
SELECT first_name, last_name, hourly_pay,
       (SELECT AVG(hourly_pay) FROM employees) AS avg_hourly_pay
FROM employees;

-- Filter rows based on a sub-query result
SELECT first_name, last_name, hourly_pay 
FROM employees
WHERE hourly_pay >= (SELECT AVG(hourly_pay) FROM employees);

-- Use a sub-query with IN to filter customers
SELECT first_name, last_name
FROM customers
WHERE customer_id IN (SELECT DISTINCT customer_id
                      FROM transactions
                      WHERE customer_id IS NOT NULL);

-- Use a sub-query with NOT IN to filter customers
SELECT first_name, last_name
FROM customers
WHERE customer_id NOT IN (SELECT DISTINCT customer_id
                          FROM transactions
                          WHERE customer_id IS NOT NULL);
```

### GROUP BY

Aggregating data with grouping.

```sql
-- Sum amounts grouped by transaction date
SELECT SUM(amount), transaction_date
FROM transactions
GROUP BY transaction_date;

-- Get the maximum amount per customer
SELECT MAX(amount), customer_id
FROM transactions
GROUP BY customer_id;

-- Count transactions per customer having more than one transaction
SELECT COUNT(amount), customer_id
FROM transactions
GROUP BY customer_id
HAVING COUNT(amount) > 1 AND customer_id IS NOT NULL;
```

### ROLL-UP

Extending group by with roll-up for super-aggregate values.

```sql
-- Sum amounts with a roll-up
SELECT SUM(amount), transaction_date
FROM transactions
GROUP BY transaction_date WITH ROLLUP;

-- Count transactions with a roll-up
SELECT COUNT(transaction_id) AS "# of orders", customer_id
FROM transactions 
GROUP BY customer_id WITH ROLLUP;

-- Sum hourly pay with a roll-up
SELECT SUM(hourly_pay) AS "hourly pay", employee_id
FROM employees
GROUP BY employee_id WITH ROLLUP;
```

### ON-DELETE

Handling foreign key deletions.

```sql
-- Delete a customer record
DELETE FROM customers
WHERE customer_id = 3;

-- Disable foreign key checks and delete a customer
SET foreign_key_checks = 0;
DELETE FROM customers
WHERE customer_id = 3;
SET foreign_key_checks = 1;

-- Insert a customer record
INSERT INTO customers
VALUES(3, "Shilpi", "Akter", 3, "shilpy@mail.com");

-- Create a table with ON DELETE SET NULL
CREATE TABLE transactions(
    transaction_id INT PRIMARY KEY,
    amount DECIMAL(5,

3),
    customer_id INT,
    order_date DATE,
    FOREIGN KEY(customer_id) REFERENCES customers(customer_id)
    ON DELETE SET NULL
);

-- Update an existing table with ON DELETE SET NULL
ALTER TABLE transactions 
DROP FOREIGN KEY fk_customer_key;
ALTER TABLE transactions 
ADD CONSTRAINT fk_customer_key
FOREIGN KEY(customer_id) REFERENCES customers(customer_id)
ON DELETE SET NULL;

-- Create or alter a table with ON DELETE CASCADE
ALTER TABLE transactions
ADD CONSTRAINT fk_transaction_id
FOREIGN KEY(customer_id) REFERENCES customers(customer_id)
ON DELETE CASCADE;
```

### STORED PROCEDURE

Creating reusable SQL code blocks.

```sql
-- Create a procedure
DELIMITER $$
CREATE PROCEDURE get_customers()
BEGIN
    SELECT * FROM customers;
END $$
DELIMITER ;

-- Delete a procedure
DROP PROCEDURE get_customers;

-- Create a procedure with an argument
DELIMITER $$
CREATE PROCEDURE find_customer(IN id INT)
BEGIN
    SELECT * FROM customers WHERE customer_id = id;
END $$
DELIMITER ;

-- Create a procedure with multiple arguments
DELIMITER $$
CREATE PROCEDURE find_customer(IN f_name VARCHAR(50), IN l_name VARCHAR(50))
BEGIN 
    SELECT * FROM customers WHERE first_name = f_name AND last_name = l_name;
END $$
DELIMITER ;

-- Call a procedure
CALL find_customer("Akib", "Ahmed");
```

### TRIGGERS

Automatically performing actions in response to events.

```sql
-- Add a salary column to the employees table
ALTER TABLE employees
ADD COLUMN salary DECIMAL(10,2) AFTER hourly_pay;

-- Calculate salary based on hourly pay
UPDATE employees
SET salary = hourly_pay * 2080;

-- Create a trigger to update salary before updating hourly pay
CREATE TRIGGER before_hourly_pay_update
BEFORE UPDATE ON employees
FOR EACH ROW
SET NEW.salary = (NEW.hourly_pay * 2080);

-- Update hourly pay and see the trigger in action
UPDATE employees 
SET hourly_pay = 50
WHERE employee_id = 1;

-- Create a trigger to update salary before inserting a new employee
CREATE TRIGGER before_hourly_pay_insert
BEFORE INSERT ON employees
FOR EACH ROW
SET NEW.salary = (NEW.hourly_pay * 2080);

-- Insert a new employee and see the trigger in action
INSERT INTO employees
VALUES(6, "Shel", "Plankton", 10, NULL, "Janitor", "2024-06-17", "09:22:23", 7);

-- Create a table for expenses
CREATE TABLE expenses(
    expense_id INT PRIMARY KEY,
    expense_name VARCHAR(50),
    expense_total DECIMAL(10,2)
);

-- Insert initial data into the expenses table
INSERT INTO expenses
VALUES (1, "salaries", 0), (2, "supplies", 0), (3, "taxes", 0);

-- Update expenses based on salaries
UPDATE expenses 
SET expense_total = (SELECT SUM(salary) FROM employees)
WHERE expense_name = "salaries";

-- Create a trigger to update expenses after deleting an employee
CREATE TRIGGER after_salary_delete
AFTER DELETE ON employees
FOR EACH ROW
UPDATE expenses
SET expense_total = expense_total - OLD.salary
WHERE expense_name = "salaries";

-- Delete an employee and see the trigger in action
DELETE FROM employees
WHERE employee_id = 6;

-- Create a trigger to update expenses after inserting a new employee
CREATE TRIGGER after_salary_insert
AFTER INSERT ON employees
FOR EACH ROW
UPDATE expenses
SET expense_total = expense_total + NEW.salary
WHERE expense_name = "salaries";

-- Insert a new employee and see the trigger in action
INSERT INTO employees
VALUES(6, "Shel", "Plankton", 10, NULL, "Janitor", "2024-06-17", "09:22:23", 7);

-- Create a trigger to update expenses after updating an employee's salary
CREATE TRIGGER after_salary_update
AFTER UPDATE ON employees
FOR EACH ROW
UPDATE expenses
SET expense_total = expense_total + (NEW.salary - OLD.salary)
WHERE expense_name = "salaries";

-- Update an employee's hourly pay and see the trigger in action
UPDATE employees
SET hourly_pay = 100
WHERE employee_id = 1;
```