SET search_path = reporting, public;
DROP VIEW IF EXISTS soop_cpr_all_deployments_view CASCADE;

-------------------------------
-- VIEW FOR SOOP-CPR
-------------------------------
-- All deployments view
CREATE or replace VIEW soop_cpr_all_deployments_view AS
  WITH phyto AS (
	SELECT DISTINCT p."TIME", 
	count(DISTINCT p."TIME") AS no_phyto_samples 
  FROM soop_auscpr.soop_auscpr_phyto_trajectory_map p
	GROUP BY p."TIME" 
	ORDER BY "TIME"), 
	
	zoop AS (
	SELECT DISTINCT z."TIME", 
	count(DISTINCT z."TIME") AS no_zoop_samples 
  FROM soop_auscpr.soop_auscpr_zoop_trajectory_map z
	GROUP BY z."TIME" 
	ORDER BY "TIME"), 

	pci AS (
	SELECT DISTINCT pci.vessel_name, 
	CASE WHEN pci.start_port < pci.end_port THEN (pci.start_port || '-' || pci.end_port) 
		ELSE (pci.end_port || '-' || pci.start_port) END AS route, 
	pci."TIME", 
	count(DISTINCT pci."TIME") AS no_pci_samples 
  FROM soop_auscpr.soop_auscpr_pci_trajectory_map pci
	GROUP BY vessel_name, route, "TIME" 
	ORDER BY vessel_name, route , "TIME") 

  SELECT 'CPR AUS' AS subfacility,
	COALESCE(CASE WHEN pci.vessel_name = 'Aurora Australia' THEN 'Aurora Australis' ELSE pci.vessel_name END || ' | ' || pci.route) AS vessel_route,
	CASE WHEN pci.vessel_name = 'Aurora Australia' THEN 'Aurora Australis' ELSE pci.vessel_name::character varying END AS vessel_name, 
	pci.route, 
	cp.trip_code::character varying AS deployment_id, 
	sum(pci.no_pci_samples) AS no_pci_samples, 
	CASE WHEN sum(phyto.no_phyto_samples) IS NULL THEN 0 ELSE sum(phyto.no_phyto_samples) END AS no_phyto_samples, 
	CASE WHEN sum(zoop.no_zoop_samples) IS NULL THEN 0 ELSE sum(zoop.no_zoop_samples) END AS no_zoop_samples, 
	COALESCE(round(min(cp.latitude)::numeric, 1) || '/' || round(max(cp.latitude)::numeric, 1)) AS lat_range, 
	COALESCE(round(min(cp.longitude)::numeric, 1) || '/' || round(max(cp.longitude)::numeric, 1)) AS lon_range,
	date(min(cp."TIME")) AS start_date, 
	date(max(cp."TIME")) AS end_date, 
	round(((date_part('day', (max(cp."TIME") - min(cp."TIME"))))::numeric + ((date_part('hours', (max(cp."TIME") - min(cp."TIME"))))::numeric / (24)::numeric)), 1) AS coverage_duration,
	round(min(cp.latitude)::numeric, 1) AS min_lat, 
	round(max(cp.latitude)::numeric, 1) AS max_lat, 
	round(min(cp.longitude)::numeric, 1) AS min_lon, 
	round(max(cp.longitude)::numeric, 1) AS max_lon
  FROM pci 
  FULL JOIN phyto ON pci."TIME" = phyto."TIME"
  FULL JOIN zoop ON pci."TIME" = zoop."TIME"
  FULL JOIN soop_auscpr.soop_auscpr_pci_trajectory_map cp ON pci."TIME" = cp."TIME"
	WHERE pci.vessel_name IS NOT NULL
	GROUP BY subfacility, pci.vessel_name, pci.route, cp.trip_code 

UNION ALL 

  SELECT 'CPR SO' AS subfacility, 
	COALESCE(CASE WHEN so.ship_code = 'AA' THEN 'Aurora Australis'
	     WHEN so.ship_code = 'AF' THEN 'Akademik Federov'
	     WHEN so.ship_code = 'HM' THEN 'Hakuho Maru'
	     WHEN so.ship_code = 'KM' THEN 'Kaiyo Maru'
	     WHEN so.ship_code = 'PS' THEN 'Polarstern'
	     WHEN so.ship_code = 'SA' THEN 'San Aotea II'
	     WHEN so.ship_code = 'SH' THEN 'Shirase'
	     WHEN so.ship_code = 'SH2' THEN 'Shirase2'
	     WHEN so.ship_code = 'TA' THEN 'Tangaroa'
	     WHEN so.ship_code = 'UM' THEN 'Umitaka Maru'
	     WHEN so.ship_code = 'YU' THEN 'Yuzhmorgeologiya'
	END || ' | ' || 'Southern Ocean') AS vessel_route,
	CASE WHEN so.ship_code = 'AA' THEN 'Aurora Australis'
	     WHEN so.ship_code = 'AF' THEN 'Akademik Federov'
	     WHEN so.ship_code = 'HM' THEN 'Hakuho Maru'
	     WHEN so.ship_code = 'KM' THEN 'Kaiyo Maru'
	     WHEN so.ship_code = 'PS' THEN 'Polarstern'
	     WHEN so.ship_code = 'SA' THEN 'San Aotea II'
	     WHEN so.ship_code = 'SH' THEN 'Shirase'
	     WHEN so.ship_code = 'SH2' THEN 'Shirase2'
	     WHEN so.ship_code = 'TA' THEN 'Tangaroa'
	     WHEN so.ship_code = 'UM' THEN 'Umitaka Maru'
	     WHEN so.ship_code = 'YU' THEN 'Yuzhmorgeologiya'
	END AS vessel_name, 
	NULL::text AS route, 
	COALESCE(so.ship_code || '-' || so.tow_number) AS deployment_id, 
	sum(CASE WHEN so.pci IS NULL THEN 0 ELSE 1 END) AS no_pci_samples, 
	NULL::numeric AS no_phyto_samples, 
	count(so.total_abundance) AS no_zoop_samples, 
	COALESCE(ROUND(min(ST_Y("position"))::numeric, 1) || '/' || ROUND(max(ST_Y("position"))::numeric, 1)) AS lat_range, 
	COALESCE(ROUND(min(ST_X("position"))::numeric, 1) || '/' || ROUND(max(ST_X("position"))::numeric, 1)) AS lon_range,
	date(min(so.date_time)) AS start_date, 
	date(max(so.date_time)) AS end_date, 
	round(((date_part('day', (max(so.date_time) - min(so.date_time))))::numeric + ((date_part('hours', (max(so.date_time) - min(so.date_time))))::numeric / (24)::numeric)), 1) AS coverage_duration,
	ROUND(min(ST_Y("position"))::numeric, 1) AS min_lat, 
	ROUND(max(ST_Y("position"))::numeric, 1) AS max_lat, 
	ROUND(min(ST_X("position"))::numeric, 1) AS min_lon, 
	ROUND(max(ST_X("position"))::numeric, 1) AS max_lon 
  FROM legacy_cpr.so_segment so
	GROUP BY subfacility, ship_code, tow_number 
	ORDER BY subfacility, vessel_name, route, start_date, deployment_id;

grant all on table soop_cpr_all_deployments_view to public;