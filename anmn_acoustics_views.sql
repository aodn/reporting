SET search_path = report_test, public;

CREATE or replace VIEW anmn_acoustics_all_deployments_view AS
  SELECT COALESCE(m.deployment_name|| ' - Lat/Lon:'|| round(m.lat::numeric, 1) || '/' || round(m.lon::numeric, 1)) AS site_name, 
	"substring"((m.deployment_name), '2[-0-9]+') AS deployment_year, 
	m.logger_id, 
	bool_or((((m.set_success) !~~* '%fail%') AND (m.frequency = 6))) AS good_data, 
	bool_or((((m.set_success) !~~* '%fail%') AND (m.frequency = 22))) AS good_22, 
	bool_or((m.is_primary AND (m.data_path IS NOT NULL))) AS on_viewer, 
	round(avg((m.receiver_depth)::numeric), 1) AS depth, 
	min(date(m.time_deployment_start)) AS start_date, 
	max(date(m.time_deployment_end)) AS end_date, 
	(max(date(m.time_deployment_end)) - min(date(m.time_deployment_start))) AS coverage_duration, 
	CASE WHEN m.logger_id IS NULL OR 
		avg(date_part('year', m.time_deployment_end)) IS NULL OR 
		bool_or(m.frequency IS NULL) OR 
		bool_or(m.set_success IS NULL) OR 
		avg(m.lat) IS NULL OR 
		avg(m.lon) IS NULL OR 
		avg(m.receiver_depth) IS NULL OR 
		bool_or(m.system_gain_file IS NULL) OR 
		bool_or(m.hydrophone_sensitivity IS NULL) THEN 'Missing information from PAO sub-facility' 
		ELSE NULL END AS missing_info 
  FROM reporting.acoustic_deployments m
	GROUP BY m.deployment_name, m.lat, m.lon, m.logger_id 
	ORDER BY site_name, deployment_year, m.logger_id;

grant all on table anmn_acoustics_all_deployments_view to public;


CREATE or replace VIEW anmn_acoustics_data_summary_view AS
  SELECT v.site_name, 
	v.deployment_year, 
	count(*) AS no_loggers, 
	sum((v.good_data)::integer) AS no_good_data, 
	sum((v.on_viewer)::integer) AS no_sets_on_viewer, 
	sum((v.good_22)::integer) AS no_good_22, 
	min(v.start_date) AS earliest_date, 
	max(v.end_date) AS latest_date, 
	(max(v.end_date) - min(v.start_date)) AS coverage_duration, 
	sum(CASE WHEN ("substring"(v.missing_info, 'PAO') IS NULL) THEN 0 ELSE 1 END) AS no_missing_info_pao_subfacility, 
	sum(CASE WHEN ("substring"(v.missing_info, 'eMII') IS NULL) THEN 0 ELSE 1 END) AS no_missing_info_emii 
  FROM anmn_acoustics_all_deployments_view v
	GROUP BY v.site_name, v.deployment_year 
	ORDER BY site_name, deployment_year;

grant all on table anmn_acoustics_data_summary_view to public;