
-- Remember that we can look up stuff, in the old report_db  

-- to generate the views in the schema
-- psql -h dbprod.emii.org.au -U jfca -d harvest -f reporting_views.sql



-- to see the objects
-- psql -h dbprod.emii.org.au -U jfca -d harvest -c 'select * from admin.objects3'

-- to test data
-- psql -h dbprod.emii.org.au -U jfca -d harvest -c 'select * from reporting.aatams_sattag_data_summary_view  limit 10 '


SET statement_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = off;
SET check_function_bodies = false;
SET client_min_messages = warning;
SET escape_string_warning = off;

SET search_path = report_test, pg_catalog, public;


-- -- drop all current views
-- select admin.exec( 'drop view if exists '||schema||'.'||name||' cascade' ) 
-- 	from admin.objects3 
-- 	where kind = 'v' 
-- 	and schema = 'reporting'
-- ;



-------------------------------
-- VIEWS FOR AATAMS_SATTAG_NRT; reporting views for AATAMS_SATTAG_DM do not exist yet; Can delete the aatams_sattag manual tables in the report schema.
-------------------------------
-- has data
-- :'<,'>s/aatams_sattag\./legacy_aatams_sattag./g
-- :'<,'>s/aatams_sattag_mdb_workflow_manual/report.aatams_sattag_mdb_workflow_manual/g
-------------------------------

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


-------------------------------
-- VIEWS FOR ABOS; Now using what's in the abos schema so don't need the dw_abos schema anymore.
-------------------------------
-- has data
-- :'<,'>s/abos\./dw_abos./g

CREATE or replace VIEW abos_asfssots_all_deployments_view AS
    WITH table_a AS (
    SELECT 
    "substring"(url, 'IMOS/ABOS/([A-Z]+)/') AS sub_facility, 
    CASE WHEN platform_code = 'PULSE' THEN 'Pulse' 
    ELSE platform_code END AS platform_code, 
    CASE WHEN deployment_code IS NULL THEN COALESCE(platform_code || '-' || CASE WHEN (deployment_number IS NULL) THEN '' 
    ELSE deployment_number END) || '-' || btrim(to_char(time_coverage_start, 'YYYY')) ELSE deployment_code END AS deployment_code,
    "substring"(url, '[^/]+nc') AS file_name,
    ("substring"(url, 'FV0([12]+)'))::integer AS file_version,
    CASE WHEN "substring"(url, '(Surface_waves|Surface_properties|Surface_fluxes|Sub-surface_temperature_pressure_conductivity|Pulse|Sub-surface_currents)') = 'Pulse' THEN 'Biogeochemistry' 
    ELSE "substring"(url, '(Surface_waves|Surface_properties|Surface_fluxes|Sub-surface_temperature_pressure_conductivity|Pulse|Sub-surface_currents)') END AS data_category,
    COALESCE("substring"(url, 'Real-time'), 'Delayed-mode') AS data_type, 
    COALESCE("substring"(url, '[0-9]{4}_daily'), 'Whole deployment') AS year_frequency, 
    timezone('UTC'::text, time_coverage_start) AS coverage_start, 
    timezone('UTC'::text, time_coverage_end) AS coverage_end, 
    round(((date_part('day', (time_coverage_end - time_coverage_start)) + (date_part('hours'::text, (time_coverage_end - time_coverage_start)) / (24)::double precision)))::numeric, 1) AS coverage_duration, 
    (date_part('day', (last_modified - date_created)))::integer AS days_to_process_and_upload, 
    (date_part('day', (last_indexed - last_modified)))::integer AS days_to_make_public, 
    deployment_number, author, principal_investigator 
    FROM abos.abos_file_vw
    WHERE status IS DISTINCT FROM 'DELETED'
    ORDER BY sub_facility, platform_code, data_category)
SELECT 
CASE WHEN a.year_frequency = 'Whole deployment' THEN 'Aggregated files' 
    ELSE 'Daily files' END AS file_type, 
COALESCE(a.sub_facility || '-' || a.platform_code || ' - ' || a.data_type) AS headers, 
a.data_type, 
a.data_category, 
a.deployment_code, 
sum(((a.file_version = 1))::integer) AS no_fv1, 
sum(((a.file_version = 2))::integer) AS no_fv2, 
date(min(a.coverage_start)) AS coverage_start, 
date(max(a.coverage_end)) AS coverage_end, 
min(a.coverage_start) AS time_coverage_start, 
max(a.coverage_end) AS time_coverage_end, 
CASE WHEN a.data_type = 'Delayed-mode' AND a.year_frequency = 'Whole deployment' THEN max(a.coverage_duration) 
    ELSE (date(max(a.coverage_end)) - date(min(a.coverage_start)))::numeric END AS coverage_duration, 
round(avg(a.days_to_process_and_upload), 1) AS mean_days_to_process_and_upload, 
round(avg(a.days_to_make_public), 1) AS mean_days_to_make_public, 
a.deployment_number, a.author, 
a.principal_investigator, 
a.platform_code, 
a.sub_facility 
FROM table_a a
GROUP BY headers, a.deployment_code, a.data_category, a.data_type, a.year_frequency, a.deployment_number, a.author, a.principal_investigator, a.platform_code, a.sub_facility 
ORDER BY file_type, headers, a.data_type, a.data_category, a.deployment_code;

grant all on table abos_asfssots_all_deployments_view to public;


CREATE or replace VIEW abos_asfssots_data_summary_view AS
    SELECT 
    v.file_type, 
    v.headers, 
    v.data_type, 
    v.data_category, 
    count(DISTINCT v.deployment_code) AS no_deployments, 
    sum(v.no_fv1) AS no_fv1, 
    sum(v.no_fv2) AS no_fv2, 
    min(v.coverage_start) AS coverage_start, 
    max(v.coverage_end) AS coverage_end, 
    ceil(((date_part('day', (max(v.time_coverage_end) - min(v.time_coverage_start))) + (date_part('hours', (max(v.time_coverage_end) - min(v.time_coverage_start))) / (24)::double precision)))::numeric) AS coverage_duration, (sum(v.coverage_duration))::integer AS data_coverage, 
    CASE WHEN max(v.coverage_end) - min(v.coverage_start) = 0 THEN 0 
    ELSE (((sum(v.coverage_duration) / ((max(v.coverage_end) - min(v.coverage_start)))::numeric) * (100)::numeric))::integer END AS percent_coverage, 
    round(avg(v.mean_days_to_process_and_upload), 1) AS mean_days_to_process_and_upload, 
    round(avg(v.mean_days_to_make_public), 1) AS mean_days_to_make_public, 
    v.platform_code, 
    v.sub_facility 
    FROM abos_asfssots_all_deployments_view v
    WHERE v.headers IS NOT NULL 
    GROUP BY v.headers, v.data_category, v.data_type, v.file_type, v.platform_code, v.sub_facility 
    ORDER BY v.file_type, v.headers, v.data_type, v.data_category;

grant all on table abos_asfssots_data_summary_view to public;


-------------------------------
-- VIEW FOR ACORN; Still using the acorn_manual table from the report schema: needs to be updated to use the two acorn schemas - acorn_hourly_avg_nonqc & acorn_hourly_avg_qc
-------------------------------
-- has data
-- acorn_manual -> report.acorn_manual

CREATE or replace VIEW acorn_all_deployments_view AS
    SELECT m.code_type, 
    CASE WHEN m.site_id = 1 THEN 'Capricorn Bunker Group' 
    WHEN m.site_id = 2 THEN 'Rottnest Shelf' 
    WHEN m.site_id = 3 THEN 'South Australia Gulf' 
    WHEN m.site_id = 4 THEN 'Coffs Harbour' 
    WHEN m.site_id = 5 THEN 'Turquoise Coast' 
    ELSE 'Bonney Coast' END AS site,
    m.code_full_name,
    date(m.start_date_of_transmission) AS start, 
    (m.non_qc_data_availability_percent)::numeric AS non_qc_radial, 
    (m.non_qc_data_portal_percent)::numeric AS non_qc_grid, 
    (m.qc_data_availability_percent)::numeric AS qc_radial, 
    (m.qc_data_portal_percent)::numeric AS qc_grid, 
    date(m.last_qc_data_received) AS last_qc_date, 
    date(m.data_on_staging) AS data_on_staging, 
    date(m.data_on_opendap) AS data_on_opendap, 
    date(m.data_on_portal) AS data_on_portal, 
    (date_part('day'::text, (m.last_qc_data_received - m.start_date_of_transmission)))::integer AS qc_coverage_duration, 
    (date_part('day'::text, (m.data_on_opendap - m.start_date_of_transmission)))::integer AS days_to_process_and_upload, 
    CASE WHEN m.data_on_portal IS NULL THEN (date_part('day', (m.data_on_opendap - m.start_date_of_transmission)))::integer 
    ELSE (date_part('day'::text, (m.data_on_portal - m.data_on_opendap)))::integer END AS days_to_make_public, 
    CASE WHEN m.mest_creation IS NULL THEN 'No' 
    ELSE 'Yes' END AS metadata 
    FROM report.acorn_manual m
    GROUP BY m.code_type, m.site_id, m.code_full_name, m.start_date_of_transmission, m.non_qc_data_availability_percent, m.non_qc_data_portal_percent, m.qc_data_availability_percent, m.qc_data_portal_percent, m.last_qc_data_received, m.data_on_staging, m.data_on_opendap, m.data_on_portal, m.mest_creation 
    ORDER BY site, m.code_type, m.code_full_name;

grant all on table acorn_all_deployments_view to public;


-- has data
-- '<,'>s/anfog\./legacy_anfog./g
-- anfog_manual -> report.anfog_manual 

CREATE or replace VIEW anfog_all_deployments_view AS
    SELECT anfog_glider.glider_type, anfog_glider.platform, anfog_manual.deployment_id, anfog_manual.deployment_start AS start_date, date(anfog_glider.time_end) AS end_date, round((anfog_glider.min_lat)::numeric, 1) AS min_lat, CASE WHEN (anfog_glider.max_lat = (99999.0)::double precision) THEN round((anfog_glider.min_lat)::numeric, 1) ELSE round((anfog_glider.max_lat)::numeric, 1) END AS max_lat, round((anfog_glider.min_lon)::numeric, 1) AS min_lon, CASE WHEN (anfog_glider.max_lon = (99999.0)::double precision) THEN round((anfog_glider.min_lon)::numeric, 1) ELSE round((anfog_glider.max_lon)::numeric, 1) END AS max_lon, COALESCE(((round((anfog_glider.min_lat)::numeric, 1) || '/'::text) || round((anfog_glider.max_lat)::numeric, 1))) AS lat_range, COALESCE(((round((anfog_glider.min_lon)::numeric, 1) || '/'::text) || round((anfog_glider.max_lon)::numeric, 1))) AS lon_range, (anfog_glider.max_depth)::integer AS max_depth, CASE WHEN (anfog_glider.uuid IS NULL) THEN 'No'::text ELSE 'Yes'::text END AS metadata, CASE WHEN (anfog_manual.data_on_opendap IS NULL) THEN 'No'::text ELSE 'Yes'::text END AS qc_data, anfog_manual.data_on_staging, anfog_manual.data_on_opendap, anfog_manual.data_on_portal, (date_part('day'::text, (anfog_glider.time_end - (anfog_manual.deployment_start)::timestamp without time zone)))::integer AS coverage_duration, (date_part('day'::text, ((anfog_manual.data_on_staging)::timestamp without time zone - anfog_glider.time_end)))::integer AS days_to_process_and_upload, (anfog_manual.data_on_portal - anfog_manual.data_on_staging) AS days_to_make_public FROM (legacy_anfog.anfog_glider RIGHT JOIN report.anfog_manual ON (((anfog_manual.deployment_id)::text = (anfog_glider.deployment_name)::text))) ORDER BY anfog_glider.glider_type, anfog_glider.platform, anfog_glider.deployment_name;

grant all on table anfog_all_deployments_view to public;


-- has data
-- no changes

CREATE or replace VIEW anfog_data_summary_view AS
    SELECT CASE WHEN (anfog_all_deployments_view.glider_type IS NULL) THEN 'Unknown'::character varying ELSE anfog_all_deployments_view.glider_type END AS glider_type, count(DISTINCT anfog_all_deployments_view.platform) AS no_platforms, count(DISTINCT anfog_all_deployments_view.deployment_id) AS no_deployments, min(anfog_all_deployments_view.start_date) AS earliest_date, max(anfog_all_deployments_view.end_date) AS latest_date, COALESCE(((min(anfog_all_deployments_view.min_lat) || '/'::text) || max(anfog_all_deployments_view.max_lat))) AS lat_range, COALESCE(((min(anfog_all_deployments_view.min_lon) || '/'::text) || max(anfog_all_deployments_view.max_lon))) AS lon_range, COALESCE(((min(anfog_all_deployments_view.max_depth) || '/'::text) || max(anfog_all_deployments_view.max_depth))) AS max_depth_range, round(avg(anfog_all_deployments_view.coverage_duration), 1) AS mean_coverage_duration, round(avg(anfog_all_deployments_view.days_to_process_and_upload), 1) AS mean_days_to_process_and_upload, round(avg(anfog_all_deployments_view.days_to_make_public), 1) AS mean_days_to_make_public, min(anfog_all_deployments_view.min_lat) AS min_lat, max(anfog_all_deployments_view.max_lat) AS max_lat, min(anfog_all_deployments_view.min_lon) AS min_lon, max(anfog_all_deployments_view.max_lon) AS max_lon, min(anfog_all_deployments_view.max_depth) AS min_depth, max(anfog_all_deployments_view.max_depth) AS max_depth FROM anfog_all_deployments_view GROUP BY anfog_all_deployments_view.glider_type ORDER BY CASE WHEN (anfog_all_deployments_view.glider_type IS NULL) THEN 'Unknown'::character varying ELSE anfog_all_deployments_view.glider_type END;

