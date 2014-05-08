
CREATE TABLE IF NOT EXISTS monthly_snapshot
( year double precision,
  month text,
  facility text,
  subfacility text,
  data_type text,
  no_projects bigint,
  no_platforms numeric,
  no_instruments numeric,
  no_deployments numeric,
  no_data numeric,
  no_data2 numeric,
  no_data3 bigint,
  no_data4 bigint,
  temporal_range text,
  lat_range text,
  lon_range text,
  depth_range text
);

grant all on table monthly_snapshot to public;


INSERT INTO monthly_snapshot (year, month, facility, subfacility, data_type, no_projects, no_platforms, no_instruments, no_deployments, no_data, no_data2, no_data3, no_data4, temporal_range, lat_range, lon_range, depth_range)
SELECT date_part('year',now()) AS year,
	to_char(to_timestamp (date_part('month',now())::text, 'MM'), 'Month') AS month,
	facility,
	subfacility,
	type AS data_type,
	no_projects,
	no_platforms,
	no_instruments,
	no_deployments,
	no_data,
	no_data2,
	no_data3,
	no_data4,
	temporal_range,
	lat_range,
	lon_range,
	depth_range
  FROM totals_view
WHERE NOT EXISTS (SELECT month FROM monthly_snapshot WHERE month = to_char(to_timestamp (date_part('month',now())::text, 'MM'), 'Month'))

SELECT * FROM monthly_snapshot_view;