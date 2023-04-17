CREATE SCHEMA IF NOT EXISTS bl_3nf;

CREATE TABLE IF NOT EXISTS bl_3nf.ce_promotions_scd2 (
					promotion_id		SERIAL PRIMARY KEY,
					promotion_src_id	VARCHAR(255) NOT NULL,
					source_system		VARCHAR(255) NOT NULL,
					source_entity		VARCHAR(255) NOT NULL,
					promotion_name		VARCHAR(255) NOT NULL,
					start_dt			DATE,
					end_dt				DATE,
					is_active			BOOL,
					update_dt			DATE,
					insert_dt			DATE			
);