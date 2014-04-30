SET SEARCH_PATH = report_test, public, abos;


-------------------------------
-------------------------------
-- TOTALS VIEW
-------------------------------
------------------------------- 
CREATE or replace view totals_view AS
 WITH interm_table AS (
  SELECT COUNT(DISTINCT(parameter)) AS no_parameters
  FROM faimms_all_deployments_view)

-------------------------------
-- AATAMS - Biologging
-------------------------------
 SELECT 'AATAMS' AS facility,
    'Biologging' AS subfacility,
    data_type AS type,
    COUNT(DISTINCT(sattag_program)) AS no_projects,
    COUNT(DISTINCT(species_name)) AS no_platforms,
    COUNT(DISTINCT(tag_type)) AS no_instruments,
    SUM(no_tags) AS no_deployments,
    SUM(total_nb_profiles) AS no_data,
    SUM(total_nb_measurements) AS no_data2,
    NULL::bigint AS no_data3,
    NULL::bigint AS no_data4,
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
    NULL::bigint AS no_data3,
    NULL::bigint AS no_data4,
    COALESCE(to_char(min(coverage_start),'DD/MM/YYYY')||' - '||to_char(max(coverage_end),'DD/MM/YYYY')) AS temporal_range,
    COALESCE(min(min_lat)||' - '||max(max_lat)) AS lat_range,
    COALESCE(min(min_lon)||' - '||max(max_lon)) AS lon_range,
    COALESCE(min(min_depth)||' - '||max(max_depth)) AS depth_range
  FROM aatams_sattag_all_deployments_view

-------------------------------
-- ABOS
-------------------------------
UNION ALL

  SELECT 'ABOS' AS facility,
	sub_facility AS subfacility,
	file_type AS type,
	NULL AS no_projects,
	COUNT(DISTINCT(platform_code)) AS no_platforms,
	COUNT(DISTINCT(data_category)) AS no_instruments,
	SUM(no_deployments) AS no_deployments,
	SUM(no_fv1) AS no_data,
	SUM(no_fv2) AS no_data2,
	NULL::bigint AS no_data3,
	NULL::bigint AS no_data4,
	COALESCE(to_char(min(coverage_start),'DD/MM/YYYY')||' - '||to_char(max(coverage_end),'DD/MM/YYYY')) AS temporal_range,
	NULL AS lat_range,
	NULL AS lon_range,
	NULL AS depth_range
  FROM abos_data_summary_view
	GROUP BY sub_facility, file_type

UNION ALL

  SELECT 'ABOS' AS facility,
	NULL AS subfacility,
	'TOTAL' AS type,
	NULL::BIGINT AS no_projects,
	COUNT(DISTINCT(platform_code)) AS no_platforms,
	COUNT(DISTINCT(data_category)) AS no_instruments,
	SUM(no_deployments) AS no_deployments,
	SUM(no_fv1) AS no_data,
	SUM(no_fv2) AS no_data2,
	NULL::bigint AS no_data3,
	NULL::bigint AS no_data4,
	COALESCE(to_char(min(coverage_start),'DD/MM/YYYY')||' - '||to_char(max(coverage_end),'DD/MM/YYYY')) AS temporal_range,
	NULL AS lat_range,
	NULL AS lon_range,
	NULL AS depth_range
  FROM abos_data_summary_view

-------------------------------
-- ACORN
-------------------------------
UNION ALL

