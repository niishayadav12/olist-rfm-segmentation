-- ============================================
-- PROJECT: Olist RFM Customer Segmentation
-- FILE: 04 - Intermediate Analysis
-- PURPOSE: Window functions, CTEs, trends
-- ============================================

USE olist_rfm_project;

-- Q1: Month over month revenue growth using LAG()
WITH monthly_revenue AS (
    SELECT
        DATE_FORMAT(o.order_purchase_timestamp, '%Y-%m') AS month,
        ROUND(SUM(oi.price), 2) AS revenue
    FROM orders o
    JOIN order_items oi ON o.order_id = oi.order_id
    WHERE o.order_status = 'delivered'
    GROUP BY month
)
SELECT
    month,
    revenue,
    LAG(revenue) OVER (ORDER BY month)  AS prev_month_revenue,
    ROUND(
        (revenue - LAG(revenue) OVER (ORDER BY month))
        / LAG(revenue) OVER (ORDER BY month) * 100
    , 2)                                 AS mom_growth_pct
FROM monthly_revenue
ORDER BY month;

-- Q2: Running cumulative revenue by year
SELECT
    DATE_FORMAT(order_purchase_timestamp, '%Y-%m') AS month,
    ROUND(SUM(oi.price), 2) AS monthly_revenue,
    ROUND(SUM(SUM(oi.price)) OVER (
        PARTITION BY YEAR(o.order_purchase_timestamp)
        ORDER BY DATE_FORMAT(o.order_purchase_timestamp, '%Y-%m')
    ), 2) AS cumulative_revenue_ytd
FROM orders o
JOIN order_items oi ON o.order_id = oi.order_id
WHERE o.order_status = 'delivered'
GROUP BY DATE_FORMAT(order_purchase_timestamp, '%Y-%m'),
         YEAR(o.order_purchase_timestamp)
ORDER BY month;

-- Q3: Top 3 states by revenue per year using RANK()
WITH state_yearly AS (
    SELECT
        YEAR(o.order_purchase_timestamp)    AS yr,
        c.customer_state,
        ROUND(SUM(oi.price), 2)             AS revenue
    FROM orders o
    JOIN order_items oi ON o.order_id = oi.order_id
    JOIN customers c    ON o.customer_id = c.customer_id
    WHERE o.order_status = 'delivered'
    GROUP BY yr, c.customer_state
),
ranked AS (
    SELECT *,
        RANK() OVER (PARTITION BY yr ORDER BY revenue DESC) AS revenue_rank
    FROM state_yearly
)
SELECT * FROM ranked
WHERE revenue_rank <= 3
ORDER BY yr, revenue_rank;
