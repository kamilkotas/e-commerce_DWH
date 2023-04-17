CREATE SCHEMA IF NOT EXISTS bl_3nf;

CREATE TABLE IF NOT EXISTS bl_3nf.ce_customers (
					customer_id			BIGINT PRIMARY KEY,
					customer_src_id		VARCHAR(255) NOT NULL,
					source_system		VARCHAR(255) NOT NULL,
					source_entity		VARCHAR(255) NOT NULL,
					address_id			BIGINT NOT NULL,
					customer_name		VARCHAR(255) NOT NULL,
					customer_surname	VARCHAR,
					customer_phone		VARCHAR(255),
					customer_email		VARCHAR(255),
					customer_birth_date VARCHAR(255),
					update_dt			DATE,
					insert_dt			DATE,
					CONSTRAINT customer_address_id_fkey FOREIGN KEY (address_id) REFERENCES bl_3nf.ce_addresses(address_id)				
);