CREATE SCHEMA IF NOT EXISTS bl_dim;

CREATE TABLE bl_dim.dim_dates
(
  date_id              	  BIGINT 		NOT NULL UNIQUE,
  date_actual	           DATE 		NOT NULL,
  day_name                 VARCHAR(9) 	NOT NULL,
  day_of_week              INT 			NOT NULL,
  day_of_month             INT 			NOT NULL,
  day_of_quarter           INT 			NOT NULL,
  day_of_year              INT 			NOT NULL,
  week_of_month            INT 			NOT NULL,
  week_of_year             INT 			NOT NULL,
  month_actual             INT 			NOT NULL,
  month_name			   CHAR(9) 		NOT NULL,
  quarter_actual           INT 			NOT NULL,
  quarter_name             VARCHAR(9) 	NOT NULL,
  year_actual              INT 			NOT NULL
	
);