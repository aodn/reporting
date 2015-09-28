SET search_path = report_test, public;

-------------------------------
-- Monthly snapshot
------------------------------- 
CREATE TABLE IF NOT EXISTS monthly_snapshot
( timestamp timestamp without time zone,
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
  start_date date,
  end_date date,
  min_lat numeric,
  max_lat numeric,
  min_lon numeric,
  max_lon numeric,
  min_depth numeric,
  max_depth numeric
);
grant all on table monthly_snapshot to public;

INSERT INTO monthly_snapshot (timestamp, facility, subfacility, data_type, no_projects, no_platforms, no_instruments, no_deployments, no_data, no_data2, no_data3, no_data4, 
start_date,end_date,min_lat,max_lat,min_lon,max_lon,min_depth,max_depth)
SELECT now()::timestamp without time zone,
	facility,
	subfacility,
	type AS data_type,
	no_projects,
	no_platforms,
	no_instruments,
	no_deployments,
	no_data,
	no_data2,
	no_data3::bigint,
	no_data4::bigint,
	to_date(substring(temporal_range,'[a-zA-Z0-9/]+'),'DD/MM/YYYY') AS start_date,
	to_date(substring(temporal_range,'-(.*)'),'DD/MM/YYYY') AS end_date,
	substring(lat_range,'(.*) - ')::numeric AS min_lat,
	substring(lat_range,' - (.*)')::numeric AS max_lat,
	substring(lon_range,'(.*) - ')::numeric AS min_lon,
	substring(lon_range,' - (.*)')::numeric AS max_lon,
	substring(depth_range,'(.*) - ')::numeric AS min_depth,
	substring(depth_range,' - (.*)')::numeric AS max_depth
  FROM totals_view;

GRANT select on all tables in schema reporting to "backup";
GRANT select on all sequences in schema reporting to "backup";