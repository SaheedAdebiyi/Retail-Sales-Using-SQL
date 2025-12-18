Create Database Retail_sales;
Use retail_sales;

Select * from retail_sales;

-- Rename the transaction id and quantity correctly
ALTER TABLE retail_sales RENAME COLUMN ï»¿transactions_id TO `transaction_id`;
ALTER TABLE retail_sales RENAME COLUMN quantiy TO `quantity`;

Select * from retail_sales;

-- Rename some cells in gender column wrongly inputted
UPDATE retail_sales
SET gender = CASE
    WHEN TRIM(UPPER(gender)) = 'F' THEN 'Female'
    WHEN TRIM(UPPER(gender)) = 'M' THEN 'Male'
    WHEN TRIM(UPPER(gender)) = 'Ma' THEN 'Male'
    WHEN TRIM(UPPER(gender)) = 'Mal' THEN 'Male'
    WHEN TRIM(UPPER(gender)) = 'Fe' THEN 'Female'
    WHEN TRIM(UPPER(gender)) = 'Fema' THEN 'Female'
    ELSE gender
END;
   
Select * from retail_sales;

-- Rename some wrong cells names in category column
UPDATE retail_sales
SET category = CASE
    WHEN TRIM(UPPER(category)) = 'Bea' THEN 'Beauty'
    WHEN TRIM(UPPER(category)) = 'Beau' THEN 'Beauty'
    WHEN TRIM(UPPER(category)) = 'Beaut' THEN 'Beauty'
    ELSE category
END;

UPDATE retail_sales
SET category = CASE
    WHEN TRIM(UPPER(category)) = 'Clo' THEN 'Beauty'
    WHEN TRIM(UPPER(category)) = 'Clot' THEN 'Beauty'
    WHEN TRIM(UPPER(category)) = 'Cloth' THEN 'Beauty'
	WHEN TRIM(UPPER(category)) = 'Clothin' THEN 'Beauty'
    ELSE category
END;

UPDATE retail_sales
SET category = CASE
    WHEN TRIM(UPPER(category)) = 'Electr' THEN 'Electronics'
    WHEN TRIM(UPPER(category)) = 'Electron' THEN 'Electronics'
        ELSE category
END;
Select * from retail_sales;

-- updating the not age cell with the mean of the age
SET @mean_age = (SELECT ROUND(AVG(age)) FROM retail_sales WHERE age > 0);

UPDATE retail_sales
SET age = @mean_age
WHERE age = 0;

-- Calculate Total Cost of goods
SELECT transaction_id, quantity, cogs, quantity * cogs AS total_cost
FROM retail_sales;

ALTER TABLE retail_sales
ADD COLUMN total_cost DECIMAL(10);

UPDATE retail_sales
SET total_cost = Round(quantity * cogs)
WHERE quantity IS NOT NULL
  AND cogs IS NOT NULL;
  
Select * from retail_sales;

-- Calculating the overal profit and profit margin
SELECT  SUM(total_sale) AS total_revenue, SUM(total_cost) AS total_costs,
ROUND(SUM(total_sale - total_cost)) AS total_profit,
ROUND((SUM(total_sale - total_cost) / SUM(total_sale)) * 100, 2) AS profit_margin_percentage
FROM retail_sales;

-- Determine the category of product that generates more profit
SELECT category, SUM(total_sale - total_cost) AS total_profit,     
COUNT(*) AS transactions,     
ROUND(SUM(total_sale)) AS total_revenue,     
ROUND((SUM(total_sale - total_cost) / SUM(total_sale)) * 100, 2) AS profit_margin     
FROM retail_sales 
GROUP BY category 
ORDER BY total_profit DESC;

-- Top most valuable customers 
SELECT customer_id, gender, age,     
COUNT(*) AS total_purchases,     
ROUND(SUM(total_sale)) AS total_revenue,     
ROUND(SUM(total_sale - total_cost)) AS total_profit,     
ROUND(AVG(total_sale)) AS avg_transaction_value   
FROM retail_sales 
GROUP BY customer_id, gender, age 
ORDER BY total_revenue DESC LIMIT 10;

-- Determine the demographic
-- -- Revenue, total profit, transaction, revenue by gender
SELECT gender, COUNT(*) AS total_transactions,
ROUND(SUM(total_sale)) AS total_revenue,
ROUND(AVG(total_sale)) AS avg_transaction_value,
ROUND(SUM(total_sale - total_cost)) AS total_profit
FROM retail_sales
GROUP BY gender
ORDER BY total_revenue DESC;

