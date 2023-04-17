-- Schema IF NOT EXISTS
CREATE SCHEMA IF NOT EXISTS bl_3nf;

-- ce_streets table

CREATE TABLE IF NOT EXISTS bl_3nf.ce_streets (
						street_id	 		BIGINT PRIMARY KEY,
						street_src_id		VARCHAR(255) NOT NULL,	
						source_system		VARCHAR(255) NOT NULL,
						source_entity		VARCHAR(255) NOT NULL,
						street_name			VARCHAR(255) NOT NULL,
						postal_code_id		BIGINT NOT NULL,
						update_dt			DATE,
						insert_dt			DATE,
						CONSTRAINT street_postal_code_id_fkey FOREIGN KEY (postal_code_id) REFERENCES bl_3nf.ce_postal_codes(postal_code_id)
					);