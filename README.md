# Retail-Sales-Using-SQL

**Author:**  Saheed Olayinka Adebiyi
**Date:** 2025-12-08
---
## Project Background
This analysis was conducted to identify the root causes and focus on improving operations, marketing, and customer satisfaction by analyzing sales and customer data. To determine peak hours to optimize staff schedules, evaluate the loyalty program to see if it drives value, target marketing more effectively based on purchasing patterns, and assess high-value customer satisfaction to enhance their experience. The insights from this analysis will help reduce costs, increase revenue, and improve overall customer loyalty. This project analyzes available data and produces an interactive Excel dashboard with actionable recommendations.
---
## Project Objective
**The following objectives focus on improving operations, marketing, and customer satisfaction by analyzing sales and customer data**
1.  Identify the busiest times in each location and make sure staff are scheduled appropriately to reduce overtime costs and shorten customer wait times.
2.  Analyze whether members spend more or provide additional benefits compared to regular customers to decide if the program is worth continuing
3.  Study who buys each product category so that marketing efforts are focused on the right audience and the budget is used effectively.
4.  Examine whether high-spending customers are satisfied and take steps to improve their experience to maintain their loyalty.

---

##Select * from retail_sales;

##-- Rename the transaction id and quantity correctly
ALTER TABLE retail_sales RENAME COLUMN ï»¿transactions_id TO `transaction_id`;
ALTER TABLE retail_sales RENAME COLUMN quantiy TO `quantity`;

Select * from retail_sales;

##-- Rename some cells in gender column wrongly inputted
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

##-- Rename some wrong cells names in category column
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

##-- updating the not age cell with the mean of the age
SET @mean_age = (SELECT ROUND(AVG(age)) FROM retail_sales WHERE age > 0);

UPDATE retail_sales
SET age = @mean_age
WHERE age = 0;

##-- Calculate Total Cost of Goods
SELECT transaction_id, quantity, cogs, quantity * cogs AS total_cost
FROM retail_sales;

ALTER TABLE retail_sales
ADD COLUMN total_cost DECIMAL(10);

UPDATE retail_sales
SET total_cost = Round(quantity * cogs)
WHERE quantity IS NOT NULL
  AND cogs IS NOT NULL;
  
Select * from retail_sales;

##-- Calculating the overall profit and profit margin
SELECT  SUM(total_sale) AS total_revenue, SUM(total_cost) AS total_costs,
ROUND(SUM(total_sale - total_cost)) AS total_profit,
ROUND((SUM(total_sale - total_cost) / SUM(total_sale)) * 100, 2) AS profit_margin_percentage
FROM retail_sales;


##-- Determine the category of product that generates more profit
SELECT category, SUM(total_sale - total_cost) AS total_profit, COUNT(*) AS transactions
FROM retail_sales
GROUP BY category
ORDER BY total_profit DESC;

Select * from retail_sales;

##-- Determine the demographic
##-- Revenue, total profit, transaction, revenue by gender
SELECT gender, COUNT(*) AS total_transactions,
ROUND(SUM(total_sale)) AS total_revenue,
ROUND(AVG(total_sale)) AS avg_transaction_value,
ROUND(SUM(total_sale - total_cost)) AS total_profit
FROM retail_sales
GROUP BY gender
ORDER BY total_revenue DESC;

##-- Revenue, total profit, transaction, revenue by age group
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

##-- Categories Product preference by age group
SELECT 
    CASE 
        WHEN age < 25 THEN '18-24'
        WHEN age BETWEEN 25 AND 34 THEN '25-34'
        WHEN age BETWEEN 35 AND 44 THEN '35-44'
        WHEN age BETWEEN 45 AND 54 THEN '45-54'
        WHEN age >= 55 THEN '55+'
    END AS age_group,
    category,
    COUNT(*) AS purchases,
    ROUND(SUM(total_sale)) AS revenue
FROM retail_sales
WHERE age IS NOT NULL
GROUP BY age_group, category
ORDER BY age_group, revenue DESC;

##-- Category preference by gender
SELECT gender, category, COUNT(*) AS purchases,
ROUND(SUM(total_sale)) AS revenue
FROM retail_sales
GROUP BY gender, category
ORDER BY gender, revenue DESC;

Select * from retail_sales;

##-- Updating the date column to the correct data type
UPDATE retail_sales
SET sale_date = STR_TO_DATE(sale_date, '%m/%d/%Y');

