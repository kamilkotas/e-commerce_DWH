
CREATE TABLE IF NOT EXISTS bl_dm.DIM_CHANNELS (
					channels_surr_id	BIGINT NOT NULL UNIQUE,
					channels_src_id		VARCHAR(255) NOT NULL,
					source_system		VARCHAR(255) NOT NULL,
					source_entity		VARCHAR(255) NOT NULL,
					category_name		VARCHAR(255) NOT NULL,
					channel_name		VARCHAR(255) NOT NULL,
					update_dt			DATE,
					insert_dt			DATE
										
);


