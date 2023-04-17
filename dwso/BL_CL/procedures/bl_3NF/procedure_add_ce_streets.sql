CREATE OR REPLACE PROCEDURE bl_cl.add_ce_streets()

    LANGUAGE plpgsql
AS
$add_ce_streets$
DECLARE
    diag_row_count int;
    flag           varchar(4);
    error_message  text;


BEGIN
    flag = 'I';

MERGE INTO bl_3nf.ce_streets 

USING
(
SELECT DISTINCT COALESCE(o.customer_street_id, '-1') AS street_id,
				'src_online' AS source_system,
				'src_online_transactions' AS source_entity,
				COALESCE(o.customer_street_name, 'N/A') AS street_name,
				COALESCE(pc.postal_code_id, -1) AS postal_code_id,
				NOW() AS update_dt,
				NOW() AS insert_dt
				
FROM online.src_online_transactions o
LEFT JOIN bl_3nf.ce_postal_codes pc ON o.customer_postal_code = pc.postal_codes_src_id
								AND pc.source_system = 'src_online'
								AND pc.source_entity = 'src_online_transactions'
LEFT JOIN bl_3nf.ce_streets cs ON o.customer_street_id = cs.street_src_id
								AND cs.source_system = 'src_online'
								AND cs.source_entity = 'src_online_transactions'
WHERE cs.street_id IS NULL


UNION

SELECT DISTINCT COALESCE(o.shop_street_id, '-1') AS street_id,
				'src_online' AS source_system,
				'src_online_transactions' AS source_entity,
				COALESCE(o.shop_street_name, 'N/A') AS street_name,
				COALESCE(pc.postal_code_id, -1) AS postal_code_id, 
				NOW() AS update_dt,
				NOW() AS insert_dt
				
FROM online.src_online_transactions o
LEFT JOIN bl_3nf.ce_postal_codes pc ON o.shop_postal_code = pc.postal_codes_src_id
								AND pc.source_system = 'src_online'
								AND pc.source_entity = 'src_online_transactions'
LEFT JOIN bl_3nf.ce_streets cs ON o.shop_street_id = cs.street_src_id
								AND cs.source_system = 'src_online'
								AND cs.source_entity = 'src_online_transactions'
WHERE cs.street_id IS NULL

UNION

SELECT DISTINCT COALESCE(o.employee_street_id, '-1') AS street_id,
				'src_online' AS source_system,
				'src_online_transactions' AS source_entity,
				COALESCE(o.employee_street_name, 'N/A') AS street_name,
				COALESCE(pc.postal_code_id, -1) AS postal_code_id,
				NOW() AS update_dt,
				NOW() AS insert_dt
				
FROM online.src_online_transactions o
LEFT JOIN bl_3nf.ce_postal_codes pc ON o.employee_postal_code_id = pc.postal_codes_src_id
								AND pc.source_system = 'src_online'
								AND pc.source_entity = 'src_online_transactions'
LEFT JOIN bl_3nf.ce_streets cs ON o.employee_street_id = cs.street_src_id
								AND cs.source_system = 'src_online'
								AND cs.source_entity = 'src_online_transactions'
WHERE cs.street_id IS NULL

UNION 

SELECT DISTINCT COALESCE(o.customer_street_id, '-1') AS street_id,
				'src_offline' AS source_system,
				'src_offline_transactions' AS source_entity,
				COALESCE(o.customer_street_name, 'N/A') AS street_name,
				COALESCE(pc.postal_code_id, -1) AS postal_code_id,
				NOW() AS update_dt,
				NOW() AS insert_dt
				
FROM offline.src_offline_transactions o
LEFT JOIN bl_3nf.ce_postal_codes pc ON o.customer_postal_code = pc.postal_codes_src_id
								AND pc.source_system = 'src_offline'
								AND pc.source_entity = 'src_offline_transactions'
LEFT JOIN bl_3nf.ce_streets cs ON o.customer_street_id = cs.street_src_id
								AND cs.source_system = 'src_offline'
								AND cs.source_entity = 'src_offline_transactions'
WHERE cs.street_id IS NULL


UNION

SELECT DISTINCT COALESCE(o.shop_street_id, '-1') AS street_id,
				'src_offline' AS source_system,
				'src_offline_transactions' AS source_entity,
				COALESCE(o.shop_street_name, 'N/A') AS street_name,
				COALESCE(pc.postal_code_id, -1) AS postal_code_id, 
				NOW() AS update_dt,
				NOW() AS insert_dt
				
FROM offline.src_offline_transactions o
LEFT JOIN bl_3nf.ce_postal_codes pc ON o.shop_postal_code = pc.postal_codes_src_id
								AND pc.source_system = 'src_offline'
								AND pc.source_entity = 'src_offline_transactions'
LEFT JOIN bl_3nf.ce_streets cs ON o.shop_street_id = cs.street_src_id
								AND cs.source_system = 'src_offline'
								AND cs.source_entity = 'src_offline_transactions'
WHERE cs.street_id IS NULL

UNION

SELECT DISTINCT COALESCE(o.employee_street_id, '-1') AS street_id,
				'src_offline' AS source_system,
				'src_offline_transactions' AS source_entity,
				COALESCE(o.employee_street_name, 'N/A') AS street_name,
				COALESCE(pc.postal_code_id, -1) AS postal_code_id,
				NOW() AS update_dt,
				NOW() AS insert_dt
				
FROM offline.src_offline_transactions o
LEFT JOIN bl_3nf.ce_postal_codes pc ON o.employee_postal_code_id = pc.postal_codes_src_id
								AND pc.source_system = 'src_offline'
								AND pc.source_entity = 'src_offline_transactions'
LEFT JOIN bl_3nf.ce_streets cs ON o.employee_street_id = cs.street_src_id
								AND cs.source_system = 'src_offline'
								AND cs.source_entity = 'src_offline_transactions'
WHERE cs.street_id IS NULL) street

		ON bl_3nf.ce_streets.street_src_id = street.street_id
		AND bl_3nf.ce_streets.source_system = street.source_system
		AND bl_3nf.ce_streets.source_entity = street.source_entity
		AND bl_3nf.ce_streets.postal_code_id = street.postal_code_id
		
