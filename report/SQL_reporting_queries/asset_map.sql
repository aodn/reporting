SET SEARCH_PATH = report_test, public;
DROP TABLE IF EXISTS asset_map;

-------------------------------
-- Generate new asset map
------------------------------- 
CREATE TABLE asset_map AS
WITH soop_cpr AS (
  SELECT vessel_name AS platform_code,
	min("TIME") AS date_start,
	max("TIME") AS date_end,
	ST_CENTROID(ST_COLLECT(geom)) AS geom
  FROM soop_auscpr.soop_auscpr_pci_trajectory_map 
    WHERE vessel_name != 'RV Cape Ferguson' AND vessel_name != 'RV Solander'
	GROUP BY vessel_name),
  aatams_sattag_dm AS (
  SELECT device_id,
	min(timestamp) AS date_start,
	max(timestamp) AS date_end,
	ST_CENTROID(ST_COLLECT(geom)) AS geom
  FROM aatams_sattag_dm.aatams_sattag_dm_profile_map
	GROUP BY device_id 
	ORDER BY random()
	LIMIT 35),
  aatams_sattag_nrt AS (
  SELECT device_id,
	min(timestamp) AS date_start,
	max(timestamp) AS date_end,
	ST_CENTROID(ST_COLLECT(geom)) AS geom
  FROM aatams_sattag_nrt.aatams_sattag_nrt_profile_map
	GROUP BY device_id 
	ORDER BY random()
	LIMIT 35),
  aatams_penguins AS(
  SELECT pttid, 
	min(observation_start_date) AS date_start,
	max(observation_end_date) AS date_end,
	ST_CENTROID(geom) AS geom
  FROM aatams_biologging_penguin.aatams_biologging_penguin_map
	GROUP BY pttid
  	ORDER BY random()
	LIMIT 25),
  aatams_shearwaters AS(
  SELECT animal_id,
	min(start_date) AS date_start,
	max(end_date) AS date_end,
	ST_CENTROID(geom) AS geom
  FROM aatams_biologging_shearwater.aatams_biologging_shearwater_map
	GROUP BY animal_id
  	ORDER BY random()
	LIMIT 25),
  aatams_snowpetrel AS(
  SELECT animal_id,
	min(start_date) AS date_start,
	max(end_date) AS date_end,
	ST_CENTROID(geom) AS geom
  FROM aatams_biologging_snowpetrel.aatams_biologging_snowpetrel_map
	GROUP BY animal_id
  	ORDER BY random()
	LIMIT 25),
  a AS (SELECT DISTINCT "STATION_NAME", min("UTC_TRIP_START_TIME") AS date_start, max("UTC_TRIP_START_TIME") AS date_end FROM anmn_nrs_bgc.anmn_nrs_bgc_chemistry GROUP BY "STATION_NAME"),
  b AS (SELECT DISTINCT "STATION_NAME", min("UTC_TRIP_START_TIME") AS date_start, max("UTC_TRIP_START_TIME") AS date_end FROM anmn_nrs_bgc.anmn_nrs_bgc_phypig GROUP BY "STATION_NAME"),
  c AS (SELECT DISTINCT "STATION_NAME", min("UTC_TRIP_START_TIME") AS date_start, max("UTC_TRIP_START_TIME") AS date_end FROM anmn_nrs_bgc.anmn_nrs_bgc_picoplankton GROUP BY "STATION_NAME"),
  d AS (SELECT DISTINCT "STATION_NAME", min("UTC_TRIP_START_TIME") AS date_start, max("UTC_TRIP_START_TIME") AS date_end FROM anmn_nrs_bgc.anmn_nrs_bgc_plankton_biomass GROUP BY "STATION_NAME"),
  e AS (SELECT DISTINCT "STATION_NAME", min("UTC_TRIP_START_TIME") AS date_start, max("UTC_TRIP_START_TIME") AS date_end FROM anmn_nrs_bgc.anmn_nrs_bgc_plankton_phytoplankton GROUP BY "STATION_NAME"),
  f AS (SELECT DISTINCT "STATION_NAME", min("UTC_TRIP_START_TIME") AS date_start, max("UTC_TRIP_START_TIME") AS date_end FROM anmn_nrs_bgc.anmn_nrs_bgc_plankton_zooplankton GROUP BY "STATION_NAME"),
  g AS (SELECT * FROM a UNION ALL SELECT * FROM b UNION ALL SELECT * FROM c UNION ALL SELECT * FROM d UNION ALL SELECT * FROM e UNION ALL SELECT * FROM f),
  h AS (SELECT DISTINCT "STATION_NAME", min(date_start) AS date_start, max(date_end) AS date_end FROM g GROUP BY "STATION_NAME")
	
---- Argo
  SELECT 'Argo'::text AS facility,
	NULL::text AS subfacility,
	NULL AS product,
	platform_number::text AS platform_code,
	'Argo float' AS platform_type,
	start_date AS date_start,
	last_measure_date AS date_end,
	TRUE AS w_temp_b,
	TRUE AS w_psal_b,
	oxygen_sensor AS w_oxygen_b,
	FALSE AS w_co2_b,
	FALSE AS w_chlorophyll_b,
	FALSE AS turb_b,
	FALSE AS w_current_b,
	FALSE AS wave_b,
	FALSE AS air_temperature_b,
	FALSE AS air_pressure_b,
	FALSE AS air_co2_b,
	FALSE AS wind_b,
	FALSE AS plankton_b,
	FALSE AS optical_properties_b,
	FALSE AS animal_location_b,
	ST_SETSRID(last_location,4326) AS geom,
	'Point'::text AS gtype,
	'#85BF1F' AS colour
  FROM argo.argo_float
	WHERE data_centre_code = 'CS'
	
---- SOOP-XBT
UNION ALL

  SELECT 'SOOP' AS facility,
	'XBT' AS subfacility,
	NULL AS product,
	"XBT_line" AS platform_code,
	'Vessel' AS platform_type,
	min("TIME") AS date_start,
	max("TIME") AS date_end,
	TRUE AS w_temp_b,
	FALSE AS w_psal_b,
	FALSE AS w_oxygen_b,
	FALSE AS w_co2_b,
	FALSE AS w_chlorophyll_b,
	FALSE AS turb_b,
	FALSE AS w_current_b,
	FALSE AS wave_b,
	FALSE AS air_temperature_b,
	FALSE AS air_pressure_b,
	FALSE AS air_co2_b,
	FALSE AS wind_b,
	FALSE AS plankton_b,
	FALSE AS optical_properties_b,
	FALSE AS animal_location_b,
	ST_SetSRID(ST_GeomFromText('LINESTRING(52.0 11.6,115.0 -32.0)'),4326) AS geom,
	'Line' AS gtype,
	'#591FBF' AS colour
  FROM soop_xbt_dm.soop_xbt_dm_profile_map
	WHERE "XBT_line" = 'IX12'
	GROUP BY "XBT_line"
	
UNION ALL

  SELECT 'SOOP' AS facility,
	'XBT' AS subfacility,
	NULL AS product,
	"XBT_line" AS platform_code,
	'Vessel' AS platform_type,
	min("TIME") AS date_start,
	max("TIME") AS date_end,
	TRUE AS w_temp_b,
	FALSE AS w_psal_b,
	FALSE AS w_oxygen_b,
	FALSE AS w_co2_b,
	FALSE AS w_chlorophyll_b,
	FALSE AS turb_b,
	FALSE AS w_current_b,
	FALSE AS wave_b,
	FALSE AS air_temperature_b,
	FALSE AS air_pressure_b,
	FALSE AS air_co2_b,
	FALSE AS wind_b,
	FALSE AS plankton_b,
	FALSE AS optical_properties_b,
	FALSE AS animal_location_b,
	ST_SetSRID(ST_GeomFromText('LINESTRING(115.0 -32.0,105.0 -7.0)'),4326) AS geom,
	'Line' AS gtype,
	'#591FBF' AS colour
  FROM soop_xbt_dm.soop_xbt_dm_profile_map
	WHERE "XBT_line" = 'IX1'
	GROUP BY "XBT_line"
	
