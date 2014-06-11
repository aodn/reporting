SET search_path = report_test, public;

-------------------------------
-- VIEWS FOR AATAMS_ACOUSTIC
-------------------------------
CREATE OR REPLACE VIEW aatams_acoustictag_all_deployments_view AS
    SELECT *
    FROM dw_aatams_acoustic.aatams_acoustictag_all_deployments_view;

CREATE OR REPLACE VIEW aatams_acoustictag_data_summary_project_view AS
    SELECT *
    FROM dw_aatams_acoustic.aatams_acoustictag_data_summary_project_view;

CREATE OR REPLACE VIEW aatams_acoustictag_data_summary_species_view AS
    SELECT *
    FROM dw_aatams_acoustic.aatams_acoustictag_data_summary_species_view;

grant all on table aatams_acoustictag_all_deployments_view to public;
grant all on table aatams_acoustictag_data_summary_project_view to public;
grant all on table aatams_acoustictag_data_summary_species_view to public;

-------------------------------
-- VIEWS FOR AATAMS_SATTAG_NRT and AATAMS_SATTAG_DM; Can delete the aatams_sattag manual tables in the report schema.
-------------------------------
-- All deployments view
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
	date_part('days', max(map."timestamp") - min(map."timestamp"))::integer AS coverage_duration,
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
	date_part('days', max(dmap."timestamp") - min(dmap."timestamp"))::integer AS coverage_duration,
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

-- Data summary view
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

-------------------------------
-- VIEWS FOR AATAMS_BIOLOGGING_PENGUIN AND AATAMS_BIOLOGGING_SHEARWATERS
-------------------------------
-- All deployments view
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

-- Data summary view
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

-------------------------------
-- VIEWS FOR ABOS; Uses what's in the dw_abos schema.
-------------------------------
-- All deployments view
CREATE or replace VIEW abos_all_deployments_view AS
    WITH table_a AS (
    SELECT 
    substring(url, 'IMOS/ABOS/([A-Z]+)/') AS sub_facility, 
    CASE WHEN platform_code = 'PULSE' THEN 'Pulse' 
	ELSE platform_code END AS platform_code, 
    CASE WHEN deployment_code IS NULL THEN COALESCE(platform_code || '-' || CASE WHEN (deployment_number IS NULL) THEN '' 
	ELSE deployment_number END) || '-' || btrim(to_char(time_coverage_start, 'YYYY')) ELSE deployment_code END AS deployment_code,
    substring(url, '[^/]+nc') AS file_name,
    (substring(url, 'FV0([12]+)'))::integer AS file_version,
    CASE WHEN substring(url, '(Surface_waves|Surface_properties|Surface_fluxes|Sub-surface_temperature_pressure_conductivity|Pulse|SAZ|Sub-surface_currents|Velocity|Temperature|CTD_timeseries|CTD_Timeseries)') = 'Pulse' 
	OR substring(url, '(Surface_waves|Surface_properties|Surface_fluxes|Sub-surface_temperature_pressure_conductivity|Pulse|SAZ|Sub-surface_currents|Velocity|Temperature|CTD_timeseries|CTD_Timeseries)') = 'SAZ' THEN 'Biogeochemistry'
	WHEN substring(url, '(Surface_waves|Surface_properties|Surface_fluxes|Sub-surface_temperature_pressure_conductivity|Pulse|SAZ|Sub-surface_currents|Velocity|Temperature|CTD_timeseries|CTD_Timeseries)') = 'CTD_Timeseries' THEN 'CTD_timeseries'
	ELSE substring(url, '(Surface_waves|Surface_properties|Surface_fluxes|Sub-surface_temperature_pressure_conductivity|Pulse|SAZ|Sub-surface_currents|Velocity|Temperature|CTD_timeseries|CTD_Timeseries)') END AS data_category,
    COALESCE(substring(url, 'Real-time'), 'Delayed-mode') AS data_type, 
    COALESCE(substring(url, '[0-9]{4}_daily'), 'Whole deployment') AS year_frequency, 
    timezone('UTC'::text, time_coverage_start) AS coverage_start, 
    timezone('UTC'::text, time_coverage_end) AS coverage_end, 
    round(((date_part('day', (time_coverage_end - time_coverage_start)) + (date_part('hours'::text, (time_coverage_end - time_coverage_start)) / (24)::double precision)))::numeric, 1) AS coverage_duration, 
    (date_part('day', (last_modified - date_created)))::integer AS days_to_process_and_upload, 
    (date_part('day', (last_indexed - last_modified)))::integer AS days_to_make_public, 
    deployment_number, author, principal_investigator 
    FROM dw_abos.abos_file
    WHERE status IS DISTINCT FROM 'DELETED'
    ORDER BY sub_facility, platform_code, data_category)
  SELECT CASE WHEN a.year_frequency = 'Whole deployment' THEN 'Aggregated files' 
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

grant all on table abos_all_deployments_view to public;

-- Data summary view
CREATE or replace VIEW abos_data_summary_view AS
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
    round(((date_part('day', (max(v.time_coverage_end) - min(v.time_coverage_start))) + (date_part('hours', (max(v.time_coverage_end) - min(v.time_coverage_start))) / (24)::double precision)))::numeric, 1) AS coverage_duration, 
    CASE WHEN (sum(v.coverage_duration))::integer > ceil(((date_part('day', (max(v.time_coverage_end) - min(v.time_coverage_start))) + (date_part('hours', (max(v.time_coverage_end) - min(v.time_coverage_start))) / (24)::double precision)))::numeric)
	THEN round(((date_part('day', (max(v.time_coverage_end) - min(v.time_coverage_start))) + (date_part('hours', (max(v.time_coverage_end) - min(v.time_coverage_start))) / (24)::double precision)))::numeric, 1)
	ElSE (sum(v.coverage_duration)) END AS data_coverage, 
    CASE WHEN max(v.coverage_end) - min(v.coverage_start) = 0 THEN 0
	WHEN (sum(v.coverage_duration))::integer > ceil(((date_part('day', (max(v.time_coverage_end) - min(v.time_coverage_start))) + (date_part('hours', (max(v.time_coverage_end) - min(v.time_coverage_start))) / (24)::double precision)))::numeric)
	THEN (((round(((date_part('day', (max(v.time_coverage_end) - min(v.time_coverage_start))) + (date_part('hours', (max(v.time_coverage_end) - min(v.time_coverage_start))) / (24)::double precision)))::numeric, 1) / ((max(v.coverage_end) - min(v.coverage_start)))::numeric) * (100)::numeric))::integer
	ELSE (((sum(v.coverage_duration) / ((max(v.coverage_end) - min(v.coverage_start)))::numeric) * (100)::numeric))::integer END AS percent_coverage, 
    round(avg(v.mean_days_to_process_and_upload), 1) AS mean_days_to_process_and_upload, 
    round(avg(v.mean_days_to_make_public), 1) AS mean_days_to_make_public, 
    v.platform_code, 
    v.sub_facility 
    FROM abos_all_deployments_view v
    WHERE v.headers IS NOT NULL 
    GROUP BY v.headers, v.data_category, v.data_type, v.file_type, v.platform_code, v.sub_facility 
    ORDER BY v.file_type, v.headers, v.data_type, v.data_category;

grant all on table abos_data_summary_view to public;

-------------------------------
-- VIEW FOR ACORN; Doesn't use the report.acorn_manual table anymore. Still work needed to incorporate acorn_radials schemas.
-------------------------------
-- All deployments view
CREATE OR REPLACE VIEW acorn_all_deployments_view AS
WITH a AS (
  SELECT timeseries_id,
	site_code,
	to_char(to_timestamp (date_part('month',time)::text, 'MM'), 'Month') AS month,
	date_part('year',time)::text AS year
  FROM acorn_hourly_avg_qc.acorn_hourly_avg_qc_timeseries_url),
     b AS (
  SELECT timeseries_id,
	site_code,
	to_char(to_timestamp (date_part('month',time)::text, 'MM'), 'Month') AS month,
	date_part('year',time)::text AS year
  FROM acorn_hourly_avg_nonqc.acorn_hourly_avg_nonqc_timeseries_url),
       c AS (
  SELECT timeseries_id,
	site_code,
	to_char(to_timestamp (date_part('month',time)::text, 'MM'), 'Month') AS month,
	date_part('year',time)::text AS year
  FROM acorn_radial_qc.acorn_radial_qc_timeseries_url),
         d AS (
  SELECT timeseries_id,
	site_code,
	to_char(to_timestamp (date_part('month',time)::text, 'MM'), 'Month') AS month,
	date_part('year',time)::text AS year
  FROM acorn_radial_nonqc.acorn_radial_nonqc_timeseries_url)
  SELECT 'Gridded product - QC' AS data_type, 
	substring(u.site_code,'\, (.*)') AS site,
	COUNT(u.timeseries_id) AS no_files,
	date(min(time)) AS time_start,
	date(max(time)) AS time_end,
	round((date_part('day',max(time)-min(time)) + date_part('hours',max(time)-min(time))/24)::numeric, 1) AS coverage_duration,
	round(COUNT(u.timeseries_id) / (round((DATE_PART('days', DATE_TRUNC('month', min(time)) + '1 MONTH'::INTERVAL - DATE_TRUNC('month', min(time))))::numeric, 0) * 24) * 100, 1) AS monthly_coverage,
	COALESCE(a.month || ' ' || a.year) AS month_year,
	a.month,
	a.year
  FROM acorn_hourly_avg_qc.acorn_hourly_avg_qc_timeseries_url u
  JOIN a ON a.timeseries_id = u.timeseries_id
	GROUP BY data_type, u.site_code, month, year

UNION ALL

  SELECT 'Gridded product - non QC' AS data_type, 
	substring(u.site_code,'\, (.*)') AS site,
	COUNT(u.timeseries_id) AS no_files,
	date(min(time)) AS time_start,
	date(max(time)) AS time_end,
	round((date_part('day',max(time)-min(time)) + date_part('hours',max(time)-min(time))/24)::numeric, 1) AS coverage_duration,
	round(COUNT(u.timeseries_id) / (round((DATE_PART('days', DATE_TRUNC('month', min(time)) + '1 MONTH'::INTERVAL - DATE_TRUNC('month', min(time))))::numeric, 0) * 24) * 100, 1) AS monthly_coverage,
	COALESCE(b.month || ' ' || b.year) AS month_year,
	b.month,
	b.year
  FROM acorn_hourly_avg_nonqc.acorn_hourly_avg_nonqc_timeseries_url u
  JOIN b ON b.timeseries_id = u.timeseries_id
	GROUP BY data_type, u.site_code, month, year

