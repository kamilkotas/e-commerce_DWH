CREATE OR REPLACE PROCEDURE bl_cl.add_ce_transactions()

    LANGUAGE plpgsql
AS
$add_ce_transactions$
DECLARE
    diag_row_count int;
    flag           varchar(4);
    error_message  text;

BEGIN
    flag = 'I';

SET datestyle = "ISO, MDY";

INSERT INTO bl_3nf.ce_transactions (promotion_id,
									customer_id,
									shop_id,
									employee_id,
									channel_id,
									product_id,
									cots,
									price,
									transaction_no,
									transaction_id,
									quantity,
									date_of_transaction,
									update_dt,
									insert_dt)

SELECT DISTINCT COALESCE(cp.promotion_id, -1) AS promotion_id,
				COALESCE(cc.customer_id, -1) AS customer_id,
				COALESCE(cs.shop_id, -1) AS shop_id,
				COALESCE(ce.employee_id, -1) AS employee_id,
				COALESCE(cc2.channel_id, -1) AS channel_id,
				COALESCE(cp2.product_id, -1) AS product_id,
				sot.costs::NUMERIC AS cots,
				sot.price::NUMERIC AS price,
				COALESCE(sot.transactionno, 'N/A') AS transaction_no, 
				COALESCE(sot.transaction_id, 'N/A') AS transaction_id,
				sot.quantity::INTEGER AS quantity,
				COALESCE(sot.date_of_tr::DATE, '19000101'::DATE) AS date_of_transaction,
				NOW(),
				NOW()
				
FROM bl_cl._online_sales_load sot
LEFT JOIN bl_3nf.ce_promotions_scd2 cp ON sot.promotion_id = cp.promotion_src_id
									AND cp.source_system = 'src_online'
									AND cp.source_entity = 'src_online_transactions'
									AND cp.end_dt >=  sot.date_of_tr::DATE
LEFT JOIN bl_3nf.ce_customers cc ON sot.customerno = cc.customer_src_id
									AND cc.source_system = 'src_online'
									AND cc.source_entity = 'src_online_transactions'
LEFT JOIN bl_3nf.ce_shops cs ON sot.shopno = cs.shop_src_id
									AND cs.source_system = 'src_online'
									AND cs.source_entity = 'src_online_transactions'
LEFT JOIN bl_3nf.ce_employees ce ON sot.employee_id = ce.employee_src_id
									AND ce.source_system = 'src_online'
									AND ce.source_entity = 'src_online_transactions'
LEFT JOIN bl_3nf.ce_channels cc2 ON sot.channel_id = cc2.channel_src_id
									AND cc2.source_system = 'src_online'
									AND cc2.source_entity = 'src_online_transactions'
LEFT JOIN bl_3nf.ce_products cp2 ON sot.productno = cp2.product_src_id
									AND cp2.source_system = 'src_online'
									AND cp2.source_entity = 'src_online_transactions'




UNION

SELECT DISTINCT COALESCE(cp.promotion_id, -1) AS promotion_id,
				COALESCE(cc.customer_id, -1) AS customer_id,
				COALESCE(cs.shop_id, -1) AS shop_id,
				COALESCE(ce.employee_id, -1) AS employee_id,
				COALESCE(cc2.channel_id, -1) AS channel_id,
				COALESCE(cp2.product_id, -1) AS product_id,
				sot.costs::NUMERIC AS cots,
				sot.price::NUMERIC AS price,
				COALESCE(sot.transactionno, 'N/A') AS transaction_no,
				COALESCE(sot.transaction_id, 'N/A') AS transaction_id,
				sot.quantity::INTEGER AS quantity,
				COALESCE(sot.date_of_tr::DATE, '19000101'::DATE) AS date_of_transaction,
				NOW(),
				NOW()
				
FROM bl_cl.offline_sales_load sot
LEFT JOIN bl_3nf.ce_promotions_scd2 cp ON sot.promotion_id = cp.promotion_src_id
									AND cp.source_system = 'src_offline'
									AND cp.source_entity = 'src_offline_transactions'
									AND cp.end_dt >=  sot.date_of_tr::DATE
									AND cp.is_active = TRUE
LEFT JOIN bl_3nf.ce_customers cc ON sot.customerno = cc.customer_src_id
									AND cc.source_system = 'src_offline'
									AND cc.source_entity = 'src_offline_transactions'
LEFT JOIN bl_3nf.ce_shops cs ON sot.shopno = cs.shop_src_id
									AND cs.source_system = 'src_offline'
									AND cs.source_entity = 'src_offline_transactions'
LEFT JOIN bl_3nf.ce_employees ce ON sot.employee_id = ce.employee_src_id
									AND ce.source_system = 'src_offline'
									AND ce.source_entity = 'src_offline_transactions'
LEFT JOIN bl_3nf.ce_channels cc2 ON sot.channel_id = cc2.channel_src_id
									AND cc2.source_system = 'src_offline'
									AND cc2.source_entity = 'src_offline_transactions'
LEFT JOIN bl_3nf.ce_products cp2 ON sot.productno = cp2.product_src_id
									AND cp2.source_system = 'src_offline'
									AND cp2.source_entity = 'src_offline_transactions';



UPDATE bl_cl.PRM_MTA_INCREMENTAL_LOAD
SET previouse_loaded_date = NOW()
WHERE upper(target_table) = 'CE_TRANSACTIONS';


PERFORM * FROM bl_cl.add_log (current_user::VARCHAR, NOW()::TIMESTAMP, 'ce_transactions'::VARCHAR, flag::VARCHAR);


    GET DIAGNOSTICS diag_row_count = row_count;
EXCEPTION
    WHEN OTHERS THEN
        flag = 'E';
        GET STACKED DIAGNOSTICS
            error_message = MESSAGE_TEXT;
			PERFORM * FROM bl_cl.add_log (current_user::VARCHAR, NOW()::TIMESTAMP, 'ce_transactions'::VARCHAR, flag::VARCHAR, error_message::VARCHAR);
        COMMIT;


END;
$add_ce_transactions$;






