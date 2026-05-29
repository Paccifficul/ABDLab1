TRUNCATE TABLE
    fact_sales,
    dim_supplier,
    dim_store,
    dim_product,
    dim_seller,
    dim_customer,
    dim_date,
    dim_brand,
    dim_pet_category,
    dim_product_category,
    dim_pet,
    dim_pet_breed,
    dim_pet_type,
    dim_location,
    dim_city,
    dim_country
RESTART IDENTITY CASCADE;

INSERT INTO dim_country (country_name)
SELECT DISTINCT country_name
FROM (
    SELECT customer_country AS country_name FROM mock_data
    UNION
    SELECT seller_country FROM mock_data
    UNION
    SELECT store_country FROM mock_data
    UNION
    SELECT supplier_country FROM mock_data
) countries
WHERE country_name IS NOT NULL;

INSERT INTO dim_city (city_name, state_name)
SELECT DISTINCT city_name, state_name
FROM (
    SELECT store_city AS city_name, store_state AS state_name FROM mock_data
    UNION
    SELECT supplier_city, NULL FROM mock_data
) cities
WHERE city_name IS NOT NULL;

INSERT INTO dim_location (city_id, country_id, postal_code, address)
SELECT DISTINCT
    NULL::int,
    c.country_id,
    m.customer_postal_code,
    NULL::varchar
FROM mock_data m
JOIN dim_country c ON c.country_name = m.customer_country
UNION
SELECT DISTINCT
    NULL::int,
    c.country_id,
    m.seller_postal_code,
    NULL::varchar
FROM mock_data m
JOIN dim_country c ON c.country_name = m.seller_country
UNION
SELECT DISTINCT
    ci.city_id,
    c.country_id,
    NULL::varchar,
    m.store_location
FROM mock_data m
JOIN dim_city ci
    ON ci.city_name = m.store_city
    AND COALESCE(ci.state_name, '') = COALESCE(m.store_state, '')
JOIN dim_country c ON c.country_name = m.store_country
UNION
SELECT DISTINCT
    ci.city_id,
    c.country_id,
    NULL::varchar,
    m.supplier_address
FROM mock_data m
JOIN dim_city ci
    ON ci.city_name = m.supplier_city
    AND ci.state_name IS NULL
JOIN dim_country c ON c.country_name = m.supplier_country;

INSERT INTO dim_pet_type (pet_type_name)
SELECT DISTINCT customer_pet_type
FROM mock_data
WHERE customer_pet_type IS NOT NULL;

INSERT INTO dim_pet_breed (pet_breed_name)
SELECT DISTINCT customer_pet_breed
FROM mock_data
WHERE customer_pet_breed IS NOT NULL;

INSERT INTO dim_pet (pet_type_id, pet_breed_id)
SELECT DISTINCT pt.pet_type_id, pb.pet_breed_id
FROM mock_data m
JOIN dim_pet_type pt ON pt.pet_type_name = m.customer_pet_type
JOIN dim_pet_breed pb ON pb.pet_breed_name = m.customer_pet_breed;

INSERT INTO dim_product_category (category_name)
SELECT DISTINCT product_category
FROM mock_data
WHERE product_category IS NOT NULL;

INSERT INTO dim_pet_category (category_name)
SELECT DISTINCT pet_category
FROM mock_data
WHERE pet_category IS NOT NULL;

INSERT INTO dim_brand (brand_name)
SELECT DISTINCT product_brand
FROM mock_data
WHERE product_brand IS NOT NULL;

INSERT INTO dim_date (full_date, year, quarter, month, day, day_of_week)
SELECT DISTINCT
    parsed_date,
    EXTRACT(YEAR FROM parsed_date)::int,
    EXTRACT(QUARTER FROM parsed_date)::int,
    EXTRACT(MONTH FROM parsed_date)::int,
    EXTRACT(DAY FROM parsed_date)::int,
    EXTRACT(ISODOW FROM parsed_date)::int
FROM (
    SELECT to_date(sale_date, 'MM/DD/YYYY') AS parsed_date FROM mock_data WHERE sale_date IS NOT NULL
    UNION
    SELECT to_date(product_release_date, 'MM/DD/YYYY') FROM mock_data WHERE product_release_date IS NOT NULL
    UNION
    SELECT to_date(product_expiry_date, 'MM/DD/YYYY') FROM mock_data WHERE product_expiry_date IS NOT NULL
) dates;

INSERT INTO dim_customer (
    source_customer_id,
    first_name,
    last_name,
    age,
    email,
    location_id,
    pet_id,
    pet_name
)
SELECT DISTINCT ON (m.customer_email)
    m.sale_customer_id,
    m.customer_first_name,
    m.customer_last_name,
    m.customer_age,
    m.customer_email,
    (
        SELECT l.location_id
        FROM dim_location l
        JOIN dim_country c ON c.country_id = l.country_id
        WHERE c.country_name = m.customer_country
          AND l.city_id IS NULL
          AND COALESCE(l.postal_code, '') = COALESCE(m.customer_postal_code, '')
          AND l.address IS NULL
        ORDER BY l.location_id
        LIMIT 1
    ) AS location_id,
    p.pet_id,
    m.customer_pet_name
FROM mock_data m
JOIN dim_pet_type pt ON pt.pet_type_name = m.customer_pet_type
JOIN dim_pet_breed pb ON pb.pet_breed_name = m.customer_pet_breed
JOIN dim_pet p
    ON p.pet_type_id = pt.pet_type_id
    AND p.pet_breed_id = pb.pet_breed_id