grant all on table anfog_data_summary_view to public;

-- has data
-- definitive is the acoustic_deployments table from acoustic_data_viewer
-- there's a join with legacy_anmn

-- backed up the acoustic_data_viewer application then 
-- pg_restore -x -O -n anmn -t acoustic_deployments  acoustic_data_viewer.dump    > acoustic_deployments.sql

CREATE or replace VIEW anmn_acoustics_all_deployments_view AS
    SELECT COALESCE(acoustic_deployments.deployment_name|| ' - Lat/Lon:'|| round(anmn_acoustics.lat::numeric, 1) || '/' || round(anmn_acoustics.lon::numeric, 1)) AS site_name, "substring"((acoustic_deployments.deployment_name)::text, '2[-0-9]+'::text) AS deployment_year, acoustic_deployments.logger_id, bool_or((((acoustic_deployments.set_success)::text !~~* '%fail%'::text) AND (acoustic_deployments.frequency = 6))) AS good_data, bool_or((((acoustic_deployments.set_success)::text !~~* '%fail%'::text) AND (acoustic_deployments.frequency = 22))) AS good_22, bool_or((acoustic_deployments.is_primary AND (acoustic_deployments.data_path IS NOT NULL))) AS on_viewer, round(avg((acoustic_deployments.receiver_depth)::numeric), 1) AS depth, min(date(acoustic_deployments.time_deployment_start)) AS start_date, max(date(acoustic_deployments.time_deployment_end)) AS end_date, (max(date(acoustic_deployments.time_deployment_end)) - min(date(acoustic_deployments.time_deployment_start))) AS coverage_duration, CASE WHEN (((((((((acoustic_deployments.logger_id IS NULL) OR (avg(date_part('year'::text, acoustic_deployments.time_deployment_end)) IS NULL)) OR bool_or((acoustic_deployments.frequency IS NULL))) OR bool_or((acoustic_deployments.set_success IS NULL))) OR (avg(acoustic_deployments.lat) IS NULL)) OR (avg(acoustic_deployments.lon) IS NULL)) OR (avg(acoustic_deployments.receiver_depth) IS NULL)) OR bool_or((acoustic_deployments.system_gain_file IS NULL))) OR bool_or((acoustic_deployments.hydrophone_sensitivity IS NULL))) THEN 'Missing information from PAO sub-facility'::text ELSE NULL::text END AS missing_info FROM (reporting.acoustic_deployments LEFT JOIN legacy_anmn.anmn_acoustics ON (((acoustic_deployments.site_code)::text = "substring"((anmn_acoustics.code)::text, 1, 5)))) GROUP BY acoustic_deployments.deployment_name, anmn_acoustics.lat, anmn_acoustics.lon, acoustic_deployments.logger_id ORDER BY COALESCE((((("substring"((acoustic_deployments.deployment_name)::text, '\D+'::text) || ' - Lat/Lon:'::text) || round((anmn_acoustics.lat)::numeric, 1)) || '/'::text) || round((anmn_acoustics.lon)::numeric, 1))), "substring"((acoustic_deployments.deployment_name)::text, '2[-0-9]+'::text), acoustic_deployments.logger_id;

grant all on table anmn_acoustics_all_deployments_view to public;


-- refers to the above,

CREATE or replace VIEW anmn_acoustics_data_summary_view AS
 SELECT anmn_acoustics_all_deployments_view.site_name, anmn_acoustics_all_deployments_view.deployment_year, count(*) AS no_loggers, sum((anmn_acoustics_all_deployments_view.good_data)::integer) AS no_good_data, sum((anmn_acoustics_all_deployments_view.on_viewer)::integer) AS no_sets_on_viewer, sum((anmn_acoustics_all_deployments_view.good_22)::integer) AS no_good_22, min(anmn_acoustics_all_deployments_view.start_date) AS earliest_date, max(anmn_acoustics_all_deployments_view.end_date) AS latest_date, (max(anmn_acoustics_all_deployments_view.end_date) - min(anmn_acoustics_all_deployments_view.start_date)) AS coverage_duration, sum(CASE WHEN ("substring"(anmn_acoustics_all_deployments_view.missing_info, 'PAO'::text) IS NULL) THEN 0 ELSE 1 END) AS no_missing_info_pao_subfacility, sum(CASE WHEN ("substring"(anmn_acoustics_all_deployments_view.missing_info, 'eMII'::text) IS NULL) THEN 0 ELSE 1 END) AS no_missing_info_emii FROM anmn_acoustics_all_deployments_view GROUP BY anmn_acoustics_all_deployments_view.site_name, anmn_acoustics_all_deployments_view.deployment_year ORDER BY anmn_acoustics_all_deployments_view.site_name, anmn_acoustics_all_deployments_view.deployment_year;

grant all on table anmn_acoustics_data_summary_view to public;


-- has data
-- anmn_platforms_manual --> report.anmn_platforms_manual 
-- there are three schemas with anmn_mv table (dw_anmn, dw_anmn_realtime, legacy_anmn )  
-- I don't know which one to use ...
-- use dw_anmn 

CREATE or replace VIEW anmn_all_deployments_view AS
    WITH site_view AS (SELECT anmn_platforms_manual.site_code, anmn_platforms_manual.site_name, avg(anmn_platforms_manual.lat) AS site_lat, avg(anmn_platforms_manual.lon) AS site_lon, (avg(anmn_platforms_manual.depth))::integer AS site_depth, min(anmn_platforms_manual.first_deployed) AS site_first_deployed, max(anmn_platforms_manual.discontinued) AS site_discontinued, bool_or(anmn_platforms_manual.active) AS site_active FROM report.anmn_platforms_manual GROUP BY anmn_platforms_manual.site_code, anmn_platforms_manual.site_name ORDER BY anmn_platforms_manual.site_code), file_view AS (SELECT DISTINCT "substring"((dw_anmn.anmn_mv.url)::text, 'IMOS/ANMN/([A-Z]+)/'::text) AS subfacility, anmn_mv.site_code, anmn_mv.platform_code, anmn_mv.deployment_code, "substring"((anmn_mv.url)::text, '([^_]+)_END'::text) AS deployment_product, anmn_mv.status, "substring"(anmn_mv.file_version, 'Level ([012]+)'::text) AS file_version, "substring"((anmn_mv.url)::text, '(Temperature|CTD_timeseries|CTD_profiles|Biogeochem_timeseries|Biogeochem_profiles|Velocity|Wave|CO2|Meteorology)'::text) AS data_category, NULLIF(anmn_mv.geospatial_vertical_min, '-Infinity'::double precision) AS geospatial_vertical_min, NULLIF(anmn_mv.geospatial_vertical_max, 'Infinity'::double precision) AS geospatial_vertical_max, CASE WHEN (timezone('UTC'::text, anmn_mv.time_deployment_start) IS NULL) THEN anmn_mv.time_coverage_start ELSE (timezone('UTC'::text, anmn_mv.time_deployment_start))::timestamp with time zone END AS time_deployment_start, CASE WHEN (timezone('UTC'::text, anmn_mv.time_deployment_end) IS NULL) THEN anmn_mv.time_coverage_end ELSE (timezone('UTC'::text, anmn_mv.time_deployment_end))::timestamp with time zone END AS time_deployment_end, timezone('UTC'::text, GREATEST(anmn_mv.time_deployment_start, anmn_mv.time_coverage_start)) AS good_data_start, timezone('UTC'::text, LEAST(anmn_mv.time_deployment_end, anmn_mv.time_coverage_end)) AS good_data_end, (anmn_mv.time_coverage_end - anmn_mv.time_coverage_start) AS coverage_duration, (anmn_mv.time_deployment_end - anmn_mv.time_deployment_start) AS deployment_duration, GREATEST('00:00:00'::interval, (LEAST(anmn_mv.time_deployment_end, anmn_mv.time_coverage_end) - GREATEST(anmn_mv.time_deployment_start, anmn_mv.time_coverage_start))) AS good_data_duration, date(timezone('UTC'::text, anmn_mv.date_created)) AS date_processed, date(timezone('UTC'::text, anmn_mv.last_modified)) AS date_uploaded, date(timezone('UTC'::text, anmn_mv.first_indexed)) AS date_public, CASE WHEN (date_part('day'::text, (anmn_mv.last_modified - anmn_mv.time_deployment_end)) IS NULL) THEN date_part('day'::text, (anmn_mv.last_modified - anmn_mv.time_coverage_end)) ELSE date_part('day'::text, (anmn_mv.last_modified - anmn_mv.time_deployment_end)) END AS processing_duration, date_part('day'::text, (anmn_mv.last_indexed - anmn_mv.last_modified)) AS publication_duration FROM dw_anmn.anmn_mv ORDER BY "substring"((anmn_mv.url)::text, 'IMOS/ANMN/([A-Z]+)/'::text), anmn_mv.deployment_code, "substring"((anmn_mv.url)::text, '(Temperature|CTD_timeseries|CTD_profiles|Biogeochem_timeseries|Biogeochem_profiles|Velocity|Wave|CO2|Meteorology)'::text)) SELECT file_view.subfacility, COALESCE(((((((((site_view.site_name)::text || ' ('::text) || file_view.site_code) || ')'::text) || ' - Lat/Lon:'::text) || round((min(site_view.site_lat))::numeric, 1)) || '/'::text) || round((min(site_view.site_lon))::numeric, 1))) AS site_name_code, file_view.data_category, file_view.deployment_code, (sum(((file_view.file_version = '0'::text))::integer))::numeric AS no_fv00, (sum(((file_view.file_version = '1'::text))::integer))::numeric AS no_fv01, date(min(file_view.time_deployment_start)) AS start_date, date(max(file_view.time_deployment_end)) AS end_date, (date_part('day'::text, (max(file_view.time_deployment_end) - min(file_view.time_deployment_start))))::numeric AS coverage_duration, (date_part('day'::text, (max(file_view.good_data_end) - min(file_view.good_data_start))))::numeric AS data_coverage, round((avg(file_view.processing_duration))::numeric, 1) AS mean_days_to_process_and_upload, round((avg(file_view.publication_duration))::numeric, 1) AS mean_days_to_make_public, CASE WHEN ((((((sum(CASE WHEN (site_view.site_name IS NULL) THEN 0 ELSE 1 END) <> count(file_view.subfacility)) OR (sum(CASE WHEN (file_view.time_deployment_start IS NULL) THEN 0 ELSE 1 END) <> count(file_view.subfacility))) OR (sum(CASE WHEN (file_view.time_deployment_end IS NULL) THEN 0 ELSE 1 END) <> count(file_view.subfacility))) OR (sum(CASE WHEN (file_view.date_processed IS NULL) THEN 0 ELSE 1 END) <> count(file_view.subfacility))) OR (sum(CASE WHEN (file_view.date_uploaded IS NULL) THEN 0 ELSE 1 END) <> count(file_view.subfacility))) OR (sum(CASE WHEN (file_view.site_code IS NULL) THEN 0 ELSE 1 END) <> count(file_view.subfacility))) THEN COALESCE((((('Missing information from'::text || ' '::text) || file_view.subfacility) || ' '::text) || 'sub-facility'::text)) WHEN (sum(CASE WHEN (file_view.date_public IS NULL) THEN 0 ELSE 1 END) <> count(file_view.subfacility)) THEN 'Missing information from eMII'::text ELSE NULL::text END AS missing_info, date(min(file_view.good_data_start)) AS good_data_start, date(max(file_view.good_data_end)) AS good_data_end, round((min(site_view.site_lat))::numeric, 1) AS min_lat, round((min(site_view.site_lon))::numeric, 1) AS min_lon, round((max(site_view.site_lat))::numeric, 1) AS max_lat, round((max(site_view.site_lon))::numeric, 1) AS max_lon, round((min(file_view.geospatial_vertical_min))::numeric, 1) AS min_depth, round((max(file_view.geospatial_vertical_max))::numeric, 1) AS max_depth, max(file_view.date_processed) AS date_processed, max(file_view.date_uploaded) AS data_on_staging, max(file_view.date_public) AS data_on_portal, file_view.site_code FROM (file_view NATURAL LEFT JOIN site_view) WHERE (file_view.status IS NULL) GROUP BY file_view.subfacility, file_view.site_code, site_view.site_name, file_view.data_category, file_view.deployment_code ORDER BY file_view.subfacility, file_view.site_code, file_view.data_category, file_view.deployment_code;

