SET search_path = reporting, public;
DROP TABLE IF EXISTS argo_all_deployments_view CASCADE;

-------------------------------
-- VIEW FOR Argo; The dw_argo schema is not being used for reporting anymore.
-------------------------------
-- All deployments view
CREATE TABLE argo_all_deployments_view AS
WITH a AS (SELECT platform_number, COUNT(DISTINCT cycle_number) AS no_profiles, COUNT(*) AS no_measurements FROM argo.argo_profile_data GROUP BY platform_number)
  SELECT DISTINCT CASE WHEN m.data_centre IS NULL THEN ps.project_name ELSE m.data_centre END AS organisation, --
	CASE WHEN m.oxygen_sensor = false THEN 'No oxygen sensor' 
		ELSE 'Oxygen sensor' END AS oxygen_sensor, 
	m.platform_number AS platform_code,
	a.no_profiles,
	a.no_measurements,
	round((m.min_lat)::numeric, 1) AS min_lat, 
	round((m.max_lat)::numeric, 1) AS max_lat, 
	round((m.min_long)::numeric, 1) AS min_lon, 
	round((m.max_long)::numeric, 1) AS max_lon, 
	COALESCE(round((m.min_lat)::numeric, 1) || '/' || round((m.max_lat)::numeric, 1)) AS lat_range, 
	COALESCE(round((m.min_long)::numeric, 1) || '/' || round((m.max_long)::numeric, 1)) AS lon_range, 
	CASE WHEN date(m.start_date) IS NULL THEN date(m.launch_date) ELSE date(m.start_date) END AS start_date, 
	date(m.last_measure_date) AS end_date, 
	CASE WHEN round((((date_part('day', (m.last_measure_date - m.start_date)))::integer)::numeric / 365.242), 1) IS NULL THEN round((((date_part('day', (m.last_measure_date - m.launch_date)))::integer)::numeric / 365.242), 1) ELSE round((((date_part('day', (m.last_measure_date - m.start_date)))::integer)::numeric / 365.242), 1) END AS coverage_duration, 
	m.pi_name
    FROM argo.argo_float m
    LEFT JOIN a ON m.platform_number = a.platform_number
    LEFT JOIN argo.profile_summary ps ON m.platform_number = ps.platform_number
    ORDER BY organisation, oxygen_sensor, platform_code;

grant all on table argo_all_deployments_view to public;

-- Data summary view
CREATE or replace VIEW argo_data_summary_view AS
  SELECT v.organisation, 
	count(DISTINCT v.platform_code) AS no_platforms, 
	count(CASE WHEN date_part('day', (now() - (v.end_date)::timestamp with time zone)) < 31 THEN 1 ELSE NULL::integer END) AS no_active_floats, 
	count(CASE WHEN v.oxygen_sensor = 'Oxygen sensor' THEN 1 ELSE NULL::integer END) AS no_oxygen_platforms, 
	count(CASE WHEN date_part('day', (now() - (v.end_date)::timestamp with time zone)) < 31 AND v.oxygen_sensor = 'Oxygen sensor' THEN 1 ELSE NULL::integer END) AS no_active_oxygen_platforms,
	SUM(no_profiles) AS total_no_profiles,
	SUM(no_measurements) AS total_no_measurements,
	min(v.min_lat) AS min_lat, 
	max(v.max_lat) AS max_lat, 
	min(v.min_lon) AS min_lon, 
	max(v.max_lon) AS max_lon, 
	COALESCE(min(v.min_lat) || '/' || max(v.max_lat)) AS lat_range, 
	COALESCE(min(v.min_lon) || '/' || max(v.max_lon)) AS lon_range, 
	min(v.start_date) AS earliest_date, 
	max(v.end_date) AS latest_date, 
	round(avg(v.coverage_duration), 1) AS mean_coverage_duration,
	round(min(v.coverage_duration), 1) || ' - ' || round(max(v.coverage_duration), 1) AS no_data_days -- Range in number of data days
  FROM argo_all_deployments_view v
	GROUP BY v.organisation 
	ORDER BY organisation;

grant all on table argo_data_summary_view to public;