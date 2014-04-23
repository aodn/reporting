SET search_path = report_test, pg_catalog, public;

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