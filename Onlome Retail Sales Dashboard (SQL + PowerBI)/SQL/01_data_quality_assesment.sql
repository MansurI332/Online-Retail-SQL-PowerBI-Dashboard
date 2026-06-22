/*
Data Quality Assesment
*/

SELECT COUNT (*) as total_rows
FROM online_retail;
-- Initial Dataset Size: 541,909 rows

SELECT COUNT(*) as missing_customers
FROM online_retail
WHERE customerid IS NULL;
-- Missing Customer ID's: 135,080 rows

SELECT ROUND(
        100.0 * COUNT(*) / (SELECT COUNT(*) FROM online_retail),
        2
    ) AS pct_missing
FROM online_retail
WHERE customerid IS NULL;
-- 24.9% of the dataset has missing Customer ID's

SELECT
    MIN(quantity) AS min_quantity,
    MAX(quantity) AS max_quantity
FROM online_retail;
-- Negative quantities may represent returns or cancellations

SELECT *
FROM online_retail
WHERE quantity = -80995
   OR quantity = 80995;
-- Same item but negative quantity invoice number starts with "C"

SELECT
    COUNT(CASE WHEN invoiceno LIKE 'C%' THEN 1 END) AS cancelled_orders,
    COUNT(CASE WHEN quantity < 0 THEN 1 END) AS negative_quantity_rows
FROM online_retail;
-- Invoice numbers starting with "C" rows is not the same amount as the num of negative quantity rows

SELECT
    COUNT(*) AS negative_not_cancelled
FROM online_retail
WHERE quantity < 0
  AND invoiceno NOT LIKE 'C%';
-- 1,336 negative quantity rows don't belong to cancelled invoices

SELECT *
FROM online_retail
WHERE quantity < 0
  AND invoiceno NOT LIKE 'C%'
LIMIT 50;
-- These rows seem to be non-sales transactions, caused by inventory mismanagment, damages, etc.
-- Rows with quantity <= 0 will be excluded from further analysis.


SELECT COUNT(DISTINCT (
    invoiceno,
    stockcode,
    quantity,
    invoicedate,
    customerid
))
AS distinct_rows
FROM online_retail;
-- 536,480 distinct rows so there is 5,429 duplicate records

SELECT
    invoiceno,
    stockcode,
    quantity,
    invoicedate,
    customerid,
    COUNT(*) AS occurrences
FROM online_retail
GROUP BY
    invoiceno,
    stockcode,
    quantity,
    invoicedate,
    customerid
HAVING COUNT(*) > 1
ORDER BY occurrences DESC
LIMIT 20;
-- No records to be removed since there is no evidence of data entry errors, special stock codes which aren't clear 

SELECT
    MIN(invoicedate) AS first_transaction,
    MAX(invoicedate) AS last_transaction
FROM online_retail;
-- Dataset covers transactions from 2010/12/01 tp 2011/12/09