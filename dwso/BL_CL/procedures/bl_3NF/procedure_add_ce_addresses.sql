CREATE OR REPLACE PROCEDURE bl_cl.add_ce_addresses()

    LANGUAGE plpgsql
AS
$add_ce_addresses$
DECLARE
    diag_row_count int;
    flag           varchar(4);
    error_message  text;


BEGIN
    flag = 'I';

MERGE INTO bl_3nf.ce_addresses

USING(
SELECT DISTINCT COALESCE(sot.customer_address_id, '-1') AS address_src_id,
				'src_online' AS source_system,
				'src_online_transactions' AS source_entity,
				COALESCE(sot.customer_home_number, 'N/A') AS address_home_number,
				COALESCE(sot.customer_address_apartment, 'N/A') AS address_apartment,
				COALESCE(cs.street_id, -1) AS street_id,
				NOW() AS update_dt,
				NOW() AS insert_dt
				
FROM online.src_online_transactions sot
LEFT JOIN bl_3nf.ce_streets cs ON sot.customer_street_id = cs.street_src_id
								AND cs.source_system = 'src_online'
								AND cs.source_entity = 'src_online_transactions'
LEFT JOIN bl_3nf.ce_addresses ca ON sot.customer_address_id = ca.address_src_id
								AND ca.source_system = 'src_online'
								AND ca.source_entity = 'src_online_transactions'
WHERE ca.address_id IS NULL

UNION

SELECT DISTINCT COALESCE(sot.shop_address_id, '-1') AS address_src_id,
				'src_online' AS source_system,
				'src_online_transactions' AS source_entity,
				COALESCE(sot.shop_address_number, 'N/A') AS address_home_number,
				COALESCE(sot.shop_address_apartment, 'N/A') AS address_apartment,
				COALESCE(cs.street_id, -1) AS street_id,
				NOW() AS update_dt,
				NOW() AS insert_dt
				
FROM online.src_online_transactions sot
LEFT JOIN bl_3nf.ce_streets cs ON sot.customer_street_id = cs.street_src_id
								AND cs.source_system = 'src_online'
								AND cs.source_entity = 'src_online_transactions'
LEFT JOIN bl_3nf.ce_addresses ca ON sot.customer_address_id = ca.address_src_id
								AND ca.source_system = 'src_online'
								AND ca.source_entity = 'src_online_transactions'
WHERE ca.address_id IS NULL

UNION

SELECT DISTINCT COALESCE(sot.employee_address_id, '-1') AS address_src_id,
				'src_online' AS source_system,
				'src_online_transactions' AS source_entity,
				COALESCE(sot.employee_home_number, 'N/A') AS address_home_number,
				COALESCE(sot.employee_address_apartment, 'N/A') AS address_apartment,
				COALESCE(cs.street_id, -1) AS street_id,
				NOW() AS update_dt,
				NOW() AS insert_dt
				
FROM online.src_online_transactions sot
LEFT JOIN bl_3nf.ce_streets cs ON sot.customer_street_id = cs.street_src_id
								AND cs.source_system = 'src_online'
								AND cs.source_entity = 'src_online_transactions'
LEFT JOIN bl_3nf.ce_addresses ca ON sot.customer_address_id = ca.address_src_id
								AND ca.source_system = 'src_online'
								AND ca.source_entity = 'src_online_transactions'
WHERE ca.address_id IS NULL

UNION 

SELECT DISTINCT COALESCE(sot.customer_address_id, '-1') AS address_src_id,
				'src_offline' AS source_system,
				'src_offline_transactions' AS source_entity,
				COALESCE(sot.customer_home_number, 'N/A') AS address_home_number,
				COALESCE(sot.customer_address_apartment, 'N/A') AS address_apartment,
				COALESCE(cs.street_id, -1) AS street_id,
				NOW() AS update_dt,
				NOW() AS insert_dt
				
FROM offline.src_offline_transactions sot
LEFT JOIN bl_3nf.ce_streets cs ON sot.customer_street_id = cs.street_src_id
								AND cs.source_system = 'src_offline'
								AND cs.source_entity = 'src_offline_transactions'
LEFT JOIN bl_3nf.ce_addresses ca ON sot.customer_address_id = ca.address_src_id
								AND ca.source_system = 'src_offline'
								AND ca.source_entity = 'src_offline_transactions'
WHERE ca.address_id IS NULL

UNION

SELECT DISTINCT COALESCE(sot.shop_address_id, '-1') AS address_src_id,
				'src_offline' AS source_system,
				'src_offline_transactions' AS source_entity,
				COALESCE(sot.shop_address_number, 'N/A') AS address_home_number,
				COALESCE(sot.shop_address_apartment, 'N/A') AS address_apartment,
				COALESCE(cs.street_id, -1) AS street_id,
				NOW() AS update_dt,
				NOW() AS insert_dt
				
FROM offline.src_offline_transactions sot
LEFT JOIN bl_3nf.ce_streets cs ON sot.customer_street_id = cs.street_src_id
								AND cs.source_system = 'src_offline'
								AND cs.source_entity = 'src_offline_transactions'
LEFT JOIN bl_3nf.ce_addresses ca ON sot.customer_address_id = ca.address_src_id
								AND ca.source_system = 'src_offline'
								AND ca.source_entity = 'src_offline_transactions'
WHERE ca.address_id IS NULL

UNION

SELECT DISTINCT COALESCE(sot.employee_address_id, '-1') AS address_src_id,
				'src_offline' AS source_system,
				'src_offline_transactions' AS source_entity,
				COALESCE(sot.employee_home_number, 'N/A') AS address_home_number,
				COALESCE(sot.employee_address_apartment, 'N/A') AS address_apartment,
				COALESCE(cs.street_id, -1) AS street_id,
				NOW() AS update_dt,
				NOW() AS insert_dt
				
FROM offline.src_offline_transactions sot
LEFT JOIN bl_3nf.ce_streets cs ON sot.customer_street_id = cs.street_src_id
								AND cs.source_system = 'src_offline'
								AND cs.source_entity = 'src_offline_transactions'
LEFT JOIN bl_3nf.ce_addresses ca ON sot.customer_address_id = ca.address_src_id
								AND ca.source_system = 'src_offline'
								AND ca.source_entity = 'src_offline_transactions'
WHERE ca.address_id IS NULL) address

		ON bl_3nf.ce_addresses.address_src_id = address.address_src_id
		AND bl_3nf.ce_addresses.source_system = address.source_system
		AND bl_3nf.ce_addresses.source_entity = address.source_entity
		AND bl_3nf.ce_addresses.street_id = address.street_id
		
		WHEN MATCHED THEN
	UPDATE SET	address_home_number = address.address_home_number,
				address_apartment = address.address_apartment,
				street_id = address.street_id,
				update_dt = NOW()
				
