-- Retail Sales Analytics Project 
-- Tools Used   : MySQL

-- DATABASE CREATION
CREATE DATABASE retail_sales_analysis;
USE retail_sales_analysis;

-- TABLE RENAMING 
RENAME TABLE sales_transactions TO sales;

-- -- COLUMN STANDARDIZATION 
ALTER TABLE sales
CHANGE COLUMN `Transaction ID` Transaction_ID BIGINT,
CHANGE COLUMN `Customer ID` Customer_ID VARCHAR(50),
CHANGE COLUMN `Product Category` Product_Category VARCHAR(100),
CHANGE COLUMN `Price per Unit` Price_per_Unit BIGINT,
CHANGE COLUMN `Total Amount` Total_Amount BIGINT;

--               BUSINESS KPI ANALYSIS

--  Total Revenue Generated
SELECT 
    SUM(total_amount) AS Total_Revenue
FROM
    sales;
 
--  Highest Revenue Generating Product Category
SELECT 
    product_category, SUM(total_amount) AS total_revenue
FROM
    sales
GROUP BY product_category
ORDER BY total_revenue DESC
LIMIT 1;

-- Lowest Sales Category
SELECT 
    product_category, SUM(total_amount) AS total_sales
FROM
    sales
GROUP BY product_category
ORDER BY total_sales
LIMIT 1;

-- Highest Quantity Sold Category
SELECT 
    product_category, SUM(quantity) AS total
FROM
    sales
GROUP BY product_category
ORDER BY total DESC
LIMIT 1;

-- Monthly Sales Trend
SELECT 
    month,
    SUM(total_amount) AS monthly_sales
FROM sales
GROUP BY month
ORDER BY 
FIELD(month,
'January','February','March','April','May','June',
'July','August','September','October','November','December');

-- Highest Sales Generating Month
SELECT 
    month, SUM(total_amount) AS total_sales
FROM
    sales
GROUP BY month
ORDER BY total_sales DESC
LIMIT 1;

-- Highest Revenue Quarter
SELECT 
    quarter, SUM(total_amount) AS total_revenue
FROM
    sales
GROUP BY quarter
ORDER BY total_revenue DESC
LIMIT 1;

-- Running Monthly Revenue Trend
SELECT 
    month,
    monthly_sales,
    SUM(monthly_sales) OVER(
        ORDER BY 
        FIELD(month,
        'January','February','March','April','May','June',
        'July','August','September','October','November','December')
    ) AS running_total
FROM (
    SELECT 
        month,
        SUM(total_amount) AS monthly_sales
    FROM sales
    GROUP BY month
) t;

--                 Customer Analytics

-- Highest Spending Customer
SELECT 
    customer_id, SUM(total_amount) AS total_spending
FROM
    sales
GROUP BY customer_id
ORDER BY total_spending DESC
LIMIT 1;

-- Top 10 Customers by Revenue
SELECT 
    customer_id, SUM(total_amount) AS total_revenue
FROM
    sales
GROUP BY customer_id
ORDER BY total_revenue DESC
LIMIT 10;

 -- Repeat Customers
SELECT 
    customer_id, COUNT(*) AS purchase
FROM
    sales
GROUP BY customer_id
HAVING COUNT(*) > 1
ORDER BY purchase DESC;

--  Customer Segmentation Analysis 
SELECT 
    Customer_ID,
    SUM(Total_Amount) AS Total_Spending,
    CASE
        WHEN SUM(Total_Amount) >= 5000 THEN 'High Value Customer'
        WHEN SUM(Total_Amount) >= 2000 THEN 'Medium Value Customer'
        ELSE 'Low Value Customer'
    END AS Customer_Segment
FROM sales
GROUP BY Customer_ID
ORDER BY Total_Spending DESC;

--                    Sales & Order Analysis
-- Average Order Value
SELECT 
    ROUND(AVG(total_amount), 2) AS avg_order_value
FROM
    sales;  
    
-- Highest Revenue Transaction
SELECT 
    Transaction_ID,
    Total_Amount AS Highest_Revenue
FROM sales
ORDER BY Highest_Revenue DESC
LIMIT 1;

-- Weekend vs Weekday Sales
SELECT 
    CASE
        WHEN DAYNAME(date) IN ('Saturday','Sunday')  
        THEN 'Weekend'
        ELSE 'Weekday'
    END AS day_type,
    SUM(total_amount) AS total_sales,
    COUNT(transaction_id) AS total_orders,
    ROUND(AVG(total_amount), 2) AS avg_order_value
FROM
    sales
GROUP BY day_type;

--                Demographic Analysis

-- Highest Sales by Age Group
SELECT 
    age_group, SUM(total_amount) AS highest_revenue
FROM
    sales
GROUP BY age_group
ORDER BY highest_revenue DESC
LIMIT 1;

-- Gender-Based Revenue Analysis
SELECT 
    Gender,
    SUM(Total_Amount) AS Total_Revenue
FROM sales
GROUP BY Gender
ORDER BY Total_Revenue DESC;

--                 Product & Category Analysis

-- Product Category Revenue Contribution Percentage
SELECT 
    Product_Category,
    SUM(Total_Amount) AS Category_Sales,
    ROUND(
        (SUM(Total_Amount) * 100.0) / 
        (SELECT SUM(Total_Amount) FROM sales),
        2
    ) AS Contribution_Percentage
FROM sales
GROUP BY Product_Category
ORDER BY Contribution_Percentage DESC;

-- Rank Categories by Sales
SELECT 
    product_category,
    SUM(total_amount) AS total_sales,
    RANK() OVER (
        ORDER BY SUM(total_amount) DESC
    ) AS sales_rank
FROM sales
GROUP BY product_category;

--               Profitability Analysis

-- Product Category Profit Analysis
SELECT 
    Product_Category,
    SUM(Profit_Estimate) AS Total_Profit
FROM sales
GROUP BY Product_Category
ORDER BY Total_Profit DESC;

-- Overall Business Profit
SELECT 
    SUM(Profit_Estimate) AS Total_Business_Profit
FROM sales;

--                      End of Project 