grant all on table anmn_all_deployments_view to public;


-- has data
-- no change

CREATE or replace VIEW anmn_data_summary_view AS
    SELECT anmn_all_deployments_view.subfacility, anmn_all_deployments_view.site_name_code, anmn_all_deployments_view.data_category, count(*) AS no_deployments, sum(anmn_all_deployments_view.no_fv00) AS no_fv00, sum(anmn_all_deployments_view.no_fv01) AS no_fv01, CASE WHEN (CASE WHEN (min(anmn_all_deployments_view.min_depth) < (0)::numeric) THEN (min(anmn_all_deployments_view.min_depth) * ((-1))::numeric) ELSE min(anmn_all_deployments_view.min_depth) END > max(anmn_all_deployments_view.max_depth)) THEN COALESCE(((max(anmn_all_deployments_view.max_depth) || '/'::text) || CASE WHEN (min(anmn_all_deployments_view.min_depth) < (0)::numeric) THEN (min(anmn_all_deployments_view.min_depth) * ((-1))::numeric) ELSE min(anmn_all_deployments_view.min_depth) END)) ELSE COALESCE(((CASE WHEN (min(anmn_all_deployments_view.min_depth) < (0)::numeric) THEN (min(anmn_all_deployments_view.min_depth) * ((-1))::numeric) ELSE min(anmn_all_deployments_view.min_depth) END || '/'::text) || max(anmn_all_deployments_view.max_depth))) END AS depth_range, min(anmn_all_deployments_view.start_date) AS earliest_date, max(anmn_all_deployments_view.end_date) AS latest_date, (max(anmn_all_deployments_view.end_date) - min(anmn_all_deployments_view.start_date)) AS coverage_duration, sum(anmn_all_deployments_view.data_coverage) AS data_coverage, CASE WHEN (round(((sum(anmn_all_deployments_view.data_coverage) / ((max(anmn_all_deployments_view.end_date) - min(anmn_all_deployments_view.start_date)))::numeric) * (100)::numeric), 1) < (0)::numeric) THEN NULL::numeric WHEN (round(((sum(anmn_all_deployments_view.data_coverage) / ((max(anmn_all_deployments_view.end_date) - min(anmn_all_deployments_view.start_date)))::numeric) * (100)::numeric), 1) > (100)::numeric) THEN (100)::numeric ELSE round(((sum(anmn_all_deployments_view.data_coverage) / ((max(anmn_all_deployments_view.end_date) - min(anmn_all_deployments_view.start_date)))::numeric) * (100)::numeric), 1) END AS percent_coverage, round(avg(anmn_all_deployments_view.mean_days_to_process_and_upload), 1) AS mean_days_to_process_and_upload, round(avg(anmn_all_deployments_view.mean_days_to_make_public), 1) AS mean_days_to_make_public, sum(CASE WHEN (anmn_all_deployments_view.missing_info IS NULL) THEN 0 WHEN ("substring"(anmn_all_deployments_view.missing_info, 'facility'::text) IS NOT NULL) THEN 1 ELSE NULL::integer END) AS missing_info_facility, sum(CASE WHEN (anmn_all_deployments_view.missing_info IS NULL) THEN 0 WHEN ("substring"(anmn_all_deployments_view.missing_info, 'eMII'::text) IS NOT NULL) THEN 1 ELSE NULL::integer END) AS missing_info_emii, min(anmn_all_deployments_view.min_lat) AS min_lat, min(anmn_all_deployments_view.min_lon) AS min_lon, min(anmn_all_deployments_view.min_depth) AS min_depth, max(anmn_all_deployments_view.max_depth) AS max_depth, anmn_all_deployments_view.site_code FROM anmn_all_deployments_view GROUP BY anmn_all_deployments_view.subfacility, anmn_all_deployments_view.site_name_code, anmn_all_deployments_view.data_category, anmn_all_deployments_view.site_code ORDER BY anmn_all_deployments_view.subfacility, anmn_all_deployments_view.site_code, anmn_all_deployments_view.data_category;

grant all on table anmn_data_summary_view to public;




-- has data
-- anmn -> legacy_anmn 
-- Needs to be added as a manual table,

-- had to explicitly copy the table nrs_aims_manual. This table is not referenced anywhere  
-- in the inventory application.

CREATE or replace VIEW anmn_nrs_realtime_all_deployments_view AS
 SELECT COALESCE((((((nrs_platforms.platform_code)::text || ' - Lat / Lon: '::text) || round((nrs_platforms.lat)::numeric, 1)) || ' / '::text) || round((nrs_platforms.lon)::numeric, 1))) AS site_name, nrs_parameters.parameter, nrs_parameters.channelid AS channel_id, round((nrs_parameters.depth_sensor)::numeric, 1) AS sensor_depth, CASE WHEN (nrs_parameters.qaqc_boolean = 1) THEN true ELSE false END AS qaqc_data, CASE WHEN (date_part('day'::text, (nrs_parameters.time_coverage_end - nrs_parameters.time_coverage_start)) IS NULL) THEN 'Missing dates'::text WHEN (nrs_parameters.metadata_uuid IS NULL) THEN 'No metadata'::text ELSE NULL::text END AS missing_info, date(nrs_parameters.time_coverage_start) AS start_date, date(nrs_parameters.time_coverage_end) AS end_date, (date_part('day'::text, (nrs_parameters.time_coverage_end - nrs_parameters.time_coverage_start)))::numeric AS coverage_duration, (date_part('day'::text, (nrs_aims_manual.data_on_staging - nrs_parameters.time_coverage_start)))::numeric AS days_to_process_and_upload, (date_part('day'::text, (nrs_aims_manual.data_on_portal - nrs_aims_manual.data_on_staging)))::numeric AS days_to_make_public, nrs_platforms.platform_code, round((nrs_platforms.lat)::numeric, 1) AS lat, round((nrs_platforms.lon)::numeric, 1) AS lon, date(nrs_aims_manual.data_on_staging) AS date_on_staging, date(nrs_aims_manual.data_on_opendap) AS date_on_opendap, date(nrs_aims_manual.data_on_portal) AS date_on_portal, nrs_aims_manual.mest_creation, nrs_parameters.no_qaqc_boolean AS no_qaqc_data, nrs_parameters.metadata_uuid AS channel_uuid FROM ((legacy_anmn.nrs_parameters LEFT JOIN legacy_anmn.nrs_platforms ON ((nrs_platforms.pkid = nrs_parameters.fk_nrs_platforms))) LEFT JOIN report.nrs_aims_manual ON (((nrs_aims_manual.platform_name)::text = (nrs_platforms.platform_code)::text))) ORDER BY COALESCE((((((nrs_platforms.platform_code)::text || ' - Lat / Lon: '::text) || round((nrs_platforms.lat)::numeric, 1)) || ' / '::text) || round((nrs_platforms.lon)::numeric, 1))), nrs_parameters.parameter, nrs_parameters.channelid;

grant all on table anmn_nrs_realtime_all_deployments_view to public;



CREATE or replace VIEW anmn_nrs_realtime_data_summary_view AS
 SELECT anmn_nrs_realtime_all_deployments_view.platform_code AS site_name, count(DISTINCT anmn_nrs_realtime_all_deployments_view.channel_id) AS no_sensors, count(DISTINCT anmn_nrs_realtime_all_deployments_view.parameter) AS no_parameters, sum(CASE WHEN (anmn_nrs_realtime_all_deployments_view.qaqc_data = true) THEN 1 ELSE 0 END) AS no_qc_data, COALESCE(((min(anmn_nrs_realtime_all_deployments_view.sensor_depth) || '-'::text) || max(anmn_nrs_realtime_all_deployments_view.sensor_depth))) AS depth_range, min(anmn_nrs_realtime_all_deployments_view.start_date) AS earliest_date, max(anmn_nrs_realtime_all_deployments_view.end_date) AS latest_date, round(avg(anmn_nrs_realtime_all_deployments_view.coverage_duration), 1) AS mean_coverage_duration, round(avg(anmn_nrs_realtime_all_deployments_view.days_to_process_and_upload), 1) AS mean_days_to_process_and_upload, round(avg(anmn_nrs_realtime_all_deployments_view.days_to_make_public), 1) AS mean_days_to_make_public, sum(CASE WHEN (anmn_nrs_realtime_all_deployments_view.missing_info IS NULL) THEN 0 ELSE 1 END) AS no_missing_info, min(anmn_nrs_realtime_all_deployments_view.sensor_depth) AS min_depth, max(anmn_nrs_realtime_all_deployments_view.sensor_depth) AS max_depth FROM anmn_nrs_realtime_all_deployments_view GROUP BY anmn_nrs_realtime_all_deployments_view.platform_code ORDER BY anmn_nrs_realtime_all_deployments_view.platform_code;

grant all on table anmn_nrs_realtime_data_summary_view to public;



-- has data
-- no change 
-- NOTICE:  geometry_gist_joinsel called with incorrect join type

CREATE or replace VIEW argo_all_deployments_view AS
    SELECT argo_float.data_centre AS organisation, CASE WHEN (argo_float.oxygen_sensor = false) THEN 'No oxygen sensor'::text ELSE 'Oxygen sensor'::text END AS oxygen_sensor, argo_float.platform_number AS platform_code, round((argo_float.min_lat)::numeric, 1) AS min_lat, round((argo_float.max_lat)::numeric, 1) AS max_lat, round((argo_float.min_long)::numeric, 1) AS min_lon, round((argo_float.max_long)::numeric, 1) AS max_lon, COALESCE(((round((argo_float.min_lat)::numeric, 1) || '/'::text) || round((argo_float.max_lat)::numeric, 1))) AS lat_range, COALESCE(((round((argo_float.min_long)::numeric, 1) || '/'::text) || round((argo_float.max_long)::numeric, 1))) AS lon_range, date(argo_float.start_date) AS start_date, date(argo_float.last_measure_date) AS end_date, round((((date_part('day'::text, (argo_float.last_measure_date - argo_float.start_date)))::integer)::numeric / 365.242), 1) AS coverage_duration, argo_float.pi_name, CASE WHEN (date_part('day'::text, (argo_float.last_measure_date - argo_float.start_date)) IS NULL) THEN 'Missing dates'::text WHEN (argo_float.uuid IS NULL) THEN 'No metadata'::text WHEN (argo_float.data_centre IS NULL) THEN 'No organisation'::text WHEN (argo_float.pi_name IS NULL) THEN 'No principal investigator'::text ELSE NULL::text END AS missing_info FROM argo.argo_float ORDER BY argo_float.data_centre, CASE WHEN (argo_float.oxygen_sensor = false) THEN 'No oxygen sensor'::text ELSE 'Oxygen sensor'::text END, argo_float.platform_number;

grant all on table argo_all_deployments_view to public;



-- has data
-- no change 

CREATE or replace VIEW argo_data_summary_view AS
    SELECT argo_all_deployments_view.organisation, count(DISTINCT argo_all_deployments_view.platform_code) AS no_platforms, count(CASE WHEN (date_part('day'::text, (now() - (argo_all_deployments_view.end_date)::timestamp with time zone)) < (31)::double precision) THEN 1 ELSE NULL::integer END) AS no_active_floats, count(CASE WHEN (argo_all_deployments_view.oxygen_sensor = 'Oxygen sensor'::text) THEN 1 ELSE NULL::integer END) AS no_oxygen_platforms, count(CASE WHEN ((date_part('day'::text, (now() - (argo_all_deployments_view.end_date)::timestamp with time zone)) < (31)::double precision) AND (argo_all_deployments_view.oxygen_sensor = 'Oxygen sensor'::text)) THEN 1 ELSE NULL::integer END) AS no_active_oxygen_platforms, count(CASE WHEN (argo_all_deployments_view.missing_info IS NOT NULL) THEN 1 ELSE NULL::integer END) AS no_deployments_with_missing_info, min(argo_all_deployments_view.min_lat) AS min_lat, max(argo_all_deployments_view.max_lat) AS max_lat, min(argo_all_deployments_view.min_lon) AS min_lon, max(argo_all_deployments_view.max_lon) AS max_lon, COALESCE(((min(argo_all_deployments_view.min_lat) || '/'::text) || max(argo_all_deployments_view.max_lat))) AS lat_range, COALESCE(((min(argo_all_deployments_view.min_lon) || '/'::text) || max(argo_all_deployments_view.max_lon))) AS lon_range, min(argo_all_deployments_view.start_date) AS earliest_date, max(argo_all_deployments_view.end_date) AS latest_date, round(avg(argo_all_deployments_view.coverage_duration), 1) AS mean_coverage_duration FROM argo_all_deployments_view GROUP BY argo_all_deployments_view.organisation ORDER BY argo_all_deployments_view.organisation;

grant all on table argo_data_summary_view to public;


-- has data
-- auv. -> legacy_auv 
-- auv_manual -> report.auv_manual

