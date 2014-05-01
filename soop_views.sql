SET search_path = report_test, pg_catalog, public, soop;

CREATE or replace VIEW soop_cpr_all_deployments_view AS
  WITH phyto AS (
	SELECT DISTINCT p.date_time_utc, 
	count(DISTINCT p.date_time_utc) AS no_phyto_samples 
  FROM legacy_cpr.csiro_harvest_phyto p
	GROUP BY p.date_time_utc 
	ORDER BY date_time_utc), 
	
	zoop AS (
	SELECT DISTINCT z.date_time_utc, 
	count(DISTINCT z.date_time_utc) AS no_zoop_samples 
  FROM legacy_cpr.csiro_harvest_zoop z
	GROUP BY z.date_time_utc 
	ORDER BY date_time_utc), 

	pci AS (
	SELECT DISTINCT pci.vessel_name, 
	CASE WHEN pci.start_port < pci.end_port THEN (pci.start_port || '-' || pci.end_port) 
		ELSE (pci.end_port || '-' || pci.start_port) END AS route, 
	pci.date_time_utc, 
	count(DISTINCT pci.date_time_utc) AS no_pci_samples 
  FROM legacy_cpr.csiro_harvest_pci pci
	GROUP BY vessel_name, route, date_time_utc 
	ORDER BY vessel_name, route , date_time_utc) 

  SELECT 'CPR-AUS (delayed-mode)' AS subfacility, 
	pci.vessel_name, 
	pci.route, 
	cp.trip_code AS deployment_id, 
	sum(pci.no_pci_samples) AS no_pci_samples, 
	CASE WHEN sum(phyto.no_phyto_samples) IS NULL THEN 0 ELSE sum(phyto.no_phyto_samples) END AS no_phyto_samples, 
	CASE WHEN sum(zoop.no_zoop_samples) IS NULL THEN 0 ELSE sum(zoop.no_zoop_samples) END AS no_zoop_samples, 
	COALESCE(round(min(cp.latitude), 1) || '/' || round(max(cp.latitude), 1)) AS lat_range, 
	COALESCE(round(min(cp.longitude), 1) || '/' || round(max(cp.longitude), 1)) AS lon_range,
	date(min(cp.date_time_utc)) AS start_date, 
	date(max(cp.date_time_utc)) AS end_date, 
	round(((date_part('day', (max(cp.date_time_utc) - min(cp.date_time_utc))))::numeric + ((date_part('hours', (max(cp.date_time_utc) - min(cp.date_time_utc))))::numeric / (24)::numeric)), 1) AS coverage_duration,
	''::text AS principal_investigator, 
	round(min(cp.latitude), 1) AS min_lat, 
	round(max(cp.latitude), 1) AS max_lat, 
	round(min(cp.longitude), 1) AS min_lon, 
	round(max(cp.longitude), 1) AS max_lon
  FROM pci 
  FULL JOIN phyto ON pci.date_time_utc = phyto.date_time_utc
  FULL JOIN zoop ON pci.date_time_utc = zoop.date_time_utc
  FULL JOIN legacy_cpr.csiro_harvest_pci cp ON pci.date_time_utc = cp.date_time_utc
	WHERE pci.vessel_name IS NOT NULL
	GROUP BY subfacility, pci.vessel_name, pci.route, cp.trip_code 

UNION ALL 

  SELECT 'CPR-SO (delayed-mode)' AS subfacility, 
	so.ship_code AS vessel_name, 
	NULL::text AS route, 
	COALESCE(so.ship_code || '-' || so.tow_number) AS deployment_id, 
	sum(CASE WHEN so.pci IS NULL THEN 0 ELSE 1 END) AS no_pci_samples, 
	NULL::numeric AS no_phyto_samples, 
	count(so.total_abundance) AS no_zoop_samples, 
	NULL::text AS lat_range, 
	NULL::text AS lon_range,
	date(min(so.date_time)) AS start_date, 
	date(max(so.date_time)) AS end_date, 
	round(((date_part('day', (max(so.date_time) - min(so.date_time))))::numeric + ((date_part('hours', (max(so.date_time) - min(so.date_time))))::numeric / (24)::numeric)), 1) AS coverage_duration, 
	''::text AS principal_investigator, 
	NULL::numeric AS min_lat, 
	NULL::numeric AS max_lat, 
	NULL::numeric AS min_lon, 
	NULL::numeric AS max_lon
  FROM legacy_cpr.so_segment so
	GROUP BY subfacility, ship_code, tow_number 
	ORDER BY subfacility, vessel_name, route, start_date;

