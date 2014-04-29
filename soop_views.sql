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
	NULL::text AS depth_range, 
	date(min(cp.date_time_utc)) AS start_date, 
	date(max(cp.date_time_utc)) AS end_date, 
	round(((date_part('day', (max(cp.date_time_utc) - min(cp.date_time_utc))))::numeric + ((date_part('hours', (max(cp.date_time_utc) - min(cp.date_time_utc))))::numeric / (24)::numeric)), 1) AS coverage_duration, 
	(date_part('day', (min(cm.data_on_staging) - (date(min(cp.date_time_utc)))::timestamp without time zone)))::numeric AS days_to_process_and_upload, 
	round(avg((date_part('day', (cm.data_on_portal - cm.data_on_staging)))::numeric), 1) AS days_to_make_public, 
	CASE WHEN (date_part('day', (min(cm.data_on_staging) - (date(min(cp.date_time_utc)))::timestamp without time zone)))::numeric IS NULL THEN 'Missing dates' 
		WHEN sum(CASE WHEN (cm.mest_uuid IS NULL) THEN 0 ELSE 1 END) <> sum(CASE WHEN (cm.cruise_id IS NOT NULL) THEN 1 ELSE 0 END) THEN 'No metadata' 
		ELSE NULL END AS missing_info, 
	''::text AS principal_investigator, 
	round(min(cp.latitude), 1) AS min_lat, 
	round(max(cp.latitude), 1) AS max_lat, 
	round(min(cp.longitude), 1) AS min_lon, 
	round(max(cp.longitude), 1) AS max_lon, 
	NULL::text AS min_depth, 
	NULL::text AS max_depth, 
	date(cm.data_on_portal) AS data_on_portal 
  FROM pci 
  FULL JOIN phyto ON pci.date_time_utc = phyto.date_time_utc
  FULL JOIN zoop ON pci.date_time_utc = zoop.date_time_utc
  FULL JOIN legacy_cpr.csiro_harvest_pci cp ON pci.date_time_utc = cp.date_time_utc
  FULL JOIN report.soop_cpr_manual cm ON cp.trip_code = cm.cruise_id
	WHERE pci.vessel_name IS NOT NULL
	GROUP BY subfacility, pci.vessel_name, pci.route, cp.trip_code, cm.data_on_portal 

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
	NULL::text AS depth_range, 
	date(min(so.date_time)) AS start_date, 
	date(max(so.date_time)) AS end_date, 
	round(((date_part('day', (max(so.date_time) - min(so.date_time))))::numeric + ((date_part('hours', (max(so.date_time) - min(so.date_time))))::numeric / (24)::numeric)), 1) AS coverage_duration, 
	NULL::numeric AS days_to_process_and_upload, 
	NULL::numeric AS days_to_make_public, 
	'Missing dates' AS missing_info, 
	''::text AS principal_investigator, 
	NULL::numeric AS min_lat, 
	NULL::numeric AS max_lat, 
	NULL::numeric AS min_lon, 
	NULL::numeric AS max_lon, 
	NULL::text AS min_depth, 
	NULL::text AS max_depth, 
	NULL::date AS data_on_portal 
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
	
  SELECT 'ASF (near real-time & delayed-mode)' AS subfacility, 
	am.vessel_name, 
	NULL::character varying AS deployment_id, 
	NULL::text AS year, 
	count(a.callsign) AS no_data_files, 
	NULL::bigint AS no_profiles, 
	COALESCE(round(min(a.geospatial_lat_min)::numeric, 1) || '/' || round(max(a.geospatial_lat_max)::numeric, 1)) AS lat_range, 
	COALESCE(round(min(a.geospatial_lon_min)::numeric, 1) || '/' || round(max(a.geospatial_lon_max)::numeric, 1)) AS lon_range, 
	COALESCE(round(min(a.geospatial_vertical_min)::numeric, 1) || '/' || round(max(a.geospatial_vertical_max)::numeric, 1)) AS depth_range, 
	date(min(a.time_coverage_start)) AS start_date, 
	date(max(a.time_coverage_end)) AS end_date, 
	(date_part('day', (max(a.time_coverage_end) - min(a.time_coverage_start))))::numeric AS coverage_duration, 
	(date_part('day', (min(am.data_on_staging) - (date(min(a.time_coverage_start)))::timestamp without time zone)))::numeric AS days_to_process_and_upload, 
	(date_part('day', (am.data_on_portal - am.data_on_staging)))::numeric AS days_to_make_public, 
	CASE WHEN (date_part('day', (min(am.data_on_staging) - (date(min(a.time_coverage_start)))::timestamp without time zone)))::numeric IS NULL 
		OR (date_part('day'::text, (am.data_on_portal - am.data_on_staging)))::numeric IS NULL THEN 'Missing dates' 
		WHEN sum(CASE WHEN (a.dataset_uuid IS NULL) THEN 0 ELSE 1 END) <> count(a.callsign) THEN 'No metadata' ELSE NULL END AS missing_info, 
	round((min(a.geospatial_lat_min))::numeric, 1) AS min_lat, 
	round((max(a.geospatial_lat_max))::numeric, 1) AS max_lat, 
	round((min(a.geospatial_lon_min))::numeric, 1) AS min_lon, 
	round((max(a.geospatial_lon_max))::numeric, 1) AS max_lon, 
	round((min(a.geospatial_vertical_min))::numeric, 1) AS min_depth, 
	round((max(a.geospatial_vertical_max))::numeric, 1) AS max_depth, 
	date(am.data_on_portal) AS data_on_portal 
  FROM soop.soop_asf_vw a 
  LEFT JOIN report.soop_asf_manual am ON a.callsign = am.platform_code 
	GROUP BY subfacility, am.vessel_name, data_on_portal, data_on_staging 

