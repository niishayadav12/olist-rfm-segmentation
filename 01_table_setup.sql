-- ============================================
-- PROJECT: Olist RFM Customer Segmentation
-- FILE: 01 - Table Setup
-- TOOL: MySQL / DBeaver
-- ============================================

CREATE DATABASE olist_rfm_project;
USE olist_rfm_project;

-- TABLE 1: Customers
CREATE TABLE customers (
    customer_id VARCHAR(50) PRIMARY KEY,
    customer_unique_id VARCHAR(50),
    customer_zip_code_prefix VARCHAR(10),
    customer_city VARCHAR(100),
    customer_state VARCHAR(5)
);

-- TABLE 2: Orders
CREATE TABLE orders (
    order_id VARCHAR(50) PRIMARY KEY,
    customer_id VARCHAR(50),
    order_status VARCHAR(30),
    order_purchase_timestamp DATETIME,
    order_approved_at DATETIME,
    order_delivered_carrier_date DATETIME,
    order_delivered_customer_date DATETIME,
    order_estimated_delivery_date DATETIME
);

-- TABLE 3: Order Items
CREATE TABLE order_items (
    order_id VARCHAR(50),
    order_item_id INT,
    product_id VARCHAR(50),
    seller_id VARCHAR(50),
    shipping_limit_date DATETIME,
    price DECIMAL(10,2),
    freight_value DECIMAL(10,2)
);

-- TABLE 4: Order Reviews
CREATE TABLE order_reviews (
    review_id VARCHAR(50),
    order_id VARCHAR(50),
    review_score INT,
    review_creation_date DATETIME,
    review_answer_timestamp DATETIME
);

-- NOTE: Data was loaded using DBeaver Import Tool
-- Right click table > Import Data > Select CSV > Map Columns > Start
