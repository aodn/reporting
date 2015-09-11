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
	'Mauritius - WA' AS platform_code,
	ST_SetSRID(ST_GeomFromText('LINESTRING (57.4 -20.2, 90.3 -25.1, 115.18 -34.5)'),4326) AS geom,
	'Line' AS gtype,
	'#069917' AS colour
UNION ALL
  SELECT 'SOOP' AS facility,
	'BA' AS subfacility,
	'Mauritius - South Madagascar' AS platform_code,
	ST_SetSRID(ST_GeomFromText('LINESTRING (57.4 -20.2, 48.9 -35.7)'),4326) AS geom,
	'Line' AS gtype,
	'#069917' AS colour
UNION ALL
  SELECT 'SOOP' AS facility,
	'BA' AS subfacility,
	'Tasman Sea' AS platform_code,
	ST_SetSRID(ST_GeomFromText('LINESTRING (147.5 -43.1, 172.7 -40.5)'),4326) AS geom,
	'Line' AS gtype,
	'#069917' AS colour
UNION ALL
  SELECT 'SOOP' AS facility,
	'BA' AS subfacility,
	'Hobart - Fiji' AS platform_code,
	ST_SetSRID(ST_GeomFromText('LINESTRING (147.5 -43.1, 177.4 -18.2)'),4326) AS geom,
	'Line' AS gtype,
	'#069917' AS colour

