SET search_path = report_test, pg_catalog, public;

CREATE or replace VIEW anmn_nrs_realtime_all_deployments_view AS
SELECT 
 COALESCE(nrs_platforms.platform_code || ' - Lat / Lon: ' || round(nrs_platforms.lat::numeric, 1) || ' / ' || round(nrs_platforms.lon::numeric, 1)) AS site_name, 
 nrs_parameters.parameter, 
 nrs_parameters.channelid AS channel_id, 
 round(nrs_parameters.depth_sensor::numeric, 1) AS sensor_depth, 
 CASE WHEN nrs_parameters.qaqc_boolean = 1 THEN true 
	ELSE false END AS qaqc_data, 
 CASE WHEN date_part('day', (nrs_parameters.time_coverage_end - nrs_parameters.time_coverage_start)) IS NULL THEN 'Missing dates' 
	WHEN nrs_parameters.metadata_uuid IS NULL THEN 'No metadata' 
	ELSE NULL END AS missing_info, 
 date(nrs_parameters.time_coverage_start) AS start_date, 
 date(nrs_parameters.time_coverage_end) AS end_date, 
 (date_part('day', (nrs_parameters.time_coverage_end - nrs_parameters.time_coverage_start)))::numeric AS coverage_duration, 
 (date_part('day', (nrs_aims_manual.data_on_staging - nrs_parameters.time_coverage_start)))::numeric AS days_to_process_and_upload, 
 (date_part('day', (nrs_aims_manual.data_on_portal - nrs_aims_manual.data_on_staging)))::numeric AS days_to_make_public, 
 nrs_platforms.platform_code, 
 round(nrs_platforms.lat::numeric, 1) AS lat, 
 round(nrs_platforms.lon::numeric, 1) AS lon, 
 date(nrs_aims_manual.data_on_staging) AS date_on_staging, 
 date(nrs_aims_manual.data_on_opendap) AS date_on_opendap, 
 date(nrs_aims_manual.data_on_portal) AS date_on_portal, 
 nrs_aims_manual.mest_creation, 
 nrs_parameters.no_qaqc_boolean AS no_qaqc_data, 
 nrs_parameters.metadata_uuid AS channel_uuid 
 FROM legacy_anmn.nrs_parameters 
 LEFT JOIN legacy_anmn.nrs_platforms ON nrs_platforms.pkid = nrs_parameters.fk_nrs_platforms 
 LEFT JOIN report.nrs_aims_manual ON nrs_aims_manual.platform_name = nrs_platforms.platform_code
 ORDER BY site_name, parameter, channel_id;

grant all on table anmn_nrs_realtime_all_deployments_view to public;


CREATE or replace VIEW anmn_nrs_realtime_data_summary_view AS
 SELECT 
 v.platform_code AS site_name, 
 count(DISTINCT v.channel_id) AS no_sensors, 
 count(DISTINCT v.parameter) AS no_parameters, 
 sum(CASE WHEN v.qaqc_data = true THEN 1 ELSE 0 END) AS no_qc_data, 
 COALESCE(min(v.sensor_depth) || '-' || max(v.sensor_depth)) AS depth_range, 
 min(v.start_date) AS earliest_date, 
 max(v.end_date) AS latest_date, 
 round(avg(v.coverage_duration), 1) AS mean_coverage_duration, 
 round(avg(v.days_to_process_and_upload), 1) AS mean_days_to_process_and_upload, 
 round(avg(v.days_to_make_public), 1) AS mean_days_to_make_public, 
 sum(CASE WHEN v.missing_info IS NULL THEN 0 ELSE 1 END) AS no_missing_info, 
 min(v.sensor_depth) AS min_depth, 
 max(v.sensor_depth) AS max_depth 
 FROM anmn_nrs_realtime_all_deployments_view v
 GROUP BY v.platform_code 
 ORDER BY platform_code;

grant all on table anmn_nrs_realtime_data_summary_view to public;