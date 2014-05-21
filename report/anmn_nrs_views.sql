SET search_path =report_test, public;

CREATE or replace VIEW anmn_nrs_realtime_all_deployments_view AS
  SELECT DISTINCT CASE WHEN site_code = 'NRSMAI' THEN 'Maria Island'
	      WHEN site_code = 'NRSYON' OR site_code = 'YongalaNRS' THEN 'Yongala'
	      WHEN site_code = 'NRSDAR' THEN 'Darwin'
	      WHEN site_code = 'NRSNSI' THEN 'North Stradbroke Island' END as site_name,
	 CASE WHEN source = instrument THEN source
	      ELSE COALESCE(source || '-' || instrument) END AS channel_id,
	 CASE WHEN substring(file_version,'[0-9]+') = '1' THEN true
	      ELSE false END AS qaqc_data,
	 time_coverage_start AS start_date,
	 time_coverage_end AS end_date,
	 (date_part('day', (time_coverage_end - time_coverage_start)))::numeric AS coverage_duration,
	 CASE WHEN site_code = 'YongalaNRS' THEN 'NRSYON' ELSE site_code END AS platform_code,
	 CASE WHEN instrument_nominal_depth IS NULL THEN geospatial_vertical_max::numeric 
	      ELSE instrument_nominal_depth::numeric END AS sensor_depth
  FROM dw_anmn_realtime.anmn_mv
	 ORDER BY site_name, channel_id, start_date;

grant all on table anmn_nrs_realtime_all_deployments_view to public;

CREATE or replace VIEW anmn_nrs_realtime_data_summary_view AS
  SELECT v.site_name AS site_name,
	COUNT(DISTINCT(channel_id)) AS nb_channels,
	sum(CASE WHEN v.qaqc_data = true THEN 1 ELSE 0 END) AS no_qc_data, 
	COALESCE(min(v.sensor_depth) || '-' || max(v.sensor_depth)) AS depth_range, 
	min(v.start_date) AS earliest_date, 
	max(v.end_date) AS latest_date, 
	round(avg(v.coverage_duration), 1) AS mean_coverage_duration,
	min(v.sensor_depth) AS min_depth, 
	max(v.sensor_depth) AS max_depth 
  FROM anmn_nrs_realtime_all_deployments_view v
	WHERE channel_id != 'Not Specified Not Specified'
	GROUP BY v.site_name	
	ORDER BY site_name;

grant all on table anmn_nrs_realtime_data_summary_view to public;