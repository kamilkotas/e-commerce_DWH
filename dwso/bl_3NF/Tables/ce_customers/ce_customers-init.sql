INSERT INTO bl_3nf.ce_customers
(customer_id, customer_src_id, source_system, source_entity, address_id, customer_name, customer_surname, customer_phone, customer_email, customer_birth_date, update_dt, insert_dt)
VALUES(-1, '-1', 'N/A', 'N/A', -1, 'N/A', 'N/A', 'N/A', 'N/A', 'N/A', '18000101'::DATE, '99990101'::DATE)
ON CONFLICT DO NOTHING;

COMMIT;