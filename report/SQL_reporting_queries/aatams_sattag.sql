SET search_path = reporting, public;
DROP VIEW IF EXISTS aatams_sattag_all_deployments_view CASCADE;

-------------------------------
-- VIEWS FOR AATAMS_SATTAG_NRT and AATAMS_SATTAG_DM; Can delete the report.aatams_sattag tables.
-------------------------------
-- All deployments view
 CREATE or replace VIEW aatams_sattag_all_deployments_view AS
WITH qc AS (SELECT smru_platform_code, COUNT(*) AS nb_measurements, min(pres) AS min_pressure, max(pres) AS max_pressure
FROM aatams_sattag_qc_ctd.aatams_sattag_qc_ctd_profile_data
GROUP BY smru_platform_code)
  SELECT 'Near real-time CTD data' AS data_type,
	COALESCE(m.sattag_program|| ' - ' || m.state_country || ' - ' || m.pi) AS headers,
	m.sattag_program,
	m.release_site,
	m.state_country,
	m.tag_type, 
	m.common_name AS species_name, 
	m.device_id AS tag_code, 
	COUNT(map.profile_id) AS nb_profiles,
	SUM(map.nb_measurements) AS nb_measurements,
	min(map."timestamp") AS coverage_start, 
	max(map."timestamp") AS coverage_end,
	round((date_part('days', max(map."timestamp") - min(map."timestamp")) + (date_part('hours', max(map."timestamp") - min(map."timestamp")))/24)::numeric, 1) AS coverage_duration,
	round(min(st_y(st_centroid(map.geom)))::numeric, 1) AS min_lat, 
	round(max(st_y(st_centroid(map.geom)))::numeric, 1) AS max_lat, 
	round(min(st_x(st_centroid(map.geom)))::numeric, 1) AS min_lon, 
	round(max(st_x(st_centroid(map.geom)))::numeric, 1) AS max_lon,
	min(map.min_pressure) AS min_depth,
	max(map.max_pressure) AS max_depth
  FROM aatams_sattag_nrt.aatams_sattag_nrt_metadata m
  LEFT JOIN aatams_sattag_nrt.aatams_sattag_nrt_profile_map map ON m.device_id = map.device_id
	WHERE m.device_wmo_ref != ''
	GROUP BY m.sattag_program, m.device_id, m.tag_type, m.pi, m.common_name, m.release_site
	HAVING COUNT(map.profile_id) != 0

UNION ALL

  SELECT 'Delayed mode CTD data' AS data_type,
	COALESCE(m.sattag_program|| ' - ' || m.state_country || ' - ' || m.pi) AS headers,
	m.sattag_program, 
	m.release_site,
	m.state_country,
	m.tag_type,
	m.common_name AS species_name, 
	m.device_id AS tag_code, 
	COUNT(dmap.profile_id) AS nb_profiles,
	SUM(dmap.nb_measurements) AS nb_measurements,
	min(dmap."timestamp") AS coverage_start, 
	max(dmap."timestamp") AS coverage_end,
	round((date_part('days', max(dmap."timestamp") - min(dmap."timestamp")) + (date_part('hours', max(dmap."timestamp") - min(dmap."timestamp")))/24)::numeric, 1) AS coverage_duration,
	round(min(st_y(st_centroid(dmap.geom)))::numeric, 1) AS min_lat, 
	round(max(st_y(st_centroid(dmap.geom)))::numeric, 1) AS max_lat, 
	round(min(st_x(st_centroid(dmap.geom)))::numeric, 1) AS min_lon, 
	round(max(st_x(st_centroid(dmap.geom)))::numeric, 1) AS max_lon,
	min(dmap.min_pressure) AS min_depth,
	max(dmap.max_pressure) AS max_depth
  FROM aatams_sattag_nrt.aatams_sattag_nrt_metadata m
  LEFT JOIN aatams_sattag_dm.aatams_sattag_dm_profile_map dmap ON m.device_id = dmap.device_id
	GROUP BY m.sattag_program, m.device_id, m.tag_type, m.pi, m.common_name, m.release_site
	HAVING COUNT(dmap.profile_id) != 0

UNION ALL