-- Revenue, total profit, transaction, revenue by age group
SELECT 
    CASE 
        WHEN age < 25 THEN '18-24'
        WHEN age BETWEEN 25 AND 34 THEN '25-34'
        WHEN age BETWEEN 35 AND 44 THEN '35-44'
        WHEN age BETWEEN 45 AND 54 THEN '45-54'
        WHEN age >= 55 THEN '55+'
        ELSE 'Unknown'
    END AS age_group, COUNT(*) AS transactions, ROUND(SUM(total_sale)) AS revenue,
    ROUND(AVG(total_sale)) AS avg_transaction_value,
    ROUND(SUM(total_sale - total_cost)) AS total_profit FROM retail_sales
WHERE age IS NOT NULL
GROUP BY age_group
ORDER BY revenue DESC;

-- Categories Product preference by age group
SELECT CASE 
        WHEN age < 25 THEN '18-24'
        WHEN age BETWEEN 25 AND 34 THEN '25-34'
        WHEN age BETWEEN 35 AND 44 THEN '35-44'
        WHEN age BETWEEN 45 AND 54 THEN '45-54'
        WHEN age >= 55 THEN '55+'
    END AS age_group, category, COUNT(*) AS purchases, ROUND(SUM(total_sale)) AS revenue 
    FROM retail_sales WHERE age IS NOT NULL GROUP BY age_group, category ORDER BY age_group, revenue DESC;

-- Category preference by gender
SELECT gender, category, COUNT(*) AS purchases,
ROUND(SUM(total_sale)) AS revenue
FROM retail_sales
GROUP BY gender, category
ORDER BY gender, revenue DESC;

-- Updating the date column to the correct data type
UPDATE retail_sales
SET sale_date = STR_TO_DATE(sale_date, '%m/%d/%Y');

-- Updating the time column to the correct data type
UPDATE retail_sales
SET sale_time = STR_TO_DATE(sale_time, '%H:%i:%s');

-- Sales trend by year
SELECT 
    EXTRACT(YEAR FROM sale_date) AS year,
    COUNT(*) AS transactions,
    ROUND(SUM(total_sale)) AS revenue,
    ROUND(SUM(total_sale - total_cost)) AS profit,
    ROUND((SUM(total_sale - total_cost) / SUM(total_sale)) * 100, 2) AS profit_margin_percentage
FROM retail_sales
GROUP BY year
ORDER BY year;

-- Sales trend by month
SELECT 
    EXTRACT(YEAR FROM sale_date) AS year,
    EXTRACT(MONTH FROM sale_date) AS month,
	DATE_FORMAT(sale_date, '%b') AS month_name,
    COUNT(*) AS transactions,
    ROUND(SUM(total_sale)) AS revenue,
    ROUND(SUM(total_sale - total_cost)) AS profit
FROM retail_sales
GROUP BY year, month, month_name
ORDER BY year, month;

-- Sales Trend by day
SELECT 
    DAYNAME(sale_date) AS day_name,
    DAYOFWEEK(sale_date) AS day_number,
    COUNT(*) AS transactions, 
    ROUND(SUM(total_sale)) AS revenue, 
    ROUND(SUM(total_sale - total_cost), 2) AS profit 
FROM retail_sales 
GROUP BY day_name, day_number
ORDER BY day_number;

-- Quantity of product by category
SELECT category,
ROUND(AVG(quantity)) AS avg_quantity,
MIN(quantity) AS min_quantity,
MAX(quantity) AS max_quantity,
COUNT(*) AS transactions
FROM retail_sales
GROUP BY category
ORDER BY avg_quantity DESC;

-- Overview of the data (KPI)
SELECT COUNT(DISTINCT customer_id) AS total_customers,
COUNT(*) AS total_transactions,
ROUND(SUM(total_sale)) AS total_revenue,
ROUND(SUM(total_cost)) AS total_costs,
ROUND(SUM(total_sale - total_cost)) AS total_profit,
ROUND((SUM(total_sale - total_cost) / SUM(total_sale)) * 100, 2) AS overall_profit_margin,
ROUND(AVG(total_sale)) AS avg_transaction_value,
ROUND(AVG(quantity)) AS avg_items_per_transaction
FROM retail_sales;



