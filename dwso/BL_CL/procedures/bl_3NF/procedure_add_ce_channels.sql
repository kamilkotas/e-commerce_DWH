CREATE OR REPLACE PROCEDURE bl_cl.add_ce_channels()

    LANGUAGE plpgsql
AS
$add_ce_channels$
DECLARE
    diag_row_count int;
    flag           varchar(4);
    error_message  text;
    error_detail   text;

BEGIN
    flag = 'I';



MERGE INTO bl_3nf.ce_channels

USING(
SELECT DISTINCT COALESCE(sot.channel_id, '-1') AS channel_id,
				'src_online' AS source_system,
				'src_online_transactions' AS source_entity,
				COALESCE(sot.channel_category, 'N/A') AS channel_category,
				COALESCE(sot.channel_name, 'N/A') AS channel_name,
				CURRENT_DATE AS update_dt,
				CURRENT_DATE AS insert_dt
				
FROM online.src_online_transactions sot
LEFT OUTER JOIN bl_3nf.ce_channels c ON sot.channel_id = c.channel_src_id
								AND c.source_system = 'src_online'
								AND c.source_entity = 'src_online_transactions'
WHERE c.channel_id IS NULL

UNION 

SELECT DISTINCT COALESCE(sot.channel_id, '-1') AS channel_id,
				'src_offline' AS source_system,
				'src_offline_transactions' AS source_entity,
				COALESCE(sot.channel_category, 'N/A') AS channel_category,
				COALESCE(sot.channel_name, 'N/A') AS channel_name,
				CURRENT_DATE AS update_dt,
				CURRENT_DATE AS insert_dt
				
FROM offline.src_offline_transactions sot
LEFT OUTER JOIN bl_3nf.ce_channels c ON sot.channel_id = c.channel_src_id
								AND c.source_system = 'src_offline'
								AND c.source_entity = 'src_offline_transactions'
WHERE c.channel_id IS NULL ) chann

							ON bl_3nf.ce_channels.channel_src_id = chann.channel_id
							AND bl_3nf.ce_channels.source_system = chann.source_system
							AND bl_3nf.ce_channels.source_entity = chann.source_entity
WHEN MATCHED THEN 
					UPDATE SET category_name = chann.channel_category,
								channel_name = chann.channel_name,
								update_dt = NOW()
WHEN NOT MATCHED THEN

INSERT (channel_id,
		channel_src_id,
		source_system,
		source_entity,
		category_name,
		channel_name,
		update_dt,
		insert_dt)
		
VALUES (NEXTVAL('bl_3nf.ce_channels_seq'),
		chann.channel_id,
		chann.source_system,
		chann.source_entity,
		chann.channel_category,
		chann.channel_name,
		NOW(),
		NOW());


INSERT INTO bl_3nf.ce_channels (channel_id, channel_src_id, source_system, source_entity, category_name, channel_name, update_dt, insert_dt)

VALUES (-1, '-1', '-1', '-1', 'N/A','N/A', '18000101'::DATE, '18000101'::DATE)

ON CONFLICT (channel_id) DO NOTHING;

PERFORM * FROM bl_cl.add_log (current_user::VARCHAR, NOW()::TIMESTAMP, 'ce_channels'::VARCHAR, flag::VARCHAR);

    GET DIAGNOSTICS diag_row_count = row_count;
EXCEPTION
    WHEN OTHERS THEN
        flag = 'E';
        GET STACKED DIAGNOSTICS
            error_message = MESSAGE_TEXT;
			PERFORM * FROM bl_cl.add_log (current_user::VARCHAR, NOW()::TIMESTAMP, 'ce_channels'::VARCHAR, flag::VARCHAR, error_message::VARCHAR);
        COMMIT;


END;
$add_ce_channels$;



