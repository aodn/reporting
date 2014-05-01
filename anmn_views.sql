SET search_path = report_test, pg_catalog, public, anmn;

CREATE or replace VIEW anmn_all_deployments_view AS
  WITH site_view AS (
  SELECT m.site_code, 
	m.site_name, 
	avg(m.lat) AS site_lat, 
	avg(m.lon) AS site_lon, 
	(avg(m.depth))::integer AS site_depth, 
	min(m.first_deployed) AS site_first_deployed, 
	max(m.discontinued) AS site_discontinued, 
	bool_or(m.active) AS site_active 
  FROM report.anmn_platforms_manual m
	GROUP BY m.site_code, m.site_name 
	ORDER BY m.site_code), 
    file_view AS (
  SELECT 
	DISTINCT "substring"((v.url), 'IMOS/ANMN/([A-Z]+)/') AS subfacility, 
	v.site_code, 
	v.platform_code, 
	v.deployment_code, 
	"substring"((v.url), '([^_]+)_END') AS deployment_product, 
	v.status, 
	"substring"(v.file_version, 'Level ([012]+)') AS file_version, 
	"substring"((v.url), '(Temperature|CTD_timeseries|CTD_profiles|Biogeochem_timeseries|Biogeochem_profiles|Velocity|Wave|CO2|Meteorology)') AS data_category, 
	NULLIF(v.geospatial_vertical_min, '-Infinity')::double precision AS geospatial_vertical_min, 
	NULLIF(v.geospatial_vertical_max, 'Infinity')::double precision AS geospatial_vertical_max, 
	CASE WHEN timezone('UTC', v.time_deployment_start) IS NULL THEN v.time_coverage_start 
		ELSE (timezone('UTC', v.time_deployment_start))::timestamp with time zone END AS time_deployment_start, 
	CASE WHEN timezone('UTC', v.time_deployment_end) IS NULL THEN v.time_coverage_end 
		ELSE (timezone('UTC', v.time_deployment_end))::timestamp with time zone END AS time_deployment_end, 
	timezone('UTC', GREATEST(v.time_deployment_start, v.time_coverage_start)) AS good_data_start, 
	timezone('UTC', LEAST(v.time_deployment_end, v.time_coverage_end)) AS good_data_end, 
	(v.time_coverage_end - v.time_coverage_start) AS coverage_duration, 
	(v.time_deployment_end - v.time_deployment_start) AS deployment_duration, 
	GREATEST('00:00:00'::interval, (LEAST(v.time_deployment_end, v.time_coverage_end) - GREATEST(v.time_deployment_start, v.time_coverage_start))) AS good_data_duration
  FROM anmn.anmn_vw v 
	ORDER BY subfacility, deployment_code, data_category)
  SELECT 
	f.subfacility, 
	COALESCE(s.site_name || ' (' || f.site_code || ')' || ' - Lat/Lon:' || round((min(s.site_lat))::numeric, 1) || '/' || round((min(s.site_lon))::numeric, 1)) AS site_name_code, 
	f.data_category, 
	f.deployment_code, 
	(sum(((f.file_version = '0'))::integer))::numeric AS no_fv00, 
	(sum(((f.file_version = '1'))::integer))::numeric AS no_fv01, 
	date(min(f.time_deployment_start)) AS start_date, 
	date(max(f.time_deployment_end)) AS end_date, 
	(date_part('day', (max(f.time_deployment_end) - min(f.time_deployment_start))))::numeric AS coverage_duration, 
	(date_part('day', (max(f.good_data_end) - min(f.good_data_start))))::numeric AS data_coverage, 
	CASE WHEN sum(CASE WHEN s.site_name IS NULL THEN 0 ELSE 1 END) <> count(f.subfacility) OR 
		sum(CASE WHEN f.time_deployment_start IS NULL THEN 0 ELSE 1 END) <> count(f.subfacility) OR 
		sum(CASE WHEN f.time_deployment_end IS NULL THEN 0 ELSE 1 END) <> count(f.subfacility) OR 
		sum(CASE WHEN (f.site_code IS NULL) THEN 0 ELSE 1 END) <> count(f.subfacility) THEN 
		COALESCE('Missing information from' || ' ' || f.subfacility || ' ' || 'sub-facility') 
		ELSE NULL END AS missing_info, 
	date(min(f.good_data_start)) AS good_data_start, 
	date(max(f.good_data_end)) AS good_data_end, 
	round((min(s.site_lat))::numeric, 1) AS min_lat, 
	round((min(s.site_lon))::numeric, 1) AS min_lon, 
	round((max(s.site_lat))::numeric, 1) AS max_lat, 
	round((max(s.site_lon))::numeric, 1) AS max_lon, 
	round((min(f.geospatial_vertical_min))::numeric, 1) AS min_depth, 
	round((max(f.geospatial_vertical_max))::numeric, 1) AS max_depth,
	f.site_code 
  FROM file_view f 
  NATURAL LEFT JOIN site_view s 
	WHERE f.status IS NULL 
	GROUP BY f.subfacility, f.site_code, s.site_name, f.data_category, f.deployment_code 
	ORDER BY f.subfacility, f.site_code, f.data_category, f.deployment_code;

grant all on table anmn_all_deployments_view to public;

CREATE or replace VIEW anmn_data_summary_view AS
  SELECT v.subfacility, 
	v.site_name_code, 
	v.data_category, 
	count(*) AS no_deployments, 
	sum(v.no_fv00) AS no_fv00, 
	sum(v.no_fv01) AS no_fv01, 
	CASE WHEN (CASE WHEN min(v.min_depth) < 0 THEN min(v.min_depth) * (-1) ELSE min(v.min_depth) END) > max(v.max_depth) 
		THEN COALESCE(max(v.max_depth) || '/' || CASE WHEN min(v.min_depth) < 0 THEN min(v.min_depth) * (-1) ELSE min(v.min_depth) END)
		ELSE COALESCE(CASE WHEN min(v.min_depth) < 0 THEN min(v.min_depth) * (-1) ELSE min(v.min_depth) END || '/' || max(v.max_depth)) END AS depth_range, 
	min(v.start_date) AS earliest_date, 
	max(v.end_date) AS latest_date, 
	(max(v.end_date) - min(v.start_date)) AS coverage_duration, 
	sum(v.data_coverage) AS data_coverage, 
	CASE WHEN round((sum(v.data_coverage) / ((max(v.end_date) - min(v.start_date)))::numeric) * 100, 1) < 0 
		THEN NULL::numeric 
		WHEN round((sum(v.data_coverage) / ((max(v.end_date) - min(v.start_date)))::numeric) * 100, 1) > 100 
		THEN 100 
		ELSE round((sum(v.data_coverage) / ((max(v.end_date) - min(v.start_date)))::numeric) * 100, 1) END AS percent_coverage,
	sum(CASE WHEN v.missing_info IS NULL THEN 0 
		WHEN "substring"(v.missing_info, 'facility') IS NOT NULL THEN 1 
		ELSE NULL::integer END) AS missing_info_facility,
	min(v.min_lat) AS min_lat, 
	min(v.min_lon) AS min_lon, 
	min(v.min_depth) AS min_depth, 
	max(v.max_depth) AS max_depth, 
	v.site_code 
  FROM anmn_all_deployments_view v
	GROUP BY v.subfacility, v.site_name_code, v.data_category, v.site_code 
	ORDER BY v.subfacility, v.site_code, v.data_category;

grant all on table anmn_data_summary_view to public;
