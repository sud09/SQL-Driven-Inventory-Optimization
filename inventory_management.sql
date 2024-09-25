-- Create the schema for the TechElectro database
CREATE SCHEMA TechElectro;

-- ==============================
-- Data Exploration Queries
-- ==============================

-- Display all records from the external factors dataset
SELECT * FROM external_factors;

-- Display all records from the inventory data dataset
SELECT * FROM inventory_data;

-- Display all records from the product information dataset
SELECT * FROM product_information;

-- Display all records from the sales data dataset
SELECT * FROM sales_data;

-- ==============================
-- Understanding Data Structure
-- ==============================

-- Show the columns of the external factors table
SHOW COLUMNS FROM external_factors;

-- Describe the structure of the product information table
DESCRIBE product_information;

-- Describe the structure of the sales data table
DESC sales_data;

-- ==============================
-- Data Cleaning
-- ==============================

-- Change the data type of columns to the correct formats
-- Step 1: Add a new column for sales date in the external factors table
ALTER TABLE external_factors 
ADD COLUMN new_sales_date DATE; 

-- Disable safe updates mode to allow certain operations
SET SQL_SAFE_UPDATES = 0; 

-- Step 2: Update the new_sales_date with the converted Sales Date
UPDATE external_factors
SET new_sales_date = STR_TO_DATE(`Sales Date`, '%d/%m/%Y');

-- Step 3: Remove the old Sales Date column
ALTER TABLE external_factors
DROP COLUMN `Sales Date`;

-- Step 4: Rename the new_sales_date column to Sales Date
ALTER TABLE external_factors
CHANGE COLUMN new_sales_date `Sales Date` DATE;

-- Verify changes in the external_factors table
SELECT * FROM external_factors;

-- Adjusting data types of existing columns
ALTER TABLE external_factors
MODIFY COLUMN GDP DECIMAL(15, 2);

ALTER TABLE external_factors
MODIFY COLUMN `Inflation Rate` DECIMAL(5, 2);

ALTER TABLE external_factors
MODIFY COLUMN `Seasonal Factor` DECIMAL(5, 2);

-- ==============================
-- Product Information Table Modifications
-- ==============================

-- Step 1: Add a new column for promotions in the product information table
ALTER TABLE product_information
ADD COLUMN NewPromotions ENUM('yes', 'no');

-- Step 2: Update the new promotions column based on existing values
UPDATE product_information
SET NewPromotions = CASE
    WHEN Promotions = 'yes' THEN 'yes'
    WHEN Promotions = 'no' THEN 'no'
    ELSE NULL
END;

-- Step 3: Remove the old Promotions column
ALTER TABLE product_information
DROP COLUMN Promotions;

-- Step 4: Rename the new promotions column back to Promotions
ALTER TABLE product_information
CHANGE COLUMN NewPromotions Promotions ENUM('yes', 'no');

-- ==============================
-- Sales Data Table Modifications
-- ==============================

-- Step 1: Add a new column for sales date in the sales data table
ALTER TABLE sales_data
ADD COLUMN New_Sales_Date DATE;

-- Step 2: Update the new sales date with converted Sales Date
UPDATE sales_data
SET New_Sales_Date = STR_TO_DATE(`Sales Date`, '%d/%m/%Y');

-- Step 3: Remove the old Sales Date column and rename the new column
ALTER TABLE sales_data
DROP COLUMN `Sales Date`,
CHANGE COLUMN New_Sales_Date `Sales Date` DATE;

-- Verify changes in the sales_data table
SELECT * FROM sales_data;

-- ==============================
-- Missing Value Analysis
-- ==============================

-- Check for missing values in the external factors table
SELECT
    SUM(CASE WHEN `Sales Date` IS NULL THEN 1 ELSE 0 END) AS missing_sales_date,
    SUM(CASE WHEN GDP IS NULL THEN 1 ELSE 0 END) AS missing_gdp,
    SUM(CASE WHEN `Inflation Rate` IS NULL THEN 1 ELSE 0 END) AS missing_inflation_rate,
    SUM(CASE WHEN `Seasonal Factor` IS NULL THEN 1 ELSE 0 END) AS missing_seasonal_factor
