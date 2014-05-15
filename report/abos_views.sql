SET search_path = report_test, pg_catalog, public;

CREATE or replace VIEW abos_all_deployments_view AS
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
    FROM dw_abos.abos_file
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

grant all on table abos_all_deployments_view to public;


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
    ceil(((date_part('day', (max(v.time_coverage_end) - min(v.time_coverage_start))) + (date_part('hours', (max(v.time_coverage_end) - min(v.time_coverage_start))) / (24)::double precision)))::numeric) AS coverage_duration, (sum(v.coverage_duration))::integer AS data_coverage, 
    CASE WHEN max(v.coverage_end) - min(v.coverage_start) = 0 THEN 0 
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