UNION ALL

  SELECT 'Radials - QC' AS data_type, 
	substring(u.site_code,'\, (.*)') AS site,
	COUNT(u.timeseries_id) AS no_files,
	date(min(time)) AS time_start,
	date(max(time)) AS time_end,
	round((date_part('day',max(time)-min(time)) + date_part('hours',max(time)-min(time))/24)::numeric, 1) AS coverage_duration,
	round(COUNT(u.timeseries_id) / (round((DATE_PART('days', DATE_TRUNC('month', min(time)) + '1 MONTH'::INTERVAL - DATE_TRUNC('month', min(time))))::numeric, 0) * 24) * 100, 1) AS monthly_coverage,
	COALESCE(b.month || ' ' || b.year) AS month_year,
	b.month,
	b.year
  FROM acorn_radial_qc.acorn_radial_qc_timeseries_url u
  JOIN b ON b.timeseries_id = u.timeseries_id
	GROUP BY data_type, u.site_code, month, year

UNION ALL

  SELECT 'Radials - non QC' AS data_type, 
	substring(u.site_code,'\, (.*)') AS site,
	COUNT(u.timeseries_id) AS no_files,
	date(min(time)) AS time_start,
	date(max(time)) AS time_end,
	round((date_part('day',max(time)-min(time)) + date_part('hours',max(time)-min(time))/24)::numeric, 1) AS coverage_duration,
	round(COUNT(u.timeseries_id) / (round((DATE_PART('days', DATE_TRUNC('month', min(time)) + '1 MONTH'::INTERVAL - DATE_TRUNC('month', min(time))))::numeric, 0) * 24) * 100, 1) AS monthly_coverage,
	COALESCE(b.month || ' ' || b.year) AS month_year,
	b.month,
	b.year
  FROM acorn_radial_nonqc.acorn_radial_nonqc_timeseries_url u
  JOIN b ON b.timeseries_id = u.timeseries_id
	GROUP BY data_type, u.site_code, month, year
	ORDER BY data_type, site, time_start;

grant all on table acorn_all_deployments_view to public;

-- Data summary view
CREATE OR REPLACE VIEW acorn_data_summary_view AS
  SELECT data_type,
	site,
	SUM(no_files) AS total_no_files,
	min(time_start) AS time_start,
	max(time_end) AS time_end,
	round(((max(time_end)-min(time_start))::numeric)/365.25, 1) AS coverage_duration,
	round(SUM(no_files) / (round((max(time_end)-min(time_start))::numeric, 0) * 24) * 100, 1) AS percentage_coverage
  FROM acorn_all_deployments_view
	GROUP BY data_type, site
	ORDER BY data_type, site;

grant all on table acorn_data_summary_view to public;

-------------------------------
-- VIEW FOR ANFOG; Now using the anfog_dm and anfog_rt schema only so don't need the legacy_anfog schema, nor report.anfog_manual anymore.
-------------------------------
-- All deployments view
CREATE or replace VIEW anfog_all_deployments_view AS
  SELECT 'Near real-time data' AS data_type,
	 mrt.platform_type AS glider_type, 
	 mrt.platform_code AS platform, 
	 mrt.deployment_name AS deployment_id, 
	 min(date(mrt.time_coverage_start)) AS start_date, 
	 max(date(mrt.time_coverage_end)) AS end_date,
 	 min(round((ST_YMIN(geom))::numeric, 1)) AS min_lat,
 	 max(round((ST_YMAX(geom))::numeric, 1)) AS max_lat,
 	 min(round((ST_XMIN(geom))::numeric, 1)) AS min_lon,
 	 max(round((ST_XMAX(geom))::numeric, 1)) AS max_lon,
 	COALESCE(min(round((ST_YMIN(geom))::numeric, 1)) || '/' || max(round((ST_YMAX(geom))::numeric, 1))) AS lat_range,
 	COALESCE(min(round((ST_XMIN(geom))::numeric, 1)) || '/' || max(round((ST_XMAX(geom))::numeric, 1))) AS lon_range,
 	round(max(drt.geospatial_vertical_max)::numeric, 1) AS max_depth, 
 	round((date_part('days', max(to_timestamp(mrt.time_coverage_end,'YYYY-MM-DDTHH:MI:SSZ')) - min(to_timestamp(mrt.time_coverage_start,'YYYY-MM-DDTHH:MI:SSZ'))) + 
 	date_part('hours', max(to_timestamp(mrt.time_coverage_end,'YYYY-MM-DDTHH:MI:SSZ')) - min(to_timestamp(mrt.time_coverage_start,'YYYY-MM-DDTHH:MI:SSZ')))/24)::numeric, 1) AS coverage_duration
  FROM anfog_rt.anfog_rt_trajectory_map mrt
  RIGHT JOIN anfog_rt.deployments drt ON mrt.file_id = drt.file_id
	GROUP BY mrt.platform_type, mrt.platform_code, mrt.deployment_name

UNION ALL

  SELECT 'Delayed mode data' AS data_type,
	 m.platform_type AS glider_type, 
	 m.platform_code AS platform, 
	 m.deployment_name AS deployment_id, 
	 date(m.time_coverage_start) AS start_date, 
	 date(m.time_coverage_end) AS end_date,
 	 round((ST_YMIN(geom))::numeric, 1) AS min_lat,
 	 round((ST_YMAX(geom))::numeric, 1) AS max_lat,
 	 round((ST_XMIN(geom))::numeric, 1) AS min_lon,
 	 round((ST_XMAX(geom))::numeric, 1) AS max_lon,
 	COALESCE(round((ST_YMIN(geom))::numeric, 1) || '/' || round((ST_YMAX(geom))::numeric, 1)) AS lat_range,
 	COALESCE(round((ST_XMIN(geom))::numeric, 1) || '/' || round((ST_XMAX(geom))::numeric, 1)) AS lon_range,
 	round(d.geospatial_vertical_max::numeric, 1) AS max_depth, 
 	round((date_part('days', max(to_timestamp(m.time_coverage_end,'YYYY-MM-DDTHH:MI:SSZ')) - min(to_timestamp(m.time_coverage_start,'YYYY-MM-DDTHH:MI:SSZ'))) + 
 	date_part('hours', max(to_timestamp(m.time_coverage_end,'YYYY-MM-DDTHH:MI:SSZ')) - min(to_timestamp(m.time_coverage_start,'YYYY-MM-DDTHH:MI:SSZ')))/24)::numeric, 1) AS coverage_duration
  FROM anfog_dm.anfog_dm_trajectory_map m
  RIGHT JOIN anfog_dm.deployments d ON m.file_id = d.file_id
	GROUP BY m.platform_type, m.platform_code, m.deployment_name, m.time_coverage_start, m.time_coverage_end, m.geom, d.geospatial_vertical_max
	ORDER BY data_type, glider_type, platform, deployment_id;

grant all on table anfog_all_deployments_view to public;

-- Data summary view
CREATE or replace VIEW anfog_data_summary_view AS
  SELECT v.data_type,
	v.glider_type AS glider_type, 
	count(DISTINCT v.platform) AS no_platforms, 
	count(DISTINCT v.deployment_id) AS no_deployments, 
	min(v.start_date) AS earliest_date, 
	max(v.end_date) AS latest_date, 
	COALESCE(min(v.min_lat) || '/' || max(v.max_lat)) AS lat_range, 
	COALESCE(min(v.min_lon) || '/' || max(v.max_lon)) AS lon_range, 
	COALESCE(min(v.max_depth) || '/' || max(v.max_depth)) AS depth_range, 
	round(avg(v.coverage_duration), 1) AS mean_coverage_duration, 
	min(v.min_lat) AS min_lat, 
	max(v.max_lat) AS max_lat, 
	min(v.min_lon) AS min_lon, 
	max(v.max_lon) AS max_lon, 
	min(v.max_depth) AS min_depth, 
	max(v.max_depth) AS max_depth 
  FROM anfog_all_deployments_view v
	GROUP BY data_type, glider_type 
	ORDER BY data_type,glider_type;

grant all on table anfog_data_summary_view to public;

-------------------------------
-- VIEW FOR ANMN Acoustics; Using the report.acoustic_deployments table only.
-------------------------------
-- All deployments view
CREATE or replace VIEW anmn_acoustics_all_deployments_view AS
  SELECT substring(m.deployment_name, '[^0-9]+') AS site_name, 
	"substring"((m.deployment_name), '2[-0-9]+') AS deployment_year, 
	m.logger_id, 
	bool_or((((m.set_success) !~~* '%fail%') AND (m.frequency = 6))) AS good_data, 
	bool_or((((m.set_success) !~~* '%fail%') AND (m.frequency = 22))) AS good_22, 
	bool_or((m.is_primary AND (m.data_path IS NOT NULL))) AS on_viewer, 
	round(avg((m.receiver_depth)::numeric), 1) AS depth, 
	min(m.time_deployment_start) AS start_date, 
	max(m.time_deployment_end) AS end_date, 
	round((date_part('days',max(m.time_deployment_end) - min(m.time_deployment_start)) + date_part('days',max(m.time_deployment_end) - min(m.time_deployment_start))/24)::numeric, 1) AS coverage_duration
  FROM reporting.acoustic_deployments m
  GROUP BY m.deployment_name, m.lat, m.lon, m.logger_id 
  ORDER BY site_name, deployment_year, m.logger_id;

grant all on table anmn_acoustics_all_deployments_view to public;

-- Data summary view
CREATE or replace VIEW anmn_acoustics_data_summary_view AS
  SELECT v.site_name, 
  v.deployment_year, 
  count(*) AS no_loggers, 
  sum((v.good_data)::integer) AS no_good_data, 
  sum((v.on_viewer)::integer) AS no_sets_on_viewer, 
  sum((v.good_22)::integer) AS no_good_22, 
  min(date(v.start_date)) AS earliest_date, 
  max(date(v.end_date)) AS latest_date, 
  round((date_part('days',max(v.end_date) - min(v.start_date)) + date_part('days',max(v.end_date) - min(v.start_date))/24)::numeric, 1) AS coverage_duration
  FROM anmn_acoustics_all_deployments_view v
  GROUP BY v.site_name, v.deployment_year 
  ORDER BY site_name, deployment_year;

