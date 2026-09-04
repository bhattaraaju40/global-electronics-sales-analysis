# Global Electronics Sales Analysis

An end-to-end data analysis project exploring sales, profitability, product performance, customer behavior, and sales channels for a global electronics retailer.

The project includes data cleaning with Python, SQL analysis in PostgreSQL, and an interactive Tableau dashboard designed to turn raw sales data into actionable business insights.

## 📊 Live Dashboard

[View the Interactive Tableau Dashboard](https://public.tableau.com/views/GlobalElectronicsSalesDashboard_17884941485620/GlobalElectronicsSalesDashboard)

## Business Problem & Objectives

The goal of this project is to analyze Global Electronics sales data and identify the main drivers of revenue, profit, customer behavior, and product performance.

The analysis focuses on answering key business questions such as:

- How much revenue and profit did the company generate?
- How did sales and profit change over time?
- Which categories, brands, and products performed best and worst?
- Which countries and stores generated the most revenue and profit?
- How did online sales compare with physical store sales?
- Which customer groups generated the most revenue?
- What was the average order value, and which customers placed the largest orders?
- How long did online orders take to deliver?
- Which high-revenue products had relatively low profitability?
- What business recommendations can be made from the analysis?

## Tools & Technologies

- **Python (Pandas)** — Cleaned, transformed, and validated the raw data before analysis
- **PostgreSQL / SQL** — Built the database, joined the tables, calculated key business metrics, and answered the main business questions
- **Tableau** — Built an interactive dashboard to show sales trends, product performance, profitability, and sales channel performance

## Data Preparation & Cleaning

Before starting the analysis, the raw datasets were reviewed and cleaned in Python using Pandas.

The main cleaning steps included:

- Standardized column names for easier analysis
- Converted date fields to datetime format
- Cleaned price and cost columns by removing currency symbols and commas
- Converted numeric fields to the correct data types
- Checked for missing values and duplicates
- Reviewed missing delivery dates and confirmed they were expected for physical store purchases
- Validated the cleaned datasets before loading them into PostgreSQL

## SQL Analysis

After cleaning the data, the datasets were loaded into PostgreSQL for analysis.

The SQL analysis covered:

- Overall business performance, including revenue, cost, profit, quantity sold, total orders, profit margin, and average order value
- Yearly and monthly sales trends, including revenue and profit growth over time
- Category, subcategory, brand, and product performance
- Country and store performance to understand where sales were strongest
- Online vs physical store performance store performance across revenue, profit, orders, average order value, and profit margin
- Top customers, customer groups, and largest individual orders
- Customer performance by gender and age group
- Average order value across different customer segments
- Online delivery performance, including average, minimum, maximum, and median delivery time
- High-revenue products with below-average profit margins
- Business recommendations based on the findings
