-- Create Database Named "SuperStoreSales" if not exist in PostgreSQL
CREATE DATABASE "SuperStoreSales"
    WITH
    OWNER = postgres
    ENCODING = 'UTF8'
    LOCALE_PROVIDER = 'libc'
    CONNECTION LIMIT = -1
    IS_TEMPLATE = False;

-- Create Tables for Data
CREATE TABLE Customer_Data (
    Customer_ID VARCHAR(20) PRIMARY KEY,
    Customer_Name VARCHAR(100),
    Segment VARCHAR(20),
    City VARCHAR(50),
    State VARCHAR(50),
    Country VARCHAR(50),
    Market VARCHAR(50),
    Region VARCHAR(50)
);

CREATE TABLE Products_Data (
    Product_ID VARCHAR(20) PRIMARY KEY,
    Product_Name VARCHAR(200),
    Category VARCHAR(50),
    Sub_Category VARCHAR(50),
    Price_Per_Unit DECIMAL(10, 2)
);

CREATE TABLE FactSales_Data (
    Row_ID INT PRIMARY KEY,
    Order_ID VARCHAR(20),
    Order_Date DATE,
    Ship_Date DATE,
    Customer_ID VARCHAR(20),
    Product_ID VARCHAR(20),
    Ship_Mode VARCHAR(50),
    Order_Priority VARCHAR(20),
    Sales DECIMAL(10, 2),
    Quantity INT,
    Discount DECIMAL(10, 2),
    Profit DECIMAL(10, 2),
    COGS DECIMAL(10, 2),
    Shipping_Cost DECIMAL(10, 2),
    FOREIGN KEY (Customer_ID) REFERENCES Customer_Data(Customer_ID),
    FOREIGN KEY (Product_ID) REFERENCES Products_Data(Product_ID)
	ON UPDATE CASCADE ON DELETE CASCADE
);

--After importing bulk, Check data for each table
SELECT * FROM Customer_Data;
SELECT * FROM Factsales_Data;
SELECT * FROM Products_Data;

--PROBLEM 1: Underperforming Product Categories
--Total Sales and Profit by Sub Category
SELECT 
    p.Sub_Category,
    SUM(Sales) AS Total_Sales,
    SUM(Profit) AS Total_Profit
FROM FactSales_Data f
JOIN Products_Data p ON f.Product_ID = p.Product_ID
GROUP BY p.Sub_Category;

-- Sub-categories with profit margin under 5%
SELECT 
    p.Sub_Category,
    ROUND(SUM(f.Profit) / NULLIF(SUM(f.Sales), 0), 2) AS Profit_Margin
FROM FactSales_Data f
JOIN Products_Data p ON f.Product_ID = p.Product_ID
GROUP BY p.Sub_Category
HAVING ROUND(SUM(f.Profit) / NULLIF(SUM(f.Sales), 0), 2) < 0.05;

-- Worst 3 Sub-categories with high sales but low margins
WITH Subcategory_Margins AS (
    SELECT 
        p.Sub_Category,
        SUM(f.Sales) AS Total_Sales,
        SUM(f.Profit) AS Total_Profit,
        ROUND(SUM(f.Profit) / NULLIF(SUM(f.Sales), 0), 2) AS Profit_Margin
    FROM FactSales_Data f
    JOIN Products_Data p ON f.Product_ID = p.Product_ID
    GROUP BY p.Sub_Category
)
SELECT *
FROM Subcategory_Margins
WHERE Profit_Margin < 1
ORDER BY Total_Sales DESC
LIMIT 3;

-- PROBLEM 2: Shipping Cost Inefficiencies by Region
-- Average shipping cost by region
SELECT 
    c.Region,
    ROUND(AVG(f.Shipping_Cost), 2) AS Avg_Shipping_Cost
FROM FactSales_Data f
JOIN Customer_Data c ON f.Customer_ID = c.Customer_ID
GROUP BY c.Region;

-- Regions with negative net profit
SELECT 
    c.Region,
    SUM(f.Profit) AS Profit,
    SUM(f.Shipping_Cost) AS Shipping_Cost,
    SUM(f.Profit - f.Shipping_Cost) AS Net_Profit
FROM FactSales_Data f
JOIN Customer_Data c ON f.Customer_ID = c.Customer_ID
GROUP BY c.Region
HAVING SUM(f.Profit - f.Shipping_Cost) < 0;

-- Top 3 cities with worst shipping efficiency (cost per unit)
SELECT 
    c.City,
    ROUND(SUM(f.Shipping_Cost)/NULLIF(SUM(f.Quantity), 0), 2) AS Cost_Per_Unit,
    SUM(f.Shipping_Cost) AS Total_Shipping
