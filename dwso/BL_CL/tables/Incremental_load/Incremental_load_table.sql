
CREATE TABLE IF NOT EXISTS bl_cl.PRM_MTA_INCREMENTAL_LOAD (
		source_table_name varchar(255),
		target_table VARCHAR(255),
		procedure_name VARCHAR(255),
		previouse_loaded_date DATE,
		UNIQUE (source_table_name, target_table));


INSERT INTO  bl_cl.PRM_MTA_INCREMENTAL_LOAD
VALUES('src_offline_transactions',
		'ce_transactions',
		'ce_transactions_load',
		'1800-01-01'::DATE)
ON CONFLICT DO NOTHING;

COMMIT;	

INSERT INTO  bl_cl.PRM_MTA_INCREMENTAL_LOAD
VALUES('src_online_transactions',
		'ce_transactions',
		'ce_transactions_load',
		'1800-01-01'::DATE)
ON CONFLICT DO NOTHING;

COMMIT;

INSERT INTO  bl_cl.PRM_MTA_INCREMENTAL_LOAD
VALUES('ce_transactions',
		'fct_transactions',
		'fct_transactions_load',
		'1800-01-01'::DATE)
ON CONFLICT DO NOTHING;
		
COMMIT;

INSERT INTO  bl_cl.PRM_MTA_INCREMENTAL_LOAD
VALUES('src_offline_transactions',
		'ce_customers',
		'ce_customers_load',
		'1800-01-01'::DATE)
ON CONFLICT DO NOTHING;

INSERT INTO  bl_cl.PRM_MTA_INCREMENTAL_LOAD
VALUES('src_online_transactions',
		'ce_customers',
		'ce_customers_load',
		'1800-01-01'::DATE)
ON CONFLICT DO NOTHING;
