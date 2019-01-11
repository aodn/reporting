SET search_path = reporting, public;
DROP VIEW IF EXISTS anmn_acoustics_all_deployments_view CASCADE;

-------------------------------
-- VIEW FOR ANMN Acoustics
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
  FROM anmn_acoustics.acoustic_deployments m
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

-- ALTER VIEW anmn_acoustics_all_deployments_view OWNER TO harvest_reporting_write_group;
-- ALTER VIEW anmn_acoustics_data_summary_view OWNER TO harvest_reporting_write_group;