grant all on table anmn_acoustics_data_summary_view to public;

-------------------------------
-- VIEW FOR ANMN; Still using the anmn_platforms_manual table from the report schema. Uses the dw_anmn schema.
-------------------------------
-- All deployments view
CREATE or replace VIEW anmn_all_deployments_view AS
  WITH site_view AS (
  SELECT m.site_code, 
	m.site_name, 
	avg(m.lat) AS site_lat, 
	avg(m.lon) AS site_lon, 
	(avg(m.depth))::integer AS site_depth, 
	min(m.first_deployed) AS site_first_deployed, 
	max(m.discontinued) AS site_discontinued, 
	bool_or(m.active) AS site_active 
  FROM report.anmn_platforms_manual m
	GROUP BY m.site_code, m.site_name 
	ORDER BY m.site_code), 
    file_view AS (
  SELECT 
	DISTINCT "substring"((v.url), 'IMOS/ANMN/([A-Z]+)/') AS subfacility, 
	v.site_code, 
	v.platform_code, 
	v.deployment_code, 
	"substring"((v.url), '([^_]+)_END') AS deployment_product, 
	v.status, 
	"substring"(v.file_version, 'Level ([012]+)') AS file_version, 
	"substring"((v.url), '(Temperature|CTD_timeseries|CTD_profiles|Biogeochem_timeseries|Biogeochem_profiles|Velocity|Wave|CO2|Meteorology)') AS data_category, 
	NULLIF(v.geospatial_vertical_min, '-Infinity')::double precision AS geospatial_vertical_min, 
	NULLIF(v.geospatial_vertical_max, 'Infinity')::double precision AS geospatial_vertical_max, 
	CASE WHEN timezone('UTC', v.time_deployment_start) IS NULL THEN v.time_coverage_start 
		ELSE (timezone('UTC', v.time_deployment_start))::timestamp with time zone END AS time_deployment_start, 
	CASE WHEN timezone('UTC', v.time_deployment_end) IS NULL THEN v.time_coverage_end 
		ELSE (timezone('UTC', v.time_deployment_end))::timestamp with time zone END AS time_deployment_end, 
	timezone('UTC', GREATEST(v.time_deployment_start, v.time_coverage_start)) AS good_data_start, 
	timezone('UTC', LEAST(v.time_deployment_end, v.time_coverage_end)) AS good_data_end, 
	(v.time_coverage_end - v.time_coverage_start) AS coverage_duration, 
	(v.time_deployment_end - v.time_deployment_start) AS deployment_duration, 
	GREATEST('00:00:00'::interval, (LEAST(v.time_deployment_end, v.time_coverage_end) - GREATEST(v.time_deployment_start, v.time_coverage_start))) AS good_data_duration
  FROM dw_anmn.anmn_mv v 
	ORDER BY subfacility, deployment_code, data_category)
  SELECT 
	f.subfacility, 
	COALESCE(s.site_name || ' (' || f.site_code || ')' || ' - Lat/Lon:' || round((min(s.site_lat))::numeric, 1) || '/' || round((min(s.site_lon))::numeric, 1)) AS site_name_code, 
	f.data_category, 
	f.deployment_code, 
	(sum(((f.file_version = '0'))::integer))::numeric AS no_fv00, 
	(sum(((f.file_version = '1'))::integer))::numeric AS no_fv01, 
	min(f.time_deployment_start) AS start_date, 
	max(f.time_deployment_end) AS end_date, 
	round((date_part('days', (max(f.time_deployment_end) - min(f.time_deployment_start))) + date_part('hours', (max(f.time_deployment_end) - min(f.time_deployment_start)))/24)::numeric, 1) AS coverage_duration, 
	round((date_part('days', (max(f.good_data_end) - min(f.good_data_start))) + date_part('hours', (max(f.good_data_end) - min(f.good_data_start)))/24)::numeric, 1) AS data_coverage,
	min(f.good_data_start) AS good_data_start, 
	max(f.good_data_end) AS good_data_end, 
	round((min(s.site_lat))::numeric, 1) AS min_lat, 
	round((min(s.site_lon))::numeric, 1) AS min_lon, 
	round((max(s.site_lat))::numeric, 1) AS max_lat, 
	round((max(s.site_lon))::numeric, 1) AS max_lon, 
	round((min(f.geospatial_vertical_min))::numeric, 1) AS min_depth, 
	round((max(f.geospatial_vertical_max))::numeric, 1) AS max_depth,
	f.site_code 
  FROM file_view f 
  NATURAL LEFT JOIN site_view s 
	WHERE f.status IS NULL 
	GROUP BY f.subfacility, f.site_code, s.site_name, f.data_category, f.deployment_code 
	ORDER BY f.subfacility, f.site_code, f.data_category, f.deployment_code;

grant all on table anmn_all_deployments_view to public;

-- Data summary view
CREATE or replace VIEW anmn_data_summary_view AS
  SELECT v.subfacility, 
	v.site_name_code, 
	v.data_category, 
	count(*) AS no_deployments, 
	sum(v.no_fv00) AS no_fv00, 
	sum(v.no_fv01) AS no_fv01, 
	CASE WHEN (CASE WHEN min(v.min_depth) < 0 THEN min(v.min_depth) * (-1) ELSE min(v.min_depth) END) > max(v.max_depth) 
		THEN COALESCE(max(v.max_depth) || '/' || CASE WHEN min(v.min_depth) < 0 THEN min(v.min_depth) * (-1) ELSE min(v.min_depth) END)
		ELSE COALESCE(CASE WHEN min(v.min_depth) < 0 THEN min(v.min_depth) * (-1) ELSE min(v.min_depth) END || '/' || max(v.max_depth)) END AS depth_range, 
	min(v.start_date) AS earliest_date, 
	max(v.end_date) AS latest_date, 
	round(((date_part('days',max(v.end_date) - min(v.start_date))) + (date_part('hours',max(v.end_date) - min(v.start_date)))/24)::numeric, 1) AS coverage_duration, 
	sum(v.data_coverage) AS data_coverage, 
	CASE WHEN round(sum(v.data_coverage) / (((date_part('days',max(v.end_date) - min(v.start_date))) + (date_part('hours',max(v.end_date) - min(v.start_date)))/24)::numeric) * 100, 1) < 0 
		THEN NULL::numeric 
		WHEN round(sum(v.data_coverage) / (((date_part('days',max(v.end_date) - min(v.start_date))) + (date_part('hours',max(v.end_date) - min(v.start_date)))/24)::numeric) * 100, 1) > 100 
		THEN 100 
		ELSE round(sum(v.data_coverage) / (((date_part('days',max(v.end_date) - min(v.start_date))) + (date_part('hours',max(v.end_date) - min(v.start_date)))/24)::numeric) * 100, 1) END AS percent_coverage,
	min(v.min_lat) AS min_lat, 
	min(v.min_lon) AS min_lon, 
	min(v.min_depth) AS min_depth, 
	max(v.max_depth) AS max_depth, 
	v.site_code 
  FROM anmn_all_deployments_view v
	GROUP BY v.subfacility, v.site_name_code, v.data_category, v.site_code 
	ORDER BY v.subfacility, v.site_code, v.data_category;

grant all on table anmn_data_summary_view to public;

-------------------------------
-- VIEW FOR ANMN NRS real-time; Only using the anmn_realtime schema. Can get rid of legacy_anmn schema and report.nrs_aims_manual
-------------------------------
-- All deployments view
CREATE or replace VIEW anmn_nrs_realtime_all_deployments_view AS
  SELECT DISTINCT CASE WHEN site_code = 'NRSMAI' THEN 'Maria Island'
        WHEN site_code = 'NRSYON' OR site_code = 'YongalaNRS' THEN 'Yongala'
        WHEN site_code = 'NRSDAR' THEN 'Darwin'
        WHEN site_code = 'NRSNSI' THEN 'North Stradbroke Island' END as site_name,
   CASE WHEN source = instrument THEN source
        ELSE COALESCE(source || '-' || instrument) END AS channel_id,
   CASE WHEN substring(file_version,'[0-9]+') = '1' THEN true
        ELSE false END AS qaqc_data,
   time_coverage_start AS start_date,
   time_coverage_end AS end_date,
   round((date_part('days', (time_coverage_end - time_coverage_start)) + date_part('hours', (time_coverage_end - time_coverage_start))/24)::numeric, 1) AS coverage_duration,
   CASE WHEN site_code = 'YongalaNRS' THEN 'NRSYON' ELSE site_code END AS platform_code,
   CASE WHEN instrument_nominal_depth IS NULL THEN geospatial_vertical_max::numeric 
        ELSE instrument_nominal_depth::numeric END AS sensor_depth
  FROM dw_anmn_realtime.anmn_mv
   ORDER BY site_name, channel_id, start_date;

grant all on table anmn_nrs_realtime_all_deployments_view to public;

-- Data summary view
CREATE or replace VIEW anmn_nrs_realtime_data_summary_view AS
  SELECT v.site_name AS site_name,
	COUNT(DISTINCT(channel_id)) AS nb_channels,
	sum(CASE WHEN v.qaqc_data = true THEN 1 ELSE 0 END) AS no_qc_data, 
	COALESCE(min(v.sensor_depth) || '-' || max(v.sensor_depth)) AS depth_range, 
	min(v.start_date) AS earliest_date, 
	max(v.end_date) AS latest_date, 
	round(avg(v.coverage_duration), 1) AS mean_coverage_duration,
	min(v.sensor_depth) AS min_depth, 
	max(v.sensor_depth) AS max_depth 
  FROM anmn_nrs_realtime_all_deployments_view v
	WHERE channel_id != 'Not Specified Not Specified'
	GROUP BY v.site_name  
	ORDER BY site_name;

grant all on table anmn_nrs_realtime_data_summary_view to public;

