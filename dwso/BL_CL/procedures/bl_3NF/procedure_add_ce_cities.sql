CREATE OR REPLACE PROCEDURE bl_cl.add_ce_cities()

    LANGUAGE plpgsql
AS
$add_ce_cities$
DECLARE
    diag_row_count int;
    flag           varchar(4);
    error_message  text;


BEGIN
    flag = 'I';


MERGE INTO bl_3nf.ce_cities
USING
	(SELECT DISTINCT COALESCE(customer_city_id, '-1') AS cities_src_id,
					'src_online' AS source_system,
					'src_online_transactions' AS source_entity,
					COALESCE(customer_city, '-1') AS city_name,
					COALESCE(cc.country_id, -1) AS country_id,
					NOW() AS UPDATE_DT,
					NOW() AS INSERT_DT
				
	
	FROM online.src_online_transactions o
	LEFT JOIN bl_3nf.ce_countries cc ON o.customer_country_id = cc.countries_src_id
										AND cc.source_system = 'src_online'
										AND cc.source_entity = 'src_online_transactions'
	LEFT JOIN bl_3nf.ce_cities cc2 ON o.customer_city_id = cc2.cities_src_id
										AND cc2.source_system = 'src_online'
										AND cc2.source_entity = 'src_online_transactions'
	WHERE cc2.city_id IS NULL
				
	UNION

	SELECT DISTINCT COALESCE(o.shop_city_id, '-1') AS cities_src_id,
					'src_online' AS source_system,
					'src_online_transactions' AS source_entity,
					COALESCE(o.shop_city, '-1') AS city_name,
					COALESCE(cc.country_id, -1) AS country_id,
					NOW() AS UPDATE_DT,
					NOW() AS INSERT_DT
				
	
	FROM online.src_online_transactions o
	LEFT JOIN bl_3nf.ce_countries cc ON o.shop_country_id = cc.countries_src_id
										AND cc.source_system = 'src_online'
										AND cc.source_entity = 'src_online_transactions'
	LEFT JOIN bl_3nf.ce_cities cc2 ON o.shop_city_id = cc2.cities_src_id
										AND cc2.source_system = 'src_online'
										AND cc2.source_entity = 'src_online_transactions'
	WHERE cc2.city_id IS NULL

	UNION

	SELECT DISTINCT COALESCE(o.employee_city_id, '-1') AS cities_src_id,
				'src_online' AS source_system,
				'src_online_transactions' AS source_entity,
				COALESCE(o.employee_city, '-1') AS city_name,
				COALESCE(cc.country_id, -1) AS country_id,
				NOW() AS UPDATE_DT,
				NOW() AS INSERT_DT
				
	
	FROM online.src_online_transactions o
	LEFT JOIN bl_3nf.ce_countries cc ON o.employee_country_id = cc.countries_src_id
										AND cc.source_system = 'src_online'
										AND cc.source_entity = 'src_online_transactions'
	LEFT JOIN bl_3nf.ce_cities cc2 ON o.employee_city_id = cc2.cities_src_id
										AND cc2.source_system = 'src_online'
										AND cc2.source_entity = 'src_online_transactions'
	WHERE cc2.city_id IS NULL
	
	UNION 
	
	SELECT DISTINCT COALESCE(customer_city_id, '-1') AS cities_src_id,
					'src_offline' AS source_system,
					'src_offline_transactions' AS source_entity,
					COALESCE(customer_city, '-1') AS city_name,
					COALESCE(cc.country_id, -1) AS country_id,
					NOW() AS UPDATE_DT,
					NOW() AS INSERT_DT
				
	
	FROM offline.src_offline_transactions o
	LEFT JOIN bl_3nf.ce_countries cc ON o.customer_country_id = cc.countries_src_id
										AND cc.source_system = 'src_offline'
										AND cc.source_entity = 'src_offline_transactions'
	LEFT JOIN bl_3nf.ce_cities cc2 ON o.customer_city_id = cc2.cities_src_id
										AND cc2.source_system = 'src_offline'
										AND cc2.source_entity = 'src_offline_transactions'
	WHERE cc2.city_id IS NULL
				
	UNION

	SELECT DISTINCT COALESCE(o.shop_city_id, '-1') AS cities_src_id,
					'src_offline' AS source_system,
					'src_offline_transactions' AS source_entity,
					COALESCE(o.shop_city, '-1') AS city_name,
					COALESCE(cc.country_id, -1) AS country_id,
					NOW() AS UPDATE_DT,
					NOW() AS INSERT_DT
				
	
	FROM offline.src_offline_transactions o
	LEFT JOIN bl_3nf.ce_countries cc ON o.shop_country_id = cc.countries_src_id
										AND cc.source_system = 'src_offline'
										AND cc.source_entity = 'src_offline_transactions'
	LEFT JOIN bl_3nf.ce_cities cc2 ON o.shop_city_id = cc2.cities_src_id
										AND cc2.source_system = 'src_offline'
										AND cc2.source_entity = 'src_offline_transactions'
	WHERE cc2.city_id IS NULL

	UNION

	SELECT DISTINCT COALESCE(o.employee_city_id, '-1') AS cities_src_id,
				'src_offline' AS source_system,
				'src_offline_transactions' AS source_entity,
				COALESCE(o.employee_city, '-1') AS city_name,
				COALESCE(cc.country_id, -1) AS country_id,
				NOW() AS UPDATE_DT,
				NOW() AS INSERT_DT
				
	
	FROM offline.src_offline_transactions o
	INNER JOIN bl_3nf.ce_countries cc ON o.employee_country_id = cc.countries_src_id
										AND cc.source_system = 'src_offline'
										AND cc.source_entity = 'src_offline_transactions'
	LEFT OUTER JOIN bl_3nf.ce_cities cc2 ON o.employee_city_id = cc2.cities_src_id
										AND cc2.source_system = 'src_offline'
										AND cc2.source_entity = 'src_offline_transactions'
	WHERE cc2.city_id IS NULL
	) cit
	
		ON bl_3nf.ce_cities.cities_src_id = cit.cities_src_id
		AND bl_3nf.ce_cities.source_system = cit.source_system
		AND bl_3nf.ce_cities.source_entity = cit.source_entity
		AND bl_3nf.ce_cities.country_id = cit.country_id

		
