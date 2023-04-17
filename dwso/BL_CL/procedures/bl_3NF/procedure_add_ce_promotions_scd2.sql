CREATE OR REPLACE PROCEDURE bl_cl.add_ce_promotions_scd2()

    LANGUAGE plpgsql
AS
$add_ce_promotions$
DECLARE
    diag_row_count int;
    flag           varchar(4);
    error_message  text;

BEGIN
    flag = 'I';




WITH all_promotions AS (	
INSERT INTO bl_3nf.ce_promotions_scd2    (promotion_src_id,
										source_system,
										source_entity,
										promotion_name,
										start_dt,
										end_dt,
										is_active,
										update_dt,
										insert_dt)

									
SELECT DISTINCT COALESCE(sot.promotion_id, '-1') AS promotion_id,
				'src_online' AS source_system,
				'src_online_transactions' AS source_entity,
				COALESCE(sot.promotion_name, '-1') AS promotion_name,
				'19000101'::DATE AS start_dt,
				'99990101'::DATE AS end_dt,
				TRUE AS is_active,
				NOW() AS update_dt,
				NOW() AS insert_dt
				
FROM online.src_online_transactions sot
LEFT OUTER JOIN bl_3nf.ce_promotions_scd2 pro ON sot.promotion_id = pro.promotion_src_id
								AND pro.source_system = 'src_online'
								AND pro.source_entity = 'src_online_transactions'
WHERE NOT EXISTS (SELECT 1
					FROM bl_3nf.ce_promotions_scd2 cp
					WHERE cp.promotion_src_id = sot.promotion_id
					AND cp.promotion_name = sot.promotion_name
					AND cp.is_active = TRUE)
					
UNION 

SELECT DISTINCT COALESCE(sot.promotion_id, '-1') AS promotion_id,
				'src_offline' AS source_system,
				'src_offline_transactions' AS source_entity,
				COALESCE(sot.promotion_name, '-1') AS promotion_name,
				'19000101'::DATE AS start_dt,
				'99990101'::DATE AS end_dt,
				TRUE AS is_active,
				NOW() AS update_dt,
				NOW() AS insert_dt
				
FROM offline.src_offline_transactions sot
LEFT OUTER JOIN bl_3nf.ce_promotions_scd2 pro ON sot.promotion_id = pro.promotion_src_id
								AND pro.source_system = 'src_offline'
								AND pro.source_entity = 'src_offline_transactions'
WHERE NOT EXISTS (SELECT 1
					FROM bl_3nf.ce_promotions_scd2 cp
					WHERE cp.promotion_src_id = sot.promotion_id
					AND cp.promotion_name = sot.promotion_name
					AND cp.is_active = TRUE)

RETURNING *)


	
UPDATE bl_3nf.ce_promotions_scd2 ps
SET is_active = FALSE,
	end_dt = NOW()
WHERE ps.promotion_src_id IN (SELECT promotion_src_id 
							FROM all_promotions a
							WHERE ps.source_system =  a.source_system
							AND ps.source_entity = a.source_entity)
	AND promotion_id <> (SELECT promotion_id FROM all_promotions a WHERE ps.source_system =  a.source_system
														AND ps.source_entity = a.source_entity);






INSERT INTO bl_3nf.ce_promotions_scd2 (promotion_id, promotion_src_id, source_system, source_entity, promotion_name, start_dt, end_dt, is_active, update_dt, insert_dt)

VALUES (-1, '-1', '-1', '-1','N/A', '18000101'::DATE, '18000101'::DATE, NULL, '18000101'::DATE, '99990101'::DATE)

ON CONFLICT (promotion_id) DO NOTHING;

PERFORM * FROM bl_cl.add_log (current_user::VARCHAR, NOW()::TIMESTAMP, 'ce_promotions_scd2'::VARCHAR, flag::VARCHAR);


    GET DIAGNOSTICS diag_row_count = row_count;
EXCEPTION
    WHEN OTHERS THEN
        flag = 'E';
        GET STACKED DIAGNOSTICS
            error_message = MESSAGE_TEXT;
			PERFORM * FROM bl_cl.add_log (current_user::VARCHAR, NOW()::TIMESTAMP, 'ce_promotions_scd2'::VARCHAR, flag::VARCHAR, error_message::VARCHAR);
        COMMIT;


END;
$add_ce_promotions$;



