-- =========================================
-- Global Electronics Retail Analysis
-- Business Analysis Queries
-- =========================================



-- =========================================================
-- 1. Overall business performance
-- =========================================================

WITH overall_perfomence AS (
SELECT
	SUM(s.quantity * p.unit_price_usd) AS total_revenue,
	SUM(s.quantity * p.unit_cost_usd) AS total_cost,
	SUM(s.quantity * (p.unit_price_usd - p.unit_cost_usd )) AS total_profit,
	SUM(s.quantity) AS total_quantity_sold,
	COUNT(distinct s.order_number) AS total_order
		
FROM sales s
JOIN products p
ON p.product_key = s.product_key
)

SELECT *,
	ROUND(((total_profit/total_revenue)*100),2) AS profit_margin_percent,
	ROUND((total_revenue/total_order),2) AS average_order_value
FROM overall_perfomence


-- =========================================================
-- 2a. Yearly Revenue and Profit Trend
-- =========================================================

with yearly_performance AS (
SELECT
	EXTRACT(YEAR FROM s.order_date) AS sales_year,
	ROUND(SUM(s.quantity * p.unit_price_usd),2) AS total_revenue,
	ROUND(SUM(s.quantity * (p.unit_price_usd-p.unit_cost_usd)),2) AS total_profit,
	SUM(s.quantity) AS total_quantity_sold,
	COUNT(DISTINCT s.order_number) AS total_orders
FROM sales s
JOIN products p
ON s.product_key = p.product_key

GROUP BY EXTRACT(YEAR FROM s.order_date)
order by sales_year
),

yearly_comparison AS (
SELECT *,
	LAG(total_revenue) OVER (ORDER BY sales_year) AS previous_year_revenue,
	LAG(total_profit) OVER(ORDER BY sales_year) AS previous_year_profit
FROM yearly_performance
)

SELECT 
	sales_year,
	total_revenue,
	total_profit,
	total_quantity_sold,
	total_orders,

	ROUND(((total_revenue - previous_year_revenue)
	/NULLIF(previous_year_revenue,0)) * 100, 2) AS revenue_growth_percent,

	ROUND(((total_profit - previous_year_profit)
	/NULLIF(previous_year_profit, 0)) * 100, 2) AS profit_growth_percent
FROM yearly_comparison;


-- =========================================================
-- 2b. Monthly sales trend
-- =========================================================

with monthly_performance AS (
SELECT 
	DATE_TRUNC('month', s.order_date) AS sales_month,
	SUM(s.quantity * p.unit_price_usd) AS total_revenue,
	SUM(s.quantity * (p.unit_price_usd - p.unit_cost_usd)) AS total_profit,
	SUM(s.quantity) AS total_quantity_sold,
	COUNT(DISTINCT s.order_number) AS total_orders
FROM sales s
JOIN products p
ON s.product_key = p.product_key
GROUP BY DATE_TRUNC('month', s.order_date)
ORDER BY sales_month
),

monthly_comparison AS (
SELECT *,
	LAG(total_revenue) OVER (ORDER BY sales_month) AS previous_month_revenue,
	LAG(total_profit) OVER (ORDER BY sales_month) AS previous_month_profit
FROM monthly_performance
)

SELECT
	sales_month,
	total_revenue,
	total_profit,
	total_quantity_sold,
	total_orders,
	ROUND(((total_revenue - previous_month_revenue)
	/NULLIF(previous_month_revenue, 0)) * 100, 2) AS revenue_growth_percent,

	ROUND(((total_profit - previous_month_profit )
	/NULLIF(previous_month_profit, 0)) * 100, 2) AS revenue_profit_percent

FROM monthly_comparison


-- =========================================================
-- 3a. Revenue and profit by category
-- =========================================================

WITH category_trend AS (
SELECT 
	category,
	SUM(s.quantity * p.unit_price_usd) AS total_revenue,
	SUM(s.quantity * (p.unit_price_usd - p.unit_cost_usd)) AS total_profit,
	SUM(s.quantity) AS total_quantity_sold	
FROM sales s
JOIN products p
ON s.product_key = p.product_key
GROUP BY category
)