CREATE or replace VIEW auv_all_deployments_view AS
    SELECT "substring"((auv_manual.campaign_code)::text, '[^0-9]+'::text) AS location, auv_manual.campaign_code AS campaign, auv.site, auv_tracks.number_of_images AS no_images, round(((auv_tracks.distance)::numeric / (1000)::numeric), 1) AS distance, round((auv_tracks.geospatial_lat_min)::numeric, 1) AS lat_min, round((auv_tracks.geospatial_lon_min)::numeric, 1) AS lon_min, COALESCE(((round((auv_tracks.geospatial_vertical_min)::numeric, 1) || '/'::text) || round((auv_tracks.geospatial_vertical_max)::numeric, 1))) AS depth_range, date(auv_tracks.time_coverage_start) AS start_date, ((date_part('hours'::text, (auv_tracks.time_coverage_end - auv_tracks.time_coverage_start)) * (60)::double precision) + ((date_part('minutes'::text, (auv_tracks.time_coverage_end - auv_tracks.time_coverage_start)))::integer)::double precision) AS coverage_duration, (date_part('day'::text, (auv_manual.data_on_staging - auv_tracks.time_coverage_end)))::integer AS days_to_process_and_upload, (date_part('day'::text, (auv_manual.data_on_portal - auv_manual.data_on_staging)))::integer AS days_to_make_public, CASE WHEN (((((((((((((((((auv.site IS NULL) OR (auv_manual.campaign_code IS NULL)) OR (date_part('hours'::text, (auv_tracks.time_coverage_end - auv_tracks.time_coverage_start)) IS NULL)) OR (auv.metadata_campaign IS NULL)) OR ((auv_report.portal_visibility)::text <> 'Yes'::text)) OR ((auv_report.viewer_visibility)::text <> 'Yes'::text)) OR ((auv_report.geotiff)::text <> 'ALL_IMAGES'::text)) OR ((auv_report.mesh)::text <> 'Yes'::text)) OR ((auv_report.multibeam)::text <> 'Yes'::text)) OR ((auv_report.nc_cdom)::text <> 'Yes'::text)) OR ((auv_report.nc_cphl)::text <> 'Yes'::text)) OR ((auv_report.nc_opbs)::text <> 'Yes'::text)) OR ((auv_report.nc_psal)::text <> 'Yes'::text)) OR ((auv_report.nc_temp)::text <> 'Yes'::text)) OR ("substring"((auv_report.dive_track_csv_kml)::text, 'Yes'::text) <> 'Yes'::text)) OR ((auv_report.dive_report)::text <> 'Yes'::text)) OR ((auv_report.data_archived)::text <> 'Yes'::text)) THEN 'Missing information'::text ELSE NULL::text END AS missing_info, auv.metadata_campaign, auv.site_code, round((auv_tracks.geospatial_lat_max)::numeric, 1) AS lat_max, round((auv_tracks.geospatial_lon_max)::numeric, 1) AS lon_max, round((auv_tracks.geospatial_vertical_min)::numeric, 1) AS min_depth, round((auv_tracks.geospatial_vertical_max)::numeric, 1) AS max_depth, date(auv_tracks.time_coverage_end) AS end_date, date(auv_manual.data_on_staging) AS date_on_staging, date(auv_manual.data_on_opendap) AS date_on_opendap, date(auv_manual.data_on_portal) AS date_on_portal, auv_report.portal_visibility, auv_report.viewer_visibility, auv_report.geotiff, auv_report.mesh, auv_report.nc_cdom, auv_report.nc_cphl, auv_report.nc_opbs, auv_report.nc_psal, auv_report.nc_temp, auv_report.dive_track_csv_kml, auv_report.dive_report, auv_report.data_archived FROM (((legacy_auv.auv LEFT JOIN legacy_auv.auv_tracks ON (((auv_tracks.site_code)::text = (auv.site_code)::text))) LEFT JOIN report.auv_manual ON (((auv_manual.campaign_code)::text = (auv.campaign)::text))) LEFT JOIN legacy_auv.auv_report ON ((((auv.site_code)::text = (auv_report.site_code)::text) AND ((auv.campaign)::text = (auv_report.campaign_code)::text)))) WHERE (((auv_manual.campaign_code IS NOT NULL) OR (auv.site IS NOT NULL)) OR (auv_report.site_code IS NOT NULL)) ORDER BY "substring"((auv_manual.campaign_code)::text, '[^0-9]+'::text), auv_manual.campaign_code, auv.site;

grant all on table auv_all_deployments_view to public;


-- has data

CREATE or replace VIEW auv_data_summary_view AS
    SELECT auv_all_deployments_view.location, count(DISTINCT CASE WHEN (auv_all_deployments_view.campaign IS NULL) THEN '1'::character varying ELSE auv_all_deployments_view.campaign END) AS no_campaigns, count(DISTINCT CASE WHEN (auv_all_deployments_view.site IS NULL) THEN '1'::character varying ELSE auv_all_deployments_view.site END) AS no_sites, count(CASE WHEN (auv_all_deployments_view.site IS NULL) THEN '1'::character varying ELSE auv_all_deployments_view.site END) AS no_deployments, sum(auv_all_deployments_view.no_images) AS total_no_images, sum(auv_all_deployments_view.distance) AS total_distance, COALESCE(((min(auv_all_deployments_view.lat_min) || '/'::text) || max(auv_all_deployments_view.lat_max))) AS lat_range, COALESCE(((min(auv_all_deployments_view.lon_min) || '/'::text) || max(auv_all_deployments_view.lon_max))) AS lon_range, COALESCE(((min(auv_all_deployments_view.min_depth) || '/'::text) || max(auv_all_deployments_view.max_depth))) AS depth_range, min(auv_all_deployments_view.start_date) AS earliest_date, max(auv_all_deployments_view.end_date) AS latest_date, round((sum((auv_all_deployments_view.coverage_duration)::numeric) / (60)::numeric), 1) AS data_duration, round(avg(auv_all_deployments_view.days_to_process_and_upload), 1) AS mean_days_to_process_and_upload, round(avg(auv_all_deployments_view.days_to_make_public), 1) AS mean_days_to_make_public, sum(CASE WHEN (auv_all_deployments_view.missing_info IS NOT NULL) THEN 1 ELSE 0 END) AS missing_info, min(auv_all_deployments_view.lat_min) AS lat_min, min(auv_all_deployments_view.lon_min) AS lon_min, max(auv_all_deployments_view.lat_max) AS lat_max, max(auv_all_deployments_view.lon_max) AS lon_max, min(auv_all_deployments_view.min_depth) AS min_depth, max(auv_all_deployments_view.max_depth) AS max_depth FROM auv_all_deployments_view GROUP BY auv_all_deployments_view.location ORDER BY auv_all_deployments_view.location;

grant all on table auv_data_summary_view to public;


-- has data
-- facility_summary -> report.facility_summary
-- public.facility -> report.facility
-- facility_summary_item -> report.facility_summary_item 

CREATE or replace VIEW facility_summary_view AS
    SELECT facility.acronym AS facility_acronym, COALESCE(((to_char(to_timestamp((date_part('month'::text, facility_summary.reporting_date))::text, 'MM'::text), 'TMMon'::text) || ' '::text) || date_part('year'::text, facility_summary.reporting_date))) AS reporting_month, facility_summary.summary AS updates, facility_summary_item.name AS issues, facility_summary.reporting_date FROM ((report.facility_summary FULL JOIN report.facility ON ((facility_summary.facility_name_id = facility.id))) LEFT JOIN report.facility_summary_item ON ((facility_summary.summary_item_id = facility_summary_item.row_id))) ORDER BY facility.acronym, facility_summary.reporting_date DESC, facility_summary_item.name;

grant all on table facility_summary_view to public;


-- has data
-- faimms -> legacy_faimms
-- faimms_manual -> report.faimms_manual

CREATE or replace VIEW faimms_all_deployments_view AS
    SELECT DISTINCT s.site_code AS site_name, p.platform_code, COALESCE(((param.channelid || ' - '::text) || (param.parameter)::text)) AS sensor_code, (param.depth_sensor)::numeric AS sensor_depth, CASE WHEN (param.qaqc_boolean = 1) THEN true ELSE false END AS qaqc_data, CASE WHEN (date_part('day'::text, (param.time_coverage_end - param.time_coverage_start)) IS NULL) THEN 'Missing dates'::text WHEN (param.metadata_uuid IS NULL) THEN 'No metadata'::text ELSE NULL::text END AS missing_info, date(param.time_coverage_start) AS start_date, date(param.time_coverage_end) AS end_date, (date_part('day'::text, (param.time_coverage_end - param.time_coverage_start)))::numeric AS coverage_duration, (date_part('day'::text, (m.data_on_staging - m.deployment_start)))::numeric AS days_to_process_and_upload, (date_part('day'::text, (m.data_on_portal - m.data_on_staging)))::numeric AS days_to_make_public, param.sensor_name, param.parameter, param.channelid AS channel_id, param.no_qaqc_boolean AS no_qaqc_data, date(m.deployment_start) AS deployment_start, date(m.data_on_staging) AS date_on_staging, date(m.data_on_opendap) AS date_on_opendap, date(m.data_on_portal) AS date_on_portal, m.mest_creation, param.metadata_uuid AS channel_uuid FROM legacy_faimms.faimms_sites s, legacy_faimms.faimms_platforms p, legacy_faimms.faimms_parameters param, report.faimms_manual m WHERE ((((m.site_name)::text = (s.site_code)::text) AND (s.pkid = p.fk_faimms_sites)) AND (p.pkid = param.fk_faimms_platforms)) ORDER BY s.site_code, p.platform_code, COALESCE(((param.channelid || ' - '::text) || (param.parameter)::text));


grant all on table faimms_all_deployments_view to public;


-- has data
-- no changes

CREATE or replace VIEW faimms_data_summary_view AS
    SELECT faimms_all_deployments_view.site_name, count(DISTINCT faimms_all_deployments_view.platform_code) AS no_platforms, count(DISTINCT faimms_all_deployments_view.sensor_code) AS no_sensors, count(DISTINCT faimms_all_deployments_view.parameter) AS no_parameters, sum(CASE WHEN (faimms_all_deployments_view.qaqc_data = true) THEN 1 ELSE 0 END) AS no_qc_data, COALESCE(((min(faimms_all_deployments_view.sensor_depth) || '-'::text) || max(faimms_all_deployments_view.sensor_depth))) AS depth_range, min(faimms_all_deployments_view.start_date) AS earliest_date, max(faimms_all_deployments_view.end_date) AS latest_date, round(avg(faimms_all_deployments_view.coverage_duration), 1) AS mean_coverage_duration, round(avg(faimms_all_deployments_view.days_to_process_and_upload), 1) AS mean_days_to_process_and_upload, round(avg(faimms_all_deployments_view.days_to_make_public), 1) AS mean_days_to_make_public, sum(CASE WHEN (faimms_all_deployments_view.missing_info IS NULL) THEN 0 ELSE 1 END) AS no_missing_info, min(faimms_all_deployments_view.sensor_depth) AS min_depth, max(faimms_all_deployments_view.sensor_depth) AS max_depth FROM faimms_all_deployments_view GROUP BY faimms_all_deployments_view.site_name ORDER BY faimms_all_deployments_view.site_name;

grant all on table faimms_data_summary_view to public;


-- has data
-- cpr -> legacy_cpr
-- soop_cpr_manual -> report.soop_cpr_manual

