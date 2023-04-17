CREATE OR REPLACE PROCEDURE bl_cl.add_ce_employees()

    LANGUAGE plpgsql
AS
$add_ce_employees$
DECLARE
    diag_row_count int;
    flag           varchar(4);
    error_message  text;


BEGIN
    flag = 'I';


MERGE INTO bl_3nf.ce_employees
USING (
SELECT DISTINCT COALESCE(sot.employee_id, '-1') AS employee_id,
				'src_online' AS source_system,
				'src_online_transactions' AS source_entity,
				COALESCE(ca.address_id, -1) AS address_id,
				COALESCE(sot.employee_first_name, 'N/A') AS employee_first_name,
				COALESCE(sot.employee_last_name, 'N/A') AS employee_last_name,
				COALESCE(sot.employee_phone, 'N/A') AS employee_phone,
				COALESCE(sot.employee_email, 'N/A') AS employee_email,
				COALESCE(sot.employee_birth_date, 'N/A') AS employee_birth_date,
				CURRENT_DATE AS update_dt,
				CURRENT_DATE AS insert_dt
				
FROM online.src_online_transactions sot
LEFT JOIN bl_3nf.ce_addresses ca ON sot.employee_address_id = ca.address_src_id
								AND ca.source_system = 'src_online'
								AND ca.source_entity = 'src_online_transactions'
LEFT JOIN bl_3nf.ce_employees emp ON sot.employee_id = emp.employee_src_id
								AND emp.source_system = 'src_online'
								AND emp.source_entity = 'src_online_transactions'
WHERE emp.employee_id IS NULL

UNION 

SELECT DISTINCT COALESCE(sot.employee_id, '-1') AS employee_id,
				'src_offline' AS source_system,
				'src_offline_transactions' AS source_entity,
				COALESCE(ca.address_id, -1) AS address_id,
				COALESCE(sot.employee_first_name, 'N/A') AS employee_first_name,
				COALESCE(sot.employee_last_name, 'N/A') AS employee_last_name,
				COALESCE(sot.employee_phone, 'N/A') AS employee_phone,
				COALESCE(sot.employee_email, 'N/A') AS employee_email,
				COALESCE(sot.employee_birth_date, 'N/A') AS employee_birth_date,
				CURRENT_DATE AS update_dt,
				CURRENT_DATE AS insert_dt
				
FROM offline.src_offline_transactions sot
LEFT JOIN bl_3nf.ce_addresses ca ON sot.employee_address_id = ca.address_src_id
								AND ca.source_system = 'src_offline'
								AND ca.source_entity = 'src_offline_transactions'
LEFT JOIN bl_3nf.ce_employees emp ON sot.employee_id = emp.employee_src_id
								AND emp.source_system = 'src_offline'
								AND emp.source_entity = 'src_offline_transactions'
WHERE emp.employee_id IS NULL
) emplo

	ON bl_3nf.ce_employees.employee_src_id = emplo.employee_id
	AND bl_3nf.ce_employees.source_system = emplo.source_system
	AND bl_3nf.ce_employees.source_entity = emplo.source_entity
	AND bl_3nf.ce_employees.address_id = emplo.address_id
	
WHEN MATCHED THEN 

UPDATE SET 					address_id = emplo.address_id,
							employee_name = emplo.employee_first_name,
							employee_surname = emplo.employee_last_name,
							employee_phone = emplo.employee_phone,
							employee_email = emplo.employee_email, 
							employee_birth_date= emplo.employee_birth_date,
							update_dt = NOW()

WHEN NOT MATCHED THEN

INSERT (employee_id,
		employee_src_id,
		source_system,
		source_entity,
		address_id,
		employee_name,
		employee_surname,
		employee_phone,
		employee_email,
		employee_birth_date,
		update_dt,
		insert_dt)
		
VALUES (NEXTVAL('bl_3nf.ce_employees_seq'),
		emplo.employee_id,
		emplo.source_system,
		emplo.source_entity,
		emplo.address_id,
		emplo.employee_first_name,
		emplo.employee_last_name,
		emplo.employee_phone,
		emplo.employee_email,
		emplo.employee_birth_date,
		NOW(),
		NOW());

INSERT INTO bl_3nf.ce_employees (employee_id, employee_src_id, source_system, source_entity, address_id, employee_name, employee_surname, employee_phone, employee_email, employee_birth_date, update_dt, insert_dt)

VALUES (-1, '-1', '-1', '-1', -1, 'N/A', 'N/A', 'N/A', 'N/A', 'N/A', '18000101'::DATE, '18000101'::DATE)

ON CONFLICT (employee_id) DO NOTHING;

DELETE FROM
   bl_3nf.ce_employees a
        USING bl_3nf.ce_employees b
WHERE
    a.employee_id > b.employee_id
    AND a.employee_src_id = b.employee_src_id
    AND a.source_system = b.source_system;

PERFORM * FROM bl_cl.add_log (current_user::VARCHAR, NOW()::TIMESTAMP, 'ce_employees'::VARCHAR, flag::VARCHAR);

    GET DIAGNOSTICS diag_row_count = row_count;
EXCEPTION
    WHEN OTHERS THEN
        flag = 'E';
        GET STACKED DIAGNOSTICS
            error_message = MESSAGE_TEXT;
			PERFORM * FROM bl_cl.add_log (current_user::VARCHAR, NOW()::TIMESTAMP, 'ce_employees'::VARCHAR, flag::VARCHAR, error_message::VARCHAR);
		COMMIT;


END;
$add_ce_employees$;