-------------------------------
-- VIEW FOR Argo; Now using what's in the argo schema so don't need the dw_argo schema anymore.
-------------------------------
-- All deployments view
CREATE or replace VIEW argo_all_deployments_view AS
  SELECT m.data_centre AS organisation, 
	CASE WHEN m.oxygen_sensor = false THEN 'No oxygen sensor' 
		ELSE 'Oxygen sensor' END AS oxygen_sensor, 
	m.platform_number AS platform_code, 
	round((m.min_lat)::numeric, 1) AS min_lat, 
	round((m.max_lat)::numeric, 1) AS max_lat, 
	round((m.min_long)::numeric, 1) AS min_lon, 
	round((m.max_long)::numeric, 1) AS max_lon, 
	COALESCE(round((m.min_lat)::numeric, 1) || '/' || round((m.max_lat)::numeric, 1)) AS lat_range, 
	COALESCE(round((m.min_long)::numeric, 1) || '/' || round((m.max_long)::numeric, 1)) AS lon_range, 
	date(m.start_date) AS start_date, 
	date(m.last_measure_date) AS end_date, 
	round((((date_part('day', (m.last_measure_date - m.start_date)))::integer)::numeric / 365.242), 1) AS coverage_duration, 
	m.pi_name
    FROM argo.argo_float m
    ORDER BY organisation, oxygen_sensor, platform_code;

grant all on table argo_all_deployments_view to public;

-- Data summary view
CREATE or replace VIEW argo_data_summary_view AS
  SELECT v.organisation, 
	count(DISTINCT v.platform_code) AS no_platforms, 
	count(CASE WHEN date_part('day', (now() - (v.end_date)::timestamp with time zone)) < 31 THEN 1 ELSE NULL::integer END) AS no_active_floats, 
	count(CASE WHEN v.oxygen_sensor = 'Oxygen sensor' THEN 1 ELSE NULL::integer END) AS no_oxygen_platforms, 
	count(CASE WHEN date_part('day', (now() - (v.end_date)::timestamp with time zone)) < 31 AND v.oxygen_sensor = 'Oxygen sensor' THEN 1 ELSE NULL::integer END) AS no_active_oxygen_platforms, 
	min(v.min_lat) AS min_lat, 
	max(v.max_lat) AS max_lat, 
	min(v.min_lon) AS min_lon, 
	max(v.max_lon) AS max_lon, 
	COALESCE(min(v.min_lat) || '/' || max(v.max_lat)) AS lat_range, 
	COALESCE(min(v.min_lon) || '/' || max(v.max_lon)) AS lon_range, 
	min(v.start_date) AS earliest_date, 
	max(v.end_date) AS latest_date, 
	round(avg(v.coverage_duration), 1) AS mean_coverage_duration 
  FROM argo_all_deployments_view v
	GROUP BY v.organisation 
	ORDER BY organisation;

grant all on table argo_data_summary_view to public;

-------------------------------
-- VIEW FOR AUV; Now using what's in the auv schema so don't need the legacy_auv schema anymore, nor the report.auv_manual table.
-------------------------------
-- All deployments view
CREATE or replace VIEW auv_all_deployments_view AS
  WITH a AS (
  SELECT fk_auv_tracks,
	COUNT(li.pkid) AS no_images
  FROM legacy_auv.auv_images li
	GROUP BY fk_auv_tracks)
  SELECT DISTINCT "substring"((d.campaign_name), '[^0-9]+') AS location, 
	d.campaign_name AS campaign, 
	v.dive_name AS site,
	round(ST_Y(ST_CENTROID(v.geom))::numeric, 1) AS lat_min, 
	round(ST_X(ST_CENTROID(v.geom))::numeric, 1) AS lon_min, 
	v.time_start AS start_date,
	v.time_end AS end_date,
	round((date_part('hours', (v.time_end - v.time_start)) * 60 + (date_part('minutes', (v.time_end - v.time_start))) + (date_part('seconds', (v.time_end - v.time_start)))/60)::numeric, 1) AS coverage_duration,
	a.no_images
  FROM auv.deployments d
  LEFT JOIN auv.auv_trajectory_map v ON v.file_id = d.file_id
  LEFT JOIN legacy_auv.auv_tracks lt ON v.dive_name = lt.site_code
  LEFT JOIN a ON lt.pkid = a.fk_auv_tracks
	ORDER BY location, campaign, site;

grant all on table auv_all_deployments_view to public;

-- Data summary view
CREATE or replace VIEW auv_data_summary_view AS
  SELECT v.location, 
	count(DISTINCT CASE WHEN v.campaign IS NULL THEN '1' ELSE v.campaign END) AS no_campaigns, 
	count(DISTINCT CASE WHEN v.site IS NULL THEN '1' ELSE v.site END) AS no_sites,
	SUM(no_images) AS total_no_images,
	COALESCE(min(v.lat_min) || '/' || max(v.lat_min)) AS lat_range, 
	COALESCE(min(v.lon_min) || '/' || max(v.lon_min)) AS lon_range, 
	min(v.start_date) AS earliest_date, 
	max(v.end_date) AS latest_date, 
	round((sum((v.coverage_duration)::numeric) / 60), 1) AS data_duration, 
	min(v.lat_min) AS lat_min, 
	min(v.lon_min) AS lon_min, 
	max(v.lat_min) AS lat_max, 
	max(v.lon_min) AS lon_max
  FROM auv_all_deployments_view v
	GROUP BY location
	ORDER BY location;

grant all on table auv_data_summary_view to public;

-------------------------------
-- VIEW FOR Facility summary;
-------------------------------
-- All deployments view
CREATE OR REPLACE VIEW facility_summary_view AS 
  SELECT facility.acronym AS facility_acronym,
	COALESCE(to_char(to_timestamp (date_part('month',facility_summary.reporting_date)::text, 'MM') ,'TMMon')||' '||date_part('year',facility_summary.reporting_date)) AS reporting_month,
	facility_summary.summary AS updates, 
	facility_summary_item.name AS issues,
	facility_summary.reporting_date
  FROM report.facility_summary
  FULL JOIN report.facility ON facility_summary.facility_name_id = facility.id
  LEFT JOIN report.facility_summary_item ON facility_summary.summary_item_id = facility_summary_item.row_id
	ORDER BY facility_acronym, reporting_date DESC, issues;

grant all on table facility_summary_view to public;


-------------------------------
-- VIEW FOR FAIMMS; Now using what's in the faimms schema so don't need the legacy_faimms schema anymore, nor the report.faimms_manual table.
-------------------------------
-- All deployments view
CREATE or replace VIEW faimms_all_deployments_view AS
  SELECT DISTINCT m.platform_code AS site_name, 
	m.site_code AS platform_code, 
	COALESCE(m.channel_id || ' - ' || (m."VARNAME")) AS sensor_code, 
	(m."DEPTH")::numeric AS sensor_depth, 
	date(m.time_start) AS start_date, 
	date(m.time_end) AS end_date, 
	round((date_part('days', (m.time_end - m.time_start)) + date_part('hours', (m.time_end - m.time_start))/24)::numeric, 1) AS coverage_duration, 
	f.instrument AS sensor_name, 
	m."VARNAME" AS parameter, 
	m.channel_id AS channel_id,
	round(ST_X(geom)::numeric, 1) AS lon,
	round(ST_Y(geom)::numeric, 1) AS lat
  FROM faimms.faimms_timeseries_map m
  LEFT JOIN faimms.global_attributes_file f ON f.aims_channel_id = m.channel_id
	ORDER BY site_name, platform_code, sensor_code;

grant all on table faimms_all_deployments_view to public;

-- Data summary view
CREATE or replace VIEW faimms_data_summary_view AS
  SELECT v.site_name, 
	count(DISTINCT v.platform_code) AS no_platforms, 
	count(DISTINCT v.sensor_code) AS no_sensors, 
	count(DISTINCT v.parameter) AS no_parameters,
	min(v.lon) AS lon, 
	min(v.lat) AS lat, 
	COALESCE(min(v.sensor_depth) || '-' || max(v.sensor_depth)) AS depth_range,
	min(v.start_date) AS earliest_date, 
	max(v.end_date) AS latest_date, 
	round(avg(v.coverage_duration), 1) AS mean_coverage_duration,
	min(v.sensor_depth) AS min_depth, 
	max(v.sensor_depth) AS max_depth
  FROM faimms_all_deployments_view v
	GROUP BY site_name 
	ORDER BY site_name;

grant all on table faimms_data_summary_view to public;

-------------------------------
-- VIEW FOR SOOP-CPR; Waiting for the new so_cpr harvester...
-------------------------------
-- All deployments view
CREATE or replace VIEW soop_cpr_all_deployments_view AS
  WITH phyto AS (
	SELECT DISTINCT p."TIME", 
	count(DISTINCT p."TIME") AS no_phyto_samples 
  FROM soop_auscpr.soop_auscpr_phyto_trajectory_map p
	GROUP BY p."TIME" 
	ORDER BY "TIME"), 
	
	zoop AS (
	SELECT DISTINCT z."TIME", 
	count(DISTINCT z."TIME") AS no_zoop_samples 
  FROM soop_auscpr.soop_auscpr_zoop_trajectory_map z
	GROUP BY z."TIME" 
	ORDER BY "TIME"), 

	pci AS (
	SELECT DISTINCT pci.vessel_name, 
	CASE WHEN pci.start_port < pci.end_port THEN (pci.start_port || '-' || pci.end_port) 
		ELSE (pci.end_port || '-' || pci.start_port) END AS route, 
	pci."TIME", 
	count(DISTINCT pci."TIME") AS no_pci_samples 
  FROM soop_auscpr.soop_auscpr_pci_trajectory_map pci
	GROUP BY vessel_name, route, "TIME" 
	ORDER BY vessel_name, route , "TIME") 

  SELECT 'CPR AUS' AS subfacility,
	COALESCE(CASE WHEN pci.vessel_name = 'Aurora Australia' THEN 'Aurora Australis' ELSE pci.vessel_name END || ' | ' || pci.route) AS vessel_route,
	CASE WHEN pci.vessel_name = 'Aurora Australia' THEN 'Aurora Australis' ELSE pci.vessel_name::character varying END AS vessel_name, 
	pci.route, 
	cp.trip_code::character varying AS deployment_id, 
	sum(pci.no_pci_samples) AS no_pci_samples, 
	CASE WHEN sum(phyto.no_phyto_samples) IS NULL THEN 0 ELSE sum(phyto.no_phyto_samples) END AS no_phyto_samples, 
	CASE WHEN sum(zoop.no_zoop_samples) IS NULL THEN 0 ELSE sum(zoop.no_zoop_samples) END AS no_zoop_samples, 
	COALESCE(round(min(cp.latitude)::numeric, 1) || '/' || round(max(cp.latitude)::numeric, 1)) AS lat_range, 
	COALESCE(round(min(cp.longitude)::numeric, 1) || '/' || round(max(cp.longitude)::numeric, 1)) AS lon_range,
	date(min(cp."TIME")) AS start_date, 
	date(max(cp."TIME")) AS end_date, 
	round(((date_part('day', (max(cp."TIME") - min(cp."TIME"))))::numeric + ((date_part('hours', (max(cp."TIME") - min(cp."TIME"))))::numeric / (24)::numeric)), 1) AS coverage_duration,
	round(min(cp.latitude)::numeric, 1) AS min_lat, 
	round(max(cp.latitude)::numeric, 1) AS max_lat, 
	round(min(cp.longitude)::numeric, 1) AS min_lon, 
	round(max(cp.longitude)::numeric, 1) AS max_lon
  FROM pci 
  FULL JOIN phyto ON pci."TIME" = phyto."TIME"
  FULL JOIN zoop ON pci."TIME" = zoop."TIME"
  FULL JOIN soop_auscpr.soop_auscpr_pci_trajectory_map cp ON pci."TIME" = cp."TIME"
	WHERE pci.vessel_name IS NOT NULL
	GROUP BY subfacility, pci.vessel_name, pci.route, cp.trip_code 

