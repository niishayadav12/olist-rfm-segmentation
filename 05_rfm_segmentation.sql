-- ============================================
-- PROJECT: Olist RFM Customer Segmentation
-- FILE: 05 - RFM Segmentation (Final)
-- PURPOSE: Segment customers by Recency + Monetary
-- NOTE: Frequency removed because 97% of customers
--       bought exactly once (see file 02 finding)
-- ============================================

USE olist_rfm_project;

-- STEP 1: FREQUENCY CHECK (Run this to confirm data limitation)
SELECT 
    frequency_bucket,
    COUNT(*) AS customers,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(), 2) AS pct
FROM (
    SELECT 
        c.customer_unique_id,
        CASE 
            WHEN COUNT(DISTINCT o.order_id) = 1  THEN '1 order'
            WHEN COUNT(DISTINCT o.order_id) = 2  THEN '2 orders'
            WHEN COUNT(DISTINCT o.order_id) >= 3 THEN '3+ orders'
        END AS frequency_bucket
    FROM orders o
    JOIN customers c ON o.customer_id = c.customer_id
    WHERE o.order_status = 'delivered'
    GROUP BY c.customer_unique_id
) freq
GROUP BY frequency_bucket
ORDER BY customers DESC;


-- STEP 2: FULL RFM SEGMENTATION (Recency + Monetary only)

WITH rfm_base AS (
    -- Calculate base metrics per unique customer
    SELECT
        c.customer_unique_id,
        MAX(o.order_purchase_timestamp)      AS last_purchase_date,
        COUNT(DISTINCT o.order_id)           AS frequency,
        ROUND(SUM(oi.price + oi.freight_value), 2) AS monetary
    FROM orders o
    JOIN order_items oi ON o.order_id = oi.order_id
    JOIN customers c    ON o.customer_id = c.customer_id
    WHERE o.order_status = 'delivered'
    GROUP BY c.customer_unique_id
),

rfm_recency AS (
    -- Calculate how many days since last purchase
    SELECT *,
        DATEDIFF('2018-10-17', last_purchase_date) AS recency_days
    FROM rfm_base
),

rfm_scored AS (
    -- Score each customer 1-5
    -- IMPORTANT:
    -- r_score DESC = score 5 goes to MOST RECENT (lowest days) = BEST
    -- m_score ASC  = score 5 goes to HIGHEST SPENDER = BEST
    SELECT *,
        NTILE(5) OVER (ORDER BY recency_days DESC) AS r_score,
        NTILE(5) OVER (ORDER BY monetary ASC)      AS m_score
    FROM rfm_recency
),

rfm_segmented AS (
    -- Classify each customer into a segment
    SELECT *,
        ROUND((r_score + m_score) / 2.0, 2) AS rm_avg,
        CASE
            WHEN r_score >= 4 AND m_score >= 4 THEN 'Champion'
            WHEN r_score >= 4 AND m_score BETWEEN 2 AND 3 THEN 'Promising'
            WHEN r_score >= 3 AND m_score >= 3 THEN 'Loyal Customer'
            WHEN r_score <= 2 AND m_score >= 4 THEN 'At Risk - High Value'
            WHEN r_score <= 2 AND m_score BETWEEN 2 AND 3 THEN 'At Risk'
            WHEN r_score = 1 AND m_score = 1   THEN 'Lost'
            ELSE 'Needs Attention'
        END AS segment
    FROM rfm_scored
)

-- FINAL OUTPUT: Business summary by segment
SELECT
    segment,
    COUNT(*)                                                    AS customer_count,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 2)         AS pct_of_customers,
    ROUND(AVG(monetary), 2)                                     AS avg_spend,
    ROUND(SUM(monetary), 2)                                     AS total_revenue,
    ROUND(SUM(monetary) * 100.0 / SUM(SUM(monetary)) OVER (), 2) AS pct_of_revenue,
    ROUND(AVG(recency_days), 0)                                 AS avg_days_since_purchase
FROM rfm_segmented
GROUP BY segment
ORDER BY total_revenue DESC;

-- ============================================
-- RESULTS OBTAINED:
-- Champion          | 15,396 | 16.49% | R$306.56 | R$4,719,724 | 30.61% | 140 days
-- At Risk-High Value| 14,529 | 15.56% | R$310.42 | R$4,510,105 | 29.25% | 442 days
-- Loyal Customer    | 11,147 | 11.94% | R$225.24 | R$2,510,714 | 16.28% | 269 days
-- At Risk           | 15,347 | 16.44% | R$89.06  | R$1,366,761 |  8.86% | 442 days
-- Promising         | 14,632 | 15.67% | R$89.92  | R$1,315,701 |  8.53% | 138 days
-- Needs Attention   | 18,408 | 19.72% | R$45.73  | R$841,829   |  5.46% | 235 days
-- Lost              |  3,899 |  4.18% | R$39.74  | R$154,936   |  1.00% | 524 days
-- ============================================
