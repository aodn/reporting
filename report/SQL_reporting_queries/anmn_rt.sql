SET search_path = reporting, public;
DROP VIEW IF EXISTS anmn_rt_all_deployments_view CASCADE;

-------------------------------
-- VIEW FOR ANMN NRS real-time;
-- The legacy_anmn schema and report.nrs_aims_manual table are not being used for reporting anymore.
-- Using the anmn_platforms_manual table from the report schema
-------------------------------
-- All deployments view
CREATE or replace VIEW anmn_rt_all_deployments_view AS
  WITH site_view AS (
    SELECT DISTINCT
      site_code,
      replace(site_name, 'National Reference Station', 'NRS') AS site_name
    FROM report.anmn_platforms_manual
  )
  SELECT DISTINCT
    CASE WHEN site_code = 'YongalaNRS' THEN 'Yongala NRS'
         WHEN site_code = 'Darwin NRS Buoy' THEN 'Darwin NRS'
         WHEN site_code = 'NRSBEA' THEN 'Beagle Gulf'
         ELSE site_name
    END as site_name,
    COALESCE(data_category||' - '||instrument, data_category, instrument) AS channel_id,
    file_version = '1' AS qaqc_data,
    time_coverage_start AS start_date,
    time_coverage_end AS end_date,
    round((date_part('days', (time_coverage_end - time_coverage_start)) + date_part('hours', (time_coverage_end - time_coverage_start))/24)::numeric, 1) AS coverage_duration,
    CASE WHEN site_code = 'YongalaNRS' THEN 'NRSYON'
         WHEN site_code = 'Darwin NRS Buoy' THEN 'NRSDAR'
         ELSE site_code
    END AS platform_code,
    COALESCE(instrument_nominal_depth::numeric, geospatial_vertical_max::numeric) AS sensor_depth
  FROM anmn_metadata.file_metadata m LEFT JOIN site_view s USING (site_code)
  WHERE realtime AND NOT deleted AND time_coverage_start > '2000-01-01'
  ORDER BY site_name, channel_id, start_date;

grant all on table anmn_rt_all_deployments_view to public;

-- Data summary view
CREATE or replace VIEW anmn_rt_data_summary_view AS
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
  FROM anmn_rt_all_deployments_view v
	GROUP BY v.site_name  
	ORDER BY site_name;

grant all on table anmn_rt_data_summary_view to public;