UNION ALL 

  SELECT 'CPR SO' AS subfacility, 
	COALESCE(CASE WHEN so.ship_code = 'AA' THEN 'Aurora Australis'
	     WHEN so.ship_code = 'AF' THEN 'Akademik Federov'
	     WHEN so.ship_code = 'HM' THEN 'Hakuho Maru'
	     WHEN so.ship_code = 'KM' THEN 'Kaiyo Maru'
	     WHEN so.ship_code = 'PS' THEN 'Polarstern'
	     WHEN so.ship_code = 'SA' THEN 'San Aotea II'
	     WHEN so.ship_code = 'SH' THEN 'Shirase'
	     WHEN so.ship_code = 'SH2' THEN 'Shirase2'
	     WHEN so.ship_code = 'TA' THEN 'Tangaroa'
	     WHEN so.ship_code = 'UM' THEN 'Umitaka Maru'
	     WHEN so.ship_code = 'YU' THEN 'Yuzhmorgeologiya'
	END || ' | ' || 'Southern Ocean') AS vessel_route,
	CASE WHEN so.ship_code = 'AA' THEN 'Aurora Australis'
	     WHEN so.ship_code = 'AF' THEN 'Akademik Federov'
	     WHEN so.ship_code = 'HM' THEN 'Hakuho Maru'
	     WHEN so.ship_code = 'KM' THEN 'Kaiyo Maru'
	     WHEN so.ship_code = 'PS' THEN 'Polarstern'
	     WHEN so.ship_code = 'SA' THEN 'San Aotea II'
	     WHEN so.ship_code = 'SH' THEN 'Shirase'
	     WHEN so.ship_code = 'SH2' THEN 'Shirase2'
	     WHEN so.ship_code = 'TA' THEN 'Tangaroa'
	     WHEN so.ship_code = 'UM' THEN 'Umitaka Maru'
	     WHEN so.ship_code = 'YU' THEN 'Yuzhmorgeologiya'
	END AS vessel_name, 
	NULL::text AS route, 
	COALESCE(so.ship_code || '-' || so.tow_number) AS deployment_id, 
	sum(CASE WHEN so.pci IS NULL THEN 0 ELSE 1 END) AS no_pci_samples, 
	NULL::numeric AS no_phyto_samples, 
	count(so.total_abundance) AS no_zoop_samples, 
	COALESCE(ROUND(min(ST_Y("position"))::numeric, 1) || '/' || ROUND(max(ST_Y("position"))::numeric, 1)) AS lat_range, 
	COALESCE(ROUND(min(ST_X("position"))::numeric, 1) || '/' || ROUND(max(ST_X("position"))::numeric, 1)) AS lon_range,
	date(min(so.date_time)) AS start_date, 
	date(max(so.date_time)) AS end_date, 
	round(((date_part('day', (max(so.date_time) - min(so.date_time))))::numeric + ((date_part('hours', (max(so.date_time) - min(so.date_time))))::numeric / (24)::numeric)), 1) AS coverage_duration,
	ROUND(min(ST_Y("position"))::numeric, 1) AS min_lat, 
	ROUND(max(ST_Y("position"))::numeric, 1) AS max_lat, 
	ROUND(min(ST_X("position"))::numeric, 1) AS min_lon, 
	ROUND(max(ST_X("position"))::numeric, 1) AS max_lon 
  FROM legacy_cpr.so_segment so
	GROUP BY subfacility, ship_code, tow_number 
	ORDER BY subfacility, vessel_name, route, start_date, deployment_id;

grant all on table soop_cpr_all_deployments_view to public;

-------------------------------
-- VIEW FOR SOOP; Now using what's in the soop schema so don't need the dw_soop schema anymore, nor any report.manual tables.
------------------------------- 
-- All deployments view
CREATE or replace VIEW soop_all_deployments_view AS
WITH a AS (SELECT file_id, COUNT(measurement) AS nb_measurements FROM soop_asf_mft.soop_asf_mft_trajectory_data GROUP BY file_id),
b AS (SELECT file_id, COUNT(measurement) AS nb_measurements FROM soop_asf_mt.soop_asf_mt_trajectory_data GROUP BY file_id),
c AS (SELECT file_id, COUNT(measurement) AS nb_measurements FROM soop_ba.measurements GROUP BY file_id),
e AS (SELECT file_id, COUNT(measurement) AS nb_measurements FROM soop_co2.soop_co2_trajectory_data GROUP BY file_id),
f AS (SELECT trajectory_id, COUNT(measurement_id) AS nb_measurements FROM soop_sst.soop_sst_nrt_trajectory_data GROUP BY trajectory_id),
g AS (SELECT trajectory_id, COUNT(measurement_id) AS nb_measurements FROM soop_sst.soop_sst_dm_trajectory_data GROUP BY trajectory_id),
h AS (SELECT trajectory_id, COUNT(measurement_id) AS nb_measurements FROM soop_tmv_nrt.soop_tmv_nrt_trajectory_data GROUP BY trajectory_id),
i AS (SELECT file_id, COUNT(measurement) AS nb_measurements FROM soop_tmv.soop_tmv_trajectory_data GROUP BY file_id),
j AS (SELECT trip_id, COUNT(measurement) AS nb_measurements FROM soop_trv.measurements_merged_data GROUP BY trip_id)
  SELECT 'ASF Flux product' AS subfacility,
  m.vessel_name,
  m.cruise_id AS deployment_id,
  date_part('year',min(time_start)) AS year,
  COUNT(m.file_id) AS no_files_profiles,
  SUM(nb_measurements) AS no_measurements,
  COALESCE(round(min(ST_YMIN(m.geom))::numeric, 1) || '/' || round(max(ST_YMAX(m.geom))::numeric, 1)) AS lat_range, 
  COALESCE(round(min(ST_XMIN(m.geom))::numeric, 1) || '/' || round(max(ST_XMAX(m.geom))::numeric, 1)) AS lon_range,
  date(min(time_start)) AS start_date, 
  date(max(time_end)) AS end_date,
  round((date_part('days',max(time_end) - min(time_start)) + date_part('hours',max(time_end) - min(time_start))/24)::numeric, 1) AS coverage_duration,
  round(min(ST_YMIN(m.geom))::numeric, 1) AS min_lat, 
  round(max(ST_YMAX(m.geom))::numeric, 1) AS max_lat, 
  round(min(ST_XMIN(m.geom))::numeric, 1) AS min_lon, 
  round(max(ST_XMAX(m.geom))::numeric, 1) AS max_lon
  FROM soop_asf_mft.soop_asf_mft_trajectory_map m
  JOIN a ON a.file_id = m.file_id
    GROUP BY subfacility, m.vessel_name, m.cruise_id
    
UNION ALL

  SELECT 'ASF Meteorological SST observations' AS subfacility,
  vessel_name,
  cruise_id AS deployment_id,
  date_part('year',min(time_start)) AS year,
  COUNT(m.file_id) AS no_files_profiles,
  SUM(nb_measurements) AS no_measurements,
  COALESCE(round(min(ST_YMIN(geom))::numeric, 1) || '/' || round(max(ST_YMAX(geom))::numeric, 1)) AS lat_range, 
  COALESCE(round(min(ST_XMIN(geom))::numeric, 1) || '/' || round(max(ST_XMAX(geom))::numeric, 1)) AS lon_range,
  date(min(time_start)) AS start_date, 
  date(max(time_end)) AS end_date,
  round((date_part('days',max(time_end) - min(time_start)) + date_part('hours',max(time_end) - min(time_start))/24)::numeric, 1) AS coverage_duration,
  round(min(ST_YMIN(geom))::numeric, 1) AS min_lat, 
  round(max(ST_YMAX(geom))::numeric, 1) AS max_lat, 
  round(min(ST_XMIN(geom))::numeric, 1) AS min_lon, 
  round(max(ST_XMAX(geom))::numeric, 1) AS max_lon
  FROM soop_asf_mt.soop_asf_mt_trajectory_map m
  JOIN b ON b.file_id = m.file_id
    GROUP BY subfacility, vessel_name, cruise_id

UNION ALL

  SELECT 'BA' AS subfacility,
  m.vessel_name,
  d.voyage_id AS deployment_id,
  date_part('year',min(time_start)) AS year,
  COUNT(m.file_id) AS no_files_profiles,
  SUM(nb_measurements) AS no_measurements,
  COALESCE(round(min(ST_YMIN(geom))::numeric, 1) || '/' || round(max(ST_YMAX(geom))::numeric, 1)) AS lat_range, 
  COALESCE(round(min(ST_XMIN(geom))::numeric, 1) || '/' || round(max(ST_XMAX(geom))::numeric, 1)) AS lon_range,
  date(min(time_start)) AS start_date, 
  date(max(time_end)) AS end_date,
  round((date_part('days',max(time_end) - min(time_start)) + date_part('hours',max(time_end) - min(time_start))/24)::numeric, 1) AS coverage_duration,
  round(min(ST_YMIN(geom))::numeric, 1) AS min_lat, 
  round(max(ST_YMAX(geom))::numeric, 1) AS max_lat, 
  round(min(ST_XMIN(geom))::numeric, 1) AS min_lon, 
  round(max(ST_XMAX(geom))::numeric, 1) AS max_lon
  FROM soop_ba.soop_ba_trajectory_map m
  JOIN soop_ba.deployments d ON d.file_id = m.file_id
  JOIN c ON c.file_id = m.file_id
    GROUP BY subfacility, m.vessel_name, d.voyage_id