---- SOOP-CO2 and SOOP-ASF
UNION ALL
  SELECT DISTINCT 'SOOP' AS facility,
	'CO2 and ASF' AS subfacility,
	vessel_name AS platform_code,
	CASE WHEN vessel_name = 'RV Tangaroa' THEN ST_SetSRID(ST_GeomFromText('LINESTRING (177.4 -35.85, 167.9 -32.3, 174.77 -48.1, 170.2 -52.7, 170.7 -46.4, 147.3 -65.6, 140.1 -65, 140 -60.5, 159.5 -56.6, 178.5 -38.7)'),4326)
		WHEN vessel_name = 'Aurora Australis' THEN ST_SetSRID(ST_GeomFromText('LINESTRING (147.7 -43.6, 131.2 -64.5, 59.5 -66.1, 115.18 -32.3, 114.8 -61.5)'),4326)
		WHEN vessel_name = 'L''Astrolabe' THEN ST_SetSRID(ST_GeomFromText('LINESTRING (147.3 -43.4, 137.3 -64.1, 155.8 -64.9, 147.3 -43.4)'),4326)
		WHEN vessel_name = 'Southern Surveyor' THEN make_trajectory(ST_SetSRID(ST_GeomFromText('LINESTRING (141.9 -46.9, 148.8 -43.1, 154.2 -26.9, 143.8 -10, 129.9 -10.7, 112.7 -21.6, 113.2 -31.3, 100 -25, 100 -29, 116.75 -35.3,
		131.4 -33.75, 148.75 -40.6, -172.6 -13, -171.17 -49, 174.1 -41.1)'),4326)) END AS geom,
	'Line' AS gtype,
	'#ED3B8B' AS colour
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
	ST_SetSRID(ST_GeomFromText('LINESTRING (113.9 -28.8, 112.86 -26, 113.76 -21.9, 122.1 -18, 121.8 -17.2, 124 -15.72, 125.7 -13.6, 130.6 -12.3, 127.4 -8.5, 116 -20.5)'),4326) AS geom,
	'Point' AS gtype,
	'#E69777' AS colour
UNION ALL
  SELECT 'SOOP' AS facility,
	'TRV' AS subfacility,
	'Cape Ferguson' AS platform_code,
	ST_SetSRID(ST_GeomFromText('LINESTRING (151.76 -23.5, 148.8 -20.06, 146.7 -18.7, 146 -16.8, 145.4 -14.7, 143.3 -11.4)'),4326) AS geom,
	'Point' AS gtype,
	'#E69777' AS colour

---- SOOP-SST
UNION ALL
  SELECT 'SOOP' AS facility,
	'SST' AS subfacility,
	vessel_name AS platform_code,
	CASE WHEN vessel_name = 'Highland Chief' THEN ST_SetSRID(ST_GeomFromText('LINESTRING(144.9 -38.3, 146.8 -39.5, 150.2 -37.9, 154.6 -26.7, 159.7 -9.1, 172.8 1.25, 139.5 34.8)'),4326) 
		WHEN vessel_name = 'Iron Yandi' THEN ST_SetSRID(ST_GeomFromText('LINESTRING(118.7 38.7, 123.46 37.5, 126.6 26.56, 127.4 4.4, 118.4 -20.2)'),4326)
		WHEN vessel_name = 'Pacific Celebes' THEN make_trajectory(ST_SetSRID(ST_GeomFromText('LINESTRING(152.1 -33.4, -125.26 48, -124.9 40.3, -118.76 32.4, -149.3 -17.6, -79.7 7.4, -79.56 12.32, -89.7 29.7, -79.4 23.4, -73.93 38.5, -66.4 42.7,
		-6.26 36.06, 8.67 38.34, 32.23 31.48, 33.28 28.32, 43.66 12.1, 71.8 18.65, 76.35 8.28, 80.57 5.5, 96.0 6.2, 110.6 -4.4, 20.6 -35.8, -73.93 38.5)'),4326))
		WHEN vessel_name = 'OOCL Panama' THEN ST_SetSRID(ST_GeomFromText('LINESTRING(143.4 -38.95, 117.2 -35.6, 114.9 -34.56, 105.05 -6.7, 107.95 -4.3, 104.4 1.38)'),4326)
		WHEN vessel_name = 'Pacific Sun' THEN ST_SetSRID(ST_GeomFromText('LINESTRING(151.5 -33.9, 169.65 -20.3, 167.36 -15.58, 153.4 -27, 153.3 -21.7, 150.4 -16.28, 145.8 -16.5, 144.4 -10.5, 132 -10.8, 131.1 -12.2)'),4326)
		WHEN vessel_name = 'Portland' THEN ST_SetSRID(ST_GeomFromText('LINESTRING(119.55 34.7, 123 34.6, 124.6 30.9, 119.5 15.97, 121.4 10.4, 118.3 -3.4, 112.25 -25.1, 115.6 -32.25)'),4326)
		WHEN vessel_name = 'Stadacona' THEN ST_SetSRID(ST_GeomFromText('LINESTRING(125.1 29.8, 145.6 -4.5, 151.2 -8.3, 153.6 -20.6, 151.2 -23.5)'),4326)
		WHEN vessel_name = 'WAKMATHA' THEN ST_SetSRID(ST_GeomFromText('LINESTRING(141.6 -12.7, 141.5 -11.3, 142.75 -10.7, 145.4 -14.7, 146.5 -18.5, 149.1 -20, 151.5 -23.7)'),4326)
		WHEN vessel_name = 'L''Astrolabe' THEN ST_SetSRID(ST_GeomFromText('LINESTRING(147.4 -43.1, 159.03 -54.5, 141.5 -66.4, 147.4 -43.1)'),4326)
		WHEN vessel_name = 'Wana Bhum' THEN ST_SetSRID(ST_GeomFromText('LINESTRING(103.9 1.1, 105.1 1.2, 117.3 -8.1, 125.8 -8, 142.58 -10.54, 145.4 -14.7, 153.5 -24.56, 153.17 -27.33)'),4326) END AS geom,
	'Line' AS gtype,
	'#F0A732' AS colour
  FROM soop_sst.soop_sst_nrt_trajectory_map
  WHERE vessel_name NOT IN ('Fantasea Wonder', 'Xutra Bhum', 'Spirit of Tasmania 2', 'RV Cape Ferguson', 'Linnaeus', 'SeaFlyte')
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