WHEN MATCHED THEN
	UPDATE SET  city_name = cit.city_name,
				country_id = cit.country_id,
				update_dt = NOW()

WHEN NOT MATCHED THEN

INSERT (city_id,
		cities_src_id,
		source_system,
		source_entity,
		city_name,
		country_id,
		update_dt,
		insert_dt)

VALUES (NEXTVAL('bl_3nf.ce_cities_seq'), 
		cit.cities_src_id,
		cit.source_system,
		cit.source_entity,
		cit.city_name,
		cit.country_id,
		NOW(),
		NOW());

INSERT INTO bl_3nf.ce_cities (city_id, cities_src_id, source_system, source_entity, city_name, country_id, update_dt, insert_dt)

VALUES (-1, '-1', '-1', '-1', 'N/A', -1, '18000101'::DATE, '18000101'::DATE)

ON CONFLICT (city_id) DO NOTHING;

PERFORM * FROM bl_cl.add_log (current_user::VARCHAR, NOW()::TIMESTAMP, 'ce_cities'::VARCHAR, flag::VARCHAR);


    GET DIAGNOSTICS diag_row_count = row_count;
EXCEPTION
    WHEN OTHERS THEN
        flag = 'E';
        GET STACKED DIAGNOSTICS
            error_message = MESSAGE_TEXT;
       		PERFORM * FROM bl_cl.add_log (current_user::VARCHAR, NOW()::TIMESTAMP, 'ce_cities'::VARCHAR, flag::VARCHAR, error_message::VARCHAR);
        COMMIT;

END;
$add_ce_cities$;