UNION ALL
  
  SELECT 'BA (delayed-mode)' AS subfacility, 
	bm.vessel_name,
	bm.deployment_id, 
	NULL::text AS year, 
	count(bm.deployment_id) AS no_data_files, 
	NULL::bigint AS no_profiles, 
	COALESCE(round((min(b.geospatial_lat_min))::numeric, 1) || '/' || round((max(b.geospatial_lat_max))::numeric, 1)) AS lat_range, 
	COALESCE(round((min(b.geospatial_lon_min))::numeric, 1) || '/' || round((max(b.geospatial_lon_max))::numeric, 1)) AS lon_range, 
	COALESCE(round((min(b.geospatial_vertical_min))::numeric, 1) || '/' || round((max(b.geospatial_vertical_max))::numeric, 1)) AS depth_range, 
	date(min(b.time_coverage_start)) AS start_date, 
	date(max(b.time_coverage_end)) AS end_date, 
	(date_part('day', (max(b.time_coverage_end) - min(b.time_coverage_start))))::numeric AS coverage_duration, 
	round(avg((date_part('day', (bm.data_on_staging - (date(b.time_coverage_start))::timestamp without time zone)))::numeric), 1) AS days_to_process_and_upload, 
	round(avg((date_part('day', (bm.data_on_portal - bm.data_on_staging)))::numeric), 1) AS days_to_make_public, 
	CASE WHEN (date_part('day', (min(bm.data_on_staging) - (date(min(b.time_coverage_start)))::timestamp without time zone)))::numeric IS NULL 
		OR round(avg((date_part('day', (bm.data_on_portal - bm.data_on_staging)))::numeric), 1) IS NULL THEN 'Missing dates' 
		WHEN sum(CASE WHEN b.dataset_uuid IS NULL THEN 0 ELSE 1 END) <> count(b.cruise_id) THEN 'No metadata' 
		WHEN sum(CASE WHEN bm.mest_creation IS NULL THEN 0 ELSE 1 END) <> count(b.vessel_name) THEN 'No metadata' 
		ELSE NULL::text END AS missing_info, 
	round((min(b.geospatial_lat_min))::numeric, 1) AS min_lat, 
	round((max(b.geospatial_lat_max))::numeric, 1) AS max_lat, 
	round((min(b.geospatial_lon_min))::numeric, 1) AS min_lon, 
	round((max(b.geospatial_lon_max))::numeric, 1) AS max_lon, 
	round((min(b.geospatial_vertical_min))::numeric, 1) AS min_depth, 
	round((max(b.geospatial_vertical_max))::numeric, 1) AS max_depth, 
	date(bm.data_on_portal) AS data_on_portal 
  FROM soop.soop_ba_vw b
  FULL JOIN report.soop_ba_manual bm ON b.cruise_id = bm.deployment_id
	GROUP BY subfacility, bm.vessel_name, deployment_id, data_on_portal 

