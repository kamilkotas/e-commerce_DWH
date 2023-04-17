INSERT INTO bl_3nf.ce_employees
(employee_id, employee_src_id, source_system, source_entity, address_id, employee_name, employee_surname, employee_phone, employee_email, employee_birth_date, update_dt, insert_dt)
VALUES(-1, '-1', 'N/A', 'N/A', -1, 'N/A', 'N/A', 'N/A', 'N/A', 'N/A', '18000101'::DATE, '99990101'::DATE)
ON CONFLICT DO NOTHING;

COMMIT;

