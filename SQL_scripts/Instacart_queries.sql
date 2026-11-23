DATABASE TABLE CREATION
------------------------



--creating the aisle table
CREATE TABLE aisle_table(
		aisle_id INT PRIMARY KEY,
		aisle VARCHAR(50)
);


--creating the departments table
CREATE TABLE departments_table(
		department_id INT PRIMARY KEY,
		department VARCHAR(20)
);


--creating the products_table
CREATE TABLE products_table(
		product_id INT PRIMARY KEY,
		product_name VARCHAR(200),
		aisle_id INT REFERENCES aisle_table(aisle_id),
		department_id INT REFERENCES departments_table(department_id),
		unit_cost NUMERIC(10,2),
		unit_price NUMERIC(10,2)
);

--creating the orders table
CREATE TABLE orders_table(
		order_id INT PRIMARY KEY,
		user_id INT,
		product_id INT REFERENCES products_table(product_id),
		quantity INT,
		order_date DATE,
		order_dow INT,
		order_hour_of_day INT,
		days_since_prior_order INT,
		order_status VARCHAR(15)
);







--PROJECT QUERIES
-----------------



--QUESTION 1
--what are the top selling products by revenue and how much revenue have they generated


SELECT p.product_name,
		'$' || ROUND( SUM(p.unit_price * o.quantity), 0) AS total_revenue
FROM products_table AS p
JOIN orders_table AS o USING (product_id)
WHERE o.order_status IN ('Shipped', 'Delivered')
GROUP BY p.product_name
ORDER BY SUM(p.unit_price * o.quantity) DESC
LIMIT 10;



--QUESTION 2
--on which day of the week are chocolates mostly sold?



SELECT COUNT(o.order_id) AS total_orders,
	CASE
		WHEN order_dow = 0 THEN 'Sunday'
		WHEN order_dow = 1 THEN 'Monday'
		WHEN order_dow = 2 THEN 'Tuesday'
		WHEN order_dow = 3 THEN 'Wednesday'
		WHEN order_dow = 4 THEN 'Thursday'
		WHEN order_dow = 5 THEN 'Friday'
		ELSE 'Saturday'
	END AS day_of_week
FROM orders_table AS o
JOIN products_table AS p ON p.product_id = o.product_id
WHERE p.product_name ILIKE '%Chocolate%'
GROUP BY o.order_dow
ORDER BY COUNT(order_id) DESC
LIMIT 1;



--QUESTION 3
--do we have any department where we made over 15million in revenue and what is the profit?


SELECT d.department,
		'$' || ROUND(SUM((p.unit_price - p.unit_cost) * o.quantity), 0) AS total_profit
FROM departments_table AS d
JOIN products_table AS p USING (department_id)
JOIN orders_table AS o USING (product_id)
GROUP BY d.department
HAVING SUM(unit_price * quantity) >15000000
ORDER BY SUM(unit_price * quantity) >15000000;



--QUESTION 4
-- which product departments recorded the highest sales quantities on Christmas day 2019,
-- and where did alccoholic products rank?

SELECT *
FROM orders_table;


SELECT d.department,
		SUM(o.quantity) AS total_quantity
FROM departments_table AS d
JOIN products_table AS p USING (department_id)
JOIN orders_table AS o USING (product_id)
WHERE o.order_date = '2019-12-25'
GROUP BY d.department
ORDER BY total_quantity DESC;



--QUESTION 5
--which year did Instacart generate the most profit? (THE NAME OF THE COMPANY IS INSTACART)

SELECT *
FROM aisle_table;

SELECT *
FROM products_table;

SELECT EXTRACT(YEAR FROM o.order_date) AS years,
		'$' || SUM((p.unit_price - unit_cost) * quantity) AS total_profit
FROM products_table AS p
LEFT JOIN orders_table AS o USING (product_id)
WHERE o.order_status IN ('Shipped', 'Delivered')
GROUP BY  EXTRACT(YEAR FROM o.order_date)
ORDER BY SUM((p.unit_price - unit_cost) * quantity) DESC
LIMIT 1;



--QUESTION 6
--how long has it been since the last Cheese order?



WITH latest_dataset_date AS (
SELECT MAX(order_date)::date AS latest_order_date
FROM orders_table
),

last_cheese_order AS (
    SELECT MAX(o.order_date)::date AS last_cheese_order_date
    FROM orders_table o
    JOIN products_table p
        ON o.product_id = p.product_id
    WHERE p.product_name ILIKE '%cheese%'
)

SELECT
    lco.last_cheese_order_date,
    ldd.latest_order_date,
    ldd.latest_order_date - lco.last_cheese_order_date
        AS days_since_last_cheese_order
FROM last_cheese_order lco
CROSS JOIN latest_dataset_date ldd;





--QUESTION 7
-- what time of the day do we sell Alcohol the most?

SELECT o.order_hour_of_day,
		SUM(o.quantity) AS order_volume
FROM departments_table AS d
JOIN products_table AS p USING (department_id)
JOIN orders_table AS o USING (product_id)
WHERE d.department = 'alcohol'
GROUP BY o.order_hour_of_day
ORDER BY order_volume DESC;



--QUESTION 8
--what is the total revenue generated in Qtr. 2 & 3 of 2016 from breads?

SELECT a.aisle,
		SUM(p.unit_price * o.quantity) AS total_revenue
FROM aisle_table AS a
JOIN products_table AS p USING (aisle_id)
JOIN orders_table AS o USING (product_id)
WHERE a.aisle = 'bread' AND o.order_date BETWEEN '2016-04-01' AND '2016-09-30'
						AND o.order_status IN ('Shipped', 'Delivered')
GROUP BY a.aisle;




--QUESTION 9
-- which 3 products do people buy at night(2020 - 2022)?

SELECT p.product_name,
		SUM(o.quantity) AS order_volume
FROM products_table AS p
JOIN orders_table AS o USING (product_id)
WHERE o.order_hour_of_day IN(20, 21, 22, 23, 0, 1, 2, 3, 4, 5)
			AND order_date BETWEEN '2020-01-01' AND '2022-12-31'
GROUP BY p.product_name
ORDER BY order_volume DESC
LIMIT 3;




--QUESTION 10
-- what is the total revenue generated from juice products?

SELECT '$' || ROUND(SUM(p.unit_price * o.quantity), 0) AS total_revenue
FROM products_table AS p
JOIN orders_table AS o USING (product_id)
WHERE p.product_name ILIKE '%juice%'  AND o.order_status IN ('Shipped', 'Delivered');




