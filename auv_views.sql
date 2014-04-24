SET search_path = report_test, pg_catalog, public;

CREATE or replace VIEW auv_all_deployments_view AS
  SELECT "substring"((auv_manual.campaign_code), '[^0-9]+') AS location, 
	auv_manual.campaign_code AS campaign, 
	auv.site, 
	auv_tracks.number_of_images AS no_images, 
	round(((auv_tracks.distance)::numeric / (1000)::numeric), 1) AS distance, 
	round((auv_tracks.geospatial_lat_min)::numeric, 1) AS lat_min, 
	round((auv_tracks.geospatial_lon_min)::numeric, 1) AS lon_min, 
	COALESCE(round((auv_tracks.geospatial_vertical_min)::numeric, 1) || '/' || round((auv_tracks.geospatial_vertical_max)::numeric, 1)) AS depth_range, 
	date(auv_tracks.time_coverage_start) AS start_date, 
	((date_part('hours', (auv_tracks.time_coverage_end - auv_tracks.time_coverage_start)) * (60)::double precision) + ((date_part('minutes', (auv_tracks.time_coverage_end - auv_tracks.time_coverage_start)))::integer)::double precision) AS coverage_duration, 
	(date_part('day', (auv_manual.data_on_staging - auv_tracks.time_coverage_end)))::integer AS days_to_process_and_upload, 
	(date_part('day', (auv_manual.data_on_portal - auv_manual.data_on_staging)))::integer AS days_to_make_public, 
	CASE WHEN auv.site IS NULL OR 
		auv_manual.campaign_code IS NULL OR 
		date_part('hours', (auv_tracks.time_coverage_end - auv_tracks.time_coverage_start)) IS NULL OR 
		auv.metadata_campaign IS NULL OR 
		(auv_report.portal_visibility) <> 'Yes' OR 
		(auv_report.viewer_visibility) <> 'Yes' OR 
		(auv_report.geotiff) <> 'ALL_IMAGES' OR 
		(auv_report.mesh) <> 'Yes' OR 
		(auv_report.multibeam) <> 'Yes' OR 
		(auv_report.nc_cdom) <> 'Yes' OR 
		(auv_report.nc_cphl) <> 'Yes' OR 
		(auv_report.nc_opbs) <> 'Yes' OR 
		(auv_report.nc_psal) <> 'Yes' OR 
		(auv_report.nc_temp) <> 'Yes' OR 
		"substring"((auv_report.dive_track_csv_kml), 'Yes') <> 'Yes' OR 
		(auv_report.dive_report) <> 'Yes' OR 
		(auv_report.data_archived) <> 'Yes' THEN 'Missing information' 
		ELSE NULL END AS missing_info, 
	auv.metadata_campaign, auv.site_code, 
	round((auv_tracks.geospatial_lat_max)::numeric, 1) AS lat_max, 
	round((auv_tracks.geospatial_lon_max)::numeric, 1) AS lon_max, 
	round((auv_tracks.geospatial_vertical_min)::numeric, 1) AS min_depth, 
	round((auv_tracks.geospatial_vertical_max)::numeric, 1) AS max_depth, 
	date(auv_tracks.time_coverage_end) AS end_date, 
	date(auv_manual.data_on_staging) AS date_on_staging, 
	date(auv_manual.data_on_opendap) AS date_on_opendap, 
	date(auv_manual.data_on_portal) AS date_on_portal, 
	auv_report.portal_visibility, 
	auv_report.viewer_visibility, 
	auv_report.geotiff, 
	auv_report.mesh, 
	auv_report.nc_cdom, 
	auv_report.nc_cphl, 
	auv_report.nc_opbs, 
	auv_report.nc_psal, 
	auv_report.nc_temp, 
	auv_report.dive_track_csv_kml, 
	auv_report.dive_report, 
	auv_report.data_archived 
  FROM legacy_auv.auv 
  LEFT JOIN legacy_auv.auv_tracks ON auv_tracks.site_code = auv.site_code 
  LEFT JOIN report.auv_manual ON auv_manual.campaign_code = auv.campaign 
  LEFT JOIN legacy_auv.auv_report ON auv.site_code = auv_report.site_code AND auv.campaign = auv_report.campaign_code 
	WHERE auv_manual.campaign_code IS NOT NULL OR auv.site IS NOT NULL OR auv_report.site_code IS NOT NULL 
	ORDER BY location, campaign, auv.site;

grant all on table auv_all_deployments_view to public;


-- has data

CREATE or replace VIEW auv_data_summary_view AS
    SELECT auv_all_deployments_view.location, count(DISTINCT CASE WHEN (auv_all_deployments_view.campaign IS NULL) THEN '1'::character varying ELSE auv_all_deployments_view.campaign END) AS no_campaigns, count(DISTINCT CASE WHEN (auv_all_deployments_view.site IS NULL) THEN '1'::character varying ELSE auv_all_deployments_view.site END) AS no_sites, count(CASE WHEN (auv_all_deployments_view.site IS NULL) THEN '1'::character varying ELSE auv_all_deployments_view.site END) AS no_deployments, sum(auv_all_deployments_view.no_images) AS total_no_images, sum(auv_all_deployments_view.distance) AS total_distance, COALESCE(((min(auv_all_deployments_view.lat_min) || '/'::text) || max(auv_all_deployments_view.lat_max))) AS lat_range, COALESCE(((min(auv_all_deployments_view.lon_min) || '/'::text) || max(auv_all_deployments_view.lon_max))) AS lon_range, COALESCE(((min(auv_all_deployments_view.min_depth) || '/'::text) || max(auv_all_deployments_view.max_depth))) AS depth_range, min(auv_all_deployments_view.start_date) AS earliest_date, max(auv_all_deployments_view.end_date) AS latest_date, round((sum((auv_all_deployments_view.coverage_duration)::numeric) / (60)::numeric), 1) AS data_duration, round(avg(auv_all_deployments_view.days_to_process_and_upload), 1) AS mean_days_to_process_and_upload, round(avg(auv_all_deployments_view.days_to_make_public), 1) AS mean_days_to_make_public, sum(CASE WHEN (auv_all_deployments_view.missing_info IS NOT NULL) THEN 1 ELSE 0 END) AS missing_info, min(auv_all_deployments_view.lat_min) AS lat_min, min(auv_all_deployments_view.lon_min) AS lon_min, max(auv_all_deployments_view.lat_max) AS lat_max, max(auv_all_deployments_view.lon_max) AS lon_max, min(auv_all_deployments_view.min_depth) AS min_depth, max(auv_all_deployments_view.max_depth) AS max_depth FROM auv_all_deployments_view GROUP BY auv_all_deployments_view.location ORDER BY auv_all_deployments_view.location;

grant all on table auv_data_summary_view to public;