FROM external_factors;

-- Check for missing values in the product information table
SELECT
    SUM(CASE WHEN `Product ID` IS NULL THEN 1 ELSE 0 END) AS missing_product_id,
    SUM(CASE WHEN `Product Category` IS NULL THEN 1 ELSE 0 END) AS missing_product_category,
    SUM(CASE WHEN Promotions IS NULL THEN 1 ELSE 0 END) AS missing_promotions
FROM product_information;

-- Check for missing values in the sales data table
SELECT
    SUM(CASE WHEN `Product ID` IS NULL THEN 1 ELSE 0 END) AS missing_product_id,
    SUM(CASE WHEN `Sales Date` IS NULL THEN 1 ELSE 0 END) AS missing_sales_date,
    SUM(CASE WHEN `Inventory Quantity` IS NULL THEN 1 ELSE 0 END) AS missing_inventory_quantity,
    SUM(CASE WHEN `Product Cost` IS NULL THEN 1 ELSE 0 END) AS missing_product_cost
FROM sales_data;

-- ==============================
-- Checking for Duplicates
-- ==============================

-- Check for duplicate sales dates in the external_factors table
SELECT `sales date`, COUNT(*) AS duplicate_count
FROM external_factors
GROUP BY `sales date`
HAVING COUNT(*) > 1;

-- Count the number of duplicate sales dates in the external_factors table
SELECT COUNT(*) AS duplicate_sales_date_count
FROM (
    SELECT `sales date`, COUNT(*) AS count
    FROM external_factors
    GROUP BY `sales date`
    HAVING count > 1
) AS duplicate;

-- Check for duplicate product IDs and categories in the product_information table
SELECT `Product ID`, `Product Category`, COUNT(*) AS duplicate_count
FROM product_information
GROUP BY `Product ID`, `Product Category`
HAVING COUNT(*) > 1;

-- Count the number of duplicate Product ID and Category combinations
SELECT COUNT(*) AS duplicate_product_info_count
FROM (
    SELECT `Product ID`, `Product Category`, COUNT(*) AS count
    FROM product_information
    GROUP BY `Product ID`, `Product Category`
    HAVING count > 1
) AS Duplicate;

-- Check for duplicate Product IDs and Sales Dates in the sales_data table
SELECT `Product ID`, `Sales Date`, COUNT(*) AS duplicate_count
FROM sales_data
GROUP BY `Product ID`, `Sales Date`
HAVING duplicate_count > 1;

-- ==============================
-- Deleting Duplicates
-- ==============================

-- Delete duplicates from the external_factors table
DELETE e1 
FROM external_factors e1
INNER JOIN (
    SELECT `Sales Date`, 
           ROW_NUMBER() OVER (PARTITION BY `Sales Date` ORDER BY `Sales Date`) AS rn 
    FROM external_factors
) e2 ON e1.`Sales Date` = e2.`Sales Date`
WHERE e2.rn > 1;

-- Delete duplicates from the product_information table
DELETE p1 
FROM product_information p1
INNER JOIN (
    SELECT `Product ID`, 
           ROW_NUMBER() OVER (PARTITION BY `Product ID` ORDER BY `Product ID`) AS pn 
    FROM product_information
) p2 ON p1.`Product ID` = p2.`Product ID`
WHERE p2.pn > 1;

-- ==============================
-- Data Integration
-- ==============================

-- Create a view combining sales data and product information
CREATE VIEW sales_product_data AS
SELECT
    s.`Product ID`,
    s.`Sales Date`,
    s.`Inventory Quantity`,
    s.`Product Cost`,
    p.`Product Category`,
    p.`Promotions`
FROM sales_data s
JOIN product_information p ON s.`Product ID` = p.`Product ID`;

-- Create a view integrating sales product data with external factors
CREATE VIEW Inventory_Data_ AS
SELECT
    sp.`Product ID`,
    sp.`Sales Date`,
    sp.`Inventory Quantity`,
    sp.`Product Cost`,
    sp.`Product Category`,
    sp.`Promotions`,
    e.`GDP`,
    e.`Inflation Rate`,
    e.`Seasonal Factor`