UNION ALL 

  SELECT 'CO2 (delayed-mode)'::text AS subfacility, 
	c.vessel_name, 
	c.cruise_id AS deployment_id, 
	NULL::text AS year, 
	NULL::bigint AS no_data_files, 
	NULL::bigint AS no_profiles, 
	COALESCE(round((c.geospatial_lat_min)::numeric, 1) || '/' || round((c.geospatial_lat_max)::numeric, 1)) AS lat_range, 
	COALESCE(round((c.geospatial_lon_min)::numeric, 1) || '/' || round((c.geospatial_lon_max)::numeric, 1)) AS lon_range, 
	COALESCE(round((c.geospatial_vertical_min)::numeric, 1) || '/' || round((c.geospatial_vertical_max)::numeric, 1)) AS depth_range, 
	date(c.time_coverage_start) AS start_date, 
	date(c.time_coverage_end) AS end_date, 
	(date_part('day', (c.time_coverage_end - c.time_coverage_start)))::numeric AS coverage_duration, 
	(date_part('day', (cm.data_on_staging - (date(c.time_coverage_start))::timestamp without time zone)))::numeric AS days_to_process_and_upload, 
	(date_part('day', (cm.data_on_portal - cm.data_on_staging)))::numeric AS days_to_make_public, 
	CASE WHEN (((date_part('day', (cm.data_on_staging - (date(c.time_coverage_start))::timestamp without time zone)))::numeric IS NULL) 
		OR ((date_part('day', (cm.data_on_portal - cm.data_on_staging)))::numeric IS NULL)) THEN 'Missing dates' 
		WHEN (cm.mest_creation IS NULL) THEN 'No metadata' 
		WHEN (c.dataset_uuid IS NULL) THEN 'No metadata' 
		ELSE NULL END AS missing_info, 
	round((c.geospatial_lat_min)::numeric, 1) AS min_lat, 
	round((c.geospatial_lat_max)::numeric, 1) AS max_lat, 
	round((c.geospatial_lon_min)::numeric, 1) AS min_lon, 
	round((c.geospatial_lon_max)::numeric, 1) AS max_lon, 
	round((c.geospatial_vertical_min)::numeric, 1) AS min_depth, 
	round((c.geospatial_vertical_max)::numeric, 1) AS max_depth, 
	date(cm.data_on_portal) AS data_on_portal 
  FROM soop.soop_co2_vw c
  FULL JOIN report.soop_co2_manual cm ON c.cruise_id = cm.deployment_id

