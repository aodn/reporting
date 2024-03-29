﻿SET search_path = reporting, public;
DROP VIEW IF EXISTS srs_all_deployments_view CASCADE;

-------------------------------
-- VIEW FOR SRS; The dw_srs and srs schema, along with the report.srs_altimetry_manual & report.srs_bio_optical_db_manual tables are not being used anymore.
-------------------------------
-- All deployments view
CREATE or replace VIEW srs_all_deployments_view AS
WITH alt AS (SELECT site_name, instrument, COUNT(*) AS no_measurements FROM srs_altimetry.srs_altimetry_timeseries_data GROUP BY site_name, instrument),
bobdaw AS (SELECT file_id, COUNT(*) AS no_measurements FROM srs_oc_bodbaw.measurements GROUP BY file_id),
gridded AS (
  SELECT 'SRS - Gridded Products' AS subfacility, 
  'SST' AS parameter_site,
  'L3C' AS deployment_code,
  '1 day composite - NOAA-19 - day time' AS sensor_name,
  COUNT(*) AS no_measurements,
  min(date("TIME")) AS start_date, 
  max(date("TIME")) AS end_date, 
  round((date_part('days', (max("TIME") - min("TIME"))) + date_part('hours', (max("TIME") - min("TIME")))/24)::numeric, 1) AS coverage_duration, 
  NULL::numeric AS lat, 
  NULL::numeric AS lon 
  FROM generic_timestep.timestep_url WHERE collection_name = 'srs_ghrsst_l3c_1d_day_n19'
UNION ALL
  SELECT 'SRS - Gridded Products' AS subfacility, 
  'SST' AS parameter_site,
  'L3C' AS deployment_code,
  '1 day composite - NOAA-19 - night time' AS sensor_name,
  COUNT(*) AS no_measurements,
  min(date("TIME")) AS start_date, 
  max(date("TIME")) AS end_date, 
  round((date_part('days', (max("TIME") - min("TIME"))) + date_part('hours', (max("TIME") - min("TIME")))/24)::numeric, 1) AS coverage_duration, 
  NULL::numeric AS lat, 
  NULL::numeric AS lon 
  FROM generic_timestep.timestep_url WHERE collection_name = 'srs_ghrsst_l3c_1d_ngt_n19'
UNION ALL
  SELECT 'SRS - Gridded Products' AS subfacility, 
  'SST' AS parameter_site,
  'L3S' AS deployment_code,
  '1 day composite - day time' AS sensor_name,
  COUNT(*) AS no_measurements,
  min(date("TIME")) AS start_date, 
  max(date("TIME")) AS end_date, 
  round((date_part('days', (max("TIME") - min("TIME"))) + date_part('hours', (max("TIME") - min("TIME")))/24)::numeric, 1) AS coverage_duration, 
  NULL::numeric AS lat, 
  NULL::numeric AS lon 
  FROM generic_timestep.timestep_url WHERE collection_name = 'srs_ghrsst_l3s_1d_day'
UNION ALL
  SELECT 'SRS - Gridded Products' AS subfacility, 
  'SST' AS parameter_site,
  'L3S' AS deployment_code,
  '1 day composite - day and night' AS sensor_name,
  COUNT(*) AS no_measurements,
  min(date("TIME")) AS start_date, 
  max(date("TIME")) AS end_date, 
  round((date_part('days', (max("TIME") - min("TIME"))) + date_part('hours', (max("TIME") - min("TIME")))/24)::numeric, 1) AS coverage_duration, 
  NULL::numeric AS lat, 
  NULL::numeric AS lon 
  FROM generic_timestep.timestep_url WHERE collection_name = 'srs_ghrsst_l3s_1d_dn'
UNION ALL
  SELECT 'SRS - Gridded Products' AS subfacility, 
  'SST' AS parameter_site,
  'L3S' AS deployment_code,
  '1 day composite - night time' AS sensor_name,
  COUNT(*) AS no_measurements,
  min(date("TIME")) AS start_date, 
  max(date("TIME")) AS end_date, 
  round((date_part('days', (max("TIME") - min("TIME"))) + date_part('hours', (max("TIME") - min("TIME")))/24)::numeric, 1) AS coverage_duration, 
  NULL::numeric AS lat, 
  NULL::numeric AS lon 
  FROM generic_timestep.timestep_url WHERE collection_name = 'srs_ghrsst_l3s_1d_ngt'
UNION ALL
  SELECT 'SRS - Gridded Products' AS subfacility, 
  'SST' AS parameter_site,
  'L3S' AS deployment_code,
  '3 day composite - day time' AS sensor_name,
  COUNT(*) AS no_measurements,
  min(date("TIME")) AS start_date, 
  max(date("TIME")) AS end_date, 
  round((date_part('days', (max("TIME") - min("TIME"))) + date_part('hours', (max("TIME") - min("TIME")))/24)::numeric, 1) AS coverage_duration, 
  NULL::numeric AS lat, 
  NULL::numeric AS lon 
  FROM generic_timestep.timestep_url WHERE collection_name = 'srs_ghrsst_l3s_3d_day'
UNION ALL
  SELECT 'SRS - Gridded Products' AS subfacility, 
  'SST' AS parameter_site,
  'L3S' AS deployment_code,
  '3 day composite - day and night' AS sensor_name,
  COUNT(*) AS no_measurements,
  min(date("TIME")) AS start_date, 
  max(date("TIME")) AS end_date, 
  round((date_part('days', (max("TIME") - min("TIME"))) + date_part('hours', (max("TIME") - min("TIME")))/24)::numeric, 1) AS coverage_duration, 
  NULL::numeric AS lat, 
  NULL::numeric AS lon 
  FROM generic_timestep.timestep_url WHERE collection_name = 'srs_ghrsst_l3s_3d_dn'
UNION ALL
  SELECT 'SRS - Gridded Products' AS subfacility, 
  'SST' AS parameter_site,
  'L3S' AS deployment_code,
  '3 day composite - night time' AS sensor_name,
  COUNT(*) AS no_measurements,
  min(date("TIME")) AS start_date, 
  max(date("TIME")) AS end_date, 
  round((date_part('days', (max("TIME") - min("TIME"))) + date_part('hours', (max("TIME") - min("TIME")))/24)::numeric, 1) AS coverage_duration, 
  NULL::numeric AS lat, 
  NULL::numeric AS lon 
  FROM generic_timestep.timestep_url WHERE collection_name = 'srs_ghrsst_l3s_3d_ngt'
UNION ALL
  SELECT 'SRS - Gridded Products' AS subfacility, 
  'SST' AS parameter_site,
  'L3U' AS deployment_code,
  'NOAA-19' AS sensor_name,
  COUNT(*) AS no_measurements,
  min(date("TIME")) AS start_date, 
  max(date("TIME")) AS end_date, 
  round((date_part('days', (max("TIME") - min("TIME"))) + date_part('hours', (max("TIME") - min("TIME")))/24)::numeric, 1) AS coverage_duration, 
  NULL::numeric AS lat, 
  NULL::numeric AS lon 
  FROM generic_timestep.timestep_url WHERE collection_name = 'srs_ghrsst_l3u_n19'
--OC
UNION ALL
  SELECT 'SRS - Gridded Products' AS subfacility, 
  'Chlorophyll a' AS parameter_site,
  'Aqua' AS deployment_code,
  '1 day composite - GSM' AS sensor_name,
  COUNT(*) AS no_measurements,
  min(date("TIME")) AS start_date, 
  max(date("TIME")) AS end_date, 
  round((date_part('days', (max("TIME") - min("TIME"))) + date_part('hours', (max("TIME") - min("TIME")))/24)::numeric, 1) AS coverage_duration, 
  NULL::numeric AS lat, 
  NULL::numeric AS lon 
  FROM generic_timestep.timestep_url WHERE collection_name = 'srs_oc_aqua_chl_gsm'
UNION ALL
  SELECT 'SRS - Gridded Products' AS subfacility, 
  'Chlorophyll a' AS parameter_site,
  'Aqua' AS deployment_code,
  '1 day composite - OC3' AS sensor_name,
  COUNT(*) AS no_measurements,
  min(date("TIME")) AS start_date, 
  max(date("TIME")) AS end_date, 
  round((date_part('days', (max("TIME") - min("TIME"))) + date_part('hours', (max("TIME") - min("TIME")))/24)::numeric, 1) AS coverage_duration, 
  NULL::numeric AS lat, 
  NULL::numeric AS lon 
  FROM generic_timestep.timestep_url WHERE collection_name = 'srs_oc_aqua_chl_oc3'
UNION ALL
  SELECT 'SRS - Gridded Products' AS subfacility, 
  'Chlorophyll a' AS parameter_site,
  'Aqua' AS deployment_code,
  '1 day composite - Nanoplankton (NPP - OC3) - Brewin et al 2010' AS sensor_name,
  COUNT(*) AS no_measurements,
  min(date("TIME")) AS start_date, 
  max(date("TIME")) AS end_date, 
  round((date_part('days', (max("TIME") - min("TIME"))) + date_part('hours', (max("TIME") - min("TIME")))/24)::numeric, 1) AS coverage_duration, 
  NULL::numeric AS lat, 
  NULL::numeric AS lon 
  FROM generic_timestep.timestep_url WHERE collection_name = 'srs_oc_aqua_nanop_brewin2010at'
UNION ALL
  SELECT 'SRS - Gridded Products' AS subfacility, 
  'Chlorophyll a' AS parameter_site,
  'Aqua' AS deployment_code,
  '1 day composite - Nanoplankton (NPP - OC3) - Brewin et al 2012' AS sensor_name,
  COUNT(*) AS no_measurements,
  min(date("TIME")) AS start_date, 
  max(date("TIME")) AS end_date, 
  round((date_part('days', (max("TIME") - min("TIME"))) + date_part('hours', (max("TIME") - min("TIME")))/24)::numeric, 1) AS coverage_duration, 
  NULL::numeric AS lat, 
  NULL::numeric AS lon 
  FROM generic_timestep.timestep_url WHERE collection_name = 'srs_oc_aqua_nanop_brewin2012in'
UNION ALL
  SELECT 'SRS - Gridded Products' AS subfacility, 
  'Chlorophyll a' AS parameter_site,
  'Aqua' AS deployment_code,
  '1 day composite - Eppley-VGPM (NPP - GSM)' AS sensor_name,
  COUNT(*) AS no_measurements,
  min(date("TIME")) AS start_date, 
  max(date("TIME")) AS end_date, 
  round((date_part('days', (max("TIME") - min("TIME"))) + date_part('hours', (max("TIME") - min("TIME")))/24)::numeric, 1) AS coverage_duration, 
  NULL::numeric AS lat, 
  NULL::numeric AS lon 
  FROM generic_timestep.timestep_url WHERE collection_name = 'srs_oc_aqua_npp_vgpm_eppley_gsm'
UNION ALL
  SELECT 'SRS - Gridded Products' AS subfacility, 
  'Chlorophyll a' AS parameter_site,
  'Aqua' AS deployment_code,
  '1 day composite - Eppley-VGPM (NPP - OC3)' AS sensor_name,
  COUNT(*) AS no_measurements,
  min(date("TIME")) AS start_date, 
  max(date("TIME")) AS end_date, 
  round((date_part('days', (max("TIME") - min("TIME"))) + date_part('hours', (max("TIME") - min("TIME")))/24)::numeric, 1) AS coverage_duration, 
  NULL::numeric AS lat, 
  NULL::numeric AS lon 
  FROM generic_timestep.timestep_url WHERE collection_name = 'srs_oc_aqua_npp_vgpm_eppley_oc3'
UNION ALL
  SELECT 'SRS - Gridded Products' AS subfacility, 
  'Chlorophyll a' AS parameter_site,
  'Aqua' AS deployment_code,
  '1 day composite - Picoplankton (NPP - OC3) - Brewin et al 2010' AS sensor_name,
  COUNT(*) AS no_measurements,
  min(date("TIME")) AS start_date, 
  max(date("TIME")) AS end_date, 
  round((date_part('days', (max("TIME") - min("TIME"))) + date_part('hours', (max("TIME") - min("TIME")))/24)::numeric, 1) AS coverage_duration, 
  NULL::numeric AS lat, 
  NULL::numeric AS lon 
  FROM generic_timestep.timestep_url WHERE collection_name = 'srs_oc_aqua_picop_brewin2010at'
UNION ALL
  SELECT 'SRS - Gridded Products' AS subfacility, 
  'Chlorophyll a' AS parameter_site,
  'Aqua' AS deployment_code,
  '1 day composite - Picoplankton (NPP - OC3) - Brewin et al 2012' AS sensor_name,
  COUNT(*) AS no_measurements,
  min(date("TIME")) AS start_date, 
  max(date("TIME")) AS end_date, 
  round((date_part('days', (max("TIME") - min("TIME"))) + date_part('hours', (max("TIME") - min("TIME")))/24)::numeric, 1) AS coverage_duration, 
  NULL::numeric AS lat, 
  NULL::numeric AS lon 
  FROM generic_timestep.timestep_url WHERE collection_name = 'srs_oc_aqua_picop_brewin2012in'
UNION ALL
  SELECT 'SRS - Gridded Products' AS subfacility, 
  'Chlorophyll a' AS parameter_site,
  'Aqua' AS deployment_code,
  '8 day composite' AS sensor_name,
  COUNT(*) AS no_measurements,
  min(date("TIME")) AS start_date, 
  max(date("TIME")) AS end_date, 
  round((date_part('days', (max("TIME") - min("TIME"))) + date_part('hours', (max("TIME") - min("TIME")))/24)::numeric, 1) AS coverage_duration, 
  NULL::numeric AS lat, 
  NULL::numeric AS lon 
  FROM generic_timestep.timestep_url WHERE collection_name = 'srs_oc_contributed_aqua_johnson_8d'
UNION ALL
  SELECT 'SRS - Gridded Products' AS subfacility, 
  'Chlorophyll a' AS parameter_site,
  'SeaWIFS' AS deployment_code,
  '8 day composite' AS sensor_name,
  COUNT(*) AS no_measurements,
  min(date("TIME")) AS start_date, 
  max(date("TIME")) AS end_date, 
  round((date_part('days', (max("TIME") - min("TIME"))) + date_part('hours', (max("TIME") - min("TIME")))/24)::numeric, 1) AS coverage_duration, 
  NULL::numeric AS lat, 
  NULL::numeric AS lon 
  FROM generic_timestep.timestep_url WHERE collection_name = 'srs_oc_contributed_seawifs_johnson_8d'
UNION ALL
  SELECT 'SRS - Gridded Products' AS subfacility, 
  'Chlorophyll a' AS parameter_site,
  'Aqua' AS deployment_code,
  'Monthly composite' AS sensor_name,
  COUNT(*) AS no_measurements,
  min(date("TIME")) AS start_date, 
  max(date("TIME")) AS end_date, 
  round((date_part('days', (max("TIME") - min("TIME"))) + date_part('hours', (max("TIME") - min("TIME")))/24)::numeric, 1) AS coverage_duration, 
  NULL::numeric AS lat, 
  NULL::numeric AS lon 
  FROM generic_timestep.timestep_url WHERE collection_name = 'srs_oc_contributed_aqua_johnson_1m'
UNION ALL
  SELECT 'SRS - Gridded Products' AS subfacility, 
  'Chlorophyll a' AS parameter_site,
  'SeaWIFS' AS deployment_code,
  'Monthly composite' AS sensor_name,
  COUNT(*) AS no_measurements,
  min(date("TIME")) AS start_date, 
  max(date("TIME")) AS end_date, 
  round((date_part('days', (max("TIME") - min("TIME"))) + date_part('hours', (max("TIME") - min("TIME")))/24)::numeric, 1) AS coverage_duration, 
  NULL::numeric AS lat, 
  NULL::numeric AS lon 
  FROM generic_timestep.timestep_url WHERE collection_name = 'srs_oc_contributed_seawifs_johnson_1m'
UNION ALL
  SELECT 'SRS - Gridded Products' AS subfacility, 
  'SST' AS parameter_site,
  'Aqua' AS deployment_code,
  '1 day composite' AS sensor_name,
  COUNT(*) AS no_measurements,
  min(date("TIME")) AS start_date, 
  max(date("TIME")) AS end_date, 
  round((date_part('days', (max("TIME") - min("TIME"))) + date_part('hours', (max("TIME") - min("TIME")))/24)::numeric, 1) AS coverage_duration, 
  NULL::numeric AS lat, 
  NULL::numeric AS lon 
  FROM generic_timestep.timestep_url WHERE collection_name = 'srs_oc_aqua_sst'),
