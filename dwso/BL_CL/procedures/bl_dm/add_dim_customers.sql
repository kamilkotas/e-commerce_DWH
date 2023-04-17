CREATE OR REPLACE PROCEDURE bl_cl.add_dim_customers()

    LANGUAGE plpgsql
AS
$add_dim_customers$
DECLARE
    diag_row_count int;
    flag           varchar(4);
    error_message  text;


BEGIN
    flag = 'I';

MERGE INTO bl_dm.dim_customers cus
USING (SELECT DISTINCT COALESCE(cus.customer_id, -1)::VARCHAR AS customer_id,
						cus.source_system AS source_system,
						cus.source_entity AS source_entity,
						COALESCE(cus.customer_name, 'N/A') AS customer_name,
						COALESCE(cus.customer_surname, 'N/A') AS customer_surname,
						COALESCE(cus.customer_phone, 'N/A') AS customer_phone,
						COALESCE(cus.customer_email, 'N/A') AS customer_email,
						COALESCE(cou.country_id, '-1') AS country_id,
						COALESCE(cou.country_name, 'N/A') AS country_name,
						COALESCE(cit.city_id, '-1') AS city_id,
						COALESCE(cit.city_name, 'N/A') AS city_name,
						COALESCE(pc.postal_code_id, '-1') AS postal_code_id,
						COALESCE(pc.postal_code, 'N/A') AS postal_code,
						COALESCE(s.street_id, '-1') AS street_id,
						COALESCE(s.street_name, 'N/A') AS street_name,
						COALESCE(cus.address_id, '-1') AS address_id,
						COALESCE(a.address_apartment, 'N/A') AS address_apartment,
						COALESCE(a.address_home_number, 'N/A') AS address_home_number
		FROM bl_3nf.ce_customers cus
		INNER JOIN bl_3nf.ce_addresses a ON cus.address_id = a.address_id
		INNER JOIN bl_3nf.ce_streets s ON a.street_id = s.street_id
		INNER JOIN bl_3nf.ce_postal_codes pc ON s.postal_code_id = pc.postal_code_id
		INNER JOIN bl_3nf.ce_cities cit ON pc.city_id = cit.city_id
		INNER JOIN bl_3nf.ce_countries cou ON cit.country_id = cou.country_id) custo
		
		ON cus.customers_src_id = custo.customer_id
		AND cus.source_system = custo.source_system
		AND cus.source_entity = custo.source_entity

		
WHEN MATCHED THEN
	UPDATE SET  source_system = custo.source_system,
				source_entity = custo.source_entity,
				customer_name = custo.customer_name,
				customer_surname = custo.customer_surname,
				customer_phone = custo.customer_phone,
				customer_email = custo.customer_email,
				customer_country_id = custo.country_id,
				customer_country_name = custo.country_name,
				customer_city_id = custo.city_id,
				customer_city_name = custo.city_name,
				customer_postal_code_id = custo.postal_code_id,
				customer_postal_code = custo.postal_code,
				customer_street_id = custo.street_id,
				customer_street_name = custo.street_name,
				customer_address_id = custo.address_id,
				customer_apartment = custo.address_apartment,
				customer_address_number = custo.address_home_number,
				update_dt = NOW()

WHEN NOT MATCHED THEN

INSERT (customers_surr_id,
		customers_src_id,
		source_system, 
		source_entity, 
		customer_name, 
		customer_surname,
		customer_phone,
		customer_email, 
		customer_country_id,
		customer_country_name,
		customer_city_id,
		customer_city_name,
		customer_postal_code_id,
		customer_postal_code,
		customer_street_id,
		customer_street_name,
		customer_address_id,
		customer_apartment,
		customer_address_number,
		update_dt,
		insert_dt)

VALUES (NEXTVAL('bl_dm.DIM_CUSTOMERS_seque'),
		custo.customer_id,
		custo.source_system,
		custo.source_entity,
		custo.customer_name,
		custo.customer_surname,
		custo.customer_phone,
		custo.customer_email,
		custo.country_id,
		custo.country_name,
		custo.city_id,
		custo.city_name,
		custo.postal_code_id,
		custo.postal_code,
		custo.street_id,
		custo.street_name,
		custo.address_id,
		custo.address_apartment,
		custo.address_home_number,
		NOW(),
		NOW());



PERFORM * FROM bl_cl.add_log (current_user::VARCHAR, NOW()::TIMESTAMP, 'dim_customers'::VARCHAR, flag::VARCHAR);

    GET DIAGNOSTICS diag_row_count = row_count;
EXCEPTION
    WHEN OTHERS THEN
        flag = 'E';
        GET STACKED DIAGNOSTICS
            error_message = MESSAGE_TEXT;
			PERFORM * FROM bl_cl.add_log (current_user::VARCHAR, NOW()::TIMESTAMP, 'dim_customers'::VARCHAR, flag::VARCHAR, error_message::VARCHAR);
        COMMIT;


END;
$add_dim_customers$;


