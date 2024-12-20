
-- Monday Coffee Project
-- Data Export Through CSV files

DROP TABLE IF EXISTS city;
DROP TABLE IF EXISTS customers;
DROP TABLE IF EXISTS products;
DROP TABLE IF EXISTS sales;


-- TABLE 1 ---

CREATE TABLE city(

city_id  INT PRIMARY KEY,
city_name VARCHAR(80),
population BIGINT,
estimated_rent FLOAT,
city_rank INT

);



-- TABLE 2 ---

CREATE TABLE customers(

customer_id INT PRIMARY KEY,
customer_name VARCHAR(100),
city_id INT,
CONSTRAINT fk_city FOREIGN KEY (city_id) REFERENCES city(city_id)

);


-- TABLE 3 ---

CREATE TABLE products(

product_id INT PRIMARY KEY,
product_name VARCHAR(200),
price INT

);


-- TABLE 4 ---

CREATE TABLE sales(

sale_id INT PRIMARY KEY,
sale_date DATE,
product_id INT,
customer_id INT,
total INT,
rating INT,
CONSTRAINT fk_product FOREIGN KEY (product_id) REFERENCES products(product_id),
CONSTRAINT fk_customer FOREIGN KEY (customer_id) REFERENCES customers(customer_id)

);