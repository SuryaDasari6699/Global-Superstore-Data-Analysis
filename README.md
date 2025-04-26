# 🧾 Global Superstore Data Analysis

## 📌 About
A complete data analysis and visualization project using **SQL**, **Excel**, and **Power BI** to uncover sales trends, shipping inefficiencies, and customer behavior in a global retail dataset.


## 🧠 Overview
This project analyzes a global superstore’s sales data to generate actionable insights. It focuses on trends in product performance, customer segmentation, operational inefficiencies, and the financial impact of discounts and delivery delays.

The approach follows a structured ETL and BI development pipeline—transforming raw transactional data into a clean, analytical star schema and delivering visual dashboards in Power BI.


## 🎯 Business Objectives

1. Detect underperforming product categories generating low or negative profit  
2. Identify regions with high shipping costs leading to net losses  
3. Analyze customer segment profitability and average order values  
4. Optimize discount strategies based on margin analysis  
5. Quantify loss due to delayed high-priority shipments


## 🧩 Analytical Approach

**1. Data Cleaning & Modeling**
- Cleaned and formatted dates, profit columns, and discounts  
- Built a **star schema** with fact and dimension tables  
- Validated joins using SQL foreign keys  

**2. KPI & Metric Development**
- Defined DAX measures: Profit Margin, Net Profit, AOV  
- Created calculated columns: Discount Tiers, Shipping Delays  

**3. Power BI Visualization**
- Built 5 interactive dashboard pages for key business areas  
- Used slicers, bookmarks, and drill-throughs for dynamic exploration  


## 🗃️ Dataset Summary

- 51,290+ transaction records  
- 3 customer segments: Consumer, Corporate, Home Office  
- 3 product categories: Furniture, Technology, Office Supplies  
- Covers 7 global markets and multiple countries  


## 🧩 Data Structures (Star Schema)

All tables are joined using foreign key constraints `Customer_ID` and `Product_ID` to build a clean, optimized star schema.

### 🔸 Fact Table: `FactSales`

| Column Name        | Data Type     | Description                                 |
|--------------------|---------------|---------------------------------------------|
| Row ID             | INT           | Unique transaction ID                       |
| Order ID           | TEXT          | Order reference                             |
| Order Date         | DATE          | Date of order                               |
| Ship Date          | DATE          | Date order was shipped                      |
| Customer ID        | TEXT          | Foreign key to DimCustomer                  |
| Product ID         | TEXT          | Foreign key to DimProduct                   |
| Ship Mode          | TEXT          | Shipping method                             |
| Order Priority     | TEXT          | Urgency of order                            |
| Sales              | FLOAT         | Sales revenue                               |
| Quantity           | INT           | Items sold                                  |
| Discount           | FLOAT         | Discount applied (0–1)                      |
| Profit             | FLOAT         | Net gain from transaction                   |
| COGS               | FLOAT         | Cost of goods sold                          |
| Shipping Cost      | FLOAT         | Shipping expense                            |

### 🔹 Dimension Table: `Customer Table`

| Column Name     | Data Type | Description                          |
|-----------------|-----------|--------------------------------------|
| Customer ID     | TEXT      | Primary key                          |
| Customer Name   | TEXT      | Full customer name                   |
| Segment         | TEXT      | Customer type (Consumer, etc.)       |
| City/State      | TEXT      | Location data                        |
| Country         | TEXT      | Country                              |
| Market          | TEXT      | Global market (e.g., EMEA, APAC)     |
| Region          | TEXT      | Regional grouping                    |

### 🔹 Dimension Table: `Product Table`

| Column Name     | Data Type | Description                          |
|-----------------|-----------|--------------------------------------|
| Product ID      | TEXT      | Primary key                          |
| Product Name    | TEXT      | Product name                         |
| Category        | TEXT      | High-level classification            |
| Sub-Category    | TEXT      | Finer product grouping               |
| Price Per Unit  | FLOAT     | Unit pricing                         |


