SET search_path = report_test, pg_catalog, public;

-- VIEWS FOR AATAMS_SATTAG_NRT and AATAMS_SATTAG_DM
 CREATE or replace VIEW aatams_sattag_all_deployments_view AS
  SELECT 'Near real-time CTD data' AS data_type,
	COALESCE(m.sattag_program|| ' - ' || m.common_name || ' - ' || m.release_site || ' - ' || m.pi || ' - ' || m.tag_type) AS headers,
	m.sattag_program, 
	m.pi AS principal_investigator, 
	m.state_country AS release_site, 
	m.tag_type, 
	m.common_name AS species_name, 
	m.device_id AS tag_code, 
	COUNT(map.profile_id) AS nb_profiles,
	SUM(map.nb_measurements) AS nb_measurements,
	COALESCE(round(min(st_y(st_centroid(map.geom)))::numeric, 1) || '/' || round(max(st_y(st_centroid(map.geom)))::numeric, 1)) AS lat_range, 
	COALESCE(round(min(st_x(st_centroid(map.geom)))::numeric, 1) || '/' || round(max(st_x(st_centroid(map.geom)))::numeric, 1)) AS lon_range,
	COALESCE(min(map.min_pressure) || '-' || max(map.max_pressure)) AS depth_range,
	min(map."timestamp") AS coverage_start, 
	max(map."timestamp") AS coverage_end,
	date_part('days', max(map."timestamp") - min(map."timestamp"))::integer AS coverage_duration,
	CASE WHEN m.sattag_program IS NULL OR 
	m.common_name IS NULL OR 
	m.release_site IS NULL OR 
	m.pi IS NULL OR 
	m.tag_type IS NULL OR 
	m.device_id IS NULL OR 
	avg(m.release_lat) IS NULL OR 
	avg(m.release_lon) IS NULL OR 
	avg(date_part('year', map."timestamp")) IS NULL THEN 'Missing information from AATAMS sub-facility' END AS missing_info, 
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
	COALESCE(m.sattag_program|| ' - ' || m.common_name || ' - ' || m.release_site || ' - ' || m.pi || ' - ' || m.tag_type) AS headers,
	m.sattag_program, 
	m.pi AS principal_investigator, 
	m.state_country AS release_site, 
	m.tag_type, 
	m.common_name AS species_name, 
	m.device_id AS tag_code, 
	COUNT(dmap.profile_id) AS nb_profiles,
	SUM(dmap.nb_measurements) AS nb_measurements,
	COALESCE(round(min(st_y(st_centroid(dmap.geom)))::numeric, 1) || '/' || round(max(st_y(st_centroid(dmap.geom)))::numeric, 1)) AS lat_range, 
	COALESCE(round(min(st_x(st_centroid(dmap.geom)))::numeric, 1) || '/' || round(max(st_x(st_centroid(dmap.geom)))::numeric, 1)) AS lon_range,
	COALESCE(min(dmap.min_pressure) || '-' || max(dmap.max_pressure)) AS depth_range,
	min(dmap."timestamp") AS coverage_start, 
	max(dmap."timestamp") AS coverage_end,
	date_part('days', max(dmap."timestamp") - min(dmap."timestamp"))::integer AS coverage_duration,
	CASE WHEN m.sattag_program IS NULL OR 
	m.common_name IS NULL OR 
	m.release_site IS NULL OR 
	m.pi IS NULL OR 
	m.tag_type IS NULL OR 
	m.device_id IS NULL OR 
	avg(m.release_lat) IS NULL OR 
	avg(m.release_lon) IS NULL OR 
	avg(date_part('year', dmap."timestamp")) IS NULL THEN 'Missing information from AATAMS sub-facility' END AS missing_info, 
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
	ORDER BY data_type, sattag_program, coverage_start;

grant all on table aatams_sattag_all_deployments_view to public;