CREATE or replace VIEW soop_cpr_all_deployments_view AS
    WITH interm_table_phyto AS (SELECT DISTINCT csiro_harvest_phyto.date_time_utc, count(DISTINCT csiro_harvest_phyto.date_time_utc) AS no_phyto_samples FROM legacy_cpr.csiro_harvest_phyto GROUP BY csiro_harvest_phyto.date_time_utc ORDER BY csiro_harvest_phyto.date_time_utc), interm_table_zoop AS (SELECT DISTINCT csiro_harvest_zoop.date_time_utc, count(DISTINCT csiro_harvest_zoop.date_time_utc) AS no_zoop_samples FROM legacy_cpr.csiro_harvest_zoop GROUP BY csiro_harvest_zoop.date_time_utc ORDER BY csiro_harvest_zoop.date_time_utc), interm_table_pci AS (SELECT DISTINCT csiro_harvest_pci.vessel_name, CASE WHEN ((csiro_harvest_pci.start_port)::text < (csiro_harvest_pci.end_port)::text) THEN (((csiro_harvest_pci.start_port)::text || '-'::text) || (csiro_harvest_pci.end_port)::text) ELSE (((csiro_harvest_pci.end_port)::text || '-'::text) || (csiro_harvest_pci.start_port)::text) END AS route, csiro_harvest_pci.date_time_utc, count(DISTINCT csiro_harvest_pci.date_time_utc) AS no_pci_samples FROM legacy_cpr.csiro_harvest_pci GROUP BY csiro_harvest_pci.vessel_name, CASE WHEN ((csiro_harvest_pci.start_port)::text < (csiro_harvest_pci.end_port)::text) THEN (((csiro_harvest_pci.start_port)::text || '-'::text) || (csiro_harvest_pci.end_port)::text) ELSE (((csiro_harvest_pci.end_port)::text || '-'::text) || (csiro_harvest_pci.start_port)::text) END, csiro_harvest_pci.date_time_utc ORDER BY csiro_harvest_pci.vessel_name, CASE WHEN ((csiro_harvest_pci.start_port)::text < (csiro_harvest_pci.end_port)::text) THEN (((csiro_harvest_pci.start_port)::text || '-'::text) || (csiro_harvest_pci.end_port)::text) ELSE (((csiro_harvest_pci.end_port)::text || '-'::text) || (csiro_harvest_pci.start_port)::text) END, csiro_harvest_pci.date_time_utc) SELECT 'CPR-AUS (delayed-mode)'::text AS subfacility, interm_table_pci.vessel_name, interm_table_pci.route, csiro_harvest_pci.trip_code AS deployment_id, sum(interm_table_pci.no_pci_samples) AS no_pci_samples, CASE WHEN (sum(interm_table_phyto.no_phyto_samples) IS NULL) THEN (0)::numeric ELSE sum(interm_table_phyto.no_phyto_samples) END AS no_phyto_samples, CASE WHEN (sum(interm_table_zoop.no_zoop_samples) IS NULL) THEN (0)::numeric ELSE sum(interm_table_zoop.no_zoop_samples) END AS no_zoop_samples, COALESCE(((round(min(csiro_harvest_pci.latitude), 1) || '/'::text) || round(max(csiro_harvest_pci.latitude), 1))) AS lat_range, COALESCE(((round(min(csiro_harvest_pci.longitude), 1) || '/'::text) || round(max(csiro_harvest_pci.longitude), 1))) AS lon_range, NULL::text AS depth_range, date(min(csiro_harvest_pci.date_time_utc)) AS start_date, date(max(csiro_harvest_pci.date_time_utc)) AS end_date, round(((date_part('day'::text, (max(csiro_harvest_pci.date_time_utc) - min(csiro_harvest_pci.date_time_utc))))::numeric + ((date_part('hours'::text, (max(csiro_harvest_pci.date_time_utc) - min(csiro_harvest_pci.date_time_utc))))::numeric / (24)::numeric)), 1) AS coverage_duration, (date_part('day'::text, (min(soop_cpr_manual.data_on_staging) - (date(min(csiro_harvest_pci.date_time_utc)))::timestamp without time zone)))::numeric AS days_to_process_and_upload, round(avg((date_part('day'::text, (soop_cpr_manual.data_on_portal - soop_cpr_manual.data_on_staging)))::numeric), 1) AS days_to_make_public, CASE WHEN ((date_part('day'::text, (min(soop_cpr_manual.data_on_staging) - (date(min(csiro_harvest_pci.date_time_utc)))::timestamp without time zone)))::numeric IS NULL) THEN 'Missing dates'::text WHEN (sum(CASE WHEN (soop_cpr_manual.mest_uuid IS NULL) THEN 0 ELSE 1 END) <> sum(CASE WHEN (soop_cpr_manual.cruise_id IS NOT NULL) THEN 1 ELSE 0 END)) THEN 'No metadata'::text ELSE NULL::text END AS missing_info, ''::text AS principal_investigator, round(min(csiro_harvest_pci.latitude), 1) AS min_lat, round(max(csiro_harvest_pci.latitude), 1) AS max_lat, round(min(csiro_harvest_pci.longitude), 1) AS min_lon, round(max(csiro_harvest_pci.longitude), 1) AS max_lon, NULL::text AS min_depth, NULL::text AS max_depth, date(soop_cpr_manual.data_on_portal) AS data_on_portal FROM ((((interm_table_pci FULL JOIN interm_table_phyto ON ((interm_table_pci.date_time_utc = interm_table_phyto.date_time_utc))) FULL JOIN interm_table_zoop ON ((interm_table_pci.date_time_utc = interm_table_zoop.date_time_utc))) FULL JOIN legacy_cpr.csiro_harvest_pci ON ((interm_table_pci.date_time_utc = csiro_harvest_pci.date_time_utc))) FULL JOIN report.soop_cpr_manual ON (((csiro_harvest_pci.trip_code)::text = (soop_cpr_manual.cruise_id)::text))) WHERE (interm_table_pci.vessel_name IS NOT NULL) GROUP BY 'CPR-AUS (delayed-mode)'::text, interm_table_pci.vessel_name, interm_table_pci.route, csiro_harvest_pci.trip_code, soop_cpr_manual.data_on_portal UNION ALL SELECT 'CPR-SO (delayed-mode)'::text AS subfacility, so_segment.ship_code AS vessel_name, NULL::text AS route, COALESCE((((so_segment.ship_code)::text || '-'::text) || so_segment.tow_number)) AS deployment_id, sum(CASE WHEN (so_segment.pci IS NULL) THEN 0 ELSE 1 END) AS no_pci_samples, NULL::numeric AS no_phyto_samples, count(so_segment.total_abundance) AS no_zoop_samples, NULL::text AS lat_range, NULL::text AS lon_range, NULL::text AS depth_range, date(min(so_segment.date_time)) AS start_date, date(max(so_segment.date_time)) AS end_date, round(((date_part('day'::text, (max(so_segment.date_time) - min(so_segment.date_time))))::numeric + ((date_part('hours'::text, (max(so_segment.date_time) - min(so_segment.date_time))))::numeric / (24)::numeric)), 1) AS coverage_duration, NULL::numeric AS days_to_process_and_upload, NULL::numeric AS days_to_make_public, 'Missing dates'::text AS missing_info, ''::text AS principal_investigator, NULL::numeric AS min_lat, NULL::numeric AS max_lat, NULL::numeric AS min_lon, NULL::numeric AS max_lon, NULL::text AS min_depth, NULL::text AS max_depth, NULL::date AS data_on_portal FROM legacy_cpr.so_segment GROUP BY 'CPR-SO (delayed-mode)'::text, so_segment.ship_code, so_segment.tow_number ORDER BY 1, 2, 3, 11;

grant all on table soop_cpr_all_deployments_view to public;



-- Have no idea soop_co2_mv don't know if it should come from legacy_soop or dw_soop 


-- soop -> dw_soop
-- soop_xbt -> report.soop_xbt  (Seb perhaps manages this himself )

