/*
Customer Analysis
*/


-- Which customers generate most revenue
SELECT
    customerid,
    ROUND(SUM(quantity * unitprice), 2) AS revenue
FROM retail_clean
GROUP BY customerid
ORDER BY revenue DESC
LIMIT 10;

-- Which customers place the most orders
SELECT
    customerid,
    COUNT(DISTINCT invoiceno) AS orders
FROM retail_clean
GROUP BY customerid
ORDER BY orders DESC
LIMIT 10;


-- How much revenue each customer generates
WITH customer_summary AS (
    SELECT
        customerid,
        ROUND(SUM(quantity * unitprice), 2) AS revenue,
        COUNT(DISTINCT invoiceno) AS orders
    FROM retail_clean
    GROUP BY customerid
)
SELECT
    customerid,
    orders,
    revenue,
    RANK() OVER (ORDER BY revenue DESC) AS revenue_rank
FROM customer_summary
ORDER BY revenue_rank
LIMIT 20;

--How many customers order once vs repeatedly
WITH customer_orders AS (
    SELECT
        customerid,
        COUNT(DISTINCT invoiceno) AS orders
    FROM retail_clean
    GROUP BY customerid
)

SELECT
    orders,
    COUNT(*) AS customers
FROM customer_orders
GROUP BY orders
ORDER BY orders;

--Repeat customer rate
WITH customer_orders AS (
    SELECT
        customerid,
        COUNT(DISTINCT invoiceno) AS orders
    FROM retail_clean
    GROUP BY customerid
)
SELECT
    COUNT(*) AS total_customers,
    COUNT(CASE WHEN orders > 1 THEN 1 END) AS repeat_customers,
    ROUND(100.0 * COUNT(CASE WHEN orders > 1 THEN 1 END)/ COUNT(*),2) AS repeat_customer_percentage
FROM customer_orders;