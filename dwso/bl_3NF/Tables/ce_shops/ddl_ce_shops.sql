-- Create schema if not exists
CREATE SCHEMA IF NOT EXISTS bl_3nf;

-- CREATE table
CREATE TABLE IF NOT EXISTS bl_3nf.ce_shops (
					shop_id				BIGINT PRIMARY KEY,
					shop_src_id			VARCHAR(255) NOT NULL,
					source_system		VARCHAR(255) NOT NULL,
					source_entity		VARCHAR(255) NOT NULL,
					address_id			BIGINT NOT NULL,
					shop_name			VARCHAR(255) NOT NULL,
					shop_phone			VARCHAR(255),
					shop_email			VARCHAR(255),
					update_dt			DATE,
					insert_dt			DATE,
					CONSTRAINT shop_address_id_fkey FOREIGN KEY (address_id) REFERENCES bl_3nf.ce_addresses(address_id)				
);