CREATE or replace VIEW soop_all_deployments_view AS
  WITH interm_table AS (SELECT soop_tmv_mv.time_coverage_start, CASE WHEN ((date(soop_tmv_mv.time_coverage_start) >= '2008-08-01'::date) AND (date(soop_tmv_mv.time_coverage_start) < '2009-01-15'::date)) THEN 'Aug08-Jan09'::text WHEN ((date(soop_tmv_mv.time_coverage_start) >= '2011-08-11'::date) AND (date(soop_tmv_mv.time_coverage_start) < '2011-12-19'::date)) THEN 'Aug11-Dec11'::text WHEN ((date(soop_tmv_mv.time_coverage_start) >= '2011-12-19'::date) AND (date(soop_tmv_mv.time_coverage_start) < '2012-02-01'::date)) THEN 'Dec11-Feb12'::text WHEN ((date(soop_tmv_mv.time_coverage_start) >= '2009-01-16'::date) AND (date(soop_tmv_mv.time_coverage_start) < '2009-07-31'::date)) THEN 'Jan09-Jul09'::text WHEN ((date(soop_tmv_mv.time_coverage_start) >= '2011-01-11'::date) AND (date(soop_tmv_mv.time_coverage_start) < '2011-07-11'::date)) THEN 'Jan11-Jun11'::text WHEN ((date(soop_tmv_mv.time_coverage_start) >= '2010-07-01'::date) AND (date(soop_tmv_mv.time_coverage_start) < '2011-01-11'::date)) THEN 'Jul10-Jan11'::text WHEN ((date(soop_tmv_mv.time_coverage_start) >= '2009-09-01'::date) AND (date(soop_tmv_mv.time_coverage_start) < '2010-06-30'::date)) THEN 'Sep09-Jun10'::text ELSE NULL::text END AS bundle_id FROM dw_soop.soop_tmv_mv), interm_table_xbt AS (SELECT soop_xbt.line_name, soop_xbt.year, soop_xbt.bundle_id, sum(soop_xbt.number_of_profile) AS no_profiles FROM report.soop_xbt GROUP BY soop_xbt.line_name, soop_xbt.bundle_id, soop_xbt.year ORDER BY soop_xbt.line_name, soop_xbt.bundle_id) (((((SELECT 'ASF (near real-time & delayed-mode)'::text AS subfacility, soop_asf_manual.vessel_name, NULL::character varying AS deployment_id, NULL::text AS year, count(soop_asf_mv.callsign) AS no_data_files, NULL::bigint AS no_profiles, COALESCE(((round((min(soop_asf_mv.geospatial_lat_min))::numeric, 1) || '/'::text) || round((max(soop_asf_mv.geospatial_lat_max))::numeric, 1))) AS lat_range, COALESCE(((round((min(soop_asf_mv.geospatial_lon_min))::numeric, 1) || '/'::text) || round((max(soop_asf_mv.geospatial_lon_max))::numeric, 1))) AS lon_range, COALESCE(((round((min(soop_asf_mv.geospatial_vertical_min))::numeric, 1) || '/'::text) || round((max(soop_asf_mv.geospatial_vertical_max))::numeric, 1))) AS depth_range, date(min(soop_asf_mv.time_coverage_start)) AS start_date, date(max(soop_asf_mv.time_coverage_end)) AS end_date, (date_part('day'::text, (max(soop_asf_mv.time_coverage_end) - min(soop_asf_mv.time_coverage_start))))::numeric AS coverage_duration, (date_part('day'::text, (min(soop_asf_manual.data_on_staging) - (date(min(soop_asf_mv.time_coverage_start)))::timestamp without time zone)))::numeric AS days_to_process_and_upload, (date_part('day'::text, (soop_asf_manual.data_on_portal - soop_asf_manual.data_on_staging)))::numeric AS days_to_make_public, CASE WHEN (((date_part('day'::text, (min(soop_asf_manual.data_on_staging) - (date(min(soop_asf_mv.time_coverage_start)))::timestamp without time zone)))::numeric IS NULL) OR ((date_part('day'::text, (soop_asf_manual.data_on_portal - soop_asf_manual.data_on_staging)))::numeric IS NULL)) THEN 'Missing dates'::text WHEN (sum(CASE WHEN (soop_asf_mv.dataset_uuid IS NULL) THEN 0 ELSE 1 END) <> count(soop_asf_mv.callsign)) THEN 'No metadata'::text ELSE NULL::text END AS missing_info, round((min(soop_asf_mv.geospatial_lat_min))::numeric, 1) AS min_lat, round((max(soop_asf_mv.geospatial_lat_max))::numeric, 1) AS max_lat, round((min(soop_asf_mv.geospatial_lon_min))::numeric, 1) AS min_lon, round((max(soop_asf_mv.geospatial_lon_max))::numeric, 1) AS max_lon, round((min(soop_asf_mv.geospatial_vertical_min))::numeric, 1) AS min_depth, round((max(soop_asf_mv.geospatial_vertical_max))::numeric, 1) AS max_depth, date(soop_asf_manual.data_on_portal) AS data_on_portal FROM (dw_soop.soop_asf_mv LEFT JOIN report.soop_asf_manual ON ((soop_asf_mv.callsign = (soop_asf_manual.platform_code)::text))) GROUP BY 'ASF (near real-time & delayed-mode)'::text, soop_asf_manual.vessel_name, soop_asf_manual.data_on_portal, soop_asf_manual.data_on_staging UNION ALL SELECT 'BA (delayed-mode)'::text AS subfacility, soop_ba_manual.vessel_name, soop_ba_manual.deployment_id, NULL::text AS year, count(soop_ba_manual.deployment_id) AS no_data_files, NULL::bigint AS no_profiles, COALESCE(((round((min(soop_ba_mv.geospatial_lat_min))::numeric, 1) || '/'::text) || round((max(soop_ba_mv.geospatial_lat_max))::numeric, 1))) AS lat_range, COALESCE(((round((min(soop_ba_mv.geospatial_lon_min))::numeric, 1) || '/'::text) || round((max(soop_ba_mv.geospatial_lon_max))::numeric, 1))) AS lon_range, COALESCE(((round((min(soop_ba_mv.geospatial_vertical_min))::numeric, 1) || '/'::text) || round((max(soop_ba_mv.geospatial_vertical_max))::numeric, 1))) AS depth_range, date(min(soop_ba_mv.time_coverage_start)) AS start_date, date(max(soop_ba_mv.time_coverage_end)) AS end_date, (date_part('day'::text, (max(soop_ba_mv.time_coverage_end) - min(soop_ba_mv.time_coverage_start))))::numeric AS coverage_duration, round(avg((date_part('day'::text, (soop_ba_manual.data_on_staging - (date(soop_ba_mv.time_coverage_start))::timestamp without time zone)))::numeric), 1) AS days_to_process_and_upload, round(avg((date_part('day'::text, (soop_ba_manual.data_on_portal - soop_ba_manual.data_on_staging)))::numeric), 1) AS days_to_make_public, CASE WHEN (((date_part('day'::text, (min(soop_ba_manual.data_on_staging) - (date(min(soop_ba_mv.time_coverage_start)))::timestamp without time zone)))::numeric IS NULL) OR (round(avg((date_part('day'::text, (soop_ba_manual.data_on_portal - soop_ba_manual.data_on_staging)))::numeric), 1) IS NULL)) THEN 'Missing dates'::text WHEN (sum(CASE WHEN (soop_ba_mv.dataset_uuid IS NULL) THEN 0 ELSE 1 END) <> count(soop_ba_mv.cruise_id)) THEN 'No metadata'::text WHEN (sum(CASE WHEN (soop_ba_manual.mest_creation IS NULL) THEN 0 ELSE 1 END) <> count(soop_ba_mv.vessel_name)) THEN 'No metadata'::text ELSE NULL::text END AS missing_info, round((min(soop_ba_mv.geospatial_lat_min))::numeric, 1) AS min_lat, round((max(soop_ba_mv.geospatial_lat_max))::numeric, 1) AS max_lat, round((min(soop_ba_mv.geospatial_lon_min))::numeric, 1) AS min_lon, round((max(soop_ba_mv.geospatial_lon_max))::numeric, 1) AS max_lon, round((min(soop_ba_mv.geospatial_vertical_min))::numeric, 1) AS min_depth, round((max(soop_ba_mv.geospatial_vertical_max))::numeric, 1) AS max_depth, date(soop_ba_manual.data_on_portal) AS data_on_portal FROM (dw_soop.soop_ba_mv FULL JOIN report.soop_ba_manual ON ((soop_ba_mv.cruise_id = (soop_ba_manual.deployment_id)::text))) GROUP BY 'BA (delayed-mode)'::text, soop_ba_manual.vessel_name, soop_ba_manual.deployment_id, soop_ba_manual.data_on_portal) UNION ALL SELECT 'CO2 (delayed-mode)'::text AS subfacility, soop_co2_mv.vessel_name, soop_co2_mv.cruise_id AS deployment_id, NULL::text AS year, NULL::bigint AS no_data_files, NULL::bigint AS no_profiles, COALESCE(((round((soop_co2_mv.geospatial_lat_min)::numeric, 1) || '/'::text) || round((soop_co2_mv.geospatial_lat_max)::numeric, 1))) AS lat_range, COALESCE(((round((soop_co2_mv.geospatial_lon_min)::numeric, 1) || '/'::text) || round((soop_co2_mv.geospatial_lon_max)::numeric, 1))) AS lon_range, COALESCE(((round((soop_co2_mv.geospatial_vertical_min)::numeric, 1) || '/'::text) || round((soop_co2_mv.geospatial_vertical_max)::numeric, 1))) AS depth_range, date(soop_co2_mv.time_coverage_start) AS start_date, date(soop_co2_mv.time_coverage_end) AS end_date, (date_part('day'::text, (soop_co2_mv.time_coverage_end - soop_co2_mv.time_coverage_start)))::numeric AS coverage_duration, (date_part('day'::text, (soop_co2_manual.data_on_staging - (date(soop_co2_mv.time_coverage_start))::timestamp without time zone)))::numeric AS days_to_process_and_upload, (date_part('day'::text, (soop_co2_manual.data_on_portal - soop_co2_manual.data_on_staging)))::numeric AS days_to_make_public, CASE WHEN (((date_part('day'::text, (soop_co2_manual.data_on_staging - (date(soop_co2_mv.time_coverage_start))::timestamp without time zone)))::numeric IS NULL) OR ((date_part('day'::text, (soop_co2_manual.data_on_portal - soop_co2_manual.data_on_staging)))::numeric IS NULL)) THEN 'Missing dates'::text WHEN (soop_co2_manual.mest_creation IS NULL) THEN 'No metadata'::text WHEN (soop_co2_mv.dataset_uuid IS NULL) THEN 'No metadata'::text ELSE NULL::text END AS missing_info, round((soop_co2_mv.geospatial_lat_min)::numeric, 1) AS min_lat, round((soop_co2_mv.geospatial_lat_max)::numeric, 1) AS max_lat, round((soop_co2_mv.geospatial_lon_min)::numeric, 1) AS min_lon, round((soop_co2_mv.geospatial_lon_max)::numeric, 1) AS max_lon, round((soop_co2_mv.geospatial_vertical_min)::numeric, 1) AS min_depth, round((soop_co2_mv.geospatial_vertical_max)::numeric, 1) AS max_depth, date(soop_co2_manual.data_on_portal) AS data_on_portal FROM (dw_soop.soop_co2_mv FULL JOIN report.soop_co2_manual ON ((soop_co2_mv.cruise_id = (soop_co2_manual.deployment_id)::text)))) UNION ALL SELECT 'SST (near real-time & delayed-mode)'::text AS subfacility, soop_sst_manual.vessel_name, NULL::character varying AS deployment_id, NULL::text AS year, count(DISTINCT soop_sst_mv.id) AS no_data_files, NULL::bigint AS no_profiles, COALESCE(((round((min(soop_sst_mv.geospatial_lat_min))::numeric, 1) || '/'::text) || round((max(soop_sst_mv.geospatial_lat_max))::numeric, 1))) AS lat_range, COALESCE(((round((min(soop_sst_mv.geospatial_lon_min))::numeric, 1) || '/'::text) || round((max(soop_sst_mv.geospatial_lon_max))::numeric, 1))) AS lon_range, COALESCE(((round((min(soop_sst_mv.geospatial_vertical_min))::numeric, 1) || '/'::text) || round((max(soop_sst_mv.geospatial_vertical_max))::numeric, 1))) AS depth_range, date(min(soop_sst_mv.time_coverage_start)) AS start_date, date(max(soop_sst_mv.time_coverage_end)) AS end_date, (date_part('day'::text, (max(soop_sst_mv.time_coverage_end) - min(soop_sst_mv.time_coverage_start))))::numeric AS coverage_duration, (date_part('day'::text, (min(soop_sst_manual.data_on_staging) - (date(min(soop_sst_mv.time_coverage_start)))::timestamp without time zone)))::numeric AS days_to_process_and_upload, round(avg((date_part('day'::text, (soop_sst_manual.data_on_portal - soop_sst_manual.data_on_staging)))::numeric), 1) AS days_to_make_public, CASE WHEN (((date_part('day'::text, (min(soop_sst_manual.data_on_staging) - (date(min(soop_sst_mv.time_coverage_start)))::timestamp without time zone)))::numeric IS NULL) OR (round(avg((date_part('day'::text, (soop_sst_manual.data_on_portal - soop_sst_manual.data_on_staging)))::numeric), 1) IS NULL)) THEN 'Missing dates'::text WHEN (soop_sst_manual.mest_creation IS NULL) THEN 'No metadata'::text WHEN (sum(CASE WHEN (soop_sst_mv.dataset_uuid IS NULL) THEN 0 ELSE 1 END) <> count(soop_sst_mv.id)) THEN 'No metadata'::text ELSE NULL::text END AS missing_info, round((min(soop_sst_mv.geospatial_lat_min))::numeric, 1) AS min_lat, round((max(soop_sst_mv.geospatial_lat_max))::numeric, 1) AS max_lat, round((min(soop_sst_mv.geospatial_lon_min))::numeric, 1) AS min_lon, round((max(soop_sst_mv.geospatial_lon_max))::numeric, 1) AS max_lon, round((min(soop_sst_mv.geospatial_vertical_min))::numeric, 1) AS min_depth, round((max(soop_sst_mv.geospatial_vertical_max))::numeric, 1) AS max_depth, date(soop_sst_manual.data_on_portal) AS data_on_portal FROM (report.soop_sst_manual FULL JOIN dw_soop.soop_sst_mv ON ((soop_sst_mv.vessel_name = (soop_sst_manual.vessel_name)::text))) GROUP BY 'SST (near real-time & delayed-mode)'::text, soop_sst_manual.vessel_name, soop_sst_manual.mest_creation, soop_sst_manual.data_on_portal) UNION ALL SELECT 'TMV (delayed-mode)'::text AS subfacility, soop_tmv_manual.vessel_name, soop_tmv_manual.bundle_id AS deployment_id, NULL::text AS year, count(interm_table.bundle_id) AS no_data_files, NULL::bigint AS no_profiles, COALESCE(((round((min(soop_tmv_mv.geospatial_lat_min))::numeric, 1) || '/'::text) || round((max(soop_tmv_mv.geospatial_lat_max))::numeric, 1))) AS lat_range, COALESCE(((round((min(soop_tmv_mv.geospatial_lon_min))::numeric, 1) || '/'::text) || round((max(soop_tmv_mv.geospatial_lon_max))::numeric, 1))) AS lon_range, COALESCE(((round((min(soop_tmv_mv.geospatial_vertical_min))::numeric, 1) || '/'::text) || round((max(soop_tmv_mv.geospatial_vertical_max))::numeric, 1))) AS depth_range, date(min(soop_tmv_mv.time_coverage_start)) AS start_date, date(max(soop_tmv_mv.time_coverage_end)) AS end_date, (date_part('day'::text, (max(soop_tmv_mv.time_coverage_end) - min(soop_tmv_mv.time_coverage_start))))::numeric AS coverage_duration, (date_part('day'::text, (min(soop_tmv_manual.data_on_staging) - (date(min(soop_tmv_mv.time_coverage_start)))::timestamp without time zone)))::numeric AS days_to_process_and_upload, round(avg((date_part('day'::text, (soop_tmv_manual.data_on_portal - soop_tmv_manual.data_on_staging)))::numeric), 1) AS days_to_make_public, CASE WHEN (((date_part('day'::text, (min(soop_tmv_manual.data_on_staging) - (date(min(soop_tmv_mv.time_coverage_start)))::timestamp without time zone)))::numeric IS NULL) OR (round(avg((date_part('day'::text, (soop_tmv_manual.data_on_portal - soop_tmv_manual.data_on_staging)))::numeric), 1) IS NULL)) THEN 'Missing dates'::text WHEN (sum(CASE WHEN (soop_tmv_mv.dataset_uuid IS NULL) THEN 0 ELSE 1 END) <> count(soop_tmv_mv.id)) THEN 'No metadata'::text ELSE NULL::text END AS missing_info, round((min(soop_tmv_mv.geospatial_lat_min))::numeric, 1) AS min_lat, round((max(soop_tmv_mv.geospatial_lat_max))::numeric, 1) AS max_lat, round((min(soop_tmv_mv.geospatial_lon_min))::numeric, 1) AS min_lon, round((max(soop_tmv_mv.geospatial_lon_max))::numeric, 1) AS max_lon, round((min(soop_tmv_mv.geospatial_vertical_min))::numeric, 1) AS min_depth, round((max(soop_tmv_mv.geospatial_vertical_max))::numeric, 1) AS max_depth, date(soop_tmv_manual.data_on_portal) AS data_on_portal FROM ((dw_soop.soop_tmv_mv LEFT JOIN interm_table ON ((interm_table.time_coverage_start = soop_tmv_mv.time_coverage_start))) FULL JOIN report.soop_tmv_manual ON ((interm_table.bundle_id = (soop_tmv_manual.bundle_id)::text))) WHERE (soop_tmv_manual.vessel_name IS NOT NULL) GROUP BY 'TMV (delayed-mode)'::text, soop_tmv_manual.vessel_name, soop_tmv_manual.bundle_id, soop_tmv_manual.data_on_portal) UNION ALL SELECT 'TRV (delayed-mode)'::text AS subfacility, soop_trv_mv.vessel_name, soop_trv_mv.cruise_id AS deployment_id, NULL::text AS year, count(soop_trv_mv.cruise_id) AS no_data_files, NULL::bigint AS no_profiles, COALESCE(((round((min(soop_trv_mv.geospatial_lat_min))::numeric, 1) || '/'::text) || round((max(soop_trv_mv.geospatial_lat_max))::numeric, 1))) AS lat_range, COALESCE(((round((min(soop_trv_mv.geospatial_lon_min))::numeric, 1) || '/'::text) || round((max(soop_trv_mv.geospatial_lon_max))::numeric, 1))) AS lon_range, COALESCE(((round((min(soop_trv_mv.geospatial_vertical_min))::numeric, 1) || '/'::text) || round((max(soop_trv_mv.geospatial_vertical_max))::numeric, 1))) AS depth_range, date(min(soop_trv_mv.time_coverage_start)) AS start_date, date(max(soop_trv_mv.time_coverage_end)) AS end_date, (date_part('day'::text, (max(soop_trv_mv.time_coverage_end) - min(soop_trv_mv.time_coverage_start))))::numeric AS coverage_duration, (date_part('day'::text, (min(soop_trv_manual.data_on_staging) - (date(min(soop_trv_mv.time_coverage_start)))::timestamp without time zone)))::numeric AS days_to_process_and_upload, round(avg((date_part('day'::text, (soop_trv_manual.data_on_portal - soop_trv_manual.data_on_staging)))::numeric), 1) AS days_to_make_public, CASE WHEN (((date_part('day'::text, (min(soop_trv_manual.data_on_staging) - (date(min(soop_trv_mv.time_coverage_start)))::timestamp without time zone)))::numeric IS NULL) OR (round(avg((date_part('day'::text, (soop_trv_manual.data_on_portal - soop_trv_manual.data_on_staging)))::numeric), 1) IS NULL)) THEN 'Missing dates'::text WHEN (sum(CASE WHEN (soop_trv_mv.dataset_uuid IS NULL) THEN 0 ELSE 1 END) <> sum(CASE WHEN (soop_trv_mv.id IS NOT NULL) THEN 1 ELSE 0 END)) THEN 'No metadata'::text ELSE NULL::text END AS missing_info, round((min(soop_trv_mv.geospatial_lat_min))::numeric, 1) AS min_lat, round((max(soop_trv_mv.geospatial_lat_max))::numeric, 1) AS max_lat, round((min(soop_trv_mv.geospatial_lon_min))::numeric, 1) AS min_lon, round((max(soop_trv_mv.geospatial_lon_max))::numeric, 1) AS max_lon, round((min(soop_trv_mv.geospatial_vertical_min))::numeric, 1) AS min_depth, round((max(soop_trv_mv.geospatial_vertical_max))::numeric, 1) AS max_depth, date(soop_trv_manual.data_on_portal) AS data_on_portal FROM (dw_soop.soop_trv_mv FULL JOIN report.soop_trv_manual ON ((soop_trv_mv.cruise_id = (soop_trv_manual.cruise_id)::text))) GROUP BY 'TRV (delayed-mode)'::text, soop_trv_mv.vessel_name, soop_trv_mv.cruise_id, soop_trv_manual.data_on_portal) UNION ALL SELECT DISTINCT 'XBT (near real-time & delayed-mode)'::text AS subfacility, COALESCE(((soop_xbt_mv.xbt_line || ' | '::text) || soop_xbt_mv.xbt_line_description)) AS vessel_name, interm_table_xbt.bundle_id AS deployment_id, interm_table_xbt.year, count(DISTINCT soop_xbt_mv.xbt_cruise_id) AS no_data_files, interm_table_xbt.no_profiles, COALESCE(((round((min(soop_xbt_mv.geospatial_lat_min))::numeric, 1) || '/'::text) || CASE WHEN (round((max(soop_xbt_mv.geospatial_lat_max))::numeric, 1) > (180)::numeric) THEN 23.4 ELSE round((max(soop_xbt_mv.geospatial_lat_max))::numeric, 1) END)) AS lat_range, COALESCE(((round((min(soop_xbt_mv.geospatial_lon_min))::numeric, 1) || '/'::text) || CASE WHEN (round((max(soop_xbt_mv.geospatial_lon_max))::numeric, 1) > (180)::numeric) THEN 135.8 ELSE round((max(soop_xbt_mv.geospatial_lon_max))::numeric, 1) END)) AS lon_range, COALESCE(((round((min(soop_xbt_mv.geospatial_vertical_min))::numeric, 1) || '/'::text) || round((max(soop_xbt_mv.geospatial_vertical_max))::numeric, 1))) AS depth_range, date(min(soop_xbt_mv.launch_date)) AS start_date, date(max(soop_xbt_mv.launch_date)) AS end_date, (date_part('day'::text, (max(soop_xbt_mv.launch_date) - min(soop_xbt_mv.launch_date))))::numeric AS coverage_duration, (date_part('day'::text, (min(soop_xbt_manual.data_on_staging) - (date(min(soop_xbt_mv.launch_date)))::timestamp without time zone)))::numeric AS days_to_process_and_upload, round(avg((date_part('day'::text, (soop_xbt_manual.data_on_portal - soop_xbt_manual.data_on_staging)))::numeric), 1) AS days_to_make_public, CASE WHEN ((((date_part('day'::text, (min(soop_xbt_manual.data_on_staging) - (date(min(soop_xbt_mv.launch_date)))::timestamp without time zone)))::numeric IS NULL) OR (avg((date_part('day'::text, (soop_xbt_manual.data_on_portal - soop_xbt_manual.data_on_staging)))::numeric) IS NULL)) OR (sum(CASE WHEN (soop_xbt_mv.launch_date IS NULL) THEN 0 ELSE 1 END) <> count(soop_xbt_mv.xbt_line))) THEN 'Missing dates'::text WHEN (sum(CASE WHEN (soop_xbt_mv.uuid IS NULL) THEN 0 ELSE 1 END) <> count(soop_xbt_mv.xbt_line)) THEN 'No metadata'::text ELSE NULL::text END AS missing_info, round((min(soop_xbt_mv.geospatial_lat_min))::numeric, 1) AS min_lat, CASE WHEN (round((max(soop_xbt_mv.geospatial_lat_max))::numeric, 1) > (180)::numeric) THEN 23.4 ELSE round((max(soop_xbt_mv.geospatial_lat_max))::numeric, 1) END AS max_lat, round((min(soop_xbt_mv.geospatial_lon_min))::numeric, 1) AS min_lon, CASE WHEN (round((max(soop_xbt_mv.geospatial_lon_max))::numeric, 1) > (180)::numeric) THEN 135.8 ELSE round((max(soop_xbt_mv.geospatial_lon_max))::numeric, 1) END AS max_lon, round((min(soop_xbt_mv.geospatial_vertical_min))::numeric, 1) AS min_depth, round((max(soop_xbt_mv.geospatial_vertical_max))::numeric, 1) AS max_depth, date(soop_xbt_manual.data_on_portal) AS data_on_portal FROM ((dw_soop.soop_xbt_mv LEFT JOIN interm_table_xbt ON (((soop_xbt_mv.xbt_line = (interm_table_xbt.line_name)::text) AND ((interm_table_xbt.year)::bpchar = (date_part('year'::text, soop_xbt_mv.launch_date))::character(4))))) LEFT JOIN report.soop_xbt_manual ON (((interm_table_xbt.bundle_id)::text = (soop_xbt_manual.bundle_id)::text))) GROUP BY 'XBT (near real-time & delayed-mode)'::text, soop_xbt_mv.xbt_line, soop_xbt_mv.xbt_line_description, interm_table_xbt.year, interm_table_xbt.bundle_id, interm_table_xbt.no_profiles, soop_xbt_manual.data_on_portal ORDER BY 1, 2, 3, 4;

