SET SEARCH_PATH = report_test, public;

DROP TABLE IF EXISTS asset_map;

CREATE TABLE asset_map AS
WITH soop_cpr AS (
  SELECT vessel_name AS platform_code,
	ST_CENTROID(ST_COLLECT(geom)) AS geom
  FROM soop_auscpr.soop_auscpr_pci_trajectory_map 
    WHERE vessel_name != 'RV Cape Ferguson' AND vessel_name != 'RV Solander'
	GROUP BY vessel_name, substring(trip_code,'[A-Z]*')),
  aatams_sattag AS (
  SELECT 'Seals and sea lions'::text AS platform_code,
	ST_CENTROID(ST_COLLECT(geom)) AS geom
  FROM aatams_sattag_dm.aatams_sattag_dm_profile_map
	GROUP BY device_id 
	ORDER BY random()
	LIMIT 75
	),
  aatams_penguins AS(
  SELECT ST_CENTROID(geom) AS geom
  FROM aatams_biologging_penguin.aatams_biologging_penguin_map
  	ORDER BY random()
	LIMIT 25
	),
  aatams_shearwaters AS(
  SELECT ST_CENTROID(geom) AS geom
  FROM aatams_biologging_shearwater.aatams_biologging_shearwater_map
  	ORDER BY random()
	LIMIT 25
	)
---- Argo
  SELECT 'Argo'::text AS facility,
	NULL::text AS subfacility,
	platform_number::text AS platform_code,
	ST_SETSRID(last_location,4326) AS geom,
	'Point'::text AS gtype,
	'#85BF1F' AS colour
  FROM argo.argo_float
	WHERE data_centre_code = 'CS'
---- SOOP-XBT
UNION ALL
  SELECT 'SOOP' AS facility,
	'XBT' AS subfacility,
	'IX12' AS platform_code,
	ST_SetSRID(ST_GeomFromText('LINESTRING(52.0 11.6,115.0 -32.0)'),4326) AS geom,
	'Line' AS gtype,
	'#591FBF' AS colour
UNION ALL
  SELECT 'SOOP' AS facility,
	'XBT' AS subfacility,
	'IX1' AS platform_code,
	ST_SetSRID(ST_GeomFromText('LINESTRING(115.0 -32.0,105.0 -7.0)'),4326) AS geom,
	'Line' AS gtype,
	'#591FBF' AS colour
UNION ALL
  SELECT 'SOOP' AS facility,
	'XBT' AS subfacility,
	'PX2' AS platform_code,
	ST_SetSRID(ST_GeomFromText('LINESTRING(115.4 -5.66, 121 -7.58, 125.41 -8.04, 127.5 -8.24, 129.44 -8.81, 134 -9.36)'),4326) AS geom, 
	'Line' AS gtype,
	'#591FBF' AS colour
UNION ALL
  SELECT 'SOOP' AS facility,
	'XBT' AS subfacility,
	'IX22-PX11' AS platform_code,
	ST_SetSRID(ST_GeomFromText('LINESTRING(118.4 -18.3, 124 -8.2, 125.8 -3, 126.7 -1.7, 131.5 20.5)'),4326) AS geom,
	'Line' AS gtype,
	'#591FBF' AS colour
UNION ALL
  SELECT 'SOOP' AS facility,
	'XBT' AS subfacility,
	'PX30-31' AS platform_code,
	ST_SetSRID(ST_GeomFromText('LINESTRING(153.4 -26.6, 167.8 -23.2, 177.45 -18.4)'),4326) AS geom,
	'Line' AS gtype,
	'#591FBF' AS colour
UNION ALL
  SELECT 'SOOP' AS facility,
	'XBT' AS subfacility,
	'PX34' AS platform_code,
	ST_SetSRID(ST_GeomFromText('LINESTRING(173.2 -40, 151.5 -33.9)'),4326) AS geom,
	'Line' AS gtype,
	'#591FBF' AS colour
UNION ALL
  SELECT 'SOOP' AS facility,
	'XBT' AS subfacility,
	'IX28' AS platform_code,
	ST_SetSRID(ST_GeomFromText('LINESTRING (147.4 -43.5, 140 -66.2)'),4326) AS geom,
	'Line' AS gtype,
	'#591FBF' AS colour

