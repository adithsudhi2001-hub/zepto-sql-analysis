-- =================================================================
-- 1. DDL: TABLE CREATION
-- =================================================================
DROP TABLE IF EXISTS zepto;

CREATE TABLE zepto (
    sku_id SERIAL PRIMARY KEY,
    category VARCHAR(120),
    name VARCHAR(150) NOT NULL,
    mrp NUMERIC(10,2),
    discountPercent NUMERIC(5,2),
    availableQuantity INTEGER,
    discountedSellingPrice NUMERIC(10,2),
    weightInGms INTEGER,
    outOfStock BOOLEAN,
    quantity INTEGER
);



-- =================================================================
-- 2. DATA EXPLORATION & AUDIT
-- =================================================================

-- Total record count
SELECT COUNT(*) AS total_rows FROM zepto;

-- Sample preview
SELECT * FROM zepto LIMIT 10;

-- Check for missing / null values across columns
SELECT * FROM zepto
WHERE name IS NULL
   OR category IS NULL
   OR mrp IS NULL
   OR discountPercent IS NULL
   OR discountedSellingPrice IS NULL
   OR weightInGms IS NULL
   OR availableQuantity IS NULL
   OR outOfStock IS NULL
   OR quantity IS NULL;

-- Distinct product categories
SELECT DISTINCT category 
FROM zepto 
ORDER BY category;

-- In-stock vs Out-of-stock breakdown
SELECT outOfStock, COUNT(sku_id) AS sku_count
FROM zepto
GROUP BY outOfStock;

-- Identify products listed under multiple SKUs/categories
SELECT name, COUNT(sku_id) AS sku_count
FROM zepto
GROUP BY name
HAVING COUNT(sku_id) > 1
ORDER BY sku_count DESC;

-- Pre-cleaning anomaly check (Price > MRP or non-positive price)
SELECT 
    sku_id, name, category, mrp, discountedSellingPrice, discountPercent,
    ROUND(((mrp - discountedSellingPrice)::numeric / NULLIF(mrp, 0)) * 100, 2) AS calculated_discount
FROM zepto
WHERE discountedSellingPrice > mrp 
   OR mrp <= 0 
   OR discountedSellingPrice <= 0;


-- =================================================================
-- 3. DATA CLEANING
-- =================================================================

-- Delete invalid records with zero or null prices
DELETE FROM zepto 
WHERE mrp = 0 
   OR mrp IS NULL 
   OR discountedSellingPrice = 0;

-- Convert paise into rupees (safeguarded: only divides values > 100)
UPDATE zepto 
SET mrp = mrp / 100.0,
    discountedSellingPrice = discountedSellingPrice / 100.0
WHERE mrp > 100;

-- Verify conversion
SELECT name, mrp, discountedSellingPrice FROM zepto LIMIT 5;


-- =================================================================
-- 4. BUSINESS ANALYSIS & INSIGHTS
-- =================================================================

-- Top 10 best value products based on discount percentage
SELECT DISTINCT
    name,
    category,
    mrp,
    discountedSellingPrice,
    discountPercent
FROM zepto
WHERE outOfStock = FALSE
ORDER BY discountPercent DESC
LIMIT 10;

-- Top 10 best value products based on price per gram (weight-to-price ratio)
SELECT 
    name,
    category,
    weightInGms,
    discountedSellingPrice,
    ROUND((discountedSellingPrice::numeric / NULLIF(weightInGms, 0)), 4) AS price_per_gram
FROM zepto
WHERE weightInGms > 0 
  AND weightInGms IS NOT NULL
ORDER BY price_per_gram ASC
LIMIT 10;

-- Total product / SKU count per category
SELECT 
    category,
    COUNT(sku_id) AS total_products
FROM zepto
GROUP BY category
ORDER BY total_products DESC;

-- Average discount percentage by category
SELECT 
    category,
    ROUND(AVG(discountPercent)::numeric, 2) AS avg_discount_percent
FROM zepto
GROUP BY category
ORDER BY avg_discount_percent DESC;

-- Inventory valuation (Total active stock value per category)
SELECT 
    category,
    SUM(availableQuantity) AS total_units_available,
    ROUND(SUM(discountedSellingPrice * availableQuantity)::numeric, 2) AS total_inventory_value_inr
FROM zepto
WHERE outOfStock = FALSE
GROUP BY category
ORDER BY total_inventory_value_inr DESC;

-- Stockout count and stockout rate percentage by category
SELECT 
    category,
    COUNT(sku_id) AS total_skus,
    SUM(CASE WHEN outOfStock = TRUE THEN 1 ELSE 0 END) AS out_of_stock_count,
    ROUND((SUM(CASE WHEN outOfStock = TRUE THEN 1 ELSE 0 END)::numeric * 100.0 / COUNT(sku_id)), 2) AS stockout_rate_pct
FROM zepto
GROUP BY category
ORDER BY stockout_rate_pct DESC;

-- Revenue exposure / Opportunity loss from out-of-stock items
SELECT 
    category,
    COUNT(sku_id) AS out_of_stock_skus,
    ROUND(AVG(mrp)::numeric, 2) AS avg_mrp,
    ROUND(SUM(mrp)::numeric, 2) AS total_mrp_exposure
FROM zepto
WHERE outOfStock = TRUE
GROUP BY category
ORDER BY total_mrp_exposure DESC;

-- Top 3 highest discounted products in each category (Window Function)
WITH RankedProducts AS (
    SELECT 
        category,
        name,
        mrp,
        discountedSellingPrice,
        discountPercent,
        DENSE_RANK() OVER (
            PARTITION BY category 
            ORDER BY discountPercent DESC
        ) AS rank_in_category
    FROM zepto
    WHERE outOfStock = FALSE 
      AND mrp > 0
)
SELECT *
FROM RankedProducts
WHERE rank_in_category <= 3;
