SET search_path = reporting, public;
DROP TABLE IF EXISTS totals_view CASCADE;

-------------------------------
-- TOTALS VIEW
-------------------------------
CREATE TABLE totals_view AS
WITH i AS (
  SELECT COUNT(DISTINCT(parameter)) AS no_parameters, 
	SUM(qaqc) AS qaqc, 
	SUM(no_qaqc) AS no_qaqc
  FROM faimms_all_deployments_view),
  bgc_chemistry AS (
  SELECT SUM(ntrip_total)::numeric AS no_chemistry_trips
  FROM anmn_nrs_bgc_data_summary_view
	WHERE product = 'Chemistry'),
  bgc_phypig AS (
  SELECT SUM(ntrip_total)::numeric AS no_phypig_trips
  FROM anmn_nrs_bgc_data_summary_view
	WHERE product = 'Phytoplankton pigment'),
  bgc_phytoplankton AS (
  SELECT SUM(ntrip_total)::numeric AS no_phytoplankton_trips
  FROM anmn_nrs_bgc_data_summary_view
	WHERE product = 'Phytoplankton'),
    bgc_zooplankton AS (
  SELECT SUM(ntrip_total)::numeric AS no_zooplankton_trips
  FROM anmn_nrs_bgc_data_summary_view
	WHERE product = 'Zooplankton'),
    bgc_picoplankton AS (
  SELECT SUM(ntrip_total)::numeric AS no_picoplankton_trips
  FROM anmn_nrs_bgc_data_summary_view
	WHERE product = 'Picoplankton'),
    bgc_plankton_biomass AS (
  SELECT SUM(ntrip_total)::numeric AS no_plankton_biomass_trips
  FROM anmn_nrs_bgc_data_summary_view
	WHERE product = 'Plankton biomass'),
    bgc_suspended_matter AS (
  SELECT SUM(ntrip_total)::numeric AS no_suspended_matter_trips
  FROM anmn_nrs_bgc_data_summary_view
	WHERE product = 'Suspended matter'),
    total AS (SELECT t FROM aatams_acoustic_stats_view WHERE statistics_type = 'no unique tag ids detected'),
    total_public AS (SELECT t FROM aatams_acoustic_stats_view WHERE statistics_type = 'no unique registered tag ids'),
    total_embargo AS (SELECT t FROM aatams_acoustic_stats_view WHERE statistics_type = 'no unique tag ids detected that aatams knows about'),
    detections_total AS (SELECT t FROM aatams_acoustic_stats_view WHERE statistics_type = 'tags detected by species'),
    detections_public AS (SELECT embargo_1 AS t FROM aatams_acoustic_embargo_totals_view WHERE type ='Tags'),
    detections_embargo AS (SELECT embargo_2 AS t FROM aatams_acoustic_embargo_totals_view WHERE type ='Tags'),
    other_1 AS (SELECT embargo_3 AS t FROM aatams_acoustic_embargo_totals_view WHERE type ='Tags'),
    other_2 AS (SELECT embargo_3_more AS t FROM aatams_acoustic_embargo_totals_view WHERE type ='Tags'),
    bgc_stats AS (
  SELECT to_char(min(first_sample),'DD/MM/YYYY') AS first_sample,
	to_char(max(last_sample),'DD/MM/YYYY') AS last_sample,
	min(lon) AS min_lon,
	max(lon) AS max_lon,
	min(lat) AS min_lat,
	max(lat) AS max_lat,
	min(min_depth) AS min_depth,
	max(max_depth) AS max_depth
  FROM anmn_nrs_bgc_data_summary_view)

-- AATAMS - Acoustic
  SELECT 'AATAMS' AS facility,
	'Acoustic tagging - Project' AS subfacility,
	funding_type::text AS type,
	no_projects::bigint AS no_projects,
	no_installations::numeric AS no_platforms,
	no_stations::numeric AS no_instruments,
	no_deployments::numeric AS no_deployments,
	no_releases::numeric AS no_data,
	no_detections::numeric AS no_data2,
	NULL::numeric AS no_data3,
	NULL::numeric AS no_data4,
	NULL AS temporal_range,
	NULL AS lat_range,
	NULL AS lon_range,
	NULL AS depth_range
  FROM aatams_acoustic_project_totals_view
    
