CREATE SCHEMA dannys_diner;
USE dannys_diner;

CREATE TABLE sales (
	customer_id VARCHAR(1),
	order_date DATE,
    product_id INT
 );

INSERT INTO sales(customer_id, order_date, product_id) VALUES
  ('A', '2021-01-01', 1),
  ('A', '2021-01-01', 2),
  ('A', '2021-01-07', 2),
  ('A', '2021-01-10', 3),
  ('A', '2021-01-11', 3),
  ('A', '2021-01-11', 3),
  ('B', '2021-01-01', 2),
  ('B', '2021-01-02', 2),
  ('B', '2021-01-04', 1),
  ('B', '2021-01-11', 1),
  ('B', '2021-01-16', 3),
  ('B', '2021-02-01', 3),
  ('C', '2021-01-01', 3),
  ('C', '2021-01-01', 3),
  ('C', '2021-01-07', 3);
 

CREATE TABLE menu (
  product_id INT,
  product_name VARCHAR(5),
  price INT
);

INSERT INTO menu
  (product_id, product_name, price)
VALUES
  ('1', 'sushi', '10'),
  ('2', 'curry', '15'),
  ('3', 'ramen', '12');
  

CREATE TABLE members (
  customer_id VARCHAR(1),
  join_date DATE
);

INSERT INTO members
  (customer_id, join_date)
VALUES
  ('A', '2021-01-07'),
  ('B', '2021-01-09');
  
 /* --------------------
   Case Study Questions
   --------------------*/

-- 1. What is the total amount each customer spent at the restaurant? 

SELECT 
	customer_id,
    SUM(price) as total
FROM sales
INNER JOIN menu
ON sales.product_id = menu.product_id
GROUP BY customer_id;

-- 2. How many days has each customer visited the restaurant?

SELECT
	customer_id,
	COUNT(DISTINCT(order_date)) AS days
FROM sales
GROUP BY customer_id;

-- 3. What was the first item from the menu purchased by each customer?

WITH sales_order_date AS(
	SELECT 
		customer_id,
        order_date,
        product_name,
        RANK()
        OVER (PARTITION BY customer_id ORDER BY order_date ASC) AS ranking
	FROM sales
    INNER JOIN menu
    ON sales.product_id = menu.product_id
    )
SELECT customer_id, product_name
FROM sales_order_date
WHERE ranking = 1;

-- 4. What is the most purchased item on the menu and how many times was it purchased by all customers?

SELECT 
	product_name,
	COUNT(product_name) AS orders
FROM sales
INNER JOIN menu
ON sales.product_id = menu.product_id
GROUP BY product_name
ORDER BY orders DESC
LIMIT 1;

-- 5. Which item was the most popular for each customer?

WITH popular_product AS(
	SELECT
		customer_id,
		product_name,
		COUNT(order_date) as orders,
		RANK()
		OVER(PARTITION BY customer_id ORDER BY COUNT(order_date) DESC) AS top
	FROM sales 
	INNER JOIN menu
	ON sales.product_id = menu.product_id
	GROUP BY product_name, customer_id
	)
SELECT
	customer_id,
    product_name,
    orders
FROM popular_product
WHERE top = 1;
    

-- 6. Which item was purchased first by the customer after they became a member?
WITH product_member_af AS(
	SELECT 
		sales.customer_id,
		product_name,
		order_date,
		join_date,
		TIMEDIFF(order_date, join_date) AS time_diff,
		RANK()
		OVER(PARTITION BY sales.customer_id ORDER BY TIMEDIFF(order_date, join_date) ASC) AS ranking
	FROM sales 
	INNER JOIN members
	ON sales.customer_id = members.customer_id
	INNER JOIN menu
	ON sales.product_id = menu.product_id
	WHERE timediff(order_date, join_date) > 0
    )
SELECT 
	customer_id,
    product_name
FROM product_member_af
WHERE ranking = 1;

-- 7. Which item was purchased just before the customer became a member?

WITH product_member_bf AS(
	SELECT 
		sales.customer_id,
		product_name,
		order_date,
		join_date,
		TIMEDIFF(order_date, join_date) AS time_diff,
		RANK()
		OVER(PARTITION BY sales.customer_id ORDER BY TIMEDIFF(order_date, join_date) DESC) AS ranking
	FROM sales 
	INNER JOIN members
	ON sales.customer_id = members.customer_id
	INNER JOIN menu
	ON sales.product_id = menu.product_id
	WHERE timediff(order_date, join_date) <= 0
    )
SELECT 
	customer_id,
    product_name
FROM product_member_bf
WHERE ranking = 1;

-- 8. What is the total items and amount spent for each member before they became a member?

SELECT 
	sales.customer_id,
    COUNT(order_date) AS orders,
    SUM(price) AS total 
FROM sales 
	INNER JOIN members
	ON sales.customer_id = members.customer_id
	INNER JOIN menu
	ON sales.product_id = menu.product_id
WHERE timediff(order_date, join_date) < 0
GROUP BY customer_id;

-- 9.  If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?

SELECT 
	sales.customer_id,
    SUM(IF(product_name = 'sushi', price*20, price*10)) AS points
FROM sales 
	INNER JOIN members
	ON sales.customer_id = members.customer_id
	INNER JOIN menu
	ON sales.product_id = menu.product_id
GROUP BY sales.customer_id;

-- 10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items,
-- not just sushi - how many points do customer A and B have at the end of January?

SELECT 
	sales.customer_id,
	SUM(CASE 
			WHEN product_name = 'sushi' THEN price * 20
			WHEN order_date BETWEEN join_date AND DATE_ADD(order_date, INTERVAL 6 DAY)
			THEN price * 20
            ELSE price * 10 
	END) AS points
FROM sales
INNER JOIN members 
ON sales.customer_id = members.customer_id
INNER JOIN menu
ON sales.product_id = menu.product_id
WHERE EXTRACT(MONTH FROM order_date) = 01
GROUP BY sales.customer_id;



