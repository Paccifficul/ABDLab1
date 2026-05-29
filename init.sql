CREATE TABLE IF NOT EXISTS mock_data (
    id int,
    customer_first_name varchar(100),
    customer_last_name varchar(100),
    customer_age int,
    customer_email varchar(255),
    customer_country varchar(100),
    customer_postal_code varchar(50),
    customer_pet_type varchar(50),
    customer_pet_name varchar(100),
    customer_pet_breed varchar(100),
    seller_first_name varchar(100),
    seller_last_name varchar(100),
    seller_email varchar(255),
    seller_country varchar(100),
    seller_postal_code varchar(50),
    product_name varchar(255),
    product_category varchar(100),
    product_price numeric(10, 2),
    product_quantity int,
    sale_date varchar(20),
    sale_customer_id int,
    sale_seller_id int,
    sale_product_id int,
    sale_quantity int,
    sale_total_price numeric(12, 2),
    store_name varchar(255),
    store_location varchar(255),
    store_city varchar(100),
    store_state varchar(100),
    store_country varchar(100),
    store_phone varchar(50),
    store_email varchar(255),
    pet_category varchar(100),
    product_weight numeric(10, 2),
    product_color varchar(50),
    product_size varchar(50),
    product_brand varchar(100),
    product_material varchar(100),
    product_description text,
    product_rating numeric(3, 1),
    product_reviews int,
    product_release_date varchar(20),
    product_expiry_date varchar(20),
    supplier_name varchar(255),
    supplier_contact varchar(255),
    supplier_email varchar(255),
    supplier_phone varchar(50),
    supplier_address varchar(255),
    supplier_city varchar(100),
    supplier_country varchar(100)
);

TRUNCATE TABLE mock_data;

COPY mock_data FROM '/csv/MOCK_DATA.csv' DELIMITER ',' CSV HEADER;
COPY mock_data FROM '/csv/MOCK_DATA (1).csv' DELIMITER ',' CSV HEADER;
COPY mock_data FROM '/csv/MOCK_DATA (2).csv' DELIMITER ',' CSV HEADER;
COPY mock_data FROM '/csv/MOCK_DATA (3).csv' DELIMITER ',' CSV HEADER;
COPY mock_data FROM '/csv/MOCK_DATA (4).csv' DELIMITER ',' CSV HEADER;
COPY mock_data FROM '/csv/MOCK_DATA (5).csv' DELIMITER ',' CSV HEADER;
COPY mock_data FROM '/csv/MOCK_DATA (6).csv' DELIMITER ',' CSV HEADER;
COPY mock_data FROM '/csv/MOCK_DATA (7).csv' DELIMITER ',' CSV HEADER;
COPY mock_data FROM '/csv/MOCK_DATA (8).csv' DELIMITER ',' CSV HEADER;
COPY mock_data FROM '/csv/MOCK_DATA (9).csv' DELIMITER ',' CSV HEADER;
