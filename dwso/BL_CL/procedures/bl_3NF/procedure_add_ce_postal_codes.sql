CREATE OR REPLACE PROCEDURE bl_cl.add_ce_postal_codes()

    LANGUAGE plpgsql
AS
$add_ce_postal_codes$
DECLARE
    diag_row_count int;
    flag           varchar(4);
    error_message  text;


BEGIN
    flag = 'I';
   
MERGE INTO bl_3nf.ce_postal_codes

USING
(SELECT DISTINCT COALESCE(o.customer_postal_code_id, '-1') AS postal_code_id,
				'src_online' AS source_system,
				'src_online_transactions' AS source_entity,
				COALESCE(o.customer_postal_code, 'N/A') AS postal_code,
				COALESCE(cc.city_id, -1) AS city_id,
				NOW() AS update_dt,
				NOW() AS insert_dt 
				
FROM online.src_online_transactions o
LEFT JOIN bl_3nf.ce_cities cc ON o.customer_city_id = cc.cities_src_id 
								AND cc.source_system = 'src_online'
								AND cc.source_entity = 'src_online_transactions'
LEFT JOIN bl_3nf.ce_postal_codes cpc ON o.customer_postal_code_id = cpc.postal_codes_src_id
								AND cpc.source_system = 'src_online'
								AND cpc.source_entity = 'src_online_transactions'
WHERE cpc.postal_code_id IS NULL

UNION

SELECT DISTINCT COALESCE(o.shop_postal_code_id, '-1') AS postal_code_id,
				'src_online' AS source_system,
				'src_online_transactions' AS source_entity,
				COALESCE(o.shop_postal_code, 'N/A') AS postal_code,
				COALESCE(cc.city_id, -1) AS city_id,
				NOW() AS update_dt,
				NOW() AS insert_dt 
				
FROM online.src_online_transactions o
INNER JOIN bl_3nf.ce_cities cc ON o.shop_city_id = cc.cities_src_id
								AND cc.source_system = 'src_online'
								AND cc.source_entity = 'src_online_transactions'
LEFT OUTER JOIN bl_3nf.ce_postal_codes cpc ON o.shop_postal_code_id = cpc.postal_codes_src_id
								AND cpc.source_system = 'src_online'
								AND cpc.source_entity = 'src_online_transactions'
WHERE cpc.postal_code_id IS NULL

UNION

SELECT DISTINCT COALESCE(o.employee_postal_code_id, '-1') AS postal_code_id,
				'src_online' AS source_system,
				'src_online_transactions' AS source_entity,
				COALESCE(o.employee_postal_code, '-1') AS postal_code,
				COALESCE(cc.city_id, -1) AS city_id,
				NOW() AS update_dt,
				NOW() AS insert_dt
				
FROM online.src_online_transactions o
INNER JOIN bl_3nf.ce_cities cc ON o.employee_city_id = cc.cities_src_id
								AND cc.source_system = 'src_online'
								AND cc.source_entity = 'src_online_transactions'
LEFT OUTER JOIN bl_3nf.ce_postal_codes cpc ON o.employee_postal_code_id = cpc.postal_codes_src_id
								AND cpc.source_system = 'src_online'
								AND cpc.source_entity = 'src_online_transactions'
WHERE cpc.postal_code_id IS NULL

UNION

SELECT DISTINCT COALESCE(o.customer_postal_code_id, '-1') AS postal_code_id,
				'src_offline' AS source_system,
				'src_offline_transactions' AS source_entity,
				COALESCE(o.customer_postal_code, 'N/A') AS postal_code,
				COALESCE(cc.city_id, -1) AS city_id,
				NOW() AS update_dt,
				NOW() AS insert_dt 
				
FROM offline.src_offline_transactions o
LEFT JOIN bl_3nf.ce_cities cc ON o.customer_city_id = cc.cities_src_id 
								AND cc.source_system = 'src_offline'
								AND cc.source_entity = 'src_offline_transactions'
LEFT JOIN bl_3nf.ce_postal_codes cpc ON o.customer_postal_code_id = cpc.postal_codes_src_id
								AND cpc.source_system = 'src_offline'
								AND cpc.source_entity = 'src_offline_transactions'
WHERE cpc.postal_code_id IS NULL

UNION

SELECT DISTINCT COALESCE(o.shop_postal_code_id, '-1') AS postal_code_id,
				'src_offline' AS source_system,
				'src_offline_transactions' AS source_entity,
				COALESCE(o.shop_postal_code, 'N/A') AS postal_code,
				COALESCE(cc.city_id, -1) AS city_id,
				NOW() AS update_dt,
				NOW() AS insert_dt 
				
FROM offline.src_offline_transactions o
INNER JOIN bl_3nf.ce_cities cc ON o.shop_city_id = cc.cities_src_id
								AND cc.source_system = 'src_offline'
								AND cc.source_entity = 'src_offline_transactions'
LEFT OUTER JOIN bl_3nf.ce_postal_codes cpc ON o.shop_postal_code_id = cpc.postal_codes_src_id
								AND cpc.source_system = 'src_offline'
								AND cpc.source_entity = 'src_offline_transactions'
WHERE cpc.postal_code_id IS NULL

UNION

SELECT DISTINCT COALESCE(o.employee_postal_code_id, '-1') AS postal_code_id,
				'src_offline' AS source_system,
				'src_offline_transactions' AS source_entity,
				COALESCE(o.employee_postal_code, '-1') AS postal_code,
				COALESCE(cc.city_id, -1) AS city_id,
				NOW() AS update_dt,
				NOW() AS insert_dt
				
FROM offline.src_offline_transactions o
LEFT JOIN bl_3nf.ce_cities cc ON o.employee_city_id = cc.cities_src_id
								AND cc.source_system = 'src_offline'
								AND cc.source_entity = 'src_offline_transactions'
LEFT JOIN bl_3nf.ce_postal_codes cpc ON o.employee_postal_code_id = cpc.postal_codes_src_id
								AND cpc.source_system = 'src_offline'
								AND cpc.source_entity = 'src_offline_transactions'
WHERE cpc.postal_code_id IS NULL) post_code

		ON bl_3nf.ce_postal_codes.postal_codes_src_id = post_code.postal_code_id
		AND bl_3nf.ce_postal_codes.source_system = post_code.source_system
		AND bl_3nf.ce_postal_codes.source_entity = post_code.source_entity
		AND bl_3nf.ce_postal_codes.city_id = post_code.city_id
		