oc AS (SELECT file_id, COUNT(*) AS no_measurements FROM srs_oc_soop_rad.measurements GROUP BY file_id)
  SELECT 'SRS - Altimetry' AS subfacility, 
  m.site_name AS parameter_site, 
  COALESCE(d.site_code || '-' || "substring"((m.instrument), '([^_]+)-')) AS deployment_code, 
  m.instrument AS sensor_name,
  alt.no_measurements,
  min(date(m.time_coverage_start)) AS start_date, 
  max(date(m.time_coverage_end)) AS end_date, 
  round((date_part('days', (max(m.time_coverage_end) - min(m.time_coverage_start))) + date_part('hours', (max(m.time_coverage_end) - min(m.time_coverage_start)))/24)::numeric, 1) AS coverage_duration, 
  round(ST_Y(ST_CENTROID(ST_COLLECT(m.geom)))::numeric, 1) AS lat, 
  round(ST_X(ST_CENTROID(ST_COLLECT(m.geom)))::numeric, 1) AS lon
  FROM srs_altimetry.srs_altimetry_timeseries_map m 
  LEFT JOIN srs_altimetry.deployments d ON d.file_id = m.file_id
  LEFT JOIN alt ON alt.site_name = m.site_name AND alt.instrument = m.instrument
  GROUP BY m.site_name, d.site_code, m.instrument,alt.no_measurements
