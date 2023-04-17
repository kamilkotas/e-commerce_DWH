INSERT INTO bl_3nf.ce_products (product_id, product_src_id, source_system, source_entity, category_id, product_name, product_desc, product_pro_year, product_color, update_dt, insert_dt)

VALUES (-1, '-1', '-1', '-1', -1, 'N/A', 'N/A', '9999', 'N/A', '18000101'::DATE, '18000101'::DATE)

ON CONFLICT DO NOTHING;

COMMIT;