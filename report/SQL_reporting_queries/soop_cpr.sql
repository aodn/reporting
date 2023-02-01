SET search_path = reporting, public;
DROP VIEW IF EXISTS soop_cpr_all_deployments_view CASCADE;

-------------------------------
-- VIEW FOR SOOP-CPR
-------------------------------
-- All deployments view
CREATE or replace VIEW soop_cpr_all_deployments_view AS
  WITH phyto AS (
        SELECT DISTINCT p."SampleTime_UTC" AS "TIME",
        count(DISTINCT p."SampleTime_UTC") AS no_phyto_samples
  FROM imos_cpr_db.cpr_phytoplankton_map p
        GROUP BY p."SampleTime_UTC"
        ORDER BY "SampleTime_UTC"),

        zoop AS (
        SELECT DISTINCT z."SampleTime_UTC" AS "TIME",
        count(DISTINCT z."SampleTime_UTC") AS no_zoop_samples
  FROM imos_cpr_db.cpr_zooplankton_map z
        GROUP BY z."SampleTime_UTC"
        ORDER BY "SampleTime_UTC"),

        pci AS (
        SELECT NULL AS vessel_name,
        NULL AS route,
        pci."SampleTime_UTC" as "TIME",
        count(DISTINCT pci."SampleTime_UTC") AS no_pci_samples
  FROM imos_cpr_db.cpr_phytoplankton_map pci
        WHERE pci."PCI" IS NOT NULL
        GROUP BY "SampleTime_UTC")

  SELECT 'CPR AUS' AS subfacility,
        NULL AS vessel_route,
        NULL AS vessel_name,
        NULL AS route,
        NULL AS deployment_id,
        sum(pci.no_pci_samples) AS no_pci_samples,
        CASE WHEN sum(phyto.no_phyto_samples) IS NULL THEN 0 ELSE sum(phyto.no_phyto_samples) END AS no_phyto_samples,
        CASE WHEN sum(zoop.no_zoop_samples) IS NULL THEN 0 ELSE sum(zoop.no_zoop_samples) END AS no_zoop_samples,
        COALESCE(round(min(cp."Latitude")::numeric, 1) || '/' || round(max(cp."Latitude")::numeric, 1)) AS lat_range,
        COALESCE(round(min(cp."Longitude")::numeric, 1) || '/' || round(max(cp."Longitude")::numeric, 1)) AS lon_range,
        date(min(cp."SampleTime_UTC")) AS start_date,
        date(max(cp."SampleTime_UTC")) AS end_date,
        round(((date_part('day', (max(cp."SampleTime_UTC") - min(cp."SampleTime_UTC"))))::numeric + ((date_part('hours', (max(cp."SampleTime_UTC") - min(cp."SampleTime_UTC"))))::numeric / (24)::numeric)), 1) AS coverage_duration,
        round(min(cp."Latitude")::numeric, 1) AS min_lat,
        round(max(cp."Latitude")::numeric, 1) AS max_lat,
        round(min(cp."Longitude")::numeric, 1) AS min_lon,
        round(max(cp."Longitude")::numeric, 1) AS max_lon
  FROM pci
  FULL JOIN phyto ON pci."TIME" = phyto."TIME"
  FULL JOIN zoop ON pci."TIME" = zoop."TIME"
  FULL JOIN imos_cpr_db.cpr_phytoplankton_map cp ON pci."TIME" = cp."SampleTime_UTC"
        GROUP BY subfacility, cp.trip_code

UNION ALL 

  SELECT 'CPR SO' AS subfacility, 
	NULL AS vessel_route,
	NULL AS vessel_name, 
	NULL::text AS route, 
	NULL AS deployment_id, 
	NULL AS no_pci_samples, 
	NULL::numeric AS no_phyto_samples, 
	NULL AS no_zoop_samples, 
	NULL AS lat_range, 
	NULL AS lon_range,
	NULL AS start_date, 
	NULL AS end_date, 
	NULL AS coverage_duration,
	NULL AS min_lat, 
	NULL AS max_lat, 
	NULL AS min_lon, 
	NULL AS max_lon; 

grant all on table soop_cpr_all_deployments_view to public;

-- ALTER VIEW soop_cpr_all_deployments_view OWNER TO harvest_reporting_write_group;