UNION ALL
  SELECT 'SRS - Bio-optical Database' AS subfacility, 
  m.data_type AS parameter_site, 
  m.cruise_id AS deployment_code, 
  m.vessel_name AS sensor_name,
  b.no_measurements,
  min(date(m.time_coverage_start)) AS start_date, 
  max(date(m.time_coverage_end)) AS end_date, 
  round((date_part('days', (max(m.time_coverage_end) - min(m.time_coverage_start))) + date_part('hours', (max(m.time_coverage_end) - min(m.time_coverage_start)))/24)::numeric, 1) AS coverage_duration, 
  round(ST_Y(ST_CENTROID(ST_COLLECT(m.geom)))::numeric, 1) AS lat, 
  round(ST_X(ST_CENTROID(ST_COLLECT(m.geom)))::numeric, 1) AS lon 
  FROM srs_oc_bodbaw.srs_oc_bodbaw_trajectory_profile_map m
  LEFT JOIN bobdaw b ON b.file_id = m.file_id
  GROUP BY m.data_type, m.cruise_id, m.vessel_name,b.no_measurements
UNION ALL
  SELECT * FROM gridded
UNION ALL
  SELECT 'SRS - Ocean Colour Calibration' AS subfacility, 
  m.vessel_name AS parameter_site, 
  m.voyage_id AS deployment_code, 
  NULL::character varying AS sensor_name,
  SUM(o.no_measurements) AS no_measurements,
  min(date(m.time_start)) AS start_date,
  max(date(m.time_end)) AS end_date, 
  round((date_part('days',max(m.time_end) - min(m.time_start)) + date_part('hours',max(m.time_end) - min(m.time_start))/24)::numeric, 1) AS coverage_duration, 
  round(AVG(ST_Y(ST_CENTROID(m.geom)))::numeric, 1) AS lat, 
  round(AVG(ST_X(ST_CENTROID(m.geom)))::numeric, 1) AS lon 
  FROM srs_oc_soop_rad.visualisation_wms m
  LEFT JOIN oc o ON o.file_id = m.file_id
  GROUP BY parameter_site, voyage_id
