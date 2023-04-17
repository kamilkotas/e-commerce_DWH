CREATE OR REPLACE PROCEDURE bl_cl.add_dim_employees()

    LANGUAGE plpgsql
AS
$add_dim_employees$
DECLARE
    diag_row_count int;
    flag           varchar(4);
    error_message  text;

BEGIN
    flag = 'I';

MERGE INTO bl_dm.dim_employees em
USING (SELECT DISTINCT 	COALESCE(emp1.employee_id, -1)::VARCHAR AS employee_id,
						emp1.source_system AS source_system,
						emp1.source_entity AS source_entity,
						COALESCE(emp1.employee_name, 'N/A') AS employee_name,
						COALESCE(emp1.employee_surname, 'N/A') AS employee_surname,
						COALESCE(emp1.employee_phone, 'N/A') AS employee_phone,
						COALESCE(emp1.employee_email, 'N/A') AS employee_email,
						COALESCE(cou.country_id, '-1') AS country_id,
						COALESCE(cou.country_name, 'N/A') AS country_name,
						COALESCE(cit.city_id, '-1') AS city_id,
						COALESCE(cit.city_name, 'N/A') AS city_name,
						COALESCE(pc.postal_code_id, '-1') AS postal_code_id,
						COALESCE(pc.postal_code, 'NA') AS postal_code,
						COALESCE(s.street_id, '-1') AS street_id,
						COALESCE(s.street_name, 'N/A') AS street_name,
						COALESCE(emp1.address_id, '-1') AS address_id,
						COALESCE(a.address_apartment, 'N/A') AS address_apartment ,
						COALESCE(a.address_home_number, 'N/A') AS address_home_number
		FROM bl_3nf.ce_employees emp1
		INNER JOIN bl_3nf.ce_addresses a ON emp1.address_id = a.address_id
		INNER JOIN bl_3nf.ce_streets s ON a.street_id = s.street_id
		INNER JOIN bl_3nf.ce_postal_codes pc ON s.postal_code_id = pc.postal_code_id
		INNER JOIN bl_3nf.ce_cities cit ON pc.city_id = cit.city_id
		INNER JOIN bl_3nf.ce_countries cou ON cit.country_id = cou.country_id) emp
		
		ON em.employees_src_id = emp.employee_id
		AND em.source_system = emp.source_system
		AND em.source_entity = emp.source_entity

		
WHEN MATCHED THEN
	UPDATE SET  source_system = emp.source_system,
				source_entity = emp.source_entity,
				employee_name = emp.employee_name,
				employee_surname = emp.employee_surname,
				employee_phone = emp.employee_phone,
				employee_email = emp.employee_email,
				employee_country_id = emp.employee_id,
				employee_country_name = emp.employee_name,
				employee_city_id = emp.city_id,
				employee_city_name = emp.city_name,
				employee_postal_code_id = emp.postal_code_id,
				employee_postal_code = emp.postal_code,
				employee_street_id = emp.street_id,
				employee_street_name = emp.street_name,
				employee_address_id = emp.address_id,
				employee_apartment = emp.address_apartment,
				employee_address_number = emp.address_home_number,
				update_dt = NOW()

WHEN NOT MATCHED THEN

INSERT (employees_surr_id,
		employees_src_id,
		source_system, 
		source_entity, 
		employee_name, 
		employee_surname,
		employee_phone,
		employee_email, 
		employee_country_id,
		employee_country_name,
		employee_city_id,
		employee_city_name,
		employee_postal_code_id,
		employee_postal_code,
		employee_street_id,
		employee_street_name,
		employee_address_id,
		employee_apartment,
		employee_address_number,
		update_dt,
		insert_dt)

VALUES (NEXTVAL('bl_dm.DIM_EMPLOYEES_seq'),
		emp.employee_id,
		emp.source_system,
		emp.source_entity,
		emp.employee_name,
		emp.employee_surname,
		emp.employee_phone,
		emp.employee_email,
		emp.country_id,
		emp.country_name,
		emp.city_id,
		emp.city_name,
		emp.postal_code_id,
		emp.postal_code,
		emp.street_id,
		emp.street_name,
		emp.address_id,
		emp.address_apartment,
		emp.address_home_number,
		NOW(),
		NOW());



PERFORM * FROM bl_cl.add_log (current_user::VARCHAR, NOW()::TIMESTAMP, 'dim_employees'::VARCHAR, flag::VARCHAR);

    GET DIAGNOSTICS diag_row_count = row_count;
EXCEPTION
    WHEN OTHERS THEN
        flag = 'E';
        GET STACKED DIAGNOSTICS
            error_message = MESSAGE_TEXT;
			PERFORM * FROM bl_cl.add_log (current_user::VARCHAR, NOW()::TIMESTAMP, 'dim_employees'::VARCHAR, flag::VARCHAR, error_message::VARCHAR);
        COMMIT;


END;
$add_dim_employees$;


