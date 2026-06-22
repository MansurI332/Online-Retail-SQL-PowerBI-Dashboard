/*
RFM Analysis
*/

-- Calculate RFM metrics, assign score, calculate overall FRM score and segment customers.
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
        recency,
        frequency,
        monetary,
        -- 5 = most recent customers
        6 - NTILE(5) OVER (ORDER BY recency ASC) AS r_score,
        -- 5 = most frequent customers
        NTILE(5) OVER (ORDER BY frequency ASC) AS f_score,
        -- 5 = highest spending customers
        NTILE(5) OVER (ORDER BY monetary ASC) AS m_score
    FROM rfm_base
)

SELECT
    customerid,
    recency,
    frequency,
    monetary,
    r_score,
    f_score,
    m_score,
    (r_score + f_score + m_score) AS rfm_score,
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
ORDER BY
    rfm_score DESC,
    monetary DESC,
    frequency DESC;

-- Customer Segmentation Categories
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
GROUP BY customer_segment
ORDER BY
    CASE customer_segment
        WHEN 'Low Value Customer' THEN 1
        WHEN 'Regular Customer' THEN 2
        WHEN 'Loyal Customer' THEN 3
        WHEN 'VIP Customer' THEN 4
    END;