UNION ALL

  SELECT 'AATAMS' AS facility,
	'Acoustic tagging - Species' AS subfacility,
	'Other stats' AS type,
	total.t AS no_projects,
	total_public.t AS no_platforms,
	total_embargo.t AS no_instruments,
	detections_total.t AS no_deployments,
	detections_public.t AS no_data,
	detections_embargo.t AS no_data2,
	other_1.t AS no_data3,
	other_2.t AS no_data4,
	NULL AS temporal_range,
	NULL AS lat_range,
	NULL AS lon_range,
	NULL AS depth_range
  FROM total, total_public, total_embargo, detections_total, detections_public, detections_embargo, other_1, other_2
  
-- AATAMS - Satellite tagging
UNION ALL  

  SELECT 'AATAMS' AS facility,
	'Biologging' AS subfacility,
	data_type AS type,
	COUNT(DISTINCT(sattag_program)) AS no_projects,
	COUNT(DISTINCT(species_name)) AS no_platforms,
	COUNT(DISTINCT(tag_type)) AS no_instruments,
	SUM(no_animals) AS no_deployments,
	SUM(total_nb_profiles) AS no_data,
	SUM(total_nb_measurements) AS no_data2,
	NULL::numeric AS no_data3,
	NULL::numeric AS no_data4,
	COALESCE(to_char(min(coverage_start),'DD/MM/YYYY')||' - '||to_char(max(coverage_end),'DD/MM/YYYY')) AS temporal_range,
	COALESCE(min(min_lat)||' - '||max(max_lat)) AS lat_range,
	COALESCE(min(min_lon)||' - '||max(max_lon)) AS lon_range,
	COALESCE(min(min_depth)||' - '||max(max_depth)) AS depth_range
  FROM aatams_sattag_data_summary_view
	GROUP BY data_type
    
UNION ALL

  SELECT 'AATAMS' AS facility,
	'Biologging' AS subfacility,
	'TOTAL' AS type,
	COUNT(DISTINCT(sattag_program)) AS no_projects,
	COUNT(DISTINCT(species_name)) AS no_platforms,
	COUNT(DISTINCT(tag_type)) AS no_instruments,
	COUNT(DISTINCT(tag_code)) AS no_deployments,
	SUM(nb_profiles) AS no_data,
	SUM(nb_measurements) AS no_data2,
	NULL::numeric AS no_data3,
	NULL::numeric AS no_data4,
	COALESCE(to_char(min(coverage_start),'DD/MM/YYYY')||' - '||to_char(max(coverage_end),'DD/MM/YYYY')) AS temporal_range,
	COALESCE(min(min_lat)||' - '||max(max_lat)) AS lat_range,
	COALESCE(min(min_lon)||' - '||max(max_lon)) AS lon_range,
	COALESCE(min(min_depth)||' - '||max(max_depth)) AS depth_range
  FROM aatams_sattag_all_deployments_view

-- AATAMS - Biologging
UNION ALL  

  SELECT 'AATAMS' AS facility,
	'Biologging' AS subfacility,
	tagged_animals AS type,
	NULL AS no_projects,
	nb_animals AS no_platforms,
	NULL AS no_instruments,
	NULL AS no_deployments,
	total_nb_locations AS no_data,
	NULL AS no_data2,
	NULL::numeric AS no_data3,
	NULL::numeric AS no_data4,
	COALESCE(to_char(date(earliest_date),'DD/MM/YYYY')||' - '||to_char(date(latest_date),'DD/MM/YYYY')) AS temporal_range,
	COALESCE(min_lat||' - '||max_lat) AS lat_range,
	COALESCE(min_lon||' - '||max_lon) AS lon_range,
	NULL AS depth_range
  FROM aatams_biologging_data_summary_view
    