UNION ALL 

  SELECT 'SST (near real-time & delayed-mode)'::text AS subfacility, 
	sm.vessel_name, 
	NULL::character varying AS deployment_id, 
	NULL::text AS year, 
	count(DISTINCT s.id) AS no_data_files, 
	NULL::bigint AS no_profiles, 
	COALESCE(round((min(s.geospatial_lat_min))::numeric, 1) || '/' || round((max(s.geospatial_lat_max))::numeric, 1)) AS lat_range, 
	COALESCE(round((min(s.geospatial_lon_min))::numeric, 1) || '/' || round((max(s.geospatial_lon_max))::numeric, 1)) AS lon_range, 
	COALESCE(round((min(s.geospatial_vertical_min))::numeric, 1) || '/' || round((max(s.geospatial_vertical_max))::numeric, 1)) AS depth_range, 
	date(min(s.time_coverage_start)) AS start_date, 
	date(max(s.time_coverage_end)) AS end_date, 
	(date_part('day', (max(s.time_coverage_end) - min(s.time_coverage_start))))::numeric AS coverage_duration, 
	(date_part('day', (min(sm.data_on_staging) - (date(min(s.time_coverage_start)))::timestamp without time zone)))::numeric AS days_to_process_and_upload, 
	round(avg((date_part('day', (sm.data_on_portal - sm.data_on_staging)))::numeric), 1) AS days_to_make_public, 
	CASE WHEN (date_part('day', (min(sm.data_on_staging) - (date(min(s.time_coverage_start)))::timestamp without time zone)))::numeric IS NULL 
		OR round(avg((date_part('day', (sm.data_on_portal - sm.data_on_staging)))::numeric), 1) IS NULL THEN 'Missing dates' 
		WHEN sm.mest_creation IS NULL THEN 'No metadata'
		WHEN sum(CASE WHEN (s.dataset_uuid IS NULL) THEN 0 ELSE 1 END) <> count(s.id) THEN 'No metadata' 
		ELSE NULL END AS missing_info, 
	round((min(s.geospatial_lat_min))::numeric, 1) AS min_lat,
	round((max(s.geospatial_lat_max))::numeric, 1) AS max_lat, 
	round((min(s.geospatial_lon_min))::numeric, 1) AS min_lon, 
	round((max(s.geospatial_lon_max))::numeric, 1) AS max_lon, 
	round((min(s.geospatial_vertical_min))::numeric, 1) AS min_depth, 
	round((max(s.geospatial_vertical_max))::numeric, 1) AS max_depth, 
	date(sm.data_on_portal) AS data_on_portal 
  FROM report.soop_sst_manual sm
  FULL JOIN soop.soop_sst_vw s ON s.vessel_name = sm.vessel_name
	GROUP BY subfacility, sm.vessel_name, mest_creation, data_on_portal

UNION ALL 

  SELECT 'TMV (delayed-mode)'::text AS subfacility, 
	tm.vessel_name, 
	tm.bundle_id AS deployment_id, 
	NULL::text AS year, count(tmv_v.bundle_id) AS no_data_files, 
	NULL::bigint AS no_profiles, 
	COALESCE(round((min(t.geospatial_lat_min))::numeric, 1) || '/' || round((max(t.geospatial_lat_max))::numeric, 1)) AS lat_range, 
	COALESCE(round((min(t.geospatial_lon_min))::numeric, 1) || '/' || round((max(t.geospatial_lon_max))::numeric, 1)) AS lon_range,
	COALESCE(round((min(t.geospatial_vertical_min))::numeric, 1) || '/' || round((max(t.geospatial_vertical_max))::numeric, 1)) AS depth_range, 
	date(min(t.time_coverage_start)) AS start_date, 
	date(max(t.time_coverage_end)) AS end_date, 
	(date_part('day', (max(t.time_coverage_end) - min(t.time_coverage_start))))::numeric AS coverage_duration, 
	(date_part('day', (min(tm.data_on_staging) - (date(min(t.time_coverage_start)))::timestamp without time zone)))::numeric AS days_to_process_and_upload, 
	round(avg((date_part('day', (tm.data_on_portal - tm.data_on_staging)))::numeric), 1) AS days_to_make_public, 
	CASE WHEN (date_part('day', (min(tm.data_on_staging) - (date(min(t.time_coverage_start)))::timestamp without time zone)))::numeric IS NULL 
		OR round(avg((date_part('day', (tm.data_on_portal - tm.data_on_staging)))::numeric), 1) IS NULL THEN 'Missing dates' 
		WHEN sum(CASE WHEN (t.dataset_uuid IS NULL) THEN 0 ELSE 1 END) <> count(t.id) THEN 'No metadata' 
		ELSE NULL END AS missing_info, 
	round((min(t.geospatial_lat_min))::numeric, 1) AS min_lat, 
	round((max(t.geospatial_lat_max))::numeric, 1) AS max_lat, 
	round((min(t.geospatial_lon_min))::numeric, 1) AS min_lon, 
	round((max(t.geospatial_lon_max))::numeric, 1) AS max_lon, 
	round((min(t.geospatial_vertical_min))::numeric, 1) AS min_depth, 
	round((max(t.geospatial_vertical_max))::numeric, 1) AS max_depth, 
	date(tm.data_on_portal) AS data_on_portal 
  FROM soop.soop_tmv_vw t 
  LEFT JOIN tmv_v ON tmv_v.time_coverage_start = t.time_coverage_start 
  FULL JOIN report.soop_tmv_manual tm ON tmv_v.bundle_id = tm.bundle_id
	WHERE tm.vessel_name IS NOT NULL 
	GROUP BY subfacility, tm.vessel_name, tm.bundle_id, tm.data_on_portal

