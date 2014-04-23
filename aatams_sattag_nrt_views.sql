SET search_path = report_test, pg_catalog, public;

-- -- drop all current views
-- select admin.exec( 'drop view if exists '||schema||'.'||name||' cascade' ) 
-- 	from admin.objects3 
-- 	where kind = 'v' 
-- 	and schema = 'reporting'
-- ;

-- has data
-- :'<,'>s/aatams_sattag\./legacy_aatams_sattag./g
-- :'<,'>s/aatams_sattag_mdb_workflow_manual/report.aatams_sattag_mdb_workflow_manual/g

-- VIEWS FOR AATAMS_SATTAG_NRT; reporting views for AATAMS_SATTAG_DM do not exist yet
 CREATE or replace VIEW aatams_sattag_all_deployments_view AS
    SELECT 
    COALESCE(m.sattag_program|| ' - ' || m.common_name || ' - ' || m.release_site || ' - ' || m.pi || ' - ' || m.tag_type) AS headers,
    m.sattag_program, 
    m.pi AS principal_investigator, 
    m.state_country AS release_site, 
    m.tag_type, 
    m.common_name AS species_name, 
    m.device_id AS tag_code, 
    COUNT(map.profile_id) AS nb_profiles,
    COALESCE(round(min(st_y(st_centroid(map.geom)))::numeric, 1) || '/' || round(max(st_y(st_centroid(map.geom)))::numeric, 1)) AS lat_range, 
    COALESCE(round(min(st_x(st_centroid(map.geom)))::numeric, 1) || '/' || round(max(st_x(st_centroid(map.geom)))::numeric, 1)) AS lon_range,
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
    round(max(st_x(st_centroid(map.geom)))::numeric, 1) AS max_lon 
    FROM aatams_sattag_nrt.aatams_sattag_nrt_metadata m
    LEFT JOIN aatams_sattag_nrt.aatams_sattag_nrt_profile_map map ON m.device_id = map.device_id 
     WHERE m.device_wmo_ref != ''
     GROUP BY m.sattag_program, m.device_id, m.tag_type, m.pi, m.common_name, m.release_site
     ORDER BY headers, m.device_id;

grant all on table aatams_sattag_all_deployments_view to public;

CREATE OR REPLACE VIEW aatams_sattag_data_summary_view AS
WITH table_a AS (
	SELECT v.sattag_program, v.species_name,
	sum(v.nb_profiles) AS total_nb_profiles
	FROM aatams_sattag_all_deployments_view v
	GROUP BY v.sattag_program,v.species_name)
    SELECT 
    COALESCE(v.species_name || ' - ' || v.tag_type) AS species_name_tag_type, 
    v.sattag_program, 
    v.release_site, 
    v.principal_investigator, 
    count(DISTINCT v.tag_code) AS no_tags, 
    total_nb_profiles, 
    min(v.coverage_start) AS coverage_start, 
    max(v.coverage_end) AS coverage_end, 
    round(avg(v.coverage_duration), 1) AS mean_coverage_duration, 
    v.tag_type, 
    v.species_name, 
    min(v.min_lat) AS min_lat, 
    max(v.max_lat) AS max_lat, 
    min(v.min_lon) AS min_lon, 
    max(v.max_lon) AS max_lon 
    FROM aatams_sattag_all_deployments_view v
    JOIN table_a ON v.sattag_program = table_a.sattag_program AND v.species_name = table_a.species_name
    WHERE total_nb_profiles != 0
    GROUP BY v.sattag_program, v.release_site, v.species_name, v.principal_investigator, v.tag_type, table_a.total_nb_profiles
    ORDER BY v.species_name, v.tag_type, v.sattag_program;

    grant all on table aatams_sattag_data_summary_view to public;