UNION ALL

  SELECT 'SOOP' AS facility,
	'XBT' AS subfacility,
	NULL AS product,
	"XBT_line" AS platform_code,
	'Vessel' AS platform_type,
	min("TIME") AS date_start,
	max("TIME") AS date_end,
	TRUE AS w_temp_b,
	FALSE AS w_psal_b,
	FALSE AS w_oxygen_b,
	FALSE AS w_co2_b,
	FALSE AS w_chlorophyll_b,
	FALSE AS turb_b,
	FALSE AS w_current_b,
	FALSE AS wave_b,
	FALSE AS air_temperature_b,
	FALSE AS air_pressure_b,
	FALSE AS air_co2_b,
	FALSE AS wind_b,
	FALSE AS plankton_b,
	FALSE AS optical_properties_b,
	FALSE AS animal_location_b,
	ST_SetSRID(ST_GeomFromText('LINESTRING(115.4 -5.66, 121 -7.58, 125.41 -8.04, 127.5 -8.24, 129.44 -8.81, 134 -9.36)'),4326) AS geom, 
	'Line' AS gtype,
	'#591FBF' AS colour
  FROM soop_xbt_dm.soop_xbt_dm_profile_map
	WHERE "XBT_line" = 'PX2'
	GROUP BY "XBT_line"
	
UNION ALL

  SELECT 'SOOP' AS facility,
	'XBT' AS subfacility,
	NULL AS product,
	"XBT_line" AS platform_code,
	'Vessel' AS platform_type,
	min("TIME") AS date_start,
	max("TIME") AS date_end,
	TRUE AS w_temp_b,
	FALSE AS w_psal_b,
	FALSE AS w_oxygen_b,
	FALSE AS w_co2_b,
	FALSE AS w_chlorophyll_b,
	FALSE AS turb_b,
	FALSE AS w_current_b,
	FALSE AS wave_b,
	FALSE AS air_temperature_b,
	FALSE AS air_pressure_b,
	FALSE AS air_co2_b,
	FALSE AS wind_b,
	FALSE AS plankton_b,
	FALSE AS optical_properties_b,
	FALSE AS animal_location_b,
	ST_SetSRID(ST_GeomFromText('LINESTRING(118.4 -18.3, 124 -8.2, 125.8 -3, 126.7 -1.7, 131.5 20.5)'),4326) AS geom,
	'Line' AS gtype,
	'#591FBF' AS colour
  FROM soop_xbt_dm.soop_xbt_dm_profile_map
	WHERE "XBT_line" = 'IX22-PX11'
	GROUP BY "XBT_line"
	
UNION ALL
  SELECT 'SOOP' AS facility,
	'XBT' AS subfacility,
	NULL AS product,
	"XBT_line" AS platform_code,
	'Vessel' AS platform_type,
	min("TIME") AS date_start,
	max("TIME") AS date_end,
	TRUE AS w_temp_b,
	FALSE AS w_psal_b,
	FALSE AS w_oxygen_b,
	FALSE AS w_co2_b,
	FALSE AS w_chlorophyll_b,
	FALSE AS turb_b,
	FALSE AS w_current_b,
	FALSE AS wave_b,
	FALSE AS air_temperature_b,
	FALSE AS air_pressure_b,
	FALSE AS air_co2_b,
	FALSE AS wind_b,
	FALSE AS plankton_b,
	FALSE AS optical_properties_b,
	FALSE AS animal_location_b,
	ST_SetSRID(ST_GeomFromText('LINESTRING(153.4 -26.6, 167.8 -23.2, 177.45 -18.4)'),4326) AS geom,
	'Line' AS gtype,
	'#591FBF' AS colour
  FROM soop_xbt_dm.soop_xbt_dm_profile_map
	WHERE "XBT_line" = 'PX30-31'
	GROUP BY "XBT_line"
	
UNION ALL

  SELECT 'SOOP' AS facility,
	'XBT' AS subfacility,
	NULL AS product,
	"XBT_line" AS platform_code,
	'Vessel' AS platform_type,
	min("TIME") AS date_start,
	max("TIME") AS date_end,
	TRUE AS w_temp_b,
	FALSE AS w_psal_b,
	FALSE AS w_oxygen_b,
	FALSE AS w_co2_b,
	FALSE AS w_chlorophyll_b,
	FALSE AS turb_b,
	FALSE AS w_current_b,
	FALSE AS wave_b,
	FALSE AS air_temperature_b,
	FALSE AS air_pressure_b,
	FALSE AS air_co2_b,
	FALSE AS wind_b,
	FALSE AS plankton_b,
	FALSE AS optical_properties_b,
	FALSE AS animal_location_b,
	ST_SetSRID(ST_GeomFromText('LINESTRING(173.2 -40, 151.5 -33.9)'),4326) AS geom,
	'Line' AS gtype,
	'#591FBF' AS colour
  FROM soop_xbt_dm.soop_xbt_dm_profile_map
	WHERE "XBT_line" = 'PX34'
	GROUP BY "XBT_line"
	
UNION ALL

  SELECT 'SOOP' AS facility,
	'XBT' AS subfacility,
	NULL AS product,
	"XBT_line" AS platform_code,
	'Vessel' AS platform_type,
	min("TIME") AS date_start,
	max("TIME") AS date_end,
	TRUE AS w_temp_b,
	FALSE AS w_psal_b,
	FALSE AS w_oxygen_b,
	FALSE AS w_co2_b,
	FALSE AS w_chlorophyll_b,
	FALSE AS turb_b,
	FALSE AS w_current_b,
	FALSE AS wave_b,
	FALSE AS air_temperature_b,
	FALSE AS air_pressure_b,
	FALSE AS air_co2_b,
	FALSE AS wind_b,
	FALSE AS plankton_b,
	FALSE AS optical_properties_b,
	FALSE AS animal_location_b,
	ST_SetSRID(ST_GeomFromText('LINESTRING (147.4 -43.5, 140 -66.2)'),4326) AS geom,
	'Line' AS gtype,
	'#591FBF' AS colour
  FROM soop_xbt_dm.soop_xbt_dm_profile_map
	WHERE "XBT_line" = 'IX28'
	GROUP BY "XBT_line"
	
---- SOOP-TMV
UNION ALL

  SELECT 'SOOP' AS facility,
	'TMV' AS subfacility,
	NULL AS product,
	'Spirit of Tasmania' AS platform_code,
	'Vessel' AS platform_type,
	min(time_start) AS date_start,
	max(time_end) AS date_end,
	TRUE AS w_temp_b,
	TRUE AS w_psal_b,
	FALSE AS w_oxygen_b,
	FALSE AS w_co2_b,
	TRUE AS w_chlorophyll_b,
	TRUE AS turb_b,
	FALSE AS w_current_b,
	FALSE AS wave_b,
	FALSE AS air_temperature_b,
	FALSE AS air_pressure_b,
	FALSE AS air_co2_b,
	FALSE AS wind_b,
	FALSE AS plankton_b,
	FALSE AS optical_properties_b,
	FALSE AS animal_location_b,
	ST_SetSRID(ST_GeomFromText('POINT(145.60 -39.84)'),4326) AS geom,
	'Point' AS gtype,
	'#591FBF' AS colour
FROM soop_tmv_nrt.soop_tmv_nrt_trajectory_map

---- SOOP-BA
UNION ALL
  SELECT 'SOOP' AS facility,
	'BA' AS subfacility,
	NULL AS product,
	'Indian Ocean' AS platform_code,
	'Vessel' AS platform_type,
	min(time_start) AS date_start,
	max(time_end) AS date_end,
	TRUE AS w_temp_b,
	TRUE AS w_psal_b,
	FALSE AS w_oxygen_b,
	FALSE AS w_co2_b,
	FALSE AS w_chlorophyll_b,
	FALSE AS turb_b,
	FALSE AS w_current_b,
	FALSE AS wave_b,
	FALSE AS air_temperature_b,
	FALSE AS air_pressure_b,
	FALSE AS air_co2_b,
	FALSE AS wind_b,
	FALSE AS plankton_b,
	TRUE AS optical_properties_b,
	FALSE AS animal_location_b,
	ST_SetSRID(ST_GeomFromText('LINESTRING (57.4 -20.2, 70 -49.1)'),4326) AS geom,
	'Line' AS gtype,
	'#069917' AS colour
  FROM soop_ba.visualisation_wms
	WHERE vessel_name IN ('Austral Leader II','Southern Champion')
	