SELECT *,
	ROUND((total_profit/NULLIF(total_revenue,0)) * 100, 2) AS profit_margin_percent
FROM category_trend
ORDER BY total_revenue DESC


-- =========================================================
-- 3b. Revenue and profit by subcategory
-- =========================================================

WITH subcategory_trend AS (
SELECT
	category,
	subcategory,
	SUM(s.quantity * p.unit_price_usd) AS total_revenue,
	SUM(s.quantity * (p.unit_price_usd - p.unit_cost_usd)) AS total_profit,
	SUM(s.quantity) AS total_quantity_sold	
FROM sales s
JOIN products p
ON s.product_key = p.product_key
GROUP BY category, subcategory
)

SELECT *,
	ROUND((total_profit/NULLIF(total_revenue,0)) * 100, 2) AS profit_margin_percent
FROM subcategory_trend
ORDER BY total_revenue DESC;


-- =========================================================
-- 3c. Top-performing brands
-- =========================================================

WITH brand_trend AS (
SELECT
	brand,
	SUM(s.quantity * p.unit_price_usd) AS total_revenue,
	SUM(s.quantity * (p.unit_price_usd - p.unit_cost_usd)) AS total_profit,
	SUM(s.quantity) AS total_quantity_sold	
FROM sales s
JOIN products p
ON s.product_key = p.product_key
GROUP BY brand
)

SELECT *,
	ROUND((total_profit/NULLIF(total_revenue,0)) * 100, 2) AS profit_margin_percent
FROM brand_trend
ORDER BY total_revenue DESC;


-- =========================================================
-- 3D. Product Performance
-- =========================================================

WITH product_trend AS (
SELECT 
	product_name,
	brand,
	category,
	SUM(s.quantity * p.unit_price_usd) AS total_revenue,
	SUM(s.quantity * (p.unit_price_usd - p.unit_cost_usd)) AS total_profit,
	SUM(s.quantity) AS total_quantity_sold		
FROM sales s
JOIN products p
ON s.product_key = p.product_key
GROUP BY product_name, brand, category
),

product_rank AS (
SELECT *,
	RANK() OVER (ORDER BY total_revenue DESC) AS revenue_rank
FROM product_trend
)

-- Top 10 Products by Revenue

SELECT *
FROM product_rank
WHERE revenue_rank <= 10

-- Bottom 10 Products by Revenue

WITH product_trend AS (
SELECT 
	product_name,
	brand,
	category,
	SUM(s.quantity * p.unit_price_usd) AS total_revenue,
	SUM(s.quantity * (p.unit_price_usd - p.unit_cost_usd)) AS total_profit,
	SUM(s.quantity) AS total_quantity_sold		
FROM sales s
JOIN products p
ON s.product_key = p.product_key
GROUP BY product_name, brand, category
)

SELECT * 
FROM product_trend
ORDER BY total_revenue ASC
LIMIT 10


-- =========================================================
-- 4a. Country performance
-- =========================================================

WITH country_trend AS (
SELECT 
	country,
	SUM(s.quantity * p.unit_price_usd) AS total_revenue,
	SUM(s.quantity * (p.unit_price_usd - p.unit_cost_usd)) AS total_profit,
	SUM(s.quantity) AS total_quantity_sold,	
	COUNT(DISTINCT order_number) AS total_order
FROM sales s
JOIN products p
ON s.product_key = p.product_key
JOIN stores st
ON s.store_key = st.store_key
WHERE st.store_key <> 0
GROUP BY country
ORDER BY total_revenue DESC
)  

SELECT *,
	ROUND((total_profit / NULLIF(total_revenue, 0)) * 100,2) AS profit_margin_percent
FROM country_trend


-- =========================================================
-- 4b. Store Performance
-- =========================================================

