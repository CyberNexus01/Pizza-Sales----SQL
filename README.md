Author - Vishwajeet Sarkar

# Pizza Sales Analysis using SQL

This document outlines a set of SQL queries designed to analyze pizza sales data. The queries are categorized into Basic, Intermediate, and Advanced levels, providing a progressive approach to understanding sales patterns and trends.

## Database Schema (Assumed)

To execute these queries, you'll need a database with tables containing information about orders, order details, pizzas, and pizza categories. A likely schema would include:

* **Orders Table:**
    * `order_id` (INT, Primary Key)
    * `order_date` (DATE)
    * `order_time` (TIME)
    * (Potentially other customer or order-related information)
* **Order Details Table:**
    * `order_detail_id` (INT, Primary Key)
    * `order_id` (INT, Foreign Key referencing Orders table)
    * `pizza_id` (INT, Foreign Key referencing Pizzas table)
    * `quantity` (INT)
* **Pizzas Table:**
    * `pizza_id` (INT, Primary Key)
    * `pizza_name` (VARCHAR)
    * `category_id` (INT, Foreign Key referencing Pizza Categories table)
    * `size` (VARCHAR)
    * `price` (DECIMAL)
* **Pizza Categories Table:**
    * `category_id` (INT, Primary Key)
    * `category_name` (VARCHAR)

**Note:** The specific table and column names might vary depending on your database structure. You'll need to adjust the queries accordingly.

## Basic Queries

These queries address fundamental questions about the pizza sales data.

1.  **Retrieve the total number of orders placed.**

    ```sql
    SELECT COUNT(DISTINCT order_id) AS total_orders
    FROM Orders;
    ```

2.  **Calculate the total revenue generated from pizza sales.**

    ```sql
    SELECT SUM(od.quantity * p.price) AS total_revenue
    FROM Order_Details od
    JOIN Pizzas p ON od.pizza_id = p.pizza_id;
    ```

3.  **Identify the highest-priced pizza.**

    ```sql
    SELECT pizza_name, price
    FROM Pizzas
    ORDER BY price DESC
    LIMIT 1;
    ```

4.  **Identify the most common pizza size ordered.**

    ```sql
    SELECT p.size, COUNT(*) AS order_count
    FROM Order_Details od
    JOIN Pizzas p ON od.pizza_id = p.pizza_id
    GROUP BY p.size
    ORDER BY order_count DESC
    LIMIT 1;
    ```

5.  **List the top 5 most ordered pizza types along with their quantities.**

    ```sql
    SELECT p.pizza_name, SUM(od.quantity) AS total_quantity
    FROM Order_Details od
    JOIN Pizzas p ON od.pizza_id = p.pizza_id
    GROUP BY p.pizza_name
    ORDER BY total_quantity DESC
    LIMIT 5;
    ```

## Intermediate Queries

These queries involve joining tables and performing more complex aggregations.

1.  **Join the necessary tables to find the total quantity of each pizza category ordered.**

    ```sql
    SELECT pc.category_name, SUM(od.quantity) AS total_quantity
    FROM Order_Details od
    JOIN Pizzas p ON od.pizza_id = p.pizza_id
    JOIN Pizza_Categories pc ON p.category_id = pc.category_id
    GROUP BY pc.category_name
    ORDER BY total_quantity DESC;
    ```