UNION ALL

  SELECT 'SOOP' AS facility,
	'BA' AS subfacility,
	NULL AS product,
	'Mauritius - WA' AS platform_code,
	'Vessel' AS platform_type,
	min(time_start) AS date_start,
	max(time_end) AS date_end,
	TRUE AS w_temp_b,
	TRUE AS w_psal_b,
	FALSE AS w_oxygen_b,
	FALSE AS w_co2_b,
	FALSE AS w_chlorophyll_b,
	FALSE AS turb_b,
	FALSE AS w_current_b,
	FALSE AS wave_b,
	FALSE AS air_temperature_b,
	FALSE AS air_pressure_b,
	FALSE AS air_co2_b,
	FALSE AS wind_b,
	FALSE AS plankton_b,
	TRUE AS optical_properties_b,
	FALSE AS animal_location_b,
	ST_SetSRID(ST_GeomFromText('LINESTRING (57.4 -20.2, 90.3 -25.1, 115.18 -34.5)'),4326) AS geom,
	'Line' AS gtype,
	'#069917' AS colour
  FROM soop_ba.visualisation_wms
	WHERE vessel_name IN ('Kaharoa')
	
UNION ALL

  SELECT 'SOOP' AS facility,
	'BA' AS subfacility,
	NULL AS product,
	'Mauritius - South Madagascar' AS platform_code,
	'Vessel' AS platform_type,
	min(time_start) AS date_start,
	max(time_end) AS date_end,
	TRUE AS w_temp_b,
	TRUE AS w_psal_b,
	FALSE AS w_oxygen_b,
	FALSE AS w_co2_b,
	FALSE AS w_chlorophyll_b,
	FALSE AS turb_b,
	FALSE AS w_current_b,
	FALSE AS wave_b,
	FALSE AS air_temperature_b,
	FALSE AS air_pressure_b,
	FALSE AS air_co2_b,
	FALSE AS wind_b,
	FALSE AS plankton_b,
	TRUE AS optical_properties_b,
	FALSE AS animal_location_b,
	ST_SetSRID(ST_GeomFromText('LINESTRING (57.4 -20.2, 48.9 -35.7)'),4326) AS geom,
	'Line' AS gtype,
	'#069917' AS colour
  FROM soop_ba.visualisation_wms
	WHERE vessel_name IN ('Will Watch')
	
UNION ALL

  SELECT 'SOOP' AS facility,
	'BA' AS subfacility,
	NULL AS product,
	'Tasman Sea' AS platform_code,
	'Vessel' AS platform_type,
	min(time_start) AS date_start,
	max(time_end) AS date_end,
	TRUE AS w_temp_b,
	TRUE AS w_psal_b,
	FALSE AS w_oxygen_b,
	FALSE AS w_co2_b,
	FALSE AS w_chlorophyll_b,
	FALSE AS turb_b,
	FALSE AS w_current_b,
	FALSE AS wave_b,
	FALSE AS air_temperature_b,
	FALSE AS air_pressure_b,
	FALSE AS air_co2_b,
	FALSE AS wind_b,
	FALSE AS plankton_b,
	TRUE AS optical_properties_b,
	FALSE AS animal_location_b,
	ST_SetSRID(ST_GeomFromText('LINESTRING (147.5 -43.1, 172.7 -40.5)'),4326) AS geom,
	'Line' AS gtype,
	'#069917' AS colour
  FROM soop_ba.visualisation_wms
	WHERE vessel_name IN ('Aurora Australis','Janas','Kaharoa','Rehua')
	
UNION ALL

  SELECT 'SOOP' AS facility,
	'BA' AS subfacility,
	NULL AS product,
	'Hobart - Fiji' AS platform_code,
	'Vessel' AS platform_type,
	min(time_start) AS date_start,
	max(time_end) AS date_end,
	TRUE AS w_temp_b,
	TRUE AS w_psal_b,
	FALSE AS w_oxygen_b,
	FALSE AS w_co2_b,
	FALSE AS w_chlorophyll_b,
	FALSE AS turb_b,
	FALSE AS w_current_b,
	FALSE AS wave_b,
	FALSE AS air_temperature_b,
	FALSE AS air_pressure_b,
	FALSE AS air_co2_b,
	FALSE AS wind_b,
	FALSE AS plankton_b,
	TRUE AS optical_properties_b,
	FALSE AS animal_location_b,
	ST_SetSRID(ST_GeomFromText('LINESTRING (147.5 -43.1, 177.4 -18.2)'),4326) AS geom,
	'Line' AS gtype,
	'#069917' AS colour
  FROM soop_ba.visualisation_wms
	WHERE vessel_name IN ('Southern Surveyor')

---- SOOP-CO2 and SOOP-ASF
UNION ALL

SELECT DISTINCT 'SOOP' AS facility,
	'CO2 and ASF' AS subfacility,
	NULL AS product,
	vessel_name AS platform_code,
	'Vessel' AS platform_type,
	min(time_start) AS date_start,
	max(time_end) AS date_end,	
	TRUE AS w_temp_b,
	TRUE AS w_psal_b,
	FALSE AS w_oxygen_b,
	TRUE AS w_co2_b,
	FALSE AS w_chlorophyll_b,
	FALSE AS turb_b,
	FALSE AS w_current_b,
	FALSE AS wave_b,
	TRUE AS air_temperature_b,
	TRUE AS air_pressure_b,
	TRUE AS air_co2_b,
	TRUE AS wind_b,
	FALSE AS plankton_b,
	TRUE AS optical_properties_b,
	FALSE AS animal_location_b,
	CASE WHEN vessel_name = 'RV Tangaroa' THEN ST_SetSRID(ST_GeomFromText('LINESTRING (177.4 -35.85, 167.9 -32.3, 174.77 -48.1, 170.2 -52.7, 170.7 -46.4, 147.3 -65.6, 140.1 -65, 140 -60.5, 159.5 -56.6, 178.5 -38.7)'),4326)
		WHEN vessel_name = 'Aurora Australis' THEN ST_SetSRID(ST_GeomFromText('LINESTRING (147.7 -43.6, 131.2 -64.5, 59.5 -66.1, 115.18 -32.3, 114.8 -61.5)'),4326)
		WHEN vessel_name = 'L''Astrolabe' THEN ST_SetSRID(ST_GeomFromText('LINESTRING (147.3 -43.4, 137.3 -64.1, 155.8 -64.9, 147.3 -43.4)'),4326)
		WHEN vessel_name = 'Southern Surveyor' THEN ST_SetSRID(ST_GeomFromText('MULTILINESTRING((141.9 -46.9, 148.8 -43.1, 154.2 -26.9, 143.8 -10, 129.9 -10.7, 112.7 -21.6, 113.2 -31.3, 100 -25, 100 -29, 116.75 -35.3,
		131.4 -33.75, 148.75 -40.6, 180 -20),(-180 -20, -172.6 -13, -171.17 -49, -180 -45), (180 -45, 174.1 -41.1))'),4326) END AS geom,
	'Line' AS gtype,
	'#ED3B8B' AS colour
  FROM soop_co2.soop_co2_trajectory_map
  GROUP BY vessel_name
  
---- SOOP-CPR
UNION ALL

  SELECT DISTINCT 'SOOP' AS facility,
	'CPR' AS subfacility,
	NULL AS product,
	CASE WHEN platform_code = 'Aurora Australia' THEN 'Aurora Australis' ELSE platform_code END AS platform_code,
	'Vessel' AS platform_type,
	date_start,
	date_end,	
	FALSE AS w_temp_b,
	FALSE AS w_psal_b,
	FALSE AS w_oxygen_b,
	FALSE AS w_co2_b,
	FALSE AS w_chlorophyll_b,
	FALSE AS turb_b,
	FALSE AS w_current_b,
	FALSE AS wave_b,
	FALSE AS air_temperature_b,
	FALSE AS air_pressure_b,
	FALSE AS air_co2_b,
	FALSE AS wind_b,
	TRUE AS plankton_b,
	FALSE AS optical_properties_b,
	FALSE AS animal_location_b,
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
	
---- SOOP-TRV
UNION ALL
  SELECT 'SOOP' AS facility,
	'TRV' AS subfacility,
	NULL AS product,
	'Solander' AS platform_code,
	'Vessel' AS platform_type,
	min(time_start) AS date_start,
	max(time_end) AS date_end,	
	TRUE AS w_temp_b,
	TRUE AS w_psal_b,
	FALSE AS w_oxygen_b,
	FALSE AS w_co2_b,
	TRUE AS w_chlorophyll_b,
	TRUE AS turb_b,
	FALSE AS w_current_b,
	FALSE AS wave_b,
	FALSE AS air_temperature_b,
	FALSE AS air_pressure_b,
	FALSE AS air_co2_b,
	FALSE AS wind_b,
	FALSE AS plankton_b,
	FALSE AS optical_properties_b,
	FALSE AS animal_location_b,
	ST_SetSRID(ST_GeomFromText('LINESTRING (113.9 -28.8, 112.86 -26, 113.76 -21.9, 122.1 -18, 121.8 -17.2, 124 -15.72, 125.7 -13.6, 130.6 -12.3, 127.4 -8.5, 116 -20.5)'),4326) AS geom,
	'Point' AS gtype,
	'#E69777' AS colour
  FROM soop_trv.soop_trv_trajectory_map
	WHERE vessel_name = 'Solander'
	