WHERE m.customer_email IS NOT NULL
ORDER BY m.customer_email, m.id;

INSERT INTO dim_seller (
    source_seller_id,
    first_name,
    last_name,
    email,
    location_id
)
SELECT DISTINCT ON (m.seller_email)
    m.sale_seller_id,
    m.seller_first_name,
    m.seller_last_name,
    m.seller_email,
    (
        SELECT l.location_id
        FROM dim_location l
        JOIN dim_country c ON c.country_id = l.country_id
        WHERE c.country_name = m.seller_country
          AND l.city_id IS NULL
          AND COALESCE(l.postal_code, '') = COALESCE(m.seller_postal_code, '')
          AND l.address IS NULL
        ORDER BY l.location_id
        LIMIT 1
    ) AS location_id
FROM mock_data m
WHERE m.seller_email IS NOT NULL
ORDER BY m.seller_email, m.id;

INSERT INTO dim_product (
    source_product_id,
    product_name,
    product_category_id,
    pet_category_id,
    brand_id,
    price,
    stock_quantity,
    weight,
    color,
    size,
    material,
    description,
    rating,
    reviews,
    release_date_id,
    expiry_date_id
)
SELECT DISTINCT ON (m.product_name, b.brand_id)
    m.sale_product_id,
    m.product_name,
    pc.product_category_id,
    petc.pet_category_id,
    b.brand_id,
    m.product_price,
    m.product_quantity,
    m.product_weight,
    m.product_color,
    m.product_size,
    m.product_material,
    m.product_description,
    m.product_rating,
    m.product_reviews,
    rd.date_id,
    ed.date_id
FROM mock_data m
JOIN dim_product_category pc ON pc.category_name = m.product_category
JOIN dim_pet_category petc ON petc.category_name = m.pet_category
JOIN dim_brand b ON b.brand_name = m.product_brand
JOIN dim_date rd ON rd.full_date = to_date(m.product_release_date, 'MM/DD/YYYY')
JOIN dim_date ed ON ed.full_date = to_date(m.product_expiry_date, 'MM/DD/YYYY')
WHERE m.product_name IS NOT NULL
ORDER BY m.product_name, b.brand_id, m.id;

INSERT INTO dim_store (store_name, location_id, phone, email)
SELECT DISTINCT ON (m.store_name, l.location_id)
    m.store_name,
    l.location_id,
    m.store_phone,
    m.store_email
FROM mock_data m
JOIN dim_city ci
    ON ci.city_name = m.store_city
    AND COALESCE(ci.state_name, '') = COALESCE(m.store_state, '')
JOIN dim_country c ON c.country_name = m.store_country
JOIN dim_location l
    ON l.city_id = ci.city_id
    AND l.country_id = c.country_id
    AND l.postal_code IS NULL
    AND COALESCE(l.address, '') = COALESCE(m.store_location, '')
WHERE m.store_name IS NOT NULL
ORDER BY m.store_name, l.location_id, m.id;

INSERT INTO dim_supplier (supplier_name, contact, email, phone, location_id)
SELECT DISTINCT ON (m.supplier_name, m.supplier_email)
    m.supplier_name,
    m.supplier_contact,
    m.supplier_email,
    m.supplier_phone,
    (
        SELECT l.location_id
        FROM dim_location l
        JOIN dim_city ci
            ON ci.city_id = l.city_id
            AND ci.city_name = m.supplier_city
            AND ci.state_name IS NULL
        JOIN dim_country c
            ON c.country_id = l.country_id
            AND c.country_name = m.supplier_country
        WHERE l.postal_code IS NULL
          AND COALESCE(l.address, '') = COALESCE(m.supplier_address, '')
        ORDER BY l.location_id
        LIMIT 1
    ) AS location_id
FROM mock_data m
WHERE m.supplier_name IS NOT NULL
ORDER BY m.supplier_name, m.supplier_email, m.id;

INSERT INTO fact_sales (
    source_row_id,
    sale_date_id,
    customer_id,
    seller_id,
    product_id,
    store_id,
    supplier_id,
    sale_quantity,
    sale_total_price
)
SELECT
    m.id,
    d.date_id,
    cu.customer_id,
    se.seller_id,
    pr.product_id,
    st.store_id,
    su.supplier_id,
    m.sale_quantity,
    m.sale_total_price
FROM mock_data m
JOIN dim_date d ON d.full_date = to_date(m.sale_date, 'MM/DD/YYYY')
JOIN dim_customer cu ON cu.email = m.customer_email
JOIN dim_seller se ON se.email = m.seller_email
JOIN dim_brand b ON b.brand_name = m.product_brand
JOIN dim_product pr
    ON pr.product_name = m.product_name
    AND pr.brand_id = b.brand_id
JOIN dim_city store_city
    ON store_city.city_name = m.store_city
    AND COALESCE(store_city.state_name, '') = COALESCE(m.store_state, '')
JOIN dim_country store_country ON store_country.country_name = m.store_country
JOIN dim_location store_location
    ON store_location.city_id = store_city.city_id
    AND store_location.country_id = store_country.country_id
    AND COALESCE(store_location.address, '') = COALESCE(m.store_location, '')
JOIN dim_store st
    ON st.store_name = m.store_name
    AND st.location_id = store_location.location_id
JOIN dim_supplier su
    ON su.supplier_name = m.supplier_name
    AND su.email = m.supplier_email;
