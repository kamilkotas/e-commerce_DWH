INSERT INTO bl_3nf.ce_cities
(city_id, cities_src_id, source_system, source_entity, city_name, country_id, update_dt, insert_dt)
VALUES(-1, '-1', 'N/A', 'N/A', 'N/A', -1, '18000101'::DATE, '99990101'::DATE)

ON CONFLICT DO NOTHING;

COMMIT;