UNION ALL

  SELECT 'SOOP' AS facility,
	'TRV' AS subfacility,
	NULL AS product,
	'Cape Ferguson' AS platform_code,
	'Vessel' AS platform_type,
	min(time_start) AS date_start,
	max(time_end) AS date_end,	
	TRUE AS w_temp_b,
	TRUE AS w_psal_b,
	FALSE AS w_oxygen_b,
	FALSE AS w_co2_b,
	TRUE AS w_chlorophyll_b,
	TRUE AS turb_b,
	FALSE AS w_current_b,
	FALSE AS wave_b,
	FALSE AS air_temperature_b,
	FALSE AS air_pressure_b,
	FALSE AS air_co2_b,
	FALSE AS wind_b,
	FALSE AS plankton_b,
	FALSE AS optical_properties_b,
	FALSE AS animal_location_b,
	ST_SetSRID(ST_GeomFromText('LINESTRING (151.76 -23.5, 148.8 -20.06, 146.7 -18.7, 146 -16.8, 145.4 -14.7, 143.3 -11.4)'),4326) AS geom,
	'Point' AS gtype,
	'#E69777' AS colour
  FROM soop_trv.soop_trv_trajectory_map
	WHERE vessel_name = 'Cape Ferguson'

---- SOOP-SST
UNION ALL
  SELECT 'SOOP' AS facility,
	'SST' AS subfacility,
	NULL AS product,
	vessel_name AS platform_code,
	'Vessel' AS platform_type,
	min(time_start) AS date_start,
	max(time_end) AS date_end,
	TRUE AS w_temp_b,
	TRUE AS w_psal_b,
	FALSE AS w_oxygen_b,
	FALSE AS w_co2_b,
	FALSE AS w_chlorophyll_b,
	FALSE AS turb_b,
	FALSE AS w_current_b,
	FALSE AS wave_b,
	TRUE AS air_temperature_b,
	TRUE AS air_pressure_b,
	FALSE AS air_co2_b,
	TRUE AS wind_b,
	FALSE AS plankton_b,
	TRUE AS optical_properties_b,
	FALSE AS animal_location_b,
	CASE WHEN vessel_name = 'Highland Chief' THEN ST_SetSRID(ST_GeomFromText('LINESTRING(144.9 -38.3, 146.8 -39.5, 150.2 -37.9, 154.6 -26.7, 159.7 -9.1, 172.8 1.25, 139.5 34.8)'),4326) 
		WHEN vessel_name = 'Iron Yandi' THEN ST_SetSRID(ST_GeomFromText('LINESTRING(118.7 38.7, 123.46 37.5, 126.6 26.56, 127.4 4.4, 118.4 -20.2)'),4326)
		WHEN vessel_name = 'Pacific Celebes' THEN ST_SetSRID(ST_GeomFromText('MULTILINESTRING((152.1 -33.4, 180 5),(-180 5, -125.26 48, -124.9 40.3, -118.76 32.4, -149.3 -17.6, -79.7 7.4, -79.56 12.32, -89.7 29.7, -79.4 23.4, -73.93 38.5, -66.4 42.7,
		-6.26 36.06, 8.67 38.34, 32.23 31.48, 33.28 28.32, 43.66 12.1, 71.8 18.65, 76.35 8.28, 80.57 5.5, 96.0 6.2, 110.6 -4.4, 20.6 -35.8, -73.93 38.5))'),4326)
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

---- SRS-Ocean Colour Radiometer
UNION ALL

  SELECT 'SRS' AS facility,
	NULL AS subfacility,
	'Radiometer' AS product,
	'Southern Surveyor' AS platform_code,
	'Vessel' AS platform_type,
	min(time_start) AS date_start,
	max(time_end) AS date_end,
	FALSE AS w_temp_b,
	FALSE AS w_psal_b,
	FALSE AS w_oxygen_b,
	FALSE AS w_co2_b,
	FALSE AS w_chlorophyll_b,
	FALSE AS turb_b,
	FALSE AS w_current_b,
	FALSE AS wave_b,
	FALSE AS air_temperature_b,
	FALSE AS air_pressure_b,
	FALSE AS air_co2_b,
	FALSE AS wind_b,
	FALSE AS plankton_b,
	TRUE AS optical_properties_b,
	FALSE AS animal_location_b,
	ST_SetSRID(ST_GeomFromText('POINT(166.2 -27.1)'),4326)AS geom,
	'Point' AS gtype,
	'#4D4A49' AS colour
  FROM srs_oc_soop_rad.srs_oc_soop_rad_trajectory_map
	WHERE vessel_name = 'Southern Surveyor'
  
---- AATAMS-Biologging
UNION ALL

  SELECT 'AATAMS' AS facility,
	'Biologging' AS subfacility,
	NULL AS product,
	pttid AS platform_code,
	'Emperor Penguins' AS platform_type,
	date_start,
	date_end,
	FALSE AS w_temp_b,
	FALSE AS w_psal_b,
	FALSE AS w_oxygen_b,
	FALSE AS w_co2_b,
	FALSE AS w_chlorophyll_b,
	FALSE AS turb_b,
	FALSE AS w_current_b,
	FALSE AS wave_b,
	FALSE AS air_temperature_b,
	FALSE AS air_pressure_b,
	FALSE AS air_co2_b,
	FALSE AS wind_b,
	FALSE AS plankton_b,
	FALSE AS optical_properties_b,
	TRUE AS animal_location_b,
	geom,
	'Point' AS gtype,
	'#15D659' AS colour
  FROM aatams_penguins
  
UNION ALL

  SELECT 'AATAMS' AS facility,
	'Biologging' AS subfacility,
	NULL AS product,
	animal_id AS platform_code,
	'Shearwaters' AS platform_type,
	date_start,
	date_end,
	FALSE AS w_temp_b,
	FALSE AS w_psal_b,
	FALSE AS w_oxygen_b,
	FALSE AS w_co2_b,
	FALSE AS w_chlorophyll_b,
	FALSE AS turb_b,
	FALSE AS w_current_b,
	FALSE AS wave_b,
	FALSE AS air_temperature_b,
	FALSE AS air_pressure_b,
	FALSE AS air_co2_b,
	FALSE AS wind_b,
	FALSE AS plankton_b,
	FALSE AS optical_properties_b,
	TRUE AS animal_location_b,
	geom,
	'Point' AS gtype,
	'#15D659' AS colour
  FROM aatams_shearwaters
  
UNION ALL

  SELECT 'AATAMS' AS facility,
	'Biologging' AS subfacility,
	NULL AS product,
	animal_id AS platform_code,
	'Snow petrels' AS platform_type,
	date_start,
	date_end,
	FALSE AS w_temp_b,
	FALSE AS w_psal_b,
	FALSE AS w_oxygen_b,
	FALSE AS w_co2_b,
	FALSE AS w_chlorophyll_b,
	FALSE AS turb_b,
	FALSE AS w_current_b,
	FALSE AS wave_b,
	FALSE AS air_temperature_b,
	FALSE AS air_pressure_b,
	FALSE AS air_co2_b,
	FALSE AS wind_b,
	FALSE AS plankton_b,
	FALSE AS optical_properties_b,
	TRUE AS animal_location_b,
	geom,
	'Point' AS gtype,
	'#15D659' AS colour
  FROM aatams_snowpetrel
  
UNION ALL

  SELECT 'AATAMS' AS facility,
	'Biologging' AS subfacility,
	'delayed-mode' AS product,
	device_id AS platform_code,
	'Seals and sea lions' AS platform_type,
	date_start,
	date_end,
	TRUE AS w_temp_b,
	TRUE AS w_psal_b,
	FALSE AS w_oxygen_b,
	FALSE AS w_co2_b,
	TRUE AS w_chlorophyll_b,
	FALSE AS turb_b,
	FALSE AS w_current_b,
	FALSE AS wave_b,
	FALSE AS air_temperature_b,
	FALSE AS air_pressure_b,
	FALSE AS air_co2_b,
	FALSE AS wind_b,
	FALSE AS plankton_b,
	FALSE AS optical_properties_b,
	TRUE AS animal_location_b,
	geom,
	'Point' AS gtype,
	'#15D659' AS colour
  FROM aatams_sattag_dm
	WHERE st_x(geom) > 0