grant all on table soop_all_deployments_view to public;

-- disable because uses above 

CREATE or replace VIEW soop_data_summary_view AS
 SELECT soop_all_deployments_view.subfacility, soop_all_deployments_view.vessel_name, count(CASE WHEN (soop_all_deployments_view.deployment_id IS NULL) THEN '1'::character varying ELSE soop_all_deployments_view.deployment_id END) AS no_deployments, sum(CASE WHEN (soop_all_deployments_view.no_data_files IS NULL) THEN (1)::bigint ELSE soop_all_deployments_view.no_data_files END) AS no_data_files, COALESCE(((round(min(soop_all_deployments_view.min_lat), 1) || '/'::text) || round(max(soop_all_deployments_view.max_lat), 1))) AS lat_range, COALESCE(((round(min(soop_all_deployments_view.min_lon), 1) || '/'::text) || round(max(soop_all_deployments_view.max_lon), 1))) AS lon_range, COALESCE(((round(min(soop_all_deployments_view.min_depth), 1) || '/'::text) || round(max(soop_all_deployments_view.max_depth), 1))) AS depth_range, min(soop_all_deployments_view.start_date) AS earliest_date, max(soop_all_deployments_view.end_date) AS latest_date, sum(soop_all_deployments_view.coverage_duration) AS coverage_duration, round(avg(soop_all_deployments_view.days_to_process_and_upload), 1) AS mean_days_to_process_and_upload, round(avg(soop_all_deployments_view.days_to_make_public), 1) AS mean_days_to_make_public, sum(CASE WHEN (soop_all_deployments_view.missing_info IS NULL) THEN 1 ELSE 0 END) AS missing_info, round(min(soop_all_deployments_view.min_lat), 1) AS min_lat, round(max(soop_all_deployments_view.max_lat), 1) AS max_lat, round(min(soop_all_deployments_view.min_lon), 1) AS min_lon, round(max(soop_all_deployments_view.max_lon), 1) AS max_lon, round(min(soop_all_deployments_view.min_depth), 1) AS min_depth, round(max(soop_all_deployments_view.max_depth), 1) AS max_depth FROM soop_all_deployments_view GROUP BY soop_all_deployments_view.subfacility, soop_all_deployments_view.vessel_name UNION ALL SELECT soop_cpr_all_deployments_view.subfacility, soop_cpr_all_deployments_view.vessel_name, count(soop_cpr_all_deployments_view.vessel_name) AS no_deployments, CASE WHEN (sum(CASE WHEN (soop_cpr_all_deployments_view.no_phyto_samples IS NULL) THEN 0 ELSE 1 END) <> count(soop_cpr_all_deployments_view.vessel_name)) THEN sum((soop_cpr_all_deployments_view.no_pci_samples + soop_cpr_all_deployments_view.no_zoop_samples)) ELSE sum(((soop_cpr_all_deployments_view.no_pci_samples + soop_cpr_all_deployments_view.no_phyto_samples) + soop_cpr_all_deployments_view.no_zoop_samples)) END AS no_data_files, COALESCE(((round(min(soop_cpr_all_deployments_view.min_lat), 1) || '/'::text) || round(max(soop_cpr_all_deployments_view.max_lat), 1))) AS lat_range, COALESCE(((round(min(soop_cpr_all_deployments_view.min_lon), 1) || '/'::text) || round(max(soop_cpr_all_deployments_view.max_lon), 1))) AS lon_range, COALESCE(((round((min(soop_cpr_all_deployments_view.min_depth))::numeric, 1) || '/'::text) || round((max(soop_cpr_all_deployments_view.max_depth))::numeric, 1))) AS depth_range, min(soop_cpr_all_deployments_view.start_date) AS earliest_date, max(soop_cpr_all_deployments_view.end_date) AS latest_date, sum(soop_cpr_all_deployments_view.coverage_duration) AS coverage_duration, round(avg(soop_cpr_all_deployments_view.days_to_process_and_upload), 1) AS mean_days_to_process_and_upload, round(avg(soop_cpr_all_deployments_view.days_to_make_public), 1) AS mean_days_to_make_public, sum(CASE WHEN (soop_cpr_all_deployments_view.missing_info IS NULL) THEN 1 ELSE 0 END) AS missing_info, round(min(soop_cpr_all_deployments_view.min_lat), 1) AS min_lat, round(max(soop_cpr_all_deployments_view.max_lat), 1) AS max_lat, round(min(soop_cpr_all_deployments_view.min_lon), 1) AS min_lon, round(max(soop_cpr_all_deployments_view.max_lon), 1) AS max_lon, round((min(soop_cpr_all_deployments_view.min_depth))::numeric, 1) AS min_depth, round((max(soop_cpr_all_deployments_view.max_depth))::numeric, 1) AS max_depth FROM soop_cpr_all_deployments_view GROUP BY soop_cpr_all_deployments_view.subfacility, soop_cpr_all_deployments_view.vessel_name ORDER BY 1, 2;

grant all on table soop_data_summary_view to public;



-- has data
-- srs_altimetry ->  legacy_srs_altimetry
-- report.srs_altimetry_manual O
-- report.srs_bio_optical_db_manual
-- report.srs_gridded_products_manual
-- srs_oc_soop_rad -> dw_srs.srs_oc_soop_rad 