---- SOOP-TMV
UNION ALL
  SELECT 'SOOP' AS facility,
	'TMV' AS subfacility,
	'Spirit of Tasmania' AS platform_code,
	ST_SetSRID(ST_GeomFromText('POINT(145.60 -39.84)'),4326) AS geom,
	'Point' AS gtype,
	'#591FBF' AS colour

---- SOOP-BA
UNION ALL
  SELECT 'SOOP' AS facility,
	'BA' AS subfacility,
	'Indian Ocean' AS platform_code,
	ST_SetSRID(ST_GeomFromText('LINESTRING (57.4 -20.2, 70 -49.1)'),4326) AS geom,
	'Line' AS gtype,
	'#069917' AS colour
UNION ALL
  SELECT 'SOOP' AS facility,
	'BA' AS subfacility,
	'Tasman Sea' AS platform_code,
	ST_SetSRID(ST_GeomFromText('LINESTRING (147.5 -43.1, 172.7 -40.5)'),4326) AS geom,
	'Line' AS gtype,
	'#069917' AS colour

---- SOOP-CO2
UNION ALL
  SELECT DISTINCT 'SOOP' AS facility,
	'CO2' AS subfacility,
	vessel_name AS platform_code,
	ST_CENTROID(ST_COLLECT(geom)) AS geom,
	'Point' AS gtype,
	'#591FBF' AS colour
  FROM soop_co2.soop_co2_trajectory_map
  GROUP BY vessel_name
  
---- SOOP-CPR
UNION ALL
  SELECT DISTINCT 'SOOP' AS facility,
	'CPR' AS subfacility,
	CASE WHEN platform_code = 'Aurora Australia' THEN 'Aurora Australis' ELSE platform_code END AS platform_code,
	CASE WHEN platform_code = 'ANL Windarra' THEN ST_SetSRID(ST_GeomFromText('LINESTRING (138.1 -35.7, 140.7 -38.8, 149.6 -39.2, 154.2 -28.7, 153.4 -26.7)'),4326)
		WHEN platform_code = 'Aurora Australia' THEN ST_SetSRID(ST_GeomFromText('LINESTRING (146.2 -44.3, 89.7 -62.5)'),4326)
		WHEN platform_code = 'Southern Surveyor' THEN ST_SetSRID(ST_GeomFromText('LINESTRING (146.4 -43.9, 114.9 -35.1, 112.5 -22.5, 119.5 -18.9)'),4326)
		WHEN platform_code = 'Rehua' THEN ST_SetSRID(ST_GeomFromText('LINESTRING (148.9 -40.8, 173.1 -40.6)'),4326)
		WHEN platform_code = 'ANL Whyalla' THEN ST_SetSRID(ST_GeomFromText('LINESTRING (118.4 -35.1, 138.3 -35.5)'),4326)
		WHEN platform_code = 'Hespérides' THEN ST_SetSRID(ST_GeomFromText('LINESTRING (115.2 -35.07, 142.4 -40.6)'),4326)
		WHEN platform_code = 'Island Chief' THEN ST_SetSRID(ST_GeomFromText('LINESTRING (151.5 -34.6, 154.5 -27.4, 152.9 -20.5)'),4326)
		WHEN platform_code = 'RV Investigator' THEN ST_SetSRID(ST_GeomFromText('LINESTRING (148.2 -43.4, 151.4 -33.75)'),4326)
		WHEN platform_code = 'Kweichow' THEN ST_SetSRID(ST_GeomFromText('LINESTRING (150.95 -22.2, 145.94 -16.8)'),4326) END AS geom,
	'Line' AS gtype,
	'#F7722A' AS colour
  FROM soop_cpr
	GROUP BY platform_code
	
---- SOOP-TRV
UNION ALL
  SELECT 'SOOP' AS facility,
	'TRV' AS subfacility,
	'Solander' AS platform_code,
	ST_SetSRID(ST_GeomFromText('POINT(121.94 -16.3)'),4326) AS geom,
	'Point' AS gtype,
	'#591FBF' AS colour
