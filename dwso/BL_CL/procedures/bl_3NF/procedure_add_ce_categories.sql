CREATE OR REPLACE PROCEDURE bl_cl.add_ce_categories()

    LANGUAGE plpgsql
AS
$add_ce_categories$
DECLARE
    diag_row_count int;
    flag           varchar(4);
    error_message  text;
    error_detail   text;

BEGIN
    flag = 'I';



MERGE INTO bl_3nf.ce_categories

USING(

SELECT DISTINCT COALESCE(sot.Product_Category_id, '-1') AS category_id,
				'src_online' AS source_system,
				'src_online_transactions' AS source_entity,
				COALESCE(sot.Product_Category, '-1') AS category_name,
				CURRENT_DATE AS update_dt,
				CURRENT_DATE AS insert_dt
				
FROM online.src_online_transactions sot
LEFT JOIN bl_3nf.ce_categories cc ON sot.product_category_id = cc.category_src_id
								AND cc.source_system = 'src_online'
								AND cc.source_entity = 'src_online_transactions'
WHERE cc.category_id IS NULL

UNION

SELECT DISTINCT COALESCE(sot.Product_Category_id, '-1') AS category_id,
				'src_offline' AS source_system,
				'src_offline_transactions' AS source_entity,
				COALESCE(sot.Product_Category, '-1') AS category_name,
				CURRENT_DATE AS update_dt,
				CURRENT_DATE AS insert_dt
				
FROM offline.src_offline_transactions sot
LEFT JOIN bl_3nf.ce_categories cc ON sot.product_category_id = cc.category_src_id
								AND cc.source_system = 'src_offline'
								AND cc.source_entity = 'src_offline_transactions'
WHERE cc.category_id IS NULL) cat
			ON bl_3nf.ce_categories.category_src_id = cat.category_id
			AND bl_3nf.ce_categories.source_system = cat.source_system
			AND bl_3nf.ce_categories.source_entity = cat.source_entity

WHEN MATCHED THEN
					UPDATE SET  category_name = cat.category_name,
								update_dt = NOW()

			
WHEN NOT MATCHED THEN

INSERT (category_id,
		category_src_id,
		source_system,
		source_entity,
		category_name,
		update_dt,
		insert_dt)
		
VALUES (NEXTVAL('bl_3nf.ce_categories_seq'),
		cat.category_id,
		cat.source_system,
		cat.source_entity,
		cat.category_name,
		NOW(),
		NOW());

INSERT INTO bl_3nf.ce_categories (category_id, category_src_id, source_system, source_entity, category_name, update_dt, insert_dt)

VALUES (-1, '-1', '-1', '-1','N/A', '18000101'::DATE, '18000101'::DATE)

ON CONFLICT (category_id) DO NOTHING;

PERFORM * FROM bl_cl.add_log (current_user::VARCHAR, NOW()::TIMESTAMP, 'ce_categories'::VARCHAR, flag::VARCHAR);

    GET DIAGNOSTICS diag_row_count = row_count;
EXCEPTION
    WHEN OTHERS THEN
        flag = 'E';
        GET STACKED DIAGNOSTICS
            error_message = MESSAGE_TEXT;
			PERFORM * FROM bl_cl.add_log (current_user::VARCHAR, NOW()::TIMESTAMP, 'ce_categories'::VARCHAR, flag::VARCHAR, error_message::VARCHAR);
        COMMIT;


END;
$add_ce_categories$;





