SET search_path = report_test, pg_catalog, public, argo;

CREATE or replace VIEW argo_all_deployments_view AS
    SELECT 
    m.data_centre AS organisation, 
    CASE WHEN m.oxygen_sensor = false THEN 'No oxygen sensor' 
	ELSE 'Oxygen sensor' END AS oxygen_sensor, 
    m.platform_number AS platform_code, 
    round((m.min_lat)::numeric, 1) AS min_lat, 
    round((m.max_lat)::numeric, 1) AS max_lat, 
    round((m.min_long)::numeric, 1) AS min_lon, 
    round((m.max_long)::numeric, 1) AS max_lon, 
    COALESCE(round((m.min_lat)::numeric, 1) || '/' || round((m.max_lat)::numeric, 1)) AS lat_range, 
    COALESCE(round((m.min_long)::numeric, 1) || '/' || round((m.max_long)::numeric, 1)) AS lon_range, 
    date(m.start_date) AS start_date, 
    date(m.last_measure_date) AS end_date, 
    round((((date_part('day', (m.last_measure_date - m.start_date)))::integer)::numeric / 365.242), 1) AS coverage_duration, 
    m.pi_name, 
    CASE WHEN date_part('day', (m.last_measure_date - m.start_date)) IS NULL THEN 'Missing dates' 
	WHEN m.uuid IS NULL THEN 'No metadata' 
	WHEN m.data_centre IS NULL THEN 'No organisation' 
	WHEN m.pi_name IS NULL THEN 'No principal investigator'::text 
	ELSE NULL END AS missing_info 
    FROM argo.argo_float m
    ORDER BY organisation, oxygen_sensor, platform_code;

grant all on table argo_all_deployments_view to public;

CREATE or replace VIEW argo_data_summary_view AS
    SELECT 
    v.organisation, 
    count(DISTINCT v.platform_code) AS no_platforms, 
    count(CASE WHEN date_part('day', (now() - (v.end_date)::timestamp with time zone)) < 31 THEN 1 ELSE NULL::integer END) AS no_active_floats, 
    count(CASE WHEN v.oxygen_sensor = 'Oxygen sensor' THEN 1 ELSE NULL::integer END) AS no_oxygen_platforms, 
    count(CASE WHEN date_part('day', (now() - (v.end_date)::timestamp with time zone)) < 31 AND v.oxygen_sensor = 'Oxygen sensor' THEN 1 ELSE NULL::integer END) AS no_active_oxygen_platforms, 
    count(CASE WHEN v.missing_info IS NOT NULL THEN 1 ELSE NULL::integer END) AS no_deployments_with_missing_info, 
    min(v.min_lat) AS min_lat, 
    max(v.max_lat) AS max_lat, 
    min(v.min_lon) AS min_lon, 
    max(v.max_lon) AS max_lon, 
    COALESCE(min(v.min_lat) || '/' || max(v.max_lat)) AS lat_range, 
    COALESCE(min(v.min_lon) || '/' || max(v.max_lon)) AS lon_range, 
    min(v.start_date) AS earliest_date, 
    max(v.end_date) AS latest_date, 
    round(avg(v.coverage_duration), 1) AS mean_coverage_duration 
    FROM argo_all_deployments_view v
    GROUP BY v.organisation 
    ORDER BY organisation;

grant all on table argo_data_summary_view to public;