FROM sales_product_data sp
LEFT JOIN external_factors e ON sp.`Sales Date` = e.`Sales Date`;

-- ==============================
-- Descriptive Analysis
-- ==============================

-- Calculate average sales by product ID and category
SELECT `Product ID`, `Product Category`, 
       ROUND(AVG(`Inventory Quantity` * `Product Cost`)) AS Avg_Sales
FROM Inventory_Data_
GROUP BY `Product ID`, `Product Category` 
ORDER BY Avg_Sales DESC;

-- Calculate median inventory stocks by product ID
SELECT `Product ID`, AVG(`Inventory Quantity`) AS median_stock
FROM (
    SELECT `Product ID`, `Inventory Quantity`,
           ROW_NUMBER() OVER (PARTITION BY `Product ID` ORDER BY `Inventory Quantity`) AS row_num_asc,
           ROW_NUMBER() OVER (PARTITION BY `Product ID` ORDER BY `Inventory Quantity` DESC) AS row_num_desc
    FROM Inventory_Data_
) AS subquery
WHERE row_num_asc IN (row_num_desc, row_num_desc - 1, row_num_desc + 1)
GROUP BY `Product ID`;

-- Calculate total sales per product ID and category
SELECT `Product ID`, `Product Category`, 
       ROUND(SUM(`Inventory Quantity` * `Product Cost`)) AS Total_Sales
FROM Inventory_Data_
GROUP BY `Product ID`, `Product Category` 
ORDER BY Total_Sales DESC;

-- Identify high-demand products based on average sales
WITH HighDemandProducts AS (
    SELECT `Product ID`, AVG(`Inventory Quantity`) AS avg_sales
    FROM Inventory_Data_
    GROUP BY `Product ID`
    HAVING avg_sales > (
        SELECT AVG(`Inventory Quantity`) * 0.95 FROM sales_product_data
    )
)

-- Calculate stockout frequency for high-demand products
SELECT s.`Product ID`, COUNT(*) AS stockout_frequency
FROM Inventory_Data_ s
WHERE s.`Product ID` IN (SELECT `Product ID` FROM HighDemandProducts)
AND s.`Inventory Quantity` = 0
GROUP BY s.`Product ID`;

-- Analyze the influence of external factors on sales (GDP)
SELECT `Product ID`,
       AVG(CASE WHEN `GDP` > 0 THEN `Inventory Quantity` ELSE NULL END) AS avg_sales_positive_gdp,
       AVG(CASE WHEN `GDP` <= 0 THEN `Inventory Quantity` ELSE NULL END) AS avg_sales_non_positive_gdp
FROM Inventory_Data_
GROUP BY `Product ID`
HAVING avg_sales_positive_gdp IS NOT NULL;

-- Analyze the influence of inflation on sales
SELECT `Product ID`,
       AVG(CASE WHEN `Inflation Rate` > 0 THEN `Inventory Quantity` ELSE NULL END) AS avg_sales_positive_inflation,
       AVG(CASE WHEN `Inflation Rate` <= 0 THEN `Inventory Quantity` ELSE NULL END) AS avg_sales_non_positive_inflation
FROM Inventory_Data_
GROUP BY `Product ID`
HAVING avg_sales_positive_inflation IS NOT NULL;

-- ==============================
-- Optimizing Inventory
-- ==============================

-- Determine optimal reorder point for each product based on historical sales data and external factors.
-- Reorder Point = Lead Time Demand + Safety Stock
-- Lead Time Demand = Rolling Average Sales x Lead Time
-- Safety Stock = Z x Lead Time^-2 x Standard Deviation of Demand
-- Z = 1.645 (for 95% service level)
-- Assuming a constant lead time of 7 days for all products.

