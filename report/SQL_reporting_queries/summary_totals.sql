SET search_path = reporting, public;
DROP VIEW IF EXISTS facility_summary_totals_view CASCADE;

-------------------------------
-- VIEW FOR Summary totals
-------------------------------
-- All deployments view
CREATE OR REPLACE VIEW facility_summary_totals_view AS 
WITH argo AS (SELECT 'Argo'::text AS facility, '# profiles'::text AS stat_1_attrib, no_data2 AS stat_1_value, '# measurements'::text AS stat_2_attrib, no_data3 AS stat_2_value FROM totals_view WHERE facility = 'Argo'),
soop AS (SELECT 'SOOP'::text AS facility, '# data files'::text AS stat_1_attrib, no_data AS stat_1_value, '# measurements'::text AS stat_2_attrib, no_data2 AS stat_2_value FROM totals_view WHERE facility = 'SOOP'::text AND type = 'TOTAL'),
abos AS (SELECT 'ABOS'::text AS facility, '# deployments'::text AS stat_1_attrib, no_deployments AS stat_1_value, '# data files'::text AS stat_2_attrib, no_data AS stat_2_value FROM totals_view WHERE facility = 'ABOS'::text AND type = 'TOTAL'),
anfog AS (SELECT 'ANFOG'::text AS facility, '# deployments'::text AS stat_1_attrib, no_deployments AS stat_1_value, '# measurements'::text AS stat_2_attrib, no_data AS stat_2_value FROM totals_view WHERE facility = 'ANFOG'::text AND type = 'TOTAL'),
auv AS (SELECT 'AUV'::text AS facility, '# deployments'::text AS stat_1_attrib, no_instruments AS stat_1_value, '# images'::text AS stat_2_attrib, no_data AS stat_2_value FROM totals_view WHERE facility = 'AUV'),
anmn AS (SELECT 'ANMN'::text AS facility, '# deployments'::text AS stat_1_attrib, no_deployments AS stat_1_value, '# data files'::text AS stat_2_attrib, no_data2 AS stat_2_value FROM totals_view WHERE facility = 'ANMN'::text AND subfacility = 'NRS, RMA, and AM'),
ac_1 AS (SELECT no_data FROM totals_view WHERE facility = 'ACORN'::text AND type = 'TOTAL - Hourly vectors'),
ac_2 AS (SELECT no_data FROM totals_view WHERE facility = 'ACORN'::text AND type = 'TOTAL - Radials'),
acorn AS (SELECT 'ACORN'::text AS facility, '# vector files'::text AS stat_1_attrib, ac_1.no_data AS stat_1_value, '# radial files'::text AS stat_2_attrib, ac_2.no_data AS stat_2_value FROM ac_1,ac_2),
aatams_acoustic AS (SELECT 'Animal tracking (acoustic)'::text AS facility, '# transmitters'::text AS stat_1_attrib, no_transmitters AS stat_1_value, '# detections'::text AS stat_2_attrib, no_detections AS stat_2_value 
FROM aatams_acoustic_registered_totals_view WHERE no_times_detected = 'Total'),
aatams_sattag AS (SELECT 'Animal tracking (satellite)'::text AS facility, '# profiles'::text AS stat_1_attrib, no_data AS stat_1_value, '# measurements'::text AS stat_2_attrib, no_data2 AS stat_2_value FROM totals_view WHERE facility = 'AATAMS'::text AND subfacility = 'Biologging' AND type = 'TOTAL'),
faimms AS (SELECT 'FAIMMS'::text AS facility, '# QC''d datasets'::text AS stat_1_attrib, no_data AS stat_1_value, '# measurements'::text AS stat_2_attrib, no_data2 AS stat_2_value FROM totals_view WHERE facility = 'FAIMMS'),
srs AS (SELECT 'SRS'::text AS facility, '# measurements'::text AS stat_1_attrib, SUM(no_data) AS stat_1_value, '# gridded images'::text AS stat_2_attrib, SUM(no_data2) AS stat_2_value FROM totals_view WHERE facility = 'SRS')
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