2.  **Determine the distribution of orders by hour of the day.**

    ```sql
    SELECT CAST(strftime('%H', order_time) AS INTEGER) AS order_hour, COUNT(*) AS order_count
    FROM Orders
    GROUP BY order_hour
    ORDER BY order_hour;
    ```
    *(Note: The `strftime('%H', order_time)` function might need adjustment based on your specific SQL dialect (e.g., `HOUR(order_time)` in MySQL, `EXTRACT(HOUR FROM order_time)` in PostgreSQL).*

3.  **Join relevant tables to find the category-wise distribution of pizzas.**

    ```sql
    SELECT pc.category_name, p.pizza_name, COUNT(od.order_detail_id) AS order_count
    FROM Order_Details od
    JOIN Pizzas p ON od.pizza_id = p.pizza_id
    JOIN Pizza_Categories pc ON p.category_id = pc.category_id
    GROUP BY pc.category_name, p.pizza_name
    ORDER BY pc.category_name, order_count DESC;
    ```

4.  **Group the orders by date and calculate the average number of pizzas ordered per day.**

    ```sql
    SELECT o.order_date, AVG(daily_orders) AS average_pizzas_per_day
    FROM (
        SELECT order_date, SUM(od.quantity) AS daily_orders
        FROM Orders o
        JOIN Order_Details od ON o.order_id = od.order_id
        GROUP BY order_date
    ) AS daily_order_counts
    GROUP BY o.order_date
    ORDER BY o.order_date;
    ```

5.  **Determine the top 3 most ordered pizza types based on revenue.**

    ```sql
    SELECT p.pizza_name, SUM(od.quantity * p.price) AS total_revenue
    FROM Order_Details od
    JOIN Pizzas p ON od.pizza_id = p.pizza_id
    GROUP BY p.pizza_name
    ORDER BY total_revenue DESC
    LIMIT 3;
    ```

## Advanced Queries

These queries involve more complex calculations and analysis.

1.  **Calculate the percentage contribution of each pizza type to total revenue.**

    ```sql
    WITH PizzaRevenue AS (
        SELECT p.pizza_name, SUM(od.quantity * p.price) AS pizza_revenue
        FROM Order_Details od
        JOIN Pizzas p ON od.pizza_id = p.pizza_id
        GROUP BY p.pizza_name
    ),
    TotalRevenue AS (
        SELECT SUM(pizza_revenue) AS total_revenue FROM PizzaRevenue
    )
    SELECT pr.pizza_name,
           (pr.pizza_revenue * 100.0 / tr.total_revenue) AS percentage_contribution
    FROM PizzaRevenue pr, TotalRevenue tr
    ORDER BY percentage_contribution DESC;
    ```

2.  **Analyze the cumulative revenue generated over time.**

    ```sql
    SELECT
        o.order_date,
        SUM(od.quantity * p.price) OVER (ORDER BY o.order_date) AS cumulative_revenue
    FROM Orders o
    JOIN Order_Details od ON o.order_id = od.order_id
    JOIN Pizzas p ON od.pizza_id = p.pizza_id
    ORDER BY o.order_date;
    ```
    *(Note: The `OVER (ORDER BY o.order_date)` clause is a window function and might have slightly different syntax depending on your SQL dialect).*

3.  **Determine the top 3 most ordered pizza types based on revenue for each pizza category.**

    ```sql
    WITH CategoryPizzaRevenue AS (
        SELECT
            pc.category_name,
            p.pizza_name,
            SUM(od.quantity * p.price) AS pizza_revenue,
            ROW_NUMBER() OVER (PARTITION BY pc.category_name ORDER BY SUM(od.quantity * p.price) DESC) AS rn
        FROM Order_Details od
        JOIN Pizzas p ON od.pizza_id = p.pizza_id
        JOIN Pizza_Categories pc ON p.category_id = pc.category_id
        GROUP BY pc.category_name, p.pizza_name
    )
    SELECT category_name, pizza_name, pizza_revenue
    FROM CategoryPizzaRevenue
    WHERE rn <= 3
    ORDER BY category_name, pizza_revenue DESC;
    ```

## How to Use

1.  **Connect to your SQL database** containing the pizza sales data.
2.  **Copy and paste** the desired SQL query into your SQL client or application.
3.  **Execute** the query.
4.  **Analyze the results** to gain insights into your pizza sales data.

Remember to adjust the table and column names in the queries to match your specific database schema. This README provides a starting point for your pizza sales analysis. You can further expand on these queries to explore more specific aspects of your data.