WITH InventoryCalculations AS (
    SELECT `Product ID`,
           AVG(rolling_avg_sales) AS avg_rolling_sales,
           AVG(rolling_variance) AS avg_rolling_variance
    FROM (
        SELECT `Product ID`,
               AVG(daily_sales) OVER (PARTITION BY `Product ID` ORDER BY `Sales Date` ROWS BETWEEN 6 PRECEDING AND CURRENT ROW) AS rolling_avg_sales,
               AVG(squared_diff) OVER (PARTITION BY `Product ID` ORDER BY `Sales Date` ROWS BETWEEN 5 PRECEDING AND CURRENT ROW) AS rolling_variance
        FROM (
            SELECT `Product ID`,
                   `Sales Date`,
                   `Inventory Quantity` * `Product Cost` AS daily_sales,
                   (`Inventory Quantity` * `Product Cost` - AVG(`Inventory Quantity` * `Product Cost`) OVER (PARTITION BY `Product ID` ORDER BY `Sales Date` ROWS BETWEEN 6 PRECEDING AND CURRENT ROW)) AS squared_diff
            FROM Inventory_Data_
        ) subquery
    ) subquery2
    GROUP BY `Product ID`
)

SELECT `Product ID`,
       avg_rolling_sales * 7 AS lead_time_demand,
       1.645 * SQRT(avg_rolling_variance * 7) AS safety_stock,
       (avg_rolling_sales * 7) + (1.645 * SQRT(avg_rolling_variance * 7)) AS reorder_point
FROM InventoryCalculations;

-- Create the inventory_optimization table
CREATE TABLE inventory_optimization (
    Product_ID INT,
    Reorder_Point DOUBLE
);

-- Step 2: Create a Stored Procedure to Recalculate Reorder Point
DELIMITER //

CREATE PROCEDURE RecalculateReorderPoint(productID INT)
BEGIN
    DECLARE avgRollingSales DOUBLE;
    DECLARE avgRollingVariance DOUBLE;
    DECLARE leadTimeDemand DOUBLE;
    DECLARE safetyStock DOUBLE;
    DECLARE reorderPoint DOUBLE;

    -- Calculating rolling averages and variances
    SELECT 
           AVG(rolling_avg_sales) AS avg_rolling_sales,
           AVG(rolling_variance) AS avg_rolling_variance
    INTO avgRollingSales, avgRollingVariance
    FROM (
        SELECT
               AVG(daily_sales) OVER (PARTITION BY `Product ID` ORDER BY `Sales Date` ROWS BETWEEN 6 PRECEDING AND CURRENT ROW) AS rolling_avg_sales,
               AVG(squared_diff) OVER (PARTITION BY `Product ID` ORDER BY `Sales Date` ROWS BETWEEN 5 PRECEDING AND CURRENT ROW) AS rolling_variance
        FROM (
            SELECT `Product ID`,
                   `Sales Date`,
                   `Inventory Quantity` * `Product Cost` AS daily_sales,
                   POWER(`Inventory Quantity` * `Product Cost` - 
                         AVG(`Inventory Quantity` * `Product Cost`) OVER (PARTITION BY `Product ID` ORDER BY `Sales Date` ROWS BETWEEN 6 PRECEDING AND CURRENT ROW), 2) AS squared_diff
            FROM Inventory_Data_
            WHERE `Product ID` = productID
        ) InnerDerived
    ) OuterDerived;

    -- Calculate lead time demand and safety stock
    SET leadTimeDemand = IFNULL(avgRollingSales, 0) * 7;
    SET safetyStock = IFNULL(1.645 * SQRT(IFNULL(avgRollingVariance, 0) * 7), 0);
    SET reorderPoint = leadTimeDemand + safetyStock;

    -- Insert or update reorder point in inventory_optimization table
    INSERT INTO inventory_optimization (Product_ID, Reorder_Point)
    VALUES (productID, reorderPoint)
    ON DUPLICATE KEY UPDATE Reorder_Point = reorderPoint;

END //

DELIMITER ;

-- Step 3: Make Inventory_Data a permanent table
CREATE TABLE Inventory_table AS SELECT * FROM Inventory_Data_;

-- Step 4: Create the Trigger
DELIMITER //

CREATE TRIGGER AfterInsertUnifiedTable
AFTER INSERT ON Inventory_table
FOR EACH ROW
BEGIN
    -- Call the stored procedure to recalculate reorder point
    CALL RecalculateReorderPoint(NEW.`Product ID`);
END //

DELIMITER ;

-- ==============================
-- Overstocking and Understocking
-- ==============================

