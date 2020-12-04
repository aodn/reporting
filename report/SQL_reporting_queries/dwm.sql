SET search_path = reporting, public;
DROP VIEW IF EXISTS dwm_all_deployments_view CASCADE;

-------------------------------
-- VIEWS FOR DWM;
-------------------------------
-- All deployments view
CREATE or replace VIEW dwm_all_deployments_view AS
    WITH table_a AS (
    SELECT 
    substring(i.url, 'IMOS/DWM/([A-Z]+)/') AS sub_facility,
    CASE WHEN m.platform_code = 'PULSE' THEN 'Pulse'
	ELSE m.platform_code END AS platform_code,
    COALESCE(m.deployment_code,
             m.platform_code || '-' || COALESCE(m.deployment_number, '') || '-' || btrim(to_char(m.time_coverage_start, 'YYYY'))
    )  AS deployment_code,
    substring(i.url, '[^/]+nc$') AS file_name,
    m.file_version::integer AS file_version,
    regexp_replace(replace(replace(m.data_category, '_', ' '),
                           'temperature pressure conductivity',
                           'CTD'
                          ),
                   'Biogeochem.*|^Pulse',
                   'Biogeochemistry'
    ) AS data_category,
    CASE WHEN m.realtime THEN 'Real-time' ELSE 'Delayed-mode' END AS data_type,
    COALESCE(substring(i.url, '[0-9]{4}_daily'), 'Whole deployment') AS year_frequency,
    timezone('UTC'::text, m.time_coverage_start) AS coverage_start,
    timezone('UTC'::text, m.time_coverage_end) AS coverage_end,
    round(((date_part('day', (m.time_coverage_end - m.time_coverage_start)) + (date_part('hours'::text, (m.time_coverage_end - m.time_coverage_start)) / (24)::double precision)))::numeric, 1) AS coverage_duration,
    m.deployment_number
    FROM anmn_metadata.indexed_file i JOIN anmn_metadata.file_metadata m ON m.file_id = i.id
    WHERE i.url LIKE 'IMOS/DWM%' AND NOT m.deleted
    )
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
	a.deployment_number,
	a.platform_code, 
	a.sub_facility 
  FROM table_a a
	GROUP BY headers, a.deployment_code, a.data_category, a.data_type, a.year_frequency, a.deployment_number, a.platform_code, a.sub_facility
	ORDER BY file_type, headers, a.data_type, a.data_category, a.deployment_code;

grant all on table dwm_all_deployments_view to public;

-- Data summary view
CREATE or replace VIEW dwm_data_summary_view AS
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
    v.platform_code, 
    v.sub_facility 
    FROM dwm_all_deployments_view v
    WHERE v.headers IS NOT NULL 
    GROUP BY v.headers, v.data_category, v.data_type, v.file_type, v.platform_code, v.sub_facility 
    ORDER BY v.file_type, v.headers, v.data_type, v.data_category;

grant all on table dwm_data_summary_view to public;

-- ALTER VIEW dwm_all_deployments_view OWNER TO harvest_reporting_write_group;
-- ALTER VIEW dwm_data_summary_view OWNER TO harvest_reporting_write_group;
