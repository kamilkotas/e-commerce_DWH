CREATE OR REPLACE PROCEDURE bl_cl.add_dim_shops()

    LANGUAGE plpgsql
AS
$add_dim_shops$
DECLARE
    diag_row_count int;
    flag           varchar(4);
    error_message  text;
    error_detail   text;

BEGIN
    flag = 'I';

MERGE INTO bl_dm.dim_shops sho
USING (SELECT DISTINCT COALESCE(s.shop_id, '-1')::VARCHAR AS shop_id,
						s.source_system AS source_system,
						s.source_entity AS source_entity,
						COALESCE(s.shop_name, 'N/A') AS shop_name,
						COALESCE(s.shop_phone, 'N/A') AS shop_phone,
						COALESCE(s.shop_email, 'N/A')AS shop_email,
						COALESCE(cou.country_id, '-1') AS country_id,
						COALESCE(cou.country_name, 'N/A') AS country_name,
						COALESCE(cit.city_id, '-1') AS city_id,
						COALESCE(cit.city_name, 'N/A')AS city_name,
						COALESCE(pc.postal_code_id, '-1') AS postal_code_id,
						COALESCE(pc.postal_code, 'N/A') AS postal_code,
						COALESCE(st.street_id, '-1') AS street_id,
						COALESCE(st.street_name, 'N/A') AS street_name,
						COALESCE(s.address_id, '-1') AS address_id,
						COALESCE(a.address_apartment, 'N/A') AS address_apartment,
						COALESCE(a.address_home_number, 'N/A') AS address_home_number
		FROM bl_3nf.ce_shops s
		INNER JOIN bl_3nf.ce_addresses a ON s.address_id = a.address_id
		INNER JOIN bl_3nf.ce_streets st ON a.street_id = st.street_id
		INNER JOIN bl_3nf.ce_postal_codes pc ON st.postal_code_id = pc.postal_code_id
		INNER JOIN bl_3nf.ce_cities cit ON pc.city_id = cit.city_id
		INNER JOIN bl_3nf.ce_countries cou ON cit.country_id = cou.country_id) shop
		
		ON sho.shops_src_id = shop.shop_id
		AND sho.source_system = shop.source_system
		AND sho.source_entity = shop.source_entity

		
WHEN MATCHED THEN
	UPDATE SET  source_system = shop.source_system,
				source_entity = shop.source_entity,
				shop_name = shop.shop_name,
				shop_phone = shop.shop_phone,
				shop_email = shop.shop_email,
				shop_country_id = shop.country_id,
				shop_country_name = shop.country_name,
				shop_city_id = shop.city_id,
				shop_city_name = shop.city_name,
				shop_postal_code_id = shop.postal_code_id,
				shop_postal_code = shop.postal_code,
				shop_street_id = shop.street_id,
				shop_street_name = shop.street_name,
				shop_address_id = shop.address_id,
				shop_apartment = shop.address_apartment,
				shop_address_number = shop.address_home_number,
				update_dt = NOW()

WHEN NOT MATCHED THEN

INSERT (shops_surr_id,
		shops_src_id,
		source_system, 
		source_entity, 
		shop_name, 
		shop_phone,
		shop_email, 
		shop_country_id,
		shop_country_name,
		shop_city_id,
		shop_city_name,
		shop_postal_code_id,
		shop_postal_code,
		shop_street_id,
		shop_street_name,
		shop_address_id,
		shop_apartment,
		shop_address_number,
		update_dt,
		insert_dt)

VALUES (NEXTVAL('bl_dm.dim_shops_seq'),
		shop.shop_id,
		shop.source_system,
		shop.source_entity,
		shop.shop_name,
		shop.shop_phone,
		shop.shop_email,
		shop.country_id,
		shop.country_name,
		shop.city_id,
		shop.city_name,
		shop.postal_code_id,
		shop.postal_code,
		shop.street_id,
		shop.street_name,
		shop.address_id,
		shop.address_apartment,
		shop.address_home_number,
		NOW(),
		NOW());



PERFORM * FROM bl_cl.add_log (current_user::VARCHAR, NOW()::TIMESTAMP, 'dim_shops'::VARCHAR, flag::VARCHAR);

    GET DIAGNOSTICS diag_row_count = row_count;
EXCEPTION
    WHEN OTHERS THEN
        flag = 'E';
        GET STACKED DIAGNOSTICS
            error_message = MESSAGE_TEXT;
			PERFORM * FROM bl_cl.add_log (current_user::VARCHAR, NOW()::TIMESTAMP, 'dim_shops'::VARCHAR, flag::VARCHAR, error_message::VARCHAR);
        COMMIT;


END;
$add_dim_shops$;