UNION ALL

  SELECT 'CO2' AS subfacility,
  vessel_name,
  cruise_id AS deployment_id,
  date_part('year',min(time_start)) AS year,
  COUNT(m.file_id) AS no_files_profiles,
  SUM(nb_measurements) AS no_measurements,
  COALESCE(round(min(ST_YMIN(geom))::numeric, 1) || '/' || round(max(ST_YMAX(geom))::numeric, 1)) AS lat_range, 
  COALESCE(round(min(ST_XMIN(geom))::numeric, 1) || '/' || round(max(ST_XMAX(geom))::numeric, 1)) AS lon_range,
  date(min(time_start)) AS start_date, 
  date(max(time_end)) AS end_date,
  round((date_part('days',max(time_end) - min(time_start)) + date_part('hours',max(time_end) - min(time_start))/24)::numeric, 1) AS coverage_duration,
  round(min(ST_YMIN(geom))::numeric, 1) AS min_lat, 
  round(max(ST_YMAX(geom))::numeric, 1) AS max_lat, 
  round(min(ST_XMIN(geom))::numeric, 1) AS min_lon, 
  round(max(ST_XMAX(geom))::numeric, 1) AS max_lon
  FROM soop_co2.soop_co2_trajectory_map m
  JOIN e ON e.file_id = m.file_id
    GROUP BY subfacility, vessel_name, cruise_id

UNION ALL 

  SELECT 'SST Near real-time' AS subfacility,
  vessel_name,
  voyage_number AS deployment_id,
  date_part('year',min(time_start)) AS year,
  COUNT(m.trajectory_id) AS no_files_profiles,
  SUM(nb_measurements) AS no_measurements,
  COALESCE(round(min(ST_YMIN(geom))::numeric, 1) || '/' || round(max(ST_YMAX(geom))::numeric, 1)) AS lat_range, 
  COALESCE(round(min(ST_XMIN(geom))::numeric, 1) || '/' || round(max(ST_XMAX(geom))::numeric, 1)) AS lon_range,
  date(min(time_start)) AS start_date, 
  date(max(time_end)) AS end_date,
  round((date_part('days',max(time_end) - min(time_start)) + date_part('hours',max(time_end) - min(time_start))/24)::numeric, 1) AS coverage_duration,
  round(min(ST_YMIN(geom))::numeric, 1) AS min_lat, 
  round(max(ST_YMAX(geom))::numeric, 1) AS max_lat, 
  round(min(ST_XMIN(geom))::numeric, 1) AS min_lon, 
  round(max(ST_XMAX(geom))::numeric, 1) AS max_lon
  FROM soop_sst.soop_sst_nrt_trajectory_map m
  JOIN f ON f.trajectory_id = m.trajectory_id
    GROUP BY subfacility, vessel_name, voyage_number

UNION ALL 

  SELECT 'SST Delayed-mode' AS subfacility,
  vessel_name,
  voyage_number AS deployment_id,
  date_part('year',min(time_start)) AS year,
  COUNT(m.trajectory_id) AS no_files_profiles,
  SUM(nb_measurements) AS no_measurements,
  COALESCE(round(min(ST_YMIN(geom))::numeric, 1) || '/' || round(max(ST_YMAX(geom))::numeric, 1)) AS lat_range, 
  COALESCE(round(min(ST_XMIN(geom))::numeric, 1) || '/' || round(max(ST_XMAX(geom))::numeric, 1)) AS lon_range,
  date(min(time_start)) AS start_date, 
  date(max(time_end)) AS end_date,
  round((date_part('days',max(time_end) - min(time_start)) + date_part('hours',max(time_end) - min(time_start))/24)::numeric, 1) AS coverage_duration,
  round(min(ST_YMIN(geom))::numeric, 1) AS min_lat, 
  round(max(ST_YMAX(geom))::numeric, 1) AS max_lat, 
  round(min(ST_XMIN(geom))::numeric, 1) AS min_lon, 
  round(max(ST_XMAX(geom))::numeric, 1) AS max_lon
  FROM soop_sst.soop_sst_dm_trajectory_map m
  JOIN g ON g.trajectory_id = m.trajectory_id
    GROUP BY subfacility, vessel_name, voyage_number

UNION ALL 

  SELECT 'TMV Near real-time' AS subfacility,
  'Spirit of Tasmania 1' AS vessel_name,
  NULL AS deployment_id,
  date_part('year',time_start) AS year,
  COUNT(m.file_id) AS no_files_profiles,
  SUM(nb_measurements) AS no_measurements,
  COALESCE(round(min(ST_YMIN(geom))::numeric, 1) || '/' || round(max(ST_YMAX(geom))::numeric, 1)) AS lat_range, 
  COALESCE(round(min(ST_XMIN(geom))::numeric, 1) || '/' || round(max(ST_XMAX(geom))::numeric, 1)) AS lon_range,
  date(min(time_start)) AS start_date, 
  date(max(time_end)) AS end_date,
  round((date_part('days',max(time_end) - min(time_start)) + date_part('hours',max(time_end) - min(time_start))/24)::numeric, 1) AS coverage_duration,
  round(min(ST_YMIN(geom))::numeric, 1) AS min_lat, 
  round(max(ST_YMAX(geom))::numeric, 1) AS max_lat, 
  round(min(ST_XMIN(geom))::numeric, 1) AS min_lon, 
  round(max(ST_XMAX(geom))::numeric, 1) AS max_lon
  FROM soop_tmv_nrt.soop_tmv_nrt_trajectory_map m
  JOIN h ON h.trajectory_id = m.file_id
    GROUP BY subfacility, vessel_name, year

UNION ALL 

  SELECT 'TMV Delayed-mode' AS subfacility,
  vessel_name,
  NULL AS deployment_id,
  date_part('year',time_start) AS year,
  COUNT(m.file_id) AS no_files_profiles,
  SUM(nb_measurements) AS no_measurements,
  COALESCE(round(min(ST_YMIN(geom))::numeric, 1) || '/' || round(max(ST_YMAX(geom))::numeric, 1)) AS lat_range, 
  COALESCE(round(min(ST_XMIN(geom))::numeric, 1) || '/' || round(max(ST_XMAX(geom))::numeric, 1)) AS lon_range,
  date(min(time_start)) AS start_date, 
  date(max(time_end)) AS end_date,
  round((date_part('days',max(time_end) - min(time_start)) + date_part('hours',max(time_end) - min(time_start))/24)::numeric, 1) AS coverage_duration,
  round(min(ST_YMIN(geom))::numeric, 1) AS min_lat, 
  round(max(ST_YMAX(geom))::numeric, 1) AS max_lat, 
  round(min(ST_XMIN(geom))::numeric, 1) AS min_lon, 
  round(max(ST_XMAX(geom))::numeric, 1) AS max_lon
  FROM soop_tmv.soop_tmv_trajectory_map m
  JOIN i ON i.file_id = m.file_id
    GROUP BY subfacility, vessel_name, year

UNION ALL 

  SELECT 'TRV' AS subfacility,
  m.vessel_name,
  m.trip_id::character varying AS deployment_id,
  date_part('year',min(time_start)) AS year,
  COUNT(file_id) AS no_files_profiles,
  SUM(nb_measurements) AS no_measurements,
  COALESCE(round(min(ST_YMIN(geom))::numeric, 1) || '/' || round(max(ST_YMAX(geom))::numeric, 1)) AS lat_range, 
  COALESCE(round(min(ST_XMIN(geom))::numeric, 1) || '/' || round(max(ST_XMAX(geom))::numeric, 1)) AS lon_range,
  date(min(time_start)) AS start_date, 
  date(max(time_end)) AS end_date,
  round((date_part('days',max(time_end) - min(time_start)) + date_part('hours',max(time_end) - min(time_start))/24)::numeric, 1) AS coverage_duration,
  round(min(ST_YMIN(geom))::numeric, 1) AS min_lat, 
  round(max(ST_YMAX(geom))::numeric, 1) AS max_lat, 
  round(min(ST_XMIN(geom))::numeric, 1) AS min_lon, 
  round(max(ST_XMAX(geom))::numeric, 1) AS max_lon
  FROM soop_trv.soop_trv_trajectory_map m
  LEFT JOIN soop_trv.deployments d ON m.trip_id = d.trip_id
  JOIN j ON j.trip_id = m.trip_id
    GROUP BY subfacility, m.vessel_name, m.trip_id

UNION ALL 

  SELECT 'XBT Near real-time' AS subfacility,
  COALESCE("XBT_line" || ' | ' || vessel_name) AS vessel_name,
  NULL AS deployment_id,
  date_part('year',"TIME") AS year,
  COUNT(profile_id) AS no_files_profiles,
  SUM(nb_measurements) AS no_measurements,
  COALESCE(round(min(ST_YMIN(geom))::numeric, 1) || '/' || round(max(ST_YMAX(geom))::numeric, 1)) AS lat_range, 
  COALESCE(round(min(ST_XMIN(geom))::numeric, 1) || '/' || round(max(ST_XMAX(geom))::numeric, 1)) AS lon_range,
  date(min("TIME")) AS start_date, 
  date(max("TIME")) AS end_date,
  round((date_part('days',max("TIME") - min("TIME")) + date_part('hours',max("TIME") - min("TIME"))/24)::numeric, 1) AS coverage_duration,
  round(min(ST_YMIN(geom))::numeric, 1) AS min_lat, 
  round(max(ST_YMAX(geom))::numeric, 1) AS max_lat, 
  round(min(ST_XMIN(geom))::numeric, 1) AS min_lon, 
  round(max(ST_XMAX(geom))::numeric, 1) AS max_lon
  FROM soop_xbt_nrt.soop_xbt_nrt_profiles_map
    GROUP BY subfacility, "XBT_line",vessel_name, year