grant all on table soop_cpr_all_deployments_view to public;





CREATE or replace VIEW soop_all_deployments_view AS
  WITH tmv_v AS (
	SELECT 
	v.time_coverage_start, 
	CASE WHEN date(v.time_coverage_start) >= '2008-08-01'::date AND date(v.time_coverage_start) < '2009-01-15'::date THEN 'Aug08-Jan09' 
	WHEN date(v.time_coverage_start) >= '2011-08-11'::date AND date(v.time_coverage_start) < '2011-12-19'::date THEN 'Aug11-Dec11' 
	WHEN date(v.time_coverage_start) >= '2011-12-19'::date AND date(v.time_coverage_start) < '2012-02-01'::date THEN 'Dec11-Feb12' 
	WHEN date(v.time_coverage_start) >= '2009-01-16'::date AND date(v.time_coverage_start) < '2009-07-31'::date THEN 'Jan09-Jul09' 
	WHEN date(v.time_coverage_start) >= '2011-01-11'::date AND date(v.time_coverage_start) < '2011-07-11'::date THEN 'Jan11-Jun11' 
	WHEN date(v.time_coverage_start) >= '2010-07-01'::date AND date(v.time_coverage_start) < '2011-01-11'::date THEN 'Jul10-Jan11' 
	WHEN date(v.time_coverage_start) >= '2009-09-01'::date AND date(v.time_coverage_start) < '2010-06-30'::date THEN 'Sep09-Jun10' 
	ELSE NULL END AS bundle_id 
  FROM soop.soop_tmv_vw v),
  
  xbt_v AS (
	SELECT 
	r.line_name, 
	r.year, 
	r.bundle_id, 
	sum(r.number_of_profile) AS no_profiles 
  FROM report.soop_xbt r
	GROUP BY r.line_name, r.bundle_id, r.year 
	ORDER BY line_name, bundle_id) 

  SELECT 'ASF Flux product' AS subfacility,
	vessel_name,
	cruise_id AS deployment_id,
	date_part('year',min(time_start)) AS year,
	COUNT(file_id) AS no_data_files,
	NULL::bigint AS no_profiles,
	COALESCE(round(min(ST_YMIN(geom))::numeric, 1) || '/' || round(max(ST_YMAX(geom))::numeric, 1)) AS lat_range, 
	COALESCE(round(min(ST_XMIN(geom))::numeric, 1) || '/' || round(max(ST_XMAX(geom))::numeric, 1)) AS lon_range,
	date(min(time_start)) AS start_date, 
	date(max(time_end)) AS end_date,
	date_part('day',max(time_end) - min(time_start))::numeric AS coverage_duration,
	round(min(ST_YMIN(geom))::numeric, 1) AS min_lat, 
	round(max(ST_YMAX(geom))::numeric, 1) AS max_lat, 
	round(min(ST_XMIN(geom))::numeric, 1) AS min_lon, 
	round(max(ST_XMAX(geom))::numeric, 1) AS max_lon
  FROM soop_asf_mft.soop_asf_mft_trajectory_map
  	GROUP BY subfacility, vessel_name, cruise_id