UNION ALL
  SELECT 'SOOP' AS facility,
	'TRV' AS subfacility,
	'Cape Ferguson' AS platform_code,
	ST_SetSRID(ST_GeomFromText('POINT(145 -14)'),4326) AS geom,
	'Point' AS gtype,
	'#591FBF' AS colour

---- SOOP-ASF
UNION ALL
  SELECT 'SOOP' AS facility,
	'ASF' AS subfacility,
	vessel_name AS platform_code,
	CASE WHEN vessel_name = 'Tangaroa' THEN ST_SetSRID(ST_GeomFromText('POINT(171.8 -39.8)'),4326) ELSE ST_CENTROID(ST_COLLECT(geom)) END AS geom,
	'Point' AS gtype,
	'#591FBF' AS colour
  FROM soop_asf_mft.soop_asf_mft_trajectory_map
  GROUP BY vessel_name

---- SOOP-SST
UNION ALL
  SELECT 'SOOP' AS facility,
	'SST' AS subfacility,
	vessel_name AS platform_code,
	CASE WHEN vessel_name = 'Xutra Bhum' THEN ST_SetSRID(ST_GeomFromText('POINT(116.3 -7.9)'),4326) 
		WHEN vessel_name = 'Wana Bhum' THEN ST_SetSRID(ST_GeomFromText('POINT(123.8 -36)'),4326)
		WHEN vessel_name = 'Pacific Celebes' THEN ST_SetSRID(ST_GeomFromText('POINT(-131.4 -19)'),4326)
		WHEN vessel_name = 'OOCL Panama' THEN ST_SetSRID(ST_GeomFromText('POINT(105.0 -1.4)'),4326)
		WHEN vessel_name = 'Linnaeus' THEN ST_SetSRID(ST_GeomFromText('POINT(113.13 -24.4)'),4326)
		WHEN vessel_name = 'Iron Yandi' THEN ST_SetSRID(ST_GeomFromText('POINT(126.8 18.9)'),4326)
		WHEN vessel_name = 'Stadacona' THEN ST_SetSRID(ST_GeomFromText('POINT(152 -35)'),4326) ELSE
		ST_CENTROID(ST_COLLECT(geom)) END AS geom,
	'Point' AS gtype,
	'#591FBF' AS colour
  FROM soop_sst.soop_sst_nrt_trajectory_map
--   WHERE vessel_name != 'Pacific Celebes' 
  GROUP BY vessel_name
-- UNION ALL
--   SELECT 'SOOP' AS facility,
-- 	'SST' AS subfacility,
-- 	vessel_name AS platform_code,
-- 	geom,
-- 	'Line' AS gtype,
-- 	'#F0A732' AS colour
--   FROM soop_sst.soop_sst_nrt_trajectory_map
--   WHERE vessel_name = 'Pacific Celebes' AND time_end < '2010-01-11'

---- SRS-Ocean Colour Radiometer
UNION ALL
  SELECT 'SRS' AS facility,
	'Radiometer' AS subfacility,
	'Southern Surveyor' AS platform_code,
	ST_SetSRID(ST_GeomFromText('POINT(166.2 -27.1)'),4326)AS geom,
	'Point' AS gtype,
	'#4D4A49' AS colour
  
---- AATAMS-Biologging
UNION ALL
  SELECT 'AATAMS' AS facility,
	'Biologging' AS subfacility,
	'Emperor Penguins' AS platform_code,
	geom,
	'Point' AS gtype,
	'#15D659' AS colour
  FROM aatams_penguins
UNION ALL
  SELECT 'AATAMS' AS facility,
	'Biologging' AS subfacility,
	'Shearwaters' AS platform_code,
	geom,
	'Point' AS gtype,
	'#15D659' AS colour
  FROM aatams_shearwaters
UNION ALL
	 SELECT 'AATAMS' AS facility,
	'Biologging' AS subfacility,
	platform_code,
	geom,
	'Point' AS gtype,
	'#15D659' AS colour
  FROM aatams_sattag
	WHERE st_x(geom) > 0

