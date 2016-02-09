SET search_path = reporting, public;
DROP VIEW IF EXISTS aatams_acoustic_project_all_deployments_view CASCADE;
DROP VIEW IF EXISTS aatams_acoustic_project_data_summary_view CASCADE;
DROP VIEW IF EXISTS aatams_acoustic_embargo_totals_view CASCADE;
DROP VIEW IF EXISTS aatams_acoustic_registered_totals_view CASCADE;
DROP VIEW IF EXISTS aatams_acoustic_stats_view CASCADE;
DROP VIEW IF EXISTS aatams_acoustic_species_all_deployments_view CASCADE;
DROP VIEW IF EXISTS aatams_acoustic_species_data_summary_view CASCADE;
DROP VIEW IF EXISTS aatams_acoustic_project_totals_view CASCADE;

-------------------------------
-- VIEWS FOR AATAMS_ACOUSTIC
-------------------------------
-- aatams_acoustic_detections_data
-- SELECT DISTINCT vd.id AS detection_id,
-- 	p.name AS project_name,
-- 	i.name AS installation_name,
-- 	ist.name AS station_name,
-- 	vd.receiver_name,
-- 	rd.bottom_depthm AS bottom_depth,
-- 	sp.common_name AS common_name,
-- 	vd.transmitter_id AS transmitter_id,
-- 	ar.releasedatetime_timestamp AT TIME ZONE 'UTC' AS release_date,
-- 	ar.release_locality AS release_locality,
-- 	vd.timestamp AT TIME ZONE 'UTC' AS detection_date,
-- 	ST_X(ist.location) AS longitude,
-- 	ST_Y(ist.location) AS latitude,
-- 	sex.sex AS sex,
-- 	sp.scientific_name AS scientific_name,
-- 	ist.location AS geom,
-- 	'TRUE' AS detected
--   FROM valid_detection vd
--   LEFT JOIN receiver_deployment rd ON vd.receiver_deployment_id = rd.id
--   LEFT JOIN installation_station ist ON ist.id = rd.station_id
--   LEFT JOIN installation i ON i.id = ist.installation_id
--   LEFT JOIN project p ON p.id = i.project_id  
--   LEFT JOIN sensor on vd.transmitter_id = sensor.transmitter_id
--   LEFT JOIN device d on sensor.tag_id = d.id
--   LEFT JOIN surgery s ON s.tag_id = d.id
--   LEFT JOIN animal_release ar ON ar.id = s.release_id
--   LEFT JOIN animal a ON a.id = ar.animal_id
--   LEFT JOIN species sp ON sp.id = a.species_id 
--   LEFT JOIN sex ON a.sex_id = sex.id
-- 	WHERE date_part('day', ar.embargo_date - now()) < 0 AND p.is_protected = FALSE AND
-- 	ar.releasedatetime_timestamp AT TIME ZONE 'UTC' < vd.timestamp AT TIME ZONE 'UTC' AND
-- 	sp.common_name IS NOT NULL AND sp.scientific_name IS NOT NULL
-- 	ORDER BY transmitter_id, detection_date;

-- -- aatams_acoustic_detections_map
-- WITH a AS (
--   SELECT DISTINCT common_name
--   FROM aatams_acoustic_detections_data),
--   b AS (
--   SELECT a.common_name,
-- 	 COALESCE('#'||''||lpad(to_hex(trunc(random() * 16777215)::integer),6,'0')) AS colour
--   FROM a),
--   c AS (
--   SELECT station_name, transmitter_id,
-- 	 COUNT(DISTINCT detection_id) AS no_detections
--   FROM aatams_acoustic_detections_data
-- 	GROUP BY station_name, transmitter_id)
--   SELECT project_name,
-- 	installation_name,
-- 	d.station_name,
-- 	d.common_name,
-- 	d.transmitter_id,
-- 	release_locality,
-- 	date(min(detection_date)) AS first_detection_date,
-- 	date(max(detection_date)) AS last_detection_date,
-- 	sex,
-- 	scientific_name,
-- 	replace(ST_AsEWKT(ST_SIMPLIFY(ST_MAKELINE(geom),0.01)), 'LINESTRING','MULTIPOINT')::geometry AS geom,
-- 	b.colour AS colour,
-- 	c.no_detections,
-- 	bool_or(no_detections > 0) AS detected
--   FROM aatams_acoustic_detections_data d
--   LEFT JOIN b ON b.common_name = d.common_name
--   LEFT JOIN c ON c.station_name = d.station_name AND c.transmitter_id = d.transmitter_id
--   	GROUP BY project_name, installation_name, d.station_name, d.common_name, d.transmitter_id, release_locality, sex, scientific_name, colour, no_detections
-- UNION ALL
--   SELECT p.name AS project_name, 
-- 	i.name AS installation_name, 
-- 	ist.name AS station_name,
-- 	NULL AS common_name,
-- 	NULL AS transmitter_id,
-- 	NULL AS release_locality,
-- 	NULL AS first_detection_date,
-- 	NULL AS last_detection_date,
-- 	NULL AS sex,
-- 	NULL AS scientific_name,
-- 	ist.location AS geom,
-- 	'#FF0000' AS colour,
-- 	0 AS no_detections,
-- 	'FALSE' AS detected
--   FROM installation_station ist
--   LEFT JOIN installation i ON i.id = ist.installation_id
--   LEFT JOIN project p ON p.id = i.project_id 
-- 	WHERE ist.name NOT IN (SELECT DISTINCT station_name FROM aatams_acoustic_detections_data)
-- 	ORDER BY detected, common_name, transmitter_id, first_detection_date;

