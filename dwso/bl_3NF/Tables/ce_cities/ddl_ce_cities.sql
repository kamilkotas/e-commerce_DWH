-- create schema if not exists
CREATE SCHEMA IF NOT EXISTS bl_3nf;


-- CREATE cities table with constraint on ce_countries table 
CREATE TABLE IF NOT EXISTS bl_3nf.ce_cities (
						city_id 			BIGINT PRIMARY KEY,
						cities_src_id		VARCHAR(255) NOT NULL,	
						source_system		VARCHAR(255) NOT NULL,
						source_entity		VARCHAR(255) NOT NULL,
						city_name			VARCHAR(255) NOT NULL,
						country_id			BIGINT NOT NULL,
						update_dt			DATE,
						insert_dt			DATE,
						CONSTRAINT city_country_id_fkey FOREIGN KEY (country_id) REFERENCES bl_3nf.ce_countries(country_id)
					);