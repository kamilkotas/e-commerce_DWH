CREATE OR REPLACE PROCEDURE bl_cl.add_fct_transactions()

    LANGUAGE plpgsql
AS
$add_fct_transactions$
DECLARE
    diag_row_count int;
    flag           varchar(4);
    error_message  text;

BEGIN
    flag = 'I';

INSERT INTO bl_dm.fct_transactions (products_surr_id,
									employees_surr_id,
									channels_surr_id,
									promotions_surr_id,
									shops_surr_id,
									customers_surr_id,
									costs,
									price,
									transaction_id,
									quntity,
									date_id)



SELECT 	COALESCE(dp.products_surr_id, -1) AS products_surr_id,
		COALESCE(de.employees_surr_id, -1) AS employees_surr_id,
		COALESCE(dc2.channels_surr_id, -1) AS channels_surr_id,
		COALESCE(dp2.promotions_surr_id, -1) AS promotions_surr_id,
		COALESCE(ds.shops_surr_id, -1) AS shops_surr_id,
		COALESCE(dc.customers_surr_id, -1) AS customers_surr_id,
		ct.cots,
		ct.price,
		COALESCE(ct.transaction_id,'N/A') AS transaction_id,
		ct.quantity,
		dd.date_id
		
FROM bl_cl._fact_table_load ct
LEFT JOIN bl_dm.dim_products dp ON ct.product_id::VARCHAR = dp.products_src_id
								AND dp.source_system = dp.source_system 
								AND dp.source_entity = dp.source_entity
LEFT JOIN bl_dm.dim_employees de ON ct.employee_id::VARCHAR = de.employees_src_id
								AND de.source_system = de.source_system 
								AND de.source_entity = de.source_entity
LEFT JOIN bl_dm.dim_channels dc2 ON ct.channel_id::VARCHAR = dc2.channels_src_id
								AND dc2.source_system = dc2.source_system 
								AND dc2.source_entity = dc2.source_entity
LEFT JOIN bl_dm.dim_shops ds ON ct.shop_id::VARCHAR = ds.shops_src_id
								AND ds.source_system = ds.source_system 
								AND ds.source_entity = ds.source_entity
LEFT JOIN bl_dm.dim_customers dc ON ct.customer_id::VARCHAR = dc.customers_src_id
								AND dc.source_system = dc.source_system 
								AND dc.source_entity = dc.source_entity
LEFT JOIN bl_dm.dim_dates dd ON ct.date_of_transaction = dd.date_actual
LEFT JOIN bl_dm.dim_promotions_scd dp2 ON ct.promotion_id::VARCHAR = dp2.promotions_src_id
								AND dp2.source_system = dp2.source_system 
								AND dp2.source_entity = dp2.source_entity;
							
UPDATE bl_cl.PRM_MTA_INCREMENTAL_LOAD
SET previouse_loaded_date = NOW()
WHERE upper(target_table) = 'FCT_TRANSACTIONS';



PERFORM * FROM bl_cl.add_log (current_user::VARCHAR, NOW()::TIMESTAMP, 'fct_transactions'::VARCHAR, flag::VARCHAR);

    GET DIAGNOSTICS diag_row_count = row_count;
EXCEPTION
    WHEN OTHERS THEN
        flag = 'E';
        GET STACKED DIAGNOSTICS
            error_message = MESSAGE_TEXT;
			PERFORM * FROM bl_cl.add_log (current_user::VARCHAR, NOW()::TIMESTAMP, 'fct_transactions'::VARCHAR, flag::VARCHAR, error_message::VARCHAR);
        COMMIT;


END;
$add_fct_transactions$;