-- -- installation_summary
--   SELECT DISTINCT p.name AS project_name,
-- 	i.name AS installation_name,
-- 	ist.name AS station_name,
-- 	ist.location AS geom
--   FROM installation_station ist
--   LEFT JOIN installation i ON i.id = ist.installation_id
--   LEFT JOIN project p ON i.project_id = p.id
-- 	ORDER BY i.name;

-- -- All deployments - Species
-- WITH a AS (SELECT DISTINCT transmitter_id FROM valid_detection
--   UNION ALL 
--   SELECT DISTINCT transmitter_id FROM sensor),
--  sub AS (SELECT DISTINCT transmitter_id FROM a)
--   SELECT DISTINCT sub.transmitter_id, 
-- 	d.id AS tag_id,
-- 	su.release_id,
-- 	p.name AS project_name,
-- 	sp.common_name,
-- 	CASE WHEN d.id IS NULL THEN FALSE ELSE TRUE END AS registered,
-- 	p.is_protected AS protected,
-- 	CASE WHEN capture_location IS NULL AND release_location IS NULL THEN FALSE ELSE TRUE END AS releaselocation_info,
-- 	date(ar.embargo_date) AS embargo_date,
-- 	COUNT(vd.timestamp) AS no_detections,
-- 	date(min(vd.timestamp)) AS first_detection,
-- 	date(max(vd.timestamp)) AS last_detection,
-- 	round((date_part('days', max(vd.timestamp) - min(vd.timestamp)) + date_part('hours', max(vd.timestamp) - min(vd.timestamp))/24)::numeric, 1) AS coverage_duration
--   FROM sub
--   LEFT JOIN valid_detection vd ON sub.transmitter_id = vd.transmitter_id
--   LEFT JOIN sensor s ON s.transmitter_id = sub.transmitter_id
--   LEFT JOIN surgery su ON s.tag_id = su.tag_id
--   LEFT JOIN device d ON d.id = s.tag_id OR d.id = su.tag_id
--   LEFT JOIN animal_release ar ON ar.id = su.release_id
--   LEFT JOIN project p ON p.id = ar.project_id
--   LEFT JOIN animal a ON a.id = ar.animal_id
--   LEFT JOIN species sp ON sp.id = a.species_id
-- 	WHERE sub.transmitter_id != ''
-- 	GROUP BY sub.transmitter_id, p.name, d.id, su.release_id, ar.animal_id, sp.common_name, p.is_protected, capturedatetime_timestamp, releasedatetime_timestamp, capture_location, release_location, ar.embargo_date
-- 	ORDER BY registered, transmitter_id, common_name, tag_id, release_id;

-- -- Update aatams_acoustic_species_all_deployments_view table to flag sentinel tags
-- UPDATE aatams_acoustic_species_all_deployments_view
-- SET common_name = 'All sentinel tags'
-- WHERE transmitter_id IN ('A69-1303-54479','A69-1303-54488','A69-1303-54490','A69-1303-54480','A69-1303-54486','A69-1303-54489',
-- 'A69-1303-54483','A69-1303-54481','A69-1303-54482','A69-1303-54485','A69-1303-54487','A69-1601-31224','A69-1303-60940');

