CREATE TABLE IF NOT EXISTS bl_dm.DIM_PRODUCTS (
							products_surr_id 	BIGINT NOT NULL UNIQUE,
							products_src_id 	VARCHAR(255) NOT NULL,
							source_system 		VARCHAR(255) NOT NULL,
							source_entity 		VARCHAR(255) NOT NULL,
							category_id 		VARCHAR(255) NOT NULL,
							category_name 		VARCHAR(255) NOT NULL,
							product_name 		VARCHAR(255) NOT NULL,
							product_desc 		VARCHAR(255) NOT NULL,
							product_pro_year 	VARCHAR(255) NOT NULL,
							product_color 		VARCHAR(255) NOT NULL,
							update_dt 			DATE NOT NULL,
							insert_dt 			DATE NOT NULL);