UNION ALL

  SELECT 'ASF Meteorological SST observations' AS subfacility,
	vessel_name,
	cruise_id AS deployment_id,
	date_part('year',min(time_start)) AS year,
	COUNT(file_id) AS no_data_files,
	NULL::bigint AS no_profiles,
	COALESCE(round(min(ST_YMIN(geom))::numeric, 1) || '/' || round(max(ST_YMAX(geom))::numeric, 1)) AS lat_range, 
	COALESCE(round(min(ST_XMIN(geom))::numeric, 1) || '/' || round(max(ST_XMAX(geom))::numeric, 1)) AS lon_range,
	date(min(time_start)) AS start_date, 
	date(max(time_end)) AS end_date,
	date_part('day',max(time_end) - min(time_start))::numeric AS coverage_duration,
	round(min(ST_YMIN(geom))::numeric, 1) AS min_lat, 
	round(max(ST_YMAX(geom))::numeric, 1) AS max_lat, 
	round(min(ST_XMIN(geom))::numeric, 1) AS min_lon, 
	round(max(ST_XMAX(geom))::numeric, 1) AS max_lon
  FROM soop_asf_mt.soop_asf_mt_trajectory_map
  	GROUP BY subfacility, vessel_name, cruise_id

UNION ALL

  SELECT 'BA' AS subfacility,
	m.vessel_name,
	d.voyage_id AS deployment_id,
	date_part('year',min(time_start)) AS year,
	COUNT(m.file_id) AS no_data_files,
	NULL::bigint AS no_profiles,
	COALESCE(round(min(ST_YMIN(geom))::numeric, 1) || '/' || round(max(ST_YMAX(geom))::numeric, 1)) AS lat_range, 
	COALESCE(round(min(ST_XMIN(geom))::numeric, 1) || '/' || round(max(ST_XMAX(geom))::numeric, 1)) AS lon_range,
	date(min(time_start)) AS start_date, 
	date(max(time_end)) AS end_date,
	date_part('day',max(time_end) - min(time_start))::numeric AS coverage_duration,
	round(min(ST_YMIN(geom))::numeric, 1) AS min_lat, 
	round(max(ST_YMAX(geom))::numeric, 1) AS max_lat, 
	round(min(ST_XMIN(geom))::numeric, 1) AS min_lon, 
	round(max(ST_XMAX(geom))::numeric, 1) AS max_lon
  FROM soop_ba.soop_ba_trajectory_map m
  JOIN soop_ba.deployments d ON d.file_id = m.file_id
  	GROUP BY subfacility, m.vessel_name, d.voyage_id

UNION ALL

  SELECT 'CO2' AS subfacility,
	vessel_name,
	cruise_id AS deployment_id,
	date_part('year',min(time_start)) AS year,
	COUNT(file_id) AS no_data_files,
	NULL::bigint AS no_profiles,
	COALESCE(round(min(ST_YMIN(geom))::numeric, 1) || '/' || round(max(ST_YMAX(geom))::numeric, 1)) AS lat_range, 
	COALESCE(round(min(ST_XMIN(geom))::numeric, 1) || '/' || round(max(ST_XMAX(geom))::numeric, 1)) AS lon_range,
	date(min(time_start)) AS start_date, 
	date(max(time_end)) AS end_date,
	date_part('day',max(time_end) - min(time_start))::numeric AS coverage_duration,
	round(min(ST_YMIN(geom))::numeric, 1) AS min_lat, 
	round(max(ST_YMAX(geom))::numeric, 1) AS max_lat, 
	round(min(ST_XMIN(geom))::numeric, 1) AS min_lon, 
	round(max(ST_XMAX(geom))::numeric, 1) AS max_lon
  FROM soop_co2.soop_co2_trajectory_map
  	GROUP BY subfacility, vessel_name, cruise_id