UNION ALL 

  SELECT 'XBT Delayed-mode' AS subfacility,
	COALESCE(m."XBT_line" || ' | ' || "XBT_line_description") AS vessel_name,
	NULL AS deployment_id,
	date_part('year',m."TIME") AS year,
	COUNT(m.profile_id) AS no_files_profiles,
	SUM(nb_measurements) AS no_measurements,
	COALESCE(round(min(ST_YMIN(m.geom))::numeric, 1) || '/' || round(max(ST_YMAX(m.geom))::numeric, 1)) AS lat_range, 
	COALESCE(round(min(ST_XMIN(m.geom))::numeric, 1) || '/' || round(max(ST_XMAX(m.geom))::numeric, 1)) AS lon_range,
	date(min(m."TIME")) AS start_date, 
	date(max(m."TIME")) AS end_date,
	round((date_part('days',max("TIME") - min("TIME")) + date_part('hours',max("TIME") - min("TIME"))/24)::numeric, 1) AS coverage_duration,
	round(min(ST_YMIN(m.geom))::numeric, 1) AS min_lat, 
	round(max(ST_YMAX(m.geom))::numeric, 1) AS max_lat, 
	round(min(ST_XMIN(m.geom))::numeric, 1) AS min_lon, 
	round(max(ST_XMAX(m.geom))::numeric, 1) AS max_lon
  FROM soop_xbt_dm.soop_xbt_dm_profile_map m
  	GROUP BY subfacility, "XBT_line", "XBT_line_description",year
	ORDER BY subfacility, vessel_name, deployment_id, year;

grant all on table soop_all_deployments_view to public;

-- Data summary view	
CREATE or replace VIEW soop_data_summary_view AS
 SELECT 
	substring(vw.subfacility, '[a-zA-Z0-9]+') AS subfacility,
	CASE WHEN substring(vw.subfacility, '[^ ]* (.*)') IS NULL THEN 'Delayed-mode' ELSE substring(vw.subfacility, '[^ ]* (.*)') END AS data_type,
	vw.vessel_name, 
	count(CASE WHEN vw.deployment_id IS NULL THEN '1'::character varying ELSE vw.deployment_id END) AS no_deployments, 
	sum(CASE WHEN vw.no_files_profiles IS NULL THEN (1)::bigint ELSE vw.no_files_profiles END) AS no_files_profiles,
	SUM(no_measurements) AS total_no_measurements,
	COALESCE(round(min(vw.min_lat), 1) || '/' || round(max(vw.max_lat), 1)) AS lat_range, 
	COALESCE(round(min(vw.min_lon), 1) || '/' || round(max(vw.max_lon), 1)) AS lon_range,
	min(vw.start_date) AS earliest_date, 
	max(vw.end_date) AS latest_date, 
	sum(vw.coverage_duration) AS coverage_duration,
	round(min(vw.min_lat), 1) AS min_lat, 
	round(max(vw.max_lat), 1) AS max_lat, 
	round(min(vw.min_lon), 1) AS min_lon, 
	round(max(vw.max_lon), 1) AS max_lon
  FROM soop_all_deployments_view vw 
	GROUP BY subfacility, data_type, vessel_name 

UNION ALL 

  SELECT 
	substring(cpr_vw.subfacility, '[a-zA-Z0-9]+') AS subfacility,
	substring(cpr_vw.subfacility, '[^ ]* (.*)') AS data_type,
	cpr_vw.vessel_name, 
	count(cpr_vw.vessel_name) AS no_deployments, 
	CASE WHEN sum(CASE WHEN cpr_vw.no_phyto_samples IS NULL THEN 0 ELSE 1 END) <> count(cpr_vw.vessel_name) THEN sum(cpr_vw.no_pci_samples + cpr_vw.no_zoop_samples) 
	ELSE sum((cpr_vw.no_pci_samples + cpr_vw.no_phyto_samples) + cpr_vw.no_zoop_samples) END AS no_files_profiles, 
	NULL AS total_no_measurements,
	COALESCE(round(min(cpr_vw.min_lat), 1) || '/' || round(max(cpr_vw.max_lat), 1)) AS lat_range, 
	COALESCE(round(min(cpr_vw.min_lon), 1) || '/' || round(max(cpr_vw.max_lon), 1)) AS lon_range, 
	min(cpr_vw.start_date) AS earliest_date, 
	max(cpr_vw.end_date) AS latest_date, 
	sum(cpr_vw.coverage_duration) AS coverage_duration, 
	round(min(cpr_vw.min_lat), 1) AS min_lat, 
	round(max(cpr_vw.max_lat), 1) AS max_lat, 
	round(min(cpr_vw.min_lon), 1) AS min_lon, 
	round(max(cpr_vw.max_lon), 1) AS max_lon
  FROM soop_cpr_all_deployments_view cpr_vw
	GROUP BY subfacility, data_type, vessel_name 
	ORDER BY subfacility, data_type, vessel_name;

grant all on table soop_data_summary_view to public;

-------------------------------
-- VIEW FOR SRS; Now using what's in the srs_altimetry, srs_oc_bodbaw, and srs_oc_soop_rad schema so don't need the dw_srs and srs schema anymore. Also don't need report.srs_altimetry_manual & report.srs_bio_optical_db_manual tables
-------------------------------
-- All deployments view
CREATE or replace VIEW srs_all_deployments_view AS
  SELECT 'SRS - Altimetry' AS subfacility, 
	m.site_name AS parameter_site, 
	COALESCE(d.site_code || '-' || "substring"((d.instrument), '([^_]+)-')) AS deployment_code, 
	m.instrument AS sensor_name,
	date(m.time_start) AS start_date, 
	date(m.time_end) AS end_date, 
	round((date_part('days', (m.time_end - m.time_start)) + date_part('hours', (m.time_end - m.time_start))/24)::numeric, 1) AS coverage_duration, 
	round((ST_Y(m.geom))::numeric, 1) AS lat, 
	round((ST_X(m.geom))::numeric, 1) AS lon 
  FROM srs_altimetry.srs_altimetry_timeseries_map m 
  LEFT JOIN srs_altimetry.deployments d ON d.file_id = m.file_id

UNION ALL 

  SELECT 'SRS - BioOptical database' AS subfacility, 
	m.data_type AS parameter_site, 
	m.cruise_id AS deployment_code, 
	m.vessel_name AS sensor_name, 
	date(m.time_start) AS start_date, 
	date(m.time_end) AS end_date, 
	round((date_part('days', (m.time_end - m.time_start)) + date_part('hours', (m.time_end - m.time_start))/24)::numeric, 1) AS coverage_duration, 
	round(ST_Y(ST_CENTROID(m.geom))::numeric, 1) AS lat, 
	round(ST_X(ST_CENTROID(m.geom))::numeric, 1) AS lon 
  FROM srs_oc_bodbaw.srs_oc_bodbaw_trajectory_profile_map m 

UNION ALL 

  SELECT 'SRS - Gridded Products' AS subfacility, 
	CASE WHEN ((srs_gridded_products_manual.product_name) = 'MODIS Aqua OC3 Chlorophyll-a') THEN 'Chlorophyll-a' 
	WHEN ((srs_gridded_products_manual.product_name) = 'SST L3C') THEN 'SST' 
	WHEN ((srs_gridded_products_manual.product_name) = 'SST L3P - 14 days mosaic') THEN 'SST' 
	ELSE NULL END AS parameter_site, 
	CASE WHEN ((srs_gridded_products_manual.product_name) = 'MODIS Aqua OC3 Chlorophyll-a') THEN 'MODIS Aqua OC3' 
	WHEN ((srs_gridded_products_manual.product_name) = 'SST L3C') THEN 'L3C' 
	WHEN ((srs_gridded_products_manual.product_name) = 'SST L3P - 14 days mosaic') THEN 'L3P - 14 days mosaic' 
	ELSE NULL END AS deployment_code, 
	NULL::character varying AS sensor_name, 
	date(srs_gridded_products_manual.deployment_start) AS start_date, 
	CASE WHEN date(srs_gridded_products_manual.deployment_end) IS NULL THEN date(now()) END AS end_date, 
	round((date_part('days', CASE WHEN srs_gridded_products_manual.deployment_end IS NULL THEN now() END - srs_gridded_products_manual.deployment_start) + 
	date_part('hours', CASE WHEN srs_gridded_products_manual.deployment_end IS NULL THEN now() END - srs_gridded_products_manual.deployment_start)/24)::numeric, 1) AS coverage_duration, 
	NULL::numeric AS lat, 
	NULL::numeric AS lon 
  FROM report.srs_gridded_products_manual 

UNION ALL 

  SELECT 'SRS - Ocean Colour' AS subfacility, 
	m.vessel_name AS parameter_site, 
	m.voyage_id AS deployment_code, 
	NULL::character varying AS sensor_name, 
	min(date(m.time_start)) AS start_date,
	max(date(m.time_end)) AS end_date, 
	round((date_part('days',max(m.time_end) - min(m.time_start)) + date_part('hours',max(m.time_end) - min(m.time_start))/24)::numeric, 1) AS coverage_duration, 
	round(AVG(ST_Y(ST_CENTROID(m.geom)))::numeric, 1) AS lat, 
	round(AVG(ST_X(ST_CENTROID(m.geom)))::numeric, 1) AS lon 
  FROM srs_oc_soop_rad.visualisation_wms m
	GROUP BY parameter_site, voyage_id 
	ORDER BY subfacility, parameter_site, deployment_code, sensor_name, start_date, end_date;

grant all on table srs_all_deployments_view to public;

-- Data summary view
CREATE or replace VIEW srs_data_summary_view AS
 SELECT v.subfacility, 
	CASE WHEN (v.parameter_site = 'absorption') THEN 'Absorption' 
		WHEN (v.parameter_site = 'pigment') THEN 'Pigment' 
		ELSE v.parameter_site END AS parameter_site, 
	count(v.deployment_code) AS no_deployments, 
	count(DISTINCT v.sensor_name) AS no_sensors, 
	min(v.start_date) AS earliest_date, 
	max(v.end_date) AS latest_date, 
	round(avg(v.coverage_duration), 1) AS mean_coverage_duration, 
	min(v.lon) AS min_lon, 
	max(v.lon) AS max_lon, 
	min(v.lat) AS min_lat, 
	max(v.lat) AS max_lat
  FROM srs_all_deployments_view v
	GROUP BY subfacility, parameter_site 
	ORDER BY subfacility, parameter_site;