CREATE or replace VIEW srs_all_deployments_view AS
    ((SELECT 'SRS - Altimetry'::text AS subfacility, CASE WHEN ((data.site_code)::text = 'SRSSTO'::text) THEN 'Storm Bay'::text WHEN ((data.site_code)::text = 'SRSBAS'::text) THEN 'Bass Strait'::text ELSE NULL::text END AS parameter_site, COALESCE((((data.site_code)::text || '-'::text) || "substring"((data.filename)::text, '([^_]+)-'::text))) AS deployment_code, data.sensor_name, round((data.sensor_depth)::numeric, 1) AS depth, date(data.time_coverage_start) AS start_date, date(data.time_coverage_end) AS end_date, (date_part('days'::text, (data.time_coverage_end - data.time_coverage_start)))::numeric AS coverage_duration, (date_part('days'::text, ((srs_altimetry_manual.data_on_staging)::timestamp with time zone - data.time_coverage_end)))::numeric AS days_to_process_and_upload, ((srs_altimetry_manual.data_on_portal - srs_altimetry_manual.data_on_staging))::numeric AS days_to_make_public, srs_altimetry_manual.data_on_staging AS date_on_staging, srs_altimetry_manual.data_on_opendap AS date_on_opendap, srs_altimetry_manual.data_on_portal AS date_on_portal, CASE WHEN (data.metadata_uuid IS NULL) THEN 'No metadata'::text ELSE NULL::text END AS missing_info, round((data.lat)::numeric, 1) AS lat, round((data.lon)::numeric, 1) AS lon FROM (legacy_srs_altimetry.data LEFT JOIN report.srs_altimetry_manual ON ((srs_altimetry_manual.pkid = data.pkid))) 

UNION ALL SELECT 'SRS - BioOptical database'::text AS subfacility, srs_bio_optical_db_manual.data_type AS parameter_site, srs_bio_optical_db_manual.cruise_id AS deployment_code, NULL::character varying AS sensor_name, NULL::numeric AS depth, srs_bio_optical_db_manual.deployment_start AS start_date, srs_bio_optical_db_manual.deployment_end AS end_date, ((srs_bio_optical_db_manual.deployment_end - srs_bio_optical_db_manual.deployment_start))::numeric AS coverage_duration, ((srs_bio_optical_db_manual.data_on_staging - srs_bio_optical_db_manual.deployment_end))::numeric AS days_to_process_and_upload, ((srs_bio_optical_db_manual.data_on_portal - srs_bio_optical_db_manual.data_on_staging))::numeric AS days_to_make_public, srs_bio_optical_db_manual.data_on_staging AS date_on_staging, srs_bio_optical_db_manual.data_on_opendap AS date_on_opendap, srs_bio_optical_db_manual.data_on_portal AS date_on_portal, CASE WHEN (srs_bio_optical_db_manual.mest_creation IS NULL) THEN 'No metadata'::text WHEN (((srs_bio_optical_db_manual.data_on_staging - srs_bio_optical_db_manual.deployment_end))::numeric IS NULL) THEN 'Missing dates'::text ELSE NULL::text END AS missing_info, NULL::numeric AS lat, NULL::numeric AS lon FROM report.srs_bio_optical_db_manual) 

UNION ALL SELECT 'SRS - Gridded Products'::text AS subfacility, CASE WHEN ((srs_gridded_products_manual.product_name)::text = 'MODIS Aqua OC3 Chlorophyll-a'::text) THEN 'Chlorophyll-a'::text WHEN ((srs_gridded_products_manual.product_name)::text = 'SST L3C'::text) THEN 'SST'::text WHEN ((srs_gridded_products_manual.product_name)::text = 'SST L3P - 14 days mosaic'::text) THEN 'SST'::text ELSE NULL::text END AS parameter_site, CASE WHEN ((srs_gridded_products_manual.product_name)::text = 'MODIS Aqua OC3 Chlorophyll-a'::text) THEN 'MODIS Aqua OC3'::text WHEN ((srs_gridded_products_manual.product_name)::text = 'SST L3C'::text) THEN 'L3C'::text WHEN ((srs_gridded_products_manual.product_name)::text = 'SST L3P - 14 days mosaic'::text) THEN 'L3P - 14 days mosaic'::text ELSE NULL::text END AS deployment_code, NULL::character varying AS sensor_name, NULL::numeric AS depth, srs_gridded_products_manual.deployment_start AS start_date, srs_gridded_products_manual.deployment_end AS end_date, ((srs_gridded_products_manual.deployment_end - srs_gridded_products_manual.deployment_start))::numeric AS coverage_duration, ((srs_gridded_products_manual.data_on_staging - srs_gridded_products_manual.deployment_end))::numeric AS days_to_process_and_upload, ((srs_gridded_products_manual.data_on_portal - srs_gridded_products_manual.data_on_staging))::numeric AS days_to_make_public, srs_gridded_products_manual.data_on_staging AS date_on_staging, srs_gridded_products_manual.data_on_opendap AS date_on_opendap, srs_gridded_products_manual.data_on_portal AS date_on_portal, CASE WHEN (srs_gridded_products_manual.mest_creation IS NULL) THEN 'No metadata'::text ELSE NULL::text END AS missing_info, NULL::numeric AS lat, NULL::numeric AS lon FROM report.srs_gridded_products_manual) 

UNION ALL SELECT 'SRS - Ocean Colour'::text AS subfacility, srs_oc_soop_rad.vessel_name AS parameter_site, srs_oc_soop_rad.voyage_number AS deployment_code, NULL::character varying AS sensor_name, NULL::numeric AS depth, min(date(srs_oc_soop_rad.time_coverage_start)) AS start_date, max(date(srs_oc_soop_rad.time_coverage_end)) AS end_date, ((max(date(srs_oc_soop_rad.time_coverage_end)) - min(date(srs_oc_soop_rad.time_coverage_start))))::numeric AS coverage_duration, NULL::numeric AS days_to_process_and_upload, NULL::numeric AS days_to_make_public, NULL::date AS date_on_staging, NULL::date AS date_on_opendap, NULL::date AS date_on_portal, CASE WHEN (((max(date(srs_oc_soop_rad.time_coverage_end)) - min(date(srs_oc_soop_rad.time_coverage_start))))::numeric IS NULL) THEN 'Missing dates'::text ELSE NULL::text END AS missing_info, round((avg(srs_oc_soop_rad.geospatial_lat_min))::numeric, 1) AS lat, round((avg(srs_oc_soop_rad.geospatial_lon_min))::numeric, 1) AS lon FROM dw_srs.srs_oc_soop_rad GROUP BY srs_oc_soop_rad.vessel_name, srs_oc_soop_rad.voyage_number ORDER BY 1, 2, 3, 4, 6, 7;

;

grant all on table srs_all_deployments_view to public;


-- fails becaus of above error
-- no change

CREATE or replace VIEW srs_data_summary_view AS
    SELECT srs_all_deployments_view.subfacility, CASE WHEN (srs_all_deployments_view.parameter_site = 'absorption'::text) THEN 'Absorption'::text WHEN (srs_all_deployments_view.parameter_site = 'pigment'::text) THEN 'Pigment'::text ELSE srs_all_deployments_view.parameter_site END AS parameter_site, count(srs_all_deployments_view.deployment_code) AS no_deployments, count(DISTINCT srs_all_deployments_view.sensor_name) AS no_sensors, COALESCE(((min(srs_all_deployments_view.depth) || ' / '::text) || max(srs_all_deployments_view.depth))) AS depth_range, sum(CASE WHEN (srs_all_deployments_view.missing_info IS NULL) THEN 0 ELSE 1 END) AS no_missing_info, min(srs_all_deployments_view.start_date) AS earliest_date, max(srs_all_deployments_view.end_date) AS latest_date, round(avg(srs_all_deployments_view.coverage_duration), 1) AS mean_coverage_duration, round(avg(srs_all_deployments_view.days_to_process_and_upload), 1) AS mean_days_to_process_and_upload, round(avg(srs_all_deployments_view.days_to_make_public), 1) AS mean_days_to_make_public, min(srs_all_deployments_view.lon) AS min_lon, max(srs_all_deployments_view.lon) AS max_lon, min(srs_all_deployments_view.lat) AS min_lat, max(srs_all_deployments_view.lat) AS max_lat, min(srs_all_deployments_view.depth) AS min_depth, max(srs_all_deployments_view.depth) AS max_depth FROM srs_all_deployments_view GROUP BY srs_all_deployments_view.subfacility, srs_all_deployments_view.parameter_site ORDER BY srs_all_deployments_view.subfacility, CASE WHEN (srs_all_deployments_view.parameter_site = 'absorption'::text) THEN 'Absorption'::text WHEN (srs_all_deployments_view.parameter_site = 'pigment'::text) THEN 'Pigment'::text ELSE srs_all_deployments_view.parameter_site END;

grant all on table srs_data_summary_view to public;



-- has data
-- totals table appears to be completely manually created
-- it must be dealt with.

-- CREATE or replace VIEW totals_view AS
--   SELECT totals.facility, totals.subfacility, totals.type, totals.no_projects, totals.no_platforms, totals.no_instruments, totals.no_deployments, totals.no_data, totals.no_data2, totals.no_data3, totals.no_data4, totals.temporal_range, totals.lat_range, totals.lon_range, totals.depth_range FROM report.totals;

-- grant all on table totals_view to public;



------

-- NOTICE:  geometry_gist_joinsel called with incorrect join type
-- ERROR:  relation "global_attribute" does not exist
-- LINE 2:       from global_attribute a
                   


--CREATE TABLE totals AS
CREATE or replace view totals_view AS
 WITH interm_table AS (
  SELECT COUNT(DISTINCT(parameter)) AS no_parameters
  FROM faimms_all_deployments_view),
   interm_table2 AS (
  SELECT COUNT(DISTINCT(parameter)) AS no_parameters
  FROM anmn_nrs_realtime_all_deployments_view)
SELECT 'AATAMS' AS facility,
'Biologging' AS subfacility,
tag_type AS type,
COUNT(DISTINCT(sattag_program)) AS no_projects,
COUNT(DISTINCT(species_name)) AS no_platforms,
NULL::bigint AS no_instruments,
SUM(no_tags) AS no_deployments,
SUM(total_nb_profiles) AS no_data,
NULL::bigint AS no_data2,
NULL::bigint AS no_data3,
NULL::bigint AS no_data4,
COALESCE(to_char(min(coverage_start),'DD/MM/YYYY')||' - '||to_char(max(coverage_end),'DD/MM/YYYY')) AS temporal_range,
COALESCE(min(min_lat)||' - '||max(max_lat)) AS lat_range,
COALESCE(min(min_lon)||' - '||max(max_lon)) AS lon_range,
NULL AS depth_range
FROM aatams_sattag_data_summary_view
GROUP BY tag_type
UNION ALL
SELECT 'AATAMS' AS facility,
'Biologging' AS subfacility,
'TOTAL' AS type,
COUNT(DISTINCT(sattag_program)) AS no_projects,
COUNT(DISTINCT(species_name)) AS no_platforms,
NULL::bigint AS no_instruments,
SUM(no_tags) AS no_deployments,
SUM(total_nb_profiles) AS no_data,
NULL::bigint AS no_data2,
NULL::bigint AS no_data3,
NULL::bigint AS no_data4,
COALESCE(to_char(min(coverage_start),'DD/MM/YYYY')||' - '||to_char(max(coverage_end),'DD/MM/YYYY')) AS temporal_range,
COALESCE(min(min_lat)||' - '||max(max_lat)) AS lat_range,
COALESCE(min(min_lon)||' - '||max(max_lon)) AS lon_range,
NULL AS depth_range
FROM aatams_sattag_data_summary_view
-----------------------------------------------------------------------
UNION ALL
SELECT 'ABOS' AS facility,
'ASFS & SOTS' AS subfacility,
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
FROM abos_asfssots_data_summary_view
GROUP BY file_type
UNION ALL
SELECT 'ABOS' AS facility,
'ASFS & SOTS' AS subfacility,
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
FROM abos_asfssots_data_summary_view
-----------------------------------------------------------------------
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
SUM(no_deployments) AS no_deployments,
SUM(total_no_images) AS no_data,
SUM(total_distance) AS no_data2,
NULL::bigint AS no_data3,
NULL::bigint AS no_data4,
COALESCE(to_char(min(earliest_date),'DD/MM/YYYY')||' - '||to_char(max(latest_date),'DD/MM/YYYY')) AS temporal_range,
COALESCE(min(lat_min)||' - '||max(lat_max)) AS lat_range,
COALESCE(min(lon_min)||' - '||max(lon_max)) AS lon_range,
COALESCE(min(min_depth)||' - '||max(max_depth)) AS depth_range
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
SUM(no_qc_data) AS no_data,
NULL AS no_data2,
NULL::bigint AS no_data3,
NULL::bigint AS no_data4,
COALESCE(to_char(min(earliest_date),'DD/MM/YYYY')||' - '||to_char(max(latest_date),'DD/MM/YYYY')) AS temporal_range,
NULL AS lat_range,
NULL AS lon_range,
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
COALESCE(min(min_depth)||' - '||max(max_depth)) AS depth_range
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
COALESCE(min(min_depth)||' - '||max(max_depth)) AS depth_range
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
SUM(no_sensors) AS no_instruments,
ROUND(AVG(interm_table2.no_parameters),0) AS no_deployments,
SUM(no_qc_data) AS no_data,
NULL AS no_data2,
NULL::bigint AS no_data3,
NULL::bigint AS no_data4,
COALESCE(to_char(min(earliest_date),'DD/MM/YYYY')||' - '||to_char(max(latest_date),'DD/MM/YYYY')) AS temporal_range,
NULL AS lat_range,
NULL AS lon_range,
COALESCE(min(min_depth)||' - '||max(max_depth)) AS depth_range
FROM anmn_nrs_realtime_data_summary_view,interm_table2
ORDER BY facility,subfacility,type;

grant all on table totals_view to public;

-- GRANT SELECT, REFERENCES ON TABLE  totals TO gisread;
-- GRANT ALL ON TABLE  totals TO gisadmin;
--
------ Create totals_view
-- CREATE OR REPLACE VIEW totals_view AS
-- SELECT * FROM totals;
-- GRANT SELECT, REFERENCES ON TABLE  totals_view TO gisread;
-- GRANT ALL ON TABLE  totals_view TO gisadmin;
--
-- SELECT * FROM  totals_view;



