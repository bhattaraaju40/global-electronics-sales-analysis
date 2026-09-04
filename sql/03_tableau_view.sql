-- Tableau Analysis View

CREATE OR REPLACE VIEW vw_sales_analysis AS

SELECT
    -- Order information
    s.order_number,
    s.line_item,
    s.order_date,
    s.delivery_date,

	 -- Customer information
    c.customer_key,
    c.name AS customer_name,
    c.gender,
    c.country AS customer_country,
    c.continent,

	CASE
        WHEN DATE_PART('year', AGE(s.order_date, c.birthday)) < 25
            THEN 'Under 25'
        WHEN DATE_PART('year', AGE(s.order_date, c.birthday)) BETWEEN 25 AND 34
            THEN '25-34'
        WHEN DATE_PART('year', AGE(s.order_date, c.birthday)) BETWEEN 35 AND 44
            THEN '35-44'
        WHEN DATE_PART('year', AGE(s.order_date, c.birthday)) BETWEEN 45 AND 54
            THEN '45-54'
        WHEN DATE_PART('year', AGE(s.order_date, c.birthday)) BETWEEN 55 AND 64
            THEN '55-64'
        ELSE '65+'
    END AS age_group,

	-- Store information
    st.store_key,
    st.country AS store_country,
    st.state AS store_state,

    CASE
        WHEN s.store_key = 0 THEN 'Online'
        ELSE 'Physical Store'
    END AS sales_channel,

	-- Product information
    p.product_key,
    p.product_name,
    p.brand,
    p.category,
    p.subcategory,

	-- Sales information
    s.quantity,
    p.unit_price_usd,
    p.unit_cost_usd,

	 -- Calculated business measures
    s.quantity * p.unit_price_usd AS revenue,
    s.quantity * p.unit_cost_usd AS cost,
    s.quantity * (p.unit_price_usd - p.unit_cost_usd) AS profit,

	 -- Delivery time
    CASE
        WHEN s.store_key = 0
             AND s.delivery_date IS NOT NULL
        THEN s.delivery_date - s.order_date
    END AS delivery_days
	
FROM sales s
JOIN products p
    ON s.product_key = p.product_key
JOIN customers c
    ON s.customer_key = c.customer_key
JOIN stores st
    ON s.store_key = st.store_key;



