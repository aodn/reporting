SET search_path = report_test, pg_catalog, public;

-- CHANGES TO FAIMMS reports:
-- DELETED qaqc_data, days_to_process_and_upload, days_to_make_public, missing_info ==> no more missing info report. Change how new deployments report are produced.
CREATE or replace VIEW faimms_all_deployments_view AS
  SELECT DISTINCT m.platform_code AS site_name, 
	m.site_code AS platform_code, 
	COALESCE(m.channel_id || ' - ' || (m."VARNAME")) AS sensor_code, 
	(m."DEPTH")::numeric AS sensor_depth, 
	date(m.time_start) AS start_date, 
	date(m.time_end) AS end_date, 
	(date_part('day', (m.time_end - m.time_start)))::numeric AS coverage_duration, 
	f.instrument AS sensor_name, 
	m."VARNAME" AS parameter, 
	m.channel_id AS channel_id,
	round(ST_X(geom)::numeric, 1) AS lon,
	round(ST_Y(geom)::numeric, 1) AS lat
  FROM faimms.faimms_timeseries_map m
  LEFT JOIN faimms.global_attributes_file f ON f.aims_channel_id = m.channel_id
	ORDER BY site_name, platform_code, sensor_code;

grant all on table faimms_all_deployments_view to public;


CREATE or replace VIEW faimms_data_summary_view AS
  SELECT v.site_name, 
	count(DISTINCT v.platform_code) AS no_platforms, 
	count(DISTINCT v.sensor_code) AS no_sensors, 
	count(DISTINCT v.parameter) AS no_parameters,
	min(v.lon) AS lon, 
	min(v.lat) AS lat, 
	COALESCE(min(v.sensor_depth) || '-' || max(v.sensor_depth)) AS depth_range,
	min(v.start_date) AS earliest_date, 
	max(v.end_date) AS latest_date, 
	round(avg(v.coverage_duration), 1) AS mean_coverage_duration,
	min(v.sensor_depth) AS min_depth, 
	max(v.sensor_depth) AS max_depth
  FROM faimms_all_deployments_view v
	GROUP BY site_name 
	ORDER BY site_name;

grant all on table faimms_data_summary_view to public;