SELECT 'ACORN' AS facility,
NULL AS subfacility,
'TOTAL' AS type,
SUM(CASE WHEN code_type = 'site' THEN 1 ELSE 0 END) AS no_projects,
SUM(CASE WHEN code_type = 'station' THEN 1 ELSE 0 END) AS no_platforms,
NULL::bigint AS no_instruments,
NULL::bigint AS no_deployments,
SUM(CASE WHEN qc_radial = 0 THEN 0 WHEN code_type = 'station' THEN 0 ELSE 1 END) AS no_data,
SUM(CASE WHEN qc_grid = 0 OR qc_grid IS NULL THEN 0 ELSE 1 END) AS no_data2,
NULL::bigint AS no_data3,
NULL::bigint AS no_data4,
COALESCE(to_char(min(start),'DD/MM/YYYY')||' - '||to_char(max(start),'DD/MM/YYYY')) AS temporal_range,
NULL AS lat_range,
NULL AS lon_range,
NULL AS depth_range
FROM acorn_all_deployments_view
-----------------------------------------------------------------------
UNION ALL
SELECT 'ANFOG' AS facility,
NULL AS subfacility,
'TOTAL' AS type,
NULL::bigint AS no_projects,
SUM(no_platforms) AS no_platforms,
NULL::bigint AS no_instruments,
SUM(no_deployments) AS no_deployments,
NULL AS no_data,
NULL AS no_data2,
NULL::bigint AS no_data3,
NULL::bigint AS no_data4,
COALESCE(to_char(min(earliest_date),'DD/MM/YYYY')||' - '||to_char(max(latest_date),'DD/MM/YYYY')) AS temporal_range,
COALESCE(min(min_lat)||' - '||max(max_lat)) AS lat_range,
COALESCE(min(min_lon)||' - '||max(max_lon)) AS lon_range,
COALESCE(min(min_depth)||' - '||max(max_depth)) AS depth_range
FROM anfog_data_summary_view
-----------------------------------------------------------------------
UNION ALL
SELECT 'Argo' AS facility,
NULL AS subfacility,
'TOTAL' AS type,
COUNT(*) AS no_projects,
SUM(no_platforms) AS no_platforms,
SUM(no_oxygen_platforms) AS no_instruments,
SUM(no_active_floats) AS no_deployments,
SUM(no_active_oxygen_platforms)  AS no_data,
NULL AS no_data2,
NULL::bigint AS no_data3,
NULL::bigint AS no_data4,
COALESCE(to_char(min(earliest_date),'DD/MM/YYYY')||' - '||to_char(max(latest_date),'DD/MM/YYYY')) AS temporal_range,
COALESCE(min(min_lat)||' - '||max(max_lat)) AS lat_range,
COALESCE(min(min_lon)||' - '||max(max_lon)) AS lon_range,
NULL AS depth_range
FROM argo_data_summary_view
-----------------------------------------------------------------------
UNION ALL
SELECT 'AUV' AS facility,
NULL AS subfacility,
'TOTAL' AS type,
COUNT(*) AS no_projects,
SUM(no_campaigns) AS no_platforms,
SUM(no_sites) AS no_instruments,
NULL AS no_deployments,
NULL AS no_data,
NULL AS no_data2,
NULL::bigint AS no_data3,
NULL::bigint AS no_data4,
COALESCE(to_char(min(earliest_date),'DD/MM/YYYY')||' - '||to_char(max(latest_date),'DD/MM/YYYY')) AS temporal_range,
COALESCE(min(lat_min)||' - '||max(lat_max)) AS lat_range,
COALESCE(min(lon_min)||' - '||max(lon_max)) AS lon_range,
NULL AS depth_range
FROM auv_data_summary_view
-----------------------------------------------------------------------
UNION ALL
SELECT 'FAIMMS' AS facility,
NULL AS subfacility,
'TOTAL' AS type,
COUNT(*) AS no_projects,
SUM(no_platforms) AS no_platforms,
SUM(no_sensors) AS no_instruments,
ROUND(AVG(interm_table.no_parameters),0) AS no_deployments,
NULL AS no_data,
NULL AS no_data2,
NULL::bigint AS no_data3,
NULL::bigint AS no_data4,
COALESCE(to_char(min(earliest_date),'DD/MM/YYYY')||' - '||to_char(max(latest_date),'DD/MM/YYYY')) AS temporal_range,
COALESCE(min(lat)||' - '||max(lat)) AS lat_range,
COALESCE(min(lon)||' - '||max(lon)) AS lon_range,
COALESCE(min(min_depth)||' - '||max(max_depth)) AS depth_range
FROM faimms_data_summary_view,interm_table
-----------------------------------------------------------------------
UNION ALL
SELECT 'SOOP' AS facility,
subfacility AS subfacility,
NULL AS type,
NULL AS no_projects,
COUNT(DISTINCT(vessel_name)) AS no_platforms,
NULL AS no_instruments,
SUM(no_deployments) AS no_deployments,
SUM(no_data_files) AS no_data,
NULL AS no_data2,
NULL::bigint AS no_data3,
NULL::bigint AS no_data4,
COALESCE(to_char(min(earliest_date),'DD/MM/YYYY')||' - '||to_char(max(latest_date),'DD/MM/YYYY')) AS temporal_range,
COALESCE(min(min_lat)||' - '||max(max_lat)) AS lat_range,
COALESCE(min(min_lon)||' - '||max(max_lon)) AS lon_range,
COALESCE(min(min_depth)||' - '||max(max_depth)) AS depth_range
FROM soop_data_summary_view
GROUP BY subfacility
UNION ALL
SELECT 'SOOP' AS facility,
NULL AS subfacility,
'TOTAL' AS type,
NULL AS no_projects,
COUNT(DISTINCT(vessel_name)) AS no_platforms,
NULL AS no_instruments,
SUM(no_deployments) AS no_deployments,
SUM(no_data_files) AS no_data,
NULL AS no_data2,
NULL::bigint AS no_data3,
NULL::bigint AS no_data4,
COALESCE(to_char(min(earliest_date),'DD/MM/YYYY')||' - '||to_char(max(latest_date),'DD/MM/YYYY')) AS temporal_range,
COALESCE(min(min_lat)||' - '||max(max_lat)) AS lat_range,
COALESCE(min(min_lon)||' - '||max(max_lon)) AS lon_range,
COALESCE(min(min_depth)||' - '||max(max_depth)) AS depth_range
FROM soop_data_summary_view
-----------------------------------------------------------------------
UNION ALL
SELECT 'SRS' AS facility,
subfacility AS subfacility,
NULL AS type,
NULL AS no_projects,
COUNT(DISTINCT(parameter_site))  AS no_platforms,
SUM(no_sensors) AS no_instruments,
SUM(no_deployments) AS no_deployments,
NULL AS no_data,
NULL AS no_data2,
NULL::bigint AS no_data3,
NULL::bigint AS no_data4,
COALESCE(to_char(min(earliest_date),'DD/MM/YYYY')||' - '||CASE WHEN to_char(max(latest_date),'DD/MM/YYYY') IS NULL THEN 'NA' ELSE to_char(max(latest_date),'DD/MM/YYYY') END) AS temporal_range,
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
NULL::bigint AS no_data3,
NULL::bigint AS no_data4,
COALESCE(to_char(min(earliest_date),'DD/MM/YYYY')||' - '||to_char(max(latest_date),'DD/MM/YYYY')) AS temporal_range,
NULL AS lat_range,
NULL AS lon_range,
NULL AS depth_range
FROM srs_data_summary_view
-----------------------------------------------------------------------
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
NULL::bigint AS no_data3,
NULL::bigint AS no_data4,
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
NULL::bigint AS no_data3,
NULL::bigint AS no_data4,
COALESCE(to_char(min(earliest_date),'DD/MM/YYYY')||' - '||to_char(max(latest_date),'DD/MM/YYYY')) AS temporal_range,
COALESCE(min(min_lat)||' - '||max(min_lat)) AS lat_range,
COALESCE(min(min_lon)||' - '||max(min_lon)) AS lon_range,
COALESCE(min(min_depth)||' - '||max(max_depth)) AS depth_range
FROM anmn_data_summary_view
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
NULL::bigint AS no_data3,
NULL::bigint AS no_data4,
COALESCE(to_char(min(earliest_date),'DD/MM/YYYY')||' - '||to_char(max(latest_date),'DD/MM/YYYY')) AS temporal_range,
NULL AS lat_range,
NULL AS lon_range,
NULL AS depth_range
FROM anmn_acoustics_data_summary_view
-- UNION ALL
-- SELECT 'ANMN' AS facility,
-- 'BGC' AS subfacility,
-- 'TOTAL' AS type,
-- SUM(CASE WHEN n_logsht IS NULL THEN 0 ELSE 1 END) AS no_projects,
-- SUM(CASE WHEN ns_ctdpro IS NULL THEN 0 ELSE 1 END) AS no_platforms,
-- SUM(CASE WHEN ns_hydall IS NULL THEN 0 ELSE 1 END) AS no_instruments,
-- SUM(CASE WHEN ns_susmat IS NULL THEN 0 ELSE 1 END) AS no_deployments,
-- SUM(CASE WHEN ns_carbon IS NULL THEN 0 ELSE 1 END) AS no_data,
-- SUM(CASE WHEN ns_phypig IS NULL THEN 0 ELSE 1 END) AS no_data2,
-- SUM(CASE WHEN ns_zoo IS NULL THEN 0 ELSE 1 END) AS no_data3,
-- SUM(CASE WHEN ns_phyto IS NULL THEN 0 ELSE 1 END) AS no_data4,
-- COALESCE(to_char(min(sample_date),'DD/MM/YYYY')||' - '||to_char(max(sample_date),'DD/MM/YYYY')) AS temporal_range,
-- NULL AS lat_range,
-- NULL AS lon_range,
-- NULL AS depth_range
-- FROM anmn_bgc_all_deployments_view
UNION ALL
SELECT 'ANMN' AS facility,
'NRS - Real-Time' AS subfacility,
'TOTAL' AS type,
COUNT(*) AS no_projects,
NULL AS no_platforms,
NULL AS no_instruments,
NULL AS no_deployments,
SUM(no_qc_data) AS no_data,
NULL AS no_data2,
NULL::bigint AS no_data3,
NULL::bigint AS no_data4,
COALESCE(to_char(min(earliest_date),'DD/MM/YYYY')||' - '||to_char(max(latest_date),'DD/MM/YYYY')) AS temporal_range,
NULL AS lat_range,
NULL AS lon_range,
COALESCE(min(min_depth)||' - '||max(max_depth)) AS depth_range
FROM anmn_nrs_realtime_data_summary_view
ORDER BY facility,subfacility,type;

grant all on table totals_view to public;