-- Updating the time column to the correct data type
UPDATE retail_sales
SET sale_time = STR_TO_DATE(sale_time, '%H:%i:%s');

##-- Sales trend by year
SELECT 
    EXTRACT(YEAR FROM sale_date) AS year,
    COUNT(*) AS transactions,
    ROUND(SUM(total_sale)) AS revenue,
    ROUND(SUM(total_sale - total_cost)) AS profit,
    ROUND((SUM(total_sale - total_cost) / SUM(total_sale)) * 100, 2) AS profit_margin_percentage
FROM retail_sales
GROUP BY year
ORDER BY year;

##-- Sales trend by month
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

##-- Sales by  day
SELECT 
    DAYNAME(sale_date) AS day_name,
    DAYOFWEEK(sale_date) AS day_number,
    COUNT(*) AS transactions, 
    ROUND(SUM(total_sale)) AS revenue, 
    ROUND(SUM(total_sale - total_cost), 2) AS profit 
FROM retail_sales 
GROUP BY day_name, day_number
ORDER BY day_number;

##  --
SELECT 
    category,
    Round(AVG(quantity)) AS avg_quantity,
    MIN(quantity) AS min_quantity,
    MAX(quantity) AS max_quantity,
    COUNT(*) AS transactions
FROM retail_sales
GROUP BY category
ORDER BY avg_quantity DESC;

-- Overview of the data (KPI)
SELECT 
    COUNT(DISTINCT customer_id) AS total_customers,
    COUNT(*) AS total_transactions,
    ROUND(SUM(total_sale)) AS total_revenue,
    ROUND(SUM(total_cost)) AS total_costs,
    ROUND(SUM(total_sale - total_cost)) AS total_profit,
    ROUND((SUM(total_sale - total_cost) / SUM(total_sale)) * 100, 2) AS overall_profit_margin,
    ROUND(AVG(total_sale)) AS avg_transaction_value,
    ROUND(AVG(quantity)) AS avg_items_per_transaction
FROM retail_sales;

## Datasets
- **supermarket_sales_2025.xlsx** — The data consists of 21,000 rows and 16 columns, which is clean without duplicates and empty spaces, except for creating new conditional columns
Dataset main columns include: Invoice ID, Branch, City, Customer Type, Gender, Payment, Product Line, Unit Price, Quantity, Tax 5%, Total, COGS, Gross,  Margin %, Date, Time, Rating

---
## Key Findings (example)
1.  Customer Satisfaction Crisis: Despite strong sales of $666.8 million, only 32% of customers are highly satisfied, while 34% are dissatisfied, indicating a significant experience gap      that  threatens retention
2.  Membership Program Success: Member customers generate $335.3 million in revenue compared to $331.2 million from normal customers, demonstrating the loyalty program's strong value in      driving sales
3.  Digital Payment Dominance: E-wallet ($222.7 Million) and credit cards ($220.9 Million) account for 67% of transactions, with cash at $223.1 million, showing successful digital            adoption
4.  Austin Leads Performance: Austin consistently outperforms Chicago and New York across categories and time periods, suggesting replicable best practices in operations and customer         service.
5.  Seasonal Revenue Vulnerability: Revenue drops significantly in Q1 (especially February) before peaking in November, exposing the business to seasonal demand fluctuations 
---
## Recommendations
1. Prioritize Customer Satisfaction Recovery: Conduct feedback surveys, implement mystery shopping, and create rapid response teams to reduce dissatisfied customers from 34% to below
2. Replicate Austin's Success Model: Document Austin's best practices and deploy their top performers to train Chicago and New York teams to achieve performance parity across all            locations
3. Expand Membership and Address Seasonality: Introduce tiered membership benefits, launch specific promotions, and develop targeted campaigns to increase the member ratio to 65% while      stabilizing seasonal revenue
4. Optimize Digital Payments and Category Mix: Enhance e-wallet infrastructure with backup systems, invest in top-performing categories like Sports & Travel, and restructure                 underperforming segments like Electronic Accessories 

---
## Tools & Techniques
- Data cleaning and transformation in SQL 

---
## Project Files (included)
- `retail_sales.sql` — interactive dashboard file 
- `Retail Sales Performance & Profitability Investigation.pdf` — boardroom slide deck 
- `README.md` — this documentation
---

---
## Contact
Adebiyi Saheed Olayinka 
Email: olayinkaadebiyi49@gmail.com
LinkedIn: www.linkedin.com/in/olayinkaadebiyi
