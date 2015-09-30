SET search_path = reporting, public;
DROP VIEW IF EXISTS faimms_all_deployments_view CASCADE; -- Delete that row once script has run once on reporting schema
DROP TABLE IF EXISTS faimms_all_deployments_view CASCADE;

-------------------------------
-- VIEWS FOR FAIMMS; The legacy_faimms schema and report.faimms_manual table are not being used anymore.
-------------------------------
-- All deployments view
CREATE TABLE faimms_all_deployments_view AS
(WITH d_1 AS (SELECT channel_id, "VALUES_quality_control", COUNT(*) AS no_measurements FROM faimms.faimms_timeseries_data GROUP BY channel_id, "VALUES_quality_control"),
d_2 AS (SELECT channel_id,
SUM(CASE WHEN "VALUES_quality_control" != '0' THEN no_measurements ELSE 0 END) qaqc,
SUM(CASE WHEN "VALUES_quality_control" = '0' THEN no_measurements ELSE 0 END) no_qaqc
FROM d_1 GROUP BY channel_id)
  SELECT DISTINCT m.platform_code AS site_name, 
	m.site_code AS platform_code, 
	COALESCE(m.channel_id || ' - ' || (m."VARNAME")) AS sensor_code, 
	(m."DEPTH")::numeric AS sensor_depth, 
	date(m.time_start) AS start_date, 
	date(m.time_end) AS end_date, 
	round((date_part('days', (m.time_end - m.time_start)) + date_part('hours', (m.time_end - m.time_start))/24)::numeric/365.25, 1) AS coverage_duration, 
	f.instrument AS sensor_name, 
	m."VARNAME" AS parameter, 
	m.channel_id AS channel_id,
	round(ST_X(geom)::numeric, 1) AS lon,
	round(ST_Y(geom)::numeric, 1) AS lat,
	d_2.qaqc,
	d_2.no_qaqc
  FROM faimms.faimms_timeseries_map m
  LEFT JOIN faimms.global_attributes_file f ON f.aims_channel_id = m.channel_id
  LEFT JOIN d_2 ON d_2.channel_id = m.channel_id
	ORDER BY site_name, platform_code, sensor_code);

grant all on table faimms_all_deployments_view to public;

-- Data summary view
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
	round(min(v.coverage_duration), 1) || ' - ' || round(max(v.coverage_duration), 1) AS no_data_days, -- Range in number of data days
	CASE WHEN min(v.sensor_depth) >0 THEN min(v.sensor_depth) ELSE 0 END AS min_depth, -- To fix up negative depths
	max(v.sensor_depth) AS max_depth,
	SUM(CASE WHEN v.qaqc = 0 THEN 0 ELSE 1 END) AS qaqc_data,
	SUM(v.qaqc + v.no_qaqc) AS no_measurements
  FROM faimms_all_deployments_view v
	GROUP BY site_name 
	ORDER BY site_name;

grant all on table faimms_data_summary_view to public;