﻿SET SEARCH_PATH = report_test, public;

DROP TABLE IF EXISTS asset_map;

CREATE TABLE asset_map AS
WITH soop_cpr AS (
  SELECT vessel_name AS platform_code,
	ST_CENTROID(ST_COLLECT(geom)) AS geom
  FROM soop_auscpr.soop_auscpr_pci_trajectory_map 
	GROUP BY vessel_name, substring(trip_code,'[A-Z]*')),
  aatams_sattag AS (
  SELECT 'Seals and sea lions'::text AS platform_code,
	ST_CENTROID(ST_COLLECT(geom)) AS geom
  FROM aatams_sattag_nrt.aatams_sattag_nrt_profile_map
	GROUP BY device_id 
	ORDER BY random()
	LIMIT 75),
  aatams_penguins AS(
  SELECT ST_CENTROID(geom) AS geom
  FROM aatams_biologging_penguin.aatams_biologging_penguin_map
  	ORDER BY random()
	LIMIT 25),
  aatams_shearwaters AS(
  SELECT ST_CENTROID(geom) AS geom
  FROM aatams_biologging_shearwater.aatams_biologging_shearwater_map
  	ORDER BY random()
	LIMIT 25)
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
	ST_SetSRID(ST_GeomFromText('POINT(64.0 -36)'),4326) AS geom,
	'Point' AS gtype,
	'#591FBF' AS colour
UNION ALL
  SELECT 'SOOP' AS facility,
	'BA' AS subfacility,
	'Tasman Sea' AS platform_code,
	ST_SetSRID(ST_GeomFromText('POINT(160.0 -42)'),4326) AS geom,
	'Point' AS gtype,
	'#591FBF' AS colour

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
	CASE WHEN platform_code = 'ANL Windarra' THEN ST_SetSRID(ST_GeomFromText('POINT(153.1 -32.4)'),4326) 
		WHEN platform_code = 'Southern Surveyor' THEN ST_SetSRID(ST_GeomFromText('POINT(139.4 -39.1)'),4326)
		WHEN platform_code = 'ANL Whyalla' THEN ST_SetSRID(ST_GeomFromText('POINT(134.4 -36)'),4326) ELSE
		ST_CENTROID(ST_COLLECT(geom)) END AS geom,
	'Point' AS gtype,
	'#591FBF' AS colour
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
		WHEN vessel_name = 'Stadacona' THEN ST_SetSRID(ST_GeomFromText('POINT(152 -35)'),4326) ELSE
		ST_CENTROID(ST_COLLECT(geom)) END AS geom,
	'Point' AS gtype,
	'#591FBF' AS colour
  FROM soop_sst.soop_sst_nrt_trajectory_map
  GROUP BY vessel_name

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
  SELECT 'ABOS' AS facility,
	'Temperature and Salinity' AS subfacility,
	platform_code AS platform_code,
	geom AS geom,
	'Point' AS gtype,
	'#CC4712' AS colour
  FROM abos_ts.abos_ts_timeseries_map

---- ABOS-Pulse
UNION ALL
  SELECT 'ABOS' AS facility,
	site_code AS subfacility,
	platform_code AS platform_code,
	geom AS geom,
	'Point' AS gtype,
	'#CC4712' AS colour
  FROM abos_pulse.abos_pulse_map

---- ABOS-Currents
UNION ALL
  SELECT 'ABOS' AS facility,
	'Currents' AS subfacility,
	platform_code AS platform_code,
	geom AS geom,
	'Point' AS gtype,
	'#CC4712' AS colour
  FROM abos_currents.abos_currents_map                         

---- ANMN-AM
UNION ALL
  SELECT 'ANMN' AS facility,
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
  FROM anmn_nrs_bgc.anmn_nrs_bgc_chemistry_map

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
  FROM dw_aatams_acoustic.aatams_acoustic_detections_map
	GROUP BY installation_name

---- SRS Altimetry
UNION ALL
  SELECT DISTINCT 'SRS' AS facility,
	'Altimetry' AS subfacility,
	instrument AS platform_code,
	geom AS geom,
	'Point' AS gtype,
	'#FF0000' AS colour
  FROM srs_altimetry.srs_altimetry_timeseries_map;

grant all on asset_map TO public, harvest_read_group;