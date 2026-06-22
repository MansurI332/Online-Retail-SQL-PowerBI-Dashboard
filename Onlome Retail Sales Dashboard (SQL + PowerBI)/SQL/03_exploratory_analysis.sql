/*
Exploratory Analysis
*/


-- Business Overview:
SELECT
    ROUND(SUM(quantity * unitprice), 2) AS total_revenue,
    COUNT(DISTINCT invoiceno) AS total_orders,
    COUNT(DISTINCT customerid) AS total_customers,
    ROUND(SUM(quantity * unitprice)/ COUNT(DISTINCT invoiceno),2)  AS avg_order_value,
    ROUND(SUM(quantity * unitprice)/ COUNT(DISTINCT customerid),2) AS revenue_per_customer
FROM retail_clean;
/* 
Total Revenue: £8,911,407.9   0
Total Number of Orders: 18536
Total Number of Customers: 4339
Average Order Value: 480.76
Revenue Per Customer: £2053.79
*/

--Product Analysis:
SELECT
    description,
    SUM(quantity) AS units_sold
FROM retail_clean
GROUP BY description
ORDER BY units_sold DESC
LIMIT 10;
-- Top 10 products by units sold

SELECT
    description,
    ROUND(SUM(quantity * unitprice), 2) AS revenue
FROM retail_clean
GROUP BY description
ORDER BY revenue DESC
LIMIT 10;
-- Top 10 products by revenue

-- Country Analysis
SELECT
    country,
    COUNT(DISTINCT customerid) AS customers,
    ROUND(SUM(quantity * unitprice), 2) AS revenue,
    ROUND(SUM(quantity * unitprice)/ COUNT(DISTINCT customerid),2)AS revenue_per_customer
FROM retail_clean
GROUP BY country
ORDER BY revenue DESC;

SELECT
    CASE
        WHEN country = 'United Kingdom'
            THEN 'United Kingdom'
        ELSE 'International'
    END AS market,
    ROUND(SUM(quantity * unitprice), 2) AS revenue
FROM retail_clean
GROUP BY
    CASE
        WHEN country = 'United Kingdom'
            THEN 'United Kingdom'
        ELSE 'International'
    END;

-- Time Analysis
SELECT
    DATE_TRUNC('month', invoicedate)::date AS month,
    ROUND(SUM(quantity * unitprice), 2) AS revenue
FROM retail_clean
GROUP BY month
ORDER BY month;


