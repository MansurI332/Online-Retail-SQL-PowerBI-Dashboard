-- Retail Performance Metrics View
CREATE OR REPLACE VIEW vw_business_overview AS
SELECT
    ROUND(SUM(quantity * unitprice), 2) AS total_revenue,
    COUNT(DISTINCT invoiceno) AS total_orders,
    COUNT(DISTINCT customerid) AS total_customers,
    ROUND(
        SUM(quantity * unitprice) /
        COUNT(DISTINCT invoiceno),
        2
    ) AS avg_order_value,
    ROUND(
        SUM(quantity * unitprice) /
        COUNT(DISTINCT customerid),
        2
    ) AS revenue_per_customer
FROM retail_clean;


-- Monthly Revenue View
CREATE OR REPLACE VIEW vw_monthly_revenue AS
SELECT
    DATE_TRUNC('month', invoicedate)::date AS month,
    ROUND(SUM(quantity * unitprice), 2) AS revenue
FROM retail_clean
GROUP BY month
ORDER BY month;

-- Country Analysis View
CREATE OR REPLACE VIEW vw_country_analysis AS
SELECT
    country,
    COUNT(DISTINCT customerid) AS customers,
    ROUND(SUM(quantity * unitprice), 2) AS revenue,
    ROUND(
        SUM(quantity * unitprice) /
        COUNT(DISTINCT customerid),
        2
    ) AS revenue_per_customer
FROM retail_clean
GROUP BY country
ORDER BY revenue DESC;

-- Product Analysis View
CREATE OR REPLACE VIEW vw_product_analysis AS
SELECT
    description,
    SUM(quantity) AS units_sold,
    ROUND(SUM(quantity * unitprice), 2) AS revenue
FROM retail_clean
WHERE description NOT IN ('POSTAGE', 'Manual')
GROUP BY description;

-- Improved Country Analysis View
CREATE OR REPLACE VIEW vw_country_analysis_no_uk AS
SELECT
    country,
    COUNT(DISTINCT customerid) AS customers,
    ROUND(SUM(quantity * unitprice), 2) AS revenue,
    ROUND(
        SUM(quantity * unitprice) /
        COUNT(DISTINCT customerid),
        2
    ) AS revenue_per_customer
FROM retail_clean
WHERE country <> 'United Kingdom'
GROUP BY country
ORDER BY revenue DESC;

-- RFM Segmentation View
CREATE OR REPLACE VIEW vw_rfm_segments AS
WITH reference_date AS (
    SELECT DATE(MAX(invoicedate)) AS max_date
    FROM retail_clean
),
rfm_base AS (
    SELECT
        customerid,
        (SELECT max_date FROM reference_date) - DATE(MAX(invoicedate)) AS recency,
        COUNT(DISTINCT invoiceno) AS frequency,
        ROUND(SUM(quantity * unitprice), 2) AS monetary
    FROM retail_clean
    GROUP BY customerid
),
scored_customers AS (
    SELECT
        customerid,
        monetary,
        6 - NTILE(5) OVER (ORDER BY recency ASC) AS r_score,
        NTILE(5) OVER (ORDER BY frequency ASC) AS f_score,
        NTILE(5) OVER (ORDER BY monetary ASC) AS m_score
    FROM rfm_base
)
SELECT
    customerid,
    monetary,
    CASE
        WHEN r_score = 5
         AND f_score = 5
         AND m_score = 5
        THEN 'VIP Customer'

        WHEN r_score >= 4
         AND f_score >= 4
         AND m_score >= 4
        THEN 'Loyal Customer'

        WHEN r_score <= 2
        THEN 'Low Value Customer'

        ELSE 'Regular Customer'
    END AS customer_segment
FROM scored_customers;

-- Summary Table View
CREATE OR REPLACE VIEW vw_rfm_summary AS
WITH reference_date AS (
    SELECT DATE(MAX(invoicedate)) AS max_date
    FROM retail_clean
),
rfm_base AS (
    SELECT
        customerid,
        (SELECT max_date FROM reference_date) - DATE(MAX(invoicedate)) AS recency,
        COUNT(DISTINCT invoiceno) AS frequency,
        ROUND(SUM(quantity * unitprice), 2) AS monetary
    FROM retail_clean
    GROUP BY customerid
),
scored_customers AS (
    SELECT
        customerid,
        monetary,
        6 - NTILE(5) OVER (ORDER BY recency ASC) AS r_score,
        NTILE(5) OVER (ORDER BY frequency ASC) AS f_score,
        NTILE(5) OVER (ORDER BY monetary ASC) AS m_score
    FROM rfm_base
),
rfm_segments AS (
    SELECT
        customerid,
        monetary,
        CASE
            WHEN r_score = 5
             AND f_score = 5
             AND m_score = 5
            THEN 'VIP Customer'

            WHEN r_score >= 4
             AND f_score >= 4
             AND m_score >= 4
            THEN 'Loyal Customer'

            WHEN r_score <= 2
            THEN 'Low Value Customer'

            ELSE 'Regular Customer'
        END AS customer_segment
    FROM scored_customers
)
SELECT
    customer_segment,
    COUNT(*) AS customers,
    ROUND(
        100.0 * COUNT(*) / SUM(COUNT(*)) OVER (),
        2
    ) AS customer_percentage,
    ROUND(AVG(monetary), 2) AS avg_customer_value
FROM rfm_segments
GROUP BY customer_segment;

-- Market Analysis View
CREATE OR REPLACE VIEW vw_market_analysis AS
SELECT
    CASE
        WHEN country = 'United Kingdom'
            THEN 'United Kingdom'
        ELSE 'International'
    END AS market,
    ROUND(SUM(quantity * unitprice), 2) AS revenue
FROM retail_clean
GROUP BY 1;

-- Top Product View
CREATE OR REPLACE VIEW vw_product_kpis AS
WITH ranked_products AS (
    SELECT *,
           ROW_NUMBER() OVER (ORDER BY revenue DESC) AS revenue_rank,
           ROW_NUMBER() OVER (ORDER BY units_sold DESC) AS units_rank
    FROM vw_product_analysis
)
SELECT
    (SELECT description
     FROM ranked_products
     WHERE revenue_rank = 1) AS top_revenue_product,
    (SELECT revenue
     FROM ranked_products
     WHERE revenue_rank = 1) AS top_product_revenue,
    (SELECT description
     FROM ranked_products
     WHERE units_rank = 1) AS top_units_product,
    (SELECT units_sold
     FROM ranked_products
     WHERE units_rank = 1) AS top_product_units_sold,
    COUNT(*) AS total_products,
    ROUND(AVG(revenue), 2) AS avg_revenue_per_product
FROM vw_product_analysis;