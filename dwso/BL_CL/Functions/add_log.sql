--Adding log to table

CREATE OR REPLACE FUNCTION bl_cl.add_log(i_user character varying, i_date timestamp without time zone, i_table character varying, i_flag character varying, i_error_mesage character varying DEFAULT NULL::character varying)
 RETURNS void
 LANGUAGE plpgsql
AS $function$


BEGIN
	INSERT INTO bl_cl.log_data_store (user_name, exec_date, table_name, flag, error_message)

	VALUES (i_user, i_date, i_table, i_flag, i_error_mesage);
END;
$function$
;
