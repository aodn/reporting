SET search_path = reporting, public;
DROP VIEW IF EXISTS aatams_biologging_all_deployments_view CASCADE;
-------------------------------
-- VIEWS FOR AATAMS_BIOLOGGING_PENGUIN AND AATAMS_BIOLOGGING_SHEARWATERS
-------------------------------
-- All deployments view
CREATE OR REPLACE VIEW aatams_biologging_all_deployments_view AS 
  SELECT 'Emperor Penguin Fledglings' AS tagged_animals,
	pttid AS animal_id,
	no_observations AS nb_locations,
	observation_start_date AS start_date,
	observation_end_date AS end_date,
	round(date_part('days', observation_end_date - observation_start_date)::numeric + (date_part('hours', observation_end_date - observation_start_date)::numeric)/24, 1) AS coverage_duration,
	COALESCE(round(ST_YMIN(geom)::numeric, 1) || '/' || round(ST_YMAX(geom)::numeric, 1)) AS lat_range,
	COALESCE(round(ST_XMIN(geom)::numeric, 1) || '/' || round(ST_XMAX(geom)::numeric, 1)) AS lon_range,
	round(ST_YMIN(geom)::numeric, 1) AS min_lat,
	round(ST_YMAX(geom)::numeric, 1) AS max_lat,
	round(ST_XMIN(geom)::numeric, 1) AS min_lon,
	round(ST_XMAX(geom)::numeric, 1) AS max_lon
  FROM aatams_biologging_penguin.aatams_biologging_penguin_map pm

UNION ALL

  SELECT 'Snow petrels' AS tagged_animals,
	animal_id,
	no_observations AS nb_locations,
	start_date AS start_date,
	end_date AS end_date,
	round(date_part('days', end_date - start_date)::numeric + (date_part('hours', end_date - start_date)::numeric)/24, 1) AS coverage_duration,
	COALESCE(round(ST_YMIN(geom)::numeric, 1) || '/' || round(ST_YMAX(geom)::numeric, 1)) AS lat_range,
	COALESCE(round(ST_XMIN(geom)::numeric, 1) || '/' || round(ST_XMAX(geom)::numeric, 1)) AS lon_range,
	round(ST_YMIN(geom)::numeric, 1) AS min_lat,
	round(ST_YMAX(geom)::numeric, 1) AS max_lat,
	round(ST_XMIN(geom)::numeric, 1) AS min_lon,
	round(ST_XMAX(geom)::numeric, 1) AS max_lon
  FROM aatams_biologging_snowpetrel.aatams_biologging_snowpetrel_map pm

UNION ALL

  SELECT 'Short-tailed shearwaters' AS tagged_animals, 
	animal_id,
	no_observations AS nb_locations,
	start_date,
	end_date,
	round(date_part('days', end_date - start_date)::numeric + (date_part('hours', end_date - start_date)::numeric)/24, 1) AS coverage_duration,
	COALESCE(round(ST_YMIN(geom)::numeric, 1) || '/' || round(ST_YMAX(geom)::numeric, 1)) AS lat_range,
	COALESCE(round(ST_XMIN(geom)::numeric, 1) || '/' || round(ST_XMAX(geom)::numeric, 1)) AS lon_range,
	round(ST_YMIN(geom)::numeric, 1) AS min_lat,
	round(ST_YMAX(geom)::numeric, 1) AS max_lat,
	round(ST_XMIN(geom)::numeric, 1) AS min_lon,
	round(ST_XMAX(geom)::numeric, 1) AS max_lon
  FROM aatams_biologging_shearwater.aatams_biologging_shearwater_map sm
	ORDER BY tagged_animals, animal_id, start_date;

grant all on table aatams_biologging_all_deployments_view to public;

-- Data summary view
CREATE OR REPLACE VIEW aatams_biologging_data_summary_view AS
  SELECT tagged_animals,
	COUNT(DISTINCT(animal_id)) AS nb_animals,
	SUM(nb_locations) AS total_nb_locations,
	COALESCE(to_char(min(start_date),'DD/MM/YYYY') || ' - ' || to_char(max(end_date),'DD/MM/YYYY')) AS temporal_range,
	round(AVG(coverage_duration),1) AS mean_coverage_duration,
	round(min(v.coverage_duration), 1) || ' - ' || round(max(v.coverage_duration), 1) AS no_data_days, -- Range in number of data days
	COALESCE(round(min(min_lat)::numeric, 1) || '/' || round(max(max_lat)::numeric, 1)) AS lat_range,
	COALESCE(round(min(min_lon)::numeric, 1) || '/' || round(max(max_lon)::numeric, 1)) AS lon_range,
	min(start_date) AS earliest_date,
	max(end_date) AS latest_date,
	round(min(min_lat)::numeric, 1) AS min_lat,
	round(max(max_lat)::numeric, 1) AS max_lat,
	round(min(min_lon)::numeric, 1) AS min_lon,
	round(max(max_lon)::numeric, 1) AS max_lon
  FROM aatams_biologging_all_deployments_view v
	GROUP BY tagged_animals
	ORDER BY tagged_animals;

grant all on table aatams_biologging_data_summary_view to public;