WITH RollingSales AS (
    SELECT 
        `Product ID`,
        `Sales Date`,
        AVG(`Inventory Quantity` * `Product Cost`) OVER (PARTITION BY `Product ID` ORDER BY `Sales Date` ROWS BETWEEN 6 PRECEDING AND CURRENT ROW) AS rolling_avg_sales
    FROM Inventory_table
),
-- Calculate the number of days a product was sold out
StockoutDays AS (
    SELECT 
        `Product ID`,
        COUNT(*) AS stockout_days
    FROM Inventory_table
    WHERE `Inventory Quantity` = 0
    GROUP BY `Product ID`
)

-- Data integration 
CREATE VIEW sales_product_data AS
SELECT
    s.`Product ID`,
    s.`Sales Date`,
    s.`Inventory Quantity`,
    s.`Product Cost`,
    p.`Product Category`,
    p.`Promotions`
FROM sales_data s
JOIN product_information p ON s.`Product ID` = p.`Product ID`;

CREATE VIEW Inventory_Data_ AS
SELECT
    sp.`Product ID`,
    sp.`Sales Date`,
    sp.`Inventory Quantity`,
    sp.`Product Cost`,
    sp.`Product Category`,
    sp.Promotions,
    e.GDP,
    e.`Inflation Rate`,
    e.`Seasonal Factor`
FROM sales_product_data sp
LEFT JOIN external_factors e ON sp.`Sales Date` = e.`Sales Date`;

-- Descriptive Analysis 
-- Average sales
SELECT 
    `Product ID`, 
    `Product Category`, 
    ROUND(AVG(`Inventory Quantity` * `Product Cost`)) AS Avg_Sales
FROM Inventory_Data_
GROUP BY `Product ID`, `Product Category` 
ORDER BY Avg_Sales DESC;

-- Median inventory stocks
SELECT `Product ID`, AVG(`Inventory Quantity`) AS median_stock
FROM (
    SELECT `Product ID`, `Inventory Quantity`,
           ROW_NUMBER() OVER (PARTITION BY `Product ID` ORDER BY `Inventory Quantity`) AS row_num_asc,
           ROW_NUMBER() OVER (PARTITION BY `Product ID` ORDER BY `Inventory Quantity` DESC) AS row_num_desc
    FROM Inventory_Data_
) AS subquery
WHERE row_num_asc IN (row_num_desc, row_num_desc - 1, row_num_desc + 1)
GROUP BY `Product ID`;

-- Performance metrics (total sales per product)
SELECT 
    `Product ID`, 
    `Product Category`, 
    ROUND(SUM(`Inventory Quantity` * `Product Cost`)) AS Total_Sales
FROM Inventory_Data_
GROUP BY `Product ID`, `Product Category` 
ORDER BY Total_Sales DESC;

-- High demand products based on average sales 
WITH HighDemandProducts AS (
    SELECT `Product ID`, AVG(`Inventory Quantity`) AS avg_sales
    FROM Inventory_Data_
    GROUP BY `Product ID`
    HAVING avg_sales > (SELECT AVG(`Inventory Quantity`) * 0.95 FROM sales_product_data)
)

-- Calculate stockout frequency for high demand products 
SELECT 
    s.`Product ID`,
    COUNT(*) AS stockout_frequency
FROM Inventory_Data_ s
WHERE s.`Product ID` IN (SELECT `Product ID` FROM HighDemandProducts)
AND s.`Inventory Quantity` = 0
GROUP BY s.`Product ID`;

-- Influence of external factors (GDP)
SELECT 
    `Product ID`,
    AVG(CASE WHEN GDP > 0 THEN `Inventory Quantity` ELSE NULL END) AS avg_sales_positive_gdp,
    AVG(CASE WHEN GDP <= 0 THEN `Inventory Quantity` ELSE NULL END) AS avg_sales_non_positive_gdp
FROM Inventory_Data_
GROUP BY `Product ID`
HAVING avg_sales_positive_gdp IS NOT NULL;

