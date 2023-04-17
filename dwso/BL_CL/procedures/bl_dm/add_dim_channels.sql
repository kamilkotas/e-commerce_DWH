CREATE OR REPLACE PROCEDURE bl_cl.add_dim_channels()

    LANGUAGE plpgsql
AS
$add_dim_channels$
DECLARE
    diag_row_count int;
    flag           varchar(4);
    error_message  text;


BEGIN
    flag = 'I';

MERGE INTO bl_dm.dim_channels chann
USING bl_3nf.ce_channels cc
ON channels_src_id = channel_id::VARCHAR
	AND chann.source_system = cc.source_system
	AND chann.source_entity = cc.source_entity
WHEN MATCHED THEN
	UPDATE SET source_system = cc.source_system,
				source_entity = cc.source_entity,
				category_name = cc.category_name,
				channel_name = cc.channel_name,
				update_dt = NOW()
WHEN NOT MATCHED THEN

INSERT (channels_surr_id, channels_src_id, source_system, source_entity, category_name, channel_name, update_dt, insert_dt)

VALUES (NEXTVAL('bl_dm.dim_channels_seque'), cc.channel_id, cc.source_system, cc.source_entity, cc.category_name, cc.channel_name, NOW(), NOW());

PERFORM * FROM bl_cl.add_log (current_user::VARCHAR, NOW()::TIMESTAMP, 'dim_channels'::VARCHAR, flag::VARCHAR);

    GET DIAGNOSTICS diag_row_count = row_count;
EXCEPTION
    WHEN OTHERS THEN
        flag = 'E';
        GET STACKED DIAGNOSTICS
            error_message = MESSAGE_TEXT;
			PERFORM * FROM bl_cl.add_log (current_user::VARCHAR, NOW()::TIMESTAMP, 'dim_channels'::VARCHAR, flag::VARCHAR, error_message::VARCHAR);
        COMMIT;


END;
$add_dim_channels$;