UNION ALL 

  SELECT 'SST - Near real-time' AS subfacility,
	vessel_name,
	voyage_number AS deployment_id,
	date_part('year',min(time_start)) AS year,
	COUNT(trajectory_id) AS no_data_files,
	NULL::bigint AS no_profiles,
	COALESCE(round(min(ST_YMIN(geom))::numeric, 1) || '/' || round(max(ST_YMAX(geom))::numeric, 1)) AS lat_range, 
	COALESCE(round(min(ST_XMIN(geom))::numeric, 1) || '/' || round(max(ST_XMAX(geom))::numeric, 1)) AS lon_range,
	date(min(time_start)) AS start_date, 
	date(max(time_end)) AS end_date,
	date_part('day',max(time_end) - min(time_start))::numeric AS coverage_duration,
	round(min(ST_YMIN(geom))::numeric, 1) AS min_lat, 
	round(max(ST_YMAX(geom))::numeric, 1) AS max_lat, 
	round(min(ST_XMIN(geom))::numeric, 1) AS min_lon, 
	round(max(ST_XMAX(geom))::numeric, 1) AS max_lon
  FROM soop_sst.soop_sst_nrt_trajectory_map
  	GROUP BY subfacility, vessel_name, voyage_number

UNION ALL 

  SELECT 'SST - Delayed-mode' AS subfacility,
	vessel_name,
	voyage_number AS deployment_id,
	date_part('year',min(time_start)) AS year,
	COUNT(trajectory_id) AS no_data_files,
	NULL::bigint AS no_profiles,
	COALESCE(round(min(ST_YMIN(geom))::numeric, 1) || '/' || round(max(ST_YMAX(geom))::numeric, 1)) AS lat_range, 
	COALESCE(round(min(ST_XMIN(geom))::numeric, 1) || '/' || round(max(ST_XMAX(geom))::numeric, 1)) AS lon_range,
	date(min(time_start)) AS start_date, 
	date(max(time_end)) AS end_date,
	date_part('day',max(time_end) - min(time_start))::numeric AS coverage_duration,
	round(min(ST_YMIN(geom))::numeric, 1) AS min_lat, 
	round(max(ST_YMAX(geom))::numeric, 1) AS max_lat, 
	round(min(ST_XMIN(geom))::numeric, 1) AS min_lon, 
	round(max(ST_XMAX(geom))::numeric, 1) AS max_lon
  FROM soop_sst.soop_sst_dm_trajectory_map
  	GROUP BY subfacility, vessel_name, voyage_number

UNION ALL 

  SELECT 'TMV - Near real-time' AS subfacility,
	'Spirit of Tasmania 1' AS vessel_name,
	NULL AS deployment_id,
	date_part('year',time_start) AS year,
	COUNT(file_id) AS no_data_files,
	NULL AS no_profiles,
	COALESCE(round(min(ST_YMIN(geom))::numeric, 1) || '/' || round(max(ST_YMAX(geom))::numeric, 1)) AS lat_range, 
	COALESCE(round(min(ST_XMIN(geom))::numeric, 1) || '/' || round(max(ST_XMAX(geom))::numeric, 1)) AS lon_range,
	date(min(time_start)) AS start_date, 
	date(max(time_end)) AS end_date,
	date_part('day',max(time_end) - min(time_start))::numeric AS coverage_duration,
	round(min(ST_YMIN(geom))::numeric, 1) AS min_lat, 
	round(max(ST_YMAX(geom))::numeric, 1) AS max_lat, 
	round(min(ST_XMIN(geom))::numeric, 1) AS min_lon, 
	round(max(ST_XMAX(geom))::numeric, 1) AS max_lon
  FROM soop_tmv_nrt.soop_tmv_nrt_trajectory_map
  	GROUP BY subfacility, vessel_name, year

UNION ALL 

  SELECT 'TMV - Delayed-mode' AS subfacility,
	vessel_name,
	NULL AS deployment_id,
	date_part('year',time_start) AS year,
	COUNT(file_id) AS no_data_files,
	NULL::bigint AS no_profiles,
	COALESCE(round(min(ST_YMIN(geom))::numeric, 1) || '/' || round(max(ST_YMAX(geom))::numeric, 1)) AS lat_range, 
	COALESCE(round(min(ST_XMIN(geom))::numeric, 1) || '/' || round(max(ST_XMAX(geom))::numeric, 1)) AS lon_range,
	date(min(time_start)) AS start_date, 
	date(max(time_end)) AS end_date,
	date_part('day',max(time_end) - min(time_start))::numeric AS coverage_duration,
	round(min(ST_YMIN(geom))::numeric, 1) AS min_lat, 
	round(max(ST_YMAX(geom))::numeric, 1) AS max_lat, 
	round(min(ST_XMIN(geom))::numeric, 1) AS min_lon, 
	round(max(ST_XMAX(geom))::numeric, 1) AS max_lon
  FROM soop_tmv.soop_tmv_trajectory_map
  	GROUP BY subfacility, vessel_name, year