-- Influence of inflation
SELECT 
    `Product ID`,
    AVG(CASE WHEN `Inflation Rate` > 0 THEN `Inventory Quantity` ELSE NULL END) AS avg_sales_positive_inflation,
    AVG(CASE WHEN `Inflation Rate` <= 0 THEN `Inventory Quantity` ELSE NULL END) AS avg_sales_non_positive_inflation
FROM Inventory_Data_
GROUP BY `Product ID`
HAVING avg_sales_positive_inflation IS NOT NULL;

-- Optimizing inventory
-- Reorder Point = Lead Time Demand + Safety Stock
WITH InventoryCalculations AS (
    SELECT 
        `Product ID`,
        AVG(rolling_avg_sales) AS avg_rolling_sales,
        AVG(rolling_variance) AS avg_rolling_variance
    FROM (
        SELECT 
            `Product ID`,
            AVG(daily_sales) OVER (PARTITION BY `Product ID` ORDER BY `Sales Date` ROWS BETWEEN 6 PRECEDING AND CURRENT ROW) AS rolling_avg_sales,
            AVG(squared_diff) OVER (PARTITION BY `Product ID` ORDER BY `Sales Date` ROWS BETWEEN 5 PRECEDING AND CURRENT ROW) AS rolling_variance
        FROM (
            SELECT 
                `Product ID`,
                `Sales Date`,
                `Inventory Quantity` * `Product Cost` AS daily_sales,
                (`Inventory Quantity` * `Product Cost` - AVG(`Inventory Quantity` * `Product Cost`) OVER (PARTITION BY `Product ID` ORDER BY `Sales Date` ROWS BETWEEN 6 PRECEDING AND CURRENT ROW)) AS squared_diff
            FROM Inventory_Data_
        ) subquery
    ) subquery2
    GROUP BY `Product ID`	
)

SELECT 
    `Product ID`,
    avg_rolling_sales * 7 AS lead_time_demand,
    1.645 * SQRT(avg_rolling_variance * 7) AS safety_stock,
    (avg_rolling_sales * 7) + (1.645 * SQRT(avg_rolling_variance * 7)) AS reorder_point
FROM InventoryCalculations;

-- Create the inventory_optimization table
CREATE TABLE inventory_optimization (
    Product_ID INT,
    Reorder_Point DOUBLE
);

-- Step 2: Create the Stored Procedure to Recalculate Reorder Point
DELIMITER //

CREATE PROCEDURE RecalculateReorderPoint(productID INT)
BEGIN
    DECLARE avgRollingSales DOUBLE;
    DECLARE avgRollingVariance DOUBLE;
    DECLARE leadTimeDemand DOUBLE;
    DECLARE safetyStock DOUBLE;
    DECLARE reorderPoint DOUBLE;

    -- Calculating rolling averages and variances
    SELECT 
        AVG(rolling_avg_sales) AS avg_rolling_sales,
        AVG(rolling_variance) AS avg_rolling_variance
    INTO avgRollingSales, avgRollingVariance
    FROM (
        SELECT
            AVG(daily_sales) OVER (PARTITION BY `Product ID` ORDER BY `Sales Date` ROWS BETWEEN 6 PRECEDING AND CURRENT ROW) AS rolling_avg_sales,
            AVG(squared_diff) OVER (PARTITION BY `Product ID` ORDER BY `Sales Date` ROWS BETWEEN 5 PRECEDING AND CURRENT ROW) AS rolling_variance
        FROM (
            SELECT 
                `Product ID`,
                `Sales Date`,
                `Inventory Quantity` * `Product Cost` AS daily_sales,
                POWER(`Inventory Quantity` * `Product Cost` - 
                    AVG(`Inventory Quantity` * `Product Cost`) OVER (PARTITION BY `Product ID` ORDER BY `Sales Date` ROWS BETWEEN 6 PRECEDING AND CURRENT ROW), 2) AS squared_diff
            FROM Inventory_Data_
            WHERE `Product ID` = productID
        ) InnerDerived
    ) OuterDerived;

    -- Calculate lead time demand and safety stock
    SET leadTimeDemand = IFNULL(avgRollingSales, 0) * 7;
    SET safetyStock = IFNULL(1.645 * SQRT(IFNULL(avgRollingVariance, 0) * 7), 0);
    SET reorderPoint = leadTimeDemand + safetyStock;

    -- Insert or update reorder point in inventory_optimization table
    INSERT INTO inventory_optimization (Product_ID, Reorder_Point)
    VALUES (productID, reorderPoint)
    ON DUPLICATE KEY UPDATE Reorder_Point = reorderPoint;