WHEN NOT MATCHED THEN


INSERT (address_id,
		address_src_id,
		source_system,
		source_entity,
		address_home_number,
		address_apartment,
		street_id,
		update_dt,
		insert_dt)
									
VALUES (NEXTVAL('bl_3nf.ce_addresses_seq'), 
		address_src_id,
		address.source_system,
		address.source_entity,
		address.address_home_number,
		address.address_apartment,
		address.street_id,
		NOW(),
		NOW());

INSERT INTO bl_3nf.ce_addresses (address_id, address_src_id, source_system, source_entity, address_home_number, address_apartment, street_id, update_dt, insert_dt)

VALUES (-1, '-1', '-1', '-1', 'N/A', 'N/A', -1, '18000101'::DATE, '18000101'::DATE)
ON CONFLICT (address_id) DO NOTHING;


PERFORM * FROM bl_cl.add_log (current_user::VARCHAR, NOW()::TIMESTAMP, 'ce_addresses'::VARCHAR, flag::VARCHAR);


    GET DIAGNOSTICS diag_row_count = row_count;
EXCEPTION
    WHEN OTHERS THEN
        flag = 'E';
        GET STACKED DIAGNOSTICS
            error_message = MESSAGE_TEXT;
			PERFORM * FROM bl_cl.add_log (current_user::VARCHAR, NOW()::TIMESTAMP, 'ce_addresses'::VARCHAR, flag::VARCHAR, error_message::VARCHAR);
        COMMIT;


END;
$add_ce_addresses$;

CALL bl_cl.add_ce_addresses()
SELECT * FROM bl_cl.log_data_store lds 



