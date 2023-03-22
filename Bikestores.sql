
/*Bikestores script*/

-- Generate a table containing the fields; Order ID, customer name, city,state, Order date, sales volume, revenue, product name, Product category, brand name, 
--Store name, sales rep from Production and Sales Datasets


SELECT ord.order_id, 
		CONCAT(cus.first_name,' ' ,cus.last_name) AS customer_name,
		cus.city, 
		cus.state, 
		ord.order_date,
		SUM(sales_item.quantity) AS total_unit,-- Sales Volume
		SUM(sales_item.quantity*sales_item.list_price) AS revenue,
		prdct.product_name,
		brand.brand_name,
		cat.category_name,
		store.store_name,
		CONCAT(rep.first_name,' ',rep.last_name) AS sales_rep
FROM	sales.orders AS ord
JOIN	sales.customers AS cus
ON		ord.customer_id = cus.customer_id
JOIN	sales.order_items AS sales_item
ON		ord.order_id = sales_item.order_id	
JOIN	production.products AS prdct
ON		sales_item.product_id = prdct.product_id
JOIN	production.brands AS brand
ON		prdct.brand_id =brand.brand_id
JOIN	production.categories AS cat
ON		prdct.category_id = cat.category_id
JOIN	sales.stores AS store
ON		ord.store_id =store.store_id
JOIN	sales.staffs AS rep
ON		store.store_id = rep.store_id
GROUP BY 
		ord.order_id,
		CONCAT(cus.first_name,' ' ,cus.last_name),
		cus.city, 
		cus.state, 
		ord.order_date, 
		prdct.product_name,
		brand.brand_name,
		cat.category_name,
		store.store_name,
		CONCAT(rep.first_name,' ',rep.last_name)