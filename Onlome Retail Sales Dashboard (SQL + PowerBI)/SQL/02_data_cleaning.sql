/* 
Data Cleaning
Removed rows with missing Customer ID's as they are required for customer-level analysis.
Removed rows with non-positive quantities as they represent returns, cancellations, and other non sales transactions.
*/

CREATE OR REPLACE VIEW retail_clean AS
SELECT *
FROM online_retail
WHERE customerid IS NOT NULL
  AND quantity > 0;

SELECT
    COUNT(*) AS cleaned_rows,
    COUNT(CASE WHEN customerid IS NULL THEN 1 END) AS remaining_missing_customers,
    COUNT(CASE WHEN quantity <= 0 THEN 1 END) AS remaining_negative_quantities
FROM retail_clean;