-- -- Data summary - Species 
--   SELECT CASE WHEN registered = FALSE THEN 'Unregistered tags' ELSE 'Registered tags' END AS registered,
-- 	CASE WHEN common_name IS NULL AND registered = FALSE THEN 'All unregistered tags' 
-- 		WHEN common_name IS NULL AND registered = TRUE THEN 'All registered tags with no species info'
-- 		ELSE common_name END AS common_name,
-- 	COUNT(transmitter_id) AS no_transmitters,
-- 	COUNT(release_id) AS no_releases,
-- 	SUM(CASE WHEN releaselocation_info = FALSE THEN 0 ELSE 1 END) AS no_releases_with_location,
-- 	SUM(CASE WHEN v.embargo_date > now() THEN 1 ELSE 0 END) AS no_embargo,
-- 	SUM(CASE WHEN v.is_protected = FALSE OR v.is_protected IS NULL THEN 0 ELSE 1 END) AS no_protected,
-- 	CASE WHEN SUM(CASE WHEN v.embargo_date > now() THEN 1 ELSE 0 END) = 0 THEN NULL ELSE max(v.embargo_date) END AS latest_embargo_date,
-- 	SUM(no_detections) AS total_no_detections,
-- 	SUM(CASE WHEN v.embargo_date < now() OR v.embargo_date IS NULL THEN no_detections ELSE 0 END) AS no_detections_public,
-- 	min(v.first_detection) AS earliest_detection,
-- 	max(v.last_detection) AS latest_detection,
-- 	round(min(v.coverage_duration), 1) || ' - ' || round(max(v.coverage_duration), 1) AS no_data_days
--   FROM aatams_acoustic_species_all_deployments_view v
-- 	GROUP BY v.common_name, registered
-- 	ORDER BY registered, common_name;

-- -- Totals - Embargo
-- WITH total_species AS (
--   SELECT COUNT(*) AS t,
-- 	'total no tagged species' AS statistics_type
--   FROM aatams_acoustic_species_data_summary_view
--   WHERE common_name NOT LIKE 'All %'),
  
-- total_species_public AS(
--   SELECT COUNT(*) AS t, 
-- 	'no tagged species for which all animals are public' AS statistics_type
--   FROM aatams_acoustic_species_data_summary_view
--     WHERE no_embargo = 0 AND common_name NOT LIKE 'All %'),
    
-- total_species_embargo AS (
--   SELECT COUNT(*) AS t,
-- 	'no tagged species for which some animals are currently under embargo' AS statistics_type
--   FROM aatams_acoustic_species_data_summary_view
--   WHERE no_embargo != 0 AND common_name NOT LIKE 'All %'),
-- -- ANIMAL RELEASES  
-- total_animals AS (
--   SELECT SUM (no_releases) AS t,
-- 	'total no tagged animals' AS statistics_type
--   FROM aatams_acoustic_species_data_summary_view),
  
-- total_animals_public AS (
--   SELECT SUM (no_releases) - SUM(no_embargo) AS t, 
-- 	'no tagged animals that are public' AS statistics_type
--   FROM aatams_acoustic_species_data_summary_view),

-- total_animals_embargo AS (
--   SELECT SUM(no_embargo) AS t, 
-- 	'no tagged animals currently under embargo' AS statistics_type
--   FROM aatams_acoustic_species_data_summary_view),
-- -- TAGS
-- total_tags AS (
--   SELECT SUM(no_transmitters) AS t,
-- 	'total no tags' AS statistics_type
--   FROM aatams_acoustic_species_data_summary_view),

-- total_tags_public AS (
--   SELECT SUM(no_transmitters) - SUM(no_embargo) AS t,
-- 	'no tags that are public' AS statistics_type
--   FROM aatams_acoustic_species_data_summary_view),

-- total_tags_embargo AS (
--   SELECT SUM(no_embargo) AS t, 
-- 	'no tags currently under embargo' AS statistics_type
--   FROM aatams_acoustic_species_data_summary_view),
-- -- DETECTIONS
-- total_detections AS (
--   SELECT SUM (total_no_detections) AS t,
-- 	'no detections' AS statistics_type
--   FROM aatams_acoustic_species_data_summary_view),
	
-- total_detections_public AS (
--   SELECT SUM (no_detections_public) AS t,
-- 	'no detections that are public' AS statistics_type
--   FROM aatams_acoustic_species_data_summary_view),
	
