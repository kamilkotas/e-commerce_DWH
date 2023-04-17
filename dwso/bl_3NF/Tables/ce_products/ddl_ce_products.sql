CREATE SCHEMA IF NOT EXISTS bl_3nf;


CREATE TABLE IF NOT EXISTS bl_3nf.ce_products (
												product_id			BIGINT PRIMARY KEY,
												product_src_id		VARCHAR(255) NOT NULL,
												source_system		VARCHAR(255) NOT NULL,
												source_entity		VARCHAR(255) NOT NULL,
												category_id			BIGINT NOT NULL,
												product_name		VARCHAR(255) NOT NULL,
												product_desc		TEXT,
												product_pro_year	VARCHAR(255),
												product_color		VARCHAR(255),
												update_dt			DATE,
												insert_dt			DATE,
												CONSTRAINT product_category_id_fkey FOREIGN KEY (category_id) REFERENCES bl_3nf.ce_categories(category_id)				
);