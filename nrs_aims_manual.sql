--
-- PostgreSQL database dump
--

SET statement_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;


SET search_path = report, pg_catalog;

CREATE TABLE nrs_aims_manual (
    platform_name character varying(50) NOT NULL,
    deployment_start timestamp without time zone,
    data_on_staging timestamp without time zone,
    data_on_opendap timestamp without time zone,
    data_on_portal timestamp without time zone,
    mest_creation timestamp without time zone,
    id bigint DEFAULT nextval('hibernate_sequence'::regclass) NOT NULL
);

--
-- Data for Name: nrs_aims_manual; Type: TABLE DATA; Schema: report; Owner: postgres
--

COPY nrs_aims_manual (platform_name, deployment_start, data_on_staging, data_on_opendap, data_on_portal, mest_creation, id) FROM stdin;
Darwin	\N	\N	\N	\N	\N	664
Yongala	\N	\N	\N	\N	\N	665
\.



--
-- nrs_aims_manual_pkey; Type: CONSTRAINT; Schema: report; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY nrs_aims_manual
    ADD CONSTRAINT nrs_aims_manual_pkey PRIMARY KEY (platform_name);