-- total_detections_embargo AS (
--   SELECT SUM (total_no_detections) - SUM (no_detections_public) AS t,
-- 	'no detections that are currently under embargo' AS statistics_type
--   FROM aatams_acoustic_species_data_summary_view),
-- -- EMBARGO
-- embargo_1 AS (
-- 	  SELECT COUNT(DISTINCT common_name) AS s,
-- 		COUNT(DISTINCT release_id) AS r,
-- 		COUNT(*) AS t,
-- 		SUM(no_detections) AS d,
-- 		'Number of tags - detections currently embargoed for less than 1 year' AS statistics_type
-- 	  FROM aatams_acoustic_species_all_deployments_view
-- 		WHERE date_part('days', embargo_date - now()) > 0 AND date_part('days', embargo_date - now()) <= 365.25 AND 
-- 		date_part('days', embargo_date - now()) IS NOT NULL),
		
-- embargo_2 AS (
-- 	  SELECT COUNT(DISTINCT common_name) AS s,
-- 		COUNT(DISTINCT release_id) AS r,
-- 		COUNT(*) AS t,
-- 		SUM(no_detections) AS d,
-- 		'Number of tags - detections currently embargoed for more than 1 year, but less than 2' AS statistics_type
-- 	  FROM aatams_acoustic_species_all_deployments_view
-- 		WHERE date_part('days', embargo_date - now()) > 365.25 AND date_part('days', embargo_date - now()) <= (2 * 365.25) AND 
-- 		date_part('days', embargo_date - now()) IS NOT NULL),
		
-- embargo_3 AS (
-- 	  SELECT COUNT(DISTINCT common_name) AS s,
-- 		COUNT(DISTINCT release_id) AS r,
-- 		COUNT(*) AS t,
-- 		SUM(no_detections) AS d,
-- 		'Number of tags - detections currently embargoed for more than 2 years, but less than 3' AS statistics_type
-- 	  FROM aatams_acoustic_species_all_deployments_view
-- 		WHERE date_part('days', embargo_date - now()) > (2 * 365.25) AND date_part('days', embargo_date - now()) <= (3 * 365.25) AND 
-- 		date_part('days', embargo_date - now()) IS NOT NULL),
		
-- embargo_3_more AS (
-- 	  SELECT COUNT(DISTINCT common_name) AS s,
-- 		COUNT(DISTINCT release_id) AS r,
-- 		COUNT(*) AS t,
-- 		SUM(no_detections) AS d,
-- 		'Number of tags - detections currently embargoed for more than three years' AS statistics_type
-- 	  FROM aatams_acoustic_species_all_deployments_view
-- 		WHERE date_part('days', embargo_date - now()) > (3 * 365.25) AND date_part('days', embargo_date - now()) IS NOT NULL)
--   SELECT 'Species' AS type, 
-- 	s.t AS total, 
-- 	sp.t AS total_public,
-- 	se.t AS total_embargo,
-- 	e1.s AS embargo_1,
-- 	e2.s AS embargo_2,
-- 	e3.s AS embargo_3,
-- 	e3m.s AS embargo_3_more
--   FROM total_species s, total_species_public sp,total_species_embargo se,embargo_1 e1,embargo_2 e2, embargo_3 e3, embargo_3_more e3m
-- UNION ALL
--   SELECT 'Animals' AS type, 
-- 	a.t AS total, 
-- 	ap.t AS total_public,
-- 	ae.t AS total_embargo,
-- 	e1.r AS embargo_1,
-- 	e2.r AS embargo_2,
-- 	e3.r AS embargo_3,
-- 	e3m.r AS embargo_3_more
--   FROM total_animals a, total_animals_public ap,total_animals_embargo ae,embargo_1 e1,embargo_2 e2, embargo_3 e3, embargo_3_more e3m
-- UNION ALL
--   SELECT 'Tags' AS type, 
-- 	tr.t AS total, 
-- 	trp.t AS total_public,
-- 	tre.t AS total_embargo,
-- 	e1.t AS embargo_1,
-- 	e2.t AS embargo_2,
-- 	e3.t AS embargo_3,
-- 	e3m.t AS embargo_3_more
--   FROM total_tags tr, total_tags_public trp,total_tags_embargo tre,embargo_1 e1,embargo_2 e2, embargo_3 e3, embargo_3_more e3m
-- UNION ALL
--   SELECT 'Detections' AS type, 
-- 	d.t AS total, 
-- 	dp.t AS total_public,
-- 	de.t AS total_embargo,
-- 	e1.d AS embargo_1,
-- 	e2.d AS embargo_2,
-- 	e3.d AS embargo_3,
-- 	e3m.d AS embargo_3_more
--   FROM total_detections d, total_detections_public dp, total_detections_embargo de,embargo_1 e1,embargo_2 e2, embargo_3 e3, embargo_3_more e3m;