SELECT 'Delayed-mode QCd CTD data' AS data_type,
	COALESCE(substring(qc_m.smru_platform_code,'^[^-]*')|| ' - ' || CASE WHEN release_location IN ('Kerguelen', 'Dumont d''Urville') THEN 'French Overseas Territory' 
    	WHEN release_location IN ('Campbell', 'Campbell Island') THEN 'New Zealand' ELSE 'Australia Antarctic Territory' END || ' - ' || pi_name) AS headers,
	substring(qc_m.smru_platform_code,'^[^-]*') AS sattag_program,
	CASE WHEN release_location = 'Davies' THEN 'Davis' 
    	WHEN release_location = 'Campbell' THEN 'Campbell Island' ELSE release_location END AS release_site,
	CASE WHEN release_location IN ('Kerguelen', 'Dumont d''Urville') THEN 'French Overseas Territory' 
    	WHEN release_location IN ('Campbell', 'Campbell Island') THEN 'New Zealand' ELSE 'Australia Antarctic Territory' END AS state_country,
	'SMRU CTD tag' AS tag_type, 
	CASE WHEN species_name = 'Weddel seal' THEN 'Weddell seal' WHEN species_name = 'Southern ellie' THEN 'Southern Elephant Seal' ELSE species_name END AS species_name, 
	qc_m.smru_platform_code AS tag_code, 
	COUNT(profile_no) AS nb_profiles,
	qc.nb_measurements AS nb_measurements,
	min(juld_location) AS coverage_start, 
	max(juld_location) AS coverage_end,
	round((date_part('days', max(juld_location) - min(juld_location)) + (date_part('hours', max(juld_location) - min(juld_location)))/24)::numeric, 1) AS coverage_duration,
	round(min(st_y(st_centroid(position)))::numeric, 1) AS min_lat, 
	round(max(st_y(st_centroid(position)))::numeric, 1) AS max_lat, 
	round(min(st_x(st_centroid(position)))::numeric, 1) AS min_lon, 
	round(max(st_x(st_centroid(position)))::numeric, 1) AS max_lon,
	qc.min_pressure AS min_depth,
	qc.max_pressure AS max_depth
  FROM aatams_sattag_qc_ctd.aatams_sattag_qc_ctd_profile_map qc_m
	JOIN qc ON qc.smru_platform_code = qc_m.smru_platform_code
	GROUP BY qc_m.smru_platform_code, qc_m.pi_name, qc_m.species_name, qc_m.release_location, qc.nb_measurements, qc.min_pressure, qc.max_pressure
	ORDER BY data_type, sattag_program, species_name, tag_code;

grant all on table aatams_sattag_all_deployments_view to public;

-- Data summary view
CREATE OR REPLACE VIEW aatams_sattag_data_summary_view AS
  SELECT v.data_type,
	v.species_name, 
	v.sattag_program, 
	v.state_country AS release_site,
	count(DISTINCT v.tag_code) AS no_animals, 
	sum(v.nb_profiles) AS total_nb_profiles,
	sum(v.nb_measurements) AS total_nb_measurements,
	min(v.coverage_start) AS coverage_start, 
	max(v.coverage_end) AS coverage_end, 
	round(avg(v.coverage_duration), 1) AS mean_coverage_duration,
	round(min(v.coverage_duration), 1) || ' - ' || round(max(v.coverage_duration), 1) AS no_data_days, -- Range in number of data days
	v.tag_type,
	min(v.min_lat) AS min_lat, 
	max(v.max_lat) AS max_lat, 
	min(v.min_lon) AS min_lon, 
	max(v.max_lon) AS max_lon,
	min(v.min_depth) AS min_depth,
	max(v.max_depth) AS max_depth
  FROM aatams_sattag_all_deployments_view v
    GROUP BY v.data_type, v.sattag_program, v.state_country, v.species_name, v.tag_type
    HAVING sum(v.nb_profiles) != 0
    ORDER BY v.data_type, v.species_name, v.tag_type, min(v.coverage_start);

grant all on table aatams_sattag_data_summary_view to public;

-- ALTER VIEW aatams_sattag_all_deployments_view OWNER TO harvest_reporting_write_group;
-- ALTER VIEW aatams_sattag_data_summary_view OWNER TO harvest_reporting_write_group;