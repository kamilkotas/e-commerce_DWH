INSERT INTO bl_dm.dim_dates
(date_id, date_actual, day_name, day_of_week, day_of_month, day_of_quarter, day_of_year, week_of_month, week_of_year, month_actual, month_name, quarter_actual, quarter_name, year_actual)
VALUES(-1, '99990101'::DATE, 'N/A', -1, -1, -1, -1, -1, -1, -1, 'N/A', -1, 'N/A', -1)
ON CONFLICT DO NOTHING;

COMMIT;