-- DWM
UNION ALL

  SELECT 'DWM' AS facility,
	sub_facility AS subfacility,
	file_type AS type,
	NULL AS no_projects,
	COUNT(DISTINCT(platform_code)) AS no_platforms,
	COUNT(DISTINCT(data_category)) AS no_instruments,
	SUM(no_deployments) AS no_deployments,
	SUM(no_fv1) AS no_data,
	SUM(no_fv2) AS no_data2,
	SUM(data_coverage) AS no_data3,
	NULL::numeric AS no_data4,
	COALESCE(to_char(min(coverage_start),'DD/MM/YYYY')||' - '||to_char(max(coverage_end),'DD/MM/YYYY')) AS temporal_range,
	NULL AS lat_range,
	NULL AS lon_range,
	NULL AS depth_range
  FROM dwm_data_summary_view
	GROUP BY sub_facility, file_type

UNION ALL

  SELECT 'DWM' AS facility,
	NULL AS subfacility,
	'TOTAL' AS type,
	NULL::BIGINT AS no_projects,
	COUNT(DISTINCT(platform_code)) AS no_platforms,
	COUNT(DISTINCT(data_category)) AS no_instruments,
	SUM(no_deployments) AS no_deployments,
	SUM(no_fv1) AS no_data,
	SUM(no_fv2) AS no_data2,
	SUM(data_coverage) AS no_data3,
	NULL::numeric AS no_data4,
	COALESCE(to_char(min(coverage_start),'DD/MM/YYYY')||' - '||to_char(max(coverage_end),'DD/MM/YYYY')) AS temporal_range,
	NULL AS lat_range,
	NULL AS lon_range,
	NULL AS depth_range
  FROM dwm_data_summary_view

-- ACORN
UNION ALL

  SELECT 'ACORN' AS facility,
	NULL AS subfacility,
	data_type AS type,
	COUNT(DISTINCT(site)) AS no_projects,
	NULL::numeric AS no_platforms,
	NULL::bigint AS no_instruments,
	NULL::bigint AS no_deployments,
	SUM(total_no_files) AS no_data,
	round(((max(time_end)-min(time_start))/365.25)::numeric, 1) AS no_data2,
	SUM(coverage_duration) AS no_data3,
	NULL::numeric AS no_data4,
	COALESCE(to_char(min(time_start),'DD/MM/YYYY')||' - '||to_char(max(time_end),'DD/MM/YYYY')) AS temporal_range,
	NULL AS lat_range,
	NULL AS lon_range,
	NULL AS depth_range
  FROM acorn_hourly_vectors_data_summary_view
	GROUP BY data_type

UNION ALL

  SELECT 'ACORN' AS facility,
	NULL AS subfacility,
	'TOTAL - Hourly vectors' AS type,
	COUNT(DISTINCT(site)) AS no_projects,
	NULL::numeric AS no_platforms,
	NULL::bigint AS no_instruments,
	NULL::bigint AS no_deployments,
	SUM(no_files) AS no_data,
	round(((max(time_end)-min(time_start))/365.25)::numeric, 1) AS no_data2,
	round((SUM(coverage_duration)/365.25)::numeric, 1) AS no_data3,
	NULL::numeric AS no_data4,
	COALESCE(to_char(min(time_start),'DD/MM/YYYY')||' - '||to_char(max(time_end),'DD/MM/YYYY')) AS temporal_range,
	NULL AS lat_range,
	NULL AS lon_range,
	NULL AS depth_range
  FROM acorn_hourly_vectors_all_deployments_view

UNION ALL

  SELECT 'ACORN' AS facility,
	NULL AS subfacility,
	data_type AS type,
	COUNT(DISTINCT(site)) AS no_projects,
	COUNT(DISTINCT(platform_code)) AS no_platforms,
	NULL::bigint AS no_instruments,
	NULL::bigint AS no_deployments,
	SUM(total_no_files) AS no_data,
	round(((max(time_end)-min(time_start))/365.25)::numeric, 1) AS no_data2,
	SUM(coverage_duration) AS no_data3,
	NULL::numeric AS no_data4,
	COALESCE(to_char(min(time_start),'DD/MM/YYYY')||' - '||to_char(max(time_end),'DD/MM/YYYY')) AS temporal_range,
	NULL AS lat_range,
	NULL AS lon_range,
	NULL AS depth_range
  FROM acorn_radials_data_summary_view
	GROUP BY data_type