-- -- Totals - Registered vs. Unregistered
-- WITH zero AS (
--   SELECT CASE WHEN registered = FALSE THEN 'Unregistered tags' ELSE 'Registered tags' END AS registered, COUNT(transmitter_id) AS no_transmitters, SUM(no_detections) AS no_detections
--   FROM aatams_acoustic_species_all_deployments_view
--   WHERE no_detections = 0
-- 	GROUP BY registered),
-- one AS (
--   SELECT CASE WHEN registered = FALSE THEN 'Unregistered tags' ELSE 'Registered tags' END AS registered, COUNT(transmitter_id) AS no_transmitters, SUM(no_detections) AS no_detections
--   FROM aatams_acoustic_species_all_deployments_view
--   WHERE no_detections = 1
-- 	GROUP BY registered),
-- morethanone AS (
--   SELECT CASE WHEN registered = FALSE THEN 'Unregistered tags' ELSE 'Registered tags' END AS registered, COUNT(transmitter_id) AS no_transmitters, SUM(no_detections) AS no_detections
--   FROM aatams_acoustic_species_all_deployments_view
--   WHERE no_detections > 1
-- 	GROUP BY registered),
-- subtotal AS (
--   SELECT CASE WHEN registered = FALSE THEN 'Unregistered tags' ELSE 'Registered tags' END AS registered, COUNT(transmitter_id) AS no_transmitters, SUM(no_detections) AS no_detections
--   FROM aatams_acoustic_species_all_deployments_view
-- 	GROUP BY registered),
-- total AS (
--   SELECT COUNT(transmitter_id) AS no_transmitters, SUM(no_detections) AS no_detections
--   FROM aatams_acoustic_species_all_deployments_view)
--   SELECT registered, '0' AS no_times_detected, no_transmitters, no_detections FROM zero
-- UNION ALL
--   SELECT registered, '1' AS no_times_detected, no_transmitters, no_detections FROM one WHERE registered = 'Registered tags'
-- UNION ALL
--   SELECT registered, '> 1' AS no_times_detected, no_transmitters, no_detections FROM morethanone WHERE registered = 'Registered tags'
-- UNION ALL
--   SELECT registered, 'Subtotal' AS no_times_detected, no_transmitters, no_detections FROM subtotal WHERE registered = 'Registered tags'
-- UNION ALL
--   SELECT registered, '1' AS no_times_detected, no_transmitters, no_detections FROM one WHERE registered = 'Unregistered tags'
-- UNION ALL
--   SELECT registered, '> 1' AS no_times_detected, no_transmitters, no_detections FROM morethanone WHERE registered = 'Unregistered tags'
-- UNION ALL
--   SELECT registered, 'Subtotal' AS no_times_detected, no_transmitters, no_detections FROM subtotal WHERE registered = 'Unregistered tags'
-- UNION ALL
--   SELECT NULL AS registered, 'Total' AS no_times_detected, no_transmitters, no_detections FROM total;

-- -- Totals - Other stats
-- WITH total_detections_registered_public AS (
-- 	  SELECT SUM (no_detections_public) AS t,
-- 		'no detections for registered tags that are public' AS statistics_type
-- 	  FROM aatams_acoustic_species_data_summary_view
-- 		WHERE registered = 'Registered tags'),
		
-- total_detections_species AS (
-- 	  SELECT SUM (total_no_detections) AS t,
-- 		'no detections at species level' AS statistics_type
-- 	  FROM aatams_acoustic_species_data_summary_view
-- 		WHERE common_name NOT LIKE 'All %'),

-- total_detections_species_public AS (
-- 	  SELECT SUM (no_detections_public) AS t,
-- 		'no public detections at species level' AS statistics_type
-- 	  FROM aatams_acoustic_species_data_summary_view
-- 		WHERE common_name NOT LIKE 'All %'),
-- -- OTHER TOTALS
-- tag_ids AS (
-- 	  SELECT COUNT(DISTINCT transmitter_id) AS t,
-- 		'no unique tag ids detected' AS statistics_type
-- 	  FROM valid_detection),

