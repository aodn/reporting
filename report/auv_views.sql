SET search_path = report_test, pg_catalog, public;

CREATE or replace VIEW auv_all_deployments_view AS
WITH a AS (
  SELECT fk_auv_tracks,
	COUNT(li.pkid) AS no_images
  FROM legacy_auv.auv_images li
  GROUP BY fk_auv_tracks)
  SELECT DISTINCT "substring"((d.campaign_name), '[^0-9]+') AS location, 
	d.campaign_name AS campaign, 
	v.dive_name AS site,
	round(ST_Y(ST_CENTROID(v.geom))::numeric, 1) AS lat_min, 
	round(ST_X(ST_CENTROID(v.geom))::numeric, 1) AS lon_min, 
	v.time_start AS start_date,
	v.time_end AS end_date,
	((date_part('hours', (v.time_end - v.time_start)) * (60)::double precision) + ((date_part('minutes', (v.time_end - v.time_start)))::integer)::double precision) AS coverage_duration,
	a.no_images
  FROM auv.deployments d
  LEFT JOIN auv.auv_trajectory_map v ON v.file_id = d.file_id
  LEFT JOIN legacy_auv.auv_tracks lt ON v.dive_name = lt.site_code
  LEFT JOIN a ON lt.pkid = a.fk_auv_tracks
	ORDER BY location, campaign, site;

grant all on table auv_all_deployments_view to public;

CREATE or replace VIEW auv_data_summary_view AS
  SELECT v.location, 
	count(DISTINCT CASE WHEN v.campaign IS NULL THEN '1' ELSE v.campaign END) AS no_campaigns, 
	count(DISTINCT CASE WHEN v.site IS NULL THEN '1' ELSE v.site END) AS no_sites,
	SUM(no_images) AS total_no_images,
	COALESCE(min(v.lat_min) || '/' || max(v.lat_min)) AS lat_range, 
	COALESCE(min(v.lon_min) || '/' || max(v.lon_min)) AS lon_range, 
	min(v.start_date) AS earliest_date, 
	max(v.end_date) AS latest_date, 
	round((sum((v.coverage_duration)::numeric) / 60), 1) AS data_duration, 
	min(v.lat_min) AS lat_min, 
	min(v.lon_min) AS lon_min, 
	max(v.lat_min) AS lat_max, 
	max(v.lon_min) AS lon_max
  FROM auv_all_deployments_view v
	GROUP BY location
	ORDER BY location;

grant all on table auv_data_summary_view to public;