CREATE OR REPLACE VIEW aatams_sattag_data_summary_view AS
  SELECT v.data_type,
	COALESCE(v.species_name || ' - ' || v.tag_type) AS species_name_tag_type, 
	v.sattag_program, 
	v.release_site, 
	v.principal_investigator, 
	count(DISTINCT v.tag_code) AS no_tags, 
	sum(v.nb_profiles) AS total_nb_profiles,
	sum(v.nb_measurements) AS total_nb_measurements,
	min(v.coverage_start) AS coverage_start, 
	max(v.coverage_end) AS coverage_end, 
	round(avg(v.coverage_duration), 1) AS mean_coverage_duration, 
	v.tag_type, 
	v.species_name,
	COALESCE(min(v.min_lat) || '/' || max(v.max_lat)) AS lat_range, 
	COALESCE(min(v.min_lon) || '/' || max(v.max_lon)) AS lon_range,
	COALESCE(min(v.min_depth) || '/' || max(v.max_depth)) AS depth_range, 
	min(v.min_lat) AS min_lat, 
	max(v.max_lat) AS max_lat, 
	min(v.min_lon) AS min_lon, 
	max(v.max_lon) AS max_lon,
	min(v.min_depth) AS min_depth,
	max(v.max_depth) AS max_depth
  FROM aatams_sattag_all_deployments_view v
    GROUP BY v.data_type, v.sattag_program, v.release_site, v.species_name, v.principal_investigator, v.tag_type
    HAVING sum(v.nb_profiles) != 0
    ORDER BY v.data_type, v.species_name, v.tag_type, min(v.coverage_start);

grant all on table aatams_sattag_data_summary_view to public;

-- VIEWS FOR AATAMS_BIOLOGGING_PENGUIN AND AATAMS_BIOLOGGING_SHEARWATERS
CREATE OR REPLACE VIEW aatams_biologging_all_deployments_view AS 
  SELECT 'Emperor Penguin Fledglings' AS tagged_animals,
	pttid AS animal_id,
	no_observations AS nb_measurements,
	observation_start_date AS start_date,
	observation_end_date AS end_date,
	date_part('day', observation_end_date - observation_start_date)::numeric AS coverage_duration,
	COALESCE(round(ST_YMIN(geom)::numeric, 1) || '/' || round(ST_YMAX(geom)::numeric, 1)) AS lat_range,
	COALESCE(round(ST_XMIN(geom)::numeric, 1) || '/' || round(ST_XMAX(geom)::numeric, 1)) AS lon_range,
	round(ST_YMIN(geom)::numeric, 1) AS min_lat,
	round(ST_YMAX(geom)::numeric, 1) AS max_lat,
	round(ST_XMIN(geom)::numeric, 1) AS min_lon,
	round(ST_XMAX(geom)::numeric, 1) AS max_lon
  FROM aatams_biologging_penguin.aatams_biologging_penguin_map pm

UNION ALL

  SELECT 'Short-tailed shearwaters' AS tagged_animals, 
	ref AS animal_id,
	no_observations AS nb_measurements,
	start_date,
	end_date,
	date_part('day', end_date - start_date)::numeric AS coverage_duration,
	COALESCE(round(ST_YMIN(geom)::numeric, 1) || '/' || round(ST_YMAX(geom)::numeric, 1)) AS lat_range,
	COALESCE(round(ST_XMIN(geom)::numeric, 1) || '/' || round(ST_XMAX(geom)::numeric, 1)) AS lon_range,
	round(ST_YMIN(geom)::numeric, 1) AS min_lat,
	round(ST_YMAX(geom)::numeric, 1) AS max_lat,
	round(ST_XMIN(geom)::numeric, 1) AS min_lon,
	round(ST_XMAX(geom)::numeric, 1) AS max_lon
  FROM aatams_biologging_shearwater.aatams_biologging_shearwater_map sm
	ORDER BY tagged_animals, animal_id, start_date;

grant all on table aatams_biologging_all_deployments_view to public;

CREATE OR REPLACE VIEW aatams_biologging_data_summary_view AS
  SELECT tagged_animals,
	COUNT(DISTINCT(animal_id)) AS nb_animals,
	SUM(nb_measurements) AS total_nb_measurements,
	COALESCE(to_char(min(start_date),'DD/MM/YYYY') || ' - ' || to_char(max(end_date),'DD/MM/YYYY')) AS temporal_range,
	round(AVG(coverage_duration),1) AS mean_coverage_duration,
	COALESCE(round(min(min_lat)::numeric, 1) || '/' || round(max(max_lat)::numeric, 1)) AS lat_range,
	COALESCE(round(min(min_lon)::numeric, 1) || '/' || round(max(max_lon)::numeric, 1)) AS lon_range,
	min(start_date) AS earliest_date,
	max(end_date) AS latest_date,
	round(min(min_lat)::numeric, 1) AS min_lat,
	round(max(max_lat)::numeric, 1) AS max_lat,
	round(min(min_lon)::numeric, 1) AS min_lon,
	round(max(max_lon)::numeric, 1) AS max_lon
  FROM aatams_biologging_all_deployments_view v
	GROUP BY tagged_animals
	ORDER BY tagged_animals;

grant all on table aatams_biologging_data_summary_view to public;