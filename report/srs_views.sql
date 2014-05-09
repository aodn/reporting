SET search_path = report_test, pg_catalog, public, srs;

CREATE or replace VIEW srs_all_deployments_view AS
  SELECT 'SRS - Altimetry' AS subfacility, 
	m.site_name AS parameter_site, 
	COALESCE(d.site_code || '-' || "substring"((d.instrument), '([^_]+)-')) AS deployment_code, 
	m.instrument AS sensor_name,
	date(m.time_start) AS start_date, 
	date(m.time_end) AS end_date, 
	(date_part('days', (m.time_end - m.time_start)))::numeric AS coverage_duration, 
	round((ST_Y(m.geom))::numeric, 1) AS lat, 
	round((ST_X(m.geom))::numeric, 1) AS lon 
  FROM srs_altimetry.srs_altimetry_timeseries_map m 
  LEFT JOIN srs_altimetry.deployments d ON d.file_id = m.file_id

UNION ALL 

  SELECT 'SRS - BioOptical database' AS subfacility, 
	m.data_type AS parameter_site, 
	m.cruise_id AS deployment_code, 
	m.vessel_name AS sensor_name, 
	date(m.time_start) AS start_date, 
	date(m.time_end) AS end_date, 
	(date_part('days', (m.time_end - m.time_start)))::numeric AS coverage_duration, 
	round(ST_Y(ST_CENTROID(m.geom))::numeric, 1) AS lat, 
	round(ST_X(ST_CENTROID(m.geom))::numeric, 1) AS lon 
  FROM srs_oc_bodbaw.srs_oc_bodbaw_trajectory_profile_map m 

UNION ALL 

  SELECT 'SRS - Gridded Products' AS subfacility, 
	CASE WHEN ((srs_gridded_products_manual.product_name) = 'MODIS Aqua OC3 Chlorophyll-a') THEN 'Chlorophyll-a' 
	WHEN ((srs_gridded_products_manual.product_name) = 'SST L3C') THEN 'SST' 
	WHEN ((srs_gridded_products_manual.product_name) = 'SST L3P - 14 days mosaic') THEN 'SST' 
	ELSE NULL END AS parameter_site, 
	CASE WHEN ((srs_gridded_products_manual.product_name) = 'MODIS Aqua OC3 Chlorophyll-a') THEN 'MODIS Aqua OC3' 
	WHEN ((srs_gridded_products_manual.product_name) = 'SST L3C') THEN 'L3C' 
	WHEN ((srs_gridded_products_manual.product_name) = 'SST L3P - 14 days mosaic') THEN 'L3P - 14 days mosaic' 
	ELSE NULL END AS deployment_code, 
	NULL::character varying AS sensor_name, 
	date(srs_gridded_products_manual.deployment_start) AS start_date, 
	CASE WHEN date(srs_gridded_products_manual.deployment_end) IS NULL THEN date( to_char(now(),'DD/MM/YYYY')) END AS end_date, 
	((srs_gridded_products_manual.deployment_end - srs_gridded_products_manual.deployment_start))::numeric AS coverage_duration, 
	NULL::numeric AS lat, 
	NULL::numeric AS lon 
  FROM report.srs_gridded_products_manual 

UNION ALL 

  SELECT 'SRS - Ocean Colour' AS subfacility, 
	m.vessel_name AS parameter_site, 
	m.voyage_id AS deployment_code, 
	NULL::character varying AS sensor_name, 
	min(date(m.time_start)) AS start_date,
	max(date(m.time_end)) AS end_date, 
	((max(date(m.time_end)) - min(date(m.time_start))))::numeric AS coverage_duration, 
	round(AVG(ST_Y(ST_CENTROID(m.geom)))::numeric, 1) AS lat, 
	round(AVG(ST_X(ST_CENTROID(m.geom)))::numeric, 1) AS lon 
  FROM srs_oc_soop_rad.visualisation_wms m
	GROUP BY parameter_site, voyage_id 
	ORDER BY subfacility, parameter_site, deployment_code, sensor_name, start_date, end_date;

grant all on table srs_all_deployments_view to public;

CREATE or replace VIEW srs_data_summary_view AS
 SELECT v.subfacility, 
	CASE WHEN (v.parameter_site = 'absorption') THEN 'Absorption' 
		WHEN (v.parameter_site = 'pigment') THEN 'Pigment' 
		ELSE v.parameter_site END AS parameter_site, 
	count(v.deployment_code) AS no_deployments, 
	count(DISTINCT v.sensor_name) AS no_sensors, 
	min(v.start_date) AS earliest_date, 
	max(v.end_date) AS latest_date, 
	round(avg(v.coverage_duration), 1) AS mean_coverage_duration, 
	min(v.lon) AS min_lon, 
	max(v.lon) AS max_lon, 
	min(v.lat) AS min_lat, 
	max(v.lat) AS max_lat
  FROM srs_all_deployments_view v
	GROUP BY subfacility, parameter_site 
	ORDER BY subfacility, parameter_site;

grant all on table srs_data_summary_view to public;