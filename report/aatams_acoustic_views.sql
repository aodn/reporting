SET SEARCH_PATH = report_test, public;

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