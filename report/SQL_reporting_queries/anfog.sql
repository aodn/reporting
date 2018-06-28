SET search_path = reporting, public;
DROP TABLE IF EXISTS anfog_all_deployments_view CASCADE;

-------------------------------
-- VIEW FOR ANFOG; The legacy_anfog schema and report.anfog_manual table are not being used anymore.
-------------------------------
-- All deployments view
CREATE TABLE anfog_all_deployments_view AS
WITH rt AS (SELECT deployment_name, COUNT(*) AS no_measurements FROM anfog_rt.anfog_rt_trajectory_data GROUP BY deployment_name),
dm AS (SELECT deployment_name, COUNT(*) AS no_measurements FROM anfog_dm.anfog_dm_trajectory_data GROUP BY deployment_name)
  SELECT 'Near real-time data' AS data_type,
	 mrt.platform_type AS glider_type, 
	 mrt.platform_code AS platform, 
	 mrt.deployment_name AS deployment_id,
	 CASE WHEN substring(mrt.deployment_name, '[aA-zZ]+') = 'PortStephens_' THEN 'PortStephens' 
		WHEN substring(mrt.deployment_name, '[aA-zZ]+') = 'Tworocks' THEN 'TwoRocks'
		ELSE substring(mrt.deployment_name, '[aA-zZ]+') END AS deployment_location,
	 CASE WHEN substring(mrt.deployment_name, '[aA-zZ]+') IN ('Bicheno','MariaIsland','SOTS','StormBay','Portland','BassStrait') THEN 'SEA IMOS'
		WHEN substring(mrt.deployment_name, '[aA-zZ]+') IN ('Coffs','CrowdyHead','Harrington','NSW','PortStephens','PortStephens_','Sydney','Yamba','Forster','JervisBay') THEN 'NSW'
		WHEN substring(mrt.deployment_name, '[aA-zZ]+') IN ('CoralSea','Heron','Lizard','LizardIsland','AIMS','Cairns','CharlotteBay','Cooktown','GBR','Brisbane') THEN 'QLD'
		WHEN substring(mrt.deployment_name, '[aA-zZ]+') IN ('GAB','MarionBay','SpencerGulf') THEN 'SA'
		WHEN substring(mrt.deployment_name, '[aA-zZ]+') IN ('TwoRocks','Tworocks', 'Kalbarri', 'Kimberley', 'Pilbara', 'Perth','PerthCanyon','Perth Canyon', 'Bremer','Leeuwin','Ningaloo','Challenger') THEN 'WA' END AS deployment_state,
	 rt.no_measurements,
	 min(date(mrt.time_coverage_start)) AS start_date, 
	 max(date(mrt.time_coverage_end)) AS end_date,
 	 min(round((ST_YMIN(geom))::numeric, 1)) AS min_lat,
 	 max(round((ST_YMAX(geom))::numeric, 1)) AS max_lat,
 	 min(round((ST_XMIN(geom))::numeric, 1)) AS min_lon,
 	 max(round((ST_XMAX(geom))::numeric, 1)) AS max_lon,
 	COALESCE(min(round((ST_YMIN(geom))::numeric, 1)) || '/' || max(round((ST_YMAX(geom))::numeric, 1))) AS lat_range,
 	COALESCE(min(round((ST_XMIN(geom))::numeric, 1)) || '/' || max(round((ST_XMAX(geom))::numeric, 1))) AS lon_range,
 	round(max(drt.geospatial_vertical_max)::numeric, 1) AS max_depth, 
 	round((date_part('days', max(mrt.time_coverage_end) - min(mrt.time_coverage_start)) + 
 	date_part('hours', max(mrt.time_coverage_end) - min(mrt.time_coverage_start))/24)::numeric, 1) AS coverage_duration
  FROM anfog_rt.anfog_rt_trajectory_map mrt
  RIGHT JOIN anfog_rt.deployments drt ON mrt.file_id = drt.file_id
  LEFT JOIN rt ON rt.deployment_name = mrt.deployment_name
	GROUP BY mrt.platform_type, mrt.platform_code, mrt.deployment_name, rt.no_measurements

