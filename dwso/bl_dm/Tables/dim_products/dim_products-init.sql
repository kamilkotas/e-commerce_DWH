INSERT INTO bl_dm.dim_products
	(products_surr_id,
	products_src_id,
	source_system,
	source_entity,
	category_id,
	category_name,
	product_name,
	product_desc,
	product_pro_year,
	product_color,
	update_dt,
	insert_dt)

VALUES(-1,
	'-1',
	'N/A',
	'N/A',
	'-1',
	'N/A',
	'N/A',
	'N/A',
	'N/A',
	'N/A',
	'18000101'::DATE,
	'99990101'::DATE)

ON CONFLICT DO NOTHING;

COMMIT;