## ❓ Business Questions to Answer


### 📋 Generic Questions
- How many distinct cities, states, and countries are present in the dataset?
- Which market and region do each customer belong to?
- What is the distribution of customer segments across regions?
- Which shipping modes are most frequently used?

---

### 🛍️ Product Analysis
- How many distinct product categories and sub-categories are there?
- Which product category generates the highest total sales?
- Which sub-category has the highest profit margin?
- Which product sub-categories consistently generate negative profits?
- Which product category received the highest discount percentages?
- How does the average profit vary across product categories and sub-categories?
- Which products have the highest sales quantity but low profitability?
- What is the contribution of each product category to the overall revenue?

---

### 💰 Sales and Discount Analysis
- What is the trend of total sales and profit over the years?
- In which months do sales typically peak across regions?
- How does discount percentage affect profit margins across different products?
- Which discount range (0–10%, 11–30%, 31–50%) generates the highest overall profit?
- What is the relationship between discount levels and number of orders?
- Which product categories remain profitable despite heavy discounting?

---

### 🚚 Shipping and Operations Analysis
- Which shipping modes incur the highest shipping costs?
- Are there regions where shipping costs exceed the profits earned?
- Which regions have the lowest net profit after shipping costs are deducted?
- How does shipping cost vary by product category?
- What is the average shipping duration across different markets and regions?

---

### 👤 Customer Segmentation Analysis
- Which customer segment (Consumer, Corporate, Home Office) generates the most revenue?
- Which segment delivers the highest profit margin?
- What is the average order value across different customer segments?
- Which customer segment is most sensitive to discounts?
- Which region has the highest concentration of Home Office customers?
- How does customer buying behavior differ across markets (e.g., APAC, EMEA)?

---

### 🕒 Priority and Delivery Analysis
- How many high-priority orders are delayed beyond expected shipping times?
- What is the total profit lost due to late shipments of high-priority orders?
- Which regions experience the most delayed high-priority shipments?
- How does order priority correlate with shipping cost and delivery time?


## 📊 Dashboards Created

1. **Underperforming Product Categories**
   - Sales vs. Profit by Category/Sub-Category  
   - Visuals: TreeMap, Clustered Bar, Profit Margin Table  

2. **Shipping Cost Inefficiencies**
   - Identify regions with shipping losses  
   - Visuals: Bar Chart, Heatmap Table, Scatter Plot  

3. **Customer Segment Profitability**
   - Segment-wise profit margin, AOV  
   - Visuals: KPI Cards, Pie Chart, Donut Chart  

## 📁 Files Included

| File Name                          | Description                             |
|-----------------------------------|-----------------------------------------|
| `Fact Table.csv`                  | Core sales transaction data             |
| `Customer Table.csv`              | Customer dimension                      |
| `Products Table.csv`              | Product catalog and pricing             |
| `Super Store Sales.sql`           | SQL table creation & schema script      |
| `Superstore Sales Data Project.xlsx` | Planning, metrics, data dictionary     |
| `SuperStore Sales.pbix`           | Final Power BI dashboard file           |

## 📌 Key Insights

- Sub-categories like **Storage** and **Binders** had high sales but negative margins  
- **Africa** and **South Asia** incurred net shipping losses  
- **Home Office** customers had highest profit margins despite fewer orders  
- Discounts above **30%** significantly harmed profitability  
- Delayed high-priority shipments caused measurable loss in certain regions  

## ▶️ How to Run the Project

1. Run `Super Store Sales.sql` in your SQL environment to create and populate schema  
2. Load the `.csv` files into Power BI or SQL  
3. Open `SuperStore Sales.pbix` and refresh connections  
4. Use slicers, filters, and visuals to explore insights  

## 🙋 Author

**Name**: Surya Dasari  
**Tools Used**: SQL, Power BI, Excel  
**Location**: Canada  
**GitHub**: [SuryaDasari6699](https://github.com/SuryaDasari6699)

---