UNION ALL 

  SELECT 'TRV (delayed-mode)'::text AS subfacility, 
	tr.vessel_name, 
	tr.cruise_id AS deployment_id, 
	NULL::text AS year, 
	count(tr.cruise_id) AS no_data_files, 
	NULL::bigint AS no_profiles, 
	COALESCE(round((min(tr.geospatial_lat_min))::numeric, 1) || '/' || round((max(tr.geospatial_lat_max))::numeric, 1)) AS lat_range, 
	COALESCE(round((min(tr.geospatial_lon_min))::numeric, 1) || '/' || round((max(tr.geospatial_lon_max))::numeric, 1)) AS lon_range, 
	COALESCE(round((min(tr.geospatial_vertical_min))::numeric, 1) || '/' || round((max(tr.geospatial_vertical_max))::numeric, 1)) AS depth_range, 
	date(min(tr.time_coverage_start)) AS start_date, 
	date(max(tr.time_coverage_end)) AS end_date, 
	(date_part('day', (max(tr.time_coverage_end) - min(tr.time_coverage_start))))::numeric AS coverage_duration, 
	(date_part('day', (min(trm.data_on_staging) - (date(min(tr.time_coverage_start)))::timestamp without time zone)))::numeric AS days_to_process_and_upload, 
	round(avg((date_part('day', (trm.data_on_portal - trm.data_on_staging)))::numeric), 1) AS days_to_make_public, 
	CASE WHEN (date_part('day', (min(trm.data_on_staging) - (date(min(tr.time_coverage_start)))::timestamp without time zone)))::numeric IS NULL 
		OR round(avg((date_part('day', (trm.data_on_portal - trm.data_on_staging)))::numeric), 1) IS NULL THEN 'Missing dates' 
		WHEN sum(CASE WHEN (tr.dataset_uuid IS NULL) THEN 0 ELSE 1 END) <> sum(CASE WHEN (tr.id IS NOT NULL) THEN 1 ELSE 0 END) THEN 'No metadata' 
		ELSE NULL END AS missing_info, 
	round((min(tr.geospatial_lat_min))::numeric, 1) AS min_lat, 
	round((max(tr.geospatial_lat_max))::numeric, 1) AS max_lat, 
	round((min(tr.geospatial_lon_min))::numeric, 1) AS min_lon, 
	round((max(tr.geospatial_lon_max))::numeric, 1) AS max_lon, 
	round((min(tr.geospatial_vertical_min))::numeric, 1) AS min_depth, 
	round((max(tr.geospatial_vertical_max))::numeric, 1) AS max_depth, 
	date(trm.data_on_portal) AS data_on_portal 
  FROM soop.soop_trv_vw tr
  FULL JOIN report.soop_trv_manual trm ON tr.cruise_id = trm.cruise_id 
	GROUP BY subfacility, tr.vessel_name, tr.cruise_id, trm.data_on_portal