WHEN MATCHED THEN
	UPDATE SET	street_name = street.street_name,
				postal_code_id = street.postal_code_id,
				update_dt = NOW()
				
WHEN NOT MATCHED THEN


INSERT (street_id,
		street_src_id,
		source_system,
		source_entity,
		street_name,
		postal_code_id,
		update_dt,
		insert_dt)
									
VALUES (NEXTVAL('bl_3nf.ce_streets_seq'),
		street.street_id,
		street.source_system,
		street.source_entity,
		street.street_name,
		street.postal_code_id,
		NOW(),
		NOW());

INSERT INTO bl_3nf.ce_streets (street_id, street_src_id, source_system, source_entity, street_name, postal_code_id, update_dt, insert_dt)

VALUES (-1, '-1', 'N/A', 'N/A', 'N/A', -1, '18000101'::DATE, '18000101'::DATE)

ON CONFLICT (street_id) DO NOTHING;


PERFORM * FROM bl_cl.add_log (current_user::VARCHAR, NOW()::TIMESTAMP, 'ce_streets'::VARCHAR, flag::VARCHAR);


    GET DIAGNOSTICS diag_row_count = row_count;
EXCEPTION
    WHEN OTHERS THEN
        flag = 'E';
        GET STACKED DIAGNOSTICS
            error_message = MESSAGE_TEXT;
			PERFORM * FROM bl_cl.add_log (current_user::VARCHAR, NOW()::TIMESTAMP, 'ce_streets'::VARCHAR, flag::VARCHAR, error_message::VARCHAR);
        COMMIT;


END;
$add_ce_streets$;





