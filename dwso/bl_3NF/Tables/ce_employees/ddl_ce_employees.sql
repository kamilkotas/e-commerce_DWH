CREATE TABLE IF NOT EXISTS bl_3nf.ce_employees (
					employee_id			BIGINT PRIMARY KEY,
					employee_src_id		VARCHAR(255) NOT NULL,
					source_system		VARCHAR(255) NOT NULL,
					source_entity		VARCHAR(255) NOT NULL,
					address_id			BIGINT NOT NULL,
					employee_name		VARCHAR(255) NOT NULL,
					employee_surname	VARCHAR,
					employee_phone		VARCHAR(255),
					employee_email		VARCHAR(255),
					employee_birth_date VARCHAR(255),
					update_dt			DATE,
					insert_dt			DATE,
					CONSTRAINT employee_address_id_fkey FOREIGN KEY (address_id) REFERENCES bl_3nf.ce_addresses(address_id)				
);