UNION ALL

  SELECT 'ACORN' AS facility,
	NULL AS subfacility,
	'TOTAL - Radials' AS type,
	COUNT(DISTINCT(site)) AS no_projects,
	COUNT(DISTINCT(platform_code)) AS no_platforms,
	NULL::bigint AS no_instruments,
	NULL::bigint AS no_deployments,
	SUM(no_files) AS no_data,
	round(((max(time_end)-min(time_start))/365.25)::numeric, 1) AS no_data2,
	round((SUM(coverage_duration)/365.25)::numeric, 1) AS no_data3,
	NULL::numeric AS no_data4,
	COALESCE(to_char(min(time_start),'DD/MM/YYYY')||' - '||to_char(max(time_end),'DD/MM/YYYY')) AS temporal_range,
	NULL AS lat_range,
	NULL AS lon_range,
	NULL AS depth_range
  FROM acorn_radials_all_deployments_view

-- ANFOG
UNION ALL

SELECT 'ANFOG' AS facility,
	NULL AS subfacility,
	data_type AS type,
	NULL::bigint AS no_projects,
	COUNT(DISTINCT deployment_location) AS no_platforms,
	NULL::bigint AS no_instruments,
	SUM(no_deployments) AS no_deployments,
	SUM(no_measurements) AS no_data,
	SUM(no_slocum_deployments) AS no_data2,
	SUM(no_seaglider_deployments) AS no_data3,
	NULL::numeric AS no_data4,
	COALESCE(to_char(min(earliest_date),'DD/MM/YYYY')||' - '||to_char(max(latest_date),'DD/MM/YYYY')) AS temporal_range,
	COALESCE(min(min_lat)||' - '||max(max_lat)) AS lat_range,
	COALESCE(min(min_lon)||' - '||max(max_lon)) AS lon_range,
	COALESCE(min(min_depth)||' - '||max(max_depth)) AS depth_range
  FROM anfog_data_summary_view
	GROUP BY data_type

UNION ALL

SELECT 'ANFOG' AS facility,
	NULL AS subfacility,
	deployment_state AS type,
	NULL::bigint AS no_projects,
	COUNT(DISTINCT deployment_location) AS no_platforms,
	NULL::bigint AS no_instruments,
	SUM(no_deployments) AS no_deployments,
	SUM(no_measurements) AS no_data,
	SUM(no_slocum_deployments) AS no_data2,
	SUM(no_seaglider_deployments) AS no_data3,
	NULL::numeric AS no_data4,
	COALESCE(to_char(min(earliest_date),'DD/MM/YYYY')||' - '||to_char(max(latest_date),'DD/MM/YYYY')) AS temporal_range,
	COALESCE(min(min_lat)||' - '||max(max_lat)) AS lat_range,
	COALESCE(min(min_lon)||' - '||max(max_lon)) AS lon_range,
	COALESCE(min(min_depth)||' - '||max(max_depth)) AS depth_range
  FROM anfog_data_summary_view
	GROUP BY deployment_state

UNION ALL

  SELECT 'ANFOG' AS facility,
	NULL AS subfacility,
	'TOTAL' AS type,
	NULL::bigint AS no_projects,
	COUNT(DISTINCT(deployment_location)) AS no_platforms,
	NULL::bigint AS no_instruments,
	count(DISTINCT COALESCE (platform || '-' || deployment_id)) AS no_deployments,
	SUM(no_measurements) AS no_data,
	SUM(CASE WHEN glider_type = 'slocum glider' THEN 1 ELSE 0 END) AS no_data2,
	SUM(CASE WHEN glider_type = 'seaglider' THEN 1 ELSE 0 END) AS no_data3,
	NULL::numeric AS no_data4,
	COALESCE(to_char(min(start_date),'DD/MM/YYYY')||' - '||to_char(max(end_date),'DD/MM/YYYY')) AS temporal_range,
	COALESCE(min(min_lat)||' - '||max(max_lat)) AS lat_range,
	COALESCE(min(min_lon)||' - '||max(max_lon)) AS lon_range,
	COALESCE(min(max_depth)||' - '||max(max_depth)) AS depth_range
  FROM anfog_all_deployments_view