UNION ALL
  SELECT 'SRS - Ocean Colour Calibration' AS subfacility, 
  'Lucinda Jetty Coastal Observatory' AS parameter_site, 
  'Aeronet'::text AS deployment_code, 
  NULL::character varying AS sensor_name,
  COUNT(DISTINCT measurement) AS no_measurements,
  min(date(m."TIME")) AS start_date,
  max(date(m."TIME")) AS end_date, 
  round((date_part('days',max(m."TIME") - min(m."TIME")) + date_part('hours',max(m."TIME") - min(m."TIME"))/24)::numeric, 1) AS coverage_duration, 
  round(latitude::numeric, 1) AS lat, 
  round(longitude::numeric, 1) AS lon 
  FROM srs_oc_ljco_aeronet.srs_oc_ljco_aeronet_map m
  GROUP BY file_id,latitude,longitude
UNION ALL
  SELECT 'SRS - Ocean Colour Calibration' AS subfacility,
  'Lucinda Jetty Coastal Observatory' AS parameter_site,
  'WWS'::text AS deployment_code,
  instrument AS sensor_name,
  count(*) as nb_measurements,
  min(time_coverage_start) AS start_date,
  max(time_coverage_end) AS end_date,
  round((date_part('days', (max(time_coverage_end) - min(time_coverage_start))) + date_part('hours', (max(time_coverage_end) - min(time_coverage_start)))/24)::numeric, 1) AS coverage_duration,
  round("LATITUDE"::numeric, 1) AS lat,
  round("LONGITUDE"::numeric, 1) AS lon
  FROM srs_oc_ljco_wws.srs_oc_ljco_wws_all_products_timeseries_map
  GROUP BY instrument, "LATITUDE", "LONGITUDE"
  ORDER BY subfacility, parameter_site, deployment_code, sensor_name, start_date, end_date;

