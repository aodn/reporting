﻿SET search_path = report_test, public;

CREATE or replace VIEW anfog_all_deployments_view AS
  SELECT 'Near real-time data' AS data_type,
	 mrt.platform_type AS glider_type, 
	 mrt.platform_code AS platform, 
	 mrt.deployment_name AS deployment_id, 
	 min(date(mrt.time_coverage_start)) AS start_date, 
	 max(date(mrt.time_coverage_end)) AS end_date,
 	 min(round((ST_YMIN(geom))::numeric, 1)) AS min_lat,
 	 max(round((ST_YMAX(geom))::numeric, 1)) AS max_lat,
 	 min(round((ST_XMIN(geom))::numeric, 1)) AS min_lon,
 	 max(round((ST_XMAX(geom))::numeric, 1)) AS max_lon,
 	COALESCE(min(round((ST_YMIN(geom))::numeric, 1)) || '/' || max(round((ST_YMAX(geom))::numeric, 1))) AS lat_range,
 	COALESCE(min(round((ST_XMIN(geom))::numeric, 1)) || '/' || max(round((ST_XMAX(geom))::numeric, 1))) AS lon_range,
 	round(max(drt.geospatial_vertical_max)::numeric, 1) AS max_depth, 
	max(date(mrt.time_coverage_end)) - min(date(mrt.time_coverage_start)) AS coverage_duration 
  FROM anfog_rt.anfog_rt_trajectory_map mrt
  RIGHT JOIN anfog_dm.deployments drt ON mrt.file_id = drt.file_id
	GROUP BY mrt.platform_type, mrt.platform_code, mrt.deployment_name

UNION ALL

  SELECT 'Delayed mode data' AS data_type,
	 m.platform_type AS glider_type, 
	 m.platform_code AS platform, 
	 m.deployment_name AS deployment_id, 
	 date(m.time_coverage_start) AS start_date, 
	 date(m.time_coverage_end) AS end_date,
 	 round((ST_YMIN(geom))::numeric, 1) AS min_lat,
 	 round((ST_YMAX(geom))::numeric, 1) AS max_lat,
 	 round((ST_XMIN(geom))::numeric, 1) AS min_lon,
 	 round((ST_XMAX(geom))::numeric, 1) AS max_lon,
 	COALESCE(round((ST_YMIN(geom))::numeric, 1) || '/' || round((ST_YMAX(geom))::numeric, 1)) AS lat_range,
 	COALESCE(round((ST_XMIN(geom))::numeric, 1) || '/' || round((ST_XMAX(geom))::numeric, 1)) AS lon_range,
 	round(d.geospatial_vertical_max::numeric, 1) AS max_depth, 
	date(m.time_coverage_end) - date(m.time_coverage_start) AS coverage_duration 
  FROM anfog_dm.anfog_dm_trajectory_map m
  RIGHT JOIN anfog_dm.deployments d ON m.file_id = d.file_id
	GROUP BY m.platform_type, m.platform_code, m.deployment_name, m.time_coverage_start, m.time_coverage_end, m.geom, d.geospatial_vertical_max
	ORDER BY data_type, glider_type, platform, deployment_id;

grant all on table anfog_all_deployments_view to public;

CREATE or replace VIEW anfog_data_summary_view AS
  SELECT v.data_type,
	v.glider_type AS glider_type, 
	count(DISTINCT v.platform) AS no_platforms, 
	count(DISTINCT v.deployment_id) AS no_deployments, 
	min(v.start_date) AS earliest_date, 
	max(v.end_date) AS latest_date, 
	COALESCE(min(v.min_lat) || '/' || max(v.max_lat)) AS lat_range, 
	COALESCE(min(v.min_lon) || '/' || max(v.max_lon)) AS lon_range, 
	COALESCE(min(v.max_depth) || '/' || max(v.max_depth)) AS depth_range, 
	round(avg(v.coverage_duration), 1) AS mean_coverage_duration, 
	min(v.min_lat) AS min_lat, 
	max(v.max_lat) AS max_lat, 
	min(v.min_lon) AS min_lon, 
	max(v.max_lon) AS max_lon, 
	min(v.max_depth) AS min_depth, 
	max(v.max_depth) AS max_depth 
  FROM anfog_all_deployments_view v
	GROUP BY data_type, glider_type 
	ORDER BY data_type,glider_type;

grant all on table anfog_data_summary_view to public;