UNION ALL

  SELECT 'Delayed mode data' AS data_type,
	 m.platform_type AS glider_type, 
	 m.platform_code AS platform, 
	 m.deployment_name AS deployment_id,
	 CASE WHEN substring(m.deployment_name, '[aA-zZ]+') = 'PortStephens_' THEN 'PortStephens' 
		WHEN substring(m.deployment_name, '[aA-zZ]+') = 'Tworocks' THEN 'TwoRocks'
		ELSE substring(m.deployment_name, '[aA-zZ]+') END AS deployment_location,
	 CASE WHEN substring(m.deployment_name, '[aA-zZ]+') IN ('Bicheno','MariaIsland','SOTS','StormBay','Portland','BassStrait') THEN 'SEA IMOS'
		WHEN substring(m.deployment_name, '[aA-zZ]+') IN ('Coffs','CrowdyHead','Harrington','NSW','PortStephens','PortStephens_','Sydney','Yamba','Forster','JervisBay') THEN 'NSW'
		WHEN substring(m.deployment_name, '[aA-zZ]+') IN ('CoralSea','Heron','Lizard','LizardIsland','AIMS','Cairns','CharlotteBay','Cooktown','GBR','Brisbane') THEN 'QLD'
		WHEN substring(m.deployment_name, '[aA-zZ]+') IN ('GAB','MarionBay','SpencerGulf') THEN 'SA'
		WHEN substring(m.deployment_name, '[aA-zZ]+') IN ('TwoRocks','Tworocks', 'Kalbarri', 'Kimberley', 'Pilbara', 'Perth','PerthCanyon','Perth Canyon', 'Bremer','Leeuwin','Ningaloo','Challenger') THEN 'WA' END AS deployment_state,
	 dm.no_measurements,
	 date(m.time_coverage_start) AS start_date, 
	 date(m.time_coverage_end) AS end_date,
 	 round((ST_YMIN(geom))::numeric, 1) AS min_lat,
 	 round((ST_YMAX(geom))::numeric, 1) AS max_lat,
 	 round((ST_XMIN(geom))::numeric, 1) AS min_lon,
 	 round((ST_XMAX(geom))::numeric, 1) AS max_lon,
 	COALESCE(round((ST_YMIN(geom))::numeric, 1) || '/' || round((ST_YMAX(geom))::numeric, 1)) AS lat_range,
 	COALESCE(round((ST_XMIN(geom))::numeric, 1) || '/' || round((ST_XMAX(geom))::numeric, 1)) AS lon_range,
 	round(d.geospatial_vertical_max::numeric, 1) AS max_depth, 
 	round((date_part('days', max(m.time_coverage_end) - min(m.time_coverage_start)) + 
 	date_part('hours', max(m.time_coverage_end) - min(m.time_coverage_start))/24)::numeric, 1) AS coverage_duration
  FROM anfog_dm.anfog_dm_trajectory_map m
  RIGHT JOIN anfog_dm.deployments d ON m.file_id = d.file_id
  LEFT JOIN dm ON dm.deployment_name = m.deployment_name
	GROUP BY m.platform_type, m.platform_code, m.deployment_name, m.time_coverage_start, m.time_coverage_end, m.geom, d.geospatial_vertical_max, dm.no_measurements
	ORDER BY data_type, deployment_state, deployment_location, deployment_id;

grant all on table anfog_all_deployments_view to public;

-- Data summary view
CREATE or replace VIEW anfog_data_summary_view AS
  SELECT v.data_type,
	v.deployment_state,
	v.deployment_location,
	SUM(CASE WHEN v.glider_type = 'slocum glider' THEN 1 ELSE 0 END) AS no_slocum_deployments,
	SUM(CASE WHEN v.glider_type = 'seaglider' THEN 1 ELSE 0 END) AS no_seaglider_deployments, 
	count(DISTINCT v.platform) AS no_platforms, 
	count(DISTINCT COALESCE (v.platform || '-' || v.deployment_id)) AS no_deployments,
	SUM(no_measurements) AS no_measurements,
	min(v.start_date) AS earliest_date, 
	max(v.end_date) AS latest_date, 
	COALESCE(min(v.min_lat) || '/' || max(v.max_lat)) AS lat_range, 
	COALESCE(min(v.min_lon) || '/' || max(v.max_lon)) AS lon_range, 
	COALESCE(min(v.max_depth) || '/' || max(v.max_depth)) AS depth_range, 
	round(avg(v.coverage_duration), 1) AS mean_coverage_duration,
	round(min(v.coverage_duration), 1) || ' - ' || round(max(v.coverage_duration), 1) AS no_data_days,
	min(v.min_lat) AS min_lat, 
	max(v.max_lat) AS max_lat, 
	min(v.min_lon) AS min_lon, 
	max(v.max_lon) AS max_lon, 
	min(v.max_depth) AS min_depth, 
	max(v.max_depth) AS max_depth 
  FROM anfog_all_deployments_view v
	GROUP BY data_type, deployment_state, deployment_location
	ORDER BY data_type, deployment_state, deployment_location;

grant all on table anfog_data_summary_view to public;
