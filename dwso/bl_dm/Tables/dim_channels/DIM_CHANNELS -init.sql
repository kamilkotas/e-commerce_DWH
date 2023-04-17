INSERT INTO bl_dm.dim_channels
(channels_surr_id, channels_src_id, source_system, source_entity, category_name, channel_name, update_dt, insert_dt)
VALUES(-1, '-1', 'N/A', 'N/A', 'N/A', 'N/A', '18000101'::DATE, '99990101'::DATE)
ON CONFLICT DO NOTHING;

COMMIT;