UNION ALL

  SELECT 'AATAMS' AS facility,
	'Biologging' AS subfacility,
	'real-time' AS product,
	device_id AS platform_code,
	'Seals and sea lions' AS platform_type,
	date_start,
	date_end,
	TRUE AS w_temp_b,
	TRUE AS w_psal_b,
	FALSE AS w_oxygen_b,
	FALSE AS w_co2_b,
	FALSE AS w_chlorophyll_b,
	FALSE AS turb_b,
	FALSE AS w_current_b,
	FALSE AS wave_b,
	FALSE AS air_temperature_b,
	FALSE AS air_pressure_b,
	FALSE AS air_co2_b,
	FALSE AS wind_b,
	FALSE AS plankton_b,
	FALSE AS optical_properties_b,
	TRUE AS animal_location_b,
	geom,
	'Point' AS gtype,
	'#15D659' AS colour
  FROM aatams_sattag_nrt
	WHERE st_x(geom) > 0
	
---- ABOS-TS
UNION ALL

  SELECT DISTINCT 'ABOS' AS facility,
	NULL AS subfacility,
	'timeseries' AS product,
	CASE WHEN m.platform_code = '' THEN ma.platform_code ELSE m.platform_code END AS platform_code,
	'Deep water mooring' AS platform_type,
	min(m.time_coverage_start) AS date_start,
	max(m.time_coverage_end) AS date_end,
	TRUE AS w_temp_b,
	TRUE AS w_psal_b,
	FALSE AS w_oxygen_b,
	FALSE AS w_co2_b,
	FALSE AS w_chlorophyll_b,
	FALSE AS turb_b,
	TRUE AS w_current_b,
	FALSE AS wave_b,
	FALSE AS air_temperature_b,
	FALSE AS air_pressure_b,
	FALSE AS air_co2_b,
	FALSE AS wind_b,
	FALSE AS plankton_b,
	FALSE AS optical_properties_b,
	TRUE AS animal_location_b,
	CASE WHEN m.geom IS NULL THEN ma.geom ELSE m.geom END AS geom,
	'Point' AS gtype,
	'#CC4712' AS colour
  FROM abos_ts.abos_ts_timeseries_map m
  FULL JOIN abos_currents.abos_currents_map ma ON m.platform_code = ma.platform_code
	GROUP BY m.platform_code, ma.platform_code,m.geom,ma.geom

---- ABOS SOFS
UNION ALL

  SELECT DISTINCT 'ABOS' AS facility,
	'SOFS' AS subfacility,
	NULL AS product,
	deployment_number AS platform_code,
	'Deep water mooring' AS platform_type,
	min(time_coverage_start) AS date_start,
	max(time_coverage_end) AS date_end,
	TRUE AS w_temp_b,
	TRUE AS w_psal_b,
	TRUE AS w_oxygen_b,
	FALSE AS w_co2_b,
	TRUE AS w_chlorophyll_b,
	TRUE AS turb_b,
	TRUE AS w_current_b,
	TRUE AS wave_b,
	TRUE AS air_temperature_b,
	TRUE AS air_pressure_b,
	FALSE AS air_co2_b,
	TRUE AS wind_b,
	FALSE AS plankton_b,
	TRUE AS optical_properties_b,
	FALSE AS animal_location_b,
	geom AS geom,
	'Point' AS gtype,
	'#CC4712' AS colour
  FROM abos_sofs_fl.abos_sofs_surfaceflux_rt_map
	WHERE deployment_number != '' 
	GROUP BY deployment_number, geom      

---- ANMN-AM
UNION ALL

  SELECT DISTINCT 'ANMN' AS facility,
	'Acidification' AS subfacility,
	'delayed-mode' AS product,
	site_code AS platform_code,
	'Mooring' AS platform_type,
	min(time_coverage_start) AS date_start,
	max(time_coverage_end) AS date_end,
	TRUE AS w_temp_b,
	TRUE AS w_psal_b,
	TRUE AS w_oxygen_b,
	TRUE AS w_co2_b,
	FALSE AS w_chlorophyll_b,
	FALSE AS turb_b,
	FALSE AS w_current_b,
	FALSE AS wave_b,
	FALSE AS air_temperature_b,
	FALSE AS air_pressure_b,
	FALSE AS air_co2_b,
	FALSE AS wind_b,
	FALSE AS plankton_b,
	FALSE AS optical_properties_b,
	FALSE AS animal_location_b,
	ST_CENTROID(ST_COLLECT(geom)) AS geom,
	'Point' AS gtype,
	'#8212CC' AS colour
  FROM anmn_am_dm.anmn_am_dm_map                         
	GROUP BY site_code

UNION ALL

  SELECT DISTINCT 'ANMN' AS facility,
	'Acidification' AS subfacility,
	'real-time' AS product,
	site_code AS platform_code,
	'Mooring' AS platform_type,
	min(time_coverage_start) AS date_start,
	max(time_coverage_end) AS date_end,
	TRUE AS w_temp_b,
	TRUE AS w_psal_b,
	FALSE AS w_oxygen_b,
	TRUE AS w_co2_b,
	FALSE AS w_chlorophyll_b,
	FALSE AS turb_b,
	FALSE AS w_current_b,
	FALSE AS wave_b,
	FALSE AS air_temperature_b,
	FALSE AS air_pressure_b,
	FALSE AS air_co2_b,
	FALSE AS wind_b,
	FALSE AS plankton_b,
	FALSE AS optical_properties_b,
	FALSE AS animal_location_b,
	ST_CENTROID(ST_COLLECT(geom)) AS geom,
	'Point' AS gtype,
	'#8212CC' AS colour
  FROM anmn_acidification_nrt.anmn_am_nrt_map                         
	GROUP BY site_code
	
---- ANMN-Burst average
UNION ALL
  SELECT DISTINCT 'ANMN' AS facility,
	NULL AS subfacility,
	'Burst averaged' AS product,
	platform_code AS platform_code,
	'Mooring' AS platform_type,
	min(time_coverage_start) AS date_start,
	max(time_coverage_end) AS date_end,
	TRUE AS w_temp_b,
	TRUE AS w_psal_b,
	TRUE AS w_oxygen_b,
	FALSE AS w_co2_b,
	TRUE AS w_chlorophyll_b,
	TRUE AS turb_b,
	FALSE AS w_current_b,
	FALSE AS wave_b,
	FALSE AS air_temperature_b,
	FALSE AS air_pressure_b,
	FALSE AS air_co2_b,
	FALSE AS wind_b,
	FALSE AS plankton_b,
	FALSE AS optical_properties_b,
	FALSE AS animal_location_b,
	ST_CENTROID(ST_COLLECT(geom)) AS geom,
	'Point' AS gtype,
	'#8212CC' AS colour
  FROM anmn_burst_avg.anmn_burst_avg_timeseries_map
	GROUP BY platform_code

---- ANMN-MHL wave
UNION ALL

  SELECT DISTINCT 'ANMN' AS facility,
	NULL AS subfacility,
	'Manly wave' AS product,
	platform_code AS platform_code,
	'Mooring' AS platform_type,
	min(time_coverage_start) AS date_start,
	max(time_coverage_end) AS date_end,
	TRUE AS w_temp_b,
	FALSE AS w_psal_b,
	FALSE AS w_oxygen_b,
	FALSE AS w_co2_b,
	FALSE AS w_chlorophyll_b,
	FALSE AS turb_b,
	FALSE AS w_current_b,
	TRUE AS wave_b,
	FALSE AS air_temperature_b,
	FALSE AS air_pressure_b,
	FALSE AS air_co2_b,
	FALSE AS wind_b,
	FALSE AS plankton_b,
	FALSE AS optical_properties_b,
	FALSE AS animal_location_b,
	geom AS geom,
	'Point' AS gtype,
	'#8212CC' AS colour
  FROM anmn_mhlwave.anmn_mhlwave_map
	GROUP BY platform_code, geom