FROM FactSales_Data f
JOIN Customer_Data c ON f.Customer_ID = c.Customer_ID
GROUP BY c.City
ORDER BY Cost_Per_Unit DESC
LIMIT 3;


-- PROBLEM 3: Customer Segment Profitability
-- Total sales and profit by segment
SELECT 
    Segment,
    SUM(Sales) AS Total_Sales,
    SUM(Profit) AS Total_Profit
FROM FactSales_Data f
JOIN Customer_Data c ON f.Customer_ID = c.Customer_ID
GROUP BY Segment;

-- Avg order value and profit margin by segment
SELECT 
    c.Segment,
    ROUND(SUM(f.Sales) / NULLIF(SUM(f.Quantity), 0), 2) AS Avg_Order_Value,
    ROUND(SUM(f.Profit) / NULLIF(SUM(f.Sales), 0), 2) AS Profit_Margin
FROM FactSales_Data f
JOIN Customer_Data c ON f.Customer_ID = c.Customer_ID
GROUP BY c.Segment;

-- Segment contribution to overall profit (%)
WITH Segment_Profit AS (
    SELECT 
        c.Segment,
        SUM(f.Profit) AS SegmentProfit
    FROM FactSales_Data f
    JOIN Customer_Data c ON f.Customer_ID = c.Customer_ID
    GROUP BY c.Segment
),
Total_Profit AS (
    SELECT SUM(Profit) AS TotalProfit FROM FactSales_Data
)
SELECT 
    s.Segment,
    s.SegmentProfit,
    ROUND((s.SegmentProfit / t.TotalProfit) * 100, 2) AS Contribution_Percent
FROM Segment_Profit s, Total_Profit t;


--PROBLEM 4: Discount Strategy Optimization
-- Profit by Discount bracket
SELECT 
  Discount,
  SUM(Profit) AS Total_Profit,
  COUNT(*) AS Order_Count
FROM FactSales_Data
GROUP BY Discount
ORDER BY Discount;

-- Discount tier impact
SELECT 
  CASE 
    WHEN Discount <= 0.1 THEN 'Low'
    WHEN Discount <= 0.3 THEN 'Medium'
    ELSE 'High'
  END AS Discount_Tier,
  ROUND(SUM(Profit)/NULLIF(SUM(Sales), 0), 2) AS Profit_Margin,
  COUNT(*) AS Orders
FROM FactSales_Data
GROUP BY Discount_Tier;

-- Products with high discount and low profitability
WITH Discounted_Products AS (
  SELECT 
    Product_ID,
    ROUND(AVG(Discount), 2) AS Avg_Discount,
    SUM(Profit) AS Total_Profit,
    SUM(Sales) AS Total_Sales
  FROM FactSales_Data
  GROUP BY Product_ID
)
SELECT 
  p.Product_Name,
  d.Avg_Discount,
  ROUND(d.Total_Profit / NULLIF(d.Total_Sales, 0), 2) AS Profit_Margin
FROM Discounted_Products d
JOIN Products_Data p ON d.Product_ID = p.Product_ID
WHERE d.Avg_Discount > 0.3 AND d.Total_Profit < 100;

-- PROBLEM 5: Loss from Delayed High-Priority Orders
-- Shipping delay for high priority orders
SELECT 
    Order_ID,
    (Ship_Date - Order_Date) AS Shipping_Days,
    Profit
FROM FactSales_Data
WHERE Order_Priority = 'High' 
	AND (Ship_Date - Order_Date) = 5;

-- Total lost profit on delayed high-priority orders
SELECT 
    SUM(Profit) AS Lost_Profit
FROM FactSales_Data
WHERE Order_Priority = 'High'
  AND (Ship_Date - Order_Date) > 2;

-- Regional impact of delayed shipping
WITH Delayed_Orders AS (
    SELECT 
        Customer_ID,
        Profit,
        (Ship_Date - Order_Date) AS Delay_Days
    FROM FactSales_Data
    WHERE Order_Priority = 'High'
      AND (Ship_Date - Order_Date) > 2
)
SELECT 
    c.Region,
    COUNT(*) AS Delayed_Orders,
    SUM(d.Profit) AS Lost_Profit
FROM Delayed_Orders d
JOIN Customer_Data c ON d.Customer_ID = c.Customer_ID
GROUP BY c.Region;

----- Different Types of Analysis on Data -----

-- 1. Descriptive Analysis (Summarize trends and patterns in historical data) --
-- Total Revenue and Profit by Year
SELECT 
    EXTRACT(YEAR FROM Order_Date) AS Year,
    SUM(Sales) AS Total_Sales,
    SUM(Profit) AS Total_Profit
FROM FactSales_Data
GROUP BY Year
ORDER BY Year;

