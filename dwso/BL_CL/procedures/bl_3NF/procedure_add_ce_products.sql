CREATE OR REPLACE PROCEDURE bl_cl.add_ce_products()

    LANGUAGE plpgsql
AS
$add_ce_products$
DECLARE
    diag_row_count int;
    flag           varchar(4);
    error_message  text;
    error_detail   text;

BEGIN
    flag = 'I';


MERGE INTO bl_3nf.ce_products
USING(
SELECT DISTINCT COALESCE(sot.ProductNo, '-1') AS product_id,
				'src_online' AS source_system,
				'src_online_transactions' AS source_entity,
				COALESCE(cc.category_id, -1) AS category_id,
				COALESCE(sot.ProductName, 'N/A') AS product_name,
				COALESCE(sot.product_desc, 'N/A') AS product_desc,
				COALESCE(sot.product_year_of_production, 'N/A') AS product_year_of_production,
				COALESCE(sot.product_color, 'N/A') AS product_color,
				CURRENT_DATE AS update_dt,
				CURRENT_DATE AS insert_dt
				
FROM online.src_online_transactions sot
LEFT JOIN bl_3nf.ce_categories cc ON sot.product_category_id = cc.category_src_id
								AND cc.source_system = 'src_online'
								AND cc.source_entity = 'src_online_transactions'
LEFT JOIN bl_3nf.ce_products cp ON sot.productno = cp.product_src_id 
								AND cp.source_system = 'src_online'
								AND cp.source_entity = 'src_online_transactions'
WHERE cp.product_id IS NULL

UNION

SELECT DISTINCT COALESCE(sot.ProductNo, '-1') AS product_id,
				'src_offline' AS source_system,
				'src_offline_transactions' AS source_entity,
				COALESCE(cc.category_id, -1) AS category_id,
				COALESCE(sot.ProductName, 'N/A') AS product_name,
				COALESCE(sot.product_desc, 'N/A') AS product_desc,
				COALESCE(sot.product_year_of_production, 'N/A') AS product_year_of_production,
				COALESCE(sot.product_color, 'N/A') AS product_color,
				CURRENT_DATE AS update_dt,
				CURRENT_DATE AS insert_dt
				
FROM offline.src_offline_transactions sot
LEFT JOIN bl_3nf.ce_categories cc ON sot.product_category_id = cc.category_src_id
								AND cc.source_system = 'src_offline'
								AND cc.source_entity = 'src_offline_transactions'
LEFT JOIN bl_3nf.ce_products cp ON sot.productno = cp.product_src_id 
								AND cp.source_system = 'src_offline'
								AND cp.source_entity = 'src_offline_transactions'
WHERE cp.product_id IS NULL) product

						ON bl_3nf.ce_products.product_src_id = product.product_id
						AND bl_3nf.ce_products.source_system = product.source_system
						AND bl_3nf.ce_products.source_entity = product.source_entity
						AND bl_3nf.ce_products.category_id = product.category_id
WHEN MATCHED THEN 
				UPDATE SET category_id = product.category_id,
							product_name = product.product_name,
							product_desc = product.product_desc,
							product_pro_year = product.product_year_of_production,
							product_color =  product.product_color,
							update_dt = NOW()
WHEN NOT MATCHED THEN		

INSERT (product_id,
		product_src_id,
		source_system,
		source_entity,
		category_id,
		product_name,
		product_desc,
		product_pro_year,
		product_color,
		update_dt,
		insert_dt)
		
VALUES (NEXTVAL('bl_3nf.ce_products_seq'),
		product.product_id,
		product.source_system,
		product.source_entity,
		product.category_id,
		product.product_name,
		product.product_desc,
		product.product_year_of_production,
		product.product_color,
		NOW(),
		NOW());

INSERT INTO bl_3nf.ce_products (product_id, product_src_id, source_system, source_entity, category_id, product_name, product_desc, product_pro_year, product_color, update_dt, insert_dt)

VALUES (-1, '-1', '-1', '-1', -1, 'N/A', 'N/A', '9999', 'N/A', '18000101'::DATE, '18000101'::DATE)

ON CONFLICT (product_id) DO NOTHING;

PERFORM * FROM bl_cl.add_log (current_user::VARCHAR, NOW()::TIMESTAMP, 'ce_products'::VARCHAR, flag::VARCHAR);

    GET DIAGNOSTICS diag_row_count = row_count;
EXCEPTION
    WHEN OTHERS THEN
        flag = 'E';
        GET STACKED DIAGNOSTICS
            error_message = MESSAGE_TEXT;
			PERFORM * FROM bl_cl.add_log (current_user::VARCHAR, NOW()::TIMESTAMP, 'ce_products'::VARCHAR, flag::VARCHAR, error_message::VARCHAR);
        COMMIT;


END;
$add_ce_products$;




