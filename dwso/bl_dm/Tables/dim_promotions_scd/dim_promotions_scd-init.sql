INSERT INTO bl_dm.dim_promotions_scd
(promotions_surr_id, promotions_src_id, source_system, source_entity, promotion_name, start_dt, end_dt, is_active, insert_dt)
VALUES(-1, '-1', 'N/A', 'N/A', 'N/A', '18000101'::DATE, '99990101'::DATE, FALSE, '18000101'::DATE)
ON CONFLICT DO NOTHING;

COMMIT;
