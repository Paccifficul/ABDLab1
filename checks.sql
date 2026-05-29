SELECT 'mock_data' AS table_name, count(*) AS rows_count FROM mock_data
UNION ALL SELECT 'fact_sales', count(*) FROM fact_sales
UNION ALL SELECT 'dim_customer', count(*) FROM dim_customer
UNION ALL SELECT 'dim_seller', count(*) FROM dim_seller
UNION ALL SELECT 'dim_product', count(*) FROM dim_product
UNION ALL SELECT 'dim_store', count(*) FROM dim_store
UNION ALL SELECT 'dim_supplier', count(*) FROM dim_supplier
UNION ALL SELECT 'dim_date', count(*) FROM dim_date;

SELECT
    sum(sale_quantity) AS sold_items,
    sum(sale_total_price) AS revenue
FROM fact_sales;

SELECT
    pc.category_name,
    count(*) AS sales_count,
    sum(fs.sale_total_price) AS revenue
FROM fact_sales fs
JOIN dim_product p ON p.product_id = fs.product_id
JOIN dim_product_category pc ON pc.product_category_id = p.product_category_id
GROUP BY pc.category_name
ORDER BY revenue DESC;