WHEN MATCHED THEN
	UPDATE SET	postal_code = post_code.postal_code,
				city_id = post_code.city_id,
				update_dt = NOW()
				
WHEN NOT MATCHED THEN


INSERT (postal_code_id,
		postal_codes_src_id,
		source_system,
		source_entity,
		postal_code,
		city_id,
		update_dt,
		insert_dt)
									
VALUES (NEXTVAL('bl_3nf.ce_postal_codes_seq'),
		post_code.postal_code_id,
		post_code.source_system,
		post_code.source_entity,
		post_code.postal_code,
		post_code.city_id,
		NOW(),
		NOW());

INSERT INTO bl_3nf.ce_postal_codes (postal_code_id, postal_codes_src_id, source_system, source_entity, postal_code, city_id,update_dt, insert_dt)

VALUES (-1, '-1', '-1', '-1', 'N/A', -1, '18000101'::DATE, '18000101'::DATE)

ON CONFLICT (postal_code_id) DO NOTHING;


PERFORM * FROM bl_cl.add_log (current_user::VARCHAR, NOW()::TIMESTAMP, 'ce_postal_codes'::VARCHAR, flag::VARCHAR);


    GET DIAGNOSTICS diag_row_count = row_count;
EXCEPTION
    WHEN OTHERS THEN
        flag = 'E';
        GET STACKED DIAGNOSTICS
            error_message = MESSAGE_TEXT;
			PERFORM * FROM bl_cl.add_log (current_user::VARCHAR, NOW()::TIMESTAMP, 'ce_postal_codes'::VARCHAR, flag::VARCHAR, error_message::VARCHAR);
        COMMIT;


END;
$add_ce_postal_codes$;