UNION ALL 

  SELECT 'TRV' AS subfacility,
	m.vessel_name,
	m.trip_id AS deployment_id,
	date_part('year',min(time_start)) AS year,
	COUNT(file_id) AS no_data_files,
	NULL::bigint AS no_profiles,
	COALESCE(round(min(ST_YMIN(geom))::numeric, 1) || '/' || round(max(ST_YMAX(geom))::numeric, 1)) AS lat_range, 
	COALESCE(round(min(ST_XMIN(geom))::numeric, 1) || '/' || round(max(ST_XMAX(geom))::numeric, 1)) AS lon_range,
	date(min(time_start)) AS start_date, 
	date(max(time_end)) AS end_date,
	date_part('day',max(time_end) - min(time_start))::numeric AS coverage_duration,
	round(min(ST_YMIN(geom))::numeric, 1) AS min_lat, 
	round(max(ST_YMAX(geom))::numeric, 1) AS max_lat, 
	round(min(ST_XMIN(geom))::numeric, 1) AS min_lon, 
	round(max(ST_XMAX(geom))::numeric, 1) AS max_lon
  FROM soop_trv.soop_trv_trajectory_map m
  LEFT JOIN soop_trv.deployments d ON m.trip_id = d.trip_id
  	GROUP BY subfacility, m.vessel_name, m.trip_id

UNION ALL 

  SELECT 'XBT - Near real-time' AS subfacility,
	COALESCE("XBT_line" || ' | ' || vessel_name) AS vessel_name,
	NULL AS deployment_id,
	date_part('year',"TIME") AS year,
	NULL AS no_data_files,
	COUNT(profile_id) AS no_profiles,
	COALESCE(round(min(ST_YMIN(geom))::numeric, 1) || '/' || round(max(ST_YMAX(geom))::numeric, 1)) AS lat_range, 
	COALESCE(round(min(ST_XMIN(geom))::numeric, 1) || '/' || round(max(ST_XMAX(geom))::numeric, 1)) AS lon_range,
	date(min("TIME")) AS start_date, 
	date(max("TIME")) AS end_date,
	date_part('day',max("TIME") - min("TIME"))::numeric AS coverage_duration,
	round(min(ST_YMIN(geom))::numeric, 1) AS min_lat, 
	round(max(ST_YMAX(geom))::numeric, 1) AS max_lat, 
	round(min(ST_XMIN(geom))::numeric, 1) AS min_lon, 
	round(max(ST_XMAX(geom))::numeric, 1) AS max_lon
  FROM soop_xbt_nrt.soop_xbt_nrt_profiles_map
  	GROUP BY subfacility, "XBT_line",vessel_name, year

UNION ALL 

  SELECT 'XBT - Delayed-mode' AS subfacility,
	COALESCE(m."XBT_line" || ' | ' || "XBT_line_description") AS vessel_name,
	COUNT(DISTINCT("XBT_cruise_ID")) AS deployment_id,
	date_part('year',m."TIME") AS year,
	NULL AS no_data_files,
	COUNT(m.profile_id) AS no_profiles,
	COALESCE(round(min(ST_YMIN(m.geom))::numeric, 1) || '/' || round(max(ST_YMAX(m.geom))::numeric, 1)) AS lat_range, 
	COALESCE(round(min(ST_XMIN(m.geom))::numeric, 1) || '/' || round(max(ST_XMAX(m.geom))::numeric, 1)) AS lon_range,
	date(min(m."TIME")) AS start_date, 
	date(max(m."TIME")) AS end_date,
	date_part('day',max("TIME") - min("TIME"))::numeric AS coverage_duration,
	round(min(ST_YMIN(m.geom))::numeric, 1) AS min_lat, 
	round(max(ST_YMAX(m.geom))::numeric, 1) AS max_lat, 
	round(min(ST_XMIN(m.geom))::numeric, 1) AS min_lon, 
	round(max(ST_XMAX(m.geom))::numeric, 1) AS max_lon
  FROM soop_xbt_dm.soop_xbt_dm_profile_map m
  	GROUP BY subfacility, "XBT_line", "XBT_line_description",year
	ORDER BY subfacility, vessel_name, deployment_id, year;

