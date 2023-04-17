CREATE SCHEMA IF NOT EXISTS bl_3nf;

CREATE TABLE bl_3nf.ce_categories (
					category_id			BIGINT PRIMARY KEY,
					category_src_id		VARCHAR(255) NOT NULL,
					source_system		VARCHAR(255) NOT NULL,
					source_entity		VARCHAR(255) NOT NULL,
					category_name		VARCHAR(255) NOT NULL,
					update_dt			DATE,
					insert_dt			DATE
										
);

COMMIT;