grant all on table srs_data_summary_view to public;

-------------------------------
-- TOTALS VIEW
-------------------------------
CREATE or replace view totals_view AS
  WITH interm_table AS (
  SELECT COUNT(DISTINCT(parameter)) AS no_parameters
  FROM faimms_all_deployments_view),
  aatams_acoustic_table AS (
  SELECT (SELECT statistics FROM dw_aatams_acoustic.aatams_acoustictag_totals_species_view WHERE statistics_type = 'no_species') AS no_species,
(SELECT statistics FROM dw_aatams_acoustic.aatams_acoustictag_totals_species_view WHERE statistics_type = 'no_species_detected') AS no_species_detected,
(SELECT statistics FROM dw_aatams_acoustic.aatams_acoustictag_totals_species_view WHERE statistics_type = 'no_releases') AS no_releases,
(SELECT statistics FROM dw_aatams_acoustic.aatams_acoustictag_totals_species_view WHERE statistics_type = 'no_detections') AS no_detections,
(SELECT statistics FROM dw_aatams_acoustic.aatams_acoustictag_totals_species_view WHERE statistics_type = 'no_unique_tag_ids_detected') AS no_unique_tag_ids_detected,
(SELECT statistics FROM dw_aatams_acoustic.aatams_acoustictag_totals_species_view WHERE statistics_type = 'tag_aatams_knows_about') AS tag_aatams_knows_about,
(SELECT statistics FROM dw_aatams_acoustic.aatams_acoustictag_totals_species_view WHERE statistics_type = 'no_detected_tags_aatams_knows_about') AS no_detected_tags_aatams_knows_about,
(SELECT statistics FROM dw_aatams_acoustic.aatams_acoustictag_totals_species_view WHERE statistics_type = 'tags_detected_by_species') AS tags_detected_by_species)
-- AATAMS - Acoustic
  SELECT 'AATAMS' AS facility,
    'Acoustic tagging' AS subfacility,
    funding_type::text AS type,
    no_projects::bigint AS no_projects,
    no_installations::numeric AS no_platforms,
    no_stations::numeric AS no_instruments,
    no_deployments::numeric AS no_deployments,
    no_detections::numeric AS no_data,
    NULL AS no_data2,
    NULL::bigint AS no_data3,
    NULL::bigint AS no_data4,
    NULL AS temporal_range,
    NULL AS lat_range,
    NULL AS lon_range,
    NULL AS depth_range
  FROM dw_aatams_acoustic.aatams_acoustictag_totals_project_view
    
UNION ALL

  SELECT 'AATAMS' AS facility,
    'Acoustic tagging' AS subfacility,
    'Species' AS type,
    no_species::bigint AS no_projects,
    no_species_detected::numeric AS no_platforms,
    tags_detected_by_species::numeric AS no_instruments,
    no_releases::numeric AS no_deployments,
    no_detections::numeric AS no_data,
    no_unique_tag_ids_detected::numeric AS no_data2,
    tag_aatams_knows_about::bigint AS no_data3,
    no_detected_tags_aatams_knows_about::bigint AS no_data4,
    NULL AS temporal_range,
    NULL AS lat_range,
    NULL AS lon_range,
    NULL AS depth_range
  FROM aatams_acoustic_table

-- AATAMS - Satellite tagging
UNION ALL  

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
  FROM report_test.aatams_sattag_data_summary_view
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
  FROM report_test.aatams_sattag_all_deployments_view

-- AATAMS - Biologging
UNION ALL  

  SELECT 'AATAMS' AS facility,
    'Biologging' AS subfacility,
    tagged_animals AS type,
    NULL AS no_projects,
    nb_animals AS no_platforms,
    NULL AS no_instruments,
    NULL AS no_deployments,
    total_nb_measurements AS no_data,
    NULL AS no_data2,
    NULL::bigint AS no_data3,
    NULL::bigint AS no_data4,
    COALESCE(to_char(date(earliest_date),'DD/MM/YYYY')||' - '||to_char(date(latest_date),'DD/MM/YYYY')) AS temporal_range,
    COALESCE(min_lat||' - '||max_lat) AS lat_range,
    COALESCE(min_lon||' - '||max_lon) AS lon_range,
    NULL AS depth_range
  FROM aatams_biologging_data_summary_view
    
-- ABOS
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

-- ACORN
UNION ALL

SELECT 'ACORN' AS facility,
NULL AS subfacility,
data_type AS type,
COUNT(DISTINCT(site)) AS no_projects,
NULL AS no_platforms,
NULL::bigint AS no_instruments,
NULL::bigint AS no_deployments,
SUM(total_no_files) AS no_data,
round(((max(time_end)-min(time_start))/365.25)::numeric, 1) AS no_data2,
NULL::bigint AS no_data3,
NULL::bigint AS no_data4,
COALESCE(to_char(min(time_start),'DD/MM/YYYY')||' - '||to_char(max(time_end),'DD/MM/YYYY')) AS temporal_range,
NULL AS lat_range,
NULL AS lon_range,
NULL AS depth_range
FROM acorn_data_summary_view
GROUP BY data_type

UNION ALL

SELECT 'ACORN' AS facility,
NULL AS subfacility,
'TOTAL' AS type,
COUNT(DISTINCT(site)) AS no_projects,
NULL AS no_platforms,
NULL::bigint AS no_instruments,
NULL::bigint AS no_deployments,
SUM(no_files) AS no_data,
round(((max(time_end)-min(time_start))/365.25)::numeric, 1) AS no_data2,
NULL::bigint AS no_data3,
NULL::bigint AS no_data4,
COALESCE(to_char(min(time_start),'DD/MM/YYYY')||' - '||to_char(max(time_end),'DD/MM/YYYY')) AS temporal_range,
NULL AS lat_range,
NULL AS lon_range,
NULL AS depth_range
FROM acorn_all_deployments_view

-- ANFOG
UNION ALL
  SELECT 'ANFOG' AS facility,
    NULL AS subfacility,
    data_type AS type,
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
    GROUP BY data_type

UNION ALL

  SELECT 'ANFOG' AS facility,
    NULL AS subfacility,
    'TOTAL' AS type,
    NULL::bigint AS no_projects,
    COUNT(DISTINCT(platform)) AS no_platforms,
    NULL::bigint AS no_instruments,
    COUNT(DISTINCT(deployment_id)) AS no_deployments,
    NULL AS no_data,
    NULL AS no_data2,
    NULL::bigint AS no_data3,
    NULL::bigint AS no_data4,
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
  NULL::bigint AS no_data3,
  NULL::bigint AS no_data4,
  COALESCE(to_char(min(earliest_date),'DD/MM/YYYY')||' - '||to_char(max(latest_date),'DD/MM/YYYY')) AS temporal_range,
  NULL AS lat_range,
  NULL AS lon_range,
  NULL AS depth_range
  FROM anmn_acoustics_data_summary_view
  
-- ANMN - NRS Real-Time
UNION ALL

  SELECT 'ANMN' AS facility,
  'NRS - Real-Time' AS subfacility,
  'TOTAL' AS type,
  COUNT(*) AS no_projects,
  NULL AS no_platforms,
  SUM(nb_channels) AS no_instruments,
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
  
-- Argo
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
  NULL AS no_data2,
  NULL::bigint AS no_data3,
  NULL::bigint AS no_data4,
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
  FROM faimms_data_summary_view, interm_table

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
NULL::bigint AS no_data3,
NULL::bigint AS no_data4,
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
NULL::bigint AS no_data3,
NULL::bigint AS no_data4,
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
NULL AS no_data,
NULL AS no_data2,
NULL::bigint AS no_data3,
NULL::bigint AS no_data4,
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
NULL::bigint AS no_data3,
NULL::bigint AS no_data4,
COALESCE(to_char(min(earliest_date),'DD/MM/YYYY')||' - '||to_char(max(latest_date),'DD/MM/YYYY')) AS temporal_range,
NULL AS lat_range,
NULL AS lon_range,
NULL AS depth_range
FROM srs_data_summary_view
  ORDER BY facility,subfacility,type;

grant all on table totals_view to public;

-------------------------------
-- Monthly snapshot
------------------------------- 
CREATE TABLE IF NOT EXISTS monthly_snapshot
( timestamp timestamp without time zone,
  facility text,
  subfacility text,
  data_type text,
  no_projects bigint,
  no_platforms numeric,
  no_instruments numeric,
  no_deployments numeric,
  no_data numeric,
  no_data2 numeric,
  no_data3 bigint,
  no_data4 bigint,
  start_date date,
  end_date date,
  min_lat numeric,
  max_lat numeric,
  min_lon numeric,
  max_lon numeric,
  min_depth numeric,
  max_depth numeric
);
grant all on table monthly_snapshot to public;

INSERT INTO monthly_snapshot (timestamp, facility, subfacility, data_type, no_projects, no_platforms, no_instruments, no_deployments, no_data, no_data2, no_data3, no_data4, 
start_date,end_date,min_lat,max_lat,min_lon,max_lon,min_depth,max_depth)
SELECT now()::timestamp without time zone,
	facility,
	subfacility,
	type AS data_type,
	no_projects,
	no_platforms,
	no_instruments,
	no_deployments,
	no_data,
	no_data2,
	no_data3,
	no_data4,
	to_date(substring(temporal_range,'[a-zA-Z0-9/]+'),'DD/MM/YYYY') AS start_date,
	to_date(substring(temporal_range,'-(.*)'),'DD/MM/YYYY') AS end_date,
	substring(lat_range,'(.*) - ')::numeric AS min_lat,
	substring(lat_range,' - (.*)')::numeric AS max_lat,
	substring(lon_range,'(.*) - ')::numeric AS min_lon,
	substring(lon_range,' - (.*)')::numeric AS max_lon,
	substring(depth_range,'(.*) - ')::numeric AS min_depth,
	substring(depth_range,' - (.*)')::numeric AS max_depth
  FROM totals_view
-- WHERE NOT EXISTS (SELECT month FROM monthly_snapshot WHERE month = to_char(to_timestamp (date_part('month',now())::text, 'MM'), 'Month'))


-- ANMN - BGC ///// Totals view
-- UNION ALL
--
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