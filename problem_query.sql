-- Monday Coffee Project

------------ PROJECT PROBLEMS ---------------


--  1) How many people in each city are estimated to consume coffee, given that 25% of the population does?
--  2) What is the total revenue generated from coffee sales across all cities in the last quarter of 2023?
--  3) How many units of each coffee product have been sold?
--  4) What is the average sales amount per customer in each city?
--  5) Provide a list of cities along with their populations and estimated coffee consumers.
--  6) What are the top 3 selling products in each city based on sales volume?
--  7) How many unique customers are there in each city who have purchased coffee products?
--  8) Find each city and their average sale per customer and avg rent per customer
--  9) Sales growth rate: Calculate the percentage growth (or decline) in sales over different time periods (monthly).
-- 10) Identify top 3 city based on highest sales, return city name, total sale, total rent, total customers, estimated coffee consumer

------------ SOLUTIONS ---------------

SELECT * FROM city;
SELECT * FROM customers;
SELECT * FROM products;
SELECT * FROM sales;




--  1) How many people in each city are estimated to consume coffee, given that 25% of the population does?

SELECT  city_name,
	    ROUND(population * 0.25/1000000,2) AS coffee_consumer_million
FROM city



--  2) What is the total revenue generated from coffee sales across all cities in the last quarter of 2023?

WITH total_revenue_generated AS (
	SELECT  city.city_name AS city_name,
	        EXTRACT(YEAR FROM sales.sale_date) AS year,
		    EXTRACT(QUARTER FROM sales.sale_date) AS quarter,
		    SUM(sales.total) AS total_revenue
	FROM city
	
	JOIN customers
	ON city.city_id = customers.city_id
	
	JOIN sales
	ON customers.customer_id = sales.customer_id
	
	GROUP BY city.city_name,year, quarter
)

SELECT city_name,total_revenue
FROM total_revenue_generated
WHERE year = 2023 AND quarter = 4;




--  3) How many units of each coffee product have been sold?

SELECT  products.product_name AS product,
        COUNT(sales.product_id) AS unit_sold
FROM sales

JOIN products
ON sales.product_id = products.product_id

GROUP BY product;




--  4) What is the average sales amount per customer in each city?

SELECT city.city_name,
	   SUM(sales.total)/COUNT(DISTINCT sales.customer_id) AS amount_per_customer
FROM city

JOIN customers
ON city.city_id = customers.city_id

JOIN sales
ON customers.customer_id = sales.customer_id

GROUP BY city.city_name
ORDER BY amount_per_customer DESC;




--  5) Provide a list of cities along with their populations and estimated coffee consumers and Number of current customers.

SELECT city.city_name, 
       city.population,
	   ROUND(population * 0.25/1000000,2) AS coffee_consumer_million,
	   COUNT(DISTINCT sales.customer_id) AS number_of_customers
FROM city

JOIN customers
ON city.city_id = customers.city_id

JOIN sales
ON customers.customer_id = sales.customer_id

GROUP BY city.city_name,city.population
ORDER BY coffee_consumer_million DESC;




--  6) What are the top 3 selling products in each city based on sales volume?

WITH top_selling_product AS (

	SELECT city.city_name AS city,
	       products.product_name AS products,
		   COUNT(sales.product_id) AS sales_volume,
		   RANK()OVER(PARTITION BY city.city_name ORDER BY COUNT(sales.product_id) DESC) AS rank
	FROM city
	
	JOIN customers
	ON city.city_id = customers.city_id
	
	JOIN sales
	ON customers.customer_id = sales.customer_id
	
	JOIN products
	ON sales.product_id = products.product_id
	
	GROUP BY city.city_name,products.product_name
	ORDER BY city.city_name,sales_volume DESC

)

SELECT city,products,sales_volume
FROM top_selling_product
WHERE rank <= 3;




--  7) How many unique customers are there in each city who have purchased coffee products?

SELECT  city.city_name,
	    COUNT(DISTINCT customers.customer_id) AS unique_customer
FROM city

JOIN customers
ON city.city_id = customers.city_id

JOIN sales
ON customers.customer_id = sales.customer_id

JOIN products
ON sales.product_id = products.product_id
WHERE products.product_id BETWEEN 1 AND 14

GROUP BY city.city_name
ORDER BY unique_customer DESC;




--  8) Find each city and their average sale per customer and avg rent per customer


SELECT  city.city_name,
	    SUM(sales.total)/COUNT(DISTINCT customers.customer_id) AS average_sale,
		ROUND(city.estimated_rent::NUMERIC/COUNT(DISTINCT sales.customer_id),2) AS average_rent
FROM city

JOIN customers
ON city.city_id = customers.city_id

JOIN sales
ON customers.customer_id = sales.customer_id

GROUP BY city.city_name,city.estimated_rent
ORDER BY average_rent DESC;




--  9) Sales growth rate: Calculate the percentage growth (or decline) in sales over different time periods (monthly).

WITH sales_growth As (
	SELECT city.city_name AS city,
	       EXTRACT(MONTH FROM sale_date) AS month,
		   TO_CHAR(sale_date,'yyyy') AS year,
	       SUM(total) AS sales
	FROM city
	
	JOIN customers
	ON city.city_id = customers.city_id
	
	JOIN sales
	ON customers.customer_id = sales.customer_id
	
	GROUP BY month,city.city_name,year
	ORDER BY year,city.city_name,month
),
monthly_sale AS (
	SELECT  city,
		    month,
	        year,
		    sales,
			LAG(sales,1)OVER(PARTITION BY city ORDER BY year,city,month)AS monthly_sales
	FROM sales_growth
)

SELECT *,
       ROUND((sales - monthly_sales)::Numeric/monthly_sales * 100,2) AS months_sale
FROM monthly_sale;




-- 10) Identify top 3 city based on highest sales, return city name, total sale, total rent, total customers, estimated coffee consumer


SELECT  city.city_name,
	    city.estimated_rent AS total_rent,
		SUM(sales.total) AS total_sales,
	    COUNT(DISTINCT customers.customer_id) AS total_customers,
		ROUND(city.population * 0.25/1000000,2) AS coffee_consumer_million,
		SUM(sales.total)/COUNT(DISTINCT customers.customer_id) AS average_sale,
		ROUND(city.estimated_rent::NUMERIC/COUNT(DISTINCT sales.customer_id),2) AS average_rent
FROM city

JOIN customers
ON city.city_id = customers.city_id
	
JOIN sales
ON customers.customer_id = sales.customer_id
	
GROUP BY city.city_name,coffee_consumer_million, total_rent
ORDER BY total_sales DESC;
-- LIMIT 3;



/*
-- Recomendation
City 1: Pune
	1.Average rent per customer is very low.
	2.Highest total revenue.
	3.Average sales per customer is also high.

City 2: Delhi
	1.Highest estimated coffee consumers at 7.7 million.
	2.Highest total number of customers, which is 68.
	3.Average rent per customer is 330 (still under 500).

City 3: Jaipur
	1.Highest number of customers, which is 69.
	2.Average rent per customer is very low at 156.
	3.Average sales per customer is better at 11.6k.