-- Average Order Size by Segment
SELECT 
    c.Segment,
    ROUND(SUM(f.Sales) / COUNT(DISTINCT f.Order_ID), 2) AS Avg_Order_Value
FROM FactSales_Data f
JOIN Customer_Data c ON f.Customer_ID = c.Customer_ID
GROUP BY c.Segment;

-- 2. Diagnostic Analysis (Identify the root cause behind trends or performance) --
-- High Sales but Low Profit Products
SELECT 
    p.Product_Name,
    SUM(f.Sales) AS Total_Sales,
    SUM(f.Profit) AS Total_Profit
FROM FactSales_Data f
JOIN Products_Data p ON f.Product_ID = p.Product_ID
GROUP BY p.Product_Name
HAVING SUM(f.Sales) > 500 AND SUM(f.Profit) < 50;

-- Orders with High Discount but Low Profit
SELECT 
    Order_ID,
    Sales,
    Discount,
    Profit
FROM FactSales_Data
WHERE Discount > 0.3 AND Profit < 0;

-- 3. Profitability & Margin Analysis
-- Profit Margin by Product Category
SELECT 
    p.Category,
    ROUND(SUM(f.Profit)/NULLIF(SUM(f.Sales), 0), 2) AS Profit_Margin
FROM FactSales_Data f
JOIN Products_Data p ON f.Product_ID = p.Product_ID
GROUP BY p.Category;

-- Most Profitable 5 Cities
SELECT 
    c.City,
    SUM(f.Profit) AS Total_Profit
FROM FactSales_Data f
JOIN Customer_Data c ON f.Customer_ID = c.Customer_ID
GROUP BY c.City
ORDER BY Total_Profit DESC
LIMIT 5;

-- 4. Operational / Logistics Analysis
-- Avg Shipping Days by Ship Mode
SELECT 
    Ship_Mode,
    ROUND(AVG(Ship_Date - Order_Date), 1) AS Avg_Shipping_Days
FROM FactSales_Data
GROUP BY Ship_Mode;

-- Orders with Longest Delays
SELECT 
    Order_ID,
    (Ship_Date - Order_Date) AS Shipping_Days
FROM FactSales_Data
ORDER BY Shipping_Days DESC
LIMIT 10;

-- 5. Customer Behavior Analysis
-- Top 5 Most Frequent Customers
SELECT 
    Customer_ID,
    COUNT(DISTINCT Order_ID) AS Order_Count
FROM FactSales_Data
GROUP BY Customer_ID
ORDER BY Order_Count DESC
LIMIT 5;

-- Region with Most Customers
SELECT 
    Region,
    COUNT(DISTINCT Customer_ID) AS Customer_Count
FROM Customer_Data
GROUP BY Region
ORDER BY Customer_Count DESC;

-- 6. Risk & Loss Analysis
-- Loss-Making Orders (Profit < 0)
SELECT 
    Order_ID,
    Sales,
    Profit,
    Discount,
    Shipping_Cost
FROM FactSales_Data
WHERE Profit < 0
ORDER BY Profit ASC;

-- Region-wise Total Loss
SELECT 
    c.Region,
    SUM(CASE WHEN f.Profit < 0 THEN f.Profit ELSE 0 END) AS Total_Loss
FROM FactSales_Data f
JOIN Customer_Data c ON f.Customer_ID = c.Customer_ID
GROUP BY c.Region;

-- 7. Strategic Decision-Making Support
-- Should We Continue Selling a Product?
SELECT 
    p.Product_Name,
    COUNT(*) AS Orders,
    SUM(f.Sales) AS Revenue,
    SUM(f.Profit) AS Profit
FROM FactSales_Data f
JOIN Products_Data p ON f.Product_ID = p.Product_ID
GROUP BY p.Product_Name
HAVING SUM(f.Sales) > 200 AND SUM(f.Profit) < 0;

-- High Revenue, Low Margin Categories
SELECT 
    p.Category,
    SUM(f.Sales) AS Total_Sales,
    ROUND(SUM(f.Profit) / NULLIF(SUM(f.Sales), 0), 2) AS Profit_Margin
FROM FactSales_Data f
JOIN Products_Data p ON f.Product_ID = p.Product_ID
GROUP BY p.Category
HAVING SUM(f.Sales) > 5000 AND ROUND(SUM(f.Profit) / NULLIF(SUM(f.Sales), 0), 2) < 0.05;

-- 8. Inventory Support Query
-- Total Quantity Sold by Sub-category
SELECT 
    p.Sub_Category,
    SUM(f.Quantity) AS Total_Units_Sold
FROM FactSales_Data f
JOIN Products_Data p ON f.Product_ID = p.Product_ID
GROUP BY p.Sub_Category
ORDER BY Total_Units_Sold DESC;
