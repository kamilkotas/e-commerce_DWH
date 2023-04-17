CREATE OR REPLACE PROCEDURE bl_cl.load_all ()

LANGUAGE  plpgsql
AS $load_all$

BEGIN  
	-- bl_3nf
	CALL bl_cl.add_ce_countries();
	
	CALL bl_cl.add_ce_cities();

	CALL bl_cl.add_ce_postal_codes();

	CALL bl_cl.add_ce_streets();

	CALL bl_cl.add_ce_addresses();

	CALL bl_cl.add_ce_customers();

	CALL bl_cl.add_ce_employees();

	CALL bl_cl.add_ce_shops();

	CALL bl_cl.add_ce_promotions_scd2();

	CALL bl_cl.add_ce_channels();

	CALL bl_cl.add_ce_categories();

	CALL bl_cl.add_ce_products();

	CALL bl_cl.add_ce_transactions();
	
-- bl_dm

	CALL bl_cl.add_dim_dates();

	CALL bl_cl.add_dim_channels();

	CALL bl_cl.add_dim_customers();

	CALL bl_cl.add_dim_employees();

	CALL bl_cl.add_dim_products();

	CALL bl_cl.add_dim_promotions();

	CALL bl_cl.add_dim_shops();

	CALL bl_cl.add_fct_transactions();
	
END

$load_all$;