-- tag_aatams_knows AS (
-- 	  SELECT COUNT(*) AS t,
-- 		'no unique registered tag ids' AS statistics_type
-- 	  FROM device 
-- 		WHERE class = 'au.org.emii.aatams.Tag'),
-- detected_tags_aatams_knows AS (
-- 	  SELECT COUNT(DISTINCT sensor.transmitter_id) AS t,
-- 		'no unique tag ids detected that aatams knows about' AS statistics_type
-- 	  FROM valid_detection 
-- 	  JOIN sensor ON valid_detection.transmitter_id = sensor.transmitter_id),
	  
-- tags_by_species AS (
-- 	  SELECT COUNT(DISTINCT s.tag_id) AS t,
-- 		'tags detected by species' AS statistics_type
-- 	  FROM valid_detection vd
-- 	  LEFT JOIN sensor on vd.transmitter_id = sensor.transmitter_id
-- 	  LEFT JOIN device d on sensor.tag_id = d.id
-- 	  JOIN surgery s ON s.tag_id = d.id)
--   SELECT 'Species' AS type, t, statistics_type::text FROM total_detections_registered_public
-- UNION ALL
--   SELECT 'Species' AS type, t, statistics_type::text FROM total_detections_species
-- UNION ALL
--   SELECT 'Species' AS type, t, statistics_type::text FROM total_detections_species_public
-- UNION ALL
--   SELECT 'Species' AS type, t, statistics_type::text FROM tag_ids
-- UNION ALL
--   SELECT 'Species' AS type, t, statistics_type::text FROM tag_aatams_knows
-- UNION ALL
--   SELECT 'Species' AS type, t, statistics_type::text FROM detected_tags_aatams_knows
-- UNION ALL
--   SELECT 'Species' AS type, t, statistics_type::text FROM tags_by_species;

-- -- All deployments - Project
-- WITH vd AS (
--   SELECT DISTINCT p.id AS project_id,
-- 	p.name AS project_name,
-- 	i.name AS installation_name,
-- 	ist.name AS station_name,
-- 	vd.transmitter_id, 
-- 	CASE WHEN vd.receiver_deployment_id IS NULL THEN rd.id ELSE vd.receiver_deployment_id END AS receiver_deployment_id, 
-- 	registered, 
-- 	COUNT(timestamp) AS no_detections,
-- 	min(timestamp) AS start_date,
-- 	max(timestamp) AS end_date,
-- 	round((date_part('days', max(timestamp) - min(timestamp)) + date_part('hours', max(timestamp) - min(timestamp))/24)::numeric/365.25, 1) AS coverage_duration
--   FROM valid_detection vd
--   LEFT JOIN aatams_acoustic_species_all_deployments_view a ON a.transmitter_id = vd.transmitter_id
--   FULL JOIN receiver_deployment rd ON rd.id = vd.receiver_deployment_id
--   FULL JOIN installation_station ist ON ist.id = rd.station_id
--   FULL JOIN installation i ON i.id = ist.installation_id
--   FULL JOIN project p ON p.id = i.project_id
-- 	GROUP BY vd.transmitter_id, vd.receiver_deployment_id, registered,rd.id,p.id, p.name,i.name,ist.name)
--   SELECT CASE WHEN substring(p.name,'AATAMS')='AATAMS' THEN 'IMOS funded and co-invested' 
-- 	      WHEN p.name = 'Coral Sea  Nautilus tracking project' 
-- 	      OR p.name = 'Seven Gill tracking in Coastal Tasmania' 
-- 	      OR substring(p.name,'Yongala')='Yongala'
-- 	      OR p.name = 'Rowley Shoals reef shark tracking 2007' 
-- 	      OR p.name = 'Wenlock River Array, Gulf of Carpentaria' THEN 'IMOS Receiver Pool' 
-- 	      ELSE 'Fully Co-Invested' END AS funding_type,
-- 	p.id AS project_id,
-- 	p.name AS project_name,
-- 	i.name AS installation_name,
-- 	ist.name AS station_name,
-- 	COUNT(DISTINCT receiver_deployment_id) AS no_deployments,
-- 	CASE WHEN SUM(no_detections) IS NULL THEN 0 ELSE SUM(no_detections) END AS no_detections,
-- 	min(rd.deploymentdatetime_timestamp) AS first_deployment_date,
-- 	max(rd.deploymentdatetime_timestamp) AS last_deployment_date,
-- 	min(vd.start_date) AS start_date,
-- 	max(vd.end_date) AS end_date,
-- 	round((date_part('days', max(vd.end_date) - min(vd.start_date)) + date_part('hours', max(vd.end_date) - min(vd.start_date))/24)::numeric/365.25, 1) AS coverage_duration,
-- 	ROUND(st_y(ist.location)::numeric,1) AS station_lat,
-- 	ROUND(st_x(ist.location)::numeric,1) AS station_lon,
-- 	ROUND(min(rd.depth_below_surfacem::integer),1) AS min_depth,
-- 	ROUND(max(rd.depth_below_surfacem::integer),1) AS max_depth,
-- 	p.is_protected,
-- 	COUNT(DISTINCT CASE WHEN registered = FALSE THEN transmitter_id ELSE NULL END) AS no_unreg_transmitters,
-- 	SUM(CASE WHEN registered = FALSE THEN no_detections ELSE 0 END) AS no_unreg_detections,
-- 	COUNT(DISTINCT transmitter_id) AS no_transmitters
--   FROM project p
--   FULL JOIN installation i ON i.project_id = p.id
--   FULL JOIN installation_station ist ON ist.installation_id = i.id
--   FULL JOIN receiver_deployment rd ON rd.station_id = ist.id
--   FULL JOIN vd ON vd.receiver_deployment_id = rd.id
-- 	WHERE p.id IS NOT NULL
-- 	GROUP BY p.id, p.name,i.name,ist.name,p.is_protected,ist.location
-- 	ORDER BY project_name,installation_name,station_name;

