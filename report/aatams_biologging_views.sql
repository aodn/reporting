SET search_path = report_test, public;

-- VIEWS FOR AATAMS_SATTAG_NRT and AATAMS_SATTAG_DM
 CREATE or replace VIEW aatams_sattag_all_deployments_view AS
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
	round(date_part('days', max(map."timestamp") - min(map."timestamp"))::numeric + ((date_part('hours', max(map."timestamp") - min(map."timestamp")))::numeric/24)::numeric, 1) AS coverage_duration,
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
	round(date_part('days', max(dmap."timestamp") - min(dmap."timestamp"))::numeric + ((date_part('hours', max(dmap."timestamp") - min(dmap."timestamp")))::numeric/24)::numeric, 1) AS coverage_duration,
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
	v.species_name, 
	v.sattag_program, 
	v.state_country AS release_site,
	count(DISTINCT v.tag_code) AS no_tags, 
	sum(v.nb_profiles) AS total_nb_profiles,
	sum(v.nb_measurements) AS total_nb_measurements,
	min(v.coverage_start) AS coverage_start, 
	max(v.coverage_end) AS coverage_end, 
	round(avg(v.coverage_duration), 1) AS mean_coverage_duration, 
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

-- VIEWS FOR AATAMS_BIOLOGGING_PENGUIN AND AATAMS_BIOLOGGING_SHEARWATERS
CREATE OR REPLACE VIEW aatams_biologging_all_deployments_view AS 
  SELECT 'Emperor Penguin Fledglings' AS tagged_animals,
	pttid AS animal_id,
	no_observations AS nb_measurements,
	observation_start_date AS start_date,
	observation_end_date AS end_date,
	round(date_part('days', observation_end_date - observation_start_date)::numeric + (date_part('hours', observation_end_date - observation_start_date)::numeric)/24, 1) AS coverage_duration,
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
	round(date_part('days', end_date - start_date)::numeric + (date_part('hours', end_date - start_date)::numeric)/24, 1) AS coverage_duration,
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