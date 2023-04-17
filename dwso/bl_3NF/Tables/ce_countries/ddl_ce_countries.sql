-- creating schema if not exists
CREATE SCHEMA IF NOT EXISTS bl_3nf;

-- create table country like in 3_NF model.


CREATE TABLE IF NOT EXISTS bl_3nf.ce_countries (
						country_id 			BIGINT PRIMARY KEY,
						countries_src_id	VARCHAR(255) NOT NULL,	
						source_system		VARCHAR(255) NOT NULL,
						source_entity		VARCHAR(255) NOT NULL,
						country_name		VARCHAR(255) NOT NULL,
						update_dt			DATE,
						insert_dt			DATE);
					





						

