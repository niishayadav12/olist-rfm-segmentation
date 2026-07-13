-- ============================================
-- PROJECT: Olist RFM Customer Segmentation
-- FILE: 03 - Basic Analysis
-- PURPOSE: Answer core business questions
-- ============================================

USE olist_rfm_project;

-- Q1: Total revenue, orders and unique customers overall
SELECT
    COUNT(DISTINCT o.order_id)          AS total_orders,
    COUNT(DISTINCT c.customer_unique_id) AS unique_customers,
    ROUND(SUM(oi.price + oi.freight_value), 2) AS total_revenue,
    ROUND(AVG(oi.price + oi.freight_value), 2) AS avg_order_value
FROM orders o
JOIN order_items oi ON o.order_id = oi.order_id
JOIN customers c    ON o.customer_id = c.customer_id
WHERE o.order_status = 'delivered';

-- Q2: Revenue by month
SELECT
    DATE_FORMAT(o.order_purchase_timestamp, '%Y-%m') AS month,
    COUNT(DISTINCT o.order_id)       AS orders,
    ROUND(SUM(oi.price), 2)          AS revenue
FROM orders o
JOIN order_items oi ON o.order_id = oi.order_id
WHERE o.order_status = 'delivered'
GROUP BY month
ORDER BY month;

-- Q3: Revenue by customer state
SELECT
    c.customer_state,
    COUNT(DISTINCT o.order_id)  AS total_orders,
    ROUND(SUM(oi.price), 2)     AS total_revenue
FROM orders o
JOIN order_items oi ON o.order_id = oi.order_id
JOIN customers c    ON o.customer_id = c.customer_id
WHERE o.order_status = 'delivered'
GROUP BY c.customer_state
ORDER BY total_revenue DESC;

-- Q4: Average review score by state
SELECT
    c.customer_state,
    ROUND(AVG(r.review_score), 2) AS avg_review,
    COUNT(r.review_id)            AS total_reviews
FROM order_reviews r
JOIN orders o    ON r.order_id = o.order_id
JOIN customers c ON o.customer_id = c.customer_id
GROUP BY c.customer_state
ORDER BY avg_review DESC;

-- Q5: Late delivery analysis by state
SELECT
    c.customer_state,
    COUNT(*) AS total_delivered,
    SUM(CASE 
        WHEN o.order_delivered_customer_date > o.order_estimated_delivery_date 
        THEN 1 ELSE 0 END)                               AS late_deliveries,
    ROUND(SUM(CASE 
        WHEN o.order_delivered_customer_date > o.order_estimated_delivery_date 
        THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2)       AS late_pct,
    ROUND(AVG(DATEDIFF(
        o.order_delivered_customer_date,
        o.order_estimated_delivery_date)), 2)            AS avg_delay_days
FROM orders o
JOIN customers c ON o.customer_id = c.customer_id
WHERE o.order_delivered_customer_date IS NOT NULL
GROUP BY c.customer_state
ORDER BY late_pct DESC;

-- Q6: KEY INSIGHT - Do late deliveries hurt review scores?
SELECT
    CASE 
        WHEN o.order_delivered_customer_date > o.order_estimated_delivery_date 
        THEN 'Late' 
        ELSE 'On Time' 
    END                               AS delivery_status,
    ROUND(AVG(r.review_score), 2)     AS avg_review_score,
    COUNT(*)                          AS order_count
FROM orders o
JOIN order_reviews r ON o.order_id = r.order_id
WHERE o.order_delivered_customer_date IS NOT NULL
GROUP BY delivery_status;
-- FINDING: Late deliveries get significantly lower review scores