---- ANMN-NRS-BGC
UNION ALL

  SELECT DISTINCT 'ANMN' AS facility,
	'NRS' AS subfacility,
	'BGC' AS product,
	s."STATION_NAME" AS platform_code,
	'Mooring' AS platform_type,
	h.date_start,
	h.date_end,
	FALSE AS w_temp_b,
	TRUE AS w_psal_b,
	TRUE AS w_oxygen_b,
	TRUE AS w_co2_b,
	TRUE AS w_chlorophyll_b,
	FALSE AS turb_b,
	FALSE AS w_current_b,
	FALSE AS wave_b,
	FALSE AS air_temperature_b,
	FALSE AS air_pressure_b,
	FALSE AS air_co2_b,
	FALSE AS wind_b,
	TRUE AS plankton_b,
	TRUE AS optical_properties_b,
	FALSE AS animal_location_b,
	s.geom AS geom,
	'Point' AS gtype,
	'#8212CC' AS colour
  FROM anmn_nrs_bgc.station_name s
	LEFT JOIN h ON h."STATION_NAME" = s."STATION_NAME"

---- ANMN-NRS-CTD
UNION ALL

  SELECT DISTINCT 'ANMN' AS facility,
	'NRS' AS subfacility,
	'CTD profiles' AS product,
	site_code AS platform_code,
	'Mooring' AS platform_type,
	min(time_coverage_start) AS date_start,
	max(time_coverage_end) AS date_end,
	TRUE AS w_temp_b,
	TRUE AS w_psal_b,
	TRUE AS w_oxygen_b,
	FALSE AS w_co2_b,
	TRUE AS w_chlorophyll_b,
	TRUE AS turb_b,
	FALSE AS w_current_b,
	FALSE AS wave_b,
	FALSE AS air_temperature_b,
	FALSE AS air_pressure_b,
	FALSE AS air_co2_b,
	FALSE AS wind_b,
	FALSE AS plankton_b,
	FALSE AS optical_properties_b,
	FALSE AS animal_location_b,
	ST_CENTROID(ST_COLLECT(geom)) AS geom,
	'Point' AS gtype,
	'#8212CC' AS colour
  FROM anmn_nrs_ctd_profiles.anmn_nrs_ctd_profiles_map
	GROUP BY site_code

---- ANMN-NRS-Realtime
UNION ALL

  SELECT DISTINCT 'ANMN' AS facility,
	'NRS' AS subfacility,
	'real-time' AS product,
	site_code AS platform_code,
	'Mooring' AS platform_type,
	min(time_coverage_start) AS date_start,
	max(time_coverage_end) AS date_end,
	TRUE AS w_temp_b,
	TRUE AS w_psal_b,
	TRUE AS w_oxygen_b,
	FALSE AS w_co2_b,
	TRUE AS w_chlorophyll_b,
	TRUE AS turb_b,
	FALSE AS w_current_b,
	FALSE AS wave_b,
	FALSE AS air_temperature_b,
	FALSE AS air_pressure_b,
	FALSE AS air_co2_b,
	FALSE AS wind_b,
	FALSE AS plankton_b,
	FALSE AS optical_properties_b,
	FALSE AS animal_location_b,
	ST_CENTROID(ST_COLLECT(geom)) AS geom,
	'Point' AS gtype,
	'#8212CC' AS colour
  FROM anmn_nrs_rt_bio.anmn_nrs_rt_bio_timeseries_map
	GROUP BY site_code

UNION ALL

  SELECT DISTINCT 'ANMN' AS facility,
	'NRS' AS subfacility,
	'real-time' AS product,
	platform_code,
	'Mooring' AS platform_type,
	min(time_start) AS date_start,
	max(time_end) AS date_end,
	TRUE AS w_temp_b,
	TRUE AS w_psal_b,
	FALSE AS w_oxygen_b,
	FALSE AS w_co2_b,
	TRUE AS w_chlorophyll_b,
	TRUE AS turb_b,
	FALSE AS w_current_b,
	FALSE AS wave_b,
	TRUE AS air_temperature_b,
	TRUE AS air_pressure_b,
	FALSE AS air_co2_b,
	TRUE AS wind_b,
	FALSE AS plankton_b,
	TRUE AS optical_properties_b,
	FALSE AS animal_location_b,
	ST_CENTROID(ST_COLLECT(geom)) AS geom,
	'Point' AS gtype,
	'#8212CC' AS colour
  FROM anmn_nrs_dar_yon.anmn_nrs_yon_dar_timeseries_map
	GROUP BY platform_code
	
UNION ALL

  SELECT DISTINCT 'ANMN' AS facility,
	'NRS' AS subfacility,
	'real-time' AS product,
	site_code AS platform_code,
	'Mooring' AS platform_type,
	min(time_coverage_start) AS date_start,
	max(time_coverage_end) AS date_end,
	TRUE AS w_temp_b,
	FALSE AS w_psal_b,
	FALSE AS w_oxygen_b,
	FALSE AS w_co2_b,
	FALSE AS w_chlorophyll_b,
	FALSE AS turb_b,
	FALSE AS w_current_b,
	FALSE AS wave_b,
	TRUE AS air_temperature_b,
	TRUE AS air_pressure_b,
	FALSE AS air_co2_b,
	TRUE AS wind_b,
	FALSE AS plankton_b,
	FALSE AS optical_properties_b,
	FALSE AS animal_location_b,
	ST_CENTROID(ST_COLLECT(geom)) AS geom,
	'Point' AS gtype,
	'#8212CC' AS colour
  FROM anmn_nrs_rt_meteo.anmn_nrs_rt_meteo_timeseries_map
	GROUP BY site_code

UNION ALL

  SELECT DISTINCT 'ANMN' AS facility,
	'NRS' AS subfacility,
	'real-time' AS product,
	site_code AS platform_code,
	'Mooring' AS platform_type,
	min(time_coverage_start) AS date_start,
	max(time_coverage_end) AS date_end,
	FALSE AS w_temp_b,
	FALSE AS w_psal_b,
	FALSE AS w_oxygen_b,
	FALSE AS w_co2_b,
	FALSE AS w_chlorophyll_b,
	FALSE AS turb_b,
	FALSE AS w_current_b,
	TRUE AS wave_b,
	FALSE AS air_temperature_b,
	FALSE AS air_pressure_b,
	FALSE AS air_co2_b,
	FALSE AS wind_b,
	FALSE AS plankton_b,
	FALSE AS optical_properties_b,
	FALSE AS animal_location_b,
	ST_CENTROID(ST_COLLECT(geom)) AS geom,
	'Point' AS gtype,
	'#8212CC' AS colour
  FROM anmn_nrs_rt_wave.anmn_nrs_rt_wave_timeseries_map
	GROUP BY site_code
	
---- ANMN timeseries
UNION ALL

  SELECT DISTINCT 'ANMN' AS facility,
	NULL AS subfacility,
	'timeseries' AS product,
	substring(site_code,'[A-Z]+') AS platform_code,
	'Mooring' AS platform_type,
	min(time_coverage_start) AS date_start,
	max(time_coverage_end) AS date_end,
	TRUE AS w_temp_b,
	TRUE AS w_psal_b,
	FALSE AS w_oxygen_b,
	FALSE AS w_co2_b,
	FALSE AS w_chlorophyll_b,
	FALSE AS turb_b,
	FALSE AS w_current_b,
	FALSE AS wave_b,
	FALSE AS air_temperature_b,
	FALSE AS air_pressure_b,
	FALSE AS air_co2_b,
	FALSE AS wind_b,
	FALSE AS plankton_b,
	FALSE AS optical_properties_b,
	FALSE AS animal_location_b,
	ST_CENTROID(ST_COLLECT(geom)) AS geom,
	'Point' AS gtype,
	'#8212CC' AS colour
  FROM anmn_ts.anmn_ts_timeseries_map
	GROUP BY substring(site_code,'[A-Z]+')

---- ANMN temperature gridded
UNION ALL

  SELECT DISTINCT 'ANMN' AS facility,
	NULL AS subfacility,
	'temperature gridded' AS product,
	substring(site_code,'[A-Z]+') AS platform_code,
	'Mooring' AS platform_type,
	min(time_coverage_start) AS date_start,
	max(time_coverage_end) AS date_end,
	TRUE AS w_temp_b,
	FALSE AS w_psal_b,
	FALSE AS w_oxygen_b,
	FALSE AS w_co2_b,
	FALSE AS w_chlorophyll_b,
	FALSE AS turb_b,
	FALSE AS w_current_b,
	FALSE AS wave_b,
	FALSE AS air_temperature_b,
	FALSE AS air_pressure_b,
	FALSE AS air_co2_b,
	FALSE AS wind_b,
	FALSE AS plankton_b,
	FALSE AS optical_properties_b,
	FALSE AS animal_location_b,
	ST_CENTROID(ST_COLLECT(geom)) AS geom,
	'Point' AS gtype,
	'#8212CC' AS colour
  FROM anmn_t_regridded.anmn_regridded_temperature_map
	GROUP BY substring(site_code,'[A-Z]+')
	