-- ANMN
UNION ALL

  SELECT 'ANMN' AS facility,
	subfacility AS subfacility,
	NULL AS type,
	COUNT(DISTINCT(site_name_code)) AS no_projects,
	NULL AS no_platforms,
	COUNT(DISTINCT(data_category)) AS no_instruments,
	SUM(no_deployments) AS no_deployments,
	SUM(no_fv00) AS no_data,
	SUM(no_fv01) AS no_data2,
	SUM(data_coverage) AS no_data3,
	NULL::numeric AS no_data4,
	COALESCE(to_char(min(earliest_date),'DD/MM/YYYY')||' - '||to_char(max(latest_date),'DD/MM/YYYY')) AS temporal_range,
	COALESCE(min(min_lat)||' - '||max(min_lat)) AS lat_range,
	COALESCE(min(min_lon)||' - '||max(min_lon)) AS lon_range,
	COALESCE(min(min_depth)||' - '||max(max_depth)) AS depth_range
  FROM anmn_data_summary_view
	GROUP BY subfacility
  
UNION ALL

  SELECT 'ANMN' AS facility,
	'NRS, RMA, and AM' AS subfacility,
	'TOTAL' AS type,
	COUNT(DISTINCT(site_name_code)) AS no_projects,
	NULL AS no_platforms,
	COUNT(DISTINCT(data_category)) AS no_instruments,
	SUM(no_deployments) AS no_deployments,
	SUM(no_fv00) AS no_data,
	SUM(no_fv01) AS no_data2,
	SUM(data_coverage) AS no_data3,
	NULL::numeric AS no_data4,
	COALESCE(to_char(min(earliest_date),'DD/MM/YYYY')||' - '||to_char(max(latest_date),'DD/MM/YYYY')) AS temporal_range,
	COALESCE(min(min_lat)||' - '||max(min_lat)) AS lat_range,
	COALESCE(min(min_lon)||' - '||max(min_lon)) AS lon_range,
	COALESCE(min(min_depth)||' - '||max(max_depth)) AS depth_range
  FROM anmn_data_summary_view

-- ANMN - Passive Acoustic
UNION ALL

  SELECT 'ANMN' AS facility,
	'PA' AS subfacility,
	'TOTAL' AS type,
	COUNT(DISTINCT(site_name)) AS no_projects,
	NULL AS no_platforms,
	SUM(no_loggers) AS no_instruments,
	COUNT(*) AS no_deployments,
	SUM(no_good_data) AS no_data,
	SUM(no_sets_on_viewer) AS no_data2,
	SUM(coverage_duration) AS no_data3,
	NULL::numeric AS no_data4,
	COALESCE(to_char(min(earliest_date),'DD/MM/YYYY')||' - '||to_char(max(latest_date),'DD/MM/YYYY')) AS temporal_range,
	NULL AS lat_range,
	NULL AS lon_range,
	NULL AS depth_range
  FROM anmn_acoustics_data_summary_view
  
-- ANMN - Real-Time
UNION ALL

  SELECT 'ANMN' AS facility,
	'NRS - Real-Time' AS subfacility,
	'TOTAL' AS type,
	COUNT(*) AS no_projects,
	NULL AS no_platforms,
	SUM(nb_channels) AS no_instruments,
	NULL AS no_deployments,
	SUM(no_qc_data) AS no_data,
	SUM(no_non_qc_data) AS no_data2,
	NULL::numeric AS no_data3,
	NULL::numeric AS no_data4,
	COALESCE(to_char(min(earliest_date),'DD/MM/YYYY')||' - '||to_char(max(latest_date),'DD/MM/YYYY')) AS temporal_range,
	NULL AS lat_range,
	NULL AS lon_range,
	COALESCE(min(min_depth)||' - '||max(max_depth)) AS depth_range
  FROM anmn_rt_data_summary_view

