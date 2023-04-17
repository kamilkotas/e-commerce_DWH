
INSERT INTO bl_3nf.ce_promotions_scd2 (promotion_id, promotion_src_id, source_system, source_entity, promotion_name, start_dt, end_dt, is_active, update_dt, insert_dt)

VALUES (-1, '-1', '-1', '-1','N/A', '18000101'::DATE, '18000101'::DATE, NULL, '18000101'::DATE, '18000101'::DATE)

ON CONFLICT DO NOTHING;

COMMIT;