---- ANFOG
UNION ALL

  SELECT DISTINCT 'ANFOG' AS facility,
	NULL AS subfacility,
	'delayed-mode' AS product,
	CASE WHEN substring(deployment_name,'[A-Za-z]*') = 'Tworocks' THEN 'TwoRocks' 
		WHEN substring(deployment_name,'[A-Za-z]*') = 'Lizard' THEN 'LizardIsland' 
		ELSE substring(deployment_name,'[A-Za-z]*') END AS platform_code,
	CASE WHEN platform_type = 'seaglider' THEN 'Seaglider' WHEN platform_type = 'slocum glider' THEN 'Slocum glider' END AS platform_type,
	min(time_coverage_start) AS date_start,
	max(time_coverage_end) AS date_end,
	TRUE AS w_temp_b,
	TRUE AS w_psal_b,
	TRUE AS w_oxygen_b,
	FALSE AS w_co2_b,
	TRUE AS w_chlorophyll_b,
	FALSE AS turb_b,
	TRUE AS w_current_b,
	FALSE AS wave_b,
	FALSE AS air_temperature_b,
	FALSE AS air_pressure_b,
	FALSE AS air_co2_b,
	FALSE AS wind_b,
	FALSE AS plankton_b,
	TRUE AS optical_properties_b,
	FALSE AS animal_location_b,
	ST_CENTROID(ST_COLLECT(geom)) AS geom,
	'Point' AS gtype,
	'#FF0000' AS colour
  FROM anfog_dm.anfog_dm_trajectory_map
	GROUP BY platform_type, CASE WHEN substring(deployment_name,'[A-Za-z]*') = 'Tworocks' THEN 'TwoRocks' WHEN substring(deployment_name,'[A-Za-z]*') = 'Lizard' THEN 'LizardIsland' ELSE substring(deployment_name,'[A-Za-z]*') END
  
UNION ALL

  SELECT DISTINCT 'ANFOG' AS facility,
	NULL AS subfacility,
	'real-time' AS product,
	CASE WHEN substring(deployment_name,'[A-Za-z]*') = 'Tworocks' THEN 'TwoRocks' 
		WHEN substring(deployment_name,'[A-Za-z]*') = 'Lizard' THEN 'LizardIsland' 
		ELSE substring(deployment_name,'[A-Za-z]*') END AS platform_code,
	CASE WHEN platform_type = 'seaglider' THEN 'Seaglider' WHEN platform_type = 'slocum glider' THEN 'Slocum glider' END AS platform_type,
	min(time_coverage_start)::timestamp AS date_start,
	max(time_coverage_end)::timestamp AS date_end,
	TRUE AS w_temp_b,
	TRUE AS w_psal_b,
	TRUE AS w_oxygen_b,
	FALSE AS w_co2_b,
	TRUE AS w_chlorophyll_b,
	FALSE AS turb_b,
	TRUE AS w_current_b,
	FALSE AS wave_b,
	FALSE AS air_temperature_b,
	FALSE AS air_pressure_b,
	FALSE AS air_co2_b,
	FALSE AS wind_b,
	FALSE AS plankton_b,
	TRUE AS optical_properties_b,
	FALSE AS animal_location_b,
	ST_CENTROID(ST_COLLECT(geom)) AS geom,
	'Point' AS gtype,
	'#FF0000' AS colour
  FROM anfog_rt.anfog_rt_trajectory_map              
	GROUP BY platform_type, CASE WHEN substring(deployment_name,'[A-Za-z]*') = 'Tworocks' THEN 'TwoRocks' WHEN substring(deployment_name,'[A-Za-z]*') = 'Lizard' THEN 'LizardIsland' ELSE substring(deployment_name,'[A-Za-z]*') END
  
---- AUV
UNION ALL

  SELECT DISTINCT 'AUV' AS facility,
	NULL AS subfacility,
	NULL AS product,
	substring(campaign_name,'[A-Za-z]*') AS platform_code,
	'Autonomous Underwater Vehicle' AS platform_type,
	min(time_start) AS date_start,
	max(time_end) AS date_end,
	TRUE AS w_temp_b,
	TRUE AS w_psal_b,
	FALSE AS w_oxygen_b,
	FALSE AS w_co2_b,
	TRUE AS w_chlorophyll_b,
	FALSE AS turb_b,
	FALSE AS w_current_b,
	FALSE AS wave_b,
	FALSE AS air_temperature_b,
	FALSE AS air_pressure_b,
	FALSE AS air_co2_b,
	FALSE AS wind_b,
	FALSE AS plankton_b,
	TRUE AS optical_properties_b,
	FALSE AS animal_location_b,
	ST_CENTROID(ST_COLLECT(geom)) AS geom,
	'Point' AS gtype,
	'#FF0000' AS colour
  FROM auv.auv_trajectory_map
	GROUP BY substring(campaign_name,'[A-Za-z]*')

---- ACORN
UNION ALL

  SELECT DISTINCT 'ACORN' AS facility,
	NULL AS subfacility,
	NULL AS product,
	'Turquoise Coast' AS platform_code,
	'Radar' AS platform_type,
	min(time_start) AS date_start,
	max(time_end) AS date_end,
	FALSE AS w_temp_b,
	FALSE AS w_psal_b,
	FALSE AS w_oxygen_b,
	FALSE AS w_co2_b,
	FALSE AS w_chlorophyll_b,
	FALSE AS turb_b,
	TRUE AS w_current_b,
	FALSE AS wave_b,
	FALSE AS air_temperature_b,
	FALSE AS air_pressure_b,
	FALSE AS air_co2_b,
	FALSE AS wind_b,
	FALSE AS plankton_b,
	FALSE AS optical_properties_b,
	FALSE AS animal_location_b,
	ST_SetSRID(ST_GeomFromText('POINT(115.0 -30.5)'),4326) AS geom,
	'Point' AS gtype,
	'#FF0000' AS colour
  FROM reporting.acorn_radials_all_deployments_view
	WHERE site = 'Turqoise Coast'
	
   
UNION ALL

  SELECT DISTINCT 'ACORN' AS facility,
	NULL AS subfacility,
	NULL AS product,
	'Rottnest Shelf' AS platform_code,
	'Radar' AS platform_type,
	min(time_start) AS date_start,
	max(time_end) AS date_end,
	FALSE AS w_temp_b,
	FALSE AS w_psal_b,
	FALSE AS w_oxygen_b,
	FALSE AS w_co2_b,
	FALSE AS w_chlorophyll_b,
	FALSE AS turb_b,
	TRUE AS w_current_b,
	FALSE AS wave_b,
	FALSE AS air_temperature_b,
	FALSE AS air_pressure_b,
	FALSE AS air_co2_b,
	FALSE AS wind_b,
	FALSE AS plankton_b,
	FALSE AS optical_properties_b,
	FALSE AS animal_location_b,
	ST_SetSRID(ST_GeomFromText('POINT(115.75 -32.05)'),4326) AS geom,
-- 	ST_SetSRID(ST_GeomFromText('POLYGON((113.95 -31.3, 115.46 -31.34, 115.58 -32.4, 114.08 -32.34, 113.95 -31.3))'),4326) AS geom,
	'Point' AS gtype,
	'#FF0000' AS colour
  FROM reporting.acorn_radials_all_deployments_view
	WHERE site = 'Rottnest Shelf'
	
UNION ALL

  SELECT DISTINCT 'ACORN' AS facility,
	NULL AS subfacility,
	NULL AS product,
	'South Australian Gulf' AS platform_code,
	'Radar' AS platform_type,
	min(time_start) AS date_start,
	max(time_end) AS date_end,
	FALSE AS w_temp_b,
	FALSE AS w_psal_b,
	FALSE AS w_oxygen_b,
	FALSE AS w_co2_b,
	FALSE AS w_chlorophyll_b,
	FALSE AS turb_b,
	TRUE AS w_current_b,
	FALSE AS wave_b,
	FALSE AS air_temperature_b,
	FALSE AS air_pressure_b,
	FALSE AS air_co2_b,
	FALSE AS wind_b,
	FALSE AS plankton_b,
	FALSE AS optical_properties_b,
	FALSE AS animal_location_b,
	ST_SetSRID(ST_GeomFromText('POINT(136.87 -35.3)'),4326) AS geom,
	'Point' AS gtype,
	'#FF0000' AS colour
  FROM reporting.acorn_radials_all_deployments_view
	WHERE site = 'South Australia Gulf'
	