---- ABOS-TS
UNION ALL
  SELECT DISTINCT 'ABOS' AS facility,
	'Temperature, Salinity, Currents' AS subfacility,
	CASE WHEN m.platform_code = '' THEN ma.platform_code ELSE m.platform_code END AS platform_code,
	CASE WHEN m.geom IS NULL THEN ma.geom ELSE m.geom END AS platform_code,
	'Point' AS gtype,
	'#CC4712' AS colour
  FROM abos_ts.abos_ts_timeseries_map m
  FULL JOIN abos_currents.abos_currents_map ma ON m.platform_code = ma.platform_code

---- ABOS SOFS AND SOTS
UNION ALL
  SELECT DISTINCT 'ABOS' AS facility,
	'SOFS and SOTS' AS subfacility,
	deployment_number AS platform_code,
	geom AS geom,
	'Point' AS gtype,
	'#CC4712' AS colour
  FROM abos_sofs_fl.abos_sofs_surfaceflux_rt_map
	WHERE deployment_number != ''                

---- ANMN-AM
UNION ALL
  SELECT DISTINCT 'ANMN' AS facility,
	'Acidification' AS subfacility,
	platform_code AS platform_code,
	geom AS geom,
	'Point' AS gtype,
	'#8212CC' AS colour
  FROM anmn_am_dm.anmn_am_dm_map                         

---- ANMN-Burst average
UNION ALL
  SELECT DISTINCT 'ANMN' AS facility,
	'Burst average' AS subfacility,
	platform_code AS platform_code,
	geom AS geom,
	'Point' AS gtype,
	'#8212CC' AS colour
  FROM anmn_burst_avg.anmn_burst_avg_timeseries_map

---- ANMN-MHL wave
UNION ALL
  SELECT DISTINCT 'ANMN' AS facility,
	'Manly wave' AS subfacility,
	platform_code AS platform_code,
	geom AS geom,
	'Point' AS gtype,
	'#8212CC' AS colour
  FROM anmn_mhlwave.anmn_mhlwave_map

---- ANMN-NRS
UNION ALL
  SELECT DISTINCT 'ANMN' AS facility,
	'NRS' AS subfacility,
	"STATION_NAME" AS platform_code,
	geom AS geom,
	'Point' AS gtype,
	'#8212CC' AS colour
  FROM anmn_nrs_bgc.station_name

---- ANMN-AM
UNION ALL
  SELECT DISTINCT 'ANMN' AS facility,
	'Temperature and Salinity' AS subfacility,
	platform_code AS platform_code,
	geom AS geom,
	'Point' AS gtype,
	'#8212CC' AS colour
  FROM anmn_ts.anmn_ts_timeseries_map  
  
---- ANFOG
UNION ALL
  SELECT DISTINCT 'ANFOG' AS facility,
	platform_type AS subfacility,
	substring(deployment_name,'[A-Za-z]*') AS platform_code,
	ST_CENTROID(ST_COLLECT(geom)) AS geom,
	'Point' AS gtype,
	'#FF0000' AS colour
  FROM anfog_dm.anfog_dm_trajectory_map
  GROUP BY platform_type, substring(deployment_name,'[A-Za-z]*')
UNION ALL
  SELECT DISTINCT 'ANFOG' AS facility,
	platform_type AS subfacility,
	substring(deployment_name,'[A-Za-z]*') AS platform_code,
	ST_CENTROID(ST_COLLECT(geom)) AS geom,
	'Point' AS gtype,
	'#FF0000' AS colour
  FROM anfog_rt.anfog_rt_trajectory_map              
  GROUP BY platform_type, substring(deployment_name,'[A-Za-z]*')
  
---- AUV
UNION ALL
  SELECT DISTINCT 'AUV' AS facility,
	NULL AS subfacility,
	substring(campaign_name,'[A-Za-z]*') AS platform_code,
	ST_CENTROID(ST_COLLECT(geom)) AS geom,
	'Point' AS gtype,
	'#FF0000' AS colour
  FROM auv.auv_trajectory_map
  GROUP BY substring(campaign_name,'[A-Za-z]*')

