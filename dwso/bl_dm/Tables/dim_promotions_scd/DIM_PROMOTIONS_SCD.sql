CREATE TABLE IF NOT EXISTS bl_dm.DIM_PROMOTIONS (
					promotions_surr_id		BIGINT NOT NULL UNIQUE,
					promotions_src_id		VARCHAR(255) NOT NULL,
					source_system			VARCHAR(255) NOT NULL,
					source_entity			VARCHAR(255) NOT NULL,
					promotion_name			VARCHAR(255) NOT NULL,
					start_dt				DATE NOT NULL,
					end_dt					DATE NOT NULL,
					is_active				BOOL NOT NULL,
					insert_dt				DATE NOT NULL			
);