UNION ALL

  SELECT DISTINCT 'ACORN' AS facility,
	NULL AS subfacility,
	NULL AS product,
	'Bonney Coast' AS platform_code,
	'Radar' AS platform_type,
	min(time_start) AS date_start,
	max(time_end) AS date_end,
	FALSE AS w_temp_b,
	FALSE AS w_psal_b,
	FALSE AS w_oxygen_b,
	FALSE AS w_co2_b,
	FALSE AS w_chlorophyll_b,
	FALSE AS turb_b,
	TRUE AS w_current_b,
	FALSE AS wave_b,
	FALSE AS air_temperature_b,
	FALSE AS air_pressure_b,
	FALSE AS air_co2_b,
	FALSE AS wind_b,
	FALSE AS plankton_b,
	FALSE AS optical_properties_b,
	FALSE AS animal_location_b,
	ST_SetSRID(ST_GeomFromText('POINT(140.52 -38.2)'),4326) AS geom,
	'Point' AS gtype,
	'#FF0000' AS colour
  FROM reporting.acorn_radials_all_deployments_view
	WHERE site = 'Bonney Coast'
	
UNION ALL

  SELECT DISTINCT 'ACORN' AS facility,
	NULL AS subfacility,
	NULL AS product,
	'Coffs Harbour' AS platform_code,
	'Radar' AS platform_type,
	min(time_start) AS date_start,
	max(time_end) AS date_end,
	FALSE AS w_temp_b,
	FALSE AS w_psal_b,
	FALSE AS w_oxygen_b,
	FALSE AS w_co2_b,
	FALSE AS w_chlorophyll_b,
	FALSE AS turb_b,
	TRUE AS w_current_b,
	FALSE AS wave_b,
	FALSE AS air_temperature_b,
	FALSE AS air_pressure_b,
	FALSE AS air_co2_b,
	FALSE AS wind_b,
	FALSE AS plankton_b,
	FALSE AS optical_properties_b,
	FALSE AS animal_location_b,
	ST_SetSRID(ST_GeomFromText('POINT(153.0 -30.6)'),4326) AS geom,
	'Point' AS gtype,
	'#FF0000' AS colour
  FROM reporting.acorn_radials_all_deployments_view
	WHERE site = 'Coffs Harbour'

UNION ALL

  SELECT DISTINCT 'ACORN' AS facility,
	NULL AS subfacility,
	NULL AS product,
	'Capricorn Bunker Group' AS platform_code,
	'Radar' AS platform_type,
	min(time_start) AS date_start,
	max(time_end) AS date_end,
	FALSE AS w_temp_b,
	FALSE AS w_psal_b,
	FALSE AS w_oxygen_b,
	FALSE AS w_co2_b,
	FALSE AS w_chlorophyll_b,
	FALSE AS turb_b,
	TRUE AS w_current_b,
	FALSE AS wave_b,
	FALSE AS air_temperature_b,
	FALSE AS air_pressure_b,
	FALSE AS air_co2_b,
	FALSE AS wind_b,
	FALSE AS plankton_b,
	FALSE AS optical_properties_b,
	FALSE AS animal_location_b,
	ST_SetSRID(ST_GeomFromText('POINT(152.7 -24.2)'),4326) AS geom,
	'Point' AS gtype,
	'#FF0000' AS colour
  FROM reporting.acorn_radials_all_deployments_view
	WHERE site = 'Capricorn Bunker Group'

---- FAIMMS
UNION ALL

  SELECT DISTINCT 'FAIMMS' AS facility,
	NULL AS subfacility,
	NULL AS product,
	platform_code AS platform_code,
	'Sensor network' AS platform_type,
	min(time_start) AS date_start,
	max(time_end) AS date_end,
	TRUE AS w_temp_b,
	TRUE AS w_psal_b,
	FALSE AS w_oxygen_b,
	FALSE AS w_co2_b,
	FALSE AS w_chlorophyll_b,
	TRUE AS turb_b,
	FALSE AS w_current_b,
	FALSE AS wave_b,
	TRUE AS air_temperature_b,
	TRUE AS air_pressure_b,
	FALSE AS air_co2_b,
	TRUE AS wind_b,
	FALSE AS plankton_b,
	TRUE AS optical_properties_b,
	FALSE AS animal_location_b,
	ST_CENTROID(ST_COLLECT(geom)) AS geom,
	'Point' AS gtype,
	'#FF0000' AS colour
  FROM faimms.faimms_timeseries_map
	GROUP BY platform_code

---- AATAMS Acoustic
UNION ALL

  SELECT DISTINCT 'AATAMS' AS facility,
	'Acoustic tagging' AS subfacility,
	NULL AS product,
	installation_name AS platform_code,
	'Acoustic receivers' AS platform_type,
	min(first_detection_date) AS date_start,
	max(last_detection_date) AS date_end,
	FALSE AS w_temp_b,
	FALSE AS w_psal_b,
	FALSE AS w_oxygen_b,
	FALSE AS w_co2_b,
	FALSE AS w_chlorophyll_b,
	FALSE AS turb_b,
	FALSE AS w_current_b,
	FALSE AS wave_b,
	FALSE AS air_temperature_b,
	FALSE AS air_pressure_b,
	FALSE AS air_co2_b,
	FALSE AS wind_b,
	FALSE AS plankton_b,
	FALSE AS optical_properties_b,
	TRUE AS animal_location_b,
	ST_CENTROID(ST_COLLECT(geom)) AS geom,
	'Point' AS gtype,
	'#FF0000' AS colour
  FROM dw_aatams_acoustic.aatams_acoustic_detections_map
	WHERE installation_name != 'Obi Obi Creek'
	GROUP BY installation_name
	HAVING st_y(ST_CENTROID(ST_COLLECT(geom))) < 0

---- SRS Altimetry
UNION ALL

  SELECT DISTINCT 'SRS' AS facility,
	NULL AS subfacility,
	'Altimetry' AS product,
	site_name AS platform_code,
	'Mooring' AS platform_type,
	min(time_start) AS date_start,
	max(time_end) AS date_end,
	TRUE AS w_temp_b,
	TRUE AS w_psal_b,
	FALSE AS w_oxygen_b,
	FALSE AS w_co2_b,
	FALSE AS w_chlorophyll_b,
	FALSE AS turb_b,
	TRUE AS w_current_b,
	FALSE AS wave_b,
	FALSE AS air_temperature_b,
	FALSE AS air_pressure_b,
	FALSE AS air_co2_b,
	FALSE AS wind_b,
	FALSE AS plankton_b,
	FALSE AS optical_properties_b,
	FALSE AS animal_location_b,
	ST_CENTROID(ST_COLLECT(geom)) AS geom,
	'Point' AS gtype,
	'#FF0000' AS colour
  FROM srs_altimetry.srs_altimetry_timeseries_map
	GROUP BY site_name

  ---- SRS Lucinda Jetty
UNION ALL

  SELECT 'SRS' AS facility,
	'Ocean colour' AS subfacility,
	'Lucinda Jetty Coastal Observatory' AS product,
	NULL AS platform_code,
	'Mooring' AS platform_type,
	min("TIME") AS date_start,
	max("TIME") AS date_end,
	FALSE AS w_temp_b,
	FALSE AS w_psal_b,
	FALSE AS w_oxygen_b,
	FALSE AS w_co2_b,
	FALSE AS w_chlorophyll_b,
	FALSE AS turb_b,
	FALSE AS w_current_b,
	FALSE AS wave_b,
	FALSE AS air_temperature_b,
	FALSE AS air_pressure_b,
	FALSE AS air_co2_b,
	FALSE AS wind_b,
	FALSE AS plankton_b,
	TRUE AS optical_properties_b,
	FALSE AS animal_location_b,
	ST_SetSRID(ST_GeomFromText('POINT(146.39 -18.52)'),4326) AS geom,
	'Point' AS gtype,
	'#FF0000' AS colour
  FROM srs_oc_ljco_aeronet.srs_oc_ljco_aeronet_map
	ORDER BY facility, subfacility, product, platform_code;

grant all on asset_map TO public, harvest_read_group;
GRANT select on all tables in schema report_test to "backup";
GRANT select on all sequences in schema report_test to "backup";