---- ACORN
UNION ALL
  SELECT DISTINCT 'ACORN' AS facility,
	NULL AS subfacility,
	'Turquoise Coast' AS platform_code,
	ST_SetSRID(ST_GeomFromText('POINT(115.0 -30.5)'),4326) AS geom,
	'Point' AS gtype,
	'#FF0000' AS colour
UNION ALL
  SELECT DISTINCT 'ACORN' AS facility,
	NULL AS subfacility,
	'Rottnest Shelf' AS platform_code,
	ST_SetSRID(ST_GeomFromText('POINT(115.75 -32.05)'),4326) AS geom,
-- 	ST_SetSRID(ST_GeomFromText('POLYGON((113.95 -31.3, 115.46 -31.34, 115.58 -32.4, 114.08 -32.34, 113.95 -31.3))'),4326) AS geom,
	'Point' AS gtype,
	'#FF0000' AS colour
UNION ALL
  SELECT DISTINCT 'ACORN' AS facility,
	NULL AS subfacility,
	'South Australian Gulf' AS platform_code,
	ST_SetSRID(ST_GeomFromText('POINT(136.87 -35.3)'),4326) AS geom,
	'Point' AS gtype,
	'#FF0000' AS colour
UNION ALL
  SELECT DISTINCT 'ACORN' AS facility,
	NULL AS subfacility,
	'Bonney Coast' AS platform_code,
	ST_SetSRID(ST_GeomFromText('POINT(140.52 -38.2)'),4326) AS geom,
	'Point' AS gtype,
	'#FF0000' AS colour
UNION ALL
  SELECT DISTINCT 'ACORN' AS facility,
	NULL AS subfacility,
	'Turquoise Coast' AS platform_code,
	ST_SetSRID(ST_GeomFromText('POINT(115.0 -30.5)'),4326) AS geom,
	'Point' AS gtype,
	'#FF0000' AS colour
UNION ALL
  SELECT DISTINCT 'ACORN' AS facility,
	NULL AS subfacility,
	'Coffs Harbour' AS platform_code,
	ST_SetSRID(ST_GeomFromText('POINT(153.0 -30.6)'),4326) AS geom,
	'Point' AS gtype,
	'#FF0000' AS colour
UNION ALL
  SELECT DISTINCT 'ACORN' AS facility,
	NULL AS subfacility,
	'Capricorn Bunker Group' AS platform_code,
	ST_SetSRID(ST_GeomFromText('POINT(152.7 -24.2)'),4326) AS geom,
	'Point' AS gtype,
	'#FF0000' AS colour

---- FAIMMS
UNION ALL
  SELECT DISTINCT 'FAIMMS' AS facility,
	NULL AS subfacility,
	platform_code AS platform_code,
	geom AS geom,
	'Point' AS gtype,
	'#FF0000' AS colour
  FROM faimms.faimms_timeseries_map

---- AATAMS Acoustic
UNION ALL
  SELECT DISTINCT 'AATAMS' AS facility,
	'Acoustic' AS subfacility,
	installation_name AS platform_code,
	ST_CENTROID(ST_COLLECT(geom)) AS geom,
	'Point' AS gtype,
	'#FF0000' AS colour
  FROM dw_aatams_acoustic.installation_summary
  WHERE st_y(geom) < 0
	GROUP BY installation_name

---- SRS Altimetry
UNION ALL
  SELECT DISTINCT 'SRS' AS facility,
	'Altimetry' AS subfacility,
	instrument AS platform_code,
	geom AS geom,
	'Point' AS gtype,
	'#FF0000' AS colour
  FROM srs_altimetry.srs_altimetry_timeseries_map

  ---- SRS Lucinda Jetty
UNION ALL
  SELECT 'SRS' AS facility,
	'Ocean colour' AS subfacility,
	'Lucinda Jetty Coastal Observatory' AS platform_code,
	ST_SetSRID(ST_GeomFromText('POINT(146.39 -18.52)'),4326) AS geom,
	'Point' AS gtype,
	'#FF0000' AS colour;

grant all on asset_map TO public, harvest_read_group;
