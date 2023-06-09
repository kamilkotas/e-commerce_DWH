CREATE TABLE IF NOT EXISTS bl_dm.DIM_CUSTOMERS (
					customers_surr_id		BIGINT UNIQUE NOT NULL ,
					customers_src_id		VARCHAR(255) NOT NULL,
					source_system			VARCHAR(255) NOT NULL,
					source_entity			VARCHAR(255) NOT NULL,
					customer_name			VARCHAR(255) NOT NULL,
					customer_surname		VARCHAR(255) NOT NULL,
					customer_phone			VARCHAR(255) NOT NULL,
					customer_email			VARCHAR(255) NOT NULL,
					customer_country_id		VARCHAR(255) NOT NULL,
					customer_country_name	VARCHAR(255) NOT NULL,
					customer_city_id		VARCHAR(255) NOT NULL,
					customer_city_name		VARCHAR(255) NOT NULL,
					customer_postal_code_id	VARCHAR(255) NOT NULL,
					customer_postal_code	VARCHAR(255) NOT NULL,
					customer_street_id		VARCHAR(255) NOT NULL,
					customer_street_name	VARCHAR(255) NOT NULL,
					customer_address_id		VARCHAR(255) NOT NULL,
					customer_apartment		VARCHAR(255) NOT NULL,
					customer_address_number	VARCHAR(255) NOT NULL,
					update_dt				DATE NOT NULL,
					insert_dt				DATE NOT NULL
);