grant all on table soop_all_deployments_view to public;


CREATE or replace VIEW soop_data_summary_view AS
 SELECT 
	vw.subfacility, 
	vw.vessel_name, 
	count(CASE WHEN vw.deployment_id IS NULL THEN '1'::character varying ELSE vw.deployment_id END) AS no_deployments, 
	sum(CASE WHEN vw.no_data_files IS NULL THEN (1)::bigint ELSE vw.no_data_files END) AS no_data_files, 
	COALESCE(round(min(vw.min_lat), 1) || '/' || round(max(vw.max_lat), 1)) AS lat_range, 
	COALESCE(round(min(vw.min_lon), 1) || '/' || round(max(vw.max_lon), 1)) AS lon_range,
	min(vw.start_date) AS earliest_date, 
	max(vw.end_date) AS latest_date, 
	sum(vw.coverage_duration) AS coverage_duration,
	round(min(vw.min_lat), 1) AS min_lat, 
	round(max(vw.max_lat), 1) AS max_lat, 
	round(min(vw.min_lon), 1) AS min_lon, 
	round(max(vw.max_lon), 1) AS max_lon
  FROM soop_all_deployments_view vw 
	GROUP BY subfacility, vessel_name 

UNION ALL 

  SELECT 
	cpr_vw.subfacility, 
	cpr_vw.vessel_name, 
	count(cpr_vw.vessel_name) AS no_deployments, 
	CASE WHEN sum(CASE WHEN cpr_vw.no_phyto_samples IS NULL THEN 0 ELSE 1 END) <> count(cpr_vw.vessel_name) THEN sum(cpr_vw.no_pci_samples + cpr_vw.no_zoop_samples) 
	ELSE sum((cpr_vw.no_pci_samples + cpr_vw.no_phyto_samples) + cpr_vw.no_zoop_samples) END AS no_data_files, 
	COALESCE(round(min(cpr_vw.min_lat), 1) || '/' || round(max(cpr_vw.max_lat), 1)) AS lat_range, 
	COALESCE(round(min(cpr_vw.min_lon), 1) || '/' || round(max(cpr_vw.max_lon), 1)) AS lon_range, 
	COALESCE(round((min(cpr_vw.min_depth))::numeric, 1) || '/' || round((max(cpr_vw.max_depth))::numeric, 1)) AS depth_range, 
	min(cpr_vw.start_date) AS earliest_date, 
	max(cpr_vw.end_date) AS latest_date, 
	sum(cpr_vw.coverage_duration) AS coverage_duration, 
	round(avg(cpr_vw.days_to_process_and_upload), 1) AS mean_days_to_process_and_upload, 
	round(avg(cpr_vw.days_to_make_public), 1) AS mean_days_to_make_public, 
	sum(CASE WHEN cpr_vw.missing_info IS NULL THEN 1 ELSE 0 END) AS missing_info, 
	round(min(cpr_vw.min_lat), 1) AS min_lat, 
	round(max(cpr_vw.max_lat), 1) AS max_lat, 
	round(min(cpr_vw.min_lon), 1) AS min_lon, 
	round(max(cpr_vw.max_lon), 1) AS max_lon, 
	round((min(cpr_vw.min_depth))::numeric, 1) AS min_depth, 
	round((max(cpr_vw.max_depth))::numeric, 1) AS max_depth 
  FROM soop_cpr_all_deployments_view cpr_vw
	GROUP BY subfacility, vessel_name 
	ORDER BY subfacility, vessel_name;

grant all on table soop_data_summary_view to public;