END //

DELIMITER ;

-- Step 3: Make inventory_data a permanent table
CREATE TABLE Inventory_table AS SELECT * FROM Inventory_Data_;

-- Step 4: Create the Trigger
DELIMITER //

CREATE TRIGGER AfterInsertUnifiedTable
AFTER INSERT ON Inventory_table
FOR EACH ROW
BEGIN
    -- Call the stored procedure to recalculate reorder point
    CALL RecalculateReorderPoint(NEW.`Product ID`);
END //

DELIMITER ;

-- Overstocking and understocking
WITH RollingSales AS (
    SELECT 
        `Product ID`,
        `Sales Date`,
        AVG(`Inventory Quantity` * `Product Cost`) OVER (PARTITION BY `Product ID` ORDER BY `Sales Date` ROWS BETWEEN 6 PRECEDING AND CURRENT ROW) AS rolling_avg_sales
    FROM Inventory_table
),

StockoutDays AS (
    SELECT 
        `Product ID`,
        COUNT(*) AS stockout_days
    FROM Inventory_table
    WHERE `Inventory Quantity` = 0
    GROUP BY `Product ID`
)

-- Main query combining the CTEs with the base table
SELECT 
    f.`Product ID`,
    AVG(f.`Inventory Quantity` * f.`Product Cost`) AS avg_inventory_value,
    AVG(rs.rolling_avg_sales) AS avg_rolling_sales,
    COALESCE(sd.stockout_days, 0) AS stockout_days
FROM inventory_table f
JOIN RollingSales rs 
    ON f.`Product ID` = rs.`Product ID` 
    AND f.`Sales Date` = rs.`Sales Date`
LEFT JOIN StockoutDays sd 
    ON f.`Product ID` = sd.`Product ID`
GROUP BY f.`Product ID`, sd.stockout_days;

-- Monitor inventory levels
DELIMITER //

CREATE PROCEDURE MonitorInventoryLevels()
BEGIN
    SELECT `Product ID`, AVG(`Inventory Quantity`) AS AvgInventory
    FROM Inventory_table
    GROUP BY `Product ID`
    ORDER BY AvgInventory DESC;
END //

DELIMITER ;

-- Monitor Sales Trends
DELIMITER //

CREATE PROCEDURE MonitorSalesTrends()
BEGIN
    SELECT `Product ID`, `Sales Date`,
           AVG(`Inventory Quantity` * `Product Cost`) OVER (PARTITION BY `Product ID` ORDER BY `Sales Date` ROWS BETWEEN 6 PRECEDING AND CURRENT ROW) AS Rolling_Avg_Sales
    FROM inventory_table
    ORDER BY `Product ID`, `Sales Date`;
END //

DELIMITER ;

-- Monitor Stockout frequencies
DELIMITER //

CREATE PROCEDURE MonitorStockouts()
BEGIN
    SELECT `Product ID`, COUNT(*) AS StockoutDays
    FROM Inventory_table
    WHERE `Inventory Quantity` = 0
    GROUP BY `Product ID`
    ORDER BY StockoutDays DESC;
END //

DELIMITER ;

-- FEEDBACK LOOP
-- Feedback Loop Establishment:

-- Feedback Portal: Develop an online platform for stakeholders to easily submit feedback on inventory performance and challenges.
-- Review Meetings: Organize periodic sessions to discuss inventory system performance and gather direct insights.
-- System Monitoring: Use established SQL procedures to track system metrics, with deviations from expectations flagged for review.

-- Refinement Based on Feedback:

-- Feedback Analysis: Regularly compile and scrutinize feedback to identify recurring themes or pressing issues.
-- Action Implementation: Prioritize and act on the feedback to adjust reorder points, safety stock levels, or overall processes.
-- Change Communication: Inform stakeholders about changes, underscoring the value of their feedback and ensuring transparency.
