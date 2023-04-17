CREATE OR REPLACE PROCEDURE bl_cl.add_ce_customers()

    LANGUAGE plpgsql
AS
$add_ce_customers$
DECLARE
    diag_row_count int;
    flag           varchar(4);
    error_message  text;


BEGIN
    flag = 'I';


MERGE INTO bl_3nf.ce_customers

USING(
SELECT DISTINCT COALESCE(sot.customerno, '-1') AS customer_id,
				'src_online' AS source_system,
				'src_online_transactions' AS source_entity,
				COALESCE(ca.address_id, -1) AS address_id,
				COALESCE(sot.customer_name, '-1') AS customer_name,
				COALESCE(sot.customer_surname, '-1') AS customer_surname,
				COALESCE(sot.customer_phone, '-1') AS customer_phone,
				COALESCE(sot.customer_mail, '-1') AS customer_mail,
				COALESCE(sot.customer_birth_date, '-1') AS customer_birth_date,
				NOW() AS update_dt,
				NOW() AS insert_dt
				
FROM bl_cl._online_customers_load sot
LEFT JOIN bl_3nf.ce_addresses ca ON sot.customer_address_id = ca.address_src_id
								AND ca.source_system = 'src_online'
								AND ca.source_entity = 'src_online_transactions'
LEFT JOIN bl_3nf.ce_customers cus ON sot.customerno = cus.customer_src_id
								AND cus.source_system = 'src_online'
								AND cus.source_entity = 'src_online_transactions'
WHERE cus.customer_id IS NULL

UNION 

SELECT DISTINCT COALESCE(sot.customerno, '-1') AS customer_id,
				'src_offline' AS source_system,
				'src_offline_transactions' AS source_entity,
				COALESCE(ca.address_id, -1) AS address_id,
				COALESCE(sot.customer_name, 'N/A')AS customer_name,
				COALESCE(sot.customer_surname, 'N/A') AS customer_surname,
				COALESCE(sot.customer_phone, 'N/A') AS customer_phone,
				COALESCE(sot.customer_mail, 'N/A')AS customer_mail,
				COALESCE(sot.customer_birth_date, 'N/A') AS customer_birth_date,
				NOW() AS update_dt,
				NOW() AS insert_dt
				
FROM bl_cl.offline_customers_load sot
LEFT JOIN bl_3nf.ce_addresses ca ON sot.customer_address_id = ca.address_src_id
								AND ca.source_system = 'src_offline'
								AND ca.source_entity = 'src_offline_transactions'
LEFT JOIN bl_3nf.ce_customers cus ON sot.customerno = cus.customer_src_id
								AND cus.source_system = 'src_offline'
								AND cus.source_entity = 'src_offline_transactions'
WHERE cus.customer_id IS NULL) custo

		ON bl_3nf.ce_customers.customer_src_id = custo.customer_id
		AND bl_3nf.ce_customers.source_system = custo.source_system
		AND bl_3nf.ce_customers.source_entity = custo.source_entity
		AND bl_3nf.ce_customers.address_id = custo.address_id

WHEN MATCHED THEN
UPDATE SET 					address_id = custo.address_id,
							customer_name = custo.customer_name,
							customer_surname = custo.customer_surname,
							customer_phone = custo.customer_phone,
							customer_email = custo.customer_mail, 
							customer_birth_date= custo.customer_birth_date,
							update_dt = NOW()
		
WHEN NOT MATCHED THEN
		
INSERT (customer_id,
		customer_src_id,
		source_system,
		source_entity,
		address_id,
		customer_name,
		customer_surname,
		customer_phone,
		customer_email,
		customer_birth_date,
		update_dt,
		insert_dt)
		
VALUES (NEXTVAL('bl_3nf.ce_customers_seq'),
		custo.customer_id,
		custo.source_system,
		custo.source_entity,
		custo.address_id,
		custo.customer_name,
		custo.customer_surname,
		custo.customer_phone,
		custo.customer_mail,
		custo.customer_birth_date,
		NOW(),
		NOW());
	


INSERT INTO bl_3nf.ce_customers (customer_id, customer_src_id, source_system, source_entity, address_id, customer_name, customer_surname, customer_phone, customer_email, customer_birth_date, update_dt, insert_dt)

VALUES (-1, '-1', '-1', '-1', -1, 'N/A', 'N/A', 'N/A', 'N/A', 'N/A', '18000101'::DATE, '18000101'::DATE)

ON CONFLICT (customer_id) DO NOTHING;

UPDATE bl_cl.PRM_MTA_INCREMENTAL_LOAD
SET previouse_loaded_date = NOW()
WHERE upper(target_table) = 'CE_TRANSACTIONS';


PERFORM * FROM bl_cl.add_log (current_user::VARCHAR, NOW()::TIMESTAMP, 'ce_customers'::VARCHAR, flag::VARCHAR);




    GET DIAGNOSTICS diag_row_count = row_count;
EXCEPTION
    WHEN OTHERS THEN
        flag = 'E';
        GET STACKED DIAGNOSTICS
            error_message = MESSAGE_TEXT;
           
			PERFORM * FROM bl_cl.add_log (current_user::VARCHAR, NOW()::TIMESTAMP, 'ce_customers'::VARCHAR, flag::VARCHAR, error_message::VARCHAR);
		
        COMMIT;


END;
$add_ce_customers$;



