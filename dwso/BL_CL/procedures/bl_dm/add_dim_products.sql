CREATE OR REPLACE PROCEDURE bl_cl.add_dim_products()

    LANGUAGE plpgsql
AS
$add_dim_products$
DECLARE
    diag_row_count int;
    flag           varchar(4);
    error_message  text;

BEGIN
    flag = 'I';

MERGE INTO bl_dm.dim_products pro
USING (SELECT DISTINCT 	COALESCE(cp1.product_id, -1)::VARCHAR AS product_id,
						cp1.source_system,
						cp1.source_entity,
						COALESCE(cp1.category_id, '-1') AS category_id,
						COALESCE(c.category_name, 'N/A')AS category_name,
						COALESCE(cp1.product_name,'N/A')AS product_name,
						COALESCE (cp1.product_desc, 'N/A')AS product_desc,
						COALESCE(cp1.product_pro_year, 'N/A')AS product_pro_year,
						COALESCE (cp1.product_color, 'N/A') AS product_color
		FROM bl_3nf.ce_products cp1
		INNER JOIN bl_3nf.ce_categories c ON cp1.category_id = c.category_id) cp
ON pro.products_src_id = cp.product_id
AND pro.source_system = cp.source_system
AND pro.source_entity = cp.source_entity
	
WHEN MATCHED THEN
	UPDATE SET  source_system = cp.source_system,
				source_entity = cp.source_entity,
				category_id = cp.category_id,
				category_name = cp.category_name,
				product_name = cp.product_name,
				product_desc = cp.product_desc,
				product_pro_year = cp.product_pro_year,
				product_color = cp.product_color,
				update_dt = NOW()
WHEN NOT MATCHED THEN

INSERT (products_surr_id,
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

VALUES (NEXTVAL('bl_dm.dim_products_seque'),
		cp.product_id,
		cp.source_system,
		cp.source_entity,
		cp.category_id,
		cp.category_name,
		cp.product_name,
		cp.product_desc,
		cp.product_pro_year,
		cp.product_color,
		NOW(),
		NOW());



PERFORM * FROM bl_cl.add_log (current_user::VARCHAR, NOW()::TIMESTAMP, 'dim_products'::VARCHAR, flag::VARCHAR);

    GET DIAGNOSTICS diag_row_count = row_count;
EXCEPTION
    WHEN OTHERS THEN
        flag = 'E';
        GET STACKED DIAGNOSTICS
            error_message = MESSAGE_TEXT;
			PERFORM * FROM bl_cl.add_log (current_user::VARCHAR, NOW()::TIMESTAMP, 'dim_products'::VARCHAR, flag::VARCHAR, error_message::VARCHAR);
        COMMIT;


END;
$add_dim_products$;




