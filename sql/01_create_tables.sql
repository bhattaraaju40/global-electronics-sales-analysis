Create table customers(
	customer_key INTEGER PRIMARY KEY,
	gender VARCHAR(20),
	name VARCHAR(100), 
	city VARCHAR(100), 
	state_code VARCHAR(50), 
	state VARCHAR(100), 
	zip_code VARCHAR(20), 
	country VARCHAR(100), 
	continent VARCHAR(100), 
	birthday DATE
);

Create table products(
	product_key INTEGER PRIMARY KEY, 
	product_name VARCHAR(200), 
	brand VARCHAR(100), 
	color VARCHAR(50), 
	unit_cost_usd NUMERIC(12,2), 
	unit_price_usd NUMERIC(12,2), 
	subcategory_key INTEGER, 
	subcategory VARCHAR(100),
	category_key INTEGER,
	category VARCHAR(100)
);

Create table stores(
	store_key INTEGER PRIMARY KEY, 
	country VARCHAR(50), 
	state VARCHAR(50), 
	square_meters NUMERIC(10,2), 
	open_date DATE
);

Create table sales(
	order_number INTEGER, 
	line_item INTEGER,
	order_date DATE NOT NULL, 
	delivery_date DATE, 
	customer_key INTEGER NOT NULL,  
	store_key INTEGER NOT NULL, 
	product_key INTEGER NOT NULL, 
	quantity INTEGER NOT NULL,
	currency_code CHAR(3),

	PRIMARY KEY (order_number, line_item),

	FOREIGN KEY (customer_key)
		REFERENCES customers(customer_key),

	FOREIGN KEY(product_key)
		REFERENCES products(product_key),

	FOREIGN KEY(store_key)
		REFERENCES stores(store_key)
);