WITH store_trend AS (
SELECT 
	st.store_key,
	st.country,
	state,
	SUM(s.quantity * p.unit_price_usd) AS total_revenue,
	SUM(s.quantity * (p.unit_price_usd - p.unit_cost_usd)) AS total_profit,
	SUM(s.quantity) AS total_quantity_sold,	
	COUNT(DISTINCT order_number) AS total_orders
FROM sales s
JOIN products p
ON s.product_key = p.product_key
JOIN stores st
ON s.store_key = st.store_key
WHERE st.store_key <> 0
GROUP BY st.store_key, country, state
ORDER BY total_revenue DESC
)  

SELECT *,
	ROUND((total_profit / NULLIF(total_revenue, 0)) * 100,2) AS profit_margin_percent
FROM store_trend


-- =========================================================
-- 5. Online vs Physical Store Performance
-- =========================================================

WITH channel_performence AS (
SELECT 
	CASE
		WHEN s.store_key = 0 THEN 'Online'
		ELSE 'Physical Store'
	END AS channel,
	SUM(s.quantity * p.unit_price_usd) AS total_revenue,
	SUM(s.quantity * (p.unit_price_usd - unit_cost_usd)) AS total_profit,
	SUM(s.quantity) AS total_quantity_sold,
	COUNT(DISTINCT order_number) AS total_order

FROM sales s
JOIN products p
on s.product_key = p.product_key
GROUP BY CASE
		WHEN s.store_key = 0 THEN 'Online'
		ELSE 'Physical Store'
	END 
)

SELECT *,
	ROUND(total_revenue/NULLIF(total_order,0),2) AS average_order_value,
	ROUND((total_profit/NULLIF(total_revenue,0)) * 100, 2) AS profit_margin_percent
FROM channel_performence


-- =========================================================
-- 6a. Top 10 Customers by Revenue
-- =========================================================

WITH top_customer AS (
SELECT
	c.customer_key,
	c.name,
	c.country,
	SUM(s.quantity * p.unit_price_usd) AS total_revenue,
	SUM(s.quantity * (p.unit_price_usd - unit_cost_usd)) AS total_profit,
	SUM(s.quantity) AS total_quantity_sold,
	COUNT(DISTINCT order_number) AS total_order
	
FROM sales s
JOIN products p
on s.product_key = p.product_key
JOIN customers c
on s.customer_key = c.customer_key
GROUP BY c.customer_key, c.name, c.country
)

SELECT *,
	ROUND(total_revenue / NULLIF(total_order, 0),2) AS average_order_value
FROM top_customer
ORDER BY total_revenue DESC
LIMIT 10


-- =========================================================
-- 6b. Customer Performance by Gender
-- =========================================================

WITH gender_performance AS (
SELECT
	c.gender,
	SUM(s.quantity * p.unit_price_usd) AS total_revenue,
	SUM(s.quantity * (p.unit_price_usd - p.unit_cost_usd)) AS total_profit,
	SUM(s.quantity) AS total_quantity_sold,
	COUNT(DISTINCT s.order_number) AS total_order
FROM sales s
JOIN products p
on s.product_key = p.product_key
JOIN customers c
on s.customer_key = c.customer_key
GROUP BY c.gender
)

SELECT *,
	ROUND(total_revenue/NULLIF(total_order,0),2) AS average_order_value,
	ROUND((total_profit/NULLIF(total_revenue,0)) * 100, 2) AS profit_margin_percent
FROM gender_performance


-- =========================================================
-- 6c. Customer Performance by Age Group
-- =========================================================

WITH age_group_performence AS (
SELECT
	CASE 
		WHEN DATE_PART('year', AGE(s.order_date, c.birthday)) < 25 THEN 'Under 25'
		WHEN DATE_PART('year', AGE(s.order_date, c.birthday)) BETWEEN 25 AND 34 THEN '25-34'
		WHEN DATE_PART('YEAR', AGE(s.order_date, c.birthday)) BETWEEN 35 AND 44 THEN '35-44'
		WHEN DATE_PART('YEAR', AGE(s.order_date, c.birthday)) BETWEEN 45 AND 54 THEN '45-54'
		WHEN DATE_PART('YEAR', AGE(s.order_date, c.birthday)) BETWEEN 55 AND 64 THEN '55-64'
		ELSE '65+'
	END AS age_group,
		
	SUM(s.quantity * p.unit_price_usd) AS total_revenue,
	SUM(s.quantity * (p.unit_price_usd - p.unit_cost_usd)) AS total_profit,
	SUM(s.quantity) AS total_quantity_sold,
	COUNT(DISTINCT s.order_number) AS total_order
FROM sales s
JOIN products p
on s.product_key = p.product_key
JOIN customers c
on s.customer_key = c.customer_key
GROUP BY age_group
)

