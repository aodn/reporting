--
-- PostgreSQL database dump
--

SET statement_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;

SET search_path = report, pg_catalog;

--
-- Name: date_round(timestamp with time zone, interval); Type: FUNCTION; Schema: report; Owner: postgres
--

CREATE FUNCTION date_round(base_date timestamp with time zone, round_interval interval) RETURNS timestamp with time zone
    LANGUAGE sql STABLE
    AS $_$
SELECT '1970-01-01'::timestamptz + (EXTRACT(epoch FROM $1)::INTEGER + EXTRACT(epoch FROM $2)::INTEGER / 2)
                / EXTRACT(epoch FROM $2)::INTEGER * EXTRACT(epoch FROM $2)::INTEGER * INTERVAL '1 second';
$_$;


ALTER FUNCTION report.date_round(base_date timestamp with time zone, round_interval interval) OWNER TO postgres;

--
-- Name: hibernate_sequence; Type: SEQUENCE; Schema: report; Owner: postgres
--

CREATE SEQUENCE hibernate_sequence
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE report.hibernate_sequence OWNER TO postgres;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: aatams_sattag_mdb_workflow_manual; Type: TABLE; Schema: report; Owner: postgres; Tablespace: 
--

CREATE TABLE aatams_sattag_mdb_workflow_manual (
    device_id character varying(20) NOT NULL,
    data_on_staging timestamp without time zone,
    data_on_opendap timestamp without time zone,
    data_on_portal timestamp without time zone,
    pkid integer DEFAULT nextval('hibernate_sequence'::regclass) NOT NULL
);


ALTER TABLE report.aatams_sattag_mdb_workflow_manual OWNER TO postgres;

--
-- Name: aatams_sattag_all_deployments_view; Type: VIEW; Schema: report; Owner: postgres
--

CREATE VIEW aatams_sattag_all_deployments_view AS
    SELECT COALESCE((((((((((ctd_device_mdb_workflow.sattag_program)::text || ' - '::text) || (ctd_device_mdb_workflow.common_name)::text) || ' - '::text) || (CASE WHEN ((ctd_device_mdb_workflow.sattag_program)::text = 'ct61'::text) THEN 'South Australia'::character varying ELSE ctd_device_mdb_workflow.release_site END)::text) || ' - '::text) || (ctd_device_mdb_workflow.pi)::text) || ' - '::text) || (ctd_device_mdb_workflow.tag_type)::text)) AS headers, ctd_device_mdb_workflow.sattag_program, ctd_device_mdb_workflow.pi AS principal_investigator, CASE WHEN (((ctd_device_mdb_workflow.sattag_program)::text = 'ct61'::text) OR ((ctd_device_mdb_workflow.release_site)::text = 'Australia'::text)) THEN 'South Australia'::character varying ELSE ctd_device_mdb_workflow.release_site END AS release_site, ctd_device_mdb_workflow.tag_type, ctd_device_mdb_workflow.common_name AS species_name, ctd_device_mdb_workflow.device_id AS tag_code, count(DISTINCT ctd_profile_mdb_workflow.pkid) AS nb_profiles, COALESCE(((round((min(ctd_profile_mdb_workflow.lat))::numeric, 1) || '/'::text) || round((max(ctd_profile_mdb_workflow.lat))::numeric, 1))) AS lat_range, COALESCE(((round((min(ctd_profile_mdb_workflow.lon))::numeric, 1) || '/'::text) || round((max(ctd_profile_mdb_workflow.lon))::numeric, 1))) AS lon_range, min(date(ctd_profile_mdb_workflow."timestamp")) AS coverage_start, max(date(ctd_profile_mdb_workflow."timestamp")) AS coverage_end, (date_part('days'::text, ((max(date(ctd_profile_mdb_workflow."timestamp")))::timestamp without time zone - (min(date(ctd_profile_mdb_workflow."timestamp")))::timestamp without time zone)))::integer AS coverage_duration, (date_part('days'::text, (aatams_sattag_mdb_workflow_manual.data_on_staging - (min(date(ctd_profile_mdb_workflow."timestamp")))::timestamp without time zone)))::integer AS days_to_process_and_upload, (date_part('days'::text, (aatams_sattag_mdb_workflow_manual.data_on_portal - aatams_sattag_mdb_workflow_manual.data_on_staging)))::integer AS days_to_make_public, CASE WHEN ((((((((((ctd_device_mdb_workflow.sattag_program IS NULL) OR (ctd_device_mdb_workflow.common_name IS NULL)) OR (ctd_device_mdb_workflow.release_site IS NULL)) OR (ctd_device_mdb_workflow.pi IS NULL)) OR (ctd_device_mdb_workflow.tag_type IS NULL)) OR (ctd_device_mdb_workflow.device_id IS NULL)) OR (ctd_device_mdb_workflow.metadata IS NULL)) OR (avg(ctd_profile_mdb_workflow.lat) IS NULL)) OR (avg(ctd_profile_mdb_workflow.lon) IS NULL)) OR (avg(date_part('year'::text, ctd_profile_mdb_workflow."timestamp")) IS NULL)) THEN 'Missing information from AATAMS sub-facility'::text WHEN (((avg(date_part('year'::text, aatams_sattag_mdb_workflow_manual.data_on_staging)) IS NULL) OR (avg(date_part('year'::text, aatams_sattag_mdb_workflow_manual.data_on_opendap)) IS NULL)) OR (avg(date_part('year'::text, aatams_sattag_mdb_workflow_manual.data_on_portal)) IS NULL)) THEN 'Missing information from eMII facility'::text ELSE NULL::text END AS missing_info, round((min(ctd_profile_mdb_workflow.lat))::numeric, 1) AS min_lat, round((max(ctd_profile_mdb_workflow.lat))::numeric, 1) AS max_lat, round((min(ctd_profile_mdb_workflow.lon))::numeric, 1) AS min_lon, round((max(ctd_profile_mdb_workflow.lon))::numeric, 1) AS max_lon FROM ((aatams_sattag.ctd_device_mdb_workflow LEFT JOIN aatams_sattag.ctd_profile_mdb_workflow ON (((ctd_device_mdb_workflow.device_id)::text = "substring"((ctd_profile_mdb_workflow.filename)::text, '(?:[^/]*/)([^/]+)'::text)))) LEFT JOIN aatams_sattag_mdb_workflow_manual ON ((ctd_device_mdb_workflow.device_id = (aatams_sattag_mdb_workflow_manual.device_id)::bpchar))) GROUP BY ctd_device_mdb_workflow.sattag_program, ctd_device_mdb_workflow.device_id, ctd_device_mdb_workflow.tag_type, ctd_device_mdb_workflow.pi, ctd_device_mdb_workflow.common_name, ctd_device_mdb_workflow.release_site, ctd_device_mdb_workflow.metadata, aatams_sattag_mdb_workflow_manual.data_on_staging, aatams_sattag_mdb_workflow_manual.data_on_portal ORDER BY COALESCE((((((((((ctd_device_mdb_workflow.sattag_program)::text || ' - '::text) || (ctd_device_mdb_workflow.common_name)::text) || ' - '::text) || (CASE WHEN ((ctd_device_mdb_workflow.sattag_program)::text = 'ct61'::text) THEN 'South Australia'::character varying ELSE ctd_device_mdb_workflow.release_site END)::text) || ' - '::text) || (ctd_device_mdb_workflow.pi)::text) || ' - '::text) || (ctd_device_mdb_workflow.tag_type)::text)), ctd_device_mdb_workflow.device_id;


ALTER TABLE report.aatams_sattag_all_deployments_view OWNER TO postgres;

--
-- Name: aatams_sattag_data_summary_view; Type: VIEW; Schema: report; Owner: postgres
--

CREATE VIEW aatams_sattag_data_summary_view AS
    SELECT COALESCE((((aatams_sattag_all_deployments_view.species_name)::text || ' - '::text) || (aatams_sattag_all_deployments_view.tag_type)::text)) AS species_name_tag_type, aatams_sattag_all_deployments_view.sattag_program, aatams_sattag_all_deployments_view.release_site, aatams_sattag_all_deployments_view.principal_investigator, count(DISTINCT aatams_sattag_all_deployments_view.tag_code) AS no_tags, sum(aatams_sattag_all_deployments_view.nb_profiles) AS total_nb_profiles, min(aatams_sattag_all_deployments_view.coverage_start) AS coverage_start, max(aatams_sattag_all_deployments_view.coverage_end) AS coverage_end, round(avg(aatams_sattag_all_deployments_view.coverage_duration), 1) AS mean_coverage_duration, round(avg(aatams_sattag_all_deployments_view.days_to_process_and_upload), 1) AS mean_time_to_process_and_upload, round(avg(aatams_sattag_all_deployments_view.days_to_make_public), 1) AS mean_time_to_make_public, aatams_sattag_all_deployments_view.tag_type, aatams_sattag_all_deployments_view.species_name, min(aatams_sattag_all_deployments_view.min_lat) AS min_lat, max(aatams_sattag_all_deployments_view.max_lat) AS max_lat, min(aatams_sattag_all_deployments_view.min_lon) AS min_lon, max(aatams_sattag_all_deployments_view.max_lon) AS max_lon FROM aatams_sattag_all_deployments_view GROUP BY aatams_sattag_all_deployments_view.sattag_program, aatams_sattag_all_deployments_view.release_site, aatams_sattag_all_deployments_view.species_name, aatams_sattag_all_deployments_view.principal_investigator, aatams_sattag_all_deployments_view.tag_type ORDER BY aatams_sattag_all_deployments_view.species_name, aatams_sattag_all_deployments_view.tag_type, aatams_sattag_all_deployments_view.sattag_program;


ALTER TABLE report.aatams_sattag_data_summary_view OWNER TO postgres;

--
-- Name: aatams_sattag_manual; Type: TABLE; Schema: report; Owner: postgres; Tablespace: 
--

CREATE TABLE aatams_sattag_manual (
    device_id character varying(15) NOT NULL,
    wmo_ref character varying(15),
    data_on_staging timestamp without time zone,
    data_on_opendap timestamp without time zone,
    data_on_portal timestamp without time zone,
    pkid integer DEFAULT nextval('hibernate_sequence'::regclass) NOT NULL
);


ALTER TABLE report.aatams_sattag_manual OWNER TO postgres;

--
-- Name: abos_asfssots_all_deployments_view; Type: VIEW; Schema: report; Owner: postgres
--

CREATE VIEW abos_asfssots_all_deployments_view AS
    WITH virtual_table AS (SELECT "substring"(abos_file.url, 'IMOS/ABOS/([A-Z]+)/'::text) AS sub_facility, CASE WHEN (abos_file.platform_code = 'PULSE'::text) THEN 'Pulse'::text ELSE abos_file.platform_code END AS platform_code, CASE WHEN (abos_file.deployment_code IS NULL) THEN COALESCE(((((abos_file.platform_code || '-'::text) || CASE WHEN (abos_file.deployment_number IS NULL) THEN ''::text ELSE abos_file.deployment_number END) || '-'::text) || btrim(to_char(abos_file.time_coverage_start, 'YYYY'::text)))) ELSE abos_file.deployment_code END AS deployment_code, "substring"(abos_file.url, '[^/]+nc'::text) AS file_name, ("substring"(abos_file.url, 'FV0([12]+)'::text))::integer AS file_version, CASE WHEN ("substring"(abos_file.url, '(Surface_waves|Surface_properties|Surface_fluxes|Sub-surface_temperature_pressure_conductivity|Pulse|Sub-surface_currents)'::text) = 'Pulse'::text) THEN 'Biogeochemistry'::text ELSE "substring"(abos_file.url, '(Surface_waves|Surface_properties|Surface_fluxes|Sub-surface_temperature_pressure_conductivity|Pulse|Sub-surface_currents)'::text) END AS data_category, COALESCE("substring"(abos_file.url, 'Real-time'::text), 'Delayed-mode'::text) AS data_type, COALESCE("substring"(abos_file.url, '[0-9]{4}_daily'::text), 'Whole deployment'::text) AS year_frequency, timezone('UTC'::text, abos_file.time_coverage_start) AS coverage_start, timezone('UTC'::text, abos_file.time_coverage_end) AS coverage_end, round(((date_part('day'::text, (abos_file.time_coverage_end - abos_file.time_coverage_start)) + (date_part('hours'::text, (abos_file.time_coverage_end - abos_file.time_coverage_start)) / (24)::double precision)))::numeric, 1) AS coverage_duration, (date_part('day'::text, (abos_file.last_modified - abos_file.date_created)))::integer AS days_to_process_and_upload, (date_part('day'::text, (abos_file.last_indexed - abos_file.last_modified)))::integer AS days_to_make_public, abos_file.deployment_number, abos_file.author, abos_file.principal_investigator FROM abos.abos_file WHERE (abos_file.status IS DISTINCT FROM 'DELETED'::text) ORDER BY "substring"(abos_file.url, 'IMOS/ABOS/([A-Z]+)/'::text), CASE WHEN (abos_file.platform_code = 'PULSE'::text) THEN 'Pulse'::text ELSE abos_file.platform_code END, CASE WHEN ("substring"(abos_file.url, '(Surface_waves|Surface_properties|Surface_fluxes|Sub-surface_temperature_pressure_conductivity|Pulse|Sub-surface_currents)'::text) = 'Pulse'::text) THEN 'Biogeochemistry'::text ELSE "substring"(abos_file.url, '(Surface_waves|Surface_properties|Surface_fluxes|Sub-surface_temperature_pressure_conductivity|Pulse|Sub-surface_currents)'::text) END) SELECT CASE WHEN (virtual_table.year_frequency = 'Whole deployment'::text) THEN 'Aggregated files'::text ELSE 'Daily files'::text END AS file_type, COALESCE(((((virtual_table.sub_facility || '-'::text) || virtual_table.platform_code) || ' - '::text) || virtual_table.data_type)) AS headers, virtual_table.data_type, virtual_table.data_category, virtual_table.deployment_code, sum(((virtual_table.file_version = 1))::integer) AS no_fv1, sum(((virtual_table.file_version = 2))::integer) AS no_fv2, date(min(virtual_table.coverage_start)) AS coverage_start, date(max(virtual_table.coverage_end)) AS coverage_end, min(virtual_table.coverage_start) AS time_coverage_start, max(virtual_table.coverage_end) AS time_coverage_end, CASE WHEN ((virtual_table.data_type = 'Delayed-mode'::text) AND (virtual_table.year_frequency = 'Whole deployment'::text)) THEN max(virtual_table.coverage_duration) ELSE ((date(max(virtual_table.coverage_end)) - date(min(virtual_table.coverage_start))))::numeric END AS coverage_duration, round(avg(virtual_table.days_to_process_and_upload), 1) AS mean_days_to_process_and_upload, round(avg(virtual_table.days_to_make_public), 1) AS mean_days_to_make_public, virtual_table.deployment_number, virtual_table.author, virtual_table.principal_investigator, virtual_table.platform_code, virtual_table.sub_facility FROM virtual_table GROUP BY COALESCE(((((virtual_table.sub_facility || '-'::text) || virtual_table.platform_code) || ' - '::text) || virtual_table.data_type)), virtual_table.deployment_code, virtual_table.data_category, virtual_table.data_type, virtual_table.year_frequency, virtual_table.deployment_number, virtual_table.author, virtual_table.principal_investigator, virtual_table.platform_code, virtual_table.sub_facility ORDER BY CASE WHEN (virtual_table.year_frequency = 'Whole deployment'::text) THEN 'Aggregated files'::text ELSE 'Daily files'::text END, COALESCE(((((virtual_table.sub_facility || '-'::text) || virtual_table.platform_code) || ' - '::text) || virtual_table.data_type)), virtual_table.data_type, virtual_table.data_category, virtual_table.deployment_code;


ALTER TABLE report.abos_asfssots_all_deployments_view OWNER TO postgres;

--
-- Name: abos_asfssots_data_summary_view; Type: VIEW; Schema: report; Owner: postgres
--

CREATE VIEW abos_asfssots_data_summary_view AS
    SELECT abos_asfssots_all_deployments_view.file_type, abos_asfssots_all_deployments_view.headers, abos_asfssots_all_deployments_view.data_type, abos_asfssots_all_deployments_view.data_category, count(DISTINCT abos_asfssots_all_deployments_view.deployment_code) AS no_deployments, sum(abos_asfssots_all_deployments_view.no_fv1) AS no_fv1, sum(abos_asfssots_all_deployments_view.no_fv2) AS no_fv2, min(abos_asfssots_all_deployments_view.coverage_start) AS coverage_start, max(abos_asfssots_all_deployments_view.coverage_end) AS coverage_end, ceil(((date_part('day'::text, (max(abos_asfssots_all_deployments_view.time_coverage_end) - min(abos_asfssots_all_deployments_view.time_coverage_start))) + (date_part('hours'::text, (max(abos_asfssots_all_deployments_view.time_coverage_end) - min(abos_asfssots_all_deployments_view.time_coverage_start))) / (24)::double precision)))::numeric) AS coverage_duration, (sum(abos_asfssots_all_deployments_view.coverage_duration))::integer AS data_coverage, CASE WHEN ((max(abos_asfssots_all_deployments_view.coverage_end) - min(abos_asfssots_all_deployments_view.coverage_start)) = 0) THEN 0 ELSE (((sum(abos_asfssots_all_deployments_view.coverage_duration) / ((max(abos_asfssots_all_deployments_view.coverage_end) - min(abos_asfssots_all_deployments_view.coverage_start)))::numeric) * (100)::numeric))::integer END AS percent_coverage, round(avg(abos_asfssots_all_deployments_view.mean_days_to_process_and_upload), 1) AS mean_days_to_process_and_upload, round(avg(abos_asfssots_all_deployments_view.mean_days_to_make_public), 1) AS mean_days_to_make_public, abos_asfssots_all_deployments_view.platform_code, abos_asfssots_all_deployments_view.sub_facility FROM abos_asfssots_all_deployments_view WHERE (abos_asfssots_all_deployments_view.headers IS NOT NULL) GROUP BY abos_asfssots_all_deployments_view.headers, abos_asfssots_all_deployments_view.data_category, abos_asfssots_all_deployments_view.data_type, abos_asfssots_all_deployments_view.file_type, abos_asfssots_all_deployments_view.platform_code, abos_asfssots_all_deployments_view.sub_facility ORDER BY abos_asfssots_all_deployments_view.file_type, abos_asfssots_all_deployments_view.headers, abos_asfssots_all_deployments_view.data_type, abos_asfssots_all_deployments_view.data_category;


ALTER TABLE report.abos_asfssots_data_summary_view OWNER TO postgres;

--
-- Name: acorn_manual; Type: TABLE; Schema: report; Owner: postgres; Tablespace: 
--

CREATE TABLE acorn_manual (
    unique_id bigint DEFAULT nextval('hibernate_sequence'::regclass) NOT NULL,
    site_id integer,
    code character varying(10),
    code_full_name character varying(100),
    code_type character varying(20),
    start_date_of_transmission timestamp without time zone,
    last_checking_date timestamp without time zone,
    non_qc_data_availability_percent double precision,
    non_qc_data_portal_percent double precision,
    qc_data_availability_percent double precision,
    qc_data_portal_percent double precision,
    last_qc_data_received timestamp without time zone,
    data_on_staging timestamp without time zone,
    data_on_opendap timestamp without time zone,
    data_on_portal timestamp without time zone,
    uuid character varying(36),
    mest_creation timestamp without time zone
);


ALTER TABLE report.acorn_manual OWNER TO postgres;

--
-- Name: acorn_all_deployments_view; Type: VIEW; Schema: report; Owner: postgres
--

CREATE VIEW acorn_all_deployments_view AS
    SELECT acorn_manual.code_type, CASE WHEN (acorn_manual.site_id = 1) THEN 'Capricorn Bunker Group'::text WHEN (acorn_manual.site_id = 2) THEN 'Rottnest Shelf'::text WHEN (acorn_manual.site_id = 3) THEN 'South Australia Gulf'::text WHEN (acorn_manual.site_id = 4) THEN 'Coffs Harbour'::text WHEN (acorn_manual.site_id = 5) THEN 'Turquoise Coast'::text ELSE 'Bonney Coast'::text END AS site, acorn_manual.code_full_name, date(acorn_manual.start_date_of_transmission) AS start, (acorn_manual.non_qc_data_availability_percent)::numeric AS non_qc_radial, (acorn_manual.non_qc_data_portal_percent)::numeric AS non_qc_grid, (acorn_manual.qc_data_availability_percent)::numeric AS qc_radial, (acorn_manual.qc_data_portal_percent)::numeric AS qc_grid, date(acorn_manual.last_qc_data_received) AS last_qc_date, date(acorn_manual.data_on_staging) AS data_on_staging, date(acorn_manual.data_on_opendap) AS data_on_opendap, date(acorn_manual.data_on_portal) AS data_on_portal, (date_part('day'::text, (acorn_manual.last_qc_data_received - acorn_manual.start_date_of_transmission)))::integer AS qc_coverage_duration, (date_part('day'::text, (acorn_manual.data_on_opendap - acorn_manual.start_date_of_transmission)))::integer AS days_to_process_and_upload, CASE WHEN (acorn_manual.data_on_portal IS NULL) THEN (date_part('day'::text, (acorn_manual.data_on_opendap - acorn_manual.start_date_of_transmission)))::integer ELSE (date_part('day'::text, (acorn_manual.data_on_portal - acorn_manual.data_on_opendap)))::integer END AS days_to_make_public, CASE WHEN (acorn_manual.mest_creation IS NULL) THEN 'No'::text ELSE 'Yes'::text END AS metadata FROM acorn_manual GROUP BY acorn_manual.code_type, acorn_manual.site_id, acorn_manual.code_full_name, acorn_manual.start_date_of_transmission, acorn_manual.non_qc_data_availability_percent, acorn_manual.non_qc_data_portal_percent, acorn_manual.qc_data_availability_percent, acorn_manual.qc_data_portal_percent, acorn_manual.last_qc_data_received, acorn_manual.data_on_staging, acorn_manual.data_on_opendap, acorn_manual.data_on_portal, acorn_manual.mest_creation ORDER BY CASE WHEN (acorn_manual.site_id = 1) THEN 'Capricorn Bunker Group'::text WHEN (acorn_manual.site_id = 2) THEN 'Rottnest Shelf'::text WHEN (acorn_manual.site_id = 3) THEN 'South Australia Gulf'::text WHEN (acorn_manual.site_id = 4) THEN 'Coffs Harbour'::text WHEN (acorn_manual.site_id = 5) THEN 'Turquoise Coast'::text ELSE 'Bonney Coast'::text END, acorn_manual.code_type, acorn_manual.code_full_name;


ALTER TABLE report.acorn_all_deployments_view OWNER TO postgres;

--
-- Name: anfog_manual; Type: TABLE; Schema: report; Owner: postgres; Tablespace: 
--

CREATE TABLE anfog_manual (
    deployment_id character varying(50) NOT NULL,
    deployment_start date,
    data_on_staging date,
    data_on_opendap date,
    data_on_portal date,
    mest_creation date,
    anfog_id bigint NOT NULL
);


ALTER TABLE report.anfog_manual OWNER TO postgres;

--
-- Name: anfog_all_deployments_view; Type: VIEW; Schema: report; Owner: postgres
--

CREATE VIEW anfog_all_deployments_view AS
    SELECT anfog_glider.glider_type, anfog_glider.platform, anfog_manual.deployment_id, anfog_manual.deployment_start AS start_date, date(anfog_glider.time_end) AS end_date, round((anfog_glider.min_lat)::numeric, 1) AS min_lat, CASE WHEN (anfog_glider.max_lat = (99999.0)::double precision) THEN round((anfog_glider.min_lat)::numeric, 1) ELSE round((anfog_glider.max_lat)::numeric, 1) END AS max_lat, round((anfog_glider.min_lon)::numeric, 1) AS min_lon, CASE WHEN (anfog_glider.max_lon = (99999.0)::double precision) THEN round((anfog_glider.min_lon)::numeric, 1) ELSE round((anfog_glider.max_lon)::numeric, 1) END AS max_lon, COALESCE(((round((anfog_glider.min_lat)::numeric, 1) || '/'::text) || round((anfog_glider.max_lat)::numeric, 1))) AS lat_range, COALESCE(((round((anfog_glider.min_lon)::numeric, 1) || '/'::text) || round((anfog_glider.max_lon)::numeric, 1))) AS lon_range, (anfog_glider.max_depth)::integer AS max_depth, CASE WHEN (anfog_glider.uuid IS NULL) THEN 'No'::text ELSE 'Yes'::text END AS metadata, CASE WHEN (anfog_manual.data_on_opendap IS NULL) THEN 'No'::text ELSE 'Yes'::text END AS qc_data, anfog_manual.data_on_staging, anfog_manual.data_on_opendap, anfog_manual.data_on_portal, (date_part('day'::text, (anfog_glider.time_end - (anfog_manual.deployment_start)::timestamp without time zone)))::integer AS coverage_duration, (date_part('day'::text, ((anfog_manual.data_on_staging)::timestamp without time zone - anfog_glider.time_end)))::integer AS days_to_process_and_upload, (anfog_manual.data_on_portal - anfog_manual.data_on_staging) AS days_to_make_public FROM (anfog.anfog_glider RIGHT JOIN anfog_manual ON (((anfog_manual.deployment_id)::text = (anfog_glider.deployment_name)::text))) ORDER BY anfog_glider.glider_type, anfog_glider.platform, anfog_glider.deployment_name;


ALTER TABLE report.anfog_all_deployments_view OWNER TO postgres;

--
-- Name: anfog_data_summary_view; Type: VIEW; Schema: report; Owner: postgres
--

CREATE VIEW anfog_data_summary_view AS
    SELECT CASE WHEN (anfog_all_deployments_view.glider_type IS NULL) THEN 'Unknown'::character varying ELSE anfog_all_deployments_view.glider_type END AS glider_type, count(DISTINCT anfog_all_deployments_view.platform) AS no_platforms, count(DISTINCT anfog_all_deployments_view.deployment_id) AS no_deployments, min(anfog_all_deployments_view.start_date) AS earliest_date, max(anfog_all_deployments_view.end_date) AS latest_date, COALESCE(((min(anfog_all_deployments_view.min_lat) || '/'::text) || max(anfog_all_deployments_view.max_lat))) AS lat_range, COALESCE(((min(anfog_all_deployments_view.min_lon) || '/'::text) || max(anfog_all_deployments_view.max_lon))) AS lon_range, COALESCE(((min(anfog_all_deployments_view.max_depth) || '/'::text) || max(anfog_all_deployments_view.max_depth))) AS max_depth_range, round(avg(anfog_all_deployments_view.coverage_duration), 1) AS mean_coverage_duration, round(avg(anfog_all_deployments_view.days_to_process_and_upload), 1) AS mean_days_to_process_and_upload, round(avg(anfog_all_deployments_view.days_to_make_public), 1) AS mean_days_to_make_public, min(anfog_all_deployments_view.min_lat) AS min_lat, max(anfog_all_deployments_view.max_lat) AS max_lat, min(anfog_all_deployments_view.min_lon) AS min_lon, max(anfog_all_deployments_view.max_lon) AS max_lon, min(anfog_all_deployments_view.max_depth) AS min_depth, max(anfog_all_deployments_view.max_depth) AS max_depth FROM anfog_all_deployments_view GROUP BY anfog_all_deployments_view.glider_type ORDER BY CASE WHEN (anfog_all_deployments_view.glider_type IS NULL) THEN 'Unknown'::character varying ELSE anfog_all_deployments_view.glider_type END;


ALTER TABLE report.anfog_data_summary_view OWNER TO postgres;

--
-- Name: anfog_seq; Type: SEQUENCE; Schema: report; Owner: postgres
--

CREATE SEQUENCE anfog_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE report.anfog_seq OWNER TO postgres;

--
-- Name: anmn_acoustics_all_deployments_view; Type: VIEW; Schema: report; Owner: postgres
--

CREATE VIEW anmn_acoustics_all_deployments_view AS
    SELECT COALESCE((((("substring"((acoustic_deployments.deployment_name)::text, '\D+'::text) || ' - Lat/Lon:'::text) || round((anmn_acoustics.lat)::numeric, 1)) || '/'::text) || round((anmn_acoustics.lon)::numeric, 1))) AS site_name, "substring"((acoustic_deployments.deployment_name)::text, '2[-0-9]+'::text) AS deployment_year, acoustic_deployments.logger_id, bool_or((((acoustic_deployments.set_success)::text !~~* '%fail%'::text) AND (acoustic_deployments.frequency = 6))) AS good_data, bool_or((((acoustic_deployments.set_success)::text !~~* '%fail%'::text) AND (acoustic_deployments.frequency = 22))) AS good_22, bool_or((acoustic_deployments.is_primary AND (acoustic_deployments.data_path IS NOT NULL))) AS on_viewer, round(avg((acoustic_deployments.receiver_depth)::numeric), 1) AS depth, min(date(acoustic_deployments.time_deployment_start)) AS start_date, max(date(acoustic_deployments.time_deployment_end)) AS end_date, (max(date(acoustic_deployments.time_deployment_end)) - min(date(acoustic_deployments.time_deployment_start))) AS coverage_duration, CASE WHEN (((((((((acoustic_deployments.logger_id IS NULL) OR (avg(date_part('year'::text, acoustic_deployments.time_deployment_end)) IS NULL)) OR bool_or((acoustic_deployments.frequency IS NULL))) OR bool_or((acoustic_deployments.set_success IS NULL))) OR (avg(acoustic_deployments.lat) IS NULL)) OR (avg(acoustic_deployments.lon) IS NULL)) OR (avg(acoustic_deployments.receiver_depth) IS NULL)) OR bool_or((acoustic_deployments.system_gain_file IS NULL))) OR bool_or((acoustic_deployments.hydrophone_sensitivity IS NULL))) THEN 'Missing information from PAO sub-facility'::text ELSE NULL::text END AS missing_info FROM (anmn.acoustic_deployments LEFT JOIN anmn.anmn_acoustics ON (((acoustic_deployments.site_code)::text = "substring"((anmn_acoustics.code)::text, 1, 5)))) GROUP BY acoustic_deployments.deployment_name, anmn_acoustics.lat, anmn_acoustics.lon, acoustic_deployments.logger_id ORDER BY COALESCE((((("substring"((acoustic_deployments.deployment_name)::text, '\D+'::text) || ' - Lat/Lon:'::text) || round((anmn_acoustics.lat)::numeric, 1)) || '/'::text) || round((anmn_acoustics.lon)::numeric, 1))), "substring"((acoustic_deployments.deployment_name)::text, '2[-0-9]+'::text), acoustic_deployments.logger_id;


ALTER TABLE report.anmn_acoustics_all_deployments_view OWNER TO postgres;

--
-- Name: anmn_acoustics_data_summary_view; Type: VIEW; Schema: report; Owner: postgres
--

CREATE VIEW anmn_acoustics_data_summary_view AS
    SELECT anmn_acoustics_all_deployments_view.site_name, anmn_acoustics_all_deployments_view.deployment_year, count(*) AS no_loggers, sum((anmn_acoustics_all_deployments_view.good_data)::integer) AS no_good_data, sum((anmn_acoustics_all_deployments_view.on_viewer)::integer) AS no_sets_on_viewer, sum((anmn_acoustics_all_deployments_view.good_22)::integer) AS no_good_22, min(anmn_acoustics_all_deployments_view.start_date) AS earliest_date, max(anmn_acoustics_all_deployments_view.end_date) AS latest_date, (max(anmn_acoustics_all_deployments_view.end_date) - min(anmn_acoustics_all_deployments_view.start_date)) AS coverage_duration, sum(CASE WHEN ("substring"(anmn_acoustics_all_deployments_view.missing_info, 'PAO'::text) IS NULL) THEN 0 ELSE 1 END) AS no_missing_info_pao_subfacility, sum(CASE WHEN ("substring"(anmn_acoustics_all_deployments_view.missing_info, 'eMII'::text) IS NULL) THEN 0 ELSE 1 END) AS no_missing_info_emii FROM anmn_acoustics_all_deployments_view GROUP BY anmn_acoustics_all_deployments_view.site_name, anmn_acoustics_all_deployments_view.deployment_year ORDER BY anmn_acoustics_all_deployments_view.site_name, anmn_acoustics_all_deployments_view.deployment_year;


ALTER TABLE report.anmn_acoustics_data_summary_view OWNER TO postgres;

--
-- Name: anmn_platforms_manual; Type: TABLE; Schema: report; Owner: postgres; Tablespace: 
--

CREATE TABLE anmn_platforms_manual (
    pkid integer NOT NULL,
    operator character varying(20),
    platform_type character varying(20),
    subfac_responsible character varying(10),
    site_code character varying(10) NOT NULL,
    site_name character varying(100),
    platform_code character varying(30) NOT NULL,
    platform_name character varying(100),
    lat double precision,
    lon double precision,
    depth integer,
    first_deployed date,
    active boolean,
    comment character varying(100),
    discontinued date
);


ALTER TABLE report.anmn_platforms_manual OWNER TO postgres;

--
-- Name: anmn_all_deployments_view; Type: VIEW; Schema: report; Owner: postgres
--

CREATE VIEW anmn_all_deployments_view AS
    WITH site_view AS (SELECT anmn_platforms_manual.site_code, anmn_platforms_manual.site_name, avg(anmn_platforms_manual.lat) AS site_lat, avg(anmn_platforms_manual.lon) AS site_lon, (avg(anmn_platforms_manual.depth))::integer AS site_depth, min(anmn_platforms_manual.first_deployed) AS site_first_deployed, max(anmn_platforms_manual.discontinued) AS site_discontinued, bool_or(anmn_platforms_manual.active) AS site_active FROM anmn_platforms_manual GROUP BY anmn_platforms_manual.site_code, anmn_platforms_manual.site_name ORDER BY anmn_platforms_manual.site_code), file_view AS (SELECT DISTINCT "substring"((dw_anmn.anmn_mv.url)::text, 'IMOS/ANMN/([A-Z]+)/'::text) AS subfacility, anmn_mv.site_code, anmn_mv.platform_code, anmn_mv.deployment_code, "substring"((anmn_mv.url)::text, '([^_]+)_END'::text) AS deployment_product, anmn_mv.status, "substring"(anmn_mv.file_version, 'Level ([012]+)'::text) AS file_version, "substring"((anmn_mv.url)::text, '(Temperature|CTD_timeseries|CTD_profiles|Biogeochem_timeseries|Biogeochem_profiles|Velocity|Wave|CO2|Meteorology)'::text) AS data_category, NULLIF(anmn_mv.geospatial_vertical_min, '-Infinity'::double precision) AS geospatial_vertical_min, NULLIF(anmn_mv.geospatial_vertical_max, 'Infinity'::double precision) AS geospatial_vertical_max, CASE WHEN (timezone('UTC'::text, anmn_mv.time_deployment_start) IS NULL) THEN anmn_mv.time_coverage_start ELSE (timezone('UTC'::text, anmn_mv.time_deployment_start))::timestamp with time zone END AS time_deployment_start, CASE WHEN (timezone('UTC'::text, anmn_mv.time_deployment_end) IS NULL) THEN anmn_mv.time_coverage_end ELSE (timezone('UTC'::text, anmn_mv.time_deployment_end))::timestamp with time zone END AS time_deployment_end, timezone('UTC'::text, GREATEST(anmn_mv.time_deployment_start, anmn_mv.time_coverage_start)) AS good_data_start, timezone('UTC'::text, LEAST(anmn_mv.time_deployment_end, anmn_mv.time_coverage_end)) AS good_data_end, (anmn_mv.time_coverage_end - anmn_mv.time_coverage_start) AS coverage_duration, (anmn_mv.time_deployment_end - anmn_mv.time_deployment_start) AS deployment_duration, GREATEST('00:00:00'::interval, (LEAST(anmn_mv.time_deployment_end, anmn_mv.time_coverage_end) - GREATEST(anmn_mv.time_deployment_start, anmn_mv.time_coverage_start))) AS good_data_duration, date(timezone('UTC'::text, anmn_mv.date_created)) AS date_processed, date(timezone('UTC'::text, anmn_mv.last_modified)) AS date_uploaded, date(timezone('UTC'::text, anmn_mv.first_indexed)) AS date_public, CASE WHEN (date_part('day'::text, (anmn_mv.last_modified - anmn_mv.time_deployment_end)) IS NULL) THEN date_part('day'::text, (anmn_mv.last_modified - anmn_mv.time_coverage_end)) ELSE date_part('day'::text, (anmn_mv.last_modified - anmn_mv.time_deployment_end)) END AS processing_duration, date_part('day'::text, (anmn_mv.last_indexed - anmn_mv.last_modified)) AS publication_duration FROM anmn.anmn_mv ORDER BY "substring"((anmn_mv.url)::text, 'IMOS/ANMN/([A-Z]+)/'::text), anmn_mv.deployment_code, "substring"((anmn_mv.url)::text, '(Temperature|CTD_timeseries|CTD_profiles|Biogeochem_timeseries|Biogeochem_profiles|Velocity|Wave|CO2|Meteorology)'::text)) SELECT file_view.subfacility, COALESCE(((((((((site_view.site_name)::text || ' ('::text) || file_view.site_code) || ')'::text) || ' - Lat/Lon:'::text) || round((min(site_view.site_lat))::numeric, 1)) || '/'::text) || round((min(site_view.site_lon))::numeric, 1))) AS site_name_code, file_view.data_category, file_view.deployment_code, (sum(((file_view.file_version = '0'::text))::integer))::numeric AS no_fv00, (sum(((file_view.file_version = '1'::text))::integer))::numeric AS no_fv01, date(min(file_view.time_deployment_start)) AS start_date, date(max(file_view.time_deployment_end)) AS end_date, (date_part('day'::text, (max(file_view.time_deployment_end) - min(file_view.time_deployment_start))))::numeric AS coverage_duration, (date_part('day'::text, (max(file_view.good_data_end) - min(file_view.good_data_start))))::numeric AS data_coverage, round((avg(file_view.processing_duration))::numeric, 1) AS mean_days_to_process_and_upload, round((avg(file_view.publication_duration))::numeric, 1) AS mean_days_to_make_public, CASE WHEN ((((((sum(CASE WHEN (site_view.site_name IS NULL) THEN 0 ELSE 1 END) <> count(file_view.subfacility)) OR (sum(CASE WHEN (file_view.time_deployment_start IS NULL) THEN 0 ELSE 1 END) <> count(file_view.subfacility))) OR (sum(CASE WHEN (file_view.time_deployment_end IS NULL) THEN 0 ELSE 1 END) <> count(file_view.subfacility))) OR (sum(CASE WHEN (file_view.date_processed IS NULL) THEN 0 ELSE 1 END) <> count(file_view.subfacility))) OR (sum(CASE WHEN (file_view.date_uploaded IS NULL) THEN 0 ELSE 1 END) <> count(file_view.subfacility))) OR (sum(CASE WHEN (file_view.site_code IS NULL) THEN 0 ELSE 1 END) <> count(file_view.subfacility))) THEN COALESCE((((('Missing information from'::text || ' '::text) || file_view.subfacility) || ' '::text) || 'sub-facility'::text)) WHEN (sum(CASE WHEN (file_view.date_public IS NULL) THEN 0 ELSE 1 END) <> count(file_view.subfacility)) THEN 'Missing information from eMII'::text ELSE NULL::text END AS missing_info, date(min(file_view.good_data_start)) AS good_data_start, date(max(file_view.good_data_end)) AS good_data_end, round((min(site_view.site_lat))::numeric, 1) AS min_lat, round((min(site_view.site_lon))::numeric, 1) AS min_lon, round((max(site_view.site_lat))::numeric, 1) AS max_lat, round((max(site_view.site_lon))::numeric, 1) AS max_lon, round((min(file_view.geospatial_vertical_min))::numeric, 1) AS min_depth, round((max(file_view.geospatial_vertical_max))::numeric, 1) AS max_depth, max(file_view.date_processed) AS date_processed, max(file_view.date_uploaded) AS data_on_staging, max(file_view.date_public) AS data_on_portal, file_view.site_code FROM (file_view NATURAL LEFT JOIN site_view) WHERE (file_view.status IS NULL) GROUP BY file_view.subfacility, file_view.site_code, site_view.site_name, file_view.data_category, file_view.deployment_code ORDER BY file_view.subfacility, file_view.site_code, file_view.data_category, file_view.deployment_code;


ALTER TABLE report.anmn_all_deployments_view OWNER TO postgres;

--
-- Name: anmn_data_summary_view; Type: VIEW; Schema: report; Owner: postgres
--

CREATE VIEW anmn_data_summary_view AS
    SELECT anmn_all_deployments_view.subfacility, anmn_all_deployments_view.site_name_code, anmn_all_deployments_view.data_category, count(*) AS no_deployments, sum(anmn_all_deployments_view.no_fv00) AS no_fv00, sum(anmn_all_deployments_view.no_fv01) AS no_fv01, CASE WHEN (CASE WHEN (min(anmn_all_deployments_view.min_depth) < (0)::numeric) THEN (min(anmn_all_deployments_view.min_depth) * ((-1))::numeric) ELSE min(anmn_all_deployments_view.min_depth) END > max(anmn_all_deployments_view.max_depth)) THEN COALESCE(((max(anmn_all_deployments_view.max_depth) || '/'::text) || CASE WHEN (min(anmn_all_deployments_view.min_depth) < (0)::numeric) THEN (min(anmn_all_deployments_view.min_depth) * ((-1))::numeric) ELSE min(anmn_all_deployments_view.min_depth) END)) ELSE COALESCE(((CASE WHEN (min(anmn_all_deployments_view.min_depth) < (0)::numeric) THEN (min(anmn_all_deployments_view.min_depth) * ((-1))::numeric) ELSE min(anmn_all_deployments_view.min_depth) END || '/'::text) || max(anmn_all_deployments_view.max_depth))) END AS depth_range, min(anmn_all_deployments_view.start_date) AS earliest_date, max(anmn_all_deployments_view.end_date) AS latest_date, (max(anmn_all_deployments_view.end_date) - min(anmn_all_deployments_view.start_date)) AS coverage_duration, sum(anmn_all_deployments_view.data_coverage) AS data_coverage, CASE WHEN (round(((sum(anmn_all_deployments_view.data_coverage) / ((max(anmn_all_deployments_view.end_date) - min(anmn_all_deployments_view.start_date)))::numeric) * (100)::numeric), 1) < (0)::numeric) THEN NULL::numeric WHEN (round(((sum(anmn_all_deployments_view.data_coverage) / ((max(anmn_all_deployments_view.end_date) - min(anmn_all_deployments_view.start_date)))::numeric) * (100)::numeric), 1) > (100)::numeric) THEN (100)::numeric ELSE round(((sum(anmn_all_deployments_view.data_coverage) / ((max(anmn_all_deployments_view.end_date) - min(anmn_all_deployments_view.start_date)))::numeric) * (100)::numeric), 1) END AS percent_coverage, round(avg(anmn_all_deployments_view.mean_days_to_process_and_upload), 1) AS mean_days_to_process_and_upload, round(avg(anmn_all_deployments_view.mean_days_to_make_public), 1) AS mean_days_to_make_public, sum(CASE WHEN (anmn_all_deployments_view.missing_info IS NULL) THEN 0 WHEN ("substring"(anmn_all_deployments_view.missing_info, 'facility'::text) IS NOT NULL) THEN 1 ELSE NULL::integer END) AS missing_info_facility, sum(CASE WHEN (anmn_all_deployments_view.missing_info IS NULL) THEN 0 WHEN ("substring"(anmn_all_deployments_view.missing_info, 'eMII'::text) IS NOT NULL) THEN 1 ELSE NULL::integer END) AS missing_info_emii, min(anmn_all_deployments_view.min_lat) AS min_lat, min(anmn_all_deployments_view.min_lon) AS min_lon, min(anmn_all_deployments_view.min_depth) AS min_depth, max(anmn_all_deployments_view.max_depth) AS max_depth, anmn_all_deployments_view.site_code FROM anmn_all_deployments_view GROUP BY anmn_all_deployments_view.subfacility, anmn_all_deployments_view.site_name_code, anmn_all_deployments_view.data_category, anmn_all_deployments_view.site_code ORDER BY anmn_all_deployments_view.subfacility, anmn_all_deployments_view.site_code, anmn_all_deployments_view.data_category;


ALTER TABLE report.anmn_data_summary_view OWNER TO postgres;

--
-- Name: anmn_datacategories_manual; Type: TABLE; Schema: report; Owner: postgres; Tablespace: 
--

CREATE TABLE anmn_datacategories_manual (
    pkid integer NOT NULL,
    instr_model bpchar NOT NULL,
    data_category character varying(20)
);


ALTER TABLE report.anmn_datacategories_manual OWNER TO postgres;

--
-- Name: anmn_datacategories_manual_pkid_seq; Type: SEQUENCE; Schema: report; Owner: postgres
--

CREATE SEQUENCE anmn_datacategories_manual_pkid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE report.anmn_datacategories_manual_pkid_seq OWNER TO postgres;

--
-- Name: anmn_datacategories_manual_pkid_seq; Type: SEQUENCE OWNED BY; Schema: report; Owner: postgres
--

ALTER SEQUENCE anmn_datacategories_manual_pkid_seq OWNED BY anmn_datacategories_manual.pkid;


--
-- Name: anmn_manual; Type: TABLE; Schema: report; Owner: postgres; Tablespace: 
--

CREATE TABLE anmn_manual (
    pkid integer NOT NULL,
    platform_code character varying(20) NOT NULL,
    deployment_code character varying(30),
    responsible_persons character varying(50),
    responsible_organisation character varying(20),
    planned_deployment_start date NOT NULL,
    planned_deployment_end date NOT NULL,
    deployment_start date,
    deployment_end date
);


ALTER TABLE report.anmn_manual OWNER TO postgres;

--
-- Name: anmn_manual_pkid_seq; Type: SEQUENCE; Schema: report; Owner: postgres
--

CREATE SEQUENCE anmn_manual_pkid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE report.anmn_manual_pkid_seq OWNER TO postgres;

--
-- Name: anmn_manual_pkid_seq; Type: SEQUENCE OWNED BY; Schema: report; Owner: postgres
--

ALTER SEQUENCE anmn_manual_pkid_seq OWNED BY anmn_manual.pkid;


--
-- Name: nrs_aims_manual; Type: TABLE; Schema: report; Owner: postgres; Tablespace: 
--

CREATE TABLE nrs_aims_manual (
    platform_name character varying(50) NOT NULL,
    deployment_start timestamp without time zone,
    data_on_staging timestamp without time zone,
    data_on_opendap timestamp without time zone,
    data_on_portal timestamp without time zone,
    mest_creation timestamp without time zone,
    id bigint DEFAULT nextval('hibernate_sequence'::regclass) NOT NULL
);


ALTER TABLE report.nrs_aims_manual OWNER TO postgres;

--
-- Name: anmn_nrs_realtime_all_deployments_view; Type: VIEW; Schema: report; Owner: postgres
--

CREATE VIEW anmn_nrs_realtime_all_deployments_view AS
    SELECT COALESCE((((((nrs_platforms.platform_code)::text || ' - Lat / Lon: '::text) || round((nrs_platforms.lat)::numeric, 1)) || ' / '::text) || round((nrs_platforms.lon)::numeric, 1))) AS site_name, nrs_parameters.parameter, nrs_parameters.channelid AS channel_id, round((nrs_parameters.depth_sensor)::numeric, 1) AS sensor_depth, CASE WHEN (nrs_parameters.qaqc_boolean = 1) THEN true ELSE false END AS qaqc_data, CASE WHEN (date_part('day'::text, (nrs_parameters.time_coverage_end - nrs_parameters.time_coverage_start)) IS NULL) THEN 'Missing dates'::text WHEN (nrs_parameters.metadata_uuid IS NULL) THEN 'No metadata'::text ELSE NULL::text END AS missing_info, date(nrs_parameters.time_coverage_start) AS start_date, date(nrs_parameters.time_coverage_end) AS end_date, (date_part('day'::text, (nrs_parameters.time_coverage_end - nrs_parameters.time_coverage_start)))::numeric AS coverage_duration, (date_part('day'::text, (nrs_aims_manual.data_on_staging - nrs_parameters.time_coverage_start)))::numeric AS days_to_process_and_upload, (date_part('day'::text, (nrs_aims_manual.data_on_portal - nrs_aims_manual.data_on_staging)))::numeric AS days_to_make_public, nrs_platforms.platform_code, round((nrs_platforms.lat)::numeric, 1) AS lat, round((nrs_platforms.lon)::numeric, 1) AS lon, date(nrs_aims_manual.data_on_staging) AS date_on_staging, date(nrs_aims_manual.data_on_opendap) AS date_on_opendap, date(nrs_aims_manual.data_on_portal) AS date_on_portal, nrs_aims_manual.mest_creation, nrs_parameters.no_qaqc_boolean AS no_qaqc_data, nrs_parameters.metadata_uuid AS channel_uuid FROM ((anmn.nrs_parameters LEFT JOIN anmn.nrs_platforms ON ((nrs_platforms.pkid = nrs_parameters.fk_nrs_platforms))) LEFT JOIN nrs_aims_manual ON (((nrs_aims_manual.platform_name)::text = (nrs_platforms.platform_code)::text))) ORDER BY COALESCE((((((nrs_platforms.platform_code)::text || ' - Lat / Lon: '::text) || round((nrs_platforms.lat)::numeric, 1)) || ' / '::text) || round((nrs_platforms.lon)::numeric, 1))), nrs_parameters.parameter, nrs_parameters.channelid;


ALTER TABLE report.anmn_nrs_realtime_all_deployments_view OWNER TO postgres;

--
-- Name: anmn_nrs_realtime_data_summary_view; Type: VIEW; Schema: report; Owner: postgres
--

CREATE VIEW anmn_nrs_realtime_data_summary_view AS
    SELECT anmn_nrs_realtime_all_deployments_view.platform_code AS site_name, count(DISTINCT anmn_nrs_realtime_all_deployments_view.channel_id) AS no_sensors, count(DISTINCT anmn_nrs_realtime_all_deployments_view.parameter) AS no_parameters, sum(CASE WHEN (anmn_nrs_realtime_all_deployments_view.qaqc_data = true) THEN 1 ELSE 0 END) AS no_qc_data, COALESCE(((min(anmn_nrs_realtime_all_deployments_view.sensor_depth) || '-'::text) || max(anmn_nrs_realtime_all_deployments_view.sensor_depth))) AS depth_range, min(anmn_nrs_realtime_all_deployments_view.start_date) AS earliest_date, max(anmn_nrs_realtime_all_deployments_view.end_date) AS latest_date, round(avg(anmn_nrs_realtime_all_deployments_view.coverage_duration), 1) AS mean_coverage_duration, round(avg(anmn_nrs_realtime_all_deployments_view.days_to_process_and_upload), 1) AS mean_days_to_process_and_upload, round(avg(anmn_nrs_realtime_all_deployments_view.days_to_make_public), 1) AS mean_days_to_make_public, sum(CASE WHEN (anmn_nrs_realtime_all_deployments_view.missing_info IS NULL) THEN 0 ELSE 1 END) AS no_missing_info, min(anmn_nrs_realtime_all_deployments_view.sensor_depth) AS min_depth, max(anmn_nrs_realtime_all_deployments_view.sensor_depth) AS max_depth FROM anmn_nrs_realtime_all_deployments_view GROUP BY anmn_nrs_realtime_all_deployments_view.platform_code ORDER BY anmn_nrs_realtime_all_deployments_view.platform_code;


ALTER TABLE report.anmn_nrs_realtime_data_summary_view OWNER TO postgres;

--
-- Name: anmn_platforms_manual_pkid_seq; Type: SEQUENCE; Schema: report; Owner: postgres
--

CREATE SEQUENCE anmn_platforms_manual_pkid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE report.anmn_platforms_manual_pkid_seq OWNER TO postgres;

--
-- Name: anmn_platforms_manual_pkid_seq; Type: SEQUENCE OWNED BY; Schema: report; Owner: postgres
--

ALTER SEQUENCE anmn_platforms_manual_pkid_seq OWNED BY anmn_platforms_manual.pkid;


--
-- Name: anmn_status_manual; Type: TABLE; Schema: report; Owner: postgres; Tablespace: 
--

CREATE TABLE anmn_status_manual (
    pkid integer NOT NULL,
    site_code character varying(10),
    platform_code character varying(30),
    deployment_code character varying(30),
    status_date date,
    status_type text,
    status_comment text,
    updated date
);


ALTER TABLE report.anmn_status_manual OWNER TO postgres;

--
-- Name: anmn_status_manual_pkid_seq; Type: SEQUENCE; Schema: report; Owner: postgres
--

CREATE SEQUENCE anmn_status_manual_pkid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE report.anmn_status_manual_pkid_seq OWNER TO postgres;

--
-- Name: anmn_status_manual_pkid_seq; Type: SEQUENCE OWNED BY; Schema: report; Owner: postgres
--

ALTER SEQUENCE anmn_status_manual_pkid_seq OWNED BY anmn_status_manual.pkid;


--
-- Name: argo_all_deployments_view; Type: VIEW; Schema: report; Owner: postgres
--

CREATE VIEW argo_all_deployments_view AS
    SELECT argo_float.data_centre AS organisation, CASE WHEN (argo_float.oxygen_sensor = false) THEN 'No oxygen sensor'::text ELSE 'Oxygen sensor'::text END AS oxygen_sensor, argo_float.platform_number AS platform_code, round((argo_float.min_lat)::numeric, 1) AS min_lat, round((argo_float.max_lat)::numeric, 1) AS max_lat, round((argo_float.min_long)::numeric, 1) AS min_lon, round((argo_float.max_long)::numeric, 1) AS max_lon, COALESCE(((round((argo_float.min_lat)::numeric, 1) || '/'::text) || round((argo_float.max_lat)::numeric, 1))) AS lat_range, COALESCE(((round((argo_float.min_long)::numeric, 1) || '/'::text) || round((argo_float.max_long)::numeric, 1))) AS lon_range, date(argo_float.start_date) AS start_date, date(argo_float.last_measure_date) AS end_date, round((((date_part('day'::text, (argo_float.last_measure_date - argo_float.start_date)))::integer)::numeric / 365.242), 1) AS coverage_duration, argo_float.pi_name, CASE WHEN (date_part('day'::text, (argo_float.last_measure_date - argo_float.start_date)) IS NULL) THEN 'Missing dates'::text WHEN (argo_float.uuid IS NULL) THEN 'No metadata'::text WHEN (argo_float.data_centre IS NULL) THEN 'No organisation'::text WHEN (argo_float.pi_name IS NULL) THEN 'No principal investigator'::text ELSE NULL::text END AS missing_info FROM argo.argo_float ORDER BY argo_float.data_centre, CASE WHEN (argo_float.oxygen_sensor = false) THEN 'No oxygen sensor'::text ELSE 'Oxygen sensor'::text END, argo_float.platform_number;


ALTER TABLE report.argo_all_deployments_view OWNER TO postgres;

--
-- Name: argo_data_summary_view; Type: VIEW; Schema: report; Owner: postgres
--

CREATE VIEW argo_data_summary_view AS
    SELECT argo_all_deployments_view.organisation, count(DISTINCT argo_all_deployments_view.platform_code) AS no_platforms, count(CASE WHEN (date_part('day'::text, (now() - (argo_all_deployments_view.end_date)::timestamp with time zone)) < (31)::double precision) THEN 1 ELSE NULL::integer END) AS no_active_floats, count(CASE WHEN (argo_all_deployments_view.oxygen_sensor = 'Oxygen sensor'::text) THEN 1 ELSE NULL::integer END) AS no_oxygen_platforms, count(CASE WHEN ((date_part('day'::text, (now() - (argo_all_deployments_view.end_date)::timestamp with time zone)) < (31)::double precision) AND (argo_all_deployments_view.oxygen_sensor = 'Oxygen sensor'::text)) THEN 1 ELSE NULL::integer END) AS no_active_oxygen_platforms, count(CASE WHEN (argo_all_deployments_view.missing_info IS NOT NULL) THEN 1 ELSE NULL::integer END) AS no_deployments_with_missing_info, min(argo_all_deployments_view.min_lat) AS min_lat, max(argo_all_deployments_view.max_lat) AS max_lat, min(argo_all_deployments_view.min_lon) AS min_lon, max(argo_all_deployments_view.max_lon) AS max_lon, COALESCE(((min(argo_all_deployments_view.min_lat) || '/'::text) || max(argo_all_deployments_view.max_lat))) AS lat_range, COALESCE(((min(argo_all_deployments_view.min_lon) || '/'::text) || max(argo_all_deployments_view.max_lon))) AS lon_range, min(argo_all_deployments_view.start_date) AS earliest_date, max(argo_all_deployments_view.end_date) AS latest_date, round(avg(argo_all_deployments_view.coverage_duration), 1) AS mean_coverage_duration FROM argo_all_deployments_view GROUP BY argo_all_deployments_view.organisation ORDER BY argo_all_deployments_view.organisation;


ALTER TABLE report.argo_data_summary_view OWNER TO postgres;

--
-- Name: auv_manual; Type: TABLE; Schema: report; Owner: postgres; Tablespace: 
--

CREATE TABLE auv_manual (
    campaign_code character varying(50) NOT NULL,
    campaign_uuid character varying(36),
    deployment_start timestamp without time zone,
    data_on_staging timestamp without time zone,
    data_on_opendap timestamp without time zone,
    data_on_portal timestamp without time zone,
    mest_creation timestamp without time zone,
    id bigint DEFAULT nextval('hibernate_sequence'::regclass) NOT NULL
);


ALTER TABLE report.auv_manual OWNER TO postgres;

--
-- Name: auv_all_deployments_view; Type: VIEW; Schema: report; Owner: postgres
--

CREATE VIEW auv_all_deployments_view AS
    SELECT "substring"((auv_manual.campaign_code)::text, '[^0-9]+'::text) AS location, auv_manual.campaign_code AS campaign, auv.site, auv_tracks.number_of_images AS no_images, round(((auv_tracks.distance)::numeric / (1000)::numeric), 1) AS distance, round((auv_tracks.geospatial_lat_min)::numeric, 1) AS lat_min, round((auv_tracks.geospatial_lon_min)::numeric, 1) AS lon_min, COALESCE(((round((auv_tracks.geospatial_vertical_min)::numeric, 1) || '/'::text) || round((auv_tracks.geospatial_vertical_max)::numeric, 1))) AS depth_range, date(auv_tracks.time_coverage_start) AS start_date, ((date_part('hours'::text, (auv_tracks.time_coverage_end - auv_tracks.time_coverage_start)) * (60)::double precision) + ((date_part('minutes'::text, (auv_tracks.time_coverage_end - auv_tracks.time_coverage_start)))::integer)::double precision) AS coverage_duration, (date_part('day'::text, (auv_manual.data_on_staging - auv_tracks.time_coverage_end)))::integer AS days_to_process_and_upload, (date_part('day'::text, (auv_manual.data_on_portal - auv_manual.data_on_staging)))::integer AS days_to_make_public, CASE WHEN (((((((((((((((((auv.site IS NULL) OR (auv_manual.campaign_code IS NULL)) OR (date_part('hours'::text, (auv_tracks.time_coverage_end - auv_tracks.time_coverage_start)) IS NULL)) OR (auv.metadata_campaign IS NULL)) OR ((auv_report.portal_visibility)::text <> 'Yes'::text)) OR ((auv_report.viewer_visibility)::text <> 'Yes'::text)) OR ((auv_report.geotiff)::text <> 'ALL_IMAGES'::text)) OR ((auv_report.mesh)::text <> 'Yes'::text)) OR ((auv_report.multibeam)::text <> 'Yes'::text)) OR ((auv_report.nc_cdom)::text <> 'Yes'::text)) OR ((auv_report.nc_cphl)::text <> 'Yes'::text)) OR ((auv_report.nc_opbs)::text <> 'Yes'::text)) OR ((auv_report.nc_psal)::text <> 'Yes'::text)) OR ((auv_report.nc_temp)::text <> 'Yes'::text)) OR ("substring"((auv_report.dive_track_csv_kml)::text, 'Yes'::text) <> 'Yes'::text)) OR ((auv_report.dive_report)::text <> 'Yes'::text)) OR ((auv_report.data_archived)::text <> 'Yes'::text)) THEN 'Missing information'::text ELSE NULL::text END AS missing_info, auv.metadata_campaign, auv.site_code, round((auv_tracks.geospatial_lat_max)::numeric, 1) AS lat_max, round((auv_tracks.geospatial_lon_max)::numeric, 1) AS lon_max, round((auv_tracks.geospatial_vertical_min)::numeric, 1) AS min_depth, round((auv_tracks.geospatial_vertical_max)::numeric, 1) AS max_depth, date(auv_tracks.time_coverage_end) AS end_date, date(auv_manual.data_on_staging) AS date_on_staging, date(auv_manual.data_on_opendap) AS date_on_opendap, date(auv_manual.data_on_portal) AS date_on_portal, auv_report.portal_visibility, auv_report.viewer_visibility, auv_report.geotiff, auv_report.mesh, auv_report.nc_cdom, auv_report.nc_cphl, auv_report.nc_opbs, auv_report.nc_psal, auv_report.nc_temp, auv_report.dive_track_csv_kml, auv_report.dive_report, auv_report.data_archived FROM (((auv.auv LEFT JOIN auv.auv_tracks ON (((auv_tracks.site_code)::text = (auv.site_code)::text))) LEFT JOIN auv_manual ON (((auv_manual.campaign_code)::text = (auv.campaign)::text))) LEFT JOIN auv.auv_report ON ((((auv.site_code)::text = (auv_report.site_code)::text) AND ((auv.campaign)::text = (auv_report.campaign_code)::text)))) WHERE (((auv_manual.campaign_code IS NOT NULL) OR (auv.site IS NOT NULL)) OR (auv_report.site_code IS NOT NULL)) ORDER BY "substring"((auv_manual.campaign_code)::text, '[^0-9]+'::text), auv_manual.campaign_code, auv.site;


ALTER TABLE report.auv_all_deployments_view OWNER TO postgres;

--
-- Name: auv_data_summary_view; Type: VIEW; Schema: report; Owner: postgres
--

CREATE VIEW auv_data_summary_view AS
    SELECT auv_all_deployments_view.location, count(DISTINCT CASE WHEN (auv_all_deployments_view.campaign IS NULL) THEN '1'::character varying ELSE auv_all_deployments_view.campaign END) AS no_campaigns, count(DISTINCT CASE WHEN (auv_all_deployments_view.site IS NULL) THEN '1'::character varying ELSE auv_all_deployments_view.site END) AS no_sites, count(CASE WHEN (auv_all_deployments_view.site IS NULL) THEN '1'::character varying ELSE auv_all_deployments_view.site END) AS no_deployments, sum(auv_all_deployments_view.no_images) AS total_no_images, sum(auv_all_deployments_view.distance) AS total_distance, COALESCE(((min(auv_all_deployments_view.lat_min) || '/'::text) || max(auv_all_deployments_view.lat_max))) AS lat_range, COALESCE(((min(auv_all_deployments_view.lon_min) || '/'::text) || max(auv_all_deployments_view.lon_max))) AS lon_range, COALESCE(((min(auv_all_deployments_view.min_depth) || '/'::text) || max(auv_all_deployments_view.max_depth))) AS depth_range, min(auv_all_deployments_view.start_date) AS earliest_date, max(auv_all_deployments_view.end_date) AS latest_date, round((sum((auv_all_deployments_view.coverage_duration)::numeric) / (60)::numeric), 1) AS data_duration, round(avg(auv_all_deployments_view.days_to_process_and_upload), 1) AS mean_days_to_process_and_upload, round(avg(auv_all_deployments_view.days_to_make_public), 1) AS mean_days_to_make_public, sum(CASE WHEN (auv_all_deployments_view.missing_info IS NOT NULL) THEN 1 ELSE 0 END) AS missing_info, min(auv_all_deployments_view.lat_min) AS lat_min, min(auv_all_deployments_view.lon_min) AS lon_min, max(auv_all_deployments_view.lat_max) AS lat_max, max(auv_all_deployments_view.lon_max) AS lon_max, min(auv_all_deployments_view.min_depth) AS min_depth, max(auv_all_deployments_view.max_depth) AS max_depth FROM auv_all_deployments_view GROUP BY auv_all_deployments_view.location ORDER BY auv_all_deployments_view.location;


ALTER TABLE report.auv_data_summary_view OWNER TO postgres;

--
-- Name: facility_summary; Type: TABLE; Schema: report; Owner: postgres; Tablespace: 
--

CREATE TABLE facility_summary (
    row_id integer NOT NULL,
    reporting_date timestamp without time zone,
    summary text,
    facility_name_id bigint,
    summary_item_id bigint
);


ALTER TABLE report.facility_summary OWNER TO postgres;

--
-- Name: facility_summary_item; Type: TABLE; Schema: report; Owner: postgres; Tablespace: 
--

CREATE TABLE facility_summary_item (
    row_id bigint NOT NULL,
    name character varying(120) NOT NULL
);


ALTER TABLE report.facility_summary_item OWNER TO postgres;

--
-- Name: facility_summary_item_row_id_seq; Type: SEQUENCE; Schema: report; Owner: postgres
--

CREATE SEQUENCE facility_summary_item_row_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE report.facility_summary_item_row_id_seq OWNER TO postgres;

--
-- Name: facility_summary_item_row_id_seq; Type: SEQUENCE OWNED BY; Schema: report; Owner: postgres
--

ALTER SEQUENCE facility_summary_item_row_id_seq OWNED BY facility_summary_item.row_id;


--
-- Name: facility_summary_row_id_seq; Type: SEQUENCE; Schema: report; Owner: postgres
--

CREATE SEQUENCE facility_summary_row_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 999999999999
    CACHE 1;


ALTER TABLE report.facility_summary_row_id_seq OWNER TO postgres;

--
-- Name: facility_summary_row_id_seq1; Type: SEQUENCE; Schema: report; Owner: postgres
--

CREATE SEQUENCE facility_summary_row_id_seq1
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE report.facility_summary_row_id_seq1 OWNER TO postgres;

--
-- Name: facility_summary_row_id_seq1; Type: SEQUENCE OWNED BY; Schema: report; Owner: postgres
--

ALTER SEQUENCE facility_summary_row_id_seq1 OWNED BY facility_summary.row_id;


--
-- Name: facility_summary_view; Type: VIEW; Schema: report; Owner: postgres
--

CREATE VIEW facility_summary_view AS
    SELECT facility.acronym AS facility_acronym, COALESCE(((to_char(to_timestamp((date_part('month'::text, facility_summary.reporting_date))::text, 'MM'::text), 'TMMon'::text) || ' '::text) || date_part('year'::text, facility_summary.reporting_date))) AS reporting_month, facility_summary.summary AS updates, facility_summary_item.name AS issues, facility_summary.reporting_date FROM ((facility_summary FULL JOIN public.facility ON ((facility_summary.facility_name_id = facility.id))) LEFT JOIN facility_summary_item ON ((facility_summary.summary_item_id = facility_summary_item.row_id))) ORDER BY facility.acronym, facility_summary.reporting_date DESC, facility_summary_item.name;


ALTER TABLE report.facility_summary_view OWNER TO postgres;

--
-- Name: faimms_manual; Type: TABLE; Schema: report; Owner: postgres; Tablespace: 
--

CREATE TABLE faimms_manual (
    site_name character varying(50) NOT NULL,
    deployment_start timestamp without time zone,
    data_on_staging timestamp without time zone,
    data_on_opendap timestamp without time zone,
    data_on_portal timestamp without time zone,
    mest_creation timestamp without time zone,
    id bigint DEFAULT nextval('hibernate_sequence'::regclass) NOT NULL
);


ALTER TABLE report.faimms_manual OWNER TO postgres;

--
-- Name: faimms_all_deployments_view; Type: VIEW; Schema: report; Owner: postgres
--

CREATE VIEW faimms_all_deployments_view AS
    SELECT DISTINCT s.site_code AS site_name, p.platform_code, COALESCE(((param.channelid || ' - '::text) || (param.parameter)::text)) AS sensor_code, (param.depth_sensor)::numeric AS sensor_depth, CASE WHEN (param.qaqc_boolean = 1) THEN true ELSE false END AS qaqc_data, CASE WHEN (date_part('day'::text, (param.time_coverage_end - param.time_coverage_start)) IS NULL) THEN 'Missing dates'::text WHEN (param.metadata_uuid IS NULL) THEN 'No metadata'::text ELSE NULL::text END AS missing_info, date(param.time_coverage_start) AS start_date, date(param.time_coverage_end) AS end_date, (date_part('day'::text, (param.time_coverage_end - param.time_coverage_start)))::numeric AS coverage_duration, (date_part('day'::text, (m.data_on_staging - m.deployment_start)))::numeric AS days_to_process_and_upload, (date_part('day'::text, (m.data_on_portal - m.data_on_staging)))::numeric AS days_to_make_public, param.sensor_name, param.parameter, param.channelid AS channel_id, param.no_qaqc_boolean AS no_qaqc_data, date(m.deployment_start) AS deployment_start, date(m.data_on_staging) AS date_on_staging, date(m.data_on_opendap) AS date_on_opendap, date(m.data_on_portal) AS date_on_portal, m.mest_creation, param.metadata_uuid AS channel_uuid FROM faimms.faimms_sites s, faimms.faimms_platforms p, faimms.faimms_parameters param, faimms_manual m WHERE ((((m.site_name)::text = (s.site_code)::text) AND (s.pkid = p.fk_faimms_sites)) AND (p.pkid = param.fk_faimms_platforms)) ORDER BY s.site_code, p.platform_code, COALESCE(((param.channelid || ' - '::text) || (param.parameter)::text));


ALTER TABLE report.faimms_all_deployments_view OWNER TO postgres;

--
-- Name: faimms_data_summary_view; Type: VIEW; Schema: report; Owner: postgres
--

CREATE VIEW faimms_data_summary_view AS
    SELECT faimms_all_deployments_view.site_name, count(DISTINCT faimms_all_deployments_view.platform_code) AS no_platforms, count(DISTINCT faimms_all_deployments_view.sensor_code) AS no_sensors, count(DISTINCT faimms_all_deployments_view.parameter) AS no_parameters, sum(CASE WHEN (faimms_all_deployments_view.qaqc_data = true) THEN 1 ELSE 0 END) AS no_qc_data, COALESCE(((min(faimms_all_deployments_view.sensor_depth) || '-'::text) || max(faimms_all_deployments_view.sensor_depth))) AS depth_range, min(faimms_all_deployments_view.start_date) AS earliest_date, max(faimms_all_deployments_view.end_date) AS latest_date, round(avg(faimms_all_deployments_view.coverage_duration), 1) AS mean_coverage_duration, round(avg(faimms_all_deployments_view.days_to_process_and_upload), 1) AS mean_days_to_process_and_upload, round(avg(faimms_all_deployments_view.days_to_make_public), 1) AS mean_days_to_make_public, sum(CASE WHEN (faimms_all_deployments_view.missing_info IS NULL) THEN 0 ELSE 1 END) AS no_missing_info, min(faimms_all_deployments_view.sensor_depth) AS min_depth, max(faimms_all_deployments_view.sensor_depth) AS max_depth FROM faimms_all_deployments_view GROUP BY faimms_all_deployments_view.site_name ORDER BY faimms_all_deployments_view.site_name;


ALTER TABLE report.faimms_data_summary_view OWNER TO postgres;

--
-- Name: soop_asf_manual; Type: TABLE; Schema: report; Owner: postgres; Tablespace: 
--

CREATE TABLE soop_asf_manual (
    vessel_name character varying(50) NOT NULL,
    platform_code character varying(10),
    platform_uuid character varying(36),
    deployment_start timestamp without time zone,
    data_on_staging timestamp without time zone,
    data_on_opendap timestamp without time zone,
    data_on_portal timestamp without time zone,
    mest_creation timestamp without time zone,
    id bigint NOT NULL
);


ALTER TABLE report.soop_asf_manual OWNER TO postgres;

--
-- Name: soop_ba_manual; Type: TABLE; Schema: report; Owner: postgres; Tablespace: 
--

CREATE TABLE soop_ba_manual (
    deployment_id character varying(50) NOT NULL,
    vessel_name character varying(50),
    data_on_staging timestamp without time zone,
    data_on_opendap timestamp without time zone,
    data_on_portal timestamp without time zone,
    mest_creation timestamp without time zone,
    id bigint
);


ALTER TABLE report.soop_ba_manual OWNER TO postgres;

--
-- Name: soop_co2_manual; Type: TABLE; Schema: report; Owner: postgres; Tablespace: 
--

CREATE TABLE soop_co2_manual (
    deployment_id character varying(50) NOT NULL,
    deployment_start timestamp without time zone,
    data_on_staging timestamp without time zone,
    data_on_opendap timestamp without time zone,
    data_on_portal timestamp without time zone,
    mest_creation timestamp without time zone,
    id bigint
);


ALTER TABLE report.soop_co2_manual OWNER TO postgres;

--
-- Name: soop_sst_manual; Type: TABLE; Schema: report; Owner: postgres; Tablespace: 
--

CREATE TABLE soop_sst_manual (
    vessel_name character varying(50) NOT NULL,
    platform_code character varying(10),
    platform_uuid character varying(36),
    deployment_start timestamp without time zone,
    data_on_staging timestamp without time zone,
    data_on_opendap timestamp without time zone,
    data_on_portal timestamp without time zone,
    mest_creation timestamp without time zone,
    id bigint
);


ALTER TABLE report.soop_sst_manual OWNER TO postgres;

--
-- Name: soop_tmv_manual; Type: TABLE; Schema: report; Owner: postgres; Tablespace: 
--

CREATE TABLE soop_tmv_manual (
    bundle_id character varying(50) NOT NULL,
    data_on_staging timestamp without time zone,
    data_on_opendap timestamp without time zone,
    data_on_portal timestamp without time zone,
    vessel_name character varying(100),
    start_date date,
    end_date date,
    id bigint
);


ALTER TABLE report.soop_tmv_manual OWNER TO postgres;

--
-- Name: soop_trv_manual; Type: TABLE; Schema: report; Owner: postgres; Tablespace: 
--

CREATE TABLE soop_trv_manual (
    cruise_id character varying(50) NOT NULL,
    data_on_staging timestamp without time zone,
    data_on_opendap timestamp without time zone,
    data_on_portal timestamp without time zone,
    id bigint
);


ALTER TABLE report.soop_trv_manual OWNER TO postgres;

--
-- Name: soop_xbt; Type: TABLE; Schema: report; Owner: postgres; Tablespace: 
--

CREATE TABLE soop_xbt (
    p_id integer DEFAULT nextval('hibernate_sequence'::regclass) NOT NULL,
    line_name character varying(50),
    year character varying(4),
    number_of_profile integer,
    bundle_id character varying(100)
);


ALTER TABLE report.soop_xbt OWNER TO postgres;

--
-- Name: soop_xbt_manual; Type: TABLE; Schema: report; Owner: postgres; Tablespace: 
--

CREATE TABLE soop_xbt_manual (
    bundle_id character varying(100) NOT NULL,
    data_on_staging timestamp without time zone,
    data_on_opendap timestamp without time zone,
    data_on_portal timestamp without time zone,
    id bigint DEFAULT nextval('hibernate_sequence'::regclass) NOT NULL
);


ALTER TABLE report.soop_xbt_manual OWNER TO postgres;

--
-- Name: soop_all_deployments_view; Type: VIEW; Schema: report; Owner: postgres
--

CREATE VIEW soop_all_deployments_view AS
    WITH interm_table AS (SELECT soop_tmv_mv.time_coverage_start, CASE WHEN ((date(soop_tmv_mv.time_coverage_start) >= '2008-08-01'::date) AND (date(soop_tmv_mv.time_coverage_start) < '2009-01-15'::date)) THEN 'Aug08-Jan09'::text WHEN ((date(soop_tmv_mv.time_coverage_start) >= '2011-08-11'::date) AND (date(soop_tmv_mv.time_coverage_start) < '2011-12-19'::date)) THEN 'Aug11-Dec11'::text WHEN ((date(soop_tmv_mv.time_coverage_start) >= '2011-12-19'::date) AND (date(soop_tmv_mv.time_coverage_start) < '2012-02-01'::date)) THEN 'Dec11-Feb12'::text WHEN ((date(soop_tmv_mv.time_coverage_start) >= '2009-01-16'::date) AND (date(soop_tmv_mv.time_coverage_start) < '2009-07-31'::date)) THEN 'Jan09-Jul09'::text WHEN ((date(soop_tmv_mv.time_coverage_start) >= '2011-01-11'::date) AND (date(soop_tmv_mv.time_coverage_start) < '2011-07-11'::date)) THEN 'Jan11-Jun11'::text WHEN ((date(soop_tmv_mv.time_coverage_start) >= '2010-07-01'::date) AND (date(soop_tmv_mv.time_coverage_start) < '2011-01-11'::date)) THEN 'Jul10-Jan11'::text WHEN ((date(soop_tmv_mv.time_coverage_start) >= '2009-09-01'::date) AND (date(soop_tmv_mv.time_coverage_start) < '2010-06-30'::date)) THEN 'Sep09-Jun10'::text ELSE NULL::text END AS bundle_id FROM soop.soop_tmv_mv), interm_table_xbt AS (SELECT soop_xbt.line_name, soop_xbt.year, soop_xbt.bundle_id, sum(soop_xbt.number_of_profile) AS no_profiles FROM soop_xbt GROUP BY soop_xbt.line_name, soop_xbt.bundle_id, soop_xbt.year ORDER BY soop_xbt.line_name, soop_xbt.bundle_id) (((((SELECT 'ASF (near real-time & delayed-mode)'::text AS subfacility, soop_asf_manual.vessel_name, NULL::character varying AS deployment_id, NULL::text AS year, count(soop_asf_mv.callsign) AS no_data_files, NULL::bigint AS no_profiles, COALESCE(((round((min(soop_asf_mv.geospatial_lat_min))::numeric, 1) || '/'::text) || round((max(soop_asf_mv.geospatial_lat_max))::numeric, 1))) AS lat_range, COALESCE(((round((min(soop_asf_mv.geospatial_lon_min))::numeric, 1) || '/'::text) || round((max(soop_asf_mv.geospatial_lon_max))::numeric, 1))) AS lon_range, COALESCE(((round((min(soop_asf_mv.geospatial_vertical_min))::numeric, 1) || '/'::text) || round((max(soop_asf_mv.geospatial_vertical_max))::numeric, 1))) AS depth_range, date(min(soop_asf_mv.time_coverage_start)) AS start_date, date(max(soop_asf_mv.time_coverage_end)) AS end_date, (date_part('day'::text, (max(soop_asf_mv.time_coverage_end) - min(soop_asf_mv.time_coverage_start))))::numeric AS coverage_duration, (date_part('day'::text, (min(soop_asf_manual.data_on_staging) - (date(min(soop_asf_mv.time_coverage_start)))::timestamp without time zone)))::numeric AS days_to_process_and_upload, (date_part('day'::text, (soop_asf_manual.data_on_portal - soop_asf_manual.data_on_staging)))::numeric AS days_to_make_public, CASE WHEN (((date_part('day'::text, (min(soop_asf_manual.data_on_staging) - (date(min(soop_asf_mv.time_coverage_start)))::timestamp without time zone)))::numeric IS NULL) OR ((date_part('day'::text, (soop_asf_manual.data_on_portal - soop_asf_manual.data_on_staging)))::numeric IS NULL)) THEN 'Missing dates'::text WHEN (sum(CASE WHEN (soop_asf_mv.dataset_uuid IS NULL) THEN 0 ELSE 1 END) <> count(soop_asf_mv.callsign)) THEN 'No metadata'::text ELSE NULL::text END AS missing_info, round((min(soop_asf_mv.geospatial_lat_min))::numeric, 1) AS min_lat, round((max(soop_asf_mv.geospatial_lat_max))::numeric, 1) AS max_lat, round((min(soop_asf_mv.geospatial_lon_min))::numeric, 1) AS min_lon, round((max(soop_asf_mv.geospatial_lon_max))::numeric, 1) AS max_lon, round((min(soop_asf_mv.geospatial_vertical_min))::numeric, 1) AS min_depth, round((max(soop_asf_mv.geospatial_vertical_max))::numeric, 1) AS max_depth, date(soop_asf_manual.data_on_portal) AS data_on_portal FROM (soop.soop_asf_mv LEFT JOIN soop_asf_manual ON ((soop_asf_mv.callsign = (soop_asf_manual.platform_code)::text))) GROUP BY 'ASF (near real-time & delayed-mode)'::text, soop_asf_manual.vessel_name, soop_asf_manual.data_on_portal, soop_asf_manual.data_on_staging UNION ALL SELECT 'BA (delayed-mode)'::text AS subfacility, soop_ba_manual.vessel_name, soop_ba_manual.deployment_id, NULL::text AS year, count(soop_ba_manual.deployment_id) AS no_data_files, NULL::bigint AS no_profiles, COALESCE(((round((min(soop_ba_mv.geospatial_lat_min))::numeric, 1) || '/'::text) || round((max(soop_ba_mv.geospatial_lat_max))::numeric, 1))) AS lat_range, COALESCE(((round((min(soop_ba_mv.geospatial_lon_min))::numeric, 1) || '/'::text) || round((max(soop_ba_mv.geospatial_lon_max))::numeric, 1))) AS lon_range, COALESCE(((round((min(soop_ba_mv.geospatial_vertical_min))::numeric, 1) || '/'::text) || round((max(soop_ba_mv.geospatial_vertical_max))::numeric, 1))) AS depth_range, date(min(soop_ba_mv.time_coverage_start)) AS start_date, date(max(soop_ba_mv.time_coverage_end)) AS end_date, (date_part('day'::text, (max(soop_ba_mv.time_coverage_end) - min(soop_ba_mv.time_coverage_start))))::numeric AS coverage_duration, round(avg((date_part('day'::text, (soop_ba_manual.data_on_staging - (date(soop_ba_mv.time_coverage_start))::timestamp without time zone)))::numeric), 1) AS days_to_process_and_upload, round(avg((date_part('day'::text, (soop_ba_manual.data_on_portal - soop_ba_manual.data_on_staging)))::numeric), 1) AS days_to_make_public, CASE WHEN (((date_part('day'::text, (min(soop_ba_manual.data_on_staging) - (date(min(soop_ba_mv.time_coverage_start)))::timestamp without time zone)))::numeric IS NULL) OR (round(avg((date_part('day'::text, (soop_ba_manual.data_on_portal - soop_ba_manual.data_on_staging)))::numeric), 1) IS NULL)) THEN 'Missing dates'::text WHEN (sum(CASE WHEN (soop_ba_mv.dataset_uuid IS NULL) THEN 0 ELSE 1 END) <> count(soop_ba_mv.cruise_id)) THEN 'No metadata'::text WHEN (sum(CASE WHEN (soop_ba_manual.mest_creation IS NULL) THEN 0 ELSE 1 END) <> count(soop_ba_mv.vessel_name)) THEN 'No metadata'::text ELSE NULL::text END AS missing_info, round((min(soop_ba_mv.geospatial_lat_min))::numeric, 1) AS min_lat, round((max(soop_ba_mv.geospatial_lat_max))::numeric, 1) AS max_lat, round((min(soop_ba_mv.geospatial_lon_min))::numeric, 1) AS min_lon, round((max(soop_ba_mv.geospatial_lon_max))::numeric, 1) AS max_lon, round((min(soop_ba_mv.geospatial_vertical_min))::numeric, 1) AS min_depth, round((max(soop_ba_mv.geospatial_vertical_max))::numeric, 1) AS max_depth, date(soop_ba_manual.data_on_portal) AS data_on_portal FROM (soop.soop_ba_mv FULL JOIN soop_ba_manual ON ((soop_ba_mv.cruise_id = (soop_ba_manual.deployment_id)::text))) GROUP BY 'BA (delayed-mode)'::text, soop_ba_manual.vessel_name, soop_ba_manual.deployment_id, soop_ba_manual.data_on_portal) UNION ALL SELECT 'CO2 (delayed-mode)'::text AS subfacility, soop_co2_mv.vessel_name, soop_co2_mv.cruise_id AS deployment_id, NULL::text AS year, NULL::bigint AS no_data_files, NULL::bigint AS no_profiles, COALESCE(((round((soop_co2_mv.geospatial_lat_min)::numeric, 1) || '/'::text) || round((soop_co2_mv.geospatial_lat_max)::numeric, 1))) AS lat_range, COALESCE(((round((soop_co2_mv.geospatial_lon_min)::numeric, 1) || '/'::text) || round((soop_co2_mv.geospatial_lon_max)::numeric, 1))) AS lon_range, COALESCE(((round((soop_co2_mv.geospatial_vertical_min)::numeric, 1) || '/'::text) || round((soop_co2_mv.geospatial_vertical_max)::numeric, 1))) AS depth_range, date(soop_co2_mv.time_coverage_start) AS start_date, date(soop_co2_mv.time_coverage_end) AS end_date, (date_part('day'::text, (soop_co2_mv.time_coverage_end - soop_co2_mv.time_coverage_start)))::numeric AS coverage_duration, (date_part('day'::text, (soop_co2_manual.data_on_staging - (date(soop_co2_mv.time_coverage_start))::timestamp without time zone)))::numeric AS days_to_process_and_upload, (date_part('day'::text, (soop_co2_manual.data_on_portal - soop_co2_manual.data_on_staging)))::numeric AS days_to_make_public, CASE WHEN (((date_part('day'::text, (soop_co2_manual.data_on_staging - (date(soop_co2_mv.time_coverage_start))::timestamp without time zone)))::numeric IS NULL) OR ((date_part('day'::text, (soop_co2_manual.data_on_portal - soop_co2_manual.data_on_staging)))::numeric IS NULL)) THEN 'Missing dates'::text WHEN (soop_co2_manual.mest_creation IS NULL) THEN 'No metadata'::text WHEN (soop_co2_mv.dataset_uuid IS NULL) THEN 'No metadata'::text ELSE NULL::text END AS missing_info, round((soop_co2_mv.geospatial_lat_min)::numeric, 1) AS min_lat, round((soop_co2_mv.geospatial_lat_max)::numeric, 1) AS max_lat, round((soop_co2_mv.geospatial_lon_min)::numeric, 1) AS min_lon, round((soop_co2_mv.geospatial_lon_max)::numeric, 1) AS max_lon, round((soop_co2_mv.geospatial_vertical_min)::numeric, 1) AS min_depth, round((soop_co2_mv.geospatial_vertical_max)::numeric, 1) AS max_depth, date(soop_co2_manual.data_on_portal) AS data_on_portal FROM (soop.soop_co2_mv FULL JOIN soop_co2_manual ON ((soop_co2_mv.cruise_id = (soop_co2_manual.deployment_id)::text)))) UNION ALL SELECT 'SST (near real-time & delayed-mode)'::text AS subfacility, soop_sst_manual.vessel_name, NULL::character varying AS deployment_id, NULL::text AS year, count(DISTINCT soop_sst_mv.id) AS no_data_files, NULL::bigint AS no_profiles, COALESCE(((round((min(soop_sst_mv.geospatial_lat_min))::numeric, 1) || '/'::text) || round((max(soop_sst_mv.geospatial_lat_max))::numeric, 1))) AS lat_range, COALESCE(((round((min(soop_sst_mv.geospatial_lon_min))::numeric, 1) || '/'::text) || round((max(soop_sst_mv.geospatial_lon_max))::numeric, 1))) AS lon_range, COALESCE(((round((min(soop_sst_mv.geospatial_vertical_min))::numeric, 1) || '/'::text) || round((max(soop_sst_mv.geospatial_vertical_max))::numeric, 1))) AS depth_range, date(min(soop_sst_mv.time_coverage_start)) AS start_date, date(max(soop_sst_mv.time_coverage_end)) AS end_date, (date_part('day'::text, (max(soop_sst_mv.time_coverage_end) - min(soop_sst_mv.time_coverage_start))))::numeric AS coverage_duration, (date_part('day'::text, (min(soop_sst_manual.data_on_staging) - (date(min(soop_sst_mv.time_coverage_start)))::timestamp without time zone)))::numeric AS days_to_process_and_upload, round(avg((date_part('day'::text, (soop_sst_manual.data_on_portal - soop_sst_manual.data_on_staging)))::numeric), 1) AS days_to_make_public, CASE WHEN (((date_part('day'::text, (min(soop_sst_manual.data_on_staging) - (date(min(soop_sst_mv.time_coverage_start)))::timestamp without time zone)))::numeric IS NULL) OR (round(avg((date_part('day'::text, (soop_sst_manual.data_on_portal - soop_sst_manual.data_on_staging)))::numeric), 1) IS NULL)) THEN 'Missing dates'::text WHEN (soop_sst_manual.mest_creation IS NULL) THEN 'No metadata'::text WHEN (sum(CASE WHEN (soop_sst_mv.dataset_uuid IS NULL) THEN 0 ELSE 1 END) <> count(soop_sst_mv.id)) THEN 'No metadata'::text ELSE NULL::text END AS missing_info, round((min(soop_sst_mv.geospatial_lat_min))::numeric, 1) AS min_lat, round((max(soop_sst_mv.geospatial_lat_max))::numeric, 1) AS max_lat, round((min(soop_sst_mv.geospatial_lon_min))::numeric, 1) AS min_lon, round((max(soop_sst_mv.geospatial_lon_max))::numeric, 1) AS max_lon, round((min(soop_sst_mv.geospatial_vertical_min))::numeric, 1) AS min_depth, round((max(soop_sst_mv.geospatial_vertical_max))::numeric, 1) AS max_depth, date(soop_sst_manual.data_on_portal) AS data_on_portal FROM (soop_sst_manual FULL JOIN soop.soop_sst_mv ON ((soop_sst_mv.vessel_name = (soop_sst_manual.vessel_name)::text))) GROUP BY 'SST (near real-time & delayed-mode)'::text, soop_sst_manual.vessel_name, soop_sst_manual.mest_creation, soop_sst_manual.data_on_portal) UNION ALL SELECT 'TMV (delayed-mode)'::text AS subfacility, soop_tmv_manual.vessel_name, soop_tmv_manual.bundle_id AS deployment_id, NULL::text AS year, count(interm_table.bundle_id) AS no_data_files, NULL::bigint AS no_profiles, COALESCE(((round((min(soop_tmv_mv.geospatial_lat_min))::numeric, 1) || '/'::text) || round((max(soop_tmv_mv.geospatial_lat_max))::numeric, 1))) AS lat_range, COALESCE(((round((min(soop_tmv_mv.geospatial_lon_min))::numeric, 1) || '/'::text) || round((max(soop_tmv_mv.geospatial_lon_max))::numeric, 1))) AS lon_range, COALESCE(((round((min(soop_tmv_mv.geospatial_vertical_min))::numeric, 1) || '/'::text) || round((max(soop_tmv_mv.geospatial_vertical_max))::numeric, 1))) AS depth_range, date(min(soop_tmv_mv.time_coverage_start)) AS start_date, date(max(soop_tmv_mv.time_coverage_end)) AS end_date, (date_part('day'::text, (max(soop_tmv_mv.time_coverage_end) - min(soop_tmv_mv.time_coverage_start))))::numeric AS coverage_duration, (date_part('day'::text, (min(soop_tmv_manual.data_on_staging) - (date(min(soop_tmv_mv.time_coverage_start)))::timestamp without time zone)))::numeric AS days_to_process_and_upload, round(avg((date_part('day'::text, (soop_tmv_manual.data_on_portal - soop_tmv_manual.data_on_staging)))::numeric), 1) AS days_to_make_public, CASE WHEN (((date_part('day'::text, (min(soop_tmv_manual.data_on_staging) - (date(min(soop_tmv_mv.time_coverage_start)))::timestamp without time zone)))::numeric IS NULL) OR (round(avg((date_part('day'::text, (soop_tmv_manual.data_on_portal - soop_tmv_manual.data_on_staging)))::numeric), 1) IS NULL)) THEN 'Missing dates'::text WHEN (sum(CASE WHEN (soop_tmv_mv.dataset_uuid IS NULL) THEN 0 ELSE 1 END) <> count(soop_tmv_mv.id)) THEN 'No metadata'::text ELSE NULL::text END AS missing_info, round((min(soop_tmv_mv.geospatial_lat_min))::numeric, 1) AS min_lat, round((max(soop_tmv_mv.geospatial_lat_max))::numeric, 1) AS max_lat, round((min(soop_tmv_mv.geospatial_lon_min))::numeric, 1) AS min_lon, round((max(soop_tmv_mv.geospatial_lon_max))::numeric, 1) AS max_lon, round((min(soop_tmv_mv.geospatial_vertical_min))::numeric, 1) AS min_depth, round((max(soop_tmv_mv.geospatial_vertical_max))::numeric, 1) AS max_depth, date(soop_tmv_manual.data_on_portal) AS data_on_portal FROM ((soop.soop_tmv_mv LEFT JOIN interm_table ON ((interm_table.time_coverage_start = soop_tmv_mv.time_coverage_start))) FULL JOIN soop_tmv_manual ON ((interm_table.bundle_id = (soop_tmv_manual.bundle_id)::text))) WHERE (soop_tmv_manual.vessel_name IS NOT NULL) GROUP BY 'TMV (delayed-mode)'::text, soop_tmv_manual.vessel_name, soop_tmv_manual.bundle_id, soop_tmv_manual.data_on_portal) UNION ALL SELECT 'TRV (delayed-mode)'::text AS subfacility, soop_trv_mv.vessel_name, soop_trv_mv.cruise_id AS deployment_id, NULL::text AS year, count(soop_trv_mv.cruise_id) AS no_data_files, NULL::bigint AS no_profiles, COALESCE(((round((min(soop_trv_mv.geospatial_lat_min))::numeric, 1) || '/'::text) || round((max(soop_trv_mv.geospatial_lat_max))::numeric, 1))) AS lat_range, COALESCE(((round((min(soop_trv_mv.geospatial_lon_min))::numeric, 1) || '/'::text) || round((max(soop_trv_mv.geospatial_lon_max))::numeric, 1))) AS lon_range, COALESCE(((round((min(soop_trv_mv.geospatial_vertical_min))::numeric, 1) || '/'::text) || round((max(soop_trv_mv.geospatial_vertical_max))::numeric, 1))) AS depth_range, date(min(soop_trv_mv.time_coverage_start)) AS start_date, date(max(soop_trv_mv.time_coverage_end)) AS end_date, (date_part('day'::text, (max(soop_trv_mv.time_coverage_end) - min(soop_trv_mv.time_coverage_start))))::numeric AS coverage_duration, (date_part('day'::text, (min(soop_trv_manual.data_on_staging) - (date(min(soop_trv_mv.time_coverage_start)))::timestamp without time zone)))::numeric AS days_to_process_and_upload, round(avg((date_part('day'::text, (soop_trv_manual.data_on_portal - soop_trv_manual.data_on_staging)))::numeric), 1) AS days_to_make_public, CASE WHEN (((date_part('day'::text, (min(soop_trv_manual.data_on_staging) - (date(min(soop_trv_mv.time_coverage_start)))::timestamp without time zone)))::numeric IS NULL) OR (round(avg((date_part('day'::text, (soop_trv_manual.data_on_portal - soop_trv_manual.data_on_staging)))::numeric), 1) IS NULL)) THEN 'Missing dates'::text WHEN (sum(CASE WHEN (soop_trv_mv.dataset_uuid IS NULL) THEN 0 ELSE 1 END) <> sum(CASE WHEN (soop_trv_mv.id IS NOT NULL) THEN 1 ELSE 0 END)) THEN 'No metadata'::text ELSE NULL::text END AS missing_info, round((min(soop_trv_mv.geospatial_lat_min))::numeric, 1) AS min_lat, round((max(soop_trv_mv.geospatial_lat_max))::numeric, 1) AS max_lat, round((min(soop_trv_mv.geospatial_lon_min))::numeric, 1) AS min_lon, round((max(soop_trv_mv.geospatial_lon_max))::numeric, 1) AS max_lon, round((min(soop_trv_mv.geospatial_vertical_min))::numeric, 1) AS min_depth, round((max(soop_trv_mv.geospatial_vertical_max))::numeric, 1) AS max_depth, date(soop_trv_manual.data_on_portal) AS data_on_portal FROM (soop.soop_trv_mv FULL JOIN soop_trv_manual ON ((soop_trv_mv.cruise_id = (soop_trv_manual.cruise_id)::text))) GROUP BY 'TRV (delayed-mode)'::text, soop_trv_mv.vessel_name, soop_trv_mv.cruise_id, soop_trv_manual.data_on_portal) UNION ALL SELECT DISTINCT 'XBT (near real-time & delayed-mode)'::text AS subfacility, COALESCE(((soop_xbt_mv.xbt_line || ' | '::text) || soop_xbt_mv.xbt_line_description)) AS vessel_name, interm_table_xbt.bundle_id AS deployment_id, interm_table_xbt.year, count(DISTINCT soop_xbt_mv.xbt_cruise_id) AS no_data_files, interm_table_xbt.no_profiles, COALESCE(((round((min(soop_xbt_mv.geospatial_lat_min))::numeric, 1) || '/'::text) || CASE WHEN (round((max(soop_xbt_mv.geospatial_lat_max))::numeric, 1) > (180)::numeric) THEN 23.4 ELSE round((max(soop_xbt_mv.geospatial_lat_max))::numeric, 1) END)) AS lat_range, COALESCE(((round((min(soop_xbt_mv.geospatial_lon_min))::numeric, 1) || '/'::text) || CASE WHEN (round((max(soop_xbt_mv.geospatial_lon_max))::numeric, 1) > (180)::numeric) THEN 135.8 ELSE round((max(soop_xbt_mv.geospatial_lon_max))::numeric, 1) END)) AS lon_range, COALESCE(((round((min(soop_xbt_mv.geospatial_vertical_min))::numeric, 1) || '/'::text) || round((max(soop_xbt_mv.geospatial_vertical_max))::numeric, 1))) AS depth_range, date(min(soop_xbt_mv.launch_date)) AS start_date, date(max(soop_xbt_mv.launch_date)) AS end_date, (date_part('day'::text, (max(soop_xbt_mv.launch_date) - min(soop_xbt_mv.launch_date))))::numeric AS coverage_duration, (date_part('day'::text, (min(soop_xbt_manual.data_on_staging) - (date(min(soop_xbt_mv.launch_date)))::timestamp without time zone)))::numeric AS days_to_process_and_upload, round(avg((date_part('day'::text, (soop_xbt_manual.data_on_portal - soop_xbt_manual.data_on_staging)))::numeric), 1) AS days_to_make_public, CASE WHEN ((((date_part('day'::text, (min(soop_xbt_manual.data_on_staging) - (date(min(soop_xbt_mv.launch_date)))::timestamp without time zone)))::numeric IS NULL) OR (avg((date_part('day'::text, (soop_xbt_manual.data_on_portal - soop_xbt_manual.data_on_staging)))::numeric) IS NULL)) OR (sum(CASE WHEN (soop_xbt_mv.launch_date IS NULL) THEN 0 ELSE 1 END) <> count(soop_xbt_mv.xbt_line))) THEN 'Missing dates'::text WHEN (sum(CASE WHEN (soop_xbt_mv.uuid IS NULL) THEN 0 ELSE 1 END) <> count(soop_xbt_mv.xbt_line)) THEN 'No metadata'::text ELSE NULL::text END AS missing_info, round((min(soop_xbt_mv.geospatial_lat_min))::numeric, 1) AS min_lat, CASE WHEN (round((max(soop_xbt_mv.geospatial_lat_max))::numeric, 1) > (180)::numeric) THEN 23.4 ELSE round((max(soop_xbt_mv.geospatial_lat_max))::numeric, 1) END AS max_lat, round((min(soop_xbt_mv.geospatial_lon_min))::numeric, 1) AS min_lon, CASE WHEN (round((max(soop_xbt_mv.geospatial_lon_max))::numeric, 1) > (180)::numeric) THEN 135.8 ELSE round((max(soop_xbt_mv.geospatial_lon_max))::numeric, 1) END AS max_lon, round((min(soop_xbt_mv.geospatial_vertical_min))::numeric, 1) AS min_depth, round((max(soop_xbt_mv.geospatial_vertical_max))::numeric, 1) AS max_depth, date(soop_xbt_manual.data_on_portal) AS data_on_portal FROM ((soop.soop_xbt_mv LEFT JOIN interm_table_xbt ON (((soop_xbt_mv.xbt_line = (interm_table_xbt.line_name)::text) AND ((interm_table_xbt.year)::bpchar = (date_part('year'::text, soop_xbt_mv.launch_date))::character(4))))) LEFT JOIN soop_xbt_manual ON (((interm_table_xbt.bundle_id)::text = (soop_xbt_manual.bundle_id)::text))) GROUP BY 'XBT (near real-time & delayed-mode)'::text, soop_xbt_mv.xbt_line, soop_xbt_mv.xbt_line_description, interm_table_xbt.year, interm_table_xbt.bundle_id, interm_table_xbt.no_profiles, soop_xbt_manual.data_on_portal ORDER BY 1, 2, 3, 4;


ALTER TABLE report.soop_all_deployments_view OWNER TO postgres;

--
-- Name: soop_cpr_manual; Type: TABLE; Schema: report; Owner: postgres; Tablespace: 
--

CREATE TABLE soop_cpr_manual (
    cruise_id character varying(50) NOT NULL,
    data_on_staging timestamp without time zone,
    data_on_opendap timestamp without time zone,
    data_on_portal timestamp without time zone,
    mest_creation timestamp without time zone,
    mest_uuid character varying(36),
    cruise_name character varying(50),
    id bigint
);


ALTER TABLE report.soop_cpr_manual OWNER TO postgres;

--
-- Name: soop_cpr_all_deployments_view; Type: VIEW; Schema: report; Owner: postgres
--

CREATE VIEW soop_cpr_all_deployments_view AS
    WITH interm_table_phyto AS (SELECT DISTINCT csiro_harvest_phyto.date_time_utc, count(DISTINCT csiro_harvest_phyto.date_time_utc) AS no_phyto_samples FROM cpr.csiro_harvest_phyto GROUP BY csiro_harvest_phyto.date_time_utc ORDER BY csiro_harvest_phyto.date_time_utc), interm_table_zoop AS (SELECT DISTINCT csiro_harvest_zoop.date_time_utc, count(DISTINCT csiro_harvest_zoop.date_time_utc) AS no_zoop_samples FROM cpr.csiro_harvest_zoop GROUP BY csiro_harvest_zoop.date_time_utc ORDER BY csiro_harvest_zoop.date_time_utc), interm_table_pci AS (SELECT DISTINCT csiro_harvest_pci.vessel_name, CASE WHEN ((csiro_harvest_pci.start_port)::text < (csiro_harvest_pci.end_port)::text) THEN (((csiro_harvest_pci.start_port)::text || '-'::text) || (csiro_harvest_pci.end_port)::text) ELSE (((csiro_harvest_pci.end_port)::text || '-'::text) || (csiro_harvest_pci.start_port)::text) END AS route, csiro_harvest_pci.date_time_utc, count(DISTINCT csiro_harvest_pci.date_time_utc) AS no_pci_samples FROM cpr.csiro_harvest_pci GROUP BY csiro_harvest_pci.vessel_name, CASE WHEN ((csiro_harvest_pci.start_port)::text < (csiro_harvest_pci.end_port)::text) THEN (((csiro_harvest_pci.start_port)::text || '-'::text) || (csiro_harvest_pci.end_port)::text) ELSE (((csiro_harvest_pci.end_port)::text || '-'::text) || (csiro_harvest_pci.start_port)::text) END, csiro_harvest_pci.date_time_utc ORDER BY csiro_harvest_pci.vessel_name, CASE WHEN ((csiro_harvest_pci.start_port)::text < (csiro_harvest_pci.end_port)::text) THEN (((csiro_harvest_pci.start_port)::text || '-'::text) || (csiro_harvest_pci.end_port)::text) ELSE (((csiro_harvest_pci.end_port)::text || '-'::text) || (csiro_harvest_pci.start_port)::text) END, csiro_harvest_pci.date_time_utc) SELECT 'CPR-AUS (delayed-mode)'::text AS subfacility, interm_table_pci.vessel_name, interm_table_pci.route, csiro_harvest_pci.trip_code AS deployment_id, sum(interm_table_pci.no_pci_samples) AS no_pci_samples, CASE WHEN (sum(interm_table_phyto.no_phyto_samples) IS NULL) THEN (0)::numeric ELSE sum(interm_table_phyto.no_phyto_samples) END AS no_phyto_samples, CASE WHEN (sum(interm_table_zoop.no_zoop_samples) IS NULL) THEN (0)::numeric ELSE sum(interm_table_zoop.no_zoop_samples) END AS no_zoop_samples, COALESCE(((round(min(csiro_harvest_pci.latitude), 1) || '/'::text) || round(max(csiro_harvest_pci.latitude), 1))) AS lat_range, COALESCE(((round(min(csiro_harvest_pci.longitude), 1) || '/'::text) || round(max(csiro_harvest_pci.longitude), 1))) AS lon_range, NULL::text AS depth_range, date(min(csiro_harvest_pci.date_time_utc)) AS start_date, date(max(csiro_harvest_pci.date_time_utc)) AS end_date, round(((date_part('day'::text, (max(csiro_harvest_pci.date_time_utc) - min(csiro_harvest_pci.date_time_utc))))::numeric + ((date_part('hours'::text, (max(csiro_harvest_pci.date_time_utc) - min(csiro_harvest_pci.date_time_utc))))::numeric / (24)::numeric)), 1) AS coverage_duration, (date_part('day'::text, (min(soop_cpr_manual.data_on_staging) - (date(min(csiro_harvest_pci.date_time_utc)))::timestamp without time zone)))::numeric AS days_to_process_and_upload, round(avg((date_part('day'::text, (soop_cpr_manual.data_on_portal - soop_cpr_manual.data_on_staging)))::numeric), 1) AS days_to_make_public, CASE WHEN ((date_part('day'::text, (min(soop_cpr_manual.data_on_staging) - (date(min(csiro_harvest_pci.date_time_utc)))::timestamp without time zone)))::numeric IS NULL) THEN 'Missing dates'::text WHEN (sum(CASE WHEN (soop_cpr_manual.mest_uuid IS NULL) THEN 0 ELSE 1 END) <> sum(CASE WHEN (soop_cpr_manual.cruise_id IS NOT NULL) THEN 1 ELSE 0 END)) THEN 'No metadata'::text ELSE NULL::text END AS missing_info, ''::text AS principal_investigator, round(min(csiro_harvest_pci.latitude), 1) AS min_lat, round(max(csiro_harvest_pci.latitude), 1) AS max_lat, round(min(csiro_harvest_pci.longitude), 1) AS min_lon, round(max(csiro_harvest_pci.longitude), 1) AS max_lon, NULL::text AS min_depth, NULL::text AS max_depth, date(soop_cpr_manual.data_on_portal) AS data_on_portal FROM ((((interm_table_pci FULL JOIN interm_table_phyto ON ((interm_table_pci.date_time_utc = interm_table_phyto.date_time_utc))) FULL JOIN interm_table_zoop ON ((interm_table_pci.date_time_utc = interm_table_zoop.date_time_utc))) FULL JOIN cpr.csiro_harvest_pci ON ((interm_table_pci.date_time_utc = csiro_harvest_pci.date_time_utc))) FULL JOIN soop_cpr_manual ON (((csiro_harvest_pci.trip_code)::text = (soop_cpr_manual.cruise_id)::text))) WHERE (interm_table_pci.vessel_name IS NOT NULL) GROUP BY 'CPR-AUS (delayed-mode)'::text, interm_table_pci.vessel_name, interm_table_pci.route, csiro_harvest_pci.trip_code, soop_cpr_manual.data_on_portal UNION ALL SELECT 'CPR-SO (delayed-mode)'::text AS subfacility, so_segment.ship_code AS vessel_name, NULL::text AS route, COALESCE((((so_segment.ship_code)::text || '-'::text) || so_segment.tow_number)) AS deployment_id, sum(CASE WHEN (so_segment.pci IS NULL) THEN 0 ELSE 1 END) AS no_pci_samples, NULL::numeric AS no_phyto_samples, count(so_segment.total_abundance) AS no_zoop_samples, NULL::text AS lat_range, NULL::text AS lon_range, NULL::text AS depth_range, date(min(so_segment.date_time)) AS start_date, date(max(so_segment.date_time)) AS end_date, round(((date_part('day'::text, (max(so_segment.date_time) - min(so_segment.date_time))))::numeric + ((date_part('hours'::text, (max(so_segment.date_time) - min(so_segment.date_time))))::numeric / (24)::numeric)), 1) AS coverage_duration, NULL::numeric AS days_to_process_and_upload, NULL::numeric AS days_to_make_public, 'Missing dates'::text AS missing_info, ''::text AS principal_investigator, NULL::numeric AS min_lat, NULL::numeric AS max_lat, NULL::numeric AS min_lon, NULL::numeric AS max_lon, NULL::text AS min_depth, NULL::text AS max_depth, NULL::date AS data_on_portal FROM cpr.so_segment GROUP BY 'CPR-SO (delayed-mode)'::text, so_segment.ship_code, so_segment.tow_number ORDER BY 1, 2, 3, 11;


ALTER TABLE report.soop_cpr_all_deployments_view OWNER TO postgres;

--
-- Name: soop_data_summary_view; Type: VIEW; Schema: report; Owner: postgres
--

CREATE VIEW soop_data_summary_view AS
    SELECT soop_all_deployments_view.subfacility, soop_all_deployments_view.vessel_name, count(CASE WHEN (soop_all_deployments_view.deployment_id IS NULL) THEN '1'::character varying ELSE soop_all_deployments_view.deployment_id END) AS no_deployments, sum(CASE WHEN (soop_all_deployments_view.no_data_files IS NULL) THEN (1)::bigint ELSE soop_all_deployments_view.no_data_files END) AS no_data_files, COALESCE(((round(min(soop_all_deployments_view.min_lat), 1) || '/'::text) || round(max(soop_all_deployments_view.max_lat), 1))) AS lat_range, COALESCE(((round(min(soop_all_deployments_view.min_lon), 1) || '/'::text) || round(max(soop_all_deployments_view.max_lon), 1))) AS lon_range, COALESCE(((round(min(soop_all_deployments_view.min_depth), 1) || '/'::text) || round(max(soop_all_deployments_view.max_depth), 1))) AS depth_range, min(soop_all_deployments_view.start_date) AS earliest_date, max(soop_all_deployments_view.end_date) AS latest_date, sum(soop_all_deployments_view.coverage_duration) AS coverage_duration, round(avg(soop_all_deployments_view.days_to_process_and_upload), 1) AS mean_days_to_process_and_upload, round(avg(soop_all_deployments_view.days_to_make_public), 1) AS mean_days_to_make_public, sum(CASE WHEN (soop_all_deployments_view.missing_info IS NULL) THEN 1 ELSE 0 END) AS missing_info, round(min(soop_all_deployments_view.min_lat), 1) AS min_lat, round(max(soop_all_deployments_view.max_lat), 1) AS max_lat, round(min(soop_all_deployments_view.min_lon), 1) AS min_lon, round(max(soop_all_deployments_view.max_lon), 1) AS max_lon, round(min(soop_all_deployments_view.min_depth), 1) AS min_depth, round(max(soop_all_deployments_view.max_depth), 1) AS max_depth FROM soop_all_deployments_view GROUP BY soop_all_deployments_view.subfacility, soop_all_deployments_view.vessel_name UNION ALL SELECT soop_cpr_all_deployments_view.subfacility, soop_cpr_all_deployments_view.vessel_name, count(soop_cpr_all_deployments_view.vessel_name) AS no_deployments, CASE WHEN (sum(CASE WHEN (soop_cpr_all_deployments_view.no_phyto_samples IS NULL) THEN 0 ELSE 1 END) <> count(soop_cpr_all_deployments_view.vessel_name)) THEN sum((soop_cpr_all_deployments_view.no_pci_samples + soop_cpr_all_deployments_view.no_zoop_samples)) ELSE sum(((soop_cpr_all_deployments_view.no_pci_samples + soop_cpr_all_deployments_view.no_phyto_samples) + soop_cpr_all_deployments_view.no_zoop_samples)) END AS no_data_files, COALESCE(((round(min(soop_cpr_all_deployments_view.min_lat), 1) || '/'::text) || round(max(soop_cpr_all_deployments_view.max_lat), 1))) AS lat_range, COALESCE(((round(min(soop_cpr_all_deployments_view.min_lon), 1) || '/'::text) || round(max(soop_cpr_all_deployments_view.max_lon), 1))) AS lon_range, COALESCE(((round((min(soop_cpr_all_deployments_view.min_depth))::numeric, 1) || '/'::text) || round((max(soop_cpr_all_deployments_view.max_depth))::numeric, 1))) AS depth_range, min(soop_cpr_all_deployments_view.start_date) AS earliest_date, max(soop_cpr_all_deployments_view.end_date) AS latest_date, sum(soop_cpr_all_deployments_view.coverage_duration) AS coverage_duration, round(avg(soop_cpr_all_deployments_view.days_to_process_and_upload), 1) AS mean_days_to_process_and_upload, round(avg(soop_cpr_all_deployments_view.days_to_make_public), 1) AS mean_days_to_make_public, sum(CASE WHEN (soop_cpr_all_deployments_view.missing_info IS NULL) THEN 1 ELSE 0 END) AS missing_info, round(min(soop_cpr_all_deployments_view.min_lat), 1) AS min_lat, round(max(soop_cpr_all_deployments_view.max_lat), 1) AS max_lat, round(min(soop_cpr_all_deployments_view.min_lon), 1) AS min_lon, round(max(soop_cpr_all_deployments_view.max_lon), 1) AS max_lon, round((min(soop_cpr_all_deployments_view.min_depth))::numeric, 1) AS min_depth, round((max(soop_cpr_all_deployments_view.max_depth))::numeric, 1) AS max_depth FROM soop_cpr_all_deployments_view GROUP BY soop_cpr_all_deployments_view.subfacility, soop_cpr_all_deployments_view.vessel_name ORDER BY 1, 2;


ALTER TABLE report.soop_data_summary_view OWNER TO postgres;

--
-- Name: soop_frrf_manual; Type: TABLE; Schema: report; Owner: postgres; Tablespace: 
--

CREATE TABLE soop_frrf_manual (
    cruise_id character varying(50) NOT NULL,
    data_on_staging timestamp without time zone,
    data_on_opendap timestamp without time zone,
    data_on_portal timestamp without time zone,
    mest_creation timestamp without time zone,
    id bigint
);


ALTER TABLE report.soop_frrf_manual OWNER TO postgres;

--
-- Name: soop_xbt_line; Type: TABLE; Schema: report; Owner: postgres; Tablespace: 
--

CREATE TABLE soop_xbt_line (
    line_name character varying(50) NOT NULL,
    line_uuid character varying(36),
    line_description character varying(100)
);


ALTER TABLE report.soop_xbt_line OWNER TO postgres;

--
-- Name: soop_xbt_realtime_manual; Type: TABLE; Schema: report; Owner: postgres; Tablespace: 
--

CREATE TABLE soop_xbt_realtime_manual (
    cruise_id integer NOT NULL,
    number_of_profile integer,
    line_name character varying(100),
    callsign character varying(10),
    vessel_name character varying(100),
    start_date timestamp without time zone,
    end_date timestamp without time zone,
    id bigint DEFAULT nextval('hibernate_sequence'::regclass) NOT NULL
);


ALTER TABLE report.soop_xbt_realtime_manual OWNER TO postgres;

--
-- Name: srs_altimetry_manual; Type: TABLE; Schema: report; Owner: postgres; Tablespace: 
--

CREATE TABLE srs_altimetry_manual (
    deployment_start date,
    deployment_end date,
    site_code character varying(40),
    data_on_staging date,
    data_on_opendap date,
    data_on_portal date,
    pkid integer DEFAULT nextval('hibernate_sequence'::regclass) NOT NULL
);


ALTER TABLE report.srs_altimetry_manual OWNER TO postgres;

--
-- Name: srs_bio_optical_db_manual; Type: TABLE; Schema: report; Owner: postgres; Tablespace: 
--

CREATE TABLE srs_bio_optical_db_manual (
    pkid integer DEFAULT nextval('hibernate_sequence'::regclass) NOT NULL,
    cruise_id character varying(50),
    data_type character varying(40),
    deployment_start date,
    deployment_end date,
    data_on_staging date,
    data_on_opendap date,
    data_on_portal date,
    mest_creation date
);


ALTER TABLE report.srs_bio_optical_db_manual OWNER TO postgres;

--
-- Name: srs_gridded_products_manual; Type: TABLE; Schema: report; Owner: postgres; Tablespace: 
--

CREATE TABLE srs_gridded_products_manual (
    product_name character varying(50) NOT NULL,
    deployment_start date,
    deployment_end date,
    data_on_staging date,
    data_on_opendap date,
    data_on_portal date,
    mest_creation date,
    pkid integer DEFAULT nextval('hibernate_sequence'::regclass) NOT NULL
);


ALTER TABLE report.srs_gridded_products_manual OWNER TO postgres;

--
-- Name: srs_all_deployments_view; Type: VIEW; Schema: report; Owner: postgres
--

CREATE VIEW srs_all_deployments_view AS
    ((SELECT 'SRS - Altimetry'::text AS subfacility, CASE WHEN ((data.site_code)::text = 'SRSSTO'::text) THEN 'Storm Bay'::text WHEN ((data.site_code)::text = 'SRSBAS'::text) THEN 'Bass Strait'::text ELSE NULL::text END AS parameter_site, COALESCE((((data.site_code)::text || '-'::text) || "substring"((data.filename)::text, '([^_]+)-'::text))) AS deployment_code, data.sensor_name, round((data.sensor_depth)::numeric, 1) AS depth, date(data.time_coverage_start) AS start_date, date(data.time_coverage_end) AS end_date, (date_part('days'::text, (data.time_coverage_end - data.time_coverage_start)))::numeric AS coverage_duration, (date_part('days'::text, ((srs_altimetry_manual.data_on_staging)::timestamp with time zone - data.time_coverage_end)))::numeric AS days_to_process_and_upload, ((srs_altimetry_manual.data_on_portal - srs_altimetry_manual.data_on_staging))::numeric AS days_to_make_public, srs_altimetry_manual.data_on_staging AS date_on_staging, srs_altimetry_manual.data_on_opendap AS date_on_opendap, srs_altimetry_manual.data_on_portal AS date_on_portal, CASE WHEN (data.metadata_uuid IS NULL) THEN 'No metadata'::text ELSE NULL::text END AS missing_info, round((data.lat)::numeric, 1) AS lat, round((data.lon)::numeric, 1) AS lon FROM (srs_altimetry.data LEFT JOIN srs_altimetry_manual ON ((srs_altimetry_manual.pkid = data.pkid))) UNION ALL SELECT 'SRS - BioOptical database'::text AS subfacility, srs_bio_optical_db_manual.data_type AS parameter_site, srs_bio_optical_db_manual.cruise_id AS deployment_code, NULL::character varying AS sensor_name, NULL::numeric AS depth, srs_bio_optical_db_manual.deployment_start AS start_date, srs_bio_optical_db_manual.deployment_end AS end_date, ((srs_bio_optical_db_manual.deployment_end - srs_bio_optical_db_manual.deployment_start))::numeric AS coverage_duration, ((srs_bio_optical_db_manual.data_on_staging - srs_bio_optical_db_manual.deployment_end))::numeric AS days_to_process_and_upload, ((srs_bio_optical_db_manual.data_on_portal - srs_bio_optical_db_manual.data_on_staging))::numeric AS days_to_make_public, srs_bio_optical_db_manual.data_on_staging AS date_on_staging, srs_bio_optical_db_manual.data_on_opendap AS date_on_opendap, srs_bio_optical_db_manual.data_on_portal AS date_on_portal, CASE WHEN (srs_bio_optical_db_manual.mest_creation IS NULL) THEN 'No metadata'::text WHEN (((srs_bio_optical_db_manual.data_on_staging - srs_bio_optical_db_manual.deployment_end))::numeric IS NULL) THEN 'Missing dates'::text ELSE NULL::text END AS missing_info, NULL::numeric AS lat, NULL::numeric AS lon FROM srs_bio_optical_db_manual) UNION ALL SELECT 'SRS - Gridded Products'::text AS subfacility, CASE WHEN ((srs_gridded_products_manual.product_name)::text = 'MODIS Aqua OC3 Chlorophyll-a'::text) THEN 'Chlorophyll-a'::text WHEN ((srs_gridded_products_manual.product_name)::text = 'SST L3C'::text) THEN 'SST'::text WHEN ((srs_gridded_products_manual.product_name)::text = 'SST L3P - 14 days mosaic'::text) THEN 'SST'::text ELSE NULL::text END AS parameter_site, CASE WHEN ((srs_gridded_products_manual.product_name)::text = 'MODIS Aqua OC3 Chlorophyll-a'::text) THEN 'MODIS Aqua OC3'::text WHEN ((srs_gridded_products_manual.product_name)::text = 'SST L3C'::text) THEN 'L3C'::text WHEN ((srs_gridded_products_manual.product_name)::text = 'SST L3P - 14 days mosaic'::text) THEN 'L3P - 14 days mosaic'::text ELSE NULL::text END AS deployment_code, NULL::character varying AS sensor_name, NULL::numeric AS depth, srs_gridded_products_manual.deployment_start AS start_date, srs_gridded_products_manual.deployment_end AS end_date, ((srs_gridded_products_manual.deployment_end - srs_gridded_products_manual.deployment_start))::numeric AS coverage_duration, ((srs_gridded_products_manual.data_on_staging - srs_gridded_products_manual.deployment_end))::numeric AS days_to_process_and_upload, ((srs_gridded_products_manual.data_on_portal - srs_gridded_products_manual.data_on_staging))::numeric AS days_to_make_public, srs_gridded_products_manual.data_on_staging AS date_on_staging, srs_gridded_products_manual.data_on_opendap AS date_on_opendap, srs_gridded_products_manual.data_on_portal AS date_on_portal, CASE WHEN (srs_gridded_products_manual.mest_creation IS NULL) THEN 'No metadata'::text ELSE NULL::text END AS missing_info, NULL::numeric AS lat, NULL::numeric AS lon FROM srs_gridded_products_manual) UNION ALL SELECT 'SRS - Ocean Colour'::text AS subfacility, srs_oc_soop_rad.vessel_name AS parameter_site, srs_oc_soop_rad.voyage_number AS deployment_code, NULL::character varying AS sensor_name, NULL::numeric AS depth, min(date(srs_oc_soop_rad.time_coverage_start)) AS start_date, max(date(srs_oc_soop_rad.time_coverage_end)) AS end_date, ((max(date(srs_oc_soop_rad.time_coverage_end)) - min(date(srs_oc_soop_rad.time_coverage_start))))::numeric AS coverage_duration, NULL::numeric AS days_to_process_and_upload, NULL::numeric AS days_to_make_public, NULL::date AS date_on_staging, NULL::date AS date_on_opendap, NULL::date AS date_on_portal, CASE WHEN (((max(date(srs_oc_soop_rad.time_coverage_end)) - min(date(srs_oc_soop_rad.time_coverage_start))))::numeric IS NULL) THEN 'Missing dates'::text ELSE NULL::text END AS missing_info, round((avg(srs_oc_soop_rad.geospatial_lat_min))::numeric, 1) AS lat, round((avg(srs_oc_soop_rad.geospatial_lon_min))::numeric, 1) AS lon FROM srs.srs_oc_soop_rad GROUP BY srs_oc_soop_rad.vessel_name, srs_oc_soop_rad.voyage_number ORDER BY 1, 2, 3, 4, 6, 7;


ALTER TABLE report.srs_all_deployments_view OWNER TO postgres;

--
-- Name: srs_data_summary_view; Type: VIEW; Schema: report; Owner: postgres
--

CREATE VIEW srs_data_summary_view AS
    SELECT srs_all_deployments_view.subfacility, CASE WHEN (srs_all_deployments_view.parameter_site = 'absorption'::text) THEN 'Absorption'::text WHEN (srs_all_deployments_view.parameter_site = 'pigment'::text) THEN 'Pigment'::text ELSE srs_all_deployments_view.parameter_site END AS parameter_site, count(srs_all_deployments_view.deployment_code) AS no_deployments, count(DISTINCT srs_all_deployments_view.sensor_name) AS no_sensors, COALESCE(((min(srs_all_deployments_view.depth) || ' / '::text) || max(srs_all_deployments_view.depth))) AS depth_range, sum(CASE WHEN (srs_all_deployments_view.missing_info IS NULL) THEN 0 ELSE 1 END) AS no_missing_info, min(srs_all_deployments_view.start_date) AS earliest_date, max(srs_all_deployments_view.end_date) AS latest_date, round(avg(srs_all_deployments_view.coverage_duration), 1) AS mean_coverage_duration, round(avg(srs_all_deployments_view.days_to_process_and_upload), 1) AS mean_days_to_process_and_upload, round(avg(srs_all_deployments_view.days_to_make_public), 1) AS mean_days_to_make_public, min(srs_all_deployments_view.lon) AS min_lon, max(srs_all_deployments_view.lon) AS max_lon, min(srs_all_deployments_view.lat) AS min_lat, max(srs_all_deployments_view.lat) AS max_lat, min(srs_all_deployments_view.depth) AS min_depth, max(srs_all_deployments_view.depth) AS max_depth FROM srs_all_deployments_view GROUP BY srs_all_deployments_view.subfacility, srs_all_deployments_view.parameter_site ORDER BY srs_all_deployments_view.subfacility, CASE WHEN (srs_all_deployments_view.parameter_site = 'absorption'::text) THEN 'Absorption'::text WHEN (srs_all_deployments_view.parameter_site = 'pigment'::text) THEN 'Pigment'::text ELSE srs_all_deployments_view.parameter_site END;


ALTER TABLE report.srs_data_summary_view OWNER TO postgres;

--
-- Name: totals; Type: TABLE; Schema: report; Owner: postgres; Tablespace: 
--

CREATE TABLE totals (
    facility text,
    subfacility text,
    type character varying,
    no_projects bigint,
    no_platforms numeric,
    no_instruments numeric,
    no_deployments numeric,
    no_data numeric,
    no_data2 numeric,
    no_data3 bigint,
    no_data4 bigint,
    temporal_range text,
    lat_range text,
    lon_range text,
    depth_range text
);


ALTER TABLE report.totals OWNER TO postgres;

--
-- Name: totals_view; Type: VIEW; Schema: report; Owner: postgres
--

CREATE VIEW totals_view AS
    SELECT totals.facility, totals.subfacility, totals.type, totals.no_projects, totals.no_platforms, totals.no_instruments, totals.no_deployments, totals.no_data, totals.no_data2, totals.no_data3, totals.no_data4, totals.temporal_range, totals.lat_range, totals.lon_range, totals.depth_range FROM totals;


ALTER TABLE report.totals_view OWNER TO postgres;

--
-- Name: pkid; Type: DEFAULT; Schema: report; Owner: postgres
--

ALTER TABLE ONLY anmn_datacategories_manual ALTER COLUMN pkid SET DEFAULT nextval('anmn_datacategories_manual_pkid_seq'::regclass);


--
-- Name: pkid; Type: DEFAULT; Schema: report; Owner: postgres
--

ALTER TABLE ONLY anmn_manual ALTER COLUMN pkid SET DEFAULT nextval('anmn_manual_pkid_seq'::regclass);


--
-- Name: pkid; Type: DEFAULT; Schema: report; Owner: postgres
--

ALTER TABLE ONLY anmn_platforms_manual ALTER COLUMN pkid SET DEFAULT nextval('anmn_platforms_manual_pkid_seq'::regclass);


--
-- Name: pkid; Type: DEFAULT; Schema: report; Owner: postgres
--

ALTER TABLE ONLY anmn_status_manual ALTER COLUMN pkid SET DEFAULT nextval('anmn_status_manual_pkid_seq'::regclass);


--
-- Name: row_id; Type: DEFAULT; Schema: report; Owner: postgres
--

ALTER TABLE ONLY facility_summary ALTER COLUMN row_id SET DEFAULT nextval('facility_summary_row_id_seq1'::regclass);


--
-- Name: row_id; Type: DEFAULT; Schema: report; Owner: postgres
--

ALTER TABLE ONLY facility_summary_item ALTER COLUMN row_id SET DEFAULT nextval('facility_summary_item_row_id_seq'::regclass);


--
-- Data for Name: aatams_sattag_manual; Type: TABLE DATA; Schema: report; Owner: postgres
--

COPY aatams_sattag_manual (device_id, wmo_ref, data_on_staging, data_on_opendap, data_on_portal, pkid) FROM stdin;
ct64-M001-09	Q9900315	2010-01-20 00:00:00	2010-07-03 00:00:00	2010-06-16 00:00:00	376
ct64-M036-09	Q9900316	2010-01-26 00:00:00	2010-07-03 00:00:00	2010-06-16 00:00:00	377
ct64-M037-09	Q9900317	2010-01-17 00:00:00	2010-07-03 00:00:00	2010-06-16 00:00:00	378
ct64-M040-09	Q9900318	2010-02-03 00:00:00	2010-07-03 00:00:00	2010-06-16 00:00:00	379
ct64-M043-09	Q9900319	2010-01-29 00:00:00	2010-07-03 00:00:00	2010-06-16 00:00:00	380
ct64-M053-09	Q9900320	2010-01-26 00:00:00	2010-07-03 00:00:00	2010-06-16 00:00:00	381
ct64-M979-09	Q9900321	2010-01-31 00:00:00	2010-07-03 00:00:00	2010-06-16 00:00:00	382
ct64-M994-09	Q9900329	2010-04-11 00:00:00	2010-07-03 00:00:00	2010-06-16 00:00:00	383
ct64-M059-09	Q9900330	2010-04-10 00:00:00	2010-07-03 00:00:00	2010-06-16 00:00:00	384
ct64-M052-09	Q9900331	2010-04-11 00:00:00	2010-07-03 00:00:00	2010-06-16 00:00:00	385
ct64-M044-09	Q9900332	2010-04-11 00:00:00	2010-07-03 00:00:00	2010-06-16 00:00:00	386
ct64-M061-09	Q9900333	2010-04-11 00:00:00	2010-07-03 00:00:00	2010-06-16 00:00:00	387
ct64-M752-09	Q9900334	2010-04-11 00:00:00	2010-07-03 00:00:00	2010-06-16 00:00:00	388
ct64-M746-09	Q9900335	2010-04-11 00:00:00	2010-07-03 00:00:00	2010-06-16 00:00:00	389
ct64-M721-09	Q9900336	2010-04-11 00:00:00	2010-07-03 00:00:00	2010-06-16 00:00:00	390
ct78d-D351-11	Q9900414	2011-04-20 00:00:00	2011-07-07 00:00:00	2011-07-06 00:00:00	391
ct78d-D358-11	Q9900415	2011-04-20 00:00:00	2011-07-07 00:00:00	2011-07-06 00:00:00	392
ct78d-D361-11	Q9900416	2011-04-20 00:00:00	2011-07-07 00:00:00	2011-07-06 00:00:00	393
ct78d-D362-11	Q9900417	2011-04-20 00:00:00	2011-07-07 00:00:00	2011-07-06 00:00:00	394
ct78d-D398-11	Q9900418	2011-04-20 00:00:00	2011-07-07 00:00:00	2011-07-06 00:00:00	395
ct78d-D400-11	Q9900419	2011-04-20 00:00:00	2011-07-07 00:00:00	2011-07-06 00:00:00	396
ct78d-D408-11	Q9900420	2011-04-20 00:00:00	2011-07-07 00:00:00	2011-07-06 00:00:00	397
ct78d-D484-11	Q9900421	2011-04-20 00:00:00	2011-07-07 00:00:00	2011-07-06 00:00:00	398
ct78d-D487-11	Q9900422	2011-04-20 00:00:00	2011-07-07 00:00:00	2011-07-06 00:00:00	399
ct78d-D489-11	Q9900423	2011-04-20 00:00:00	2011-07-07 00:00:00	2011-07-06 00:00:00	400
ct78d-D496-11	Q9900424	2011-04-20 00:00:00	2011-07-07 00:00:00	2011-07-06 00:00:00	401
ct78d-D677-11	Q9900425	2011-04-20 00:00:00	2011-07-07 00:00:00	2011-07-06 00:00:00	402
ct78d-D703-11	Q9900426	2011-04-20 00:00:00	2011-07-07 00:00:00	2011-07-06 00:00:00	403
ct78d-D704-11	Q9900427	2011-04-20 00:00:00	2011-07-07 00:00:00	2011-07-06 00:00:00	404
ct78d-760-11	Q9900428	2011-04-20 00:00:00	2011-07-07 00:00:00	2011-07-06 00:00:00	405
ct78d-D761-11	Q9900429	2011-04-20 00:00:00	2011-07-07 00:00:00	2011-07-06 00:00:00	406
ct78d-D822-11	Q9900430	2011-04-20 00:00:00	2011-07-07 00:00:00	2011-07-06 00:00:00	407
ct78d-D827-11	Q9900431	2011-04-20 00:00:00	2011-07-07 00:00:00	2011-07-06 00:00:00	408
ct78d-D850-11	Q9900432	2011-04-20 00:00:00	2011-07-07 00:00:00	2011-07-06 00:00:00	409
ct78d-D876-11	Q9900433	2011-04-20 00:00:00	2011-07-07 00:00:00	2011-07-06 00:00:00	410
ct78d-D877-11	Q9900434	2011-04-20 00:00:00	2011-07-07 00:00:00	2011-07-06 00:00:00	411
ct61-03-09	Q9900286	2009-12-07 00:00:00	2010-07-03 00:00:00	2010-06-16 00:00:00	412
ct61-02-09	Q9900287	2009-11-05 00:00:00	2010-07-03 00:00:00	2010-06-16 00:00:00	413
ct61-09-09	Q9900288	2009-12-09 00:00:00	2010-07-03 00:00:00	2010-06-16 00:00:00	414
ct61-01-09	Q9900289	2009-12-11 00:00:00	2010-07-03 00:00:00	2010-06-16 00:00:00	415
ct61-05-09	Q9900290	2011-02-11 00:00:00	2011-07-07 00:00:00	2011-07-06 00:00:00	416
ct61-10-09	Q9900291	2009-11-07 00:00:00	2010-07-03 00:00:00	2010-06-16 00:00:00	417
ct61-08-09	Q9900292	2009-11-06 00:00:00	2010-07-03 00:00:00	2010-06-16 00:00:00	418
ct61-07-09	Q9900293	2010-01-01 00:00:00	2010-07-03 00:00:00	2010-06-16 00:00:00	419
ct61-06-09	Q9900294	2009-11-26 00:00:00	2010-07-03 00:00:00	2010-06-16 00:00:00	420
ct61-04-09	Q9900295	2009-11-26 00:00:00	2010-07-03 00:00:00	2010-06-16 00:00:00	421
\.


--
-- Data for Name: aatams_sattag_mdb_workflow_manual; Type: TABLE DATA; Schema: report; Owner: postgres
--

COPY aatams_sattag_mdb_workflow_manual (device_id, data_on_staging, data_on_opendap, data_on_portal, pkid) FROM stdin;
ct31-441-07	2012-08-09 00:00:00	2012-09-17 00:00:00	2012-09-17 00:00:00	422
ct31-448B_rec-07	2012-08-09 00:00:00	2012-09-17 00:00:00	2012-09-17 00:00:00	423
ct78-826-12	2012-08-09 00:00:00	2012-09-17 00:00:00	2012-09-17 00:00:00	424
ct78-821-12	2012-08-09 00:00:00	2012-09-17 00:00:00	2012-09-17 00:00:00	425
ct78-820-12	2012-08-09 00:00:00	2012-09-17 00:00:00	2012-09-17 00:00:00	426
ct78-472-12	2012-08-09 00:00:00	2012-09-17 00:00:00	2012-09-17 00:00:00	427
ct78-471-12	2012-08-09 00:00:00	2012-09-17 00:00:00	2012-09-17 00:00:00	430
ct78-461-12	2012-08-09 00:00:00	2012-09-17 00:00:00	2012-09-17 00:00:00	432
ct86-172-12	2012-08-09 00:00:00	2012-09-17 00:00:00	2012-09-17 00:00:00	433
ct78-700-12	2012-08-09 00:00:00	2012-09-17 00:00:00	2012-09-17 00:00:00	434
ct78-460-12	2012-08-09 00:00:00	2012-09-17 00:00:00	2012-09-17 00:00:00	436
ct78-459-12	2012-08-09 00:00:00	2012-09-17 00:00:00	2012-09-17 00:00:00	437
ct78-450-12	2012-08-09 00:00:00	2012-09-17 00:00:00	2012-09-17 00:00:00	438
ct86-186-12	2012-08-09 00:00:00	2012-09-17 00:00:00	2012-09-17 00:00:00	442
ct36-A-09	2012-08-09 00:00:00	2012-09-17 00:00:00	2012-09-17 00:00:00	448
ct36-R4-09	2012-08-09 00:00:00	2012-09-17 00:00:00	2012-09-17 00:00:00	449
ct36-R3-09	2012-08-09 00:00:00	2012-09-17 00:00:00	2012-09-17 00:00:00	450
ct76-073-11	2012-08-09 00:00:00	2012-09-17 00:00:00	2012-09-17 00:00:00	451
ct86-187-12	2012-08-09 00:00:00	2012-09-17 00:00:00	2012-09-17 00:00:00	459
ct86-189-12	2012-08-09 00:00:00	2012-09-17 00:00:00	2012-09-17 00:00:00	460
ct76-364-11	2012-08-09 00:00:00	2012-09-17 00:00:00	2012-09-17 00:00:00	461
ct76-364r-11	2012-08-09 00:00:00	2012-09-17 00:00:00	2012-09-17 00:00:00	462
ct76-825-11	2012-08-09 00:00:00	2012-09-17 00:00:00	2012-09-17 00:00:00	463
ct76-402-11	2012-08-09 00:00:00	2012-09-17 00:00:00	2012-09-17 00:00:00	464
ct86-239-12	2012-08-09 00:00:00	2012-09-17 00:00:00	2012-09-17 00:00:00	465
ct36-R2-09	2012-08-09 00:00:00	2012-09-17 00:00:00	2012-09-17 00:00:00	478
ct36-R1-09	2012-08-09 00:00:00	2012-09-17 00:00:00	2012-09-17 00:00:00	479
ct86-364_2-11	2012-08-09 00:00:00	2012-09-17 00:00:00	2012-09-17 00:00:00	481
ct61-01r-09	2012-08-09 00:00:00	2012-09-17 00:00:00	2012-09-17 00:00:00	487
ct86-402_2-11	2012-08-09 00:00:00	2012-09-17 00:00:00	2012-09-17 00:00:00	488
ct91-327-12	2012-08-09 00:00:00	2012-09-17 00:00:00	2012-09-17 00:00:00	489
ct91-418-12	2012-08-09 00:00:00	2012-09-17 00:00:00	2012-09-17 00:00:00	490
ct91-329-12	2012-08-09 00:00:00	2012-09-17 00:00:00	2012-09-17 00:00:00	491
ct91-414-12	2012-08-09 00:00:00	2012-09-17 00:00:00	2012-09-17 00:00:00	492
ct91-417-12	2012-08-09 00:00:00	2012-09-17 00:00:00	2012-09-17 00:00:00	493
ct77-469-12	2012-08-09 00:00:00	2012-09-17 00:00:00	2012-09-17 00:00:00	494
ct77-185-12	2012-08-09 00:00:00	2012-09-17 00:00:00	2012-09-17 00:00:00	495
ct77-179-12	2012-08-09 00:00:00	2012-09-17 00:00:00	2012-09-17 00:00:00	546
ct77-178-12	2012-08-09 00:00:00	2012-09-17 00:00:00	2012-09-17 00:00:00	547
ct77-177-12	2012-08-09 00:00:00	2012-09-17 00:00:00	2012-09-17 00:00:00	548
wd04-881-11	2012-08-09 00:00:00	2012-09-17 00:00:00	2012-09-17 00:00:00	549
ct77-854-12	2012-08-09 00:00:00	2012-09-17 00:00:00	2012-09-17 00:00:00	550
ct77-824-12	2012-08-09 00:00:00	2012-09-17 00:00:00	2012-09-17 00:00:00	551
ct77-823-12	2012-08-09 00:00:00	2012-09-17 00:00:00	2012-09-17 00:00:00	552
ct77-701-12	2012-08-09 00:00:00	2012-09-17 00:00:00	2012-09-17 00:00:00	553
ct77-652-12	2012-08-09 00:00:00	2012-09-17 00:00:00	2012-09-17 00:00:00	554
ct77-492-12	2012-08-09 00:00:00	2012-09-17 00:00:00	2012-09-17 00:00:00	555
ct77-485-12	2012-08-09 00:00:00	2012-09-17 00:00:00	2012-09-17 00:00:00	556
wd04-880-11	2012-08-09 00:00:00	2012-09-17 00:00:00	2012-09-17 00:00:00	557
wd04-839-11	2012-08-09 00:00:00	2012-09-17 00:00:00	2012-09-17 00:00:00	558
wd04-838-11	2012-08-09 00:00:00	2012-09-17 00:00:00	2012-09-17 00:00:00	559
ct77-173-12	2012-08-09 00:00:00	2012-09-17 00:00:00	2012-09-17 00:00:00	560
ct77-171-12	2012-08-09 00:00:00	2012-09-17 00:00:00	2012-09-17 00:00:00	561
ct77-170-12	2012-08-09 00:00:00	2012-09-17 00:00:00	2012-09-17 00:00:00	562
ct77-169-12	2012-08-09 00:00:00	2012-09-17 00:00:00	2012-09-17 00:00:00	563
ct77-167-12	2012-08-09 00:00:00	2012-09-17 00:00:00	2012-09-17 00:00:00	564
ct78-829-12	2012-08-09 00:00:00	2012-09-17 00:00:00	2012-09-17 00:00:00	565
ct78-828-12	2012-08-09 00:00:00	2012-09-17 00:00:00	2012-09-17 00:00:00	566
ct78-758-12	2012-08-09 00:00:00	2012-09-17 00:00:00	2012-09-17 00:00:00	567
ct78-706-12	2012-08-09 00:00:00	2012-09-17 00:00:00	2012-09-17 00:00:00	568
ct78-523-12	2012-08-09 00:00:00	2012-09-17 00:00:00	2012-09-17 00:00:00	569
ct78-498-12	2012-08-09 00:00:00	2012-09-17 00:00:00	2012-09-17 00:00:00	570
ct78-497-12	2012-08-09 00:00:00	2012-09-17 00:00:00	2012-09-17 00:00:00	571
ct91-305-12	2012-08-09 00:00:00	2012-09-17 00:00:00	2012-09-17 00:00:00	572
ct91-411-12	2012-08-09 00:00:00	2012-09-17 00:00:00	2012-09-17 00:00:00	573
ct91-326-12	2012-08-09 00:00:00	2012-09-17 00:00:00	2012-09-17 00:00:00	574
ct91-412-12	2012-08-09 00:00:00	2012-09-17 00:00:00	2012-09-17 00:00:00	575
ct78-465-12	2012-08-09 00:00:00	2012-09-17 00:00:00	2012-09-17 00:00:00	496
ct77-919-12	2012-08-09 00:00:00	2012-09-17 00:00:00	2012-09-17 00:00:00	497
ct77-891-12	2012-08-09 00:00:00	2012-09-17 00:00:00	2012-09-17 00:00:00	498
ct77-473-12	2012-08-09 00:00:00	2012-09-17 00:00:00	2012-09-17 00:00:00	499
wd04-911-11	2012-08-09 00:00:00	2012-09-17 00:00:00	2012-09-17 00:00:00	500
wd04-910-11	2012-08-09 00:00:00	2012-09-17 00:00:00	2012-09-17 00:00:00	501
ct36-F-09	2012-08-09 00:00:00	2012-09-17 00:00:00	2012-09-17 00:00:00	509
ct36-E-09	2012-08-09 00:00:00	2012-09-17 00:00:00	2012-09-17 00:00:00	510
ct36-D-09	2012-08-09 00:00:00	2012-09-17 00:00:00	2012-09-17 00:00:00	511
ct36-C-09	2012-08-09 00:00:00	2012-09-17 00:00:00	2012-09-17 00:00:00	512
ct36-B-09	2012-08-09 00:00:00	2012-09-17 00:00:00	2012-09-17 00:00:00	513
ct79-238-12	2012-08-09 00:00:00	2012-09-17 00:00:00	2012-09-17 00:00:00	514
ct79-242-12	2012-08-09 00:00:00	2012-09-17 00:00:00	2012-09-17 00:00:00	515
ct78-892-12	2012-08-09 00:00:00	2012-09-17 00:00:00	2012-09-17 00:00:00	516
ct78-879-12	2012-08-09 00:00:00	2012-09-17 00:00:00	2012-09-17 00:00:00	517
ct79-249-12	2012-08-09 00:00:00	2012-09-17 00:00:00	2012-09-17 00:00:00	519
ct79-259-12	2012-08-09 00:00:00	2012-09-17 00:00:00	2012-09-17 00:00:00	520
wd04-909-11	2012-08-09 00:00:00	2012-09-17 00:00:00	2012-09-17 00:00:00	521
wd04-836-11	2012-08-09 00:00:00	2012-09-17 00:00:00	2012-09-17 00:00:00	522
ct31-448B-07	2012-08-09 00:00:00	2012-09-17 00:00:00	2012-09-17 00:00:00	523
ct31-448A-07	2012-08-09 00:00:00	2012-09-17 00:00:00	2012-09-17 00:00:00	524
ct31-441_rec-07	2012-08-09 00:00:00	2012-09-17 00:00:00	2012-09-17 00:00:00	525
ct78-878-12	2012-08-09 00:00:00	2012-09-17 00:00:00	2012-09-17 00:00:00	526
ct78-875-12	2012-08-09 00:00:00	2012-09-17 00:00:00	2012-09-17 00:00:00	527
ct78-852-12	2012-08-09 00:00:00	2012-09-17 00:00:00	2012-09-17 00:00:00	528
ct78-851-12	2012-08-09 00:00:00	2012-09-17 00:00:00	2012-09-17 00:00:00	529
wd04-908-11	2012-08-09 00:00:00	2012-09-17 00:00:00	2012-09-17 00:00:00	530
wd04-907-11	2012-08-09 00:00:00	2012-09-17 00:00:00	2012-09-17 00:00:00	531
wd04-906-11	2012-08-09 00:00:00	2012-09-17 00:00:00	2012-09-17 00:00:00	532
wd04-900-11	2012-08-09 00:00:00	2012-09-17 00:00:00	2012-09-17 00:00:00	533
wd04-899-11	2012-08-09 00:00:00	2012-09-17 00:00:00	2012-09-17 00:00:00	534
wd04-898-11	2012-08-09 00:00:00	2012-09-17 00:00:00	2012-09-17 00:00:00	535
wd04-897-11	2012-08-09 00:00:00	2012-09-17 00:00:00	2012-09-17 00:00:00	536
wd04-896-11	2012-08-09 00:00:00	2012-09-17 00:00:00	2012-09-17 00:00:00	537
wd04-884-11	2012-08-09 00:00:00	2012-09-17 00:00:00	2012-09-17 00:00:00	538
wd04-883-11	2012-08-09 00:00:00	2012-09-17 00:00:00	2012-09-17 00:00:00	539
wd04-882-11	2012-08-09 00:00:00	2012-09-17 00:00:00	2012-09-17 00:00:00	540
ct77-184-12	2012-08-09 00:00:00	2012-09-17 00:00:00	2012-09-17 00:00:00	541
ct77-183-12	2012-08-09 00:00:00	2012-09-17 00:00:00	2012-09-17 00:00:00	542
ct77-182-12	2012-08-09 00:00:00	2012-09-17 00:00:00	2012-09-17 00:00:00	543
ct77-181-12	2012-08-09 00:00:00	2012-09-17 00:00:00	2012-09-17 00:00:00	544
ct77-180-12	2012-08-09 00:00:00	2012-09-17 00:00:00	2012-09-17 00:00:00	545
ct64-M746-09	2010-04-11 00:00:00	2010-07-03 00:00:00	2010-06-16 00:00:00	428
ct64-M721-09	2010-04-11 00:00:00	2010-07-03 00:00:00	2010-06-16 00:00:00	429
ct61-01-09	2009-12-11 00:00:00	2010-07-03 00:00:00	2010-06-16 00:00:00	431
ct61-09-09	2009-12-09 00:00:00	2010-07-03 00:00:00	2010-06-16 00:00:00	435
ct78d-D358-11	2011-04-20 00:00:00	2011-07-07 00:00:00	2011-07-06 00:00:00	439
ct78d-D351-11	2011-04-20 00:00:00	2011-07-07 00:00:00	2011-07-06 00:00:00	440
ct78d-D398-11	2011-04-20 00:00:00	2011-07-07 00:00:00	2011-07-06 00:00:00	441
ct61-10-09	2009-11-07 00:00:00	2010-07-03 00:00:00	2010-06-16 00:00:00	443
ct78d-D362-11	2011-04-20 00:00:00	2011-07-07 00:00:00	2011-07-06 00:00:00	444
ct78d-D361-11	2011-04-20 00:00:00	2011-07-07 00:00:00	2011-07-06 00:00:00	445
ct78d-D704-11	2011-04-20 00:00:00	2011-07-07 00:00:00	2011-07-06 00:00:00	446
ct78d-D703-11	2011-04-20 00:00:00	2011-07-07 00:00:00	2011-07-06 00:00:00	447
ct78d-D677-11	2011-04-20 00:00:00	2011-07-07 00:00:00	2011-07-06 00:00:00	452
ct78d-D827-11	2011-04-20 00:00:00	2011-07-07 00:00:00	2011-07-06 00:00:00	453
ct78d-D822-11	2011-04-20 00:00:00	2011-07-07 00:00:00	2011-07-06 00:00:00	454
ct78d-D761-11	2011-04-20 00:00:00	2011-07-07 00:00:00	2011-07-06 00:00:00	455
ct78d-D877-11	2011-04-20 00:00:00	2011-07-07 00:00:00	2011-07-06 00:00:00	456
ct78d-D876-11	2011-04-20 00:00:00	2011-07-07 00:00:00	2011-07-06 00:00:00	457
ct78d-D850-11	2011-04-20 00:00:00	2011-07-07 00:00:00	2011-07-06 00:00:00	458
ct64-M994-09	2010-04-11 00:00:00	2010-07-03 00:00:00	2010-06-16 00:00:00	466
ct64-M979-09	2010-01-31 00:00:00	2010-07-03 00:00:00	2010-06-16 00:00:00	467
ct64-M752-09	2010-04-11 00:00:00	2010-07-03 00:00:00	2010-06-16 00:00:00	468
ct64-M061-09	2010-04-11 00:00:00	2010-07-03 00:00:00	2010-06-16 00:00:00	469
ct64-M059-09	2010-04-10 00:00:00	2010-07-03 00:00:00	2010-06-16 00:00:00	470
ct64-M053-09	2010-01-26 00:00:00	2010-07-03 00:00:00	2010-06-16 00:00:00	471
ct64-M052-09	2010-04-11 00:00:00	2010-07-03 00:00:00	2010-06-16 00:00:00	472
ct64-M044-09	2010-04-11 00:00:00	2010-07-03 00:00:00	2010-06-16 00:00:00	473
ct64-M043-09	2010-01-29 00:00:00	2010-07-03 00:00:00	2010-06-16 00:00:00	474
ct64-M040-09	2010-02-03 00:00:00	2010-07-03 00:00:00	2010-06-16 00:00:00	475
ct64-M037-09	2010-01-17 00:00:00	2010-07-03 00:00:00	2010-06-16 00:00:00	476
ct64-M001-09	2010-01-20 00:00:00	2010-07-03 00:00:00	2010-06-16 00:00:00	477
ct61-04-09	2009-11-26 00:00:00	2010-07-03 00:00:00	2010-06-16 00:00:00	480
ct61-02-09	2009-11-05 00:00:00	2010-07-03 00:00:00	2010-06-16 00:00:00	482
ct61-03-09	2009-12-07 00:00:00	2010-07-03 00:00:00	2010-06-16 00:00:00	483
ct61-06-09	2009-11-26 00:00:00	2010-07-03 00:00:00	2010-06-16 00:00:00	484
ct61-07-09	2010-01-01 00:00:00	2010-07-03 00:00:00	2010-06-16 00:00:00	485
ct61-08-09	2009-11-06 00:00:00	2010-07-03 00:00:00	2010-06-16 00:00:00	486
ct78d-D496-11	2011-04-20 00:00:00	2011-07-07 00:00:00	2011-07-06 00:00:00	502
ct78d-D489-11	2011-04-20 00:00:00	2011-07-07 00:00:00	2011-07-06 00:00:00	503
ct64-M036-09	2010-01-26 00:00:00	2010-07-03 00:00:00	2010-06-16 00:00:00	504
ct78d-D484-11	2011-04-20 00:00:00	2011-07-07 00:00:00	2011-07-06 00:00:00	505
ct78d-D408-11	2011-04-20 00:00:00	2011-07-07 00:00:00	2011-07-06 00:00:00	506
ct78d-D400-11	2011-04-20 00:00:00	2011-07-07 00:00:00	2011-07-06 00:00:00	507
ct78d-D487-11	2011-04-20 00:00:00	2011-07-07 00:00:00	2011-07-06 00:00:00	508
ct78d-760-11	2011-04-20 00:00:00	2011-07-07 00:00:00	2011-07-06 00:00:00	518
\.


--
-- Data for Name: acorn_manual; Type: TABLE DATA; Schema: report; Owner: postgres
--

COPY acorn_manual (unique_id, site_id, code, code_full_name, code_type, start_date_of_transmission, last_checking_date, non_qc_data_availability_percent, non_qc_data_portal_percent, qc_data_availability_percent, qc_data_portal_percent, last_qc_data_received, data_on_staging, data_on_opendap, data_on_portal, uuid, mest_creation) FROM stdin;
6	2	ROT	Rottnest Shelf	site	2010-02-19 00:00:00	2014-02-15 00:00:00	88	86.2999999999999972	83.2000000000000028	75.7000000000000028	2013-11-20 00:00:00	\N	2010-12-01 00:00:00	2010-06-01 00:00:00	dc2743f5-709f-4760-b681-3cae02cbb6f0	2011-06-30 00:00:00
3	1	CBG	Capricorn Bunker Group	site	2007-09-29 00:00:00	2014-02-15 00:00:00	84.5999999999999943	77.4000000000000057	80.9000000000000057	71.7999999999999972	2013-09-14 00:00:00	\N	2010-12-01 00:00:00	2010-06-01 00:00:00	acc716df-0f45-46c2-9863-07a227c9760d	2011-06-30 00:00:00
1	1	TAN	Tannum Sands	station	2007-09-29 00:00:00	2014-02-15 00:00:00	93.2999999999999972	\N	91.2999999999999972	\N	2013-10-01 00:00:00	\N	2009-11-09 00:00:00	\N	5b867afa-10c5-4957-9130-b497b1379bf8	2011-06-30 00:00:00
2	1	LEI	Lady Elliott Island	station	2007-09-29 00:00:00	2014-02-15 00:00:00	88.2999999999999972	\N	86.2999999999999972	\N	2013-09-14 00:00:00	\N	2009-11-01 00:00:00	\N	00a49ec7-7597-406b-9005-0bdaea873e95	2011-06-30 00:00:00
9	3	SAG	South Australia Gulf	site	2009-09-29 00:00:00	2014-02-15 00:00:00	78.2000000000000028	75.9000000000000057	69.9000000000000057	62.2999999999999972	2013-11-27 00:00:00	\N	2010-12-01 00:00:00	2010-06-01 00:00:00	c95de3c2-1edb-41a6-8525-935434405fcc	2011-06-30 00:00:00
7	3	CSP	Cape Spencer	station	2009-12-02 00:00:00	2014-02-15 00:00:00	88.2000000000000028	\N	88.9000000000000057	\N	2013-11-27 00:00:00	\N	2010-01-08 00:00:00	\N	5fbe8b2b-9044-4dc5-8c3e-d3de74baa6e6	2011-06-30 00:00:00
10	4	NNB	North Nambucca	station	2012-03-09 00:00:00	2014-02-15 00:00:00	90.7999999999999972	\N	79.5999999999999943	\N	2013-10-21 00:00:00	\N	2012-03-27 00:00:00	\N	\N	\N
8	3	CWI	Cape Wiles	station	2009-09-29 00:00:00	2014-02-15 00:00:00	90.5	\N	83.5	\N	2013-11-30 00:00:00	\N	2009-11-28 00:00:00	\N	0fa0140a-786a-4de8-8a4f-28552205bb57	2011-06-30 00:00:00
11	4	RRK	Red Rock	station	2012-03-05 00:00:00	2014-02-15 00:00:00	91.2000000000000028	\N	86.2999999999999972	\N	2013-10-18 00:00:00	\N	2012-03-27 00:00:00	\N	\N	\N
12	4	COF	Coffs Harbour	site	2012-03-12 00:00:00	2014-02-15 00:00:00	88.9000000000000057	87.0999999999999943	77	75.9000000000000057	2013-10-18 00:00:00	\N	2012-04-21 00:00:00	2010-04-21 00:00:00	\N	\N
14	5	CRVT	Cervantes	station	2009-03-27 00:00:00	2014-02-15 00:00:00	95	\N	0	\N	\N	\N	2010-12-09 00:00:00	\N	95d5df74-b69e-479c-b9f7-f6d98cd64c47	2011-06-30 00:00:00
16	6	NOCR	Nora Creina	station	2010-05-21 00:00:00	2014-02-15 00:00:00	89.5	\N	0	\N	\N	\N	2010-07-30 00:00:00	\N	0da2422a-389d-4af6-a34c-a68caefbd23f	2011-06-30 00:00:00
17	6	BFCV	Blackfellows cave	station	2010-07-14 00:00:00	2014-02-15 00:00:00	90.9000000000000057	\N	0	\N	\N	\N	2010-07-21 00:00:00	\N	c455a298-6e4d-4ce3-8610-76f7abb59983	2011-06-30 00:00:00
15	5	TURQ	Turquoise Coast	site	2009-03-27 00:00:00	2014-02-15 00:00:00	88.2000000000000028	81	0	0	\N	\N	2011-03-03 00:00:00	2011-02-01 00:00:00	fb51aa08-c07e-4f7e-acf8-8e5dab108928	2011-06-30 00:00:00
18	6	BONC	Bonney Coast	site	2010-05-21 00:00:00	2014-02-15 00:00:00	86.5999999999999943	78.2000000000000028	0	0	\N	\N	2011-04-27 00:00:00	2011-11-01 00:00:00	2852a776-cbfc-4bc8-a126-f3c036814892	2011-06-30 00:00:00
4	2	GUI	Guilderton	station	2010-03-10 00:00:00	2014-02-15 00:00:00	90.4000000000000057	\N	92.4000000000000057	\N	2013-11-20 00:00:00	\N	2010-03-11 00:00:00	\N	59982321-dcaf-48c1-a2b1-643916952b46	2011-06-30 00:00:00
13	5	SBRD	SeaBird	station	2009-03-27 00:00:00	2014-02-15 00:00:00	90.2999999999999972	\N	0	\N	\N	\N	2010-12-09 00:00:00	\N	beea6da4-411a-4084-8665-1c6e343dc599	2011-06-30 00:00:00
5	2	FRE	Fremantle	station	2010-02-19 00:00:00	2014-02-15 00:00:00	93.5999999999999943	\N	89.2000000000000028	\N	2013-11-21 00:00:00	\N	2010-03-09 00:00:00	\N	6318db32-0e09-44b6-99c9-36288c4e926b	2011-06-30 00:00:00
\.


--
-- Data for Name: anfog_manual; Type: TABLE DATA; Schema: report; Owner: postgres
--

COPY anfog_manual (deployment_id, deployment_start, data_on_staging, data_on_opendap, data_on_portal, mest_creation, anfog_id) FROM stdin;
Yamba20120619	2012-06-19	2012-09-07	2012-09-21	2012-10-09	2012-10-11	89
Yamba20120714	2012-07-14	2012-09-11	2012-09-21	2012-10-09	2012-09-28	97
SpencerGulf20120412	2012-04-12	2012-09-11	2012-09-21	2012-10-09	2012-10-11	94
Pilbara20120630	2012-06-30	2012-09-11	2012-09-21	2012-10-09	2012-10-11	98
Kimberly20120529	2012-05-29	2012-09-03	2012-09-28	2012-10-09	2012-10-11	99
Kimberly20120727	2012-07-27	2012-10-30	2012-10-31	2012-10-31	2012-10-31	100
StormBay20120608	2012-06-08	2012-10-18	2012-10-23	2012-10-31	2012-10-23	101
StormBay20120823	2012-08-23	2012-10-18	2012-10-23	2012-10-31	2012-10-23	102
TwoRocks20120802	2012-08-02	2012-10-23	2012-10-31	2012-10-31	2012-10-31	103
TwoRocks20120517	2012-05-17	2012-10-29	2012-10-31	2012-10-31	2012-10-31	104
Yamba20120904	2012-09-04	2012-11-22	2012-11-30	2012-12-03	2012-12-03	105
SpencerGulf20120912	2012-09-12	2012-11-26	2012-11-30	2012-12-03	2012-12-03	106
Bicheno20090422	2009-04-21	2009-07-08	2009-07-10	2009-07-18	2009-07-16	3
Kalbarri20090519	2009-05-18	2009-06-18	2009-06-20	2009-06-28	2009-06-26	4
Kalbarri20091111	2009-11-11	2010-04-01	2010-04-11	2010-04-21	2010-04-12	5
NSW20091019	2009-10-18	2010-05-01	2010-04-11	2010-07-22	2010-06-01	6
Bicheno20091126	2009-11-26	2010-06-14	2010-07-16	2010-07-24	2010-07-22	7
MarionBay20090115	2009-01-01	2009-03-17	2009-03-19	2009-06-21	2009-03-25	8
MarionBay20080716	2008-07-16	2008-08-10	2008-08-12	2008-08-20	2009-08-18	9
CrowdyHead20091002	2009-10-01	2010-01-11	2010-01-13	2010-04-21	2010-02-09	10
MarionBay20091104	2009-11-04	2010-01-11	2010-01-13	2010-04-21	2010-02-09	11
TwoRocks20091208	2009-12-08	2010-01-24	2010-02-10	2010-04-21	2010-02-16	12
Kalbarri20091222	2009-12-22	2010-01-29	2010-02-10	2010-04-21	2010-02-16	13
PortStephens20091028	2009-10-28	2010-01-21	2010-01-30	2010-04-21	2010-02-09	14
TwoRocks20100122	2010-01-22	2010-05-21	2010-05-26	2010-07-22	2010-06-01	15
MarionBay20100210	2010-02-10	2010-05-28	2010-05-30	2010-07-22	2010-06-01	16
TwoRocks20100218	2010-02-18	2010-06-14	2010-07-16	2010-07-23	2010-07-21	17
SOTS20100320	2010-03-20	2010-07-21	2010-07-22	2010-09-28	2010-09-28	18
PortStephens20100309	2010-03-09	2010-06-14	2010-07-16	2010-07-23	2010-07-18	19
TwoRocks20090120	2009-01-20	2009-02-27	2009-03-01	2009-06-21	2009-03-07	20
TwoRocks20090220	2009-02-20	2009-03-29	2009-03-31	2009-06-21	2009-04-06	21
TwoRocks20090313	2009-03-13	2009-04-12	2009-04-14	2009-06-21	2009-04-20	22
TwoRocks20090327	2009-03-27	2009-04-19	2009-04-21	2009-06-21	2009-04-27	23
TwoRocks20090402	2009-04-02	2009-05-14	2009-05-16	2009-06-21	2009-05-22	24
TwoRocks20090515	2009-05-15	2009-06-20	2009-06-22	2009-06-30	2009-06-28	25
TwoRocks20090603	2009-06-03	2010-02-02	2010-02-10	2010-04-21	2010-02-16	26
TwoRocks20090729	2009-07-29	2010-01-11	2010-01-13	2010-04-21	2010-02-09	27
TwoRocks20090821	2009-08-21	2010-01-11	2010-01-13	2010-04-21	2010-02-09	28
Harrington20090317	2009-03-17	2009-04-26	2009-04-28	2009-06-21	2009-05-04	29
MariaIsland20090213	2009-02-12	2009-06-01	2009-06-11	2009-06-21	2009-06-16	30
MarionBay20090528	2009-05-28	2009-07-10	2009-07-12	2009-07-20	2009-07-18	31
PortStephens20081125	2008-11-25	2008-12-27	2008-12-29	2009-06-21	2009-01-04	32
PerthTrial_20090210	2009-02-09	2009-03-16	2009-04-01	2009-06-21	2009-06-20	33
Bicheno20110406	2011-04-06	2011-12-06	2011-12-13	2011-12-15	2011-10-21	34
Portland20090526	2009-05-26	2010-03-02	2010-03-03	2010-04-21	2010-04-06	35
NSW20110810	2011-08-10	2012-01-08	2011-12-13	2011-12-13	2011-10-21	36
Kimberly20111121	2011-11-21	2012-01-16	2012-01-17	2012-03-05	2011-12-14	37
StormBay20110926	2011-09-26	2012-05-01	2012-03-01	2012-03-05	2011-12-14	38
Bicheno20100813	2010-08-13	2011-08-09	2011-09-01	2011-09-13	2011-10-19	39
CoralSea20100601	2010-06-01	2011-03-21	2011-08-22	2011-09-13	2011-05-27	40
NSW20110518	2011-05-18	2011-08-01	2011-08-22	2011-09-13	2011-10-21	51
TwoRocks20120824	2012-08-24	2012-12-07	2012-12-13	2012-12-17	2012-12-13	113
CrowdyHead20100809	2010-08-09	2011-02-18	2011-02-19	2011-03-20	2011-03-10	41
Ningaloo20100906	2010-09-06	2011-01-19	2011-01-21	2011-03-20	2011-03-10	42
Perth20100517	2010-05-17	2010-10-06	2010-11-17	2011-03-20	2010-11-16	43
Perth20100810	2010-08-10	2010-10-06	2010-11-17	2011-03-20	2010-11-16	44
Perth20101026	2010-10-26	2011-07-01	2011-07-15	2011-09-13	2011-10-19	45
Perth20110626_1	2011-06-26	2011-08-29	2011-10-17	2011-10-18	2011-10-19	47
Perth20110626_2	2011-06-26	2011-11-10	2011-12-13	2011-12-15	2011-10-21	48
SOTS20100913	2010-09-13	2011-08-22	2011-09-13	2011-09-13	2010-09-28	49
SOTS20110420	2010-04-20	2011-07-25	2011-08-22	2011-09-13	2011-10-19	50
MarionBay20110202	2011-02-02	2011-06-07	2011-07-15	2011-09-13	2011-10-19	52
NSW20100921	2010-09-21	2010-06-14	2011-05-15	2011-05-26	2011-05-27	53
NSW20101126	2010-11-26	2011-05-16	2011-05-17	2011-05-26	2011-05-26	54
TwoRocks20100507	2010-05-07	2011-04-18	2011-05-15	2011-05-26	2011-05-25	55
TwoRocks20100628	2010-06-28	2011-05-09	2011-05-15	2011-05-26	2011-05-25	56
TwoRocks20100730	2010-07-30	2011-05-16	2011-05-17	2011-05-26	2011-05-25	57
TwoRocks20100805	2010-08-05	2011-05-16	2011-05-17	2011-05-26	2011-05-25	58
TwoRocks20100916	2010-09-16	2011-05-16	2011-05-17	2011-05-26	2011-05-25	59
TwoRocks20101026	2010-10-26	2011-06-01	2011-07-15	2011-09-13	2011-09-13	60
TwoRocks20110310	2011-03-10	2011-11-23	2011-12-13	2011-12-15	2011-12-14	61
TwoRocks20110412	2011-04-12	2011-06-24	2011-07-15	2011-09-13	2011-10-19	62
TwoRocks20110610	2011-06-10	2011-12-12	2011-12-13	2011-12-15	2011-12-14	63
TwoRocks20110818	2011-08-18	2011-12-12	2011-12-13	2011-12-15	2011-12-14	64
TwoRocks20110913	2011-09-13	2011-12-09	2011-12-13	2011-12-15	2011-12-14	65
Perth20110215	2011-02-15	2011-09-20	2011-10-17	2011-10-18	2011-10-19	46
StormBay20120313	2012-03-13	2012-09-24	2012-09-26	2012-10-09	2012-09-28	77
TwoRocks20120223	2012-02-23	2012-10-25	2012-10-31	2012-10-31	2012-10-31	73
StormBay20110805	2011-08-05	2012-12-10	2012-12-13	2012-12-17	2012-12-13	66
Kimberly20120914	2012-09-14	2013-03-04	2013-03-05	2013-03-06	2013-03-05	110
Coffs20111112	2011-11-12	2013-02-27	2013-02-28	2013-03-06	2013-03-05	115
PerthCanyon20121206	2012-12-06	2013-03-01	2013-03-05	2013-03-06	2013-03-05	116
Yamba20121114	2012-11-14	2013-03-06	2013-03-21	2013-03-21	2013-03-21	117
Pilbara20120723	2012-07-23	2013-04-12	2013-05-02	2013-05-02	2013-05-02	118
TwoRocks20130215	2013-02-15	2013-06-07	2013-06-11	2013-06-18	2013-06-11	119
StormBay20120904	2012-09-04	2013-06-10	2013-06-11	2013-06-18	2013-06-11	111
Kimberly20130214	2013-02-14	2013-06-12	2013-06-14	2013-06-18	2013-06-14	120
Pilbara20130212	2013-02-12	2013-06-12	2013-06-14	2013-06-18	2013-06-14	121
SpencerGulf20121127	2012-11-27	2013-06-14	2013-06-14	2013-06-18	2013-06-14	107
StormBay20121114	2012-11-14	2013-06-17	2013-06-18	2013-06-18	2013-06-18	122
StormBay20130208	2013-02-08	2013-06-24	2013-07-03	2013-07-03	2013-07-03	123
NSW20110809	2011-08-09	2011-12-12	2011-12-12	2013-07-10	2013-07-10	127
StormBay20120921	2012-09-21	2013-06-28	2013-07-03	2013-07-03	2013-07-03	124
StormBay20130226	2013-02-26	2013-07-01	2013-07-03	2013-07-03	2013-07-03	125
StormBay20121019	2012-10-19	2013-06-28	2013-07-03	2013-07-03	2013-07-03	108
Bremer20130221	2013-02-21	2013-06-28	2013-07-03	2013-07-03	2013-07-03	126
Pilbara20120211	2012-02-11	2012-10-18	2012-10-23	2012-10-31	2012-10-23	72
\.


--
-- Name: anfog_seq; Type: SEQUENCE SET; Schema: report; Owner: postgres
--

SELECT pg_catalog.setval('anfog_seq', 127, true);


--
-- Data for Name: anmn_datacategories_manual; Type: TABLE DATA; Schema: report; Owner: postgres
--

COPY anmn_datacategories_manual (pkid, instr_model, data_category) FROM stdin;
1	Aquatec Aqualogger 520	Temperature
2	NORTEK ADCP	Velocity
3	RDI ADCP	Velocity
4	SEABIRD SBE37SM	CTD
5	SEABIRD SBE39	Temperature
6	Teledyne RD Workhorse ADCP	Velocity
7	WETLABS WQM	Biogeochem
\.


--
-- Name: anmn_datacategories_manual_pkid_seq; Type: SEQUENCE SET; Schema: report; Owner: postgres
--

SELECT pg_catalog.setval('anmn_datacategories_manual_pkid_seq', 9, true);


--
-- Data for Name: anmn_manual; Type: TABLE DATA; Schema: report; Owner: postgres
--

COPY anmn_manual (pkid, platform_code, deployment_code, responsible_persons, responsible_organisation, planned_deployment_start, planned_deployment_end, deployment_start, deployment_end) FROM stdin;
1	PH100	PH100-1101	Moninya Roughan / Brad Morris	SIMS / OFS	2010-12-28	2011-01-28	2010-12-28	2011-01-28
2	PH100	PH100-1102	Moninya Roughan / Brad Morris	SIMS / OFS	2011-01-23	2011-03-04	2011-01-23	2011-03-04
3	PH100	PH100-1103	Moninya Roughan / Brad Morris	SIMS / OFS	2011-02-22	2011-03-31	2011-02-22	2011-03-31
4	PH100	PH100-1104	Moninya Roughan / Brad Morris	SIMS / OFS	2011-03-27	2011-05-15	2011-03-27	2011-05-15
5	PH100	PH100-1105	Moninya Roughan / Brad Morris	SIMS / OFS	2011-05-02	2011-06-23	2011-05-02	2011-06-23
6	PH100	PH100-1106	Moninya Roughan / Brad Morris	SIMS / OFS	2011-06-16	2011-09-02	2011-06-16	2011-09-02
7	KIM050	KIM050-1202	Craig Steinberg	AIMS	2012-02-01	2012-07-20	2012-02-01	\N
8	KIM100	KIM100-1202	Craig Steinberg	AIMS	2012-02-01	2012-07-20	2012-02-01	\N
9	KIM200	KIM200-1202	Craig Steinberg	AIMS	2012-02-02	2012-07-20	2012-02-02	\N
10	KIM400	KIM400-1202	Craig Steinberg	AIMS	2012-02-03	2012-07-20	2012-02-03	\N
11	CH070	\N	Moninya Roughan / Brad Morris	SIMS / UNSW	2012-07-15	2012-09-15	\N	\N
12	CH070	\N	Moninya Roughan / Brad Morris	SIMS / UNSW	2012-09-15	2012-11-15	\N	\N
13	CH070	\N	Moninya Roughan / Brad Morris	SIMS / UNSW	2012-11-15	2013-01-15	\N	\N
14	CH070	\N	Moninya Roughan / Brad Morris	SIMS / UNSW	2013-01-15	2013-03-15	\N	\N
15	CH070	\N	Moninya Roughan / Brad Morris	SIMS / UNSW	2013-03-15	2013-05-15	\N	\N
16	CH070	\N	Moninya Roughan / Brad Morris	SIMS / UNSW	2013-05-15	2013-06-15	\N	\N
17	CH100	\N	Moninya Roughan / Brad Morris	SIMS / UNSW	2012-07-15	2012-09-15	\N	\N
18	CH100	\N	Moninya Roughan / Brad Morris	SIMS / UNSW	2012-09-15	2012-11-15	\N	\N
19	CH100	\N	Moninya Roughan / Brad Morris	SIMS / UNSW	2012-11-15	2013-01-15	\N	\N
20	CH100	\N	Moninya Roughan / Brad Morris	SIMS / UNSW	2013-01-15	2013-03-15	\N	\N
21	CH100	\N	Moninya Roughan / Brad Morris	SIMS / UNSW	2013-03-15	2013-05-15	\N	\N
22	CH100	\N	Moninya Roughan / Brad Morris	SIMS / UNSW	2013-05-15	2013-06-15	\N	\N
23	SYD100	\N	Moninya Roughan / Brad Morris	SIMS / OFS	2012-07-15	2012-10-15	\N	\N
24	SYD100	\N	Moninya Roughan / Brad Morris	SIMS / OFS	2012-10-15	2013-01-15	\N	\N
25	SYD100	\N	Moninya Roughan / Brad Morris	SIMS / OFS	2013-01-15	2013-04-15	\N	\N
26	SYD100	\N	Moninya Roughan / Brad Morris	SIMS / OFS	2013-04-15	2013-06-15	\N	\N
27	SYD140	\N	Moninya Roughan / Brad Morris	SIMS / OFS	2012-08-15	2012-11-15	\N	\N
28	SYD140	\N	Moninya Roughan / Brad Morris	SIMS / OFS	2012-11-15	2013-02-15	\N	\N
29	SYD140	\N	Moninya Roughan / Brad Morris	SIMS / OFS	2013-02-15	2013-05-15	\N	\N
30	SYD140	\N	Moninya Roughan / Brad Morris	SIMS / OFS	2013-05-15	2013-06-15	\N	\N
31	PH100	\N	Moninya Roughan / Brad Morris	SIMS / OFS	2012-06-15	2012-09-15	\N	\N
32	PH100	\N	Moninya Roughan / Brad Morris	SIMS / OFS	2012-09-15	2012-12-15	\N	\N
33	PH100	\N	Moninya Roughan / Brad Morris	SIMS / OFS	2012-12-15	2013-03-15	\N	\N
34	PH100	\N	Moninya Roughan / Brad Morris	SIMS / OFS	2013-03-15	2013-05-15	\N	\N
35	PH100	\N	Moninya Roughan / Brad Morris	SIMS / OFS	2013-05-15	2013-06-15	\N	\N
36	BMP090	\N	Moninya Roughan / Brad Morris	SIMS / UNSW	2012-07-15	2012-09-15	\N	\N
37	BMP090	\N	Moninya Roughan / Brad Morris	SIMS / UNSW	2012-09-15	2012-11-15	\N	\N
38	BMP090	\N	Moninya Roughan / Brad Morris	SIMS / UNSW	2012-11-15	2013-01-15	\N	\N
39	BMP090	\N	Moninya Roughan / Brad Morris	SIMS / UNSW	2013-01-15	2013-03-15	\N	\N
40	BMP090	\N	Moninya Roughan / Brad Morris	SIMS / UNSW	2013-03-15	2013-05-15	\N	\N
41	BMP090	\N	Moninya Roughan / Brad Morris	SIMS / UNSW	2013-05-15	2013-06-15	\N	\N
42	BMP120	\N	Moninya Roughan / Brad Morris	SIMS / UNSW	2012-07-15	2012-09-15	\N	\N
43	BMP120	\N	Moninya Roughan / Brad Morris	SIMS / UNSW	2012-09-15	2012-11-15	\N	\N
44	BMP120	\N	Moninya Roughan / Brad Morris	SIMS / UNSW	2012-11-15	2013-01-15	\N	\N
45	BMP120	\N	Moninya Roughan / Brad Morris	SIMS / UNSW	2013-01-15	2013-03-15	\N	\N
46	BMP120	\N	Moninya Roughan / Brad Morris	SIMS / UNSW	2013-03-15	2013-05-15	\N	\N
47	BMP120	\N	Moninya Roughan / Brad Morris	SIMS / UNSW	2013-05-15	2013-06-15	\N	\N
\.


--
-- Name: anmn_manual_pkid_seq; Type: SEQUENCE SET; Schema: report; Owner: postgres
--

SELECT pg_catalog.setval('anmn_manual_pkid_seq', 49, true);


--
-- Data for Name: anmn_platforms_manual; Type: TABLE DATA; Schema: report; Owner: postgres
--

COPY anmn_platforms_manual (pkid, operator, platform_type, subfac_responsible, site_code, site_name, platform_code, platform_name, lat, lon, depth, first_deployed, active, comment, discontinued) FROM stdin;
77	SIMS	NRS sampling site	NSW	NRSPHB	Port Hacking National Reference Station	NRSPHB	Port Hacking NRS Water Sampling Site	-34.1159999999999997	151.218999999999994	100	2009-02-23	t	water sampling site only (mooring at PH100)	\N
1	SIMS	Shelf array	NSW	BMP090	Batemans Marine Park 90m	BMP090	Batemans Marine Park 90m Mooring	-36.1920000000000002	150.233000000000004	90	2011-03-30	t	Possibly Move into 70	\N
2	SIMS	Shelf array	NSW	BMP120	Batemans Marine Park 120m	BMP120	Batemans Marine Park 120m Mooring	-36.213000000000001	150.308999999999997	120	2011-03-30	t	\N	\N
5	AIMS	Shelf array	QLD	GBRCCH	Capricorn Channel	GBRCCH	Capricorn Channel Mooring	-22.4001358332999985	151.983500555599989	87	2007-09-01	t	\N	\N
6	AIMS	Shelf array	QLD	GBRELR	Elusive Reef	GBRELR	Elusive Reef Mooring	-21.0169036110999983	151.983500555599989	300	2007-09-01	t	\N	\N
7	AIMS	Shelf array	QLD	GBRHIN	Heron Island North	GBRHIN	Heron Island North Mooring	-23.3833349999999989	151.983391388900003	46	2007-09-01	t	\N	\N
8	AIMS	Shelf array	QLD	GBRHIS	Heron Island South	GBRHIS	Heron Island South Mooring	-23.5002216666999999	151.950081944400011	48	2007-09-01	t	\N	\N
9	AIMS	Shelf array	QLD	GBRLSH	Lizard Shelf	GBRLSH	Lizard Shelf Mooring	-14.6836033333000007	145.633504444399989	24	2007-11-01	t	\N	\N
10	AIMS	Shelf array	QLD	GBRLSL	Lizard Slope	GBRLSL	Lizard Slope Mooring	-14.3334358332999994	145.333505555599999	360	2007-11-01	t	\N	\N
11	AIMS	Shelf array	QLD	GBRMYR	Myrmidon	GBRMYR	Myrmidon Mooring	-18.266111111099999	147.333505833299995	200	2007-11-01	t	\N	\N
12	AIMS	Shelf array	QLD	GBROTE	One Tree East	GBROTE	One Tree East Mooring	-23.4833341667000006	152.166766111100003	60	2007-09-01	t	\N	\N
13	AIMS	Shelf array	QLD	GBRPPS	Palm Passage	GBRPPS	Palm Passage Mooring	-18.3001724999999986	147.150221111099995	60	2007-11-01	t	\N	\N
14	AIMS	Shelf array	QLD	ITFFTB	Flat Top Banks	ITFFTB	Flat Top Banks Shelf Mooring	-12.2834455556000002	128.466836388899992	103	2010-06-01	t	Change name to Timor Throughflow?	\N
15	AIMS	Shelf array	QLD	ITFJBG	Joseph Bonaparte Gulf	ITFJBG	Joseph Bonaparte Gulf Shelf Mooring	-13.6001363888999993	128.966687500000006	59	2010-06-01	t	Change name to Timor Throughflow?	\N
16	AIMS	Shelf array	QLD	ITFMHB	Margaret Harries Banks	ITFMHB	Margaret Harries Banks Shelf Mooring	-11	128	145	2010-06-01	t	Change name to Timor Throughflow?	\N
17	AIMS	Shelf array	QLD	ITFTIS	Timor South	ITFTIS	Timor South Shelf Mooring	-9.81667305560000081	127.550055277799999	465	2010-06-01	t	Change name to Timor Throughflow?	\N
19	AIMS	Shelf array	QLD	KIM050	Kimberley 50m	KIM050	Kimberley 50m Mooring	-16.3878999999999984	121.588130000000007	50	2012-02-01	t	\N	\N
20	AIMS	Shelf array	QLD	KIM100	Kimberley 100m	KIM100	Kimberley 100m Mooring	-15.6797599999999999	121.303799999999995	100	2012-02-01	t	\N	\N
21	AIMS	Shelf array	QLD	KIM200	Kimberley 200m	KIM200	Kimberley 200m Mooring	-15.5347000000000008	121.243070000000003	200	2012-02-02	t	\N	\N
22	AIMS	Shelf array	QLD	KIM400	Kimberley 400m	KIM400	Kimberley 400m Mooring	-15.2209699999999994	121.114710000000002	400	2012-02-03	t	\N	\N
23	AIMS	NRS	QLD	NRSDAR	Darwin National Reference Station	NRSDAR	Darwin NRS Mooring	-12.3334013889000005	130.683536388899995	20	2009-08-01	t	\N	\N
24	CMAR	NRS	WA	NRSESP	Esperance National Reference Station	NRSESP-ADCP	Esperance NRS ADCP Mooring	-33.916666666700003	121.849999999999994	52	2011-08-18	t	\N	\N
25	CMAR	NRS	WA	NRSESP	Esperance National Reference Station	NRSESP-SubSurface	Esperance NRS Sub-surface Mooring	-33.9333333332999985	121.849999999999994	51	2008-11-24	t	Longitude missing – copied from NRSESP-ADCP	\N
26	SARDI	NRS	ANMN	NRSKAI	Kangaroo Island National Reference Station	NRSKAI-CO2	Kangaroo Island Acidification Mooring	-35.8359999999999985	136.448000000000008	110	2012-02-08	t	Proposed location	\N
27	SARDI	NRS	SA	NRSKAI	Kangaroo Island National Reference Station	NRSKAI-SubSurface	Kangaroo Island NRS Sub-surface Mooring	-35.8359999999999985	136.448000000000008	110	2008-02-12	t	\N	\N
28	CMAR	NRS	ANMN	NRSMAI	Maria Island National Reference Station	NRSMAI-ADCP	Maria Island NRS ADCP Mooring	-42.599766666699999	148.232666666699998	90	2011-07-29	t	\N	\N
29	CMAR	NRS	ANMN	NRSMAI	Maria Island National Reference Station	NRSMAI-CO2	Maria Island Acidification Mooring	-42.5970000000000013	148.233000000000004	90	2011-04-01	t	\N	\N
30	CMAR	NRS	ANMN	NRSMAI	Maria Island National Reference Station	NRSMAI-SubSurface	Maria Island NRS Sub-surface Mooring	-42.5970000000000013	148.233000000000004	90	2008-05-01	t	\N	\N
31	CMAR	NRS	ANMN	NRSMAI	Maria Island National Reference Station	NRSMAI-Surface	Maria Island NRS Surface Mooring	-42.5970000000000013	148.233000000000004	90	2009-04-01	t	\N	\N
33	CMAR	NRS	ANMN	NRSNSI	North Stradbroke Island National Reference Station	NRSNSI-ADCP	North Stradbroke Island NRS ADCP Mooring	-27.3392283332999995	153.56177333330001	60	2010-12-13	t	\N	\N
34	CMAR	NRS	ANMN	NRSNSI	North Stradbroke Island National Reference Station	NRSNSI-SubSurface	North Stradbroke Island NRS Sub-surface Mooring	-27.3834263888999985	153.566892499999994	60	2009-09-01	t	\N	\N
35	CMAR	NRS	ANMN	NRSNSI	North Stradbroke Island National Reference Station	NRSNSI-Surface	North Stradbroke Island NRS Surface Mooring	-27.3409883333000003	153.561183333299994	60	2010-12-13	t	\N	\N
36	CMAR	NRS	WA	NRSROT	Rottnest Island National Reference Station	NRSROT-ADCP	Rottnest Island NRS ADCP Mooring	-32	115.400000000000006	50	2011-06-25	t	\N	\N
37	CMAR	NRS	WA	NRSROT	Rottnest Island National Reference Station	NRSROT-SubSurface	Rottnest Island NRS Sub-surface Mooring	-32	115.416666666699996	48	2008-11-19	t	\N	\N
38	AIMS	NRS	QLD	NRSYON	Yongala National Reference Station	NRSYON	Yongala NRS Mooring	-19.3001019444000015	147.616725833299995	28	2007-11-01	t	Awaiting repairs after Yasi Jan 2011 includes CO2 sensors	\N
39	SYDNEY WATER	Shelf array	NSW	ORS065	Ocean Reference Station Sydney	ORS065	Ocean Reference Station Sydney Mooring	-33.8975000000000009	151.315300000000008	65	2006-05-02	t	\N	\N
4	SIMS	Shelf array	NSW	CH100	Coffs Harbour 100m	CH100	Coffs Harbour 100m Mooring	-30.2680000000000007	153.396999999999991	100	2009-08-15	t	\N	\N
18	UNSW ADFA	Shelf array	NSW	JB070	Jervis Bay	JB070	Jervis Bay Mooring	-35.0829999999999984	150.849999999999994	70	2009-07-28	f	Obsolete - no longer maintained 7 oct 2009; No instruments returned; previously aka NSJB07	2009-10-07
32	AIMS	NRS	QLD	NRSNIN	Ningaloo Reef National Reference Station	NRSNIN	Ningaloo Reef NRS Mooring	-21.8679999999999986	113.933999999999997	55	2010-01-01	t	\N	\N
52	SIMS	Shelf array	NSW	PH100	Port Hacking 100m	PH100	Port Hacking 100m Mooring	-34.1203100000000035	151.224369999999993	110	2009-10-29	t	Site of T-string/ADCP/WQM mooring (different to NRSPHB, which is a water-sampling site ONLY)	\N
53	AIMS	Shelf array	QLD	PIL050	Pilbara 50m	PIL050	Pilbara 50m Mooring	-20.0546700000000016	116.416150000000002	50	2012-02-21	t	\N	\N
54	AIMS	Shelf array	QLD	PIL100	Pilbara 100m	PIL100	Pilbara 100m Mooring	-19.6943699999999993	116.111549999999994	100	2012-02-20	t	\N	\N
55	AIMS	Shelf array	QLD	PIL200	Pilbara 200m	PIL200	Pilbara 200m Mooring	-19.4355699999999985	115.915350000000004	200	2012-02-20	t	\N	\N
60	SARDI	Shelf array	SA	SAM5CB	M5 Coffin Bay	SAM5CB	M5 Coffin Bay Mooring	-34.9279999999999973	135.009999999999991	99	2009-02-05	t	\N	\N
63	SARDI	Shelf array	SA	SAM8SG	M8 Spencer Gulf Mouth	SAM8SG	M8 Spencer Gulf Mouth Mooring	-35.25	136.689999999999998	47	2009-06-02	t	\N	\N
64	CMAR	Shelf array	ANMN	SEQ200	South-East Queensland 200m	SEQ200	South-East Queensland 200m Mooring	-27.3399999999999999	153.775000000000006	200	2012-03-25	t	\N	\N
65	CMAR	Shelf array	ANMN	SEQ400	South-East Queensland 400m	SEQ400	South-East Queensland 400m Mooring	-27.3320000000000007	153.87700000000001	400	2012-03-24	t	\N	\N
66	SIMS	Shelf array	NSW	SYD100	Sydney 100m	SYD100	Sydney 100m Mooring	-33.9429999999999978	151.382000000000005	100	2008-06-25	t	\N	\N
67	SIMS	Shelf array	NSW	SYD140	Sydney 140m	SYD140	Sydney 140m Mooring	-33.9939999999999998	151.459000000000003	140	2008-06-25	t	\N	\N
68	CMAR	Shelf array	WA	WACA20	Canyon 200m Head (BGC)	WACA20	Canyon 200m Head Mooring	-31.9833333332999992	115.233333333299996	200	2010-01-22	t	\N	\N
70	CMAR	Shelf array	WA	WACASO	Canyon 500m South	WACASO	Canyon 500m South Mooring	-31.0500555556000002	115.0669333333	500	2010-01-22	t	\N	\N
71	CMAR	Shelf array	WA	WATR05	TwoRocks 50m	WATR05	Two Rocks 50m Shelf Mooring	-31.6168333333000007	115.233541666700006	50	2009-07-07	t	\N	\N
72	CMAR	Shelf array	WA	WATR10	TwoRocks 100m	WATR10	Two Rocks 100m Shelf Mooring	-31.633555555600001	115.183541666699995	100	2009-07-07	t	\N	\N
73	CMAR	Shelf array	WA	WATR15	TwoRocks 150m	WATR15	Two Rocks 150m Shelf Mooring	-31.6834999999999987	115.116666666699999	150	2009-07-07	t	\N	\N
74	CMAR	Shelf array	WA	WATR20	TwoRocks 200m (BGC)	WATR20	Two Rocks 200m Shelf Mooring	-31.7167111111000004	115.016888888899999	200	2009-07-13	t	\N	\N
75	CMAR	Shelf array	WA	WATR50	TwoRocks 500m	WATR50	Two Rocks 500m Shelf Mooring	-31.7667305555999988	114.933499999999995	500	2009-07-13	t	\N	\N
3	SIMS	Shelf array	NSW	CH070	Coffs Harbour 70m	CH070	Coffs Harbour 70m Mooring	-30.2749999999999986	153.300000000000011	70	2009-08-15	t	Possibly Move to 50m	\N
59	SARDI	Shelf array	SA	SAM4CY	M4 Canyon	SAM4CY	M4 Canyon Mooring	-36.5200000000000031	136.855999999999995	119	2009-02-04	f	Obsolete - no longer maintained	2010-03-16
69	CMAR	Shelf array	WA	WACANO	Canyon 500m North	WACANO	Canyon 500m North Mooring	-31.9220000000000006	114.992999999999995	500	2010-01-22	f	Discontinued 22 July 2010 due to sub/boat strike	2010-07-22
56	SARDI	Shelf array	SA	SAM1DS	M1 Deep Slope	SAM1DS	M1 Deep Slope Mooring	-36.5159999999999982	136.244	525	2008-12-10	f	Obsolete - no longer maintained	2009-06-04
57	SARDI	Shelf array	SA	SAM2CP	M2 Cabbage Patch	SAM2CP	M2 Cabbage Patch Mooring	-35.2680000000000007	135.683999999999997	99	2008-10-18	f	Obsolete - no longer maintained	2010-03-17
61	SARDI	Shelf array	SA	SAM6IS	M6 Investigator Strait	SAM6IS	M6 Investigator Strait Mooring	-35.5	136.599999999999994	82	2009-02-05	f	Obsolete - no longer maintained	2009-06-02
58	SARDI	Shelf array	SA	SAM3MS	M3 Mid-Slope	SAM3MS	M3 Mid-Slope Mooring	-36.1458999999999975	135.903999999999996	175	2011-02-22	t	Maintained for 6-8 months during summer/autumn depending on logistics\n	\N
62	SARDI	Shelf array	SA	SAM7DS	M7 Deep-Slope	SAM7DS	M7 Deep-Slope Mooring	-36.1809000000000012	135.843899999999991	500	2009-12-15	t	Maintained for 6-8 months during summer/autumn depending on logistics	\N
40	CURTIN	Shelf array	PA	PAPCA	Perth Canyon, WA Passive Acoustic Observatory	PAPCA	Perth Canyon, WA Passive Acoustic Observatory	-31.8919999999999995	114.938999999999993	455	2008-02-26	t	Nominal site. 2 to 4 loggers deployed each time.	\N
44	CURTIN	Shelf array	PA	PAPOR	Portland, VIC Passive Acoustic Observatory	PAPOR	Portland, VIC Passive Acoustic Observatory	-38.5450000000000017	141.241000000000014	168	2009-05-06	t	Nominal site. 2 to 4 loggers deployed each time.	\N
48	CURTIN	Shelf array	PA	PATUN	Tuncurry, NSW Passive Acoustic Observatory	PATUN	Tuncurry, NSW Passive Acoustic Observatory	-32.3100000000000023	152.926999999999992	161	2010-02-09	t	Nominal site. 2 to 4 loggers deployed each time.	\N
\.


--
-- Name: anmn_platforms_manual_pkid_seq; Type: SEQUENCE SET; Schema: report; Owner: postgres
--

SELECT pg_catalog.setval('anmn_platforms_manual_pkid_seq', 77, true);


--
-- Data for Name: anmn_status_manual; Type: TABLE DATA; Schema: report; Owner: postgres
--

COPY anmn_status_manual (pkid, site_code, platform_code, deployment_code, status_date, status_type, status_comment, updated) FROM stdin;
6	SAM5CB	SAM5CB	SAM5CB-0906-GAP	2009-06-02	NOT DEPLOYED	Not deployed until October 2009 due to lack of instruments.	2012-10-09
8	SAM7DS	SAM7DS	SAM7DS-1102	2011-02-22	NOT PROCESSED	CTD data not yet processed due to file size problem with Toolbox.	2012-10-09
7	SAM5CB	SAM5CB	SAM5CB-0910	2009-10-09	NOT PROCESSED	CTD data not yet processed due to file size problem with Toolbox.	2012-10-09
9	SAM8SG	SAM8SG	SAM8SG-0906	2009-06-02	NOT DEPLOYED	CTD not deployed.	2012-10-09
10	SAM8SG	SAM8SG	SAM8SG-0910-GAP	2009-10-06	NOT DEPLOYED	Not deployed until February 2010 due to lack of instruments.	2012-10-09
11	SAM8SG	SAM8SG	SAM8SG-1110	2011-10-25	DEPLOYMENT FAILED	No ADCP data due to battery failure.	2012-10-09
1	SAM3MS	SAM3MS	\N	2012-11-08	RECOVED	Approx date	2012-12-18
4	SAM8SG	SAM8SG	\N	2012-11-08	RECOVED	Approx date	2012-12-18
2	SAM5CB	SAM5CB	\N	2012-11-08	RECOVED	Approx date	2012-12-18
3	SAM7DS	SAM7DS	\N	2012-11-08	RECOVED	Approx date	2012-12-18
5	NRSKAI	NRSKAI	\N	2012-11-08	RECOVED	Approx date	2012-12-18
14	NRSKAI	NRSKAI	\N	2012-11-29	DEPLOYED		2012-12-18
15	SAM8SG	SAM8SG	\N	2012-11-30	DEPLOYED		2012-12-18
17	NRSKAI	NRSKAI	\N	2013-04-15	RECOVERED	Approximate date	2013-06-26
18	SAM8SG	SAM8SG	\N	2013-04-15	NOT RECOVERED	Approximate date. Mooring release issues - still in the water.	2013-06-26
\.


--
-- Name: anmn_status_manual_pkid_seq; Type: SEQUENCE SET; Schema: report; Owner: postgres
--

SELECT pg_catalog.setval('anmn_status_manual_pkid_seq', 18, true);


--
-- Data for Name: auv_manual; Type: TABLE DATA; Schema: report; Owner: postgres
--

COPY auv_manual (campaign_code, campaign_uuid, deployment_start, data_on_staging, data_on_opendap, data_on_portal, mest_creation, id) FROM stdin;
Tuncurry200911	\N	2009-11-01 00:00:00	\N	\N	\N	\N	91
ScottReef201108	\N	2011-08-01 00:00:00	\N	\N	\N	\N	93
Whyalla200806	ba9cffa9-480a-463c-a72a-0f0ef3cfdea0	2008-06-23 00:00:00	\N	\N	\N	2009-03-10 00:00:00	95
GBR200709	89fb5a5c-abe7-4aa3-bace-f758340cf49e	2007-09-28 00:00:00	2009-09-01 00:00:00	2009-09-15 00:00:00	2010-08-09 00:00:00	2010-02-11 00:00:00	96
Tasmania200810	60b2e700-f96f-4a29-9bd3-a3e1ca63726e	2008-10-06 00:00:00	2008-11-15 00:00:00	2008-11-20 00:00:00	2009-07-31 00:00:00	2009-04-01 00:00:00	97
SAJosephBanks200806	af15d920-8d19-496d-a813-0bbb9c9018ac	2008-06-15 00:00:00	\N	\N	\N	2009-03-10 00:00:00	98
Ningaloo200705	3cb49272-0b81-499d-9030-2bab96e2e21c	2007-05-20 00:00:00	\N	\N	\N	2009-03-10 00:00:00	99
GBR201107	\N	\N	\N	\N	\N	\N	100
Jervis201004	\N	\N	\N	\N	\N	\N	101
JervisBay200708	\N	\N	\N	\N	\N	\N	102
JervisBay200805	\N	\N	\N	\N	\N	\N	103
JervisBay200809	\N	\N	\N	\N	\N	\N	104
Ningaloo201203	\N	\N	\N	\N	\N	\N	105
NSW201111	\N	\N	\N	\N	\N	\N	106
RoyalSydYacht200903	\N	\N	\N	\N	\N	\N	108
Tasmania201206	\N	\N	\N	\N	\N	\N	110
Tuncurry201007	\N	\N	\N	\N	\N	\N	111
Batemans201011	f47a6929-1f19-4724-b74b-7c8579872cb7	2010-11-01 00:00:00	2012-05-12 00:00:00	2012-05-12 00:00:00	2012-05-12 00:00:00	2012-08-30 00:00:00	113
GBR201102	1ce0a3db-6c70-44d1-b092-3171e512b4ac	2011-02-01 00:00:00	2012-05-12 00:00:00	2012-05-12 00:00:00	2012-05-12 00:00:00	2012-08-30 00:00:00	114
ScottReef200907	783f9b8d-4ce2-417b-aeb1-234799dc4696	2009-07-26 00:00:00	2009-09-01 00:00:00	2009-09-15 00:00:00	2010-08-09 00:00:00	2012-08-30 00:00:00	115
Tasmania200903	c5b6340a-bbc2-4b0c-85ef-83aab49f42ac	2009-06-10 00:00:00	2010-04-01 00:00:00	2010-05-20 00:00:00	2010-08-09 00:00:00	2012-08-30 00:00:00	116
Tasmania200906	c211b8bd-c504-4b6e-8d62-8aad3341797e	2009-06-10 00:00:00	2010-03-29 00:00:00	2010-05-20 00:00:00	2010-08-09 00:00:00	2012-08-30 00:00:00	117
Tasmania201006	1664dcfa-8be7-4edf-b578-4c8e30021acb	2010-06-02 00:00:00	2010-08-07 00:00:00	2010-08-10 00:00:00	2010-08-12 00:00:00	2012-08-30 00:00:00	118
Tasmania201106	af2a50b8-4d0f-44c9-8209-88c691db8d9c	2011-06-01 00:00:00	2012-05-12 00:00:00	2012-05-12 00:00:00	2012-05-12 00:00:00	2012-08-30 00:00:00	119
WA201004	23ee6500-b36f-4a95-8841-505a20f967ad	2010-04-20 00:00:00	2010-05-01 00:00:00	2010-05-20 00:00:00	2010-08-09 00:00:00	2012-08-30 00:00:00	120
SEQueensland201010	fc8fef03-d6c1-4791-a216-81c1248e4fc4	2010-10-21 00:00:00	2010-10-23 00:00:00	2012-10-22 00:00:00	2012-11-01 00:00:00	2012-12-03 00:00:00	94
SEQueensland201110	\N	2011-11-22 00:00:00	2011-11-24 00:00:00	2012-10-22 00:00:00	2012-11-01 00:00:00	2012-12-03 00:00:00	109
WA201104	0f379372-f0c3-4c86-aa25-4aeaa3986635	2011-04-01 00:00:00	2011-04-14 00:00:00	2012-10-22 00:00:00	2012-11-01 00:00:00	2012-12-03 00:00:00	92
PS201012	\N	2010-12-15 00:00:00	2010-12-19 00:00:00	2012-10-22 00:00:00	2012-11-01 00:00:00	\N	107
WA201204	bfc49629-7949-43b2-9448-d32767712f4a	2012-04-19 00:00:00	2012-05-01 00:00:00	2012-10-22 00:00:00	2012-11-01 00:00:00	\N	112
SolitaryIs201208	6be08828-275d-4a5c-9478-f5fe20613709	2012-08-22 00:00:00	2012-09-04 00:00:00	2012-10-22 00:00:00	2012-11-01 00:00:00	\N	123
\.


--
-- Data for Name: facility_summary; Type: TABLE DATA; Schema: report; Owner: postgres
--

COPY facility_summary (row_id, reporting_date, summary, facility_name_id, summary_item_id) FROM stdin;
55	2013-06-18 00:00:00	Six new Slocum glider deployment published on the IMOS portal (TwoRocks20130215,StormBay20120904,Kimberly20130214,Pilbara20130212,SpencerGulf20121127,StormBay20121114)	453	1
56	2013-07-02 00:00:00	17 new missions have been uploaded to emII(SouthernSurveyor: SS2012_T01,SS2012_V01,SS2012_T02,SS2012_V02,SS2012_T03,SS2012_V03; Aurora Australis: AA1213_VMS,AA1213_V1, AA1213_V2,AA1213_V3AA1213_V4; \r\nAstrolabe: AL1213_R0_southbound,AL1213_R0_northbound,AL1213_R2_southbound,AL1213_R2_northbound,AL1213_R4_southbound,AL1213_R4_northbound). Metadata records have been created and data are available through opendap and on the IMOS portal.	457	1
58	2013-07-08 00:00:00	Snow petrel data: The AAD (Barbara Wienecke) has given access to all raw data and metadata from snow petrel deployments. eMII now holds raw GLS data for 16 deployments for 2010/2011, and 13 deployments for 2011/2012. These raw data (hexadecimal format) are currently getting processed by Mark Hindell and Simon Wotherspoon to extract geographic information.	502	1
59	2013-07-08 00:00:00	Emperor penguin data: Xavier sent an email to and met Barbara Wienecke, who said that she will work with people at the AAD Data Centre to make those data available to eMII very soon. Xavier will re-contact Barbara if she hasn't heard from her by Thursday 11/07.\r\n\r\neMII currently only holds Argos data for emperor penguin deployments made in 2010/2011 (n =12), but doesn't have any associated metadata. eMII is expecting the following amount of data: 12 datasets from tags deployed in 2010/2011, 15 for tags deployed in 2011/2012, and 15 for tags deployed in 2012/2013.	502	1
63	2013-07-08 00:00:00	Shearwater GLS data: eMII only holds processed data on 33 individuals tagged in 2010/2011 (from 23/10/2010 to 27/02/2011). Mark said he will provide eMII will all the raw shearwater data he has along with the associated calibration files (2009/2010, 2010/2011, 2011/2012, 2012/2013?), and the processed shearwater data that eMII doesn't have yet (2009/2010, and 2011/2012). eMII has not received any shearwater GLS data from Rob Harcourt's team yet.	502	1
57	2013-07-09 00:00:00	QC data for 5 new deployments are now available through opendap and the IMOS portal(StormBay20120921, StormBay20121019, StormBay20130208, StormBay20130226, Bremer20130221)	453	1
62	2013-07-08 00:00:00	Shearwater GLS metadata: Rob Harcourt has asked Dustin O'Hara on 04/07 to input the metadata for the GLS tags he deployed this year on shearwaters.\r\nMark Hindell has to ask one of his student (Delphie) to gather all information related to IMOS funded GLS tag deployments on shearwaters, and send all that to Xavier.	502	2
61	2013-07-08 00:00:00	Satellite tagging metadata: Simon Goldsworthy has provided Xavier with all metadata information Xavier had requested.\r\nMark Hindell has to put together all the information  (e.g. deployment date and location, PI, attachment method, morphometric measurements, sex, age class, type of tag) for the deployments he is in charge of that he has in various Excel spreadsheets and send that to Xavier.\r\nRob Harcourt has asked Clive McMahon and Marcus Salton on 04/07 to input the metadata for all elephant seal and fur seal deployments.	502	2
60	2013-07-08 00:00:00	Satellite tagging data: Mark Hindell has provided Xavier with MS Access database files for eight campaigns that weren't IMOS funded (i.e. awru1, ct22, ct56, ct6, wd1, wd2, wd3), he will provide Xavier with data for the other three campaigns later (ct75, ct47, and ct38w) due to missing login/password.\r\n\r\nNear real-time data: WMO codes available for some active deployments, Xavier is working on Talend to re-establish the near-real time workflow for satellite tagging data.\r\nDelayed-mode data: Xavier is working on Talend to convert data in MS Access databases into a PostgreSQL database so that users will be able to download all biological and physical data.	502	1
64	2013-07-08 00:00:00	-ROT FV01 radials have been uploaded from the time period 2013-01-30 to 2013-05-16 and are available on OPENDAP. FV01 hourly averaged products have been created accordingly and are available on OPENDAP.\r\n-TURQ and BONC FV00 vector files are back. A bug has been interrupting their transmission to eMII since early April 2013. Thus FV00 hourly averaged products are also available.\r\n-Links on the portal from the "ACORN radar stations" have been updated to the new THREDDS server URL. Other ACORN links are still pointing towards QCIF old THREDDS server and are currently broken.	455	1
65	2013-07-10 00:00:00	Water sampling program: Carbon data in new aggregated Excel format has been published for Kangaroo Island and Porth Hacking (other stations yet to come).  New HPLC Pigments data published for Darwin, Esperance, Maria Island, Ningaloo and Yongala.	494	1
66	2013-07-10 00:00:00	Marty & Rog met with Jeanette O’Sullivan, Dave Watts, Tim Lynch, and Ken Ridgway to discuss management of all Maria Island data: 1) historically obtained by CMAR;  2) currently collected under IMOS; and  3) new data products to be produced. Rog has written a summary with action items. 	494	3
67	2013-07-10 00:00:00	Still waiting for Carbon data data updates for most stations. With one exception, we have no data past April 2012. Suggestion: IMOS office to contact Bronte Tilbrook.	494	4
68	2013-07-10 00:00:00	The basic version of the Acoustic Data Viewer application is now complete. We've received feedback from the sub-facility and other users, and implemented some of their suggestions. We have a list of further improvements, to be implemented when the development team has time.	474	5
69	2013-07-10 00:00:00	The Kangaroo Island CO2 mooring has been retreived and is no longer transmitting real-time data. Awaiting deployment of Yongala CO2 mooring.	509	5
70	2013-07-10 00:00:00	No delayed-mode processed data at all, and no indication of when these might be available. Marty has asked Bronte about this several times but has received no response.	509	4
71	2013-07-10 00:00:00	The first datasets from the ITF deepwater array have been processed and delivered to eMII. Will be published soon, after a few metadata issues are fixed.	485	1
72	2013-07-10 00:00:00	Real-time SOFS data still not being updated on portal. Marty workin on setting this up again.	485	4
73	2013-07-10 00:00:00	We have agreed with the sub-facility leaders on a rough plan for supplying ABOS data to OceanSITES. Sub-facilities will produce the files in the appropriate format, eMII (Marty) will act as local DAC, upload files to global DAC and participate in OceanSITES data management team.	485	5
74	2013-07-10 00:00:00	One slocum glider present on the opendap (NSW20110809) server but unpublished as been processed and is now available on the IMOS portal.	453	1
1	2012-09-13 00:00:00	Bundle of data collected by BOM in 2011 has been transferred to eMII for processing	456	1
28	2013-01-15 00:00:00	New data from all NSW moorings has been made public.	495	1
31	2013-01-15 00:00:00	New data for North Stradbroke and Rottnest Island NRS moorings has been made public.\r\nNRS Biogeochemical sampling: New logsheets for North Stradbroke, Darwin, and Port Hacking. New and re-processed CTD profiles for Maria, North Stradbroke, Darwin, Ningaloo & Rottnest.	494	1
75	2013-07-11 00:00:00	-CBG FV01 radials have been uploaded from the time period 2013-02-04 to 2013-05-28 and are available on OPENDAP. FV01 hourly averaged products have been created accordingly and are available on OPENDAP.\r\n-Current ncwms.emii.org.au server has been updated with the links to the new Melbourne THREDDS server.	455	1
76	2013-07-22 00:00:00	-COF FV01 radials have been uploaded from the time period 2013-03-25 to 2013-07-04 and are available on OPENDAP. FV01 hourly averaged products have been created accordingly and are available on OPENDAP.\r\n-The new ncWMS server ncwms.aodn.org.au is now displayed on the new portal, that is to say that real-time data are available to be displayed again since December 2012!	455	1
77	2013-08-07 00:00:00	Satellite tags: all near real-time data, delayed-mode data, and corresponding metadata are now available in a database format. Those data will be made available through the portal soon and users will be able to filter them.	502	1
78	2013-08-07 00:00:00	Emperor penguin data: Xavier is in touch with Dave Connell and Miles at the AAD who have agreed to provide those Argos data in a .csv format in the next week or two.	502	1
79	2013-09-10 00:00:00	-Historical data from the datafabric has finally been moved to the new storage server in Melbourne and is now available through THREDDS. Collisions (historical files with the same name but different content of an already existing file in Melbourne) haven't been processed yet.\r\n-COF FV01 radials are available again from the time period 2013-03-01 to 2012-10-23 Through THREDDS. FV01 hourly averaged products have been created accordingly and are available on THREDDS.	455	1
80	2013-09-10 00:00:00	-The imos portal looks like it is not displaying the relevant WMS image for a specific date/time.\r\n-The ncWMS server ncwms.aodn.org.au used by the imos portal is not displaying directionnal data with vector properly. It looks like the U component of the vector is inversed.\r\n\r\nThese 2 issues are listed on the portal GitHub list of issues and should be fixed in the next iterations.	455	4
83	2013-09-12 00:00:00	Meeting with Lesley Clemenston in order to get the infrastructure of the AEsOP project (a database and web frontend to get data) into the IMOS portal	482	1
30	2013-01-15 00:00:00	New data for Perth Canyon 200m, Two Rocks 100m & 200m moorings has been made public. Also new CTD profiles (text format) for Two Rocks 100m and Perth Canyon 200m.	498	1
84	2013-09-12 00:00:00	Many new campaigns have been uploaded recently. The data is currently being processed to be incorporated into the AUV viewer (but some data issues slow down the process). However, the data is already publicly accessible.	480	1
34	2013-01-15 00:00:00	Updated map layers for Satellite Tags to allow independent plotting of tracks for each species. The menu now has a separate layer for each marine mammal species.	502	1
35	2013-02-15 00:00:00	The Acoustic Data Viewer application is running with the most basic functionality. Two data sets can be viewed. The viewer is available to the public and linked from the portal via the sub-facility metadata record.	474	1
36	2013-02-15 00:00:00	No new data uploads during data migration to new storage. However, all data links for netCDF data now point to the new IMOS THREDDS server.\r\nNRS Biogeochem: Received the first two Carbon files in new Excel template. Finalised template for Suspended matter data.	494	1
37	2013-03-15 00:00:00	QC data for 3 deployments are now available through OPeNDAP and the IMOS portal (Coffs20111112,PerthCanyon20121206,Kimberly20120914)	453	1
38	2013-04-10 00:00:00	One new Slocum glider deployment published on the IMOS portal(Yamba20121114).	453	1
39	2013-04-12 00:00:00	NRS Biogeochemical sampling: Suspended matter data for all stations have been aggregated into the new Excel template and made public.	494	1
85	2013-09-12 00:00:00	AIMS team has changed/updated their operational web service which we query to download FAIMMS - NRS Darwin and Yongala - SOOP TRV data.  As usual, their web service was not tested, and many bugs appeared. \r\nWe proposed a solution to avoid this type of errors in the future (having a stable branch and a development branch of their web service). But this is unfortunately not possible for them put in place	454	1
86	2013-09-12 00:00:00	The SRS SST products used to be viewed using the ncWMS server at IVEC. With the shutdown of this latter, the AODN ncWMS server is now replacing it.	483	1
82	2013-09-12 00:00:00	Real-time satellite tagging data are now being harvested daily by a Talend job that puts all the data in the database.	502	1
98	2013-10-15 00:00:00	% New Slocum deployment received but NOT published( StormBay20130325,  Pilbara20130310, Yamba20130531, SpencerGulf20130411, TwoRocks20130416)\r\n\r\nRealtime Slocum Glider and Seaglider back on the portal.	453	1
23	2013-01-15 00:00:00	The NSW PA site has been re-labelled from "Sydney, NSW" (site code "PASYD") to "Tuncurry, NSW" ("PATUN") as that town is much closer, and sites nearer to Sydney may be used in the future. Metadata records and the portal layer have been updated.	474	1
87	2013-09-19 00:00:00	-SAG FV01 radials have been uploaded from the time period 2013-05-09 to 2013-08-10 and are available on THREDDS. FV01 hourly averaged products have been created accordingly and are available on THREDDS. 	455	1
88	2013-09-24 00:00:00	-ROT FV01 radials have been uploaded from the time period 2013-05-16 to 2013-08-08 and are available on THREDDS. FV01 hourly averaged products have been created accordingly and are available on THREDDS. 	455	1
89	2013-10-07 00:00:00	ACORN data migration from former datafabric to the new servers in Melbourne is complete! Collisions identified during the merge have been processed so that there is only the non-corrupted last up-to-date datasets left in Melbourne.	455	1
90	2013-10-10 00:00:00	Data that will be delayed in publishing are:\r\n- Argos emperor penguin data from Barbara Wienecke (AAD) - 42 deployments (should obtain those shortly from Miles Jordan). Currently eMII only has data for the deployments of 2010/2011 (n = 12). \r\n- Snow petrel data in hexadecimal format (16 deployments in 2010/2011, 13 deployments in 2011/2012).\r\n- Shearwater tracking data for 2010/2011 (n = 33 deployments).\r\n- Delayed-mode satellite tracking data from seals and sea lions (three deployment campaigns, i.e. more than 30 deployments).	502	1
92	2013-10-11 00:00:00	487 sensor data files (from 19 deployments) waiting on staging.	495	1
3	2012-10-14 00:00:00	All data (except data collected by SCRIPPS) for 2011 and early 2012 have been processed \r\nand are available through OPeNDAP and the IMOS portal	456	1
7	2012-12-13 00:00:00	Realtime data for 2 new realtime slocum deployment are available in the staging directory but not through the IMOS portal yet.	453	1
9	2012-12-13 00:00:00	All the raw data has been downloaded to a disk at eMII. Two data sets are on the new storage in Melbourne, ready to be viewed via the Acoustic Data viewer (just waiting for the storage to be web-accessible).	474	1
11	2012-12-17 00:00:00	Data for 3 new cruises of the Southern Surveyor (SS2011_V04, SS2011V05 and SS2011_V07) have been transferred to eMII. Data is available through OPeNDAP. Metadata records will need to be created.	457	1
12	2012-12-17 00:00:00	Data for 5 deployments of the Will Watch have been trasnferred to eMII. Data is now available through OPeNDAP. Metadata records will need to be created.	479	1
93	2013-10-11 00:00:00	191 data files (from 14 deployments) waiting on staging.	496	1
94	2013-10-11 00:00:00	No data waiting on staging.	497	1
95	2013-10-11 00:00:00	24 data files (8 deployments) waiting on staging.	498	1
91	2013-10-11 00:00:00	118 biogeochemical data files and 81 sensor data files (8 deployments) waiting on staging.\r\nReal-time data streams still being updated to public, though no new data has been received from North Stradbroke NRS since Sep 17.	494	1
16	2012-12-18 00:00:00	New campaign available on the portal in the southern ocean, west of Tasmania	482	1
17	2012-12-18 00:00:00	Some work has been done with Vittorio's team to deliver AC9 and HS6 data. eMII will have to convert those data and make sure they fulfil the requirements (the estimated deadline for these data to be on the portal is the end of January)	482	1
19	2012-12-18 00:00:00	received updated version of all the previous NetCDF files. The new version includes now Salinity (while only conductivity before). This will be available on the portal soon. eMII needs to update the associated metadata record 	481	1
22	2013-01-14 00:00:00	Updating of SOFS real-time data has been put on hold during the migration from the Data Fabric to Uni of Melbourne.	485	1
24	2013-01-15 00:00:00	Updating of ACORN real-time data has been put on hold during the migration from the Data Fabric to Uni of Melbourne.	455	1
25	2013-01-15 00:00:00	Creation of metadata records to describe the MV Xutra Bhum and the MV Wana Bhum. \r\n\r\nUpdating of SOOP-SST real-time data has been put on hold during the migration from the Data Fabric to Uni of Melbourne.	461	1
26	2013-01-15 00:00:00	Creation of metadata records to describe data collected during the following 3 cruises: SS2011V04, SS2011V05 and SS2011V07.	457	1
27	2013-01-15 00:00:00	Creation of metadata records to describe data collected during 7 deployments of the Will Watch and 1 deployment of the Aurora Australis	479	1
29	2013-01-15 00:00:00	New data from GBR Capricorn Channel and Kimberley moorings has been made public. Sub-facility metadata record has been updated.	496	1
96	2013-10-11 00:00:00	** SOFS real-time data are being published on opendap again (updated daily).   \r\n** Data from the first deployments from the ITF deepwater array have been published. Updated (aggregated) versions of these files have also been uploaded but are still on staging.   \r\n** New Pulse-9 data are also waiting on staging.	485	1
97	2013-10-14 00:00:00	Many new campaigns have been uploaded in the last month. They are all available on the IMOS portal as well as on the AUV viewer.\r\nMetadata records at the campaign level haven't been yet populated (waiting for an abstract about each mission from the facility)	480	1
99	2013-11-05 00:00:00	3 new Slocum deployments received but not published on the portal (Heron20121127, Heron20130403, StormBay20130620)\r\n\r\nData for 3 Realtime deployment  are currently received (Slocum: TwoRocks20131017; Seaglider: Leeuwin20131017, Lizard20131024)\r\nData for 1 Realtime deployment have been received and glider has been  recovered (Kimberly20130925) 	453	1
100	2013-11-07 00:00:00	200 biogeochemical data files and 119 sensor data files (11 deployments) waiting on staging.\r\nReal-time data streams still being updated to public, though no new data has been received from North Stradbroke NRS since Sep 17.	494	1
101	2013-11-07 00:00:00	675 sensor data files (from 25 deployments) waiting on staging.	495	1
102	2013-11-07 00:00:00	133 sensor data files (from 11 deployments) waiting on staging. \r\nData from a recent deployment of the Pilbara moorings has been published by special request from Craig Steinberg. 	496	1
103	2013-11-07 00:00:00	68 sensor data files (from 12 deployments) waiting on staging.	498	1
104	2013-11-07 00:00:00	** SOFS has been recovered, so real-time data are no longer updated.\r\n** Aggregated files for the ITF deepwater array have been uploaded but are still on staging.\r\n** New Pulse-9 data are also waiting on staging.	485	1
42	2013-04-15 00:00:00	Bundle of data collected by BOM and CSIRO in 2012 have been transferred to eMII for processing.\r\nIMOS compliant NetCDF files have been produced but thay are not available on OPeNDAP yet. 	456	1
43	2013-04-15 00:00:00	SCRIPPS XBT data for the period 2010-2012 has been transferred to eMII for processing. \r\nIMOS compliant NETCDF files have been produced.\r\nSebastien is chasing data for some missing cruises which are available through the SCRIPPS website	456	1
44	2013-04-15 00:00:00	Peter, Laurent and Sebastien had two meetings with Edward King to discuss changes in the workflow to store, serve, visualise and access satellite gridded products.	483	1
45	2013-04-15 00:00:00	Data are ongoing and automatically ingested to the IMOS database from the CSIRO database. Data entry is managed by the AusCPR team in Queensland. 	458	1
105	2013-11-11 00:00:00	Data on hold and received this month: all Argos emperor penguin data from Barbara Wienecke (AAD) - 42 deployments.	502	1
47	2013-05-14 00:00:00	One new Slocum glider deployment published on the IMOS portal(Pilbara20120723).	453	1
106	2013-11-12 00:00:00	-CBG FV01 radials have been uploaded from the time period 2013-05-28 to 2013-09-14 and are available on THREDDS. FV01 hourly averaged products have been created accordingly and are available on THREDDS. 	455	1
48	2013-05-15 00:00:00	New data published for Esperance, Rottnest Is and Kangaroo Is NRS.\r\nAll data now being (re-)processed with the latest version of the IMOS Matlab Toolbox (v2.2), featuring a standard set of QA/QC procedures.	494	1
49	2013-05-15 00:00:00	New data published for Batemans Marine Park and Coffs Harbour moorings.\r\nAll data now being (re-)processed with the latest version of the IMOS Matlab Toolbox (v2.2), featuring a standard set of QA/QC procedures.	495	1
50	2013-05-15 00:00:00	New data published from Indonesian Throughflow, Pilbara and Kimberley arrays.\r\nAll data now being (re-)processed with the latest version of the IMOS Matlab Toolbox (v2.2), featuring a standard set of QA/QC procedures.	496	1
51	2013-05-15 00:00:00	New data published for Mid-Slope, Coffin Bay, Deep-Slope and Spencer Gulf Mouth moorings.\r\nAll data now being (re-)processed with the latest version of the IMOS Matlab Toolbox (v2.2), featuring a standard set of QA/QC procedures.	497	1
52	2013-05-15 00:00:00	New data published from Perth Canyon South, and Two Rocks 200m & 500m moorings.\r\nAll data now being (re-)processed with the latest version of the IMOS Matlab Toolbox (v2.2), featuring a standard set of QA/QC procedures.	498	1
53	2013-05-15 00:00:00	Real-time raw CO2 measurements from the Kangaroo and Maria Island moorings are now available via the Portal in netCDF format. They are updated with new data once a day.\r\nRaw data from all previous deployments of these moorings are also available.	509	1
54	2013-05-29 00:00:00	COF FV01 radials have been uplaoded from the time period 2012-10-23 to 2013-03-24 and are available on OPENDAP. Hourly average product has also been created accordingly and is available on OPENDAP.	455	1
107	2013-11-15 00:00:00	As of about 2013-11-11 there has been\r\na significant degradation of the data quality at LEI.  ACORN is working\r\non a solution.  LEI staff have been helpful but simple recovery\r\nprocedures have not worked.  ACORN is shipping a spare part to LEI that\r\nwe hope will fix the problem.	455	4
108	2013-11-22 00:00:00	The problem at LEI seems to be sorted out and hourly gridded data files are back to production from 2013-11-22 12:30pm. There will be a gap between 2013-11-11 and 2013-11-22 for CBG hourly gridded product	455	4
109	2013-11-26 00:00:00	The air conditioning system at GUI (WA) has been reported vandalised on 2013-11-25 and until ACORN has a replacement they have had to shut down the system to avoid any damage.	455	4
110	2013-12-06 00:00:00	-COF FV01 radials have been uploaded from the time period 2013-07-04 to 2013-10-18 and are available on THREDDS. FV01 hourly averaged products have been created accordingly and are available on THREDDS. 	455	1
33	2013-01-15 00:00:00	The 'point of truth' link in IMOS metadata is hard coded to refer to a GeoNetwork MEST record and we haven't yet been able to introduce flexibility to enable us to replace that link with a CAASM link.\n\nUpdated the IMOS metadata record to mirror the CAASM metadata record. Added a link to the IMOS record that points to the CAASM record as the 'source record' for metadata. Removed the metadata links that pointed to old datasets (original delivery of data from 1990 to 2008), and ensured that the new data are available through the portal. Changed all citation instructions to match the AAD Data Centre citation guidelines. Updated the information that appears in the portal pop-up windows so that it instructs users to contact Graham Hosie for help with using these data. Updated the styles of the Southern Ocean CPR layer to bring it closer, visually, to the other plankton layers.	458	4
40	2013-04-15 00:00:00	Archival tags data of emperor penguins and snow petrels still at the AAD. Shavawn had a meeting with Barbara about those data, Tim to talk to Nick in the near future.\r\n\r\nArchival tags data of short tailed shearwaters still with Mark Hindell, will have a meeting with him about those (availability + processing technique) when he gets back from Campbell Island (17/04/2013).\n\nAll SMRU CTD tags associated with the 'IMOS Kerguelen' (ct96) program have been deployed. \r\n\r\nMark Hindell agreed to provide IMOS with data from previous satellite tagging campaigns that were not IMOS funded (n = 11 campaigns, don't know how many tags yet).\r\n\r\nStarted working on how to publish additional information from CTD satellite tags (e.g. Argos locations, diving profiles) - most likely through a database created with Talend.\r\n\r\nCTD data from each animal satellite tagged were used to produce two plots (TEMP ~ DEPTH x TIME & PSAL ~ DEPTH x TIME)  and two animations (SST ~ LAT x LONG x TIME & SSSAL ~ LAT x LONG x TIME) per animal. Those plots are now all finalised and a job has been logged with Peter's team to make them available through the portal.	502	4
2	2012-11-09 00:00:00	No real-time data is available through the IMOS portal\n\nQC data for 7 deployments are now available through OPeNDAP and the IMOS portal \r\n(StormBay20120608, Pilbara20120211, StormBay20120823, TwoRocks20120802, \r\nTwoRocks20120223, TwoRocks20120517, Kimberly20120727)	453	4
8	2012-12-13 00:00:00	no realtime  seaglider deployments\n\nQC data for 4 new deployments are available through OPeNDAP and the IMOS portal (Yamba20120904, SpencerGulf2012,TwoRocks20120824,StormBay20110805).	453	4
13	2012-12-18 00:00:00	Making files public is still a slow manual process and can delay public availability by weeks. It needs to be automated.\n\nNRS & Regional moorings: New and previously missing data from GBR made public. All SA moorings have been serviced and data are being processed. Many files still on staging.	478	4
111	2013-12-19 00:00:00	# data for 3 deployments have been received but have not been published on the portal(Kimberley20130925,Kimberley20130613,Pilbara20130619)\r\n\r\n\r\nData for two seaglider missions are currently published on the portal (Leeuwin20131017,Lizard20131024)\r\nRealtime data for two slocum glider missions have been published on the portal and glider have been recovered(TwoRocks20131017,Yamba20131120)\r\n	453	1
112	2013-12-20 00:00:00	No new data received this month. Data that will be delayed in publishing are: \r\n- all Argos emperor penguin data from Barbara Wienecke (AAD) - 42 deployments. \r\n- Snow petrel data in hexadecimal format (16 deployments in 2010/2011, 13 deployments in 2011/2012). \r\n- Shearwater tracking data for 2010/2011 (n = 33 deployments). \r\n- Delayed-mode satellite tracking data from seals and sea lions (three deployment campaigns, i.e. more than 30 deployments).	502	1
113	2013-12-23 00:00:00	New deployment received, ready to be put on Opendap	481	1
114	2013-12-23 00:00:00	Many new pigment and absorption data received in a Dropbox folder, ready to get processed.	482	1
115	2014-01-17 00:00:00	-SAG FV01 radials have been uploaded from the time period 2013-08-11 to 2013-11-27 and are available on THREDDS. FV01 hourly averaged products have been created accordingly and are available on THREDDS. 	455	1
117	2014-01-30 00:00:00	299 data files (51 deployments) on staging, including data up to Jan 2014.\r\nAlso 198 BGC data files on staging, but these are now being entered into the database at CSIRO and will be harvested from there.	494	1
118	2014-01-30 00:00:00	679 data files (26 deployments) on staging, including data up to Sep 2013.	495	1
119	2014-01-30 00:00:00	135 data files (12 deployments) on staging, including data up to June 2013.	496	1
120	2014-01-30 00:00:00	(No data waiting on staging.)	497	1
121	2014-01-30 00:00:00	68 data files (12 deployments) on staging, including data up to October 2013.	498	1
122	2014-01-30 00:00:00	Near-real-time data from the Yongala CO2 mooring is being uploaded to staging. Not yet converted to netCDF or published.	509	5
14	2012-12-18 00:00:00	We've been waiting for Bronte Tilbrook to approve the Carbon data in the new template since June.\n\nNRS Biogeochem: progress on moving the Suspended matter data into new aggregated Excel template (not public yet).	478	4
15	2012-12-18 00:00:00	Don't have Pulse-9 NRT data yet. Will work with Pete Jansen on that next year.\n\nWe now have Pulse 8 raw data on public. Meeting with Tom Trull & Peter Jansen about SOTS data availability. Working with Tom to get data from water sampling-instrument on Pulse.	485	4
46	2013-04-15 00:00:00	At the end of March the AATAMS community reported that 'embargoed' surgeries were available publicly through online searches. This was a flaw in our database security system.\n\nThe matter of 'surgery' data being available without the correct level of authorisation was dealt with on the day it was reported. The flawed version of the database was immediately withdrawn from public view. Requests to deleted cached versions of the webpages were lodged with Google and processed quickly. The incident highlighted a problem with regularly releasing updated versions of the AATAMS database without testing, and testing procedures within eMII were reviewed.	501	4
123	2014-01-30 00:00:00	Still only two deployments available via the Acoustic Data Viewer. The remaining data sets are on disk at eMII but need processing before they can be available via the ADV. This requires some project-officer time to set up the process and a computer with Matlab to do the number crunching (probably a few weeks' worth).	474	4
41	2013-04-15 00:00:00	CRVT and SBRD stations from TURQ site have been replaced by respectively GHED and LANC. Scripts and metadata records have been created/updated accordingly.\n\n-Historical data from the datafabric are still being migrated to the new Uni of Melbourne server.\r\n-Any new data stream (radial, vector and gridded files being QC'd or not) is not visible yet on the portal. Links on Geoserver and ncWMS layers towards Uni Melbourne storage need to be created.\r\n-A bug for Sea-sonde data (BONC and TURQ stations) in the position grid occurred from ~2012/12 to 2013/04/01. Historical data is being re-processed. ACORN operational scripts have been fixed and data from 2013/04/01 is back to correct.\n\n-WERA near real time radials data (CBG, SAG, ROT and COF stations) are processed every 6 hours to create gridded hourly averaged current data.\r\n-WERA delayed mode QC'd radials data (CBG, SAG and ROT stations) have been processed to create gridded hourly averaged current data up to:\r\nSAG->2013/01/20 05:30\r\nROT->2013/01/30 03:30\r\nCBG->2013/02/01 00:30	455	5
124	2014-01-31 00:00:00	Emperor penguin data: eMII has received data for 42 deployments (2010 to 2013), all are available on the new portal	502	1
125	2014-01-31 00:00:00	Snow petrel data: The AAD has given access to all raw data and metadata from snow petrel deployments. eMII now holds raw GLS data for 16 deployments for 2010/2011, and 13 deployments for 2011/2012. These raw data (hexadecimal format) are still getting processed by Simon Wotherspoon to extract geographic information. This data collection is not available on the portal.	502	1
126	2014-01-31 00:00:00	Shearwater GLS data: eMII holds processed data on 33 individuals tagged in 2010/2011. Mark Hindell said he will provide eMII will all the processed shearwater data that eMII doesn't have yet, but he has not mentioned how many deployments eMII is missing. eMII has not received any shearwater GLS data from Rob Harcourt's team yet.	502	1
127	2014-01-31 00:00:00	Satellite tagging near-real time data: eMII now harvests all CTD data transmitted by seals and sea lions in near real-time. This data collection consists of data for 177 animals, which recorded 82583 CTD profiles (1,296,422 temperature and salinity measurements).	502	1
128	2014-01-31 00:00:00	Satellite tagging delayed-mode data: this data collection is not available yet through the new portal. eMII holds data for 19 deployment campaigns, which makes a total of 264 deployments.	502	1
129	2014-01-31 00:00:00	 96 previously published SOFS files with bad/missing metadata have been removed from opendap. Marty has contacted Eric Shulz about getting these files updated, but so far no response.	485	4
130	2014-01-31 00:00:00	** ASFS: delayed-mode ADCP data from SOFS-2 and SOFS-4 (to Oct 2013), and raw data from SOFS-4 are on staging.\r\n\r\n** SOTS: New files for all deployments (6 to 10, to Oct 2013) of the Pulse mooring are on staging. Earlier versions of deployments 6, 7, 8 (up to July 2012) are public. Deployments 8, 9, 10 are published via OceanSITES.\r\n      ** Deep Microcat CTD data from the SAZ-15 mooring is on staging (in both IMOS and OceanSITES formats). Photos from the sediment trap are also on staging.\r\n\r\n** DA: 3 files on staging (new versions of data already public)	485	1
131	2014-02-03 00:00:00	New deployment received in late december, still on archive	481	1
132	2014-02-03 00:00:00	On going download of data	454	1
133	2014-02-03 00:00:00	No new campaign. Everything is already available on the portal	480	1
134	2014-02-03 00:00:00	Data download on going	459	1
135	2014-02-03 00:00:00	No new data	482	1
116	2014-01-30 00:00:00	Data for 5 delayed mode deployments have been received but not published on the portal (CoralSea20130618, TwoRocks20131017,Pilbara20130919,Pilbara20130709,Yamba20131009)\r\n\r\nGliders of 2 Realtime deployment have been recovered(Leeuwin20131017,Lizard20131024)\r\nCurrently not receiving realtime data.	453	1
136	2014-02-03 00:00:00	Raw data for one deployment of the FV-Rehua and one deployment of the RV Southern surveyor have been received.	479	1
\.


--
-- Data for Name: facility_summary_item; Type: TABLE DATA; Schema: report; Owner: postgres
--

COPY facility_summary_item (row_id, name) FROM stdin;
1	Progress on data
2	Progress on metadata
3	Meetings and outcomes
4	Issues and suggested solutions
5	New developments
\.


--
-- Name: facility_summary_item_row_id_seq; Type: SEQUENCE SET; Schema: report; Owner: postgres
--

SELECT pg_catalog.setval('facility_summary_item_row_id_seq', 5, true);


--
-- Name: facility_summary_row_id_seq; Type: SEQUENCE SET; Schema: report; Owner: postgres
--

SELECT pg_catalog.setval('facility_summary_row_id_seq', 1, false);


--
-- Name: facility_summary_row_id_seq1; Type: SEQUENCE SET; Schema: report; Owner: postgres
--

SELECT pg_catalog.setval('facility_summary_row_id_seq1', 136, true);


--
-- Data for Name: faimms_manual; Type: TABLE DATA; Schema: report; Owner: postgres
--

COPY faimms_manual (site_name, deployment_start, data_on_staging, data_on_opendap, data_on_portal, mest_creation, id) FROM stdin;
Heron_Island	2008-08-01 00:00:00	2010-08-10 00:00:00	2010-12-16 00:00:00	2011-01-13 00:00:00	2008-07-01 00:00:00	83
One_Tree_Island	2008-08-01 00:00:00	2010-08-10 00:00:00	2010-12-16 00:00:00	2011-01-13 00:00:00	2008-08-04 00:00:00	84
Davies_Reef	2008-08-01 00:00:00	2010-08-10 00:00:00	2010-12-16 00:00:00	2011-01-13 00:00:00	2008-08-04 00:00:00	85
Orpheus_Island	2009-09-01 00:00:00	2010-08-10 00:00:00	2010-12-16 00:00:00	2011-01-13 00:00:00	2009-09-01 00:00:00	86
Lizard_Island	2010-08-30 00:00:00	2010-10-14 00:00:00	2010-12-16 00:00:00	2011-01-13 00:00:00	2010-08-24 00:00:00	87
 	\N	\N	\N	\N	\N	88
Rib_Reef	2011-12-14 00:00:00	2012-04-01 00:00:00	2012-04-01 00:00:00	2012-04-01 00:00:00	2012-04-01 00:00:00	90
Myrmidon_Reef	1987-01-12 00:00:00	2012-06-01 00:00:00	2012-06-01 00:00:00	2012-06-01 00:00:00	2012-06-01 00:00:00	89
\.


--
-- Name: hibernate_sequence; Type: SEQUENCE SET; Schema: report; Owner: postgres
--

SELECT pg_catalog.setval('hibernate_sequence', 673, true);


--
-- Data for Name: nrs_aims_manual; Type: TABLE DATA; Schema: report; Owner: postgres
--

COPY nrs_aims_manual (platform_name, deployment_start, data_on_staging, data_on_opendap, data_on_portal, mest_creation, id) FROM stdin;
Darwin	\N	\N	\N	\N	\N	664
Yongala	\N	\N	\N	\N	\N	665
\.


--
-- Data for Name: soop_asf_manual; Type: TABLE DATA; Schema: report; Owner: postgres
--

COPY soop_asf_manual (vessel_name, platform_code, platform_uuid, deployment_start, data_on_staging, data_on_opendap, data_on_portal, mest_creation, id) FROM stdin;
R/V SOUTHERN SURVEYOR	VLHJ	dba353fd-f60b-43c8-84e5-c2534681f8f4	2008-04-01 00:00:00	2009-03-31 00:00:00	2009-04-01 00:00:00	2009-06-30 00:00:00	2009-05-01 00:00:00	80
RSV AURORA AUSTRALIS	VNAA	6ea52a64-cc94-46ba-b482-e0b7e2a8e11c	2010-01-24 00:00:00	2010-04-23 00:00:00	2010-05-01 00:00:00	2010-06-01 00:00:00	2009-03-05 15:46:00	81
RV TANGAROA	ZMFR	6111a607-5f7a-4930-b686-0f4165b5627b	2011-04-27 00:00:00	2011-10-01 00:00:00	2011-11-06 00:00:00	2011-11-10 00:00:00	2011-09-30 15:46:00	82
\.


--
-- Data for Name: soop_ba_manual; Type: TABLE DATA; Schema: report; Owner: postgres
--

COPY soop_ba_manual (deployment_id, vessel_name, data_on_staging, data_on_opendap, data_on_portal, mest_creation, id) FROM stdin;
Rehua_20100611-20100615	Rehua	2011-04-30 00:00:00	2011-05-03 00:00:00	2011-07-08 00:00:00	2011-10-11 00:00:00	85
Rehua_20100813-20100817	Rehua	2011-05-02 00:00:00	2011-05-06 00:00:00	2011-07-08 00:00:00	2011-10-11 00:00:00	86
Rehua_20090813-20090815	Rehua	2011-08-30 00:00:00	2011-09-01 00:00:00	2011-09-03 00:00:00	2011-10-11 00:00:00	87
Rehua_20110617-20110620	Rehua	2011-08-30 00:00:00	2011-09-01 00:00:00	2011-09-03 00:00:00	2011-10-11 00:00:00	88
Southern_Surveyor_20110609-20110614	Southern Surveyor	2011-09-05 00:00:00	2011-09-07 00:00:00	2011-09-09 00:00:00	2011-10-11 00:00:00	89
Janas_20090826-20090831	Janas	2011-05-01 00:00:00	2011-06-08 00:00:00	2011-07-08 00:00:00	2011-10-11 00:00:00	90
Janas_20090821-20090825	Janas	2011-08-26 00:00:00	2011-08-30 00:00:00	2011-09-01 00:00:00	2011-10-11 00:00:00	91
Janas_20100513-20100517	Janas	2011-07-13 00:00:00	2011-07-14 00:00:00	2011-07-15 00:00:00	2011-10-11 00:00:00	92
Janas_20110609-20110614	Janas	2011-07-13 00:00:00	2011-07-14 00:00:00	2011-07-15 00:00:00	2011-10-11 00:00:00	93
Antartic Chieftain	Antartic Chieftain	\N	\N	\N	\N	95
Saxon Progress	Saxon Progress	\N	\N	\N	\N	101
Tangaroa	Tangaroa	\N	\N	\N	\N	102
L'Astrolabe	L'Astrolabe	\N	\N	\N	\N	103
Southern_Champion_20100119-20100124	Southern Champion	2012-01-23 00:00:00	2012-01-24 00:00:00	2012-01-25 00:00:00	2012-02-07 00:00:00	104
Southern_Champion_20100227-20100303	Southern Champion	2012-01-23 00:00:00	2012-01-28 00:00:00	2012-01-29 00:00:00	2012-02-07 00:00:00	105
Southern_Champion_20110316-20110321	Southern Champion	2012-01-23 00:00:00	2012-01-24 00:00:00	2012-01-25 00:00:00	2012-02-07 00:00:00	106
Southern_Champion_20110510-20110512	Southern Champion	2012-01-23 00:00:00	2012-01-24 00:00:00	2012-01-24 00:00:00	2012-02-07 00:00:00	107
Austral_Leader_II_20110904-20110911	Austral Leader II	2012-01-24 00:00:00	2012-01-25 00:00:00	2012-01-26 00:00:00	2012-02-07 00:00:00	108
Austral_Leader_II_20110707-20110712	Austral Leader II	2012-01-24 00:00:00	2012-01-26 00:00:00	2012-01-27 00:00:00	2012-02-07 00:00:00	109
Janas_20110624-20110628	Janas	2011-10-07 00:00:00	2011-10-07 00:00:00	2011-10-08 00:00:00	2011-10-11 00:00:00	110
Nikko Maru	Nikko Maru	\N	\N	\N	\N	116
Southern_Champion_20110906-20110908	Southern Champion	2012-03-01 00:00:00	2012-03-02 00:00:00	2012-03-04 00:00:00	2012-07-26 00:00:00	111
Rehua_20110813-20110818	Rehua	2012-10-01 00:00:00	2012-10-31 00:00:00	2012-11-07 00:00:00	2013-01-21 00:00:00	446
Janas_20120419-20120426	Janas	2012-10-01 00:00:00	2012-10-31 00:00:00	2012-11-07 00:00:00	2013-01-21 00:00:00	445
Will_Watch_20110730-20110803	Will Watch	2012-11-16 00:00:00	2012-12-11 00:00:00	2013-06-01 00:00:00	2013-01-11 00:00:00	117
Will_Watch_20120211-20120218	Will Watch	2012-11-16 00:00:00	2012-12-11 00:00:00	2013-06-01 00:00:00	2013-01-11 00:00:00	467
Will_Watch_20111203-20111211	Will Watch	2012-11-16 00:00:00	2012-12-11 00:00:00	2013-06-01 00:00:00	2013-01-11 00:00:00	466
Will_Watch_20110921-20110925	Will Watch	2012-11-16 00:00:00	2012-12-11 00:00:00	2013-06-01 00:00:00	2013-01-11 00:00:00	465
Will_Watch_20120228-20120302	Will Watch	2012-11-16 00:00:00	2012-12-11 00:00:00	2013-06-01 00:00:00	2013-01-11 00:00:00	468
Will_Watch_20120419-20120422	Will Watch	2012-11-16 00:00:00	2012-12-11 00:00:00	2013-06-01 00:00:00	2013-01-11 00:00:00	469
Will_Watch_20120426-20120428	Will Watch	2012-11-16 00:00:00	2012-12-11 00:00:00	2013-06-01 00:00:00	2013-01-11 00:00:00	470
Aurora_Australis_20120416-20120418	Aurora Australis	2012-08-21 00:00:00	2012-09-11 00:00:00	2013-06-01 00:00:00	2013-01-11 00:00:00	112
Santo_Rocco_20120426-20120428	Santo Rocco	2012-08-21 00:00:00	2012-09-11 00:00:00	2013-06-01 00:00:00	2013-01-21 00:00:00	113
Santo_Rocco_20120501-20120503	Santo Rocco	2012-08-21 00:00:00	2012-09-11 00:00:00	2013-06-01 00:00:00	2013-01-22 00:00:00	114
Santo_Rocco_20120511-20120519	Santo Rocco	2012-08-21 00:00:00	2012-09-11 00:00:00	2013-06-01 00:00:00	2013-01-22 00:00:00	115
\.


--
-- Data for Name: soop_co2_manual; Type: TABLE DATA; Schema: report; Owner: postgres
--

COPY soop_co2_manual (deployment_id, deployment_start, data_on_staging, data_on_opendap, data_on_portal, mest_creation, id) FROM stdin;
AL1011_R0_northbound	2010-10-31 00:00:00	2011-03-21 00:00:00	2011-03-26 00:00:00	2011-03-29 00:00:00	2011-05-30 00:00:00	118
AL1011_R0_southbound	2010-10-21 00:00:00	2011-03-21 00:00:00	2011-03-26 00:00:00	2011-03-29 00:00:00	2011-05-30 00:00:00	119
SS2008_V01	2008-01-01 00:00:00	2009-05-02 00:00:00	2009-06-01 00:00:00	2009-06-30 00:00:00	2009-06-11 00:00:00	120
SS2009_V01	2009-02-03 00:00:00	2010-04-07 00:00:00	2010-04-09 00:00:00	2010-04-13 00:00:00	2010-04-11 00:00:00	121
SS2008_V02	2008-01-01 00:00:00	2009-05-02 00:00:00	2009-06-01 00:00:00	2009-06-30 00:00:00	2009-06-11 00:00:00	122
SS2008_V03	2008-01-01 00:00:00	2009-05-02 00:00:00	2009-06-01 00:00:00	2009-06-30 00:00:00	2009-06-11 00:00:00	123
SS2008_V04	2008-01-01 00:00:00	2009-05-02 00:00:00	2009-06-01 00:00:00	2009-06-30 00:00:00	2009-06-11 00:00:00	124
SS2009_V04	2009-09-22 00:00:00	2010-04-07 00:00:00	2010-04-09 00:00:00	2010-04-13 00:00:00	2010-04-11 00:00:00	125
SS2008_V05	2008-01-01 00:00:00	2009-05-02 00:00:00	2009-06-01 00:00:00	2009-06-30 00:00:00	2009-06-11 00:00:00	126
SS2008_V06	2008-01-01 00:00:00	2009-05-02 00:00:00	2009-06-01 00:00:00	2009-06-30 00:00:00	2009-06-11 00:00:00	127
SS2008_V07	2008-01-01 00:00:00	2009-05-02 00:00:00	2009-06-01 00:00:00	2009-06-30 00:00:00	2009-06-11 00:00:00	128
SS2008_V09	2008-01-01 00:00:00	2009-05-02 00:00:00	2009-06-01 00:00:00	2009-06-30 00:00:00	2009-06-11 00:00:00	129
SS2008_V10	2008-01-01 00:00:00	2009-05-02 00:00:00	2009-06-01 00:00:00	2009-06-30 00:00:00	2009-06-11 00:00:00	130
SS2009_V02leg1	2009-04-22 00:00:00	2010-11-15 00:00:00	2010-11-16 00:00:00	2010-11-20 00:00:00	2010-11-17 00:00:00	131
SS2009_V02leg2	2009-06-04 00:00:00	2010-11-15 00:00:00	2010-11-16 00:00:00	2010-11-20 00:00:00	2010-11-17 00:00:00	132
SS2009_V03	2009-07-03 00:00:00	2010-11-15 00:00:00	2010-11-16 00:00:00	2010-11-20 00:00:00	2010-11-17 00:00:00	133
SS2009_V05	2009-10-16 00:00:00	2010-11-15 00:00:00	2010-11-16 00:00:00	2010-11-20 00:00:00	2010-11-17 00:00:00	134
SS2010_V03	2010-04-14 00:00:00	2011-01-16 00:00:00	2011-02-25 00:00:00	2011-02-25 00:00:00	2011-02-25 00:00:00	135
SS2010_V04	2010-05-08 00:00:00	2011-01-16 00:00:00	2011-02-25 00:00:00	2011-02-25 00:00:00	2011-02-25 00:00:00	136
SS2008_T01	2008-01-01 00:00:00	2009-05-02 00:00:00	2009-06-01 00:00:00	2009-06-30 00:00:00	2009-06-11 00:00:00	137
SS2009_T01	2009-01-28 00:00:00	2010-04-07 00:00:00	2010-04-09 00:00:00	2010-04-13 00:00:00	2010-04-11 00:00:00	138
SS2008_T02	2008-01-01 00:00:00	2009-05-02 00:00:00	2009-06-01 00:00:00	2009-06-30 00:00:00	2009-06-11 00:00:00	139
SS2009_T02	2009-07-29 00:00:00	2010-04-07 00:00:00	2010-04-09 00:00:00	2010-04-13 00:00:00	2010-04-11 00:00:00	140
SS2008_T03	2008-01-01 00:00:00	2009-05-02 00:00:00	2009-06-01 00:00:00	2009-06-30 00:00:00	2009-06-11 00:00:00	141
SS2009_T03	2009-10-10 00:00:00	2010-04-07 00:00:00	2010-04-09 00:00:00	2010-04-13 00:00:00	2010-04-11 00:00:00	142
AL1011_R4_northbound	2011-03-01 00:00:00	2011-03-21 00:00:00	2011-03-26 00:00:00	2011-03-29 00:00:00	2011-05-30 00:00:00	143
AL1011_R4_southbound	2011-02-20 00:00:00	2011-03-21 00:00:00	2011-03-26 00:00:00	2011-03-29 00:00:00	2011-05-30 00:00:00	144
AL1112_R0_northbound	2011-12-06 00:00:00	2012-04-12 00:00:00	2012-07-11 00:00:00	2012-07-26 00:00:00	2012-07-26 00:00:00	145
AL1112_R0_southbound	2011-10-25 00:00:00	2012-04-12 00:00:00	2012-07-11 00:00:00	2012-07-26 00:00:00	2012-07-26 00:00:00	146
SS2011_V01	2011-04-16 00:00:00	2012-01-19 00:00:00	2012-01-31 00:00:00	2012-02-01 00:00:00	2012-02-07 00:00:00	147
SS2011_V02	2011-05-13 00:00:00	2012-01-19 00:00:00	2012-01-31 00:00:00	2012-02-01 00:00:00	2012-02-07 00:00:00	148
SS2010_T01	2010-03-29 00:00:00	2011-04-28 00:00:00	2011-04-29 00:00:00	2011-05-26 00:00:00	2011-05-27 00:00:00	149
SS2010_T02	2010-08-10 00:00:00	2011-04-28 00:00:00	2011-04-29 00:00:00	2011-05-26 00:00:00	2011-05-27 00:00:00	150
SS2010_V01	2010-01-22 00:00:00	2011-04-28 00:00:00	2011-04-29 00:00:00	2011-05-26 00:00:00	2011-05-27 00:00:00	151
SS2010_V02	2010-03-15 00:00:00	2011-04-28 00:00:00	2011-04-29 00:00:00	2011-05-26 00:00:00	2011-05-27 00:00:00	152
SS2010_V05	2010-07-06 00:00:00	2011-04-28 00:00:00	2011-04-29 00:00:00	2011-05-26 00:00:00	2011-05-27 00:00:00	153
SS2010_V06	2010-07-29 00:00:00	2011-04-28 00:00:00	2011-04-29 00:00:00	2011-05-26 00:00:00	2011-05-27 00:00:00	154
SS2010_V07	2010-09-07 00:00:00	2011-04-28 00:00:00	2011-04-29 00:00:00	2011-05-26 00:00:00	2011-05-27 00:00:00	155
SS2011_T02	2011-06-06 00:00:00	2012-01-19 00:00:00	2012-01-31 00:00:00	2012-02-01 00:00:00	2012-02-07 00:00:00	156
AA1011_VMS	2011-01-04 00:00:00	2012-01-19 00:00:00	2012-01-31 00:00:00	2012-02-01 00:00:00	2012-02-07 00:00:00	157
SS2010_V08	2010-09-22 00:00:00	2012-01-19 00:00:00	2012-01-31 00:00:00	2012-02-01 00:00:00	2012-02-07 00:00:00	158
SS2010_V09	2010-10-15 00:00:00	2012-01-19 00:00:00	2012-01-31 00:00:00	2012-02-01 00:00:00	2012-02-07 00:00:00	159
SS2011_C01	2011-04-06 00:00:00	2012-01-19 00:00:00	2012-01-31 00:00:00	2012-02-01 00:00:00	2012-02-07 00:00:00	160
SS2011_T01	2011-05-05 00:00:00	2012-01-19 00:00:00	2012-01-31 00:00:00	2012-02-01 00:00:00	2012-02-07 00:00:00	161
AL1112_R2_northbound	2012-01-23 00:00:00	2012-04-12 00:00:00	2012-07-11 00:00:00	2012-07-26 00:00:00	2012-07-26 00:00:00	162
SS2011_T03	2011-08-12 00:00:00	2012-06-04 00:00:00	2012-06-05 00:00:00	2012-07-26 00:00:00	2012-06-19 00:00:00	163
SS2011_T04	2011-11-10 00:00:00	2012-06-04 00:00:00	2012-06-05 00:00:00	2012-07-26 00:00:00	2012-06-19 00:00:00	164
SS2011_V03	2011-08-01 00:00:00	2012-06-04 00:00:00	2012-06-05 00:00:00	2012-07-26 00:00:00	2012-06-19 00:00:00	165
AA1112_V1	2011-10-23 00:00:00	2012-06-04 00:00:00	2012-06-05 00:00:00	2012-07-26 00:00:00	2012-09-12 00:00:00	166
AA1112_V3	2012-01-05 00:00:00	2012-06-04 00:00:00	2012-06-05 00:00:00	2012-07-26 00:00:00	2012-09-12 00:00:00	167
AA1112_V4	2012-02-15 00:00:00	2012-06-04 00:00:00	2012-06-05 00:00:00	2012-07-26 00:00:00	2012-09-12 00:00:00	168
AA1112_V5	2012-03-17 00:00:00	2012-06-04 00:00:00	2012-06-05 00:00:00	2012-07-26 00:00:00	2012-09-12 00:00:00	169
AA1112_V6	2012-04-16 00:00:00	2012-06-04 00:00:00	2012-06-05 00:00:00	2012-07-26 00:00:00	2012-09-12 00:00:00	170
AL1112_R2_southbound	2012-01-07 00:00:00	2012-04-12 00:00:00	2012-07-11 00:00:00	2012-07-26 00:00:00	2012-07-26 00:00:00	171
AL1112_R4_northbound	2012-03-02 00:00:00	2012-04-12 00:00:00	2012-07-11 00:00:00	2012-07-26 00:00:00	2012-07-26 00:00:00	172
AL1112_R4_southbound	2012-02-18 00:00:00	2012-04-12 00:00:00	2012-07-11 00:00:00	2012-07-26 00:00:00	2012-07-26 00:00:00	173
AL1213_R2_northbound	2013-01-26 00:00:00	2013-06-13 00:00:00	2013-06-28 00:00:00	2013-07-02 00:00:00	2013-06-28 00:00:00	531
AL1213_R4_southbound	2013-02-19 00:00:00	2013-06-13 00:00:00	2013-06-28 00:00:00	2013-07-02 00:00:00	2013-06-28 00:00:00	532
AL1213_R4_northbound	2013-02-26 00:00:00	2013-06-13 00:00:00	2013-06-28 00:00:00	2013-07-02 00:00:00	2013-06-28 00:00:00	533
SS2012_T01	2012-04-11 00:00:00	2013-06-06 00:00:00	2013-06-28 00:00:00	2013-07-02 00:00:00	2013-06-28 00:00:00	517
SS2012_V01	2012-04-20 00:00:00	2013-06-06 00:00:00	2013-06-28 00:00:00	2013-07-02 00:00:00	2013-06-28 00:00:00	518
SS2012_T02	2012-05-02 00:00:00	2013-06-06 00:00:00	2013-06-28 00:00:00	2013-07-02 00:00:00	2013-06-28 00:00:00	519
SS2012_V02	2012-05-13 00:00:00	2013-06-06 00:00:00	2013-06-28 00:00:00	2013-07-02 00:00:00	2013-06-28 00:00:00	520
SS2012_T03	2012-06-08 00:00:00	2013-06-06 00:00:00	2013-06-28 00:00:00	2013-07-02 00:00:00	2013-06-28 00:00:00	521
SS2012_V03	2012-07-11 00:00:00	2013-06-06 00:00:00	2013-06-28 00:00:00	2013-07-02 00:00:00	2013-06-28 00:00:00	522
AA1213_VMS	2012-09-17 00:00:00	2013-06-21 00:00:00	2013-06-28 00:00:00	2013-07-02 00:00:00	2013-06-28 00:00:00	523
AA1213_V1	2012-11-18 00:00:00	2013-06-21 00:00:00	2013-06-28 00:00:00	2013-07-02 00:00:00	2013-06-28 00:00:00	524
AA1213_V2	2012-12-17 00:00:00	2013-06-21 00:00:00	2013-06-28 00:00:00	2013-07-02 00:00:00	2013-06-28 00:00:00	525
AA1213_V3	2013-01-13 00:00:00	2013-06-21 00:00:00	2013-06-28 00:00:00	2013-07-02 00:00:00	2013-06-28 00:00:00	526
AA1213_V4	2013-02-27 00:00:00	2013-06-21 00:00:00	2013-06-28 00:00:00	2013-07-02 00:00:00	2013-06-28 00:00:00	527
AL1213_R0_southbound	2012-10-23 00:00:00	2013-06-13 00:00:00	2013-06-28 00:00:00	2013-07-02 00:00:00	2013-06-28 00:00:00	528
AL1213_R0_northbound	2012-11-18 00:00:00	2013-06-13 00:00:00	2013-06-28 00:00:00	2013-07-02 00:00:00	2013-06-28 00:00:00	529
AL1213_R2_southbound	2013-01-10 00:00:00	2013-06-13 00:00:00	2013-06-28 00:00:00	2013-07-02 00:00:00	2013-06-28 00:00:00	530
SS2011_V04	2011-08-25 00:00:00	2012-11-27 00:00:00	2012-12-11 00:00:00	2012-12-11 00:00:00	2013-01-11 00:00:00	472
SS2011_V07	2011-11-22 00:00:00	2012-11-27 00:00:00	2012-12-11 00:00:00	2012-12-11 00:00:00	2013-01-11 00:00:00	471
SS2011_V05	2011-09-22 00:00:00	2012-11-27 00:00:00	2012-12-11 00:00:00	2012-12-11 00:00:00	2013-01-11 00:00:00	473
\.


--
-- Data for Name: soop_cpr_manual; Type: TABLE DATA; Schema: report; Owner: postgres
--

COPY soop_cpr_manual (cruise_id, data_on_staging, data_on_opendap, data_on_portal, mest_creation, mest_uuid, cruise_name, id) FROM stdin;
BRSY20090627	2010-01-19 00:00:00	2010-01-21 00:00:00	2010-01-26 00:00:00	2009-08-30 00:00:00	6d914de0-515a-44df-a6b6-b885045a7049	East Coast Australia (BNE-SYD) - Jun09	174
BRSY20090725	2010-01-19 00:00:00	2010-01-21 00:00:00	2010-01-26 00:00:00	2009-08-30 00:00:00	cfb9e4bd-1c38-4e35-824b-7094e9d5f847	East Coast Australia (BNE-SYD) - Jul09	175
BRSY20090822	2010-01-19 00:00:00	2010-01-21 00:00:00	2010-01-26 00:00:00	2009-08-30 00:00:00	6c32f076-7d06-462f-9497-6c81efb711be	East Coast Australia (BNE-SYD) - Aug09	176
BRSY20091016	2010-07-16 00:00:00	2010-07-17 00:00:00	2011-07-15 00:00:00	\N	\N	East Coast Australia (BNE-SYD) - Oct09	177
BRSY20091212	2010-07-16 00:00:00	2010-07-17 00:00:00	2011-07-15 00:00:00	\N	\N	East Coast Australia (BNE-SYD) - Dect09	178
BRSY20100111	2010-07-16 00:00:00	2010-07-17 00:00:00	2011-07-15 00:00:00	\N	\N	East Coast Australia (BNE-SYD) - Jan10	179
BRSY20100320	2010-07-16 00:00:00	2010-07-17 00:00:00	2011-07-15 00:00:00	\N	\N	East Coast Australia (BNE-SYD) - Mar09	180
BRSY20100529	\N	\N	\N	\N	\N	East Coast Australia (BNE-SYD) - May10	181
BRSY20100810	2011-05-15 00:00:00	\N	2011-07-15 00:00:00	\N	\N	East Coast Australia (BNE-SYD) - Aug10	182
BRSY20101017	2011-05-15 00:00:00	\N	2011-07-15 00:00:00	\N	\N	East Coast Australia (BNE-SYD) - Oct10	183
BRSY20110305	2011-05-15 00:00:00	\N	2011-07-15 00:00:00	\N	\N	East Coast Australia (BNE-SYD) - Mar11	184
SYME20110517	\N	\N	\N	\N	\N	East Coast Australia (SYD-MEL) - May11	185
BRSY20110514	\N	\N	\N	\N	\N	East Coast Australia (BNE-SYD) - May11	186
BUNE20100813	2011-06-15 00:00:00	\N	2011-07-15 00:00:00	\N	\N	Burnie to Nelson - Aug 2010	187
FRAN20090103	2011-06-15 00:00:00	\N	2011-07-15 00:00:00	\N	\N	Fremantle to Antarctica - Jan 2009	188
FRBO20100407	2011-06-15 00:00:00	\N	2011-07-15 00:00:00	\N	\N	Fremantle to Broome - Apr 2010	189
HOAN20081125	2011-06-15 00:00:00	\N	2011-07-15 00:00:00	\N	\N	Hobart to Antarctica - Nov 2008	190
HOAN20091209	2011-06-15 00:00:00	\N	2011-07-15 00:00:00	\N	\N	Hobart to Antarctica - Dec 2009	191
HOSY20100917	2011-06-15 00:00:00	\N	2011-07-15 00:00:00	\N	\N	Hobart to Sydney - Sep 2010	192
MEAD20101023	2011-06-15 00:00:00	\N	2011-07-15 00:00:00	\N	\N	Melbourne to Adelaide - Oct 2010	193
MEAD20110103	2011-06-15 00:00:00	\N	2011-07-15 00:00:00	\N	\N	Melbourne to Adelaide - Jan 2011	194
MEAD20110311	2011-06-15 00:00:00	\N	2011-07-15 00:00:00	\N	\N	Melbourne to Adelaide - Mar 2011	195
SYHO20101104	2011-06-15 00:00:00	\N	2011-07-15 00:00:00	\N	\N	Sydney to Hobart - Nov 2010	196
MEAD20111007	\N	\N	\N	\N	\N	Melbourne to Adelaide - Oct 2011	197
SYME20091019	2010-07-16 00:00:00	2010-07-17 00:00:00	2011-07-15 00:00:00	\N	\N	East Coast Australia (SYD-MEL) - Oct09	201
SYME20090629	2010-01-19 00:00:00	2010-01-21 00:00:00	2010-01-26 00:00:00	2009-08-30 00:00:00	0d06ada4-42e1-4ef6-898f-9fc2a866054a	East Coast Australia (SYD-MEL) - Jun09	198
SYME20090824	2010-01-19 00:00:00	2010-07-17 00:00:00	2010-01-26 00:00:00	2009-08-30 00:00:00	6c32f076-7d06-462f-9497-6c81efb711be	East Coast Australia (SYD-MEL) - Aug09	199
SYME20090727	2010-01-19 00:00:00	2010-01-21 00:00:00	2010-01-26 00:00:00	2009-08-30 00:00:00	03fe4f23-9537-42df-9c7b-524071ba763b	East Coast Australia (SYD-MEL) - Jul09	200
SYME20091215	2010-07-16 00:00:00	2010-07-17 00:00:00	2011-07-15 00:00:00	\N	\N	East Coast Australia (SYD-MEL) - Dec09	202
SYME20100114	2010-07-16 00:00:00	2010-07-17 00:00:00	2011-07-15 00:00:00	\N	\N	East Coast Australia (SYD-MEL) - Jan10	203
SYME20100216	2011-06-15 00:00:00	\N	2011-07-15 00:00:00	\N	\N	East Coast Australia (SYD-MEL) - Feb10	204
SYME20100323	2010-07-16 00:00:00	2010-07-17 00:00:00	2011-07-15 00:00:00	\N	\N	East Coast Australia (SYD-MEL) - Mar09	205
SYME20100605	2011-06-15 00:00:00	\N	2011-07-15 00:00:00	\N	\N	East Coast Australia (SYD-MEL) - Jun10	206
SYME20101021	2011-06-15 00:00:00	\N	2011-07-15 00:00:00	\N	\N	East Coast Australia (SYD-MEL) - Oct10	207
SYME20101231	2011-06-15 00:00:00	\N	2011-07-15 00:00:00	\N	\N	East Coast Australia (SYD-MEL) - Dec10	208
SYME20110308	2011-06-15 00:00:00	\N	2011-07-15 00:00:00	\N	\N	East Coast Australia (SYD-MEL) - Mar11	209
SYME20110727	\N	\N	\N	\N	\N	East Coast Australia (SYD-MEL) - July11	210
BRSY200909	\N	\N	\N	\N	\N	East Coast Australia (BNE-SYD) - Sept09	211
BRSY200911	\N	\N	\N	\N	\N	East Coast Australia (BNE-SYD) - Nov09	212
BRSY201002	\N	\N	\N	\N	\N	East Coast Australia (BNE-SYD) - Feb10	213
BRSY200904	\N	\N	\N	\N	\N	East Coast Australia (BNE-SYD) - Apr09	214
BRSY201006	\N	\N	\N	\N	\N	East Coast Australia (BNE-SYD) - Jun10	215
SYME200909	\N	\N	\N	\N	\N	East Coast Australia (SYD-MEL) - Sept09	216
SYME200911	\N	\N	\N	\N	\N	East Coast Australia (SYD-MEL) - Nov09	217
SYME200904	\N	\N	\N	\N	\N	East Coast Australia (SYD-MEL) - Aprt09	218
SYME201005	\N	\N	\N	\N	\N	East Coast Australia (SYD-MEL) - May10	219
ANHO20090215	2011-06-15 00:00:00	2011-06-15 00:00:00	2011-07-15 00:00:00	\N	\N	Antarctica to Hobart - Feb 2009	220
\.


--
-- Data for Name: soop_frrf_manual; Type: TABLE DATA; Schema: report; Owner: postgres
--

COPY soop_frrf_manual (cruise_id, data_on_staging, data_on_opendap, data_on_portal, mest_creation, id) FROM stdin;
R42003s	2011-08-03 00:00:00	2011-08-30 00:00:00	2011-09-07 00:00:00	2011-11-11 00:00:00	221
R42004n	2011-08-03 00:00:00	2011-08-30 00:00:00	2011-09-07 00:00:00	2011-11-11 00:00:00	222
R42004s	2011-08-03 00:00:00	2011-08-30 00:00:00	2011-09-07 00:00:00	2011-11-11 00:00:00	223
R42006n	2011-08-03 00:00:00	2011-08-30 00:00:00	2011-09-07 00:00:00	2011-11-11 00:00:00	224
R42006s	2011-08-03 00:00:00	2011-08-30 00:00:00	2011-09-07 00:00:00	2011-11-11 00:00:00	225
R42007n	2011-08-03 00:00:00	2011-08-30 00:00:00	2011-09-07 00:00:00	2011-11-11 00:00:00	226
R42007s	2011-08-03 00:00:00	2011-08-30 00:00:00	2011-09-07 00:00:00	2011-11-11 00:00:00	227
R02003n	2011-08-03 00:00:00	2011-08-30 00:00:00	2011-09-07 00:00:00	2011-11-11 00:00:00	228
R02003s	2011-08-03 00:00:00	2011-08-30 00:00:00	2011-09-07 00:00:00	2011-11-11 00:00:00	229
R02004n	2011-08-03 00:00:00	2011-08-30 00:00:00	2011-09-07 00:00:00	2011-11-11 00:00:00	230
R02004s	2011-08-03 00:00:00	2011-08-30 00:00:00	2011-09-07 00:00:00	2011-11-11 00:00:00	231
R02005n	2011-08-03 00:00:00	2011-08-30 00:00:00	2011-09-07 00:00:00	2011-11-11 00:00:00	232
R02005s	2011-08-03 00:00:00	2011-08-30 00:00:00	2011-09-07 00:00:00	2011-11-11 00:00:00	233
R02006s	2011-08-03 00:00:00	2011-08-30 00:00:00	2011-09-07 00:00:00	2011-11-11 00:00:00	234
R02007n	2011-08-03 00:00:00	2011-08-30 00:00:00	2011-09-07 00:00:00	2011-11-11 00:00:00	235
R02007s	2011-08-03 00:00:00	2011-08-30 00:00:00	2011-09-07 00:00:00	2011-11-11 00:00:00	236
R02008n	2011-08-03 00:00:00	2011-08-30 00:00:00	2011-09-07 00:00:00	2011-11-11 00:00:00	237
R02008s	2011-08-03 00:00:00	2011-08-30 00:00:00	2011-09-07 00:00:00	2011-11-11 00:00:00	238
R02009n	2011-08-03 00:00:00	2011-08-30 00:00:00	2011-09-07 00:00:00	2011-11-11 00:00:00	239
R02009s	2011-08-03 00:00:00	2011-08-30 00:00:00	2011-09-07 00:00:00	2011-11-11 00:00:00	240
R22002n	2011-08-03 00:00:00	2011-08-30 00:00:00	2011-09-07 00:00:00	2011-11-11 00:00:00	241
R22002s	2011-08-03 00:00:00	2011-08-30 00:00:00	2011-09-07 00:00:00	2011-11-11 00:00:00	242
R22003n	2011-08-03 00:00:00	2011-08-30 00:00:00	2011-09-07 00:00:00	2011-11-11 00:00:00	243
R22003s	2011-08-03 00:00:00	2011-08-30 00:00:00	2011-09-07 00:00:00	2011-11-11 00:00:00	244
R22004n	2011-08-03 00:00:00	2011-08-30 00:00:00	2011-09-07 00:00:00	2011-11-11 00:00:00	245
R22004s	2011-08-03 00:00:00	2011-08-30 00:00:00	2011-09-07 00:00:00	2011-11-11 00:00:00	246
R22006n	2011-08-03 00:00:00	2011-08-30 00:00:00	2011-09-07 00:00:00	2011-11-11 00:00:00	247
R22006s	2011-08-03 00:00:00	2011-08-30 00:00:00	2011-09-07 00:00:00	2011-11-11 00:00:00	248
R22007n	2011-08-03 00:00:00	2011-08-30 00:00:00	2011-09-07 00:00:00	2011-11-11 00:00:00	249
R22007s	2011-08-03 00:00:00	2011-08-30 00:00:00	2011-09-07 00:00:00	2011-11-11 00:00:00	250
R42002n	2011-08-03 00:00:00	2011-08-30 00:00:00	2011-09-07 00:00:00	2011-11-11 00:00:00	251
R42002s	2011-08-03 00:00:00	2011-08-30 00:00:00	2011-09-07 00:00:00	2011-11-11 00:00:00	252
R42003n	2011-08-03 00:00:00	2011-08-30 00:00:00	2011-09-07 00:00:00	2011-11-11 00:00:00	253
\.


--
-- Data for Name: soop_sst_manual; Type: TABLE DATA; Schema: report; Owner: postgres
--

COPY soop_sst_manual (vessel_name, platform_code, platform_uuid, deployment_start, data_on_staging, data_on_opendap, data_on_portal, mest_creation, id) FROM stdin;
M/V SeaFlyte	VHW5167	e5bce384-c5f3-4c97-9fef-8859e500534e	2008-04-30 00:00:00	2009-05-01 00:00:00	2009-05-16 00:00:00	2009-06-30 00:00:00	2009-06-01 00:00:00	254
Spirit of Tasmania II	VNSZ	654bbf0c-a988-488b-be34-0c4b66e998b7	2008-12-18 00:00:00	2009-05-01 00:00:00	2009-05-16 00:00:00	2009-06-30 00:00:00	2009-06-01 00:00:00	255
Portland	VNAH	36456ffd-41f3-4d65-93cf-82c615769aa9	2009-06-20 00:00:00	2009-06-01 00:00:00	2009-07-01 00:00:00	2009-08-06 00:00:00	2009-08-01 00:00:00	256
Stadacona	C6FS9	5b5e8a67-2867-428d-9892-1634536c6b38	2009-08-10 00:00:00	2009-11-01 00:00:00	2009-11-02 00:00:00	2010-04-21 00:00:00	2009-11-11 00:00:00	257
Highland Chief	VROB	b8adea52-e798-48c5-9f0e-da3000c3a32b	2009-09-30 00:00:00	2009-10-01 00:00:00	2009-10-02 00:00:00	2009-11-21 00:00:00	2009-10-10 00:00:00	258
Iron Yandi	VNVR	bc05b68d-7b48-4587-80b3-56e84eb34b7c	2010-02-10 00:00:00	2010-03-04 00:00:00	2010-03-04 00:00:00	2010-04-21 00:00:00	2010-03-27 00:00:00	259
M/V Reef Voyager	\N	\N	\N	\N	\N	\N	\N	260
M/V ANL Yarunga	V2BJ5	\N	\N	\N	\N	\N	\N	261
L'Astrolabe	FHZI	3dbc4e0c-73c6-477d-9756-3e3e8001fc0b	2008-12-15 00:00:00	2009-04-01 00:00:00	2009-05-16 00:00:00	2009-06-30 00:00:00	2009-06-01 00:00:00	262
RSV L'Astrolabe	FHZI	3dbc4e0c-73c6-477d-9756-3e3e8001fc0b	2008-10-21 00:00:00	2010-01-20 00:00:00	2010-01-22 00:00:00	2010-06-26 00:00:00	2010-02-10 00:00:00	263
M/V Fantasea	VJQ7467	94a978f9-76a0-4df3-b35e-b6a378f0b7a3	2008-11-05 00:00:00	2009-05-01 00:00:00	2009-05-16 00:00:00	2009-06-30 00:00:00	2009-06-01 00:00:00	264
M/V Fantasea Wonder	VJQ7467	94a978f9-76a0-4df3-b35e-b6a378f0b7a3	2008-11-05 00:00:00	2009-05-01 00:00:00	2009-05-16 00:00:00	2009-06-30 00:00:00	2009-06-01 00:00:00	265
Pacific Sun	9HA2479	05d4f14b-9e35-4f74-9635-276e455f566f	2010-11-24 00:00:00	2010-11-26 00:00:00	2010-11-27 00:00:00	2010-12-01 00:00:00	2011-05-30 00:00:00	267
R/V LINNAEUS	VHW6005	9717a1c7-e50e-41b8-acb4-9ad8668a2823	2011-12-01 00:00:00	2012-05-01 00:00:00	2012-05-31 00:00:00	2012-06-01 00:00:00	2012-06-06 00:00:00	442
MV Xutra Bhum	HSB3402	09ad0906-07c9-4f9c-a6d8-42f57ce964e9	2012-07-03 00:00:00	2012-07-08 00:00:00	2012-09-27 00:00:00	\N	2013-01-10 00:00:00	443
MV Wana Bhum	HSB3403	0e4fc7ca-0181-49b0-b14d-414d2246cfad	2012-08-05 00:00:00	2012-08-12 00:00:00	2012-09-27 00:00:00	\N	2013-01-10 00:00:00	444
MV Pacific Celebes	VRZN9	"2165c738-6b65-45c8-902e-d34381f1aa3	2008-05-11 00:00:00	2011-12-20 00:00:00	2012-02-16 00:00:00	2012-02-16 00:00:00	2012-02-20 00:00:00	510
\.


--
-- Data for Name: soop_tmv_manual; Type: TABLE DATA; Schema: report; Owner: postgres
--

COPY soop_tmv_manual (bundle_id, data_on_staging, data_on_opendap, data_on_portal, vessel_name, start_date, end_date, id) FROM stdin;
Aug08-Jan09	2009-03-01 00:00:00	2009-05-01 00:00:00	2009-06-30 00:00:00	Spirit of Tasmania 1	2008-08-01	2009-01-15	268
Jan09-Jul09	2010-07-20 00:00:00	2010-07-22 00:00:00	2010-07-23 00:00:00	Spirit of Tasmania 1	2009-01-16	2009-07-31	269
Sep09-Jun10	2011-03-11 00:00:00	2011-03-11 00:00:00	2011-03-11 00:00:00	Spirit of Tasmania 1	2009-09-01	2010-06-30	270
Jul10-Jan11	2011-01-24 00:00:00	2012-09-15 00:00:00	2012-09-22 00:00:00	Spirit of Tasmania 1	2010-07-01	2011-01-11	271
Jan11-Jun11	2011-07-20 00:00:00	2012-09-15 00:00:00	2012-09-22 00:00:00	Spirit of Tasmania 1	2011-01-11	2011-07-11	272
Aug11-Dec11	2012-01-05 00:00:00	2013-06-25 00:00:00	2013-06-26 00:00:00	Spirit of Tasmania 1	2011-08-11	2011-12-19	273
Dec11-Feb12	2012-02-15 00:00:00	2013-06-25 00:00:00	2013-06-26 00:00:00	Spirit of Tasmania 1	2011-12-19	2012-02-01	274
\.


--
-- Data for Name: soop_trv_manual; Type: TABLE DATA; Schema: report; Owner: postgres
--

COPY soop_trv_manual (cruise_id, data_on_staging, data_on_opendap, data_on_portal, id) FROM stdin;
5008	2011-01-01 00:00:00	2011-01-13 00:00:00	2011-02-01 00:00:00	275
5012	2011-01-01 00:00:00	2011-01-13 00:00:00	2011-02-01 00:00:00	276
5114	2011-01-01 00:00:00	2011-01-13 00:00:00	2011-02-01 00:00:00	277
5117	2011-01-01 00:00:00	2011-01-13 00:00:00	2011-02-01 00:00:00	278
5118	2011-01-01 00:00:00	2011-01-13 00:00:00	2011-02-01 00:00:00	279
5119	2011-01-01 00:00:00	2011-01-13 00:00:00	2011-02-01 00:00:00	280
5120	2011-01-01 00:00:00	2011-01-13 00:00:00	2011-02-01 00:00:00	281
5124	2011-01-01 00:00:00	2011-01-13 00:00:00	2011-02-01 00:00:00	282
5126	2011-01-01 00:00:00	2011-01-13 00:00:00	2011-02-01 00:00:00	283
5128	2011-01-01 00:00:00	2011-01-13 00:00:00	2011-02-01 00:00:00	284
5129	2011-01-01 00:00:00	2011-01-13 00:00:00	2011-02-01 00:00:00	285
5130	2011-01-01 00:00:00	2011-01-13 00:00:00	2011-02-01 00:00:00	286
5131	2011-01-27 00:00:00	2011-02-07 00:00:00	2011-02-09 00:00:00	287
5133	2011-02-15 00:00:00	2011-02-26 00:00:00	2011-02-28 00:00:00	288
5135	2011-03-03 00:00:00	2011-03-14 00:00:00	2011-03-16 00:00:00	289
5305	2011-03-24 00:00:00	2011-04-04 00:00:00	2011-04-06 00:00:00	290
5306	2011-04-29 00:00:00	2011-05-10 00:00:00	2011-05-12 00:00:00	291
5309	2011-05-08 00:00:00	2011-05-19 00:00:00	2011-05-21 00:00:00	292
5310	2011-05-13 00:00:00	2011-05-24 00:00:00	2011-05-26 00:00:00	293
5313	2011-05-30 00:00:00	2011-06-10 00:00:00	2011-06-12 00:00:00	294
5316	2011-06-16 00:00:00	2011-06-27 00:00:00	2011-06-29 00:00:00	295
5353	2011-06-27 00:00:00	2011-07-08 00:00:00	2011-07-10 00:00:00	296
5354	2011-07-09 00:00:00	2011-07-20 00:00:00	2011-07-22 00:00:00	297
5355	2011-07-12 00:00:00	2011-07-23 00:00:00	2011-07-25 00:00:00	298
5164	2011-07-31 00:00:00	2011-08-11 00:00:00	2011-08-13 00:00:00	299
4729	2010-05-02 00:00:00	2010-05-14 00:00:00	2010-06-26 00:00:00	300
4730	2010-05-02 00:00:00	2010-05-14 00:00:00	2010-06-26 00:00:00	301
4732	2010-05-02 00:00:00	2010-05-14 00:00:00	2010-06-26 00:00:00	302
4733	2010-05-02 00:00:00	2010-05-14 00:00:00	2010-06-26 00:00:00	303
4897	2010-05-02 00:00:00	2010-05-14 00:00:00	2010-06-26 00:00:00	304
4898	2010-05-02 00:00:00	2010-05-14 00:00:00	2010-06-26 00:00:00	305
4900	2010-05-02 00:00:00	2010-05-14 00:00:00	2010-06-26 00:00:00	306
4901	2010-05-02 00:00:00	2010-05-14 00:00:00	2010-06-26 00:00:00	307
4907	2010-05-02 00:00:00	2010-05-14 00:00:00	2010-06-26 00:00:00	308
4914	2010-05-02 00:00:00	2010-05-14 00:00:00	2010-06-26 00:00:00	309
4915	2010-05-02 00:00:00	2010-05-14 00:00:00	2010-06-26 00:00:00	310
4916	2010-05-02 00:00:00	2010-05-14 00:00:00	2010-06-26 00:00:00	311
4917	2010-05-02 00:00:00	2010-05-14 00:00:00	2010-06-26 00:00:00	312
4918	2010-05-02 00:00:00	2010-05-14 00:00:00	2010-06-26 00:00:00	313
5095	2010-05-23 00:00:00	2011-01-13 00:00:00	2011-02-01 00:00:00	314
4921	2010-06-03 00:00:00	2011-01-13 00:00:00	2011-02-01 00:00:00	315
4922	2010-06-22 00:00:00	2011-01-13 00:00:00	2011-02-01 00:00:00	316
4923	2010-07-09 00:00:00	2011-01-13 00:00:00	2011-02-01 00:00:00	317
4924	2010-07-13 00:00:00	2011-01-13 00:00:00	2011-02-01 00:00:00	318
4925	2010-07-26 00:00:00	2011-01-13 00:00:00	2011-02-01 00:00:00	319
4926	2010-07-26 00:00:00	2011-01-13 00:00:00	2011-02-01 00:00:00	320
5218	2010-09-06 00:00:00	2011-01-13 00:00:00	2011-02-01 00:00:00	321
5138	2010-09-22 00:00:00	2011-01-13 00:00:00	2011-02-01 00:00:00	322
5167	2010-10-12 00:00:00	2011-01-13 00:00:00	2011-02-01 00:00:00	323
5140	2010-10-27 00:00:00	2011-01-13 00:00:00	2011-02-01 00:00:00	324
5141	2010-11-16 00:00:00	2011-01-13 00:00:00	2011-02-01 00:00:00	325
5143	2010-12-07 00:00:00	2011-01-13 00:00:00	2011-02-01 00:00:00	326
5144	2010-12-19 00:00:00	2011-01-13 00:00:00	2011-02-01 00:00:00	327
5145	2010-12-24 00:00:00	2011-01-13 00:00:00	2011-02-01 00:00:00	328
5146	2011-01-01 00:00:00	2011-01-13 00:00:00	2011-02-01 00:00:00	329
5147	2011-01-01 00:00:00	2011-01-13 00:00:00	2011-02-01 00:00:00	330
5148	2011-01-04 00:00:00	2011-01-15 00:00:00	2011-01-17 00:00:00	331
5150	2011-01-22 00:00:00	2011-02-02 00:00:00	2011-02-04 00:00:00	332
5151	2011-02-05 00:00:00	2011-02-16 00:00:00	2011-02-18 00:00:00	333
5152	2011-02-09 00:00:00	2011-02-20 00:00:00	2011-02-22 00:00:00	334
5154	2011-03-05 00:00:00	2011-03-16 00:00:00	2011-03-18 00:00:00	335
5171	2011-03-13 00:00:00	2011-03-24 00:00:00	2011-03-26 00:00:00	336
5172	2011-04-01 00:00:00	2011-04-12 00:00:00	2011-04-14 00:00:00	337
5155	2011-04-22 00:00:00	2011-05-03 00:00:00	2011-05-05 00:00:00	338
5156	2011-05-08 00:00:00	2011-05-19 00:00:00	2011-05-21 00:00:00	339
5157	2011-05-24 00:00:00	2011-06-04 00:00:00	2011-06-06 00:00:00	340
5159	2011-06-01 00:00:00	2011-06-12 00:00:00	2011-06-14 00:00:00	341
5160	2011-06-06 00:00:00	2011-06-17 00:00:00	2011-06-19 00:00:00	342
5161	2011-06-27 00:00:00	2011-07-08 00:00:00	2011-07-10 00:00:00	343
5163	2011-08-02 00:00:00	2011-08-13 00:00:00	2011-08-15 00:00:00	344
5139	2011-10-01 00:00:00	2011-10-18 00:00:00	2011-10-23 00:00:00	345
5293	2011-10-01 00:00:00	2011-10-18 00:00:00	2011-10-23 00:00:00	346
5421	2011-10-01 00:00:00	2011-10-18 00:00:00	2011-10-23 00:00:00	347
5423	2011-12-20 00:00:00	2012-01-17 00:00:00	2012-01-24 00:00:00	348
5486	2011-12-20 00:00:00	2012-01-17 00:00:00	2012-01-24 00:00:00	349
5424	2011-12-20 00:00:00	2012-01-17 00:00:00	2012-01-24 00:00:00	350
5425	2011-12-20 00:00:00	2012-01-17 00:00:00	2012-01-24 00:00:00	351
5426	2012-01-27 00:00:00	2012-02-17 00:00:00	2012-02-24 00:00:00	352
5428	2012-01-27 00:00:00	2012-02-17 00:00:00	2012-02-24 00:00:00	353
5429	2012-01-27 00:00:00	2012-02-17 00:00:00	2012-02-24 00:00:00	354
5530	2012-01-27 00:00:00	2012-02-17 00:00:00	2012-02-24 00:00:00	355
5357	2011-10-01 00:00:00	2011-10-18 00:00:00	2011-10-23 00:00:00	356
5358	2011-10-01 00:00:00	2011-10-18 00:00:00	2011-10-23 00:00:00	357
5443	2011-10-01 00:00:00	2011-10-18 00:00:00	2011-10-23 00:00:00	358
5444	2011-10-01 00:00:00	2011-10-18 00:00:00	2011-10-23 00:00:00	359
5446	2011-12-01 00:00:00	2012-01-17 00:00:00	2012-01-22 00:00:00	360
5448	2011-12-01 00:00:00	2012-01-17 00:00:00	2012-01-22 00:00:00	361
5449	2011-12-01 00:00:00	2012-01-17 00:00:00	2012-01-22 00:00:00	362
5450	2011-12-01 00:00:00	2012-01-17 00:00:00	2012-01-22 00:00:00	363
5451	2012-01-04 00:00:00	2012-01-17 00:00:00	2012-01-22 00:00:00	364
5452	2012-01-04 00:00:00	2012-01-17 00:00:00	2012-01-22 00:00:00	365
5454	2012-01-04 00:00:00	2012-01-17 00:00:00	2012-01-22 00:00:00	366
5455	2012-01-27 00:00:00	2012-02-17 00:00:00	2012-02-22 00:00:00	367
5457	2012-02-17 00:00:00	2012-06-13 00:00:00	2012-09-01 00:00:00	369
5458	2012-02-26 00:00:00	2012-06-13 00:00:00	2012-09-01 00:00:00	370
5459	2012-03-14 00:00:00	2012-06-13 00:00:00	2012-09-01 00:00:00	371
5431	2012-02-04 00:00:00	2012-06-13 00:00:00	2012-09-01 00:00:00	372
5432	2012-02-21 00:00:00	2012-06-13 00:00:00	2012-09-01 00:00:00	373
5433	2012-03-10 00:00:00	2012-06-13 00:00:00	2012-09-01 00:00:00	374
5434	2012-03-30 00:00:00	2012-06-13 00:00:00	2012-09-01 00:00:00	375
5435	2012-04-08 00:00:00	2012-06-13 00:00:00	2012-09-01 00:00:00	376
5436	2012-04-28 00:00:00	2012-06-13 00:00:00	2012-09-01 00:00:00	377
5437	2012-05-08 00:00:00	2012-06-13 00:00:00	2012-09-01 00:00:00	378
5438	2012-05-21 00:00:00	2012-06-13 00:00:00	2012-09-01 00:00:00	379
5439	2012-06-11 00:00:00	2012-06-13 00:00:00	2012-09-01 00:00:00	380
5456	2012-02-05 00:00:00	2012-06-13 00:00:00	2012-09-01 00:00:00	381
5460	2012-03-18 00:00:00	2012-06-13 00:00:00	2012-09-01 00:00:00	382
5462	2012-04-23 00:00:00	2012-06-13 00:00:00	2012-09-01 00:00:00	383
5463	2012-05-30 00:00:00	2012-06-13 00:00:00	2012-09-01 00:00:00	384
5550	2012-06-03 00:00:00	2012-06-13 00:00:00	2012-09-01 00:00:00	385
5585	2012-04-30 00:00:00	2012-06-13 00:00:00	2012-09-01 00:00:00	386
4725	2009-02-28 00:00:00	2013-06-01 00:00:00	2013-06-01 00:00:00	535
4714	2008-10-31 00:00:00	2013-06-01 00:00:00	2013-06-01 00:00:00	534
5596	2012-08-27 00:00:00	2012-08-27 00:00:00	2013-06-01 00:00:00	389
5598	2012-09-05 00:00:00	2012-09-05 00:00:00	2013-06-01 00:00:00	387
5597	2012-08-27 00:00:00	2012-08-27 00:00:00	2013-06-01 00:00:00	388
5637	2012-08-27 00:00:00	2012-08-27 00:00:00	2013-06-01 00:00:00	368
5442	2012-08-27 00:00:00	2012-08-27 00:00:00	2013-06-01 00:00:00	390
5638	2012-08-27 00:00:00	2012-08-27 00:00:00	2013-06-01 00:00:00	391
5599	2012-10-31 00:00:00	2013-06-01 00:00:00	2013-06-01 00:00:00	536
5639	2012-10-02 00:00:00	2013-06-01 00:00:00	2013-06-01 00:00:00	537
5640	2012-10-14 00:00:00	2013-06-01 00:00:00	2013-06-01 00:00:00	538
5642	2012-11-08 00:00:00	2013-06-01 00:00:00	2013-06-01 00:00:00	539
5643	2012-11-13 00:00:00	2013-06-01 00:00:00	2013-06-01 00:00:00	540
5644	2012-11-24 00:00:00	2013-06-01 00:00:00	2013-06-01 00:00:00	541
5645	2012-11-30 00:00:00	2013-06-01 00:00:00	2013-06-01 00:00:00	542
5646	2012-12-09 00:00:00	2013-06-01 00:00:00	2013-06-01 00:00:00	543
5647	2012-12-20 00:00:00	2013-06-01 00:00:00	2013-06-01 00:00:00	544
5650	2012-10-05 00:00:00	2013-06-01 00:00:00	2013-06-01 00:00:00	545
5668	2012-11-19 00:00:00	2013-06-01 00:00:00	2013-06-01 00:00:00	546
5670	2012-12-06 00:00:00	2013-06-01 00:00:00	2013-06-01 00:00:00	547
5671	2012-12-19 00:00:00	2013-06-01 00:00:00	2013-06-01 00:00:00	548
5673	2013-01-28 00:00:00	2013-06-01 00:00:00	2013-06-01 00:00:00	549
5674	2013-02-13 00:00:00	2013-06-01 00:00:00	2013-06-01 00:00:00	550
5692	2013-01-19 00:00:00	2013-06-01 00:00:00	2013-06-01 00:00:00	551
5695	2013-02-11 00:00:00	2013-06-01 00:00:00	2013-06-01 00:00:00	552
5696	2013-02-27 00:00:00	2013-06-01 00:00:00	2013-06-01 00:00:00	553
5698	2013-04-01 00:00:00	2013-06-01 00:00:00	2013-06-01 00:00:00	554
5701	2013-04-27 00:00:00	2013-06-01 00:00:00	2013-06-01 00:00:00	555
5702	2013-05-20 00:00:00	2013-06-01 00:00:00	2013-06-01 00:00:00	556
5703	2013-06-03 00:00:00	2013-06-05 00:00:00	2013-06-05 00:00:00	557
5734	2013-02-24 00:00:00	2013-06-01 00:00:00	2013-06-01 00:00:00	558
5735	2013-03-11 00:00:00	2013-06-01 00:00:00	2013-06-01 00:00:00	559
5736	2013-04-13 00:00:00	2013-06-01 00:00:00	2013-06-01 00:00:00	560
5737	2013-03-29 00:00:00	2013-06-01 00:00:00	2013-06-01 00:00:00	561
5751	2013-04-24 00:00:00	2013-06-01 00:00:00	2013-06-01 00:00:00	562
5754	2013-05-30 00:00:00	2013-06-01 00:00:00	2013-06-01 00:00:00	563
5761	2013-06-02 00:00:00	2013-06-05 00:00:00	2013-06-05 00:00:00	564
\.


--
-- Data for Name: soop_xbt; Type: TABLE DATA; Schema: report; Owner: postgres
--

COPY soop_xbt (p_id, line_name, year, number_of_profile, bundle_id) FROM stdin;
30	IX1	1983	51	CSIRO_1983to1988
31	IX1	1984	96	CSIRO_1983to1988
32	IX1	1985	128	CSIRO_1983to1988
34	IX1	1986	233	CSIRO_1983to1988
35	IX1	1987	358	CSIRO_1983to1988
36	IX1	1988	351	CSIRO_1983to1988
39	IX1	1990	459	CSIRO_1989to1993
40	IX1	1991	484	CSIRO_1989to1993
41	IX1	1992	552	CSIRO_1989to1993
42	IX1	1993	673	CSIRO_1989to1993
43	IX1	1994	624	CSIRO_1994to2006
44	IX1	1995	749	CSIRO_1994to2006
45	IX1	1996	567	CSIRO_1996
46	IX1	1997	582	CSIRO_1996
47	IX1	1998	309	BOM_1994to2006
48	IX1	1999	569	BOM_1994to2006
49	IX1	2000	714	BOM_1994to2006
50	IX1	2001	464	BOM_1994to2006
51	IX1	2002	638	BOM_1994to2006
52	IX1	2003	480	BOM_1994to2006
53	IX1	2004	443	BOM_1994to2006
54	IX1	2005	680	BOM_1994to2006
55	IX1	2006	604	ALL_2007to2009
56	IX1	2007	360	ALL_2007to2009
57	IX1	2008	709	ALL_2007to2009
58	IX1	2009	665	ALL_2007to2009
59	IX1	2010	842	BOM_2010
38	IX1	1989	335	CSIRO_1989to1993
61	IX12	1986	216	CSIRO_1983to1988
62	IX12	1987	691	CSIRO_1983to1988
63	IX12	1988	664	CSIRO_1983to1988
65	IX12	1990	501	CSIRO_1989to1993
66	IX12	1991	625	CSIRO_1989to1993
67	IX12	1992	665	CSIRO_1989to1993
68	IX12	1993	688	CSIRO_1989to1993
69	IX12	1994	499	CSIRO_1994to2006
70	IX12	1995	420	CSIRO_1994to2006
71	IX12	1996	609	CSIRO_1996
72	IX12	1997	695	BOM_1994to2006
73	IX12	1998	646	BOM_1994to2006
74	IX12	1999	261	BOM_1994to2006
75	IX12	2000	549	BOM_1994to2006
76	IX12	2001	616	BOM_1994to2006
77	IX12	2002	550	BOM_1994to2006
78	IX12	2003	660	BOM_1994to2006
79	IX12	2004	835	BOM_1994to2006
80	IX12	2005	854	BOM_1994to2006
81	IX12	2006	347	ALL_2007to2009
82	IX12	2007	699	ALL_2007to2009
83	IX12	2008	736	ALL_2007to2009
84	IX12	2009	670	ALL_2007to2009
85	IX12	2010	960	BOM_2010
64	IX12	1989	623	CSIRO_1989to1993
86	IX9	1986	119	CSIRO_1983to1988
87	IX9	1987	232	CSIRO_1983to1988
88	IX9	1988	250	CSIRO_1983to1988
89	IX9	1989	154	\N
90	IX9	1990	276	CSIRO_1989to1993
91	IX9	1991	382	CSIRO_1989to1993
92	IX9	1992	194	CSIRO_1989to1993
93	IX9	1993	240	CSIRO_1989to1993
94	IX9	1994	107	CSIRO_1994to2006
95	IX9	1995	51	CSIRO_1994to2006
96	IX9	1996	17	CSIRO_1996
97	IX22-PX11	1986	450	CSIRO_1983to1988
98	IX22-PX11	1987	907	CSIRO_1983to1988
99	IX22-PX11	1988	590	CSIRO_1983to1988
100	IX22-PX11	1990	540	CSIRO_1989to1993
101	IX22-PX11	1991	332	CSIRO_1989to1993
102	IX22-PX11	1992	333	CSIRO_1989to1993
103	IX22-PX11	1993	346	CSIRO_1989to1993
104	IX22-PX11	1994	240	CSIRO_1994to2006
105	IX22-PX11	1995	228	CSIRO_1994to2006
106	IX22-PX11	1996	244	CSIRO_1996
107	IX22-PX11	1997	358	CSIRO_1996
108	IX22-PX11	1998	222	BOM_1994to2006
109	IX22-PX11	1999	433	BOM_1994to2006
110	IX22-PX11	2000	437	BOM_1994to2006
111	IX22-PX11	2001	437	BOM_1994to2006
112	IX22-PX11	2002	409	BOM_1994to2006
113	IX22-PX11	2003	244	BOM_1994to2006
114	IX22-PX11	2004	148	BOM_1994to2006
115	IX22-PX11	2005	78	BOM_1994to2006
116	IX22-PX11	2006	207	ALL_2007to2009
117	IX22-PX11	2007	347	ALL_2007to2009
118	IX22-PX11	2008	451	ALL_2007to2009
119	IX22-PX11	2009	465	ALL_2007to2009
120	IX22-PX11	2010	352	BOM_2010
121	PX2	1983	31	CSIRO_1983to1988
122	PX2	1984	92	CSIRO_1983to1988
123	PX2	1985	107	CSIRO_1983to1988
124	PX2	1986	141	CSIRO_1983to1988
125	PX2	1987	210	CSIRO_1983to1988
126	PX2	1988	146	CSIRO_1983to1988
127	PX2	1989	260	CSIRO_1989to1993
128	PX2	1990	304	CSIRO_1989to1993
129	PX2	1991	296	CSIRO_1989to1993
130	PX2	1992	394	CSIRO_1989to1993
131	PX2	1993	341	CSIRO_1989to1993
132	PX2	1994	365	CSIRO_1994to2006
133	PX2	1995	196	CSIRO_1994to2006
134	PX2	1996	254	CSIRO_1996
135	PX2	1997	227	CSIRO_1996
136	PX2	1998	206	BOM_1994to2006
137	PX2	1999	216	BOM_1994to2006
138	PX2	2000	238	BOM_1994to2006
139	PX2	2001	177	BOM_1994to2006
140	PX2	2002	192	BOM_1994to2006
141	PX2	2003	116	BOM_1994to2006
142	PX2	2004	186	BOM_1994to2006
143	PX2	2005	207	BOM_1994to2006
144	PX2	2006	218	ALL_2007to2009
145	PX2	2007	110	ALL_2007to2009
146	PX2	2008	358	ALL_2007to2009
147	PX2	2009	404	ALL_2007to2009
148	PX2	2010	340	BOM_2010
149	PX3	1983	125	CSIRO_1983to1988
150	PX3	1984	270	CSIRO_1983to1988
151	PX3	1985	482	CSIRO_1983to1988
152	PX3	1986	313	CSIRO_1983to1988
153	PX3	1987	311	CSIRO_1983to1988
154	PX3	1988	237	CSIRO_1983to1988
155	PX3	1989	279	CSIRO_1989to1993
156	PX3	1990	267	CSIRO_1989to1993
157	PX3	1994	168	CSIRO_1994to2006
158	PX3	1995	191	CSIRO_1994to2006
159	PX3	1997	16	CSIRO_1996
160	PX3	1998	64	BOM_1994to2006
161	PX3	1999	1	BOM_1994to2006
163	PX05	1987	80	CSIRO_1983to1988
164	PX05	1988	408	CSIRO_1983to1988
165	PX05	1989	108	CSIRO_1989to1993
166	PX05	1990	260	CSIRO_1989to1993
167	PX05	1991	278	CSIRO_1989to1993
168	PX05	1992	184	CSIRO_1989to1993
169	PX05	1993	305	CSIRO_1989to1993
170	PX05	1996	267	CSIRO_1996
171	PX05	1997	217	CSIRO_1996
172	PX05	2009	117	SCRIPPS_2006to2009
173	PX05	2010	56	SCRIPPS_2006to2009
188	PX13	1986	312	CSIRO_others
189	PX13	1987	367	CSIRO_others
190	PX13	1988	313	CSIRO_others
191	PX13	1989	278	CSIRO_others
192	PX13	1990	245	CSIRO_others
193	PX13	1991	229	CSIRO_others
194	PX13	1992	240	CSIRO_others
195	PX13	1993	309	CSIRO_others
196	PX13	1994	184	CSIRO_others
197	PX13	1995	267	CSIRO_others
198	PX13	1996	258	CSIRO_others
199	PX13	2007	56	SCRIPPS_2006to2009
200	PX13	2008	62	SCRIPPS_2006to2009
201	PX13	2009	140	SCRIPPS_2006to2009
202	PX13	2010	64	SCRIPPS_2006to2009
203	PX34	1988	26	CSIRO_1983to1988
204	PX34	1989	9	CSIRO_1983to1988
205	PX34	1990	4	CSIRO_1983to1988
206	PX34	1991	307	CSIRO_highdensity
207	PX34	1992	318	CSIRO_highdensity
208	PX34	1993	250	CSIRO_highdensity
209	PX34	1994	187	CSIRO_1994to2006
210	PX34	1995	213	CSIRO_1994to2006
211	PX34	1996	324	CSIRO_1996
212	PX34	1997	270	CSIRO_1996
213	PX34	1998	289	CSIRO_1996
214	PX34	1999	219	CSIRO_1994to2006
215	PX34	2000	230	CSIRO_1994to2006
216	PX34	2001	302	CSIRO_1994to2006
217	PX34	2002	60	CSIRO_1994to2006
218	PX34	2003	152	CSIRO_1994to2006
219	PX34	2004	219	CSIRO_1994to2006
220	PX34	2005	225	CSIRO_1994to2006
221	PX34	2006	167	ALL_2007to2009
222	PX34	2007	240	ALL_2007to2009
223	PX34	2008	243	ALL_2007to2009
224	PX34	2009	216	ALL_2007to2009
225	PX34	2010	169	CSIRO_2010
228	PX57	1984	19	CSIRO_1983to1988
229	PX35	1991	173	CSIRO_highdensity
230	PX35	1992	101	CSIRO_highdensity
231	PX30-31	1991	289	CSIRO_1989to1993
232	PX30-31	1992	239	CSIRO_1989to1993
233	PX30-31	1993	299	CSIRO_1989to1993
234	PX30-31	1994	341	CSIRO_1994to2006
235	PX30-31	1995	287	CSIRO_1994to2006
236	PX30-31	1996	399	CSIRO_1996
237	PX30-31	1997	462	CSIRO_1996
238	PX30-31	1998	320	CSIRO_1994to2006
239	PX30-31	1999	437	CSIRO_1994to2006
240	PX30-31	2000	41	CSIRO_1994to2006
241	PX30-31	2001	343	CSIRO_1994to2006
242	PX30-31	2002	279	CSIRO_1994to2006
243	PX30-31	2003	302	CSIRO_1994to2006
244	PX30-31	2004	454	CSIRO_1994to2006
245	PX30-31	2005	497	CSIRO_1994to2006
246	PX30-31	2006	423	CSIRO_1994to2006
247	PX30-31	2007	457	ALL_2007to2009
248	PX30-31	2008	438	ALL_2007to2009
249	PX30-31	2009	411	ALL_2007to2009
250	PX30-31	2010	415	CSIRO_2010
252	PX55	1991	71	CSIRO_highdensity
253	IX8	1992	94	CSIRO_others
254	IX8	1993	31	CSIRO_others
258	IX28	1993	171	ANTARTICA_1994to2006
259	IX28	1994	459	ANTARTICA_1994to2006
260	IX28	1995	377	ANTARTICA_1994to2006
261	IX28	1996	364	ANTARTICA_1994to2006
262	IX28	1997	385	ANTARTICA_1994to2006
263	IX28	1998	450	ANTARTICA_1994to2006
264	IX28	1999	506	ANTARTICA_1994to2006
265	IX28	2000	625	ANTARTICA_1994to2006
266	IX28	2001	366	ANTARTICA_1994to2006
267	IX28	2002	455	ANTARTICA_1994to2006
268	IX28	2003	590	ANTARTICA_1994to2006
269	IX28	2004	477	ANTARTICA_1994to2006
272	IX28	2005	479	ALL_2007to2009
273	IX28	2006	339	ALL_2007to2009
274	IX28	2007	672	ALL_2007to2009
275	IX28	2008	677	ALL_2007to2009
276	IX28	2009	496	ALL_2007to2009
277	IX28	2010	451	ANTARTICA_2010
279	IX21	1994	92	SCRIPPS_2006to2009
280	IX21	1995	246	SCRIPPS_2006to2009
281	IX21	2004	300	SCRIPPS_2006to2009
282	IX21	2005	89	SCRIPPS_2006to2009
283	IX21	2006	249	SCRIPPS_2006to2009
284	IX21	2007	85	SCRIPPS_2006to2009
285	IX15	1994	154	SCRIPPS_2006to2009
286	IX15	1995	398	SCRIPPS_2006to2009
287	IX15	2004	642	SCRIPPS_2006to2009
288	IX15	2005	298	SCRIPPS_2006to2009
290	IX15-IX31	2006	791	SCRIPPS_2006to2009
291	IX15-IX31	2007	203	SCRIPPS_2006to2009
251	PX30-31	2011	289	CSIRO_2011
292	PX06	2006	73	SCRIPPS_2006to2009
293	PX06	2007	220	SCRIPPS_2006to2009
294	PX06	2008	210	SCRIPPS_2006to2009
295	PX06	2009	361	SCRIPPS_2006to2009
296	PX06	2010	69	SCRIPPS_2006to2009
297	IX21-IX06	2007	101	SCRIPPS_2006to2009
298	IX21-IX06	2008	831	SCRIPPS_2006to2009
299	IX21-IX06	2009	413	SCRIPPS_2006to2009
300	PX31	2009	82	SCRIPPS_2006to2009
301	PX31	2010	42	SCRIPPS_2006to2009
302	PX33	2008	63	ALL_2007to2009
303	PX33	2010	40	ANTARTICA_2010
304	PX17	1984	42	CSIRO_1983to1988
305	PX17	1985	264	CSIRO_1983to1988
306	PX17	1986	271	CSIRO_1983to1988
307	PX28	1984	57	CSIRO_1983to1988
321	Southern-Ocean	1978	16	CSIRO_others
322	Southern-Ocean	1979	17	CSIRO_others
323	Southern-Ocean	1983	7	CSIRO_others
324	Southern-Ocean	1985	14	CSIRO_others
325	Southern-Ocean	1986	69	CSIRO_others
326	Southern-Ocean	1988	4	CSIRO_others
327	Southern-Ocean	1989	22	CSIRO_others
328	Southern-Ocean	1990	37	CSIRO_others
329	Southern-Ocean	1991	46	CSIRO_1989to1993
330	Southern-Ocean	1992	21	CSIRO_1989to1993
331	Southern-Ocean	1993	18	ANTARTICA_1994to2006
332	Southern-Ocean	1998	122	ANTARTICA_1994to2006
333	Southern-Ocean	2008	58	ALL_2007to2009
341	Tasman-sea	1987	79	CSIRO_1983to1988
342	Tasman-sea	1988	22	CSIRO_1983to1988
343	Tasman-sea	1989	51	CSIRO_1989to1993
344	Tasman-sea	1990	12	CSIRO_1989to1993
345	Tasman-sea	1991	127	CSIRO_1989to1993
346	Tasman-sea	1992	71	CSIRO_1989to1993
347	Tasman-sea	1993	60	CSIRO_1989to1993
348	Tasman-sea	1994	25	CSIRO_1994to2006
349	Tasman-sea	1995	51	CSIRO_1994to2006
350	Tasman-sea	1996	52	CSIRO_1996
351	Tasman-sea	1997	153	BOM_1994to2006
352	Tasman-sea	1998	0	BOM_1994to2006
353	Tasman-sea	1999	210	BOM_1994to2006
354	Tasman-sea	2000	107	BOM_1994to2006
355	Tasman-sea	2001	189	BOM_1994to2006
356	Tasman-sea	2002	107	BOM_1994to2006
357	Tasman-sea	2003	12	BOM_1994to2006
358	Tasman-sea	2004	15	CSIRO_1994to2006
359	Tasman-sea	2005	123	CSIRO_1994to2006
360	Tasman-sea	2006	39	ALL_2007to2009
361	Tasman-sea	2008	6	ALL_2007to2009
363	Indian-Ocean	1996	35	CSIRO_1996
364	Indian-Ocean	1999	27	CSIRO_1994to2006
365	Indian-Ocean	2003	228	SCRIPPS_2006to2009
366	Indian-Ocean	2010	40	BOM_2010
60	IX1	2011	964	BOM_2011
226	PX34	2011	215	CSIRO_2011
278	IX28	2011	382	ANTARCTICA_2011
368	PX2	2011	419	BOM_2011
369	IX22-PX11	2011	327	BOM_2011
370	PX34	2012	106	CSIRO_2011
371	PX30-31	2012	187	CSIRO_2011
372	IX28	2012	228	ANTARCTICA_2011
\.


--
-- Data for Name: soop_xbt_line; Type: TABLE DATA; Schema: report; Owner: postgres
--

COPY soop_xbt_line (line_name, line_uuid, line_description) FROM stdin;
IX1	562edcbc-a5fa-4122-9167-60e8f6768e33	Fremantle-Sunda Strait
IX12	c1ec90fe-c89f-429c-a897-1c1583b22394	Fremantle-Red Sea
IX15	dd85beec-6ad4-4a3a-94bf-b5c39d17ecb5	Mauritius-Fremantle
IX15-IX31	40248cb4-09a5-41de-8790-504a1ed8e997	Mauritius-Melbourne
IX21	0443254b-fd39-468f-923f-1469f8caa9aa	Cape of Good Hope-Mauritius
IX21-IX06	b36e91b1-7cdf-491d-8685-1e91312b94c8	Cape of Good Hope-Mauritius-Malacca Strait
IX22	ebf306f3-e4df-4b2f-8df5-7e143b1bef29	Fremantle-Flores Sea
IX22-PX11	8be275bb-6951-45cd-9dd1-0c5adffd1ec6	Port Hedland-Japan
IX28	6159cfe9-fc3e-46d2-9fd8-fe407b24944e	Dumont d Urville-Hobart
IX8	b4f241f5-a5d8-4365-8b69-41dc48879c6c	Mauritius - Bombay
IX9	c7831608-9a2a-4eec-881d-4b632858a4bc	Fremantle-Persian Gulf
PX05	\N	Noumea - Auckland
PX06	e537589d-4ae1-4ab4-818b-31708491901e	Suva-Auckland
PX13	486d8463-36b3-47b1-a8d5-f73139cbdd16	New Zealand-California
PX17	7d3a2249-6f9a-4dc9-8bbb-354009f5b254	Tahiti-Panama
PX2	78aa4a11-f448-4a91-a24b-3fc13045a902	Across the Banda Sea
PX28	2a347914-9786-4cb0-872d-9d436735d53d	Tahiti-Auckland
PX3	0659b103-0843-4b18-8d16-f0fb59eae536	Coral Sea
PX30-31	e7520889-b939-4109-bf3f-5cfdcf30f870	Brisbane-Noumea-Suva
PX31	e7520889-b939-4109-bf3f-5cfdcf30f870	Noumea-Suva
PX33	cecf39f4-9cc2-4ff2-9134-f6adaf65b846	Hobart-Macquarie Island
PX34	937111f2-21e8-45e8-81d5-032a7c8b0c81	Sydney-Wellington
PX35	e0df3463-b68a-4a3f-873e-30bc562d4222	Melbourne-Dunedin
PX5	fb42c8b8-1006-4ec6-b347-1a36e80c1f5a	Brisbane-Japan
PX55	74861aae-7e5c-4ebd-9bc4-d10b0bf2c5c4	Melbourne-Wellington
PX57	9b462449-329b-4d0b-8af6-af1c35959869	Brisbane-Wellington
Southern-Ocean	\N	Southern Ocean
Tasman-sea	55b6a183-e942-424e-b3bd-476dfb284fc0	Tasman Sea
Indian-Ocean	\N	Indian Ocean
\.


--
-- Data for Name: soop_xbt_manual; Type: TABLE DATA; Schema: report; Owner: postgres
--

COPY soop_xbt_manual (bundle_id, data_on_staging, data_on_opendap, data_on_portal, id) FROM stdin;
CSIRO_1994to2006	2010-01-01 00:00:00	2010-01-09 00:00:00	2011-01-11 00:00:00	392
CSIRO_2010	2011-03-21 00:00:00	2011-08-10 00:00:00	2011-08-11 00:00:00	393
BOM_1994to2006	2010-01-01 00:00:00	2010-01-09 00:00:00	2011-01-12 00:00:00	394
ALL_2007to2009	2009-04-01 00:00:00	2009-05-16 00:00:00	2009-06-30 00:00:00	395
BOM_2010	2011-05-04 00:00:00	2011-08-10 00:00:00	2011-08-11 00:00:00	396
SCRIPPS_2006to2009	2010-04-01 00:00:00	2010-04-09 00:00:00	2011-01-13 00:00:00	397
ANTARTICA_1994to2006	2010-01-01 00:00:00	2010-01-09 00:00:00	2011-01-12 00:00:00	398
ANTARTICA_2010	2011-03-21 00:00:00	2011-08-10 00:00:00	2011-08-11 00:00:00	399
CSIRO_1983to1988	2011-05-01 00:00:00	2011-10-15 00:00:00	2011-10-25 00:00:00	400
CSIRO_1989to1993	2011-05-01 00:00:00	2011-10-15 00:00:00	2011-10-25 00:00:00	401
CSIRO_1996	2011-05-01 00:00:00	2011-10-15 00:00:00	2011-10-25 00:00:00	402
CSIRO_highdensity	2011-05-01 00:00:00	2011-10-15 00:00:00	2011-10-25 00:00:00	403
CSIRO_others	2011-05-01 00:00:00	2011-10-15 00:00:00	2011-10-25 00:00:00	404
ANTARCTICA_2011	2012-02-25 00:00:00	2012-10-10 00:00:00	2012-10-17 00:00:00	405
BOM_2011	2012-09-01 00:00:00	2012-10-10 00:00:00	2012-10-17 00:00:00	406
CSIRO_2011	2012-02-25 00:00:00	2012-10-10 00:00:00	2012-10-10 00:00:00	407
CSIRO_2012	2013-03-08 00:00:00	2013-05-22 00:00:00	2013-05-24 00:00:00	584
BOM_2012	2013-04-09 00:00:00	2013-05-22 00:00:00	2013-05-24 00:00:00	585
SCRIPPS_2010to2012	2013-03-20 00:00:00	2013-05-22 00:00:00	2013-05-24 00:00:00	586
\.


--
-- Data for Name: soop_xbt_realtime_manual; Type: TABLE DATA; Schema: report; Owner: postgres
--

COPY soop_xbt_realtime_manual (cruise_id, number_of_profile, line_name, callsign, vessel_name, start_date, end_date, id) FROM stdin;
26	60	PX34	V2BP4	Vega-Gotland	2010-07-11 00:00:00	2010-07-15 00:00:00	428
25	1	PX34	V2BP4	Vega-Gotland	2010-03-09 00:00:00	2010-03-10 00:00:00	427
34	53	PX34	A8JM5	ANL Benalla	2012-09-22 00:00:00	2012-09-26 00:00:00	441
45	58	PX34	A8JM5	ANL Benalla	2013-08-21 00:00:00	2013-08-26 00:00:00	672
44	38	PX30-31	3FLZ	Tropical Islander	2013-06-06 00:00:00	2013-06-09 00:00:00	671
4	1	PX34	A8SW3	Buxlink	2011-02-08 00:00:00	2011-02-10 00:00:00	409
28	51	PX34	DDPH	Merkur-Sky	2012-05-21 00:00:00	2012-05-25 00:00:00	430
42	49	PX34	A8JM5	ANL Benalla	2013-05-09 00:00:00	2013-05-13 00:00:00	669
41	54	PX34	A8JM5	ANL Benalla	2013-02-13 00:00:00	2013-02-18 00:00:00	668
32	79	IX28	FHZI	Astrolabe	2012-03-01 00:00:00	2012-03-07 00:00:00	439
37	60	PX34	A8JM5	ANL Benalla	2012-11-26 00:00:00	2012-11-30 00:00:00	664
1	2	PX34	A8SW3	Buxlink	2010-10-08 00:00:00	2010-10-11 00:00:00	408
2	56	PX34	A8SW3	Buxlink	2010-10-19 00:00:00	2010-10-23 00:00:00	413
3	55	PX34	A8SW3	Buxlink	2011-02-01 00:00:00	2011-02-05 00:00:00	414
5	53	PX34	A8SW3	Buxlink	2011-04-06 00:00:00	2011-04-10 00:00:00	415
6	51	PX34	A8SW3	Buxlink	2011-07-27 00:00:00	2011-07-31 00:00:00	412
29	71	PX30-31	VLHJ	Southern Surveyor	2012-05-03 00:00:00	2012-05-10 00:00:00	436
7	52	PX34	DDPH	Merkur-Sky	2012-01-31 00:00:00	2012-02-05 00:00:00	410
30	97	PX30-31	YJZC5	Pacific Gas	2012-03-08 00:00:00	2012-03-14 00:00:00	437
33	89	PX30-31	YJZC5	Pacific Gas	2012-09-07 00:00:00	2012-09-13 00:00:00	440
35	84	PX33	FHZI	Astrolabe	2012-10-23 00:00:00	2012-10-29 00:00:00	442
43	52	PX30-31	V2CN5	Sofrana Surville	2013-06-05 00:00:00	2013-06-08 00:00:00	670
27	55	PX30-31	V2CN5	Sofrana Surville	2011-12-14 00:00:00	2011-12-17 00:00:00	429
23	98	PX30-31	V2BF1	Florence	2011-02-15 00:00:00	2011-02-22 00:00:00	434
22	57	PX30-31	V2BF1	Florence	2010-10-28 00:00:00	2010-11-03 00:00:00	433
21	92	PX30-31	V2BF1	Florence	2010-07-17 00:00:00	2010-07-23 00:00:00	432
24	95	PX30-31	V2BF1	Florence	2011-04-25 00:00:00	2011-05-01 00:00:00	435
20	32	PX30-31	V2BF1	Florence	2010-05-11 00:00:00	2010-05-14 00:00:00	431
19	34	PX30-31	PBKZ	Schelde-Trader	2011-11-24 00:00:00	2011-11-27 00:00:00	426
18	57	PX34	P3JM9	Conti-Harmony	2011-10-05 00:00:00	2011-10-10 00:00:00	425
40	80	IX28	FHZI	Astrolabe	2013-01-02 00:00:00	2013-01-07 00:00:00	667
39	3	IX28	FHZI	Astrolabe	2012-12-14 00:00:00	2012-12-16 00:00:00	666
38	83	IX28	FHZI	Astrolabe	2012-12-01 00:00:00	2012-12-07 00:00:00	665
13	78	IX28	FHZI	Astrolabe	2011-03-01 00:00:00	2011-03-06 00:00:00	420
31	86	IX28	FHZI	Astrolabe	2012-02-19 00:00:00	2012-02-26 00:00:00	438
17	87	IX28	FHZI	Astrolabe	2011-12-29 00:00:00	2012-01-05 00:00:00	424
36	149	IX28	FHZI	Astrolabe	2012-11-17 00:00:00	2012-11-23 00:00:00	663
14	57	PX33	FHZI	Astrolabe	2011-10-22 00:00:00	2011-10-29 00:00:00	421
11	102	IX28	FHZI	Astrolabe	2010-12-20 00:00:00	2010-12-26 00:00:00	418
10	67	IX28	FHZI	Astrolabe	2010-12-09 00:00:00	2010-12-15 00:00:00	417
9	69	IX28	FHZI	Astrolabe	2010-10-31 00:00:00	2010-11-08 00:00:00	416
8	70	PX33	FHZI	Astrolabe	2010-10-21 00:00:00	2010-10-27 00:00:00	411
12	56	IX28	FHZI	Astrolabe	2011-02-21 00:00:00	2011-02-26 00:00:00	419
15	45	IX28	FHZI	Astrolabe	2011-12-06 00:00:00	2011-12-11 00:00:00	422
16	79	IX28	FHZI	Astrolabe	2011-12-16 00:00:00	2011-12-23 00:00:00	423
46	15	Tasman-sea	VRCF6	Santos Express	2013-08-19 00:00:00	2013-08-20 00:00:00	673
\.


--
-- Data for Name: srs_altimetry_manual; Type: TABLE DATA; Schema: report; Owner: postgres
--

COPY srs_altimetry_manual (deployment_start, deployment_end, site_code, data_on_staging, data_on_opendap, data_on_portal, pkid) FROM stdin;
2008-01-07	2008-07-03	SRSBAS	2011-06-14	2011-06-15	2011-06-15	7
2008-01-07	2009-02-02	SRSBAS	2011-06-14	2011-06-15	2011-06-15	8
2008-05-29	2009-02-02	SRSBAS	2011-06-14	2011-06-15	2011-06-15	9
2010-10-12	2011-04-04	SRSBAS	2011-06-14	2011-06-15	2011-06-15	10
2009-04-05	2009-11-17	SRSSTO	2011-06-14	2011-06-15	2011-06-15	1
2009-04-05	2010-05-04	SRSSTO	2011-06-14	2011-06-15	2011-06-15	2
2009-11-18	2010-05-04	SRSSTO	2011-06-14	2011-06-15	2011-06-15	3
2010-10-18	2011-03-28	SRSSTO	2011-06-14	2011-06-15	2011-06-15	4
2011-08-26	2012-08-19	SRSBAS	2012-09-18	2012-10-15	2012-10-15	11
2012-02-29	2012-08-02	SRSSTO	2012-09-18	2012-10-15	2012-10-15	6
2011-08-22	2012-08-02	SRSSTO	2012-09-18	2012-10-15	2012-10-15	5
\.


--
-- Data for Name: srs_bio_optical_db_manual; Type: TABLE DATA; Schema: report; Owner: postgres
--

COPY srs_bio_optical_db_manual (pkid, cruise_id, data_type, deployment_start, deployment_end, data_on_staging, data_on_opendap, data_on_portal, mest_creation) FROM stdin;
1	DT04	absorption	2004-03-30	2004-04-03	2012-06-20	2012-07-20	2012-07-20	2012-09-19
2	DT03	absorption	2003-09-29	2003-10-03	2012-06-20	2012-07-20	2012-07-20	2012-09-19
3	FR1097	absorption	1997-12-01	1997-12-07	2011-05-01	2011-05-01	2011-05-01	2012-09-19
4	FK04	absorption	2004-08-15	2004-08-17	2012-06-20	2012-07-20	2012-07-20	2012-09-19
5	FK03	absorption	2003-09-04	2003-09-12	2012-06-20	2012-07-20	2012-07-20	2012-09-19
7	SS012004	absorption	2004-01-20	2004-01-25	2011-08-01	2011-08-01	2011-08-01	2012-09-19
8	SS072003	absorption	2003-08-23	2003-08-28	2011-08-01	2011-08-01	2011-08-01	2012-09-19
9	FR1097	pigment	1997-12-01	1997-12-07	2011-05-01	2011-05-01	2011-05-01	2012-09-19
10	DT04	pigment	2004-03-30	2004-04-03	2012-06-20	2012-07-20	2012-07-20	2012-09-19
11	DT03	pigment	2003-09-29	2003-10-03	2012-06-20	2012-07-20	2012-07-20	2012-09-19
12	FK04	pigment	2004-08-15	2004-08-17	2012-06-20	2012-07-20	2012-07-20	2012-09-19
13	FK03	pigment	2003-09-04	2003-09-12	2012-06-20	2012-07-20	2012-07-20	2012-09-19
15	SS012004	pigment	2004-01-20	2004-01-25	2011-08-01	2011-08-01	2011-08-01	2012-09-19
16	SS072003	pigment	2003-08-23	2003-08-28	2011-08-01	2011-08-01	2011-08-01	2012-09-19
17	EX0108	pigment	2008-11-10	2008-12-04	2012-06-20	2012-07-20	2012-07-20	2012-09-19
18	TIP2000	pigment	2000-09-11	2000-10-01	2011-08-01	2011-08-01	2011-08-01	2012-09-19
19	2ROCKS	pigment	2002-02-26	2004-12-18	2011-12-10	2011-12-10	2011-12-10	2012-09-19
14	LB3172	pigment	2002-10-21	2002-10-29	2012-01-10	2012-01-10	2012-01-10	2012-09-19
6	LB3172	absorption	2002-10-21	2002-10-29	2012-01-10	2012-01-10	2012-01-10	2012-09-19
20	AA9706	absorption	1998-03-02	1998-03-26	2012-11-28	2012-12-07	2012-12-07	2012-12-07
587	MI042003	suspended_matter	2003-04-14	2003-04-17	2013-06-13	2013-06-14	2013-06-14	\N
588	R1012003	suspended_matter	2003-01-28	2005-05-01	2013-06-13	2013-06-14	2013-06-14	\N
589	LB4083	suspended_matter	2004-08-23	2005-08-28	2013-06-13	2013-06-14	2013-06-14	\N
590	MG052004	suspended_matter	2004-05-19	2004-05-24	2013-06-13	2013-06-14	2013-06-14	\N
591	P072004	suspended_matter	2004-07-26	2004-08-02	2013-06-13	2013-06-14	2013-06-14	\N
592	LB092005	suspended_matter	2005-09-16	2005-09-21	2013-06-13	2013-06-14	2013-06-14	\N
593	CF4296	suspended_matter	2006-10-27	2006-11-08	2013-06-13	2013-06-14	2013-06-14	\N
594	T112006	suspended_matter	2006-11-30	2006-12-05	2013-06-13	2013-06-14	2013-06-14	\N
595	JK092007	suspended_matter	2007-09-19	2007-09-26	2013-06-13	2013-06-14	2013-06-14	\N
596	JK042008	suspended_matter	2008-04-17	2008-04-23	2013-06-13	2013-06-14	2013-06-14	\N
597	KS022008	suspended_matter	2008-02-06	2008-02-09	2013-06-13	2013-06-14	2013-06-14	\N
598	SS201009	suspended_matter	2010-10-16	2010-10-30	2013-06-13	2013-06-14	2013-06-14	\N
599	ER051997	pigment	1997-05-14	1997-05-15	2013-06-13	2013-06-14	2013-06-14	\N
600	LP091997	pigment	1997-09-10	1997-09-14	2013-06-13	2013-06-14	2013-06-14	\N
601	LP111997	pigment	1997-11-04	1997-11-07	2013-06-13	2013-06-14	2013-06-14	\N
602	TO071997	pigment	1997-07-10	1997-07-13	2013-06-13	2013-06-14	2013-06-14	\N
603	TO081997	pigment	1997-08-22	1997-08-23	2013-06-13	2013-06-14	2013-06-14	\N
604	TO101997	pigment	1997-10-13	1997-10-17	2013-06-13	2013-06-14	2013-06-14	\N
605	TO111997	pigment	1997-11-17	1997-11-19	2013-06-13	2013-06-14	2013-06-14	\N
606	LP021998	pigment	1998-02-10	1998-02-11	2013-06-13	2013-06-14	2013-06-14	\N
607	LP041998	pigment	1998-04-25	1998-04-27	2013-06-13	2013-06-14	2013-06-14	\N
608	TO021998	pigment	1998-02-12	1998-02-16	2013-06-13	2013-06-14	2013-06-14	\N
609	TO061998	pigment	1998-06-07	1998-06-09	2013-06-13	2013-06-14	2013-06-14	\N
610	TO081998	pigment	1998-08-09	1998-08-12	2013-06-13	2013-06-14	2013-06-14	\N
611	TO111998	pigment	1998-11-03	1998-11-09	2013-06-13	2013-06-14	2013-06-14	\N
612	LB2108/99	pigment	1999-01-03	1999-02-28	2013-06-13	2013-06-14	2013-06-14	\N
613	NB121999	pigment	1999-12-01	1999-12-24	2013-06-13	2013-06-14	2013-06-14	\N
614	S081999	pigment	1999-08-16	1999-08-23	2013-06-13	2013-06-14	2013-06-14	\N
615	S101999	pigment	1999-10-15	1999-10-22	2013-06-13	2013-06-14	2013-06-14	\N
616	S121999	pigment	1999-12-07	1999-12-22	2013-06-13	2013-06-14	2013-06-14	\N
617	NB012000	pigment	2000-01-22	2000-02-01	2013-06-13	2013-06-14	2013-06-14	\N
618	NB032000	pigment	2000-03-02	2000-03-17	2013-06-13	2013-06-14	2013-06-14	\N
619	NB042000	pigment	2000-04-17	2000-04-21	2013-06-13	2013-06-14	2013-06-14	\N
620	NB052000	pigment	2000-05-24	2000-05-29	2013-06-13	2013-06-14	2013-06-14	\N
621	NB062000	pigment	2000-06-01	2000-06-09	2013-06-13	2013-06-14	2013-06-14	\N
622	NB072000	pigment	2000-07-10	2000-07-25	2013-06-13	2013-06-14	2013-06-14	\N
623	NB082000	pigment	2000-08-18	2000-09-01	2013-06-13	2013-06-14	2013-06-14	\N
624	NB102000	pigment	2000-09-29	2000-10-09	2013-06-13	2013-06-14	2013-06-14	\N
625	S022000	pigment	2000-02-11	2000-02-25	2013-06-13	2013-06-14	2013-06-14	\N
626	S092000	pigment	2000-09-04	2000-09-19	2013-06-13	2013-06-14	2013-06-14	\N
627	S122000	pigment	2000-12-07	2000-12-08	2013-06-13	2013-06-14	2013-06-14	\N
628	S012001	pigment	2001-01-04	2001-01-08	2013-06-13	2013-06-14	2013-06-14	\N
629	BEAGLE2003	pigment	2003-08-04	2004-01-20	2013-06-13	2013-06-14	2013-06-14	\N
630	MI042003	pigment	2003-04-14	2004-01-20	2013-06-13	2013-06-14	2013-06-14	\N
631	MV062003	pigment	2003-06-18	2004-01-20	2013-06-13	2013-06-14	2013-06-14	\N
632	R1012003	pigment	2003-01-28	2004-01-20	2013-06-13	2013-06-14	2013-06-14	\N
633	MG052004	pigment	2003-06-27	2004-05-24	2013-06-13	2013-06-14	2013-06-14	\N
634	P072004	pigment	2003-06-27	2004-08-02	2013-06-13	2013-06-14	2013-06-14	\N
635	SS072004	pigment	2003-06-27	2004-08-02	2013-06-13	2013-06-14	2013-06-14	\N
636	SS092004	pigment	2003-06-27	2004-09-27	2013-06-13	2013-06-14	2013-06-14	\N
637	LB092005	pigment	2003-06-27	2005-09-21	2013-06-13	2013-06-14	2013-06-14	\N
638	LB4083	pigment	2003-06-27	2005-08-28	2013-06-13	2013-06-14	2013-06-14	\N
639	RR022005	pigment	2003-06-27	2005-02-09	2013-06-13	2013-06-14	2013-06-14	\N
640	CF4296	pigment	2003-06-27	2006-11-08	2013-06-13	2013-06-14	2013-06-14	\N
641	SS032006	pigment	2003-10-20	2006-05-09	2013-06-13	2013-06-14	2013-06-14	\N
642	T112006	pigment	2003-10-20	2006-12-05	2013-06-13	2013-06-14	2013-06-14	\N
643	JK092007	pigment	2003-10-20	2007-09-26	2013-06-13	2013-06-14	2013-06-14	\N
644	JK042008	pigment	2003-10-20	2008-04-23	2013-06-13	2013-06-14	2013-06-14	\N
645	KS022008	pigment	2003-10-20	2008-04-30	2013-06-13	2013-06-14	2013-06-14	\N
646	SS201009	pigment	2003-10-20	2010-10-30	2013-06-13	2013-06-14	2013-06-14	\N
647	BEAGLE2003	absorption	2003-08-04	2004-01-20	2013-06-13	2013-06-14	2013-06-14	\N
648	MI042003	absorption	2003-04-14	2004-01-20	2013-06-13	2013-06-14	2013-06-14	\N
649	MV062003	absorption	2003-06-18	2004-01-20	2013-06-13	2013-06-14	2013-06-14	\N
650	R1012003	absorption	2003-01-28	2005-05-01	2013-06-13	2013-06-14	2013-06-14	\N
651	LB4083	absorption	2003-06-27	2005-08-28	2013-06-13	2013-06-14	2013-06-14	\N
652	MG052004	absorption	2003-06-27	2004-05-24	2013-06-13	2013-06-14	2013-06-14	\N
653	SS072004	absorption	2003-06-27	2004-08-02	2013-06-13	2013-06-14	2013-06-14	\N
654	LB092005	absorption	2003-06-27	2005-09-21	2013-06-13	2013-06-14	2013-06-14	\N
655	RR022005	absorption	2003-06-27	2005-09-21	2013-06-13	2013-06-14	2013-06-14	\N
656	CF4296	absorption	2003-06-27	2006-11-08	2013-06-13	2013-06-14	2013-06-14	\N
657	SS032006	absorption	2003-06-27	2006-11-08	2013-06-13	2013-06-14	2013-06-14	\N
658	T112006	absorption	2003-06-27	2006-12-05	2013-06-13	2013-06-14	2013-06-14	\N
659	JK092007	absorption	2003-06-27	2007-09-26	2013-06-13	2013-06-14	2013-06-14	\N
660	JK042008	absorption	2003-06-27	2008-04-23	2013-06-13	2013-06-14	2013-06-14	\N
661	KS022008	absorption	2003-06-27	2008-02-09	2013-06-13	2013-06-14	2013-06-14	\N
662	SS201009	absorption	2003-06-27	2010-10-30	2013-06-13	2013-06-14	2013-06-14	\N
\.


--
-- Data for Name: srs_gridded_products_manual; Type: TABLE DATA; Schema: report; Owner: postgres
--

COPY srs_gridded_products_manual (product_name, deployment_start, deployment_end, data_on_staging, data_on_opendap, data_on_portal, mest_creation, pkid) FROM stdin;
MODIS Aqua OC3 Chlorophyll-a	2011-08-20	\N	\N	2012-06-16	2012-07-30	2012-07-30	373
SST L3C	2009-02-26	\N	\N	2011-02-01	2011-05-16	\N	374
SST L3P - 14 days mosaic	2001-01-01	\N	\N	2009-06-01	2010-07-01	2010-06-30	375
\.


--
-- Data for Name: totals; Type: TABLE DATA; Schema: report; Owner: postgres
--

COPY totals (facility, subfacility, type, no_projects, no_platforms, no_instruments, no_deployments, no_data, no_data2, no_data3, no_data4, temporal_range, lat_range, lon_range, depth_range) FROM stdin;
AATAMS	Biologging	SMRU CTD tag	11	4	\N	135	72203	\N	\N	\N	26/03/2007 - 10/08/2012	-76.5 - -32.1	-180.0 - 180.0	\N
AATAMS	Biologging	SMRU SRDL tag	1	1	\N	19	7569	\N	\N	\N	11/03/2011 - 01/12/2011	-69.6 - -66.1	70.0 - 82.4	\N
AATAMS	Biologging	TOTAL	12	5	\N	154	79772	\N	\N	\N	26/03/2007 - 10/08/2012	-76.5 - -32.1	-180.0 - 180.0	\N
ABOS	ASFS & SOTS	Aggregated files	\N	5	6	11	83	1	\N	\N	27/09/2009 - 05/10/2012	\N	\N	\N
ABOS	ASFS & SOTS	Daily files	\N	1	3	20	1710	1065	\N	\N	17/03/2010 - 27/10/2013	\N	\N	\N
ABOS	ASFS & SOTS	TOTAL	\N	5	6	31	1793	1066	\N	\N	27/09/2009 - 27/10/2013	\N	\N	\N
ACORN	\N	TOTAL	6	12	\N	\N	4	4	\N	\N	29/09/2007 - 12/03/2012	\N	\N	\N
ANFOG	\N	TOTAL	\N	22	\N	97	\N	\N	\N	\N	16/07/2008 - 17/03/2013	-46.7 - -14.0	111.6 - 156.0	51 - 1025
ANMN	AM	\N	2	\N	1	8	8	0	\N	\N	20/04/2011 - 31/01/2014	-42.6 - -35.8	136.4 - 148.2	\N
ANMN	NRS	\N	8	\N	4	178	305	320	\N	\N	11/02/2008 - 12/07/2013	-42.6 - -12.3	113.9 - 153.6	-26141312.0 - 191.0
ANMN	NRS - Real-Time	TOTAL	2	\N	105	24	41	\N	\N	\N	09/02/2010 - 30/05/2013	\N	\N	0.0 - 24.5
ANMN	NRS, RMA, and AM	TOTAL	52	\N	6	890	1996	3310	\N	\N	10/09/2007 - 31/01/2014	-42.6 - -9.8	113.9 - 153.6	-26141312.0 - 1796.1
ANMN	NSW	\N	8	\N	3	265	846	1864	\N	\N	25/06/2008 - 25/06/2013	-36.2 - -30.3	150.2 - 153.4	-298.7 - 144.5
ANMN	PA	TOTAL	8	\N	110	24	102	8	\N	\N	26/02/2008 - 06/11/2012	\N	\N	\N
ANMN	QLD	\N	20	\N	5	312	461	751	\N	\N	10/09/2007 - 31/07/2013	-23.5 - -9.8	115.9 - 152.2	-1278.5 - 620.4
ANMN	SA	\N	8	\N	2	52	52	51	\N	\N	20/10/2008 - 08/11/2012	-36.5 - -34.9	135.0 - 136.9	-10.2 - 600.8
ANMN	WA	\N	8	\N	4	75	324	324	\N	\N	07/07/2009 - 12/07/2013	-32.0 - -31.1	114.9 - 115.2	-150.1 - 1796.1
Argo	\N	TOTAL	11	1709	104	782	47	\N	\N	\N	21/10/1999 - 24/01/2014	-75.1 - 48.4	-180.0 - 180.0	\N
AUV	\N	TOTAL	13	22	325	448	2728317	1064.9	\N	\N	28/09/2007 - 13/06/2013	-43.6 - -14.0	113.3 - 153.6	0.4 - 225.0
FAIMMS	\N	TOTAL	7	37	262	13	171	\N	\N	\N	01/11/1987 - 12/06/2013	\N	\N	-0.3 - 22.8
SOOP	ASF (near real-time & delayed-mode)	\N	\N	3	\N	3	4786	\N	\N	\N	27/01/2008 - 02/12/2013	-69.1 - 1.3	-180.0 - 180.0	0.0 - 0.0
SOOP	BA (delayed-mode)	\N	\N	13	\N	36	35	\N	\N	\N	13/08/2009 - 19/06/2013	-54.5 - -20.2	44.5 - 172.9	5.0 - 1195.0
SOOP	CO2 (delayed-mode)	\N	\N	3	\N	78	78	\N	\N	\N	11/01/2008 - 15/03/2013	-68.6 - 0.0	-180.0 - 180.0	0.0 - 0.0
SOOP	CPR-AUS (delayed-mode)	\N	\N	8	\N	73	13121	\N	\N	\N	25/11/2007 - 05/01/2014	-65.3 - -15.1	89.6 - 174.3	\N
SOOP	CPR-SO (delayed-mode)	\N	\N	11	\N	513	38483	\N	\N	\N	12/01/1991 - 27/03/2010	\N	\N	\N
SOOP	SST (near real-time & delayed-mode)	\N	\N	17	\N	17	11465	\N	\N	\N	30/01/2008 - 01/01/2014	-74.4 - 49.5	-99.3 - 180.0	0.0 - 0.0
SOOP	TMV (delayed-mode)	\N	\N	1	\N	7	543	\N	\N	\N	28/08/2008 - 01/02/2012	-41.2 - -37.9	144.6 - 146.4	0.0 - 0.0
SOOP	TRV (delayed-mode)	\N	\N	2	\N	169	662	\N	\N	\N	30/09/2008 - 11/11/2013	\N	\N	1.9 - 1.9
SOOP	XBT (near real-time & delayed-mode)	\N	\N	30	\N	285	2817	\N	\N	\N	27/12/1978 - 18/02/2013	-77.6 - 33.6	-180.0 - 180.0	0.0 - 2200.1
SOOP	\N	TOTAL	\N	83	\N	1181	71990	\N	\N	\N	27/12/1978 - 05/01/2014	-77.6 - 49.5	-180.0 - 180.0	0.0 - 2200.1
SRS	SRS - Altimetry	\N	\N	2	6	46	\N	\N	\N	\N	17/12/2007 - 05/03/2013	\N	\N	14.0 - 96.0
SRS	SRS - BioOptical database	\N	\N	3	0	96	\N	\N	\N	\N	14/05/1997 - 30/10/2010	\N	\N	\N
SRS	SRS - Gridded Products	\N	\N	2	0	3	\N	\N	\N	\N	01/01/2001 - NA	\N	\N	\N
SRS	SRS - Ocean Colour	\N	\N	1	0	15	\N	\N	\N	\N	29/07/2011 - 27/06/2013	\N	\N	\N
SRS	\N	TOTAL	\N	8	6	160	\N	\N	\N	\N	14/05/1997 - 27/06/2013	\N	\N	14.0 - 96.0
\.


--
-- Name: aatams_sattag_manual_pkey; Type: CONSTRAINT; Schema: report; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY aatams_sattag_manual
    ADD CONSTRAINT aatams_sattag_manual_pkey PRIMARY KEY (device_id);


--
-- Name: aatams_sattag_mdb_workflow_manual_pkey; Type: CONSTRAINT; Schema: report; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY aatams_sattag_mdb_workflow_manual
    ADD CONSTRAINT aatams_sattag_mdb_workflow_manual_pkey PRIMARY KEY (device_id);


--
-- Name: acorn_manual_pkey; Type: CONSTRAINT; Schema: report; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY acorn_manual
    ADD CONSTRAINT acorn_manual_pkey PRIMARY KEY (unique_id);


--
-- Name: anfog_manual_pkey; Type: CONSTRAINT; Schema: report; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY anfog_manual
    ADD CONSTRAINT anfog_manual_pkey PRIMARY KEY (anfog_id);


--
-- Name: anmn_datacategories_manual_pkey; Type: CONSTRAINT; Schema: report; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY anmn_datacategories_manual
    ADD CONSTRAINT anmn_datacategories_manual_pkey PRIMARY KEY (pkid);


--
-- Name: anmn_manual_pkey; Type: CONSTRAINT; Schema: report; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY anmn_manual
    ADD CONSTRAINT anmn_manual_pkey PRIMARY KEY (pkid);


--
-- Name: anmn_platforms_manual_pkey; Type: CONSTRAINT; Schema: report; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY anmn_platforms_manual
    ADD CONSTRAINT anmn_platforms_manual_pkey PRIMARY KEY (pkid);


--
-- Name: anmn_status_manual_pkey; Type: CONSTRAINT; Schema: report; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY anmn_status_manual
    ADD CONSTRAINT anmn_status_manual_pkey PRIMARY KEY (pkid);


--
-- Name: auv_manual_pkey; Type: CONSTRAINT; Schema: report; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY auv_manual
    ADD CONSTRAINT auv_manual_pkey PRIMARY KEY (campaign_code);


--
-- Name: facility_summary_item_pkey; Type: CONSTRAINT; Schema: report; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY facility_summary_item
    ADD CONSTRAINT facility_summary_item_pkey PRIMARY KEY (row_id);


--
-- Name: facility_summary_pkey; Type: CONSTRAINT; Schema: report; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY facility_summary
    ADD CONSTRAINT facility_summary_pkey PRIMARY KEY (row_id);


--
-- Name: faimms_manual_pkey; Type: CONSTRAINT; Schema: report; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY faimms_manual
    ADD CONSTRAINT faimms_manual_pkey PRIMARY KEY (site_name);


--
-- Name: nrs_aims_manual_pkey; Type: CONSTRAINT; Schema: report; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY nrs_aims_manual
    ADD CONSTRAINT nrs_aims_manual_pkey PRIMARY KEY (platform_name);


--
-- Name: pkid; Type: CONSTRAINT; Schema: report; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY srs_bio_optical_db_manual
    ADD CONSTRAINT pkid PRIMARY KEY (pkid);


--
-- Name: soop_asf_manual_pkey; Type: CONSTRAINT; Schema: report; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY soop_asf_manual
    ADD CONSTRAINT soop_asf_manual_pkey PRIMARY KEY (id);


--
-- Name: soop_ba_manual_pkey; Type: CONSTRAINT; Schema: report; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY soop_ba_manual
    ADD CONSTRAINT soop_ba_manual_pkey PRIMARY KEY (deployment_id);


--
-- Name: soop_co2_manual_pkey; Type: CONSTRAINT; Schema: report; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY soop_co2_manual
    ADD CONSTRAINT soop_co2_manual_pkey PRIMARY KEY (deployment_id);


--
-- Name: soop_cpr_manual_pkey; Type: CONSTRAINT; Schema: report; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY soop_cpr_manual
    ADD CONSTRAINT soop_cpr_manual_pkey PRIMARY KEY (cruise_id);


--
-- Name: soop_frrf_manual_pkey; Type: CONSTRAINT; Schema: report; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY soop_frrf_manual
    ADD CONSTRAINT soop_frrf_manual_pkey PRIMARY KEY (cruise_id);


--
-- Name: soop_sst_vessel_pkey; Type: CONSTRAINT; Schema: report; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY soop_sst_manual
    ADD CONSTRAINT soop_sst_vessel_pkey PRIMARY KEY (vessel_name);


--
-- Name: soop_tmv_manual_pkey; Type: CONSTRAINT; Schema: report; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY soop_tmv_manual
    ADD CONSTRAINT soop_tmv_manual_pkey PRIMARY KEY (bundle_id);


--
-- Name: soop_trv_manual_pkey; Type: CONSTRAINT; Schema: report; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY soop_trv_manual
    ADD CONSTRAINT soop_trv_manual_pkey PRIMARY KEY (cruise_id);


--
-- Name: soop_xbt_line_pkey; Type: CONSTRAINT; Schema: report; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY soop_xbt_line
    ADD CONSTRAINT soop_xbt_line_pkey PRIMARY KEY (line_name);


--
-- Name: soop_xbt_manual_pkey; Type: CONSTRAINT; Schema: report; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY soop_xbt_manual
    ADD CONSTRAINT soop_xbt_manual_pkey PRIMARY KEY (bundle_id);


--
-- Name: soop_xbt_pkey; Type: CONSTRAINT; Schema: report; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY soop_xbt
    ADD CONSTRAINT soop_xbt_pkey PRIMARY KEY (p_id);


--
-- Name: soop_xbt_realtime_manual_pkey; Type: CONSTRAINT; Schema: report; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY soop_xbt_realtime_manual
    ADD CONSTRAINT soop_xbt_realtime_manual_pkey PRIMARY KEY (cruise_id);


--
-- Name: srs_altimetry_manual_pkey; Type: CONSTRAINT; Schema: report; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY srs_altimetry_manual
    ADD CONSTRAINT srs_altimetry_manual_pkey PRIMARY KEY (pkid);


--
-- Name: srs_gridded_products_manual_pkey; Type: CONSTRAINT; Schema: report; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY srs_gridded_products_manual
    ADD CONSTRAINT srs_gridded_products_manual_pkey PRIMARY KEY (product_name);


--
-- Name: fk4cf96a0a64c74090; Type: FK CONSTRAINT; Schema: report; Owner: postgres
--

ALTER TABLE ONLY facility_summary
    ADD CONSTRAINT fk4cf96a0a64c74090 FOREIGN KEY (summary_item_id) REFERENCES facility_summary_item(row_id);


--
-- Name: fk4cf96a0a944a76aa; Type: FK CONSTRAINT; Schema: report; Owner: postgres
--

ALTER TABLE ONLY facility_summary
    ADD CONSTRAINT fk4cf96a0a944a76aa FOREIGN KEY (facility_name_id) REFERENCES public.facility(id);


--
-- Name: soop_xbt_bundle_id_fkey; Type: FK CONSTRAINT; Schema: report; Owner: postgres
--

ALTER TABLE ONLY soop_xbt
    ADD CONSTRAINT soop_xbt_bundle_id_fkey FOREIGN KEY (bundle_id) REFERENCES soop_xbt_manual(bundle_id);


--
-- Name: soop_xbt_line_name_fkey; Type: FK CONSTRAINT; Schema: report; Owner: postgres
--

ALTER TABLE ONLY soop_xbt
    ADD CONSTRAINT soop_xbt_line_name_fkey FOREIGN KEY (line_name) REFERENCES soop_xbt_line(line_name);


--
-- Name: date_round(timestamp with time zone, interval); Type: ACL; Schema: report; Owner: postgres
--

REVOKE ALL ON FUNCTION date_round(base_date timestamp with time zone, round_interval interval) FROM PUBLIC;
REVOKE ALL ON FUNCTION date_round(base_date timestamp with time zone, round_interval interval) FROM postgres;
GRANT ALL ON FUNCTION date_round(base_date timestamp with time zone, round_interval interval) TO postgres;
GRANT ALL ON FUNCTION date_round(base_date timestamp with time zone, round_interval interval) TO PUBLIC;
GRANT ALL ON FUNCTION date_round(base_date timestamp with time zone, round_interval interval) TO jfca;
GRANT ALL ON FUNCTION date_round(base_date timestamp with time zone, round_interval interval) TO xavier;
GRANT ALL ON FUNCTION date_round(base_date timestamp with time zone, round_interval interval) TO jac;


--
-- Name: hibernate_sequence; Type: ACL; Schema: report; Owner: postgres
--

REVOKE ALL ON SEQUENCE hibernate_sequence FROM PUBLIC;
REVOKE ALL ON SEQUENCE hibernate_sequence FROM postgres;
GRANT ALL ON SEQUENCE hibernate_sequence TO postgres;
GRANT ALL ON SEQUENCE hibernate_sequence TO jfca;
GRANT ALL ON SEQUENCE hibernate_sequence TO xavier;
GRANT SELECT ON SEQUENCE hibernate_sequence TO jac;


--
-- Name: aatams_sattag_mdb_workflow_manual; Type: ACL; Schema: report; Owner: postgres
--

REVOKE ALL ON TABLE aatams_sattag_mdb_workflow_manual FROM PUBLIC;
REVOKE ALL ON TABLE aatams_sattag_mdb_workflow_manual FROM postgres;
GRANT ALL ON TABLE aatams_sattag_mdb_workflow_manual TO postgres;
GRANT ALL ON TABLE aatams_sattag_mdb_workflow_manual TO jfca;
GRANT ALL ON TABLE aatams_sattag_mdb_workflow_manual TO xavier;
GRANT SELECT ON TABLE aatams_sattag_mdb_workflow_manual TO jac;


--
-- Name: aatams_sattag_all_deployments_view; Type: ACL; Schema: report; Owner: postgres
--

REVOKE ALL ON TABLE aatams_sattag_all_deployments_view FROM PUBLIC;
REVOKE ALL ON TABLE aatams_sattag_all_deployments_view FROM postgres;
GRANT ALL ON TABLE aatams_sattag_all_deployments_view TO postgres;
GRANT ALL ON TABLE aatams_sattag_all_deployments_view TO jfca;
GRANT ALL ON TABLE aatams_sattag_all_deployments_view TO xavier;
GRANT SELECT ON TABLE aatams_sattag_all_deployments_view TO jac;


--
-- Name: aatams_sattag_data_summary_view; Type: ACL; Schema: report; Owner: postgres
--

REVOKE ALL ON TABLE aatams_sattag_data_summary_view FROM PUBLIC;
REVOKE ALL ON TABLE aatams_sattag_data_summary_view FROM postgres;
GRANT ALL ON TABLE aatams_sattag_data_summary_view TO postgres;
GRANT ALL ON TABLE aatams_sattag_data_summary_view TO jfca;
GRANT ALL ON TABLE aatams_sattag_data_summary_view TO xavier;
GRANT SELECT ON TABLE aatams_sattag_data_summary_view TO jac;


--
-- Name: aatams_sattag_manual; Type: ACL; Schema: report; Owner: postgres
--

REVOKE ALL ON TABLE aatams_sattag_manual FROM PUBLIC;
REVOKE ALL ON TABLE aatams_sattag_manual FROM postgres;
GRANT ALL ON TABLE aatams_sattag_manual TO postgres;
GRANT ALL ON TABLE aatams_sattag_manual TO jfca;
GRANT ALL ON TABLE aatams_sattag_manual TO xavier;
GRANT SELECT ON TABLE aatams_sattag_manual TO jac;


--
-- Name: abos_asfssots_all_deployments_view; Type: ACL; Schema: report; Owner: postgres
--

REVOKE ALL ON TABLE abos_asfssots_all_deployments_view FROM PUBLIC;
REVOKE ALL ON TABLE abos_asfssots_all_deployments_view FROM postgres;
GRANT ALL ON TABLE abos_asfssots_all_deployments_view TO postgres;
GRANT ALL ON TABLE abos_asfssots_all_deployments_view TO jfca;
GRANT ALL ON TABLE abos_asfssots_all_deployments_view TO xavier;
GRANT SELECT ON TABLE abos_asfssots_all_deployments_view TO jac;


--
-- Name: abos_asfssots_data_summary_view; Type: ACL; Schema: report; Owner: postgres
--

REVOKE ALL ON TABLE abos_asfssots_data_summary_view FROM PUBLIC;
REVOKE ALL ON TABLE abos_asfssots_data_summary_view FROM postgres;
GRANT ALL ON TABLE abos_asfssots_data_summary_view TO postgres;
GRANT ALL ON TABLE abos_asfssots_data_summary_view TO jfca;
GRANT ALL ON TABLE abos_asfssots_data_summary_view TO xavier;
GRANT SELECT ON TABLE abos_asfssots_data_summary_view TO jac;


--
-- Name: acorn_manual; Type: ACL; Schema: report; Owner: postgres
--

REVOKE ALL ON TABLE acorn_manual FROM PUBLIC;
REVOKE ALL ON TABLE acorn_manual FROM postgres;
GRANT ALL ON TABLE acorn_manual TO postgres;
GRANT ALL ON TABLE acorn_manual TO jfca;
GRANT ALL ON TABLE acorn_manual TO xavier;
GRANT SELECT ON TABLE acorn_manual TO jac;


--
-- Name: acorn_all_deployments_view; Type: ACL; Schema: report; Owner: postgres
--

REVOKE ALL ON TABLE acorn_all_deployments_view FROM PUBLIC;
REVOKE ALL ON TABLE acorn_all_deployments_view FROM postgres;
GRANT ALL ON TABLE acorn_all_deployments_view TO postgres;
GRANT ALL ON TABLE acorn_all_deployments_view TO jfca;
GRANT ALL ON TABLE acorn_all_deployments_view TO xavier;
GRANT SELECT ON TABLE acorn_all_deployments_view TO jac;


--
-- Name: anfog_manual; Type: ACL; Schema: report; Owner: postgres
--

REVOKE ALL ON TABLE anfog_manual FROM PUBLIC;
REVOKE ALL ON TABLE anfog_manual FROM postgres;
GRANT ALL ON TABLE anfog_manual TO postgres;
GRANT ALL ON TABLE anfog_manual TO jfca;
GRANT ALL ON TABLE anfog_manual TO xavier;
GRANT SELECT ON TABLE anfog_manual TO jac;


--
-- Name: anfog_all_deployments_view; Type: ACL; Schema: report; Owner: postgres
--

REVOKE ALL ON TABLE anfog_all_deployments_view FROM PUBLIC;
REVOKE ALL ON TABLE anfog_all_deployments_view FROM postgres;
GRANT ALL ON TABLE anfog_all_deployments_view TO postgres;
GRANT ALL ON TABLE anfog_all_deployments_view TO jfca;
GRANT ALL ON TABLE anfog_all_deployments_view TO xavier;
GRANT SELECT ON TABLE anfog_all_deployments_view TO jac;


--
-- Name: anfog_data_summary_view; Type: ACL; Schema: report; Owner: postgres
--

REVOKE ALL ON TABLE anfog_data_summary_view FROM PUBLIC;
REVOKE ALL ON TABLE anfog_data_summary_view FROM postgres;
GRANT ALL ON TABLE anfog_data_summary_view TO postgres;
GRANT ALL ON TABLE anfog_data_summary_view TO jfca;
GRANT ALL ON TABLE anfog_data_summary_view TO xavier;
GRANT SELECT ON TABLE anfog_data_summary_view TO jac;


--
-- Name: anfog_seq; Type: ACL; Schema: report; Owner: postgres
--

REVOKE ALL ON SEQUENCE anfog_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE anfog_seq FROM postgres;
GRANT ALL ON SEQUENCE anfog_seq TO postgres;
GRANT ALL ON SEQUENCE anfog_seq TO jfca;
GRANT ALL ON SEQUENCE anfog_seq TO xavier;
GRANT SELECT ON SEQUENCE anfog_seq TO jac;


--
-- Name: anmn_acoustics_all_deployments_view; Type: ACL; Schema: report; Owner: postgres
--

REVOKE ALL ON TABLE anmn_acoustics_all_deployments_view FROM PUBLIC;
REVOKE ALL ON TABLE anmn_acoustics_all_deployments_view FROM postgres;
GRANT ALL ON TABLE anmn_acoustics_all_deployments_view TO postgres;
GRANT ALL ON TABLE anmn_acoustics_all_deployments_view TO jfca;
GRANT ALL ON TABLE anmn_acoustics_all_deployments_view TO xavier;
GRANT SELECT ON TABLE anmn_acoustics_all_deployments_view TO jac;


--
-- Name: anmn_acoustics_data_summary_view; Type: ACL; Schema: report; Owner: postgres
--

REVOKE ALL ON TABLE anmn_acoustics_data_summary_view FROM PUBLIC;
REVOKE ALL ON TABLE anmn_acoustics_data_summary_view FROM postgres;
GRANT ALL ON TABLE anmn_acoustics_data_summary_view TO postgres;
GRANT ALL ON TABLE anmn_acoustics_data_summary_view TO jfca;
GRANT ALL ON TABLE anmn_acoustics_data_summary_view TO xavier;
GRANT SELECT ON TABLE anmn_acoustics_data_summary_view TO jac;


--
-- Name: anmn_platforms_manual; Type: ACL; Schema: report; Owner: postgres
--

REVOKE ALL ON TABLE anmn_platforms_manual FROM PUBLIC;
REVOKE ALL ON TABLE anmn_platforms_manual FROM postgres;
GRANT ALL ON TABLE anmn_platforms_manual TO postgres;
GRANT ALL ON TABLE anmn_platforms_manual TO jfca;
GRANT ALL ON TABLE anmn_platforms_manual TO xavier;
GRANT SELECT ON TABLE anmn_platforms_manual TO jac;


--
-- Name: anmn_all_deployments_view; Type: ACL; Schema: report; Owner: postgres
--

REVOKE ALL ON TABLE anmn_all_deployments_view FROM PUBLIC;
REVOKE ALL ON TABLE anmn_all_deployments_view FROM postgres;
GRANT ALL ON TABLE anmn_all_deployments_view TO postgres;
GRANT ALL ON TABLE anmn_all_deployments_view TO jfca;
GRANT ALL ON TABLE anmn_all_deployments_view TO xavier;
GRANT SELECT ON TABLE anmn_all_deployments_view TO jac;


--
-- Name: anmn_data_summary_view; Type: ACL; Schema: report; Owner: postgres
--

REVOKE ALL ON TABLE anmn_data_summary_view FROM PUBLIC;
REVOKE ALL ON TABLE anmn_data_summary_view FROM postgres;
GRANT ALL ON TABLE anmn_data_summary_view TO postgres;
GRANT ALL ON TABLE anmn_data_summary_view TO jfca;
GRANT ALL ON TABLE anmn_data_summary_view TO xavier;
GRANT SELECT ON TABLE anmn_data_summary_view TO jac;


--
-- Name: anmn_datacategories_manual; Type: ACL; Schema: report; Owner: postgres
--

REVOKE ALL ON TABLE anmn_datacategories_manual FROM PUBLIC;
REVOKE ALL ON TABLE anmn_datacategories_manual FROM postgres;
GRANT ALL ON TABLE anmn_datacategories_manual TO postgres;
GRANT ALL ON TABLE anmn_datacategories_manual TO jfca;
GRANT ALL ON TABLE anmn_datacategories_manual TO xavier;
GRANT SELECT ON TABLE anmn_datacategories_manual TO jac;


--
-- Name: anmn_datacategories_manual_pkid_seq; Type: ACL; Schema: report; Owner: postgres
--

REVOKE ALL ON SEQUENCE anmn_datacategories_manual_pkid_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE anmn_datacategories_manual_pkid_seq FROM postgres;
GRANT ALL ON SEQUENCE anmn_datacategories_manual_pkid_seq TO postgres;
GRANT ALL ON SEQUENCE anmn_datacategories_manual_pkid_seq TO jfca;
GRANT ALL ON SEQUENCE anmn_datacategories_manual_pkid_seq TO xavier;
GRANT SELECT ON SEQUENCE anmn_datacategories_manual_pkid_seq TO jac;


--
-- Name: anmn_manual; Type: ACL; Schema: report; Owner: postgres
--

REVOKE ALL ON TABLE anmn_manual FROM PUBLIC;
REVOKE ALL ON TABLE anmn_manual FROM postgres;
GRANT ALL ON TABLE anmn_manual TO postgres;
GRANT ALL ON TABLE anmn_manual TO jfca;
GRANT ALL ON TABLE anmn_manual TO xavier;
GRANT SELECT ON TABLE anmn_manual TO jac;


--
-- Name: anmn_manual_pkid_seq; Type: ACL; Schema: report; Owner: postgres
--

REVOKE ALL ON SEQUENCE anmn_manual_pkid_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE anmn_manual_pkid_seq FROM postgres;
GRANT ALL ON SEQUENCE anmn_manual_pkid_seq TO postgres;
GRANT ALL ON SEQUENCE anmn_manual_pkid_seq TO jfca;
GRANT ALL ON SEQUENCE anmn_manual_pkid_seq TO xavier;
GRANT SELECT ON SEQUENCE anmn_manual_pkid_seq TO jac;


--
-- Name: nrs_aims_manual; Type: ACL; Schema: report; Owner: postgres
--

REVOKE ALL ON TABLE nrs_aims_manual FROM PUBLIC;
REVOKE ALL ON TABLE nrs_aims_manual FROM postgres;
GRANT ALL ON TABLE nrs_aims_manual TO postgres;
GRANT ALL ON TABLE nrs_aims_manual TO jfca;
GRANT ALL ON TABLE nrs_aims_manual TO xavier;
GRANT SELECT ON TABLE nrs_aims_manual TO jac;


--
-- Name: anmn_nrs_realtime_all_deployments_view; Type: ACL; Schema: report; Owner: postgres
--

REVOKE ALL ON TABLE anmn_nrs_realtime_all_deployments_view FROM PUBLIC;
REVOKE ALL ON TABLE anmn_nrs_realtime_all_deployments_view FROM postgres;
GRANT ALL ON TABLE anmn_nrs_realtime_all_deployments_view TO postgres;
GRANT ALL ON TABLE anmn_nrs_realtime_all_deployments_view TO jfca;
GRANT ALL ON TABLE anmn_nrs_realtime_all_deployments_view TO xavier;
GRANT SELECT ON TABLE anmn_nrs_realtime_all_deployments_view TO jac;


--
-- Name: anmn_nrs_realtime_data_summary_view; Type: ACL; Schema: report; Owner: postgres
--

REVOKE ALL ON TABLE anmn_nrs_realtime_data_summary_view FROM PUBLIC;
REVOKE ALL ON TABLE anmn_nrs_realtime_data_summary_view FROM postgres;
GRANT ALL ON TABLE anmn_nrs_realtime_data_summary_view TO postgres;
GRANT ALL ON TABLE anmn_nrs_realtime_data_summary_view TO jfca;
GRANT ALL ON TABLE anmn_nrs_realtime_data_summary_view TO xavier;
GRANT SELECT ON TABLE anmn_nrs_realtime_data_summary_view TO jac;


--
-- Name: anmn_platforms_manual_pkid_seq; Type: ACL; Schema: report; Owner: postgres
--

REVOKE ALL ON SEQUENCE anmn_platforms_manual_pkid_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE anmn_platforms_manual_pkid_seq FROM postgres;
GRANT ALL ON SEQUENCE anmn_platforms_manual_pkid_seq TO postgres;
GRANT ALL ON SEQUENCE anmn_platforms_manual_pkid_seq TO jfca;
GRANT ALL ON SEQUENCE anmn_platforms_manual_pkid_seq TO xavier;
GRANT SELECT ON SEQUENCE anmn_platforms_manual_pkid_seq TO jac;


--
-- Name: anmn_status_manual; Type: ACL; Schema: report; Owner: postgres
--

REVOKE ALL ON TABLE anmn_status_manual FROM PUBLIC;
REVOKE ALL ON TABLE anmn_status_manual FROM postgres;
GRANT ALL ON TABLE anmn_status_manual TO postgres;
GRANT ALL ON TABLE anmn_status_manual TO jfca;
GRANT ALL ON TABLE anmn_status_manual TO xavier;
GRANT SELECT ON TABLE anmn_status_manual TO jac;


--
-- Name: anmn_status_manual_pkid_seq; Type: ACL; Schema: report; Owner: postgres
--

REVOKE ALL ON SEQUENCE anmn_status_manual_pkid_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE anmn_status_manual_pkid_seq FROM postgres;
GRANT ALL ON SEQUENCE anmn_status_manual_pkid_seq TO postgres;
GRANT ALL ON SEQUENCE anmn_status_manual_pkid_seq TO jfca;
GRANT ALL ON SEQUENCE anmn_status_manual_pkid_seq TO xavier;
GRANT SELECT ON SEQUENCE anmn_status_manual_pkid_seq TO jac;


--
-- Name: argo_all_deployments_view; Type: ACL; Schema: report; Owner: postgres
--

REVOKE ALL ON TABLE argo_all_deployments_view FROM PUBLIC;
REVOKE ALL ON TABLE argo_all_deployments_view FROM postgres;
GRANT ALL ON TABLE argo_all_deployments_view TO postgres;
GRANT ALL ON TABLE argo_all_deployments_view TO jfca;
GRANT ALL ON TABLE argo_all_deployments_view TO xavier;
GRANT SELECT ON TABLE argo_all_deployments_view TO jac;


--
-- Name: argo_data_summary_view; Type: ACL; Schema: report; Owner: postgres
--

REVOKE ALL ON TABLE argo_data_summary_view FROM PUBLIC;
REVOKE ALL ON TABLE argo_data_summary_view FROM postgres;
GRANT ALL ON TABLE argo_data_summary_view TO postgres;
GRANT ALL ON TABLE argo_data_summary_view TO jfca;
GRANT ALL ON TABLE argo_data_summary_view TO xavier;
GRANT SELECT ON TABLE argo_data_summary_view TO jac;


--
-- Name: auv_manual; Type: ACL; Schema: report; Owner: postgres
--

REVOKE ALL ON TABLE auv_manual FROM PUBLIC;
REVOKE ALL ON TABLE auv_manual FROM postgres;
GRANT ALL ON TABLE auv_manual TO postgres;
GRANT ALL ON TABLE auv_manual TO jfca;
GRANT ALL ON TABLE auv_manual TO xavier;
GRANT SELECT ON TABLE auv_manual TO jac;


--
-- Name: auv_all_deployments_view; Type: ACL; Schema: report; Owner: postgres
--

REVOKE ALL ON TABLE auv_all_deployments_view FROM PUBLIC;
REVOKE ALL ON TABLE auv_all_deployments_view FROM postgres;
GRANT ALL ON TABLE auv_all_deployments_view TO postgres;
GRANT ALL ON TABLE auv_all_deployments_view TO jfca;
GRANT ALL ON TABLE auv_all_deployments_view TO xavier;
GRANT SELECT ON TABLE auv_all_deployments_view TO jac;


--
-- Name: auv_data_summary_view; Type: ACL; Schema: report; Owner: postgres
--

REVOKE ALL ON TABLE auv_data_summary_view FROM PUBLIC;
REVOKE ALL ON TABLE auv_data_summary_view FROM postgres;
GRANT ALL ON TABLE auv_data_summary_view TO postgres;
GRANT ALL ON TABLE auv_data_summary_view TO jfca;
GRANT ALL ON TABLE auv_data_summary_view TO xavier;
GRANT SELECT ON TABLE auv_data_summary_view TO jac;


--
-- Name: facility_summary; Type: ACL; Schema: report; Owner: postgres
--

REVOKE ALL ON TABLE facility_summary FROM PUBLIC;
REVOKE ALL ON TABLE facility_summary FROM postgres;
GRANT ALL ON TABLE facility_summary TO postgres;
GRANT ALL ON TABLE facility_summary TO jfca;
GRANT ALL ON TABLE facility_summary TO xavier;
GRANT SELECT ON TABLE facility_summary TO jac;


--
-- Name: facility_summary_item; Type: ACL; Schema: report; Owner: postgres
--

REVOKE ALL ON TABLE facility_summary_item FROM PUBLIC;
REVOKE ALL ON TABLE facility_summary_item FROM postgres;
GRANT ALL ON TABLE facility_summary_item TO postgres;
GRANT ALL ON TABLE facility_summary_item TO jfca;
GRANT ALL ON TABLE facility_summary_item TO xavier;
GRANT SELECT ON TABLE facility_summary_item TO jac;


--
-- Name: facility_summary_item_row_id_seq; Type: ACL; Schema: report; Owner: postgres
--

REVOKE ALL ON SEQUENCE facility_summary_item_row_id_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE facility_summary_item_row_id_seq FROM postgres;
GRANT ALL ON SEQUENCE facility_summary_item_row_id_seq TO postgres;
GRANT ALL ON SEQUENCE facility_summary_item_row_id_seq TO jfca;
GRANT ALL ON SEQUENCE facility_summary_item_row_id_seq TO xavier;
GRANT SELECT ON SEQUENCE facility_summary_item_row_id_seq TO jac;


--
-- Name: facility_summary_row_id_seq; Type: ACL; Schema: report; Owner: postgres
--

REVOKE ALL ON SEQUENCE facility_summary_row_id_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE facility_summary_row_id_seq FROM postgres;
GRANT ALL ON SEQUENCE facility_summary_row_id_seq TO postgres;
GRANT ALL ON SEQUENCE facility_summary_row_id_seq TO jfca;
GRANT ALL ON SEQUENCE facility_summary_row_id_seq TO xavier;
GRANT SELECT ON SEQUENCE facility_summary_row_id_seq TO jac;


--
-- Name: facility_summary_row_id_seq1; Type: ACL; Schema: report; Owner: postgres
--

REVOKE ALL ON SEQUENCE facility_summary_row_id_seq1 FROM PUBLIC;
REVOKE ALL ON SEQUENCE facility_summary_row_id_seq1 FROM postgres;
GRANT ALL ON SEQUENCE facility_summary_row_id_seq1 TO postgres;
GRANT ALL ON SEQUENCE facility_summary_row_id_seq1 TO jfca;
GRANT ALL ON SEQUENCE facility_summary_row_id_seq1 TO xavier;
GRANT SELECT ON SEQUENCE facility_summary_row_id_seq1 TO jac;


--
-- Name: facility_summary_view; Type: ACL; Schema: report; Owner: postgres
--

REVOKE ALL ON TABLE facility_summary_view FROM PUBLIC;
REVOKE ALL ON TABLE facility_summary_view FROM postgres;
GRANT ALL ON TABLE facility_summary_view TO postgres;
GRANT ALL ON TABLE facility_summary_view TO jfca;
GRANT ALL ON TABLE facility_summary_view TO xavier;
GRANT SELECT ON TABLE facility_summary_view TO jac;


--
-- Name: faimms_manual; Type: ACL; Schema: report; Owner: postgres
--

REVOKE ALL ON TABLE faimms_manual FROM PUBLIC;
REVOKE ALL ON TABLE faimms_manual FROM postgres;
GRANT ALL ON TABLE faimms_manual TO postgres;
GRANT ALL ON TABLE faimms_manual TO jfca;
GRANT ALL ON TABLE faimms_manual TO xavier;
GRANT SELECT ON TABLE faimms_manual TO jac;


--
-- Name: faimms_all_deployments_view; Type: ACL; Schema: report; Owner: postgres
--

REVOKE ALL ON TABLE faimms_all_deployments_view FROM PUBLIC;
REVOKE ALL ON TABLE faimms_all_deployments_view FROM postgres;
GRANT ALL ON TABLE faimms_all_deployments_view TO postgres;
GRANT ALL ON TABLE faimms_all_deployments_view TO jfca;
GRANT ALL ON TABLE faimms_all_deployments_view TO xavier;
GRANT SELECT ON TABLE faimms_all_deployments_view TO jac;


--
-- Name: faimms_data_summary_view; Type: ACL; Schema: report; Owner: postgres
--

REVOKE ALL ON TABLE faimms_data_summary_view FROM PUBLIC;
REVOKE ALL ON TABLE faimms_data_summary_view FROM postgres;
GRANT ALL ON TABLE faimms_data_summary_view TO postgres;
GRANT ALL ON TABLE faimms_data_summary_view TO jfca;
GRANT ALL ON TABLE faimms_data_summary_view TO xavier;
GRANT SELECT ON TABLE faimms_data_summary_view TO jac;


--
-- Name: soop_asf_manual; Type: ACL; Schema: report; Owner: postgres
--

REVOKE ALL ON TABLE soop_asf_manual FROM PUBLIC;
REVOKE ALL ON TABLE soop_asf_manual FROM postgres;
GRANT ALL ON TABLE soop_asf_manual TO postgres;
GRANT ALL ON TABLE soop_asf_manual TO jfca;
GRANT ALL ON TABLE soop_asf_manual TO xavier;
GRANT SELECT ON TABLE soop_asf_manual TO jac;


--
-- Name: soop_ba_manual; Type: ACL; Schema: report; Owner: postgres
--

REVOKE ALL ON TABLE soop_ba_manual FROM PUBLIC;
REVOKE ALL ON TABLE soop_ba_manual FROM postgres;
GRANT ALL ON TABLE soop_ba_manual TO postgres;
GRANT ALL ON TABLE soop_ba_manual TO jfca;
GRANT ALL ON TABLE soop_ba_manual TO xavier;
GRANT SELECT ON TABLE soop_ba_manual TO jac;


--
-- Name: soop_co2_manual; Type: ACL; Schema: report; Owner: postgres
--

REVOKE ALL ON TABLE soop_co2_manual FROM PUBLIC;
REVOKE ALL ON TABLE soop_co2_manual FROM postgres;
GRANT ALL ON TABLE soop_co2_manual TO postgres;
GRANT ALL ON TABLE soop_co2_manual TO jfca;
GRANT ALL ON TABLE soop_co2_manual TO xavier;
GRANT SELECT ON TABLE soop_co2_manual TO jac;


--
-- Name: soop_sst_manual; Type: ACL; Schema: report; Owner: postgres
--

REVOKE ALL ON TABLE soop_sst_manual FROM PUBLIC;
REVOKE ALL ON TABLE soop_sst_manual FROM postgres;
GRANT ALL ON TABLE soop_sst_manual TO postgres;
GRANT ALL ON TABLE soop_sst_manual TO jfca;
GRANT ALL ON TABLE soop_sst_manual TO xavier;
GRANT SELECT ON TABLE soop_sst_manual TO jac;


--
-- Name: soop_tmv_manual; Type: ACL; Schema: report; Owner: postgres
--

REVOKE ALL ON TABLE soop_tmv_manual FROM PUBLIC;
REVOKE ALL ON TABLE soop_tmv_manual FROM postgres;
GRANT ALL ON TABLE soop_tmv_manual TO postgres;
GRANT ALL ON TABLE soop_tmv_manual TO jfca;
GRANT ALL ON TABLE soop_tmv_manual TO xavier;
GRANT SELECT ON TABLE soop_tmv_manual TO jac;


--
-- Name: soop_trv_manual; Type: ACL; Schema: report; Owner: postgres
--

REVOKE ALL ON TABLE soop_trv_manual FROM PUBLIC;
REVOKE ALL ON TABLE soop_trv_manual FROM postgres;
GRANT ALL ON TABLE soop_trv_manual TO postgres;
GRANT ALL ON TABLE soop_trv_manual TO jfca;
GRANT ALL ON TABLE soop_trv_manual TO xavier;
GRANT SELECT ON TABLE soop_trv_manual TO jac;


--
-- Name: soop_xbt; Type: ACL; Schema: report; Owner: postgres
--

REVOKE ALL ON TABLE soop_xbt FROM PUBLIC;
REVOKE ALL ON TABLE soop_xbt FROM postgres;
GRANT ALL ON TABLE soop_xbt TO postgres;
GRANT ALL ON TABLE soop_xbt TO jfca;
GRANT ALL ON TABLE soop_xbt TO xavier;
GRANT SELECT ON TABLE soop_xbt TO jac;


--
-- Name: soop_xbt_manual; Type: ACL; Schema: report; Owner: postgres
--

REVOKE ALL ON TABLE soop_xbt_manual FROM PUBLIC;
REVOKE ALL ON TABLE soop_xbt_manual FROM postgres;
GRANT ALL ON TABLE soop_xbt_manual TO postgres;
GRANT ALL ON TABLE soop_xbt_manual TO jfca;
GRANT ALL ON TABLE soop_xbt_manual TO xavier;
GRANT SELECT ON TABLE soop_xbt_manual TO jac;


--
-- Name: soop_all_deployments_view; Type: ACL; Schema: report; Owner: postgres
--

REVOKE ALL ON TABLE soop_all_deployments_view FROM PUBLIC;
REVOKE ALL ON TABLE soop_all_deployments_view FROM postgres;
GRANT ALL ON TABLE soop_all_deployments_view TO postgres;
GRANT ALL ON TABLE soop_all_deployments_view TO jfca;
GRANT ALL ON TABLE soop_all_deployments_view TO xavier;
GRANT SELECT ON TABLE soop_all_deployments_view TO jac;


--
-- Name: soop_cpr_manual; Type: ACL; Schema: report; Owner: postgres
--

REVOKE ALL ON TABLE soop_cpr_manual FROM PUBLIC;
REVOKE ALL ON TABLE soop_cpr_manual FROM postgres;
GRANT ALL ON TABLE soop_cpr_manual TO postgres;
GRANT ALL ON TABLE soop_cpr_manual TO jfca;
GRANT ALL ON TABLE soop_cpr_manual TO xavier;
GRANT SELECT ON TABLE soop_cpr_manual TO jac;


--
-- Name: soop_cpr_all_deployments_view; Type: ACL; Schema: report; Owner: postgres
--

REVOKE ALL ON TABLE soop_cpr_all_deployments_view FROM PUBLIC;
REVOKE ALL ON TABLE soop_cpr_all_deployments_view FROM postgres;
GRANT ALL ON TABLE soop_cpr_all_deployments_view TO postgres;
GRANT ALL ON TABLE soop_cpr_all_deployments_view TO jfca;
GRANT ALL ON TABLE soop_cpr_all_deployments_view TO xavier;
GRANT SELECT ON TABLE soop_cpr_all_deployments_view TO jac;


--
-- Name: soop_data_summary_view; Type: ACL; Schema: report; Owner: postgres
--

REVOKE ALL ON TABLE soop_data_summary_view FROM PUBLIC;
REVOKE ALL ON TABLE soop_data_summary_view FROM postgres;
GRANT ALL ON TABLE soop_data_summary_view TO postgres;
GRANT ALL ON TABLE soop_data_summary_view TO jfca;
GRANT ALL ON TABLE soop_data_summary_view TO xavier;
GRANT SELECT ON TABLE soop_data_summary_view TO jac;


--
-- Name: soop_frrf_manual; Type: ACL; Schema: report; Owner: postgres
--

REVOKE ALL ON TABLE soop_frrf_manual FROM PUBLIC;
REVOKE ALL ON TABLE soop_frrf_manual FROM postgres;
GRANT ALL ON TABLE soop_frrf_manual TO postgres;
GRANT ALL ON TABLE soop_frrf_manual TO jfca;
GRANT ALL ON TABLE soop_frrf_manual TO xavier;
GRANT SELECT ON TABLE soop_frrf_manual TO jac;


--
-- Name: soop_xbt_line; Type: ACL; Schema: report; Owner: postgres
--

REVOKE ALL ON TABLE soop_xbt_line FROM PUBLIC;
REVOKE ALL ON TABLE soop_xbt_line FROM postgres;
GRANT ALL ON TABLE soop_xbt_line TO postgres;
GRANT ALL ON TABLE soop_xbt_line TO jfca;
GRANT ALL ON TABLE soop_xbt_line TO xavier;
GRANT SELECT ON TABLE soop_xbt_line TO jac;


--
-- Name: soop_xbt_realtime_manual; Type: ACL; Schema: report; Owner: postgres
--

REVOKE ALL ON TABLE soop_xbt_realtime_manual FROM PUBLIC;
REVOKE ALL ON TABLE soop_xbt_realtime_manual FROM postgres;
GRANT ALL ON TABLE soop_xbt_realtime_manual TO postgres;
GRANT ALL ON TABLE soop_xbt_realtime_manual TO jfca;
GRANT ALL ON TABLE soop_xbt_realtime_manual TO xavier;
GRANT SELECT ON TABLE soop_xbt_realtime_manual TO jac;


--
-- Name: srs_altimetry_manual; Type: ACL; Schema: report; Owner: postgres
--

REVOKE ALL ON TABLE srs_altimetry_manual FROM PUBLIC;
REVOKE ALL ON TABLE srs_altimetry_manual FROM postgres;
GRANT ALL ON TABLE srs_altimetry_manual TO postgres;
GRANT ALL ON TABLE srs_altimetry_manual TO jfca;
GRANT ALL ON TABLE srs_altimetry_manual TO xavier;
GRANT SELECT ON TABLE srs_altimetry_manual TO jac;


--
-- Name: srs_bio_optical_db_manual; Type: ACL; Schema: report; Owner: postgres
--

REVOKE ALL ON TABLE srs_bio_optical_db_manual FROM PUBLIC;
REVOKE ALL ON TABLE srs_bio_optical_db_manual FROM postgres;
GRANT ALL ON TABLE srs_bio_optical_db_manual TO postgres;
GRANT ALL ON TABLE srs_bio_optical_db_manual TO jfca;
GRANT ALL ON TABLE srs_bio_optical_db_manual TO xavier;
GRANT SELECT ON TABLE srs_bio_optical_db_manual TO jac;


--
-- Name: srs_gridded_products_manual; Type: ACL; Schema: report; Owner: postgres
--

REVOKE ALL ON TABLE srs_gridded_products_manual FROM PUBLIC;
REVOKE ALL ON TABLE srs_gridded_products_manual FROM postgres;
GRANT ALL ON TABLE srs_gridded_products_manual TO postgres;
GRANT ALL ON TABLE srs_gridded_products_manual TO jfca;
GRANT ALL ON TABLE srs_gridded_products_manual TO xavier;
GRANT SELECT ON TABLE srs_gridded_products_manual TO jac;


--
-- Name: srs_all_deployments_view; Type: ACL; Schema: report; Owner: postgres
--

REVOKE ALL ON TABLE srs_all_deployments_view FROM PUBLIC;
REVOKE ALL ON TABLE srs_all_deployments_view FROM postgres;
GRANT ALL ON TABLE srs_all_deployments_view TO postgres;
GRANT ALL ON TABLE srs_all_deployments_view TO jfca;
GRANT ALL ON TABLE srs_all_deployments_view TO xavier;
GRANT SELECT ON TABLE srs_all_deployments_view TO jac;


--
-- Name: srs_data_summary_view; Type: ACL; Schema: report; Owner: postgres
--

REVOKE ALL ON TABLE srs_data_summary_view FROM PUBLIC;
REVOKE ALL ON TABLE srs_data_summary_view FROM postgres;
GRANT ALL ON TABLE srs_data_summary_view TO postgres;
GRANT ALL ON TABLE srs_data_summary_view TO jfca;
GRANT ALL ON TABLE srs_data_summary_view TO xavier;
GRANT SELECT ON TABLE srs_data_summary_view TO jac;


--
-- Name: totals; Type: ACL; Schema: report; Owner: postgres
--

REVOKE ALL ON TABLE totals FROM PUBLIC;
REVOKE ALL ON TABLE totals FROM postgres;
GRANT ALL ON TABLE totals TO postgres;
GRANT ALL ON TABLE totals TO jfca;
GRANT ALL ON TABLE totals TO xavier;
GRANT SELECT ON TABLE totals TO jac;


--
-- Name: totals_view; Type: ACL; Schema: report; Owner: postgres
--

REVOKE ALL ON TABLE totals_view FROM PUBLIC;
REVOKE ALL ON TABLE totals_view FROM postgres;
GRANT ALL ON TABLE totals_view TO postgres;
GRANT ALL ON TABLE totals_view TO jfca;
GRANT ALL ON TABLE totals_view TO xavier;
GRANT SELECT ON TABLE totals_view TO jac;


--
-- PostgreSQL database dump complete
--

