INSERT INTO bl_3nf.ce_shops
(shop_id, shop_src_id, source_system, source_entity, address_id, shop_name, shop_phone, shop_email, update_dt, insert_dt)
VALUES(-1, '-1', 'N/A', 'N/A', -1, 'N/A', 'N/A', 'N/A', '18000101'::DATE, '99990101'::DATE)

ON CONFLICT DO NOTHING;

COMMIT;