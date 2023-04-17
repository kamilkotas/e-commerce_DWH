-- Schema
CREATE SCHEMA IF NOT EXISTS bl_3nf;


-- Postal _codes table

CREATE TABLE IF NOT EXISTS bl_3nf.ce_postal_codes (
						postal_code_id 		BIGINT PRIMARY KEY,
						postal_codes_src_id	VARCHAR(255) NOT NULL,	
						source_system		VARCHAR(255) NOT NULL,
						source_entity		VARCHAR(255) NOT NULL,
						postal_code			VARCHAR(255) NOT NULL,
						city_id				BIGINT NOT NULL,
						update_dt			DATE,
						insert_dt			DATE,
						CONSTRAINT city_country_id_fkey FOREIGN KEY (city_id) REFERENCES bl_3nf.ce_cities(city_id)
					);