UNION ALL 

  SELECT DISTINCT 'XBT (near real-time & delayed-mode)' AS subfacility, 
	COALESCE(x.xbt_line || ' | ' || x.xbt_line_description) AS vessel_name, 
	xbt_v.bundle_id AS deployment_id, 
	xbt_v.year, 
	count(DISTINCT x.xbt_cruise_id) AS no_data_files, 
	xbt_v.no_profiles, 
	COALESCE(round((min(x.geospatial_lat_min))::numeric, 1) || '/' || CASE WHEN round((max(x.geospatial_lat_max))::numeric, 1) > 180 THEN 23.4 ELSE round((max(x.geospatial_lat_max))::numeric, 1) END) AS lat_range, 
	COALESCE(round((min(x.geospatial_lon_min))::numeric, 1) || '/' || CASE WHEN round((max(x.geospatial_lon_max))::numeric, 1) > 180 THEN 135.8 ELSE round((max(x.geospatial_lon_max))::numeric, 1) END) AS lon_range, 
	COALESCE(round((min(x.geospatial_vertical_min))::numeric, 1) || '/' || round((max(x.geospatial_vertical_max))::numeric, 1)) AS depth_range, 
	date(min(x.launch_date)) AS start_date, 
	date(max(x.launch_date)) AS end_date, 
	(date_part('day', (max(x.launch_date) - min(x.launch_date))))::numeric AS coverage_duration, 
	(date_part('day', (min(xm.data_on_staging) - (date(min(x.launch_date)))::timestamp without time zone)))::numeric AS days_to_process_and_upload, 
	round(avg((date_part('day', (xm.data_on_portal - xm.data_on_staging)))::numeric), 1) AS days_to_make_public, 
	CASE WHEN (date_part('day', (min(xm.data_on_staging) - (date(min(x.launch_date)))::timestamp without time zone)))::numeric IS NULL 
		OR avg((date_part('day', (xm.data_on_portal - xm.data_on_staging)))::numeric) IS NULL
		OR sum(CASE WHEN (x.launch_date IS NULL) THEN 0 ELSE 1 END) <> count(x.xbt_line) THEN 'Missing dates' 
		WHEN sum(CASE WHEN (x.uuid IS NULL) THEN 0 ELSE 1 END) <> count(x.xbt_line) THEN 'No metadata' 
		ELSE NULL END AS missing_info, 
	round((min(x.geospatial_lat_min))::numeric, 1) AS min_lat, 
	CASE WHEN round((max(x.geospatial_lat_max))::numeric, 1) > 180 THEN 23.4 
		ELSE round((max(x.geospatial_lat_max))::numeric, 1) END AS max_lat, 
	round((min(x.geospatial_lon_min))::numeric, 1) AS min_lon, 
	CASE WHEN round((max(x.geospatial_lon_max))::numeric, 1) > 180 THEN 135.8 
		ELSE round((max(x.geospatial_lon_max))::numeric, 1) END AS max_lon, 
	round((min(x.geospatial_vertical_min))::numeric, 1) AS min_depth, 
	round((max(x.geospatial_vertical_max))::numeric, 1) AS max_depth, 
	date(xm.data_on_portal) AS data_on_portal 
  FROM soop.soop_xbt_vw x
  LEFT JOIN xbt_v ON x.xbt_line = xbt_v.line_name AND xbt_v.year::bpchar = date_part('year', x.launch_date)::bpchar
  LEFT JOIN report.soop_xbt_manual xm ON xbt_v.bundle_id = xm.bundle_id 
	GROUP BY subfacility, x.xbt_line, x.xbt_line_description, xbt_v.year, xbt_v.bundle_id, xbt_v.no_profiles, xm.data_on_portal 
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
	COALESCE(round(min(vw.min_depth), 1) || '/' || round(max(vw.max_depth), 1)) AS depth_range, 
	min(vw.start_date) AS earliest_date, 
	max(vw.end_date) AS latest_date, 
	sum(vw.coverage_duration) AS coverage_duration, 
	round(avg(vw.days_to_process_and_upload), 1) AS mean_days_to_process_and_upload, 
	round(avg(vw.days_to_make_public), 1) AS mean_days_to_make_public, 
	sum(CASE WHEN vw.missing_info IS NULL THEN 1 ELSE 0 END) AS missing_info, 
	round(min(vw.min_lat), 1) AS min_lat, 
	round(max(vw.max_lat), 1) AS max_lat, 
	round(min(vw.min_lon), 1) AS min_lon, 
	round(max(vw.max_lon), 1) AS max_lon, 
	round(min(vw.min_depth), 1) AS min_depth, 
	round(max(vw.max_depth), 1) AS max_depth 
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