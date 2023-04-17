

CREATE OR REPLACE VIEW bl_cl.offline_transaction_load AS (
	SELECT *
	FROM offline.src_offline_transactions sot 
	WHERE insert_dt > (SELECT previouse_loaded_date
					   FROM bl_cl.PRM_MTA_INCREMENTAL_LOAD
					   WHERE source_table_name = 'src_offline_transactions'
                        AND target_table = 'ce_transactions'));

					  

CREATE OR REPLACE VIEW bl_cl._online_transactions_load AS (
	SELECT *
	FROM online.src_online_transactions sot  
	WHERE insert_dt > (SELECT previouse_loaded_date
					   FROM bl_cl.PRM_MTA_INCREMENTAL_LOAD
					   WHERE source_table_name = 'src_online_transactions'
                        AND target_table = 'ce_transactions'));	
					  
					  
CREATE OR REPLACE VIEW bl_cl._fact_table_load AS (
	SELECT *
	FROM bl_3nf.ce_transactions ct  
	WHERE update_dt > (SELECT previouse_loaded_date
					   FROM bl_cl.PRM_MTA_INCREMENTAL_LOAD
					   WHERE source_table_name = 'ce_transactions'
                        AND target_table = 'fct_transactions'));
					   

CREATE OR REPLACE VIEW bl_cl.offline_customers_load AS (
	SELECT	customerno,
			customer_address_id,
			customer_name,
			customer_surname,
			customer_phone,
			customer_mail,
			customer_birth_date
	FROM offline.src_offline_transactions sot 
	WHERE insert_dt > (SELECT previouse_loaded_date
					   FROM bl_cl.PRM_MTA_INCREMENTAL_LOAD
					   WHERE source_table_name = 'src_offline_transactions'
					  	AND target_table = 'ce_customers'));					  
					  
					  
CREATE OR REPLACE VIEW bl_cl._online_customers_load AS (
	SELECT *
	FROM online.src_online_transactions sot  
	WHERE insert_dt > (SELECT previouse_loaded_date
					   FROM bl_cl.PRM_MTA_INCREMENTAL_LOAD
					   WHERE source_table_name = 'src_online_transactions'
					  AND target_table = 'ce_customers'));
					   
					  
