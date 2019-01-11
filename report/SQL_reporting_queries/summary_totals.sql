SET search_path = reporting, public;
DROP VIEW IF EXISTS facility_summary_totals_view CASCADE;

-------------------------------
-- VIEW FOR Summary totals
-------------------------------
-- All deployments view
CREATE OR REPLACE VIEW facility_summary_totals_view AS 
WITH argo AS (
  SELECT 'Argo'::text AS facility, 
	'# Australian floats'::text AS stat_1_attrib, 
	no_data4 AS stat_1_value, 
	'# profiles'::text AS stat_2_attrib,
	no_data2 AS stat_2_value,
	NULL::text as stat_3_attrib,
	Null::numeric as stat_3_value
  FROM totals_view 
	WHERE facility = 'Argo'),

  soop AS (
  SELECT COALESCE('SOOP'::text||'-'||subfacility||' '||type) AS facility, 
	CASE WHEN subfacility IN ('SST', 'TMV') THEN NULL ELSE '# cruises'::text END AS stat_1_attrib, 
	CASE WHEN subfacility IN ('SST', 'TMV') THEN NULL ELSE no_deployments END AS stat_1_value, 
	CASE WHEN subfacility = 'XBT' THEN '# profiles'::text WHEN subfacility = 'CPR' THEN '# samples' ELSE '# data files'::text END AS stat_2_attrib, 
	no_data AS stat_2_value,
	CASE WHEN subfacility = 'CPR' THEN '# days of data'::text ELSE '# measurements'::text END AS stat_3_attrib, 
	CASE WHEN subfacility = 'CPR' THEN no_data3 ELSE no_data2 END AS stat_3_value 
  FROM totals_view 
	WHERE facility = 'SOOP'::text AND type != 'TOTAL'),
  
  abos AS (
  SELECT 'ABOS'::text AS facility, 
	'# deployments'::text AS stat_1_attrib, 
	no_deployments AS stat_1_value, 
	'# QC''d datasets'::text AS stat_2_attrib, 
	no_data AS stat_2_value,
	'# days of data'::text AS stat_3_attrib, 
	no_data3 AS stat_3_value
  FROM totals_view 
	WHERE facility = 'ABOS'::text AND type = 'TOTAL'),
  
  anfog AS (
  SELECT 'ANFOG'::text AS facility, 
	'# gliders'::text AS stat_1_attrib,
	no_platforms AS stat_1_value,
	'# deployments'::text AS stat_2_attrib, 
	no_deployments AS stat_2_value, 
	'# measurements'::text AS stat_3_attrib, 
	no_data AS stat_3_value 
  FROM totals_view 
	WHERE facility = 'ANFOG'::text AND type = 'TOTAL'),
  
  auv AS (
  SELECT 'AUV'::text AS facility,
	'# deployment campaigns'::text AS stat_1_attrib, 
	no_platforms AS stat_1_value,
	'# deployments'::text AS stat_2_attrib, 
	no_instruments AS stat_2_value, 
	'# images'::text AS stat_3_attrib, 
	no_data AS stat_3_value	
  FROM totals_view 
	WHERE facility = 'AUV'),
	
  anmn AS (
  SELECT 'ANMN'::text AS facility, 
	'# deployments'::text AS stat_1_attrib,
	no_deployments AS stat_1_value, 
	'# QC''d data files'::text AS stat_2_attrib, 
	no_data2 AS stat_2_value,
	'# days of data'::text AS stat_3_attrib, 
	no_data3 AS stat_3_value 
    FROM totals_view 
	WHERE facility = 'ANMN'::text AND subfacility = 'NRS, RMA, and AM'),

  anmn_nrs_bgc AS (
  SELECT 'ANMN-BGC'::text AS facility, 
	'# chemistry trips'::text AS stat_1_attrib,
	no_projects AS stat_1_value, 
	'# phytoplankton trips'::text AS stat_2_attrib, 
	no_instruments AS stat_2_value,
	'# zooplankton trips'::text AS stat_3_attrib, 
	no_deployments AS stat_3_value 
    FROM totals_view 
	WHERE facility = 'ANMN'::text AND subfacility = 'BGC'),

	
  anmn_pa AS (
  SELECT 'ANMN-PA'::text AS facility, 
	'# loggers deployed'::text AS stat_1_attrib,
	no_instruments AS stat_1_value, 
	'# datasets on Acoustic Viewer'::text AS stat_2_attrib, 
	no_data2 AS stat_2_value,
	'# days of data'::text AS stat_3_attrib, 
	no_data3 AS stat_3_value 
    FROM totals_view 
	WHERE facility = 'ANMN'::text AND subfacility = 'PA'),
	
  ac_1 AS (SELECT no_data, no_data3 FROM totals_view WHERE facility = 'ACORN'::text AND type = 'TOTAL - Hourly vectors'),
  ac_2 AS (SELECT no_data, no_data3 FROM totals_view WHERE facility = 'ACORN'::text AND type = 'TOTAL - Radials'),
  acorn AS (
  SELECT 'ACORN'::text AS facility, 
	'# vector files'::text AS stat_1_attrib, 
	ac_1.no_data AS stat_1_value, 
	'# radial files'::text AS stat_2_attrib, 
	ac_2.no_data AS stat_2_value,
	'# years of data'::text AS stat_3_attrib, 
	ac_1.no_data3 + ac_2.no_data3 AS stat_3_value 
  FROM ac_1,ac_2),

  t AS (SELECT t FROM aatams_acoustic_stats_view WHERE statistics_type = 'no public detections at species level'),
  aatams_acoustic AS (
  SELECT 'Animal tracking (acoustic)'::text AS facility, 
	'# transmitters'::text AS stat_1_attrib, 
	no_transmitters AS stat_1_value, 
	'# detections'::text AS stat_2_attrib, 
	no_detections AS stat_2_value,
	'# detections with species information that are public'::text AS stat_3_attrib, 
	t.t AS stat_3_value 
  FROM aatams_acoustic_registered_totals_view,t 
	WHERE no_times_detected = 'Total'),
	
  aatams_sattag AS (
  SELECT 'Animal tracking (satellite)'::text AS facility, 
	'# animals equipped with satellite tags'::text AS stat_1_attrib, 
	no_deployments AS stat_1_value,
	'# profiles'::text AS stat_2_attrib, 
	no_data AS stat_2_value, 
	'# measurements'::text AS stat_3_attrib, 
	no_data2 AS stat_3_value 
  FROM totals_view 
	WHERE facility = 'AATAMS'::text AND subfacility = 'Biologging' AND type = 'TOTAL'),
	
  faimms AS (
  SELECT 'FAIMMS'::text AS facility,
	'# sites'::text AS stat_1_attrib, 
	no_projects AS stat_1_value,
	'# sensors with QAQC''d data'::text AS stat_2_attrib, 
	no_data AS stat_2_value, 
	'# QAQC''d measurements'::text AS stat_3_attrib, 
	no_data3 AS stat_3_value 
  FROM totals_view 
	WHERE facility = 'FAIMMS'),
  
  srs AS (
  SELECT subfacility AS facility, 
	CASE WHEN subfacility = 'SRS - Gridded Products' THEN '# data products' ELSE '# deployments'::text END AS stat_1_attrib, 
	no_deployments AS stat_1_value, 
	CASE WHEN subfacility = 'SRS - Gridded Products' THEN '# gridded images' ELSE '# measurements'::text END AS stat_2_attrib, 
	CASE WHEN subfacility = 'SRS - Gridded Products' THEN no_data2 ELSE no_data END AS stat_2_value, 
	'# days of data'::text AS stat_3_attrib, 
	no_data3 AS stat_3_value 
  FROM totals_view WHERE facility = 'SRS' AND type IS NULL)

  SELECT * FROM argo
  UNION ALL
  SELECT * FROM soop
  UNION ALL
  SELECT * FROM abos
  UNION ALL
  SELECT * FROM anfog
  UNION ALL
  SELECT * FROM auv
  UNION ALL
  SELECT * FROM anmn
  UNION ALL
  SELECT * FROM anmn_nrs_bgc
  UNION ALL
  SELECT * FROM anmn_pa
  UNION ALL
  SELECT * FROM acorn
  UNION ALL
  SELECT * FROM aatams_acoustic
  UNION ALL
  SELECT * FROM aatams_sattag
  UNION ALL
  SELECT * FROM faimms
  UNION ALL
  SELECT * FROM srs
	ORDER BY facility;

grant all on table facility_summary_totals_view to public;

-- ALTER VIEW facility_summary_totals_view OWNER TO harvest_reporting_write_group;