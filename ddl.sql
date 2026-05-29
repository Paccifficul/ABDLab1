CREATE TABLE IF NOT EXISTS dim_country (
    country_id serial PRIMARY KEY,
    country_name varchar(100) NOT NULL UNIQUE
);

CREATE TABLE IF NOT EXISTS dim_city (
    city_id serial PRIMARY KEY,
    city_name varchar(100) NOT NULL,
    state_name varchar(100)
);

CREATE UNIQUE INDEX IF NOT EXISTS uq_dim_city
    ON dim_city (city_name, state_name) NULLS NOT DISTINCT;

CREATE TABLE IF NOT EXISTS dim_location (
    location_id serial PRIMARY KEY,
    city_id int REFERENCES dim_city(city_id),
    country_id int NOT NULL REFERENCES dim_country(country_id),
    postal_code varchar(50),
    address varchar(255)
);

CREATE UNIQUE INDEX IF NOT EXISTS uq_dim_location
    ON dim_location (city_id, country_id, postal_code, address) NULLS NOT DISTINCT;

CREATE TABLE IF NOT EXISTS dim_pet_type (
    pet_type_id serial PRIMARY KEY,
    pet_type_name varchar(50) NOT NULL UNIQUE
);

CREATE TABLE IF NOT EXISTS dim_pet_breed (
    pet_breed_id serial PRIMARY KEY,
    pet_breed_name varchar(100) NOT NULL UNIQUE
);

CREATE TABLE IF NOT EXISTS dim_pet (
    pet_id serial PRIMARY KEY,
    pet_type_id int NOT NULL REFERENCES dim_pet_type(pet_type_id),
    pet_breed_id int NOT NULL REFERENCES dim_pet_breed(pet_breed_id),
    CONSTRAINT uq_dim_pet UNIQUE (pet_type_id, pet_breed_id)
);

CREATE TABLE IF NOT EXISTS dim_product_category (
    product_category_id serial PRIMARY KEY,
    category_name varchar(100) NOT NULL UNIQUE
);

CREATE TABLE IF NOT EXISTS dim_pet_category (
    pet_category_id serial PRIMARY KEY,
    category_name varchar(100) NOT NULL UNIQUE
);

CREATE TABLE IF NOT EXISTS dim_brand (
    brand_id serial PRIMARY KEY,
    brand_name varchar(100) NOT NULL UNIQUE
);

CREATE TABLE IF NOT EXISTS dim_date (
    date_id serial PRIMARY KEY,
    full_date date NOT NULL UNIQUE,
    year int NOT NULL,
    quarter int NOT NULL,
    month int NOT NULL,
    day int NOT NULL,
    day_of_week int NOT NULL
);

CREATE TABLE IF NOT EXISTS dim_customer (
    customer_id serial PRIMARY KEY,
    source_customer_id int,
    first_name varchar(100),
    last_name varchar(100),
    age int,
    email varchar(255) UNIQUE,
    location_id int REFERENCES dim_location(location_id),
    pet_id int REFERENCES dim_pet(pet_id),
    pet_name varchar(100)
);

CREATE TABLE IF NOT EXISTS dim_seller (
    seller_id serial PRIMARY KEY,
    source_seller_id int,
    first_name varchar(100),
    last_name varchar(100),
    email varchar(255) UNIQUE,
    location_id int REFERENCES dim_location(location_id)
);

CREATE TABLE IF NOT EXISTS dim_product (
    product_id serial PRIMARY KEY,
    source_product_id int,
    product_name varchar(255) NOT NULL,
    product_category_id int REFERENCES dim_product_category(product_category_id),
    pet_category_id int REFERENCES dim_pet_category(pet_category_id),
    brand_id int REFERENCES dim_brand(brand_id),
    price numeric(10, 2),
    stock_quantity int,
    weight numeric(10, 2),
    color varchar(50),
    size varchar(50),
    material varchar(100),
    description text,
    rating numeric(3, 1),
    reviews int,
    release_date_id int REFERENCES dim_date(date_id),
    expiry_date_id int REFERENCES dim_date(date_id),
    CONSTRAINT uq_dim_product UNIQUE (product_name, brand_id)
);

CREATE TABLE IF NOT EXISTS dim_store (
    store_id serial PRIMARY KEY,
    store_name varchar(255) NOT NULL,
    location_id int REFERENCES dim_location(location_id),
    phone varchar(50),
    email varchar(255),
    CONSTRAINT uq_dim_store UNIQUE (store_name, location_id)
);

CREATE TABLE IF NOT EXISTS dim_supplier (
    supplier_id serial PRIMARY KEY,
    supplier_name varchar(255) NOT NULL,
    contact varchar(255),
    email varchar(255),
    phone varchar(50),
    location_id int REFERENCES dim_location(location_id),
    CONSTRAINT uq_dim_supplier UNIQUE (supplier_name, email)
);

CREATE TABLE IF NOT EXISTS fact_sales (
    sale_id serial PRIMARY KEY,
    source_row_id int,
    sale_date_id int NOT NULL REFERENCES dim_date(date_id),
    customer_id int REFERENCES dim_customer(customer_id),
    seller_id int REFERENCES dim_seller(seller_id),
    product_id int REFERENCES dim_product(product_id),
    store_id int REFERENCES dim_store(store_id),
    supplier_id int REFERENCES dim_supplier(supplier_id),
    sale_quantity int NOT NULL,
    sale_total_price numeric(12, 2) NOT NULL
);