SELECT *,
	ROUND(total_revenue/NULLIF(total_order,0),2) AS average_order_value,
	ROUND((total_profit/NULLIF(total_revenue,0)) * 100, 2) AS profit_margin_percent
FROM age_group_performence
ORDER BY CASE age_group
    WHEN 'Under 25' THEN 1
    WHEN '25-34' THEN 2
    WHEN '35-44' THEN 3
    WHEN '45-54' THEN 4
    WHEN '55-64' THEN 5
    WHEN '65+' THEN 6
END


-- =========================================================
-- 7. Top 10 largest individual orders
-- =========================================================

SELECT
    s.order_number,
    s.order_date,
    c.customer_key,
    c.name,
    c.country,
	SUM(s.quantity * p.unit_price_usd) AS order_value,
	SUM(s.quantity * (p.unit_price_usd - p.unit_cost_usd)) AS order_profit,
	SUM(s.quantity) AS total_quantity
FROM sales s
JOIN products p
on s.product_key = p.product_key
JOIN customers c
on s.customer_key = c.customer_key
GROUP BY s.order_number, s.order_date, c.customer_key, c.name, c.country
ORDER BY order_value DESC
LIMIT 10


-- =========================================================
-- 8. Online Delivery Performance
-- =========================================================

WITH online_orders AS (
SELECT 
	s.order_number,
	s.order_date,
	s.delivery_date,
	s.delivery_date - s.order_date AS delivery_days
FROM sales s
WHERE store_key = 0 AND delivery_date IS NOT NULL
GROUP BY s.order_number, s.order_date, s.delivery_date
)

SELECT
	COUNT(*) AS online_order,
	ROUND(AVG(delivery_days),0) AS average_delivery_days,
	PERCENTILE_CONT(0.5)
        WITHIN GROUP (ORDER BY delivery_days)AS median_delivery_days,
	MIN(delivery_days) AS minimum_delivery_days,
	MAX(delivery_days) AS maximun_delivery_days
FROM online_orders


-- =========================================================
-- 9. High-Sales Products with Relatively Low Profitability
-- =========================================================

WITH product_performance AS (
SELECT
	p.product_key,
	p.product_name,
	p.brand,
	p.category,
	SUM(s.quantity * p.unit_price_usd) AS total_revenue,
	SUM(s.quantity * (p.unit_price_usd - p.unit_cost_usd)) AS total_profit,
	SUM(s.quantity) AS total_quantity_sold,
	ROUND((SUM(s.quantity * (p.unit_price_usd - p.unit_cost_usd))
	/ NULLIF(SUM(s.quantity * p.unit_price_usd), 0)) * 100,2) AS profit_margin_percent
FROM sales s
JOIN products p
ON s.product_key = p.product_key
GROUP BY p.product_key, p.product_name, p.brand, p.category
),

revenue_threshold AS (
SELECT
	PERCENTILE_CONT(0.75)
        WITHIN GROUP (ORDER BY total_revenue) AS high_revenue_threshold
FROM product_performance
)

SELECT
    pp.product_key,
    pp.product_name,
    pp.brand,
    pp.category,
    pp.total_revenue,
    pp.total_profit,
    pp.total_quantity_sold,
    pp.profit_margin_percent

FROM product_performance pp
CROSS JOIN revenue_threshold rt

WHERE pp.total_revenue >= rt.high_revenue_threshold
  AND pp.profit_margin_percent < 58.58

ORDER BY pp.total_revenue DESC;






	