-- -- Data summary - Project 
-- WITH a AS (SELECT project_id, COUNT(DISTINCT ar.id) AS no_releases FROM animal_release ar GROUP BY project_id)
--   SELECT funding_type,
-- 	project_name,
-- 	COUNT (DISTINCT(installation_name))::numeric AS no_installations,
-- 	COUNT (DISTINCT(station_name))::numeric AS no_stations,
-- 	SUM(no_deployments)::numeric AS no_deployments,
-- 	CASE WHEN a.no_releases IS NULL THEN 0 ELSE a.no_releases END AS no_releases,
-- 	SUM(no_detections) AS no_detections,
-- 	min(first_deployment_date) AS earliest_deployment_date,
-- 	max(last_deployment_date) AS latest_deployment_date,
-- 	min(start_date) AS start_date,
-- 	max(end_date) AS end_date,
-- 	round((date_part('days', max(end_date) - min(start_date)) + date_part('hours', max(end_date) - min(start_date))/24)::numeric/365.25, 1) AS coverage_duration,
-- 	min(station_lat) AS min_lat,
-- 	max(station_lat) AS max_lat,
-- 	min(station_lon) AS min_lon,
-- 	max(station_lon) AS max_lon,
-- 	min(min_depth) AS min_depth,
-- 	max(max_depth) AS max_depth,
-- 	is_protected,
-- 	SUM(no_transmitters) AS no_transmitters,
-- 	SUM(no_unreg_transmitters) AS no_unreg_transmitters,
-- 	CASE WHEN SUM(no_transmitters) = 0 THEN NULL ELSE ROUND(SUM(no_unreg_transmitters)/SUM(no_transmitters) * 100, 1) END AS prop_unreg_transmitters,
-- 	SUM(no_unreg_detections) AS no_unreg_detections,
-- 	CASE WHEN SUM(no_transmitters) = 0 THEN NULL ELSE ROUND(SUM(no_unreg_detections)/SUM(no_detections) * 100, 1) END AS prop_unreg_detections
--   FROM aatams_acoustic_project_all_deployments_view v
--   LEFT JOIN a ON a.project_id = v.project_id
-- 	GROUP BY funding_type,project_name, is_protected, a.no_releases
-- 	ORDER BY funding_type DESC,project_name;
	
-- -- Totals - Project
-- SELECT funding_type,
-- 	COUNT(DISTINCT(project_name)) AS no_projects,
-- 	SUM(no_installations) AS no_installations,
-- 	SUM(no_stations) AS no_stations,
-- 	SUM(no_deployments) AS no_deployments,
-- 	SUM(no_releases) AS no_releases,
-- 	SUM(no_detections) AS no_detections
--   FROM aatams_acoustic_project_data_summary_view
-- 	GROUP BY funding_type
-- UNION ALL
--   SELECT 'TOTAL' AS funding_type,
-- 	COUNT(DISTINCT(project_name)) AS no_projects,
-- 	SUM(no_installations) AS no_installations,
-- 	SUM(no_stations) AS no_stations,
-- 	SUM(no_deployments) AS no_deployments,
-- 	SUM(no_releases) AS no_releases,
-- 	SUM(no_detections) AS no_detections
--   FROM aatams_acoustic_project_data_summary_view
-- 	ORDER BY funding_type ASC;

