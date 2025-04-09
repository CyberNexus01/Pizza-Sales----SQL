--------------- Creating Tables ---------------

CREATE TABLE pizza (
		pizza_id VARCHAR(50),
		pizza_type_id VARCHAR(50),
		size VARCHAR(50),
		price NUMERIC(10,2)
);
SELECT * FROM pizza;


CREATE TABLE pizza_types(
		pizza_type_id VARCHAR(50),
		name VARCHAR(50),
		category VARCHAR(50),
		ingredients VARCHAR(100)
);
SELECT * FROM pizza_types


CREATE TABLE orders(
		order_id INTEGER PRIMARY KEY,
		order_date DATE NOT NULL,
		order_time TIME NOT NULL
)
SELECT * FROM orders;


CREATE TABLE order_details(
		order_details_id INTEGER,
		order_id INTEGER,
		pizza_id VARCHAR(50),
		quantity INTEGER
)
SELECT * FROM order_details;


--------------- Questions ---------------


-- Retrieve the total number of orders placed.

SELECT COUNT(order_id) AS Total_Orders FROM orders;

-- Calclate the total revenue generated from pizza table 

SELECT
ROUND(SUM(order_details.quantity * pizza.price),2) AS total_sales
FROM order_details join pizza
ON pizza.pizza_id = order_details.pizza_id;

-- Identify Highest priced Pizza

SELECT pizza_types.name, pizza.price
FROM pizza_types JOIN pizza
ON pizza_types.pizza_type_id = pizza.pizza_type_id
ORder BY pizza.price DESC LIMIT 1;


-- Identify the most common pizza size ordered.

SELECT pizza.size, count(order_details.order_details_id) as order_count
FROM pizza Join order_details
ON pizza.pizza_id = order_details.pizza_id
Group by pizza.size order by order_count DESC;


-- List the top 5 most ordered pizza types along with their quantities.

SELECT pizza_types.name,
sum(order_details.quantity) as quantity
FROM pizza_types JOIN pizza
ON pizza_types.pizza_type_id = pizza.pizza_type_id
JOIN order_details on order_details.pizza_id = pizza.pizza_id
group by pizza_types.name order by quantity desc limit 5;


-- Join the necessary tables to find the total quantity of each pizza Category.

SELECT
	PIZZA_TYPES.CATEGORY,
	SUM(ORDER_DETAILS.QUANTITY) AS QUANTITY
FROM
	PIZZA_TYPES
	JOIN PIZZA ON PIZZA_TYPES.PIZZA_TYPE_ID = PIZZA.PIZZA_TYPE_ID
	JOIN ORDER_DETAILS ON ORDER_DETAILS.PIZZA_ID = PIZZA.PIZZA_ID
GROUP BY
	PIZZA_TYPES.CATEGORY
ORDER BY
	QUANTITY DESC;



-- Determine the distribution of orders by hour of the day.

select HOUR(order_time), count(order_id) from orders
group by HOUR(order_time);

SELECT * from orders;



-- Join relevant tables to find the category wise distribution of pizza

select category, count(name) from pizza_types
group by category;



-- Group the orders by date and calulate the average number of pizzas ordered per day.

select round(avg(quantity),0) as average_pizza_ordered_per_day from (
select orders.order_date, sum(order_details.quantity) as quantity
from orders join order_details
on orders.order_id = order_details.order_id
group by orders.order_date) as order_quantity;


-- Determine the top 3 most ordered pizza types based on revenue


select pizza_types.name, sum(order_details.quantity * pizza.price) as revenue
from pizza_types join pizza
on pizza.pizza_type_id = pizza_types.pizza_type_id
join order_details
on order_details.pizza_id = pizza.pizza_id
group by pizza_types.name order by revenue desc limit 3;


-- Calculate the percentage contribution of each pizza type to total revenue.

select count(category) from pizza_types;
select pizza_types.category,
round(sum(order_details.quantity * pizza.price)/(SELECT
ROUND(SUM(order_details.quantity * pizza.price),2) AS total_sales
FROM order_details join pizza
ON pizza.pizza_id = order_details.pizza_id)*100,2) as revenue
from pizza_types join pizza
on pizza_types.pizza_type_id = pizza.pizza_type_id
join order_details
on order_details.pizza_id = pizza.pizza_id
group by pizza_types.category order by revenue desc;


-- Analyze the cumulative revenue generated over time

select order_date,
sum(revenue) over (order by order_date) as cum_revenue
from
(select orders.order_date,
sum(order_details.quantity * pizza.price)as revenue from
order_details join pizza
on order_details.pizza_id = pizza.pizza_id
join orders
on orders.order_id = order_details.order_id
group by orders.order_date order by orders.order_date ASC) as sales ;


-- Determine the top 3 most ordered pizza types based on revenue for each pizza category

select name, revenue from
(select category, name, revenue,
rank() over(partition by category order by revenue desc) rn
from
(select pizza_types.category, pizza_types.name,
sum(order_details.quantity * pizza.price) as revenue
from pizza_types join pizza
on pizza_types.pizza_type_id = pizza.pizza_type_id
join order_details
on order_details.pizza_id = pizza.pizza_id
group by pizza_types.category, pizza_types.name) as a) as b
where rn <= 3;