grant all on table srs_all_deployments_view to public;

-- Data summary view
CREATE or replace VIEW srs_data_summary_view AS
 SELECT v.subfacility, 
  CASE WHEN (v.parameter_site = 'absorption') THEN 'Absorption' 
    WHEN (v.parameter_site = 'pigment') THEN 'Pigment'
    WHEN (v.parameter_site = 'backscattering') THEN 'Backscattering' 
    WHEN (v.parameter_site = 'suspended matter') THEN 'Suspended matter' 
    ELSE v.parameter_site END AS parameter_site, 
  count(v.deployment_code) AS no_deployments, 
  CASE WHEN subfacility = 'SRS - Gridded Products' THEN 0 ELSE count(DISTINCT v.sensor_name) END AS no_sensors,
  SUM(no_measurements) AS no_measurements,
  min(v.start_date) AS earliest_date, 
  max(v.end_date) AS latest_date, 
  round(avg(v.coverage_duration), 1) AS mean_coverage_duration,
  round(min(v.coverage_duration), 1) || ' - ' || round(max(v.coverage_duration), 1) AS no_data_days, -- Range in number of data days
  min(v.lon) AS min_lon, 
  max(v.lon) AS max_lon, 
  min(v.lat) AS min_lat, 
  max(v.lat) AS max_lat
  FROM srs_all_deployments_view v
  GROUP BY subfacility, parameter_site 
  ORDER BY subfacility, parameter_site;

grant all on table srs_data_summary_view to public;

-- ALTER VIEW srs_all_deployments_view OWNER TO harvest_reporting_write_group;
-- ALTER VIEW srs_data_summary_view OWNER TO harvest_reporting_write_group;
