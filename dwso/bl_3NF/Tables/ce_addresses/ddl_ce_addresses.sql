--CREATE schema if not exists
CREATE SCHEMA IF NOT EXISTS;

-- Create ce_addresses table

CREATE TABLE IF NOT EXISTS bl_3nf.ce_addresses (
					address_id				BIGINT PRIMARY KEY,
					address_src_id			VARCHAR(255) NOT NULL,
					source_system			VARCHAR(255) NOT NULL,
					source_entity			VARCHAR(255) NOT NULL,
					address_home_number		VARCHAR NOT NULL,
					address_apartment		VARCHAR(255) NOT NULL,
					street_id				BIGINT NOT NULL,
					update_dt				DATE,
					insert_dt				DATE,
					CONSTRAINT address_street_id_fkey FOREIGN KEY (street_id) REFERENCES bl_3nf.ce_streets(street_id)				
);

