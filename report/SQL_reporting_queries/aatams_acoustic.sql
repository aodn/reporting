SET search_path = reporting, public;
DROP VIEW IF EXISTS aatams_acoustic_project_all_deployments_view CASCADE;
DROP VIEW IF EXISTS aatams_acoustic_project_data_summary_view CASCADE;
DROP VIEW IF EXISTS aatams_acoustic_embargo_totals_view CASCADE;
DROP VIEW IF EXISTS aatams_acoustic_registered_totals_view CASCADE;
DROP VIEW IF EXISTS aatams_acoustic_stats_view CASCADE;
DROP VIEW IF EXISTS aatams_acoustic_species_all_deployments_view CASCADE;
DROP VIEW IF EXISTS aatams_acoustic_species_data_summary_view CASCADE;
DROP VIEW IF EXISTS aatams_acoustic_project_totals_view CASCADE;

-- Create all views in reporting schema
CREATE OR REPLACE VIEW aatams_acoustic_species_all_deployments_view AS SELECT * FROM aatams_acoustic_reporting.aatams_acoustic_species_all_deployments_view;
CREATE OR REPLACE VIEW aatams_acoustic_species_data_summary_view AS 
SELECT registered, 
CASE WHEN common_name = '[a devilray]' THEN 'Devil Ray' WHEN
	common_name = '[a temperate bass]' THEN 'Temperate Bass' WHEN
	common_name = '[a whaler shark]' THEN 'Whaler Shark' WHEN
	common_name = '[a wobbegong ]' THEN 'Wobbegong' ELSE common_name END AS common_name, 
no_transmitters, no_releases, no_releases_with_location, no_embargo, no_protected, latest_embargo_date, total_no_detections, no_detections_public, earliest_detection, latest_detection, no_data_days
 FROM aatams_acoustic_reporting.aatams_acoustic_species_data_summary_view
 ORDER BY registered, common_name;
CREATE OR REPLACE VIEW aatams_acoustic_embargo_totals_view AS SELECT * FROM aatams_acoustic_reporting.aatams_acoustic_embargo_totals_view;
CREATE OR REPLACE VIEW aatams_acoustic_registered_totals_view AS SELECT * FROM aatams_acoustic_reporting.aatams_acoustic_registered_totals_view;
CREATE OR REPLACE VIEW aatams_acoustic_stats_view AS SELECT * FROM aatams_acoustic_reporting.aatams_acoustic_stats_view;
CREATE OR REPLACE VIEW aatams_acoustic_project_all_deployments_view AS SELECT * FROM aatams_acoustic_reporting.aatams_acoustic_project_all_deployments_view ORDER BY project_name, installation_name, station_name;
CREATE OR REPLACE VIEW aatams_acoustic_project_data_summary_view AS SELECT * FROM aatams_acoustic_reporting.aatams_acoustic_project_data_summary_view;
CREATE OR REPLACE VIEW aatams_acoustic_project_totals_view AS SELECT * FROM aatams_acoustic_reporting.aatams_acoustic_project_totals_view;

grant all on table aatams_acoustic_species_all_deployments_view to public;
grant all on table aatams_acoustic_species_data_summary_view to public;
grant all on table aatams_acoustic_embargo_totals_view to public;
grant all on table aatams_acoustic_registered_totals_view to public;
grant all on table aatams_acoustic_stats_view to public;
grant all on table aatams_acoustic_project_all_deployments_view to public;
grant all on table aatams_acoustic_project_data_summary_view to public;
grant all on table aatams_acoustic_project_totals_view to public;

-- ALTER VIEW aatams_acoustic_species_all_deployments_view OWNER TO harvest_reporting_write_group;
-- ALTER VIEW aatams_acoustic_species_data_summary_view OWNER TO harvest_reporting_write_group;
-- ALTER VIEW aatams_acoustic_embargo_totals_view OWNER TO harvest_reporting_write_group;
-- ALTER VIEW aatams_acoustic_registered_totals_view OWNER TO harvest_reporting_write_group;
-- ALTER VIEW aatams_acoustic_stats_view OWNER TO harvest_reporting_write_group;
-- ALTER VIEW aatams_acoustic_project_all_deployments_view OWNER TO harvest_reporting_write_group;
-- ALTER VIEW aatams_acoustic_project_data_summary_view OWNER TO harvest_reporting_write_group;
-- ALTER VIEW aatams_acoustic_project_totals_view OWNER TO harvest_reporting_write_group;