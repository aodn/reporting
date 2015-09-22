SET search_path = report_test, public;
DROP VIEW IF EXISTS anmn_nrs_realtime_all_deployments_view CASCADE;

-------------------------------
-- VIEW FOR ANMN NRS real-time; The legacy_anmn schema and report.nrs_aims_manual table are not being used for reporting anymore.
-------------------------------
-- All deployments view
CREATE or replace VIEW anmn_nrs_realtime_all_deployments_view AS
  SELECT DISTINCT CASE WHEN site_code = 'NRSMAI' THEN 'Maria Island'
        WHEN site_code = 'NRSYON' OR site_code = 'YongalaNRS' THEN 'Yongala'
        WHEN site_code = 'NRSDAR' OR site_code = 'Darwin NRS Buoy' THEN 'Darwin'
        WHEN site_code = 'NRSNSI' THEN 'North Stradbroke Island' END as site_name,
   CASE WHEN source = instrument THEN source
        ELSE COALESCE(source || '-' || instrument) END AS channel_id,
   CASE WHEN substring(file_version,'[0-9]+') = '1' THEN true
        ELSE false END AS qaqc_data,
   time_coverage_start AS start_date,
   time_coverage_end AS end_date,
   round((date_part('days', (time_coverage_end - time_coverage_start)) + date_part('hours', (time_coverage_end - time_coverage_start))/24)::numeric, 1) AS coverage_duration,
   CASE WHEN site_code = 'YongalaNRS' THEN 'NRSYON' WHEN site_code = 'Darwin NRS Buoy' THEN 'NRSDAR' ELSE site_code END AS platform_code,
   CASE WHEN instrument_nominal_depth IS NULL THEN geospatial_vertical_max::numeric 
        ELSE instrument_nominal_depth::numeric END AS sensor_depth
  FROM dw_anmn_realtime.anmn_mv
  WHERE time_coverage_start > '2000-01-01'
   ORDER BY site_name, channel_id, start_date;

grant all on table anmn_nrs_realtime_all_deployments_view to public;

-- Data summary view
CREATE or replace VIEW anmn_nrs_realtime_data_summary_view AS
  SELECT v.site_name AS site_name,
	COUNT(DISTINCT(channel_id)) AS nb_channels,
	sum(CASE WHEN v.qaqc_data = true THEN 1 ELSE 0 END) AS no_qc_data,
	sum(CASE WHEN v.qaqc_data = false THEN 1 ELSE 0 END) AS no_non_qc_data, 
	COALESCE(min(v.sensor_depth) || '-' || max(v.sensor_depth)) AS depth_range, 
	min(v.start_date) AS earliest_date, 
	max(v.end_date) AS latest_date, 
	round(avg(v.coverage_duration), 1) AS mean_coverage_duration,
	round(min(v.coverage_duration), 1) || ' - ' || round(max(v.coverage_duration), 1) AS no_data_days, -- Range in number of data days
	min(v.sensor_depth) AS min_depth, 
	max(v.sensor_depth) AS max_depth 
  FROM anmn_nrs_realtime_all_deployments_view v
	GROUP BY v.site_name  
	ORDER BY site_name;

grant all on table anmn_nrs_realtime_data_summary_view to public;