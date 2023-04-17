CREATE OR REPLACE PROCEDURE bl_cl.add_ce_shops()

    LANGUAGE plpgsql
AS
$add_ce_shops$
DECLARE
    diag_row_count int;
    flag           varchar(4);
    error_message  text;

BEGIN
    flag = 'I';



MERGE INTO bl_3nf.ce_shops

USING(

SELECT DISTINCT COALESCE(sot.ShopNo, '-1') AS shop_id,
				'src_online' AS source_system,
				'src_online_transactions' AS source_entity,
				COALESCE(ca.address_id, -1) AS address_id,
				COALESCE(sot.shop_name, 'N/A') AS shop_name,
				COALESCE(sot.shop_phone, 'N/A') AS shop_phone,
				COALESCE(sot.shop_mail, 'N/A') AS shop_mail,
				CURRENT_DATE AS update_dt,
				CURRENT_DATE AS insert_dt
				
FROM online.src_online_transactions sot
LEFT JOIN bl_3nf.ce_addresses ca ON sot.shop_address_id = ca.address_src_id
								AND ca.source_system = 'src_online'
								AND ca.source_entity = 'src_online_transactions'
LEFT JOIN bl_3nf.ce_shops sh ON sot.ShopNO = sh.shop_src_id
								AND sh.source_system = 'src_online'
								AND sh.source_entity = 'src_online_transactions'
WHERE sh.shop_id IS NULL

UNION

SELECT DISTINCT COALESCE(sot.ShopNo, '-1') AS shop_id,
				'src_offline' AS source_system,
				'src_offline_transactions' AS source_entity,
				COALESCE(ca.address_id, -1) AS address_id,
				COALESCE(sot.shop_name, '-1') AS shop_name,
				COALESCE(sot.shop_phone, '-1')AS shop_phone,
				COALESCE(sot.shop_mail, '-1') AS shop_mail,
				CURRENT_DATE AS update_dt,
				CURRENT_DATE AS insert_dt
				
FROM offline.src_offline_transactions sot
LEFT JOIN bl_3nf.ce_addresses ca ON sot.shop_address_id = ca.address_src_id
								AND ca.source_system = 'src_offline'
								AND ca.source_entity = 'src_offline_transactions'
LEFT JOIN bl_3nf.ce_shops sh ON sot.ShopNO = sh.shop_src_id
								AND sh.source_system = 'src_offline'
								AND sh.source_entity = 'src_offline_transactions'
WHERE sh.shop_id IS NULL) shop
			ON bl_3nf.ce_shops.shop_src_id = shop.shop_id
			AND bl_3nf.ce_shops.source_system = shop.source_system
			AND bl_3nf.ce_shops.source_entity = shop.source_entity
			AND bl_3nf.ce_shops.address_id = shop.address_id

WHEN MATCHED THEN 
				UPDATE SET	address_id = shop.address_id,
							shop_name = shop.shop_name,
							shop_phone = shop.shop_phone,
							shop_email = shop.shop_mail, 
							update_dt = NOW()
	

WHEN NOT MATCHED THEN

INSERT (shop_id,
		shop_src_id,
		source_system,
		source_entity,
		address_id,
		shop_name,
		shop_phone,
		shop_email,
		update_dt,
		insert_dt)
		
VALUES (NEXTVAL('bl_3nf.ce_shops_seq') ,
		shop.shop_id,
		shop.source_system,
		shop.source_entity,
		shop.address_id,
		shop.shop_name,
		shop.shop_phone,
		shop.shop_mail,
		NOW(),
		NOW());

INSERT INTO bl_3nf.ce_shops (shop_id, shop_src_id, source_system, source_entity, address_id, shop_name, shop_phone, shop_email, update_dt, insert_dt)  

VALUES (-1, '-1', '-1', '-1', -1, 'N/A', 'N/A', 'N/A', '18000101'::DATE, '18000101'::DATE)

ON CONFLICT (shop_id) DO NOTHING;

DELETE FROM
   bl_3nf.ce_shops a
       USING bl_3nf.ce_shops b
WHERE
    a.shop_id > b.shop_id
   AND a.shop_src_id = b.shop_src_id
 AND a.source_system = b.source_system;

PERFORM * FROM bl_cl.add_log (current_user::VARCHAR, NOW()::TIMESTAMP, 'ce_shops'::VARCHAR, flag::VARCHAR);

    GET DIAGNOSTICS diag_row_count = row_count;
EXCEPTION
    WHEN OTHERS THEN
        flag = 'E';
        GET STACKED DIAGNOSTICS
            error_message = MESSAGE_TEXT;
			PERFORM * FROM bl_cl.add_log (current_user::VARCHAR, NOW()::TIMESTAMP, 'ce_shops'::VARCHAR, flag::VARCHAR, error_message::VARCHAR);
        COMMIT;


END;
$add_ce_shops$;



