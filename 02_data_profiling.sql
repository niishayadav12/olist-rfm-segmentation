-- ============================================
-- PROJECT: Olist RFM Customer Segmentation
-- FILE: 02 - Data Profiling
-- PURPOSE: Understand data before any analysis
-- ============================================

USE olist_rfm_project;

-- Q1: How many records in each table?
SELECT 'customers'    AS table_name, COUNT(*) AS row_count FROM customers
UNION ALL
SELECT 'orders',      COUNT(*) FROM orders
UNION ALL
SELECT 'order_items', COUNT(*) FROM order_items
UNION ALL
SELECT 'order_reviews', COUNT(*) FROM order_reviews;

-- Q2: What order statuses exist and how many?
SELECT 
    order_status, 
    COUNT(*) AS count
FROM orders
GROUP BY order_status
ORDER BY count DESC;

-- Q3: What is the date range of the data?
SELECT
    MIN(order_purchase_timestamp) AS earliest_order,
    MAX(order_purchase_timestamp) AS latest_order,
    DATEDIFF(
        MAX(order_purchase_timestamp), 
        MIN(order_purchase_timestamp)
    ) AS total_days_of_data
FROM orders;

-- Q4: How many NULL delivery dates exist? (Data quality check)
SELECT
    COUNT(*) AS total_orders,
    SUM(CASE WHEN order_delivered_customer_date IS NULL THEN 1 ELSE 0 END) AS null_deliveries,
    SUM(CASE WHEN order_approved_at IS NULL THEN 1 ELSE 0 END) AS null_approvals,
    ROUND(
        SUM(CASE WHEN order_delivered_customer_date IS NULL THEN 1 ELSE 0 END) 
        * 100.0 / COUNT(*), 2
    ) AS null_delivery_pct
FROM orders;

-- Q5: Unique customers check
SELECT
    COUNT(*) AS total_customer_rows,
    COUNT(DISTINCT customer_id) AS unique_customer_ids,
    COUNT(DISTINCT customer_unique_id) AS unique_customers
FROM customers;
-- NOTE: customer_id and customer_unique_id differ
-- because one person can place multiple orders with different customer_ids
-- Always use customer_unique_id for true customer count

-- Q6: CRITICAL FINDING - How many customers are repeat buyers?
SELECT 
    frequency_bucket,
    COUNT(*) AS customers,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(), 2) AS pct
FROM (
    SELECT 
        c.customer_unique_id,
        COUNT(DISTINCT o.order_id) AS order_count,
        CASE 
            WHEN COUNT(DISTINCT o.order_id) = 1  THEN '1 order'
            WHEN COUNT(DISTINCT o.order_id) = 2  THEN '2 orders'
            WHEN COUNT(DISTINCT o.order_id) >= 3 THEN '3+ orders'
        END AS frequency_bucket
    FROM orders o
    JOIN customers c ON o.customer_id = c.customer_id
    WHERE o.order_status = 'delivered'
    GROUP BY c.customer_unique_id
) AS freq_check
GROUP BY frequency_bucket
ORDER BY customers DESC;
-- RESULT: 97% of customers bought exactly once
-- This caused the RFM model to be adapted (see file 04)
