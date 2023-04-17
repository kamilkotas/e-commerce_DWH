CREATE TABLE bl_cl.log_data_store (
	id serial4 NOT NULL,
	user_name varchar(255) NOT NULL,
	exec_date timestamp NOT NULL,
	table_name varchar(255) NOT NULL,
	flag varchar(1) NOT NULL,
	error_message varchar(255) NULL
);