-- -- Other totals
-- INSERT INTO aatams_acoustic_stats_view 
--   SELECT 'Project' AS type,
-- 	COUNT(*) AS t, 
-- 	'Number of projects with no installation or release' AS statistics_type 
--   FROM aatams_acoustic_project_data_summary_view v 
-- 	WHERE no_installations = 0 AND no_releases = 0
-- UNION ALL
--   SELECT 'Project' AS type,
-- 	COUNT(*) AS t, 
-- 	'Number of projects with installations but no detection' AS statistics_type 
--   FROM aatams_acoustic_project_data_summary_view v 
-- 	WHERE no_installations != 0 AND no_detections = 0
-- UNION ALL
--   SELECT 'Project' AS type,
-- 	COUNT(*) AS t, 
-- 	'Number of protected projects' AS statistics_type 
--   FROM aatams_acoustic_project_data_summary_view v 
-- 	WHERE is_protected = TRUE
-- UNION ALL
--   SELECT 'Project' AS type,
-- 	COUNT(*) AS t, 
-- 	'Number of projects with receiver deployments during the past year' AS statistics_type 
--   FROM aatams_acoustic_project_data_summary_view v 
-- 	WHERE date_part('days',now() - latest_deployment_date) < 365.25;

-- Create all views in reporting schema
CREATE OR REPLACE VIEW reporting.aatams_acoustic_species_all_deployments_view AS SELECT * FROM dw_aatams_acoustic.aatams_acoustic_species_all_deployments_view;
CREATE OR REPLACE VIEW reporting.aatams_acoustic_species_data_summary_view AS 
SELECT registered, 
CASE WHEN common_name = '[a devilray]' THEN 'Devil Ray' WHEN
	common_name = '[a temperate bass]' THEN 'Temperate Bass' WHEN
	common_name = '[a whaler shark]' THEN 'Whaler Shark' WHEN
	common_name = '[a wobbegong ]' THEN 'Wobbegong' ELSE common_name END AS common_name, 
no_transmitters, no_releases, no_releases_with_location, no_embargo, no_protected, latest_embargo_date, total_no_detections, no_detections_public, earliest_detection, latest_detection, no_data_days
 FROM dw_aatams_acoustic.aatams_acoustic_species_data_summary_view
 ORDER BY registered, common_name;
CREATE OR REPLACE VIEW reporting.aatams_acoustic_embargo_totals_view AS SELECT * FROM dw_aatams_acoustic.aatams_acoustic_embargo_totals_view;
CREATE OR REPLACE VIEW reporting.aatams_acoustic_registered_totals_view AS SELECT * FROM dw_aatams_acoustic.aatams_acoustic_registered_totals_view;
CREATE OR REPLACE VIEW reporting.aatams_acoustic_stats_view AS SELECT * FROM dw_aatams_acoustic.aatams_acoustic_stats_view;
CREATE OR REPLACE VIEW reporting.aatams_acoustic_project_all_deployments_view AS SELECT * FROM dw_aatams_acoustic.aatams_acoustic_project_all_deployments_view ORDER BY project_name, installation_name, station_name;
CREATE OR REPLACE VIEW reporting.aatams_acoustic_project_data_summary_view AS SELECT * FROM dw_aatams_acoustic.aatams_acoustic_project_data_summary_view;
CREATE OR REPLACE VIEW reporting.aatams_acoustic_project_totals_view AS SELECT * FROM dw_aatams_acoustic.aatams_acoustic_project_totals_view;

grant all on table reporting.aatams_acoustic_species_all_deployments_view to public;
grant all on table reporting.aatams_acoustic_species_data_summary_view to public;
grant all on table reporting.aatams_acoustic_embargo_totals_view to public;
grant all on table reporting.aatams_acoustic_registered_totals_view to public;
grant all on table reporting.aatams_acoustic_stats_view to public;
grant all on table reporting.aatams_acoustic_project_all_deployments_view to public;
grant all on table reporting.aatams_acoustic_project_data_summary_view to public;
grant all on table reporting.aatams_acoustic_project_totals_view to public;