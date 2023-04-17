

CREATE OR REPLACE PROCEDURE bl_cl.add_ce_countries()

    LANGUAGE plpgsql
AS
$add_ce_countries$
DECLARE
    diag_row_count int;
    flag           varchar(4);
    error_message  text;

BEGIN
    flag = 'I';

MERGE INTO bl_3nf.ce_countries 
USING (SELECT DISTINCT COALESCE(o.customer_country_id, '-1') AS countries_id,
				'src_online' AS source_system,
				'src_online_transactions' AS source_entity,
				COALESCE(o.customer_country_name, '-1') AS country_name,
				NOW() AS UPDATE_DT,
				NOW() AS INSERT_DT
	
FROM online.src_online_transactions o
LEFT JOIN  bl_3nf.ce_countries cou ON o.customer_country_id = cou.countries_src_id
									AND cou.source_system = 'src_online'
									AND cou.source_entity = 'src_online_transaction'
WHERE cou.country_id IS NULL

UNION 

SELECT DISTINCT COALESCE(o.employee_country_id, '-1') AS countries_id,
				'src_online' AS source_system,
				'src_online_transactions' AS source_entity,
				COALESCE(o.employee_country, '-1') AS country_name,
				NOW() AS UPDATE_DT,
				NOW() AS INSERT_DT
				
	
FROM online.src_online_transactions o
LEFT JOIN  bl_3nf.ce_countries cou ON o.employee_country_id = cou.countries_src_id
									AND cou.source_system = 'src_online'
									AND cou.source_entity = 'src_online_transaction'
WHERE cou.country_id IS NULL

UNION

SELECT DISTINCT COALESCE(o.shop_country_id, '-1') AS countries_id,
				'src_online' AS source_system,
				'src_online_transactions' AS source_entity,
				COALESCE(o.shop_country, '-1') AS country_name,
				NOW() AS UPDATE_DT,
				NOW() AS INSERT_DT
				
	
FROM online.src_online_transactions o
LEFT JOIN  bl_3nf.ce_countries cou ON o.employee_country_id = cou.countries_src_id
									AND cou.source_system = 'src_online'
									AND cou.source_entity = 'src_online_transaction'
WHERE cou.country_id IS NULL

UNION

SELECT DISTINCT COALESCE(o.customer_country_id, '-1') AS countries_id,
				'src_offline' AS source_system,
				'src_offline_transactions' AS source_entity,
				COALESCE(o.customer_country_name, '-1') AS country_name,
				NOW() AS UPDATE_DT,
				NOW() AS INSERT_DT
	
FROM offline.src_offline_transactions o
LEFT JOIN  bl_3nf.ce_countries cou ON o.customer_country_id = cou.countries_src_id
									AND cou.source_system = 'src_offline'
									AND cou.source_entity = 'src_offline_transactions'
WHERE cou.country_id IS NULL

UNION 

SELECT DISTINCT COALESCE(o.employee_country_id, '-1') AS countries_id,
				'src_offline' AS source_system,
				'src_offline_transactions' AS source_entity,
				COALESCE(o.employee_country, '-1') AS country_name,
				NOW() AS UPDATE_DT,
				NOW() AS INSERT_DT
				
	
FROM offline.src_offline_transactions o
LEFT JOIN  bl_3nf.ce_countries cou ON o.employee_country_id = cou.countries_src_id
									AND cou.source_system = 'src_offline'
									AND cou.source_entity = 'src_offline_transactions'
WHERE cou.country_id IS NULL

UNION

SELECT DISTINCT COALESCE(o.shop_country_id, '-1') AS countries_id,
				'src_offline' AS source_system,
				'src_offline_transactions' AS source_entity,
				COALESCE(o.shop_country, '-1') AS country_name,
				NOW() AS UPDATE_DT,
				NOW() AS INSERT_DT
				
	
FROM offline.src_offline_transactions o
LEFT JOIN  bl_3nf.ce_countries cou ON o.employee_country_id = cou.countries_src_id
									AND cou.source_system = 'src_offline'
									AND cou.source_entity = 'src_offline_transactions'
WHERE cou.country_id IS NULL
) cou1
		ON ce_countries.countries_src_id = cou1.countries_id
		AND ce_countries.source_system = cou1.source_system
		AND ce_countries.source_entity = cou1.source_entity

		
WHEN MATCHED THEN
	UPDATE SET  country_name = cou1.country_name,
				update_dt = NOW()

WHEN NOT MATCHED THEN

INSERT (country_id,
		countries_src_id,
		source_system,
		source_entity,
		country_name,
		update_dt,
		insert_dt)

VALUES (NEXTVAL('bl_3nf.ce_countries_seq'), 
		cou1.countries_id,
		cou1.source_system,
		cou1.source_entity,
		cou1.country_name,
		NOW(),
		NOW());

INSERT INTO bl_3nf.ce_countries (country_id, countries_src_id, source_system, source_entity, country_name, update_dt, insert_dt)

VALUES (-1, '-1', '-1', '-1', 'N/A', '18000101'::DATE, '18000101'::DATE)

ON CONFLICT (country_id) DO NOTHING;

PERFORM * FROM bl_cl.add_log (current_user::VARCHAR, NOW()::TIMESTAMP, 'ce_countries'::VARCHAR, flag::VARCHAR);

    GET DIAGNOSTICS diag_row_count = row_count;
EXCEPTION
    WHEN OTHERS THEN
        flag = 'E';
        GET STACKED DIAGNOSTICS
            error_message = MESSAGE_TEXT;
			PERFORM * FROM bl_cl.add_log (current_user::VARCHAR, NOW()::TIMESTAMP, 'ce_countries'::VARCHAR, flag::VARCHAR, error_message::VARCHAR);
        COMMIT;


END;
$add_ce_countries$;


