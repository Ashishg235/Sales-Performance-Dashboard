-- Create DB for the tables

CREATE DATABASE sales_dashboard;
USE sales_dashboard;

-- Create products table

CREATE TABLE products (
	product_id INT PRIMARY KEY,
    product_name VARCHAR(50),
    category VARCHAR(30),
    cost_price DECIMAL(10, 2)
);

-- Create customers table

CREATE TABLE customers (
	customer_id INT PRIMARY KEY,
    name VARCHAR(50),
    segment VARCHAR(20)
);

-- Create regions table

CREATE TABLE regions (
	region_id INT PRIMARY KEY,
    region_name VARCHAR(30)
);

-- Create sales table

CREATE TABLE sales (
	sale_id INT PRIMARY KEY,
	date DATE,
    product_id INT,
    customer_id INT,
    quantity INT,
    price DECIMAL(10, 2),
    region_id INT,
    FOREIGN KEY (product_id) REFERENCES products(product_id),
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id),
    FOREIGN KEY (region_id) REFERENCES regions(region_id)
);

-- Data Cleaning -------------------------------------------

-- Checking for null

SELECT count(*)
FROM sales 
WHERE product_id IS NULL 
	OR customer_id IS NULL
    OR region_id IS NULL;
    
SELECT COUNT(*)
FROM products
WHERE product_name IS NULL;

SELECT count(*)
FROM customers
WHERE name IS NULL;

-- Checking for invalid data

SELECT * 
FROM sales
WHERE quantity <= 0
	OR price < 0;
    
SELECT *
FROM sales
WHERE `date` > CURDATE();

-- Standardize data

UPDATE customers 
SET name = TRIM(name);

UPDATE products
SET product_name = TRIM(product_name);

-- Cleaned view with filters built in for powerBI

CREATE OR REPLACE VIEW cleaned_sales AS
SELECT s.sale_id,
	s.date,
    p.product_name,
    p.category,
    c.name AS customer_name,
    c.segment,
    r.region_name,
    s.quantity,
    s.price,
    (s.quantity * s.price) AS total_sales,
    (s.quantity * p.cost_price) AS total_cost,
    ((s.quantity * s.price) - (s.quantity * p.cost_price)) AS profit
FROM sales s
JOIN products p ON s.product_id = p.product_id
JOIN customers c ON s.customer_id = c.customer_id
JOIN regions r ON s.region_id = r.region_id
WHERE s.quantity > 0 AND s.price > 0 AND s.date <= CURDATE();