-- ANMN - NRS BGC
UNION ALL

  SELECT 'ANMN' AS facility,
	'BGC' AS subfacility,
	'TOTAL' AS type,
	no_chemistry_trips AS no_projects,
	no_phypig_trips AS no_platforms,
	no_phytoplankton_trips AS no_instruments,
	no_zooplankton_trips AS no_deployments,
	no_picoplankton_trips AS no_data,
	no_plankton_biomass_trips AS no_data2,
	no_suspended_matter_trips AS no_data3,
	NULL AS no_data4,
	COALESCE(first_sample||' - '||last_sample) AS temporal_range,
	COALESCE(min_lat||' - '||max_lat) AS lat_range,
	COALESCE(min_lon||' - '||max_lon) AS lon_range,
	COALESCE(min_depth||' - '||max_depth) AS depth_range
  FROM bgc_chemistry, bgc_phypig, bgc_phytoplankton, bgc_zooplankton, bgc_picoplankton, bgc_plankton_biomass, bgc_suspended_matter, bgc_stats

-- Argo
UNION ALL

  SELECT 'Argo' AS facility,
	NULL AS subfacility,
	'TOTAL' AS type,
	COUNT(*) AS no_projects,
	SUM(no_platforms) AS no_platforms, -- # floats in Australian region
	SUM(no_oxygen_platforms) AS no_instruments,
	SUM(no_active_floats) AS no_deployments,
	SUM(no_active_oxygen_platforms)  AS no_data,
	SUM(total_no_profiles) AS no_data2,
	SUM(total_no_measurements) AS no_data3,
	SUM(CASE WHEN organisation = 'csiro' THEN no_platforms ELSE 0 END) AS no_data4, -- # Australian floats
	COALESCE(to_char(min(earliest_date),'DD/MM/YYYY')||' - '||to_char(max(latest_date),'DD/MM/YYYY')) AS temporal_range,
	COALESCE(min(min_lat)||' - '||max(max_lat)) AS lat_range,
	COALESCE(min(min_lon)||' - '||max(max_lon)) AS lon_range,
	NULL AS depth_range
  FROM argo_data_summary_view

-- AUV
UNION ALL

  SELECT 'AUV' AS facility,
	NULL AS subfacility,
	'TOTAL' AS type,
	COUNT(*) AS no_projects,
	SUM(no_campaigns) AS no_platforms,
	SUM(no_sites) AS no_instruments,
	NULL AS no_deployments,
	SUM(total_no_images) AS no_data,
	ROUND((SUM(data_duration)/24)::numeric,1) AS no_data2,
	NULL::numeric AS no_data3,
	NULL::numeric AS no_data4,
	COALESCE(to_char(min(earliest_date),'DD/MM/YYYY')||' - '||to_char(max(latest_date),'DD/MM/YYYY')) AS temporal_range,
	COALESCE(min(lat_min)||' - '||max(lat_max)) AS lat_range,
	COALESCE(min(lon_min)||' - '||max(lon_max)) AS lon_range,
	NULL AS depth_range
  FROM auv_data_summary_view

-- FAIMMS
UNION ALL

SELECT 'FAIMMS' AS facility,
	NULL AS subfacility,
	'TOTAL' AS type,
	COUNT(s.*) AS no_projects,
	SUM(s.no_platforms) AS no_platforms,
	ROUND(AVG(i.no_parameters),0) AS no_deployments,
	SUM(s.no_sensors) AS no_instruments,
	SUM(s.qaqc_data) AS no_data, -- Calculate number of quality controlled datasets
	SUM(s.no_measurements) AS no_data2, -- Calculate total number of measurements
	i.qaqc AS no_data3, -- Calculate number of QAQC measurements
	i.no_qaqc AS no_data4, -- Calculate number of non QAQC measurements
	COALESCE(to_char(min(s.earliest_date),'DD/MM/YYYY')||' - '||to_char(max(s.latest_date),'DD/MM/YYYY')) AS temporal_range,
	COALESCE(min(s.lat)||' - '||max(s.lat)) AS lat_range,
	COALESCE(min(s.lon)||' - '||max(s.lon)) AS lon_range,
	COALESCE(min(s.min_depth)||' - '||max(s.max_depth)) AS depth_range
  FROM faimms_data_summary_view s, i
  GROUP BY i.qaqc, i.no_qaqc

-- SOOP
UNION ALL

  SELECT 'SOOP' AS facility,
	subfacility AS subfacility,
	data_type AS type,
	NULL AS no_projects,
	COUNT(DISTINCT(vessel_name)) AS no_platforms,
	NULL AS no_instruments,
	SUM(no_deployments) AS no_deployments,
	SUM(no_files_profiles) AS no_data,
	SUM(total_no_measurements) AS no_data2,
	SUM(coverage_duration) AS no_data3,
	NULL::numeric AS no_data4,
	COALESCE(to_char(min(earliest_date),'DD/MM/YYYY')||' - '||to_char(max(latest_date),'DD/MM/YYYY')) AS temporal_range,
	COALESCE(min(min_lat)||' - '||max(max_lat)) AS lat_range,
	COALESCE(min(min_lon)||' - '||max(max_lon)) AS lon_range,
	NULL AS depth_range
  FROM soop_data_summary_view
	GROUP BY subfacility, data_type

UNION ALL

  SELECT 'SOOP' AS facility,
	NULL AS subfacility,
	'TOTAL' AS type,
	NULL AS no_projects,
	COUNT(DISTINCT(vessel_name)) AS no_platforms,
	NULL AS no_instruments,
	count(CASE WHEN deployment_id IS NULL THEN '1'::character varying ELSE deployment_id END) AS no_deployments,
	sum(CASE WHEN no_files_profiles IS NULL THEN (1)::bigint ELSE no_files_profiles END) AS no_data,
	SUM(no_measurements) AS no_data2,
	SUM(coverage_duration) AS no_data3,
	NULL::numeric AS no_data4,
	COALESCE(to_char(min(start_date),'DD/MM/YYYY')||' - '||to_char(max(end_date),'DD/MM/YYYY')) AS temporal_range,
	COALESCE(min(min_lat)||' - '||max(max_lat)) AS lat_range,
	COALESCE(min(min_lon)||' - '||max(max_lon)) AS lon_range,
	NULL AS depth_range
  FROM soop_all_deployments_view

-- SRS
UNION ALL

  SELECT 'SRS' AS facility,
	subfacility AS subfacility,
	NULL AS type,
	NULL AS no_projects,
	COUNT(DISTINCT(parameter_site))  AS no_platforms,
	SUM(no_sensors) AS no_instruments,
	SUM(no_deployments) AS no_deployments,
	CASE WHEN subfacility = 'SRS - Gridded Products' THEN 0 ELSE SUM(no_measurements) END AS no_data,
	CASE WHEN subfacility != 'SRS - Gridded Products' THEN 0 ELSE SUM(no_measurements) END AS no_data2,
	SUM(mean_coverage_duration) AS no_data3,
	NULL::numeric AS no_data4,
	COALESCE(to_char(min(earliest_date),'DD/MM/YYYY')||' - '||to_char(max(latest_date),'DD/MM/YYYY')) AS temporal_range,
	NULL AS lat_range,
	NULL AS lon_range,
	NULL AS depth_range
  FROM srs_data_summary_view
	GROUP BY subfacility

UNION ALL

  SELECT 'SRS' AS facility,
	NULL AS subfacility,
	'TOTAL' AS type,
	NULL AS no_projects,
	COUNT(DISTINCT(parameter_site))  AS no_platforms,
	SUM(no_sensors) AS no_instruments,
	SUM(no_deployments) AS no_deployments,
	NULL AS no_data,
	NULL AS no_data2,
	SUM(mean_coverage_duration) AS no_data3,
	NULL::numeric AS no_data4,
	COALESCE(to_char(min(earliest_date),'DD/MM/YYYY')||' - '||to_char(max(latest_date),'DD/MM/YYYY')) AS temporal_range,
	NULL AS lat_range,
	NULL AS lon_range,
	NULL AS depth_range
  FROM srs_data_summary_view
	ORDER BY facility,subfacility,type;

grant all on table totals_view to public;

-- ALTER TABLE totals_view OWNER TO harvest_reporting_write_group;
