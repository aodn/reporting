SET search_path = report_test, public;
DROP VIEW IF EXISTS anmn_nrs_bgc_all_deployments_view CASCADE;

-------------------------------
-- VIEWS FOR ANMN_NRS_BGC
-------------------------------
-- All deployments
CREATE VIEW anmn_nrs_bgc_all_deployments_view AS
WITH a AS (
  SELECT 'Chemistry' AS data_type, 
	"STATION_NAME" AS station_name,
	"NRS_TRIP_CODE" AS trip_code,
	COUNT("NRS_SAMPLE_CODE") AS no_samples,
	7 AS total_no_parameters,
	CASE WHEN SUM(CASE WHEN "SALINITY" IS NULL THEN 0 ELSE 1 END) = 0 THEN 0 ELSE 1 END +
	CASE WHEN SUM(CASE WHEN "SILICATE_UMOL_PER_L" IS NULL THEN 0 ELSE 1 END) = 0 THEN 0 ELSE 1 END +
	CASE WHEN SUM(CASE WHEN "NITRATE_UMOL_PER_L" IS NULL THEN 0 ELSE 1 END) = 0 THEN 0 ELSE 1 END +
	CASE WHEN SUM(CASE WHEN "PHOSPHATE_UMOL_PER_L" IS NULL THEN 0 ELSE 1 END) = 0 THEN 0 ELSE 1 END +
	CASE WHEN SUM(CASE WHEN "AMMONIUM_UMOL_PER_L" IS NULL THEN 0 ELSE 1 END) = 0 THEN 0 ELSE 1 END +
	CASE WHEN SUM(CASE WHEN "TCO2_UMOL_PER_KG" IS NULL THEN 0 ELSE 1 END) = 0 THEN 0 ELSE 1 END +
	CASE WHEN SUM(CASE WHEN "TALKALINITY_UMOL_PER_KG" IS NULL THEN 0 ELSE 1 END) = 0 THEN 0 ELSE 1 END AS no_parameters_measured,
	COUNT("NRS_SAMPLE_CODE") * 7 AS total_no_measurements,
	SUM(CASE WHEN "SALINITY" IS NULL THEN 0 ELSE 1 END) +
	SUM(CASE WHEN "SILICATE_UMOL_PER_L" IS NULL THEN 0 ELSE 1 END) +
	SUM(CASE WHEN "NITRATE_UMOL_PER_L" IS NULL THEN 0 ELSE 1 END) +
	SUM(CASE WHEN "PHOSPHATE_UMOL_PER_L" IS NULL THEN 0 ELSE 1 END) +
	SUM(CASE WHEN "AMMONIUM_UMOL_PER_L" IS NULL THEN 0 ELSE 1 END) +
	SUM(CASE WHEN "TCO2_UMOL_PER_KG" IS NULL THEN 0 ELSE 1 END) +
	SUM(CASE WHEN "TALKALINITY_UMOL_PER_KG" IS NULL THEN 0 ELSE 1 END) AS no_measurements_with_data,
	min("LONGITUDE") AS lon,
	min("LATITUDE") AS lat,
	min("SAMPLE_DEPTH_M") AS min_depth,
	max("SAMPLE_DEPTH_M") AS max_depth
  FROM anmn_nrs_bgc.anmn_nrs_bgc_chemistry_data
	GROUP BY "STATION_NAME", "NRS_TRIP_CODE"
UNION ALL
  SELECT 'Phytoplankton pigment' AS data_type, 
	"STATION_NAME" AS station_name,
	"NRS_TRIP_CODE" AS trip_code,
	COUNT("NRS_SAMPLE_CODE") AS no_samples,
	41 AS total_no_parameters,
	CASE WHEN SUM(CASE WHEN "CPHL_C3" IS NULL THEN 0 ELSE 1 END) = 0 THEN 0 ELSE 1 END +
	CASE WHEN SUM(CASE WHEN "MG_DVP" IS NULL THEN 0 ELSE 1 END) = 0 THEN 0 ELSE 1 END +
	CASE WHEN SUM(CASE WHEN "CPHL_C2" IS NULL THEN 0 ELSE 1 END) = 0 THEN 0 ELSE 1 END +
	CASE WHEN SUM(CASE WHEN "CPHL_C1" IS NULL THEN 0 ELSE 1 END) = 0 THEN 0 ELSE 1 END +
	CASE WHEN SUM(CASE WHEN "CPHL_C1C2" IS NULL THEN 0 ELSE 1 END) = 0 THEN 0 ELSE 1 END +
	CASE WHEN SUM(CASE WHEN "CPHLIDE_A" IS NULL THEN 0 ELSE 1 END) = 0 THEN 0 ELSE 1 END +
	CASE WHEN SUM(CASE WHEN "PHIDE_A" IS NULL THEN 0 ELSE 1 END) = 0 THEN 0 ELSE 1 END +
	CASE WHEN SUM(CASE WHEN "PERID" IS NULL THEN 0 ELSE 1 END) = 0 THEN 0 ELSE 1 END +
	CASE WHEN SUM(CASE WHEN "PYROPHIDE_A" IS NULL THEN 0 ELSE 1 END) = 0 THEN 0 ELSE 1 END +
	CASE WHEN SUM(CASE WHEN "BUT_FUCO" IS NULL THEN 0 ELSE 1 END) = 0 THEN 0 ELSE 1 END +
	CASE WHEN SUM(CASE WHEN "FUCO" IS NULL THEN 0 ELSE 1 END) = 0 THEN 0 ELSE 1 END +
	CASE WHEN SUM(CASE WHEN "NEO" IS NULL THEN 0 ELSE 1 END) = 0 THEN 0 ELSE 1 END +
	CASE WHEN SUM(CASE WHEN "KETO_HEX_FUCO" IS NULL THEN 0 ELSE 1 END) = 0 THEN 0 ELSE 1 END +
	CASE WHEN SUM(CASE WHEN "PRAS" IS NULL THEN 0 ELSE 1 END) = 0 THEN 0 ELSE 1 END +
	CASE WHEN SUM(CASE WHEN "VIOLA" IS NULL THEN 0 ELSE 1 END) = 0 THEN 0 ELSE 1 END +
	CASE WHEN SUM(CASE WHEN "HEX_FUCO" IS NULL THEN 0 ELSE 1 END) = 0 THEN 0 ELSE 1 END +
	CASE WHEN SUM(CASE WHEN "ASTA" IS NULL THEN 0 ELSE 1 END) = 0 THEN 0 ELSE 1 END +
	CASE WHEN SUM(CASE WHEN "DIADCHR" IS NULL THEN 0 ELSE 1 END) = 0 THEN 0 ELSE 1 END +
	CASE WHEN SUM(CASE WHEN "DIADINO" IS NULL THEN 0 ELSE 1 END) = 0 THEN 0 ELSE 1 END +
	CASE WHEN SUM(CASE WHEN "DINO" IS NULL THEN 0 ELSE 1 END) = 0 THEN 0 ELSE 1 END +
	CASE WHEN SUM(CASE WHEN "ANTH" IS NULL THEN 0 ELSE 1 END) = 0 THEN 0 ELSE 1 END +
	CASE WHEN SUM(CASE WHEN "ALLO" IS NULL THEN 0 ELSE 1 END) = 0 THEN 0 ELSE 1 END +
	CASE WHEN SUM(CASE WHEN "DIATO" IS NULL THEN 0 ELSE 1 END) = 0 THEN 0 ELSE 1 END +
	CASE WHEN SUM(CASE WHEN "ZEA" IS NULL THEN 0 ELSE 1 END) = 0 THEN 0 ELSE 1 END +
	CASE WHEN SUM(CASE WHEN "LUT" IS NULL THEN 0 ELSE 1 END) = 0 THEN 0 ELSE 1 END +
	CASE WHEN SUM(CASE WHEN "CANTHA" IS NULL THEN 0 ELSE 1 END) = 0 THEN 0 ELSE 1 END +
	CASE WHEN SUM(CASE WHEN "GYRO" IS NULL THEN 0 ELSE 1 END) = 0 THEN 0 ELSE 1 END +
	CASE WHEN SUM(CASE WHEN "DV_CPHL_B" IS NULL THEN 0 ELSE 1 END) = 0 THEN 0 ELSE 1 END +
	CASE WHEN SUM(CASE WHEN "CPHL_B" IS NULL THEN 0 ELSE 1 END) = 0 THEN 0 ELSE 1 END +
	CASE WHEN SUM(CASE WHEN "DV_CPHL_B_AND_CPHL_B" IS NULL THEN 0 ELSE 1 END) = 0 THEN 0 ELSE 1 END +
	CASE WHEN SUM(CASE WHEN "DV_CPHL_A" IS NULL THEN 0 ELSE 1 END) = 0 THEN 0 ELSE 1 END +
	CASE WHEN SUM(CASE WHEN "CPHL_A" IS NULL THEN 0 ELSE 1 END) = 0 THEN 0 ELSE 1 END +
	CASE WHEN SUM(CASE WHEN "DV_CPHL_A_AND_CPHL_A" IS NULL THEN 0 ELSE 1 END) = 0 THEN 0 ELSE 1 END +
	CASE WHEN SUM(CASE WHEN "ECHIN" IS NULL THEN 0 ELSE 1 END) = 0 THEN 0 ELSE 1 END +
	CASE WHEN SUM(CASE WHEN "PHYTIN_B" IS NULL THEN 0 ELSE 1 END) = 0 THEN 0 ELSE 1 END +
	CASE WHEN SUM(CASE WHEN "PHYTIN_A" IS NULL THEN 0 ELSE 1 END) = 0 THEN 0 ELSE 1 END +
	CASE WHEN SUM(CASE WHEN "LYCO" IS NULL THEN 0 ELSE 1 END) = 0 THEN 0 ELSE 1 END +
	CASE WHEN SUM(CASE WHEN "BETA_EPI_CAR" IS NULL THEN 0 ELSE 1 END) = 0 THEN 0 ELSE 1 END +
	CASE WHEN SUM(CASE WHEN "BETA_BETA_CAR" IS NULL THEN 0 ELSE 1 END) = 0 THEN 0 ELSE 1 END +
	CASE WHEN SUM(CASE WHEN "ALPHA_BETA_CAR" IS NULL THEN 0 ELSE 1 END) = 0 THEN 0 ELSE 1 END +
	CASE WHEN SUM(CASE WHEN "PYROPHYTIN_A" IS NULL THEN 0 ELSE 1 END) = 0 THEN 0 ELSE 1 END AS no_parameters_measured,
	COUNT("NRS_SAMPLE_CODE") * 41 AS total_no_measurements,
	SUM(CASE WHEN "CPHL_C3" IS NULL THEN 0 ELSE 1 END) +
	SUM(CASE WHEN "MG_DVP" IS NULL THEN 0 ELSE 1 END) +
	SUM(CASE WHEN "CPHL_C2" IS NULL THEN 0 ELSE 1 END) +
	SUM(CASE WHEN "CPHL_C1" IS NULL THEN 0 ELSE 1 END) +
	SUM(CASE WHEN "CPHL_C1C2" IS NULL THEN 0 ELSE 1 END) +
	SUM(CASE WHEN "CPHLIDE_A" IS NULL THEN 0 ELSE 1 END) +
	SUM(CASE WHEN "PHIDE_A" IS NULL THEN 0 ELSE 1 END) +
	SUM(CASE WHEN "PERID" IS NULL THEN 0 ELSE 1 END) +
	SUM(CASE WHEN "PYROPHIDE_A" IS NULL THEN 0 ELSE 1 END) +
	SUM(CASE WHEN "BUT_FUCO" IS NULL THEN 0 ELSE 1 END) +
	SUM(CASE WHEN "FUCO" IS NULL THEN 0 ELSE 1 END) +
	SUM(CASE WHEN "NEO" IS NULL THEN 0 ELSE 1 END) +
	SUM(CASE WHEN "KETO_HEX_FUCO" IS NULL THEN 0 ELSE 1 END) +
	SUM(CASE WHEN "PRAS" IS NULL THEN 0 ELSE 1 END) +
	SUM(CASE WHEN "VIOLA" IS NULL THEN 0 ELSE 1 END) +
	SUM(CASE WHEN "HEX_FUCO" IS NULL THEN 0 ELSE 1 END) +
	SUM(CASE WHEN "ASTA" IS NULL THEN 0 ELSE 1 END) +
	SUM(CASE WHEN "DIADCHR" IS NULL THEN 0 ELSE 1 END) +
	SUM(CASE WHEN "DIADINO" IS NULL THEN 0 ELSE 1 END) +
	SUM(CASE WHEN "DINO" IS NULL THEN 0 ELSE 1 END) +
	SUM(CASE WHEN "ANTH" IS NULL THEN 0 ELSE 1 END) +
	SUM(CASE WHEN "ALLO" IS NULL THEN 0 ELSE 1 END) +
	SUM(CASE WHEN "DIATO" IS NULL THEN 0 ELSE 1 END) +
	SUM(CASE WHEN "ZEA" IS NULL THEN 0 ELSE 1 END) +
	SUM(CASE WHEN "LUT" IS NULL THEN 0 ELSE 1 END) +
	SUM(CASE WHEN "CANTHA" IS NULL THEN 0 ELSE 1 END) +
	SUM(CASE WHEN "GYRO" IS NULL THEN 0 ELSE 1 END) +
	SUM(CASE WHEN "DV_CPHL_B" IS NULL THEN 0 ELSE 1 END) +
	SUM(CASE WHEN "CPHL_B" IS NULL THEN 0 ELSE 1 END) +
	SUM(CASE WHEN "DV_CPHL_B_AND_CPHL_B" IS NULL THEN 0 ELSE 1 END) +
	SUM(CASE WHEN "DV_CPHL_A" IS NULL THEN 0 ELSE 1 END) +
	SUM(CASE WHEN "CPHL_A" IS NULL THEN 0 ELSE 1 END) +
	SUM(CASE WHEN "DV_CPHL_A_AND_CPHL_A" IS NULL THEN 0 ELSE 1 END) +
	SUM(CASE WHEN "ECHIN" IS NULL THEN 0 ELSE 1 END) +
	SUM(CASE WHEN "PHYTIN_B" IS NULL THEN 0 ELSE 1 END) +
	SUM(CASE WHEN "PHYTIN_A" IS NULL THEN 0 ELSE 1 END) +
	SUM(CASE WHEN "LYCO" IS NULL THEN 0 ELSE 1 END) +
	SUM(CASE WHEN "BETA_EPI_CAR" IS NULL THEN 0 ELSE 1 END) +
	SUM(CASE WHEN "BETA_BETA_CAR" IS NULL THEN 0 ELSE 1 END) +
	SUM(CASE WHEN "ALPHA_BETA_CAR" IS NULL THEN 0 ELSE 1 END) +
	SUM(CASE WHEN "PYROPHYTIN_A" IS NULL THEN 0 ELSE 1 END) AS no_measurements_with_data,
	min("LONGITUDE") AS lon,
	min("LATITUDE") AS lat,
	min("SAMPLE_DEPTH_M") AS min_depth,
	max("SAMPLE_DEPTH_M") AS max_depth
  FROM anmn_nrs_bgc.anmn_nrs_bgc_phypig_data
	GROUP BY "STATION_NAME", "NRS_TRIP_CODE"
UNION ALL
  SELECT 'Picoplankton' AS data_type, 
	"STATION_NAME" AS station_name,
	"NRS_TRIP_CODE" AS trip_code,
	COUNT("NRS_SAMPLE_CODE") AS no_samples,
	3 AS total_no_parameters,
	CASE WHEN SUM(CASE WHEN "PROCHLOROCOCCUS_CELLSPERML" IS NULL THEN 0 ELSE 1 END) = 0 THEN 0 ELSE 1 END +
	CASE WHEN SUM(CASE WHEN "SYNECOCHOCCUS_CELLSPERML" IS NULL THEN 0 ELSE 1 END) = 0 THEN 0 ELSE 1 END +
	CASE WHEN SUM(CASE WHEN "PICOEUKARYOTES_CELLSPERML" IS NULL THEN 0 ELSE 1 END) = 0 THEN 0 ELSE 1 END AS no_parameters_measured,
	COUNT("NRS_SAMPLE_CODE") * 3 AS total_no_measurements,
	SUM(CASE WHEN "PROCHLOROCOCCUS_CELLSPERML" IS NULL THEN 0 ELSE 1 END) +
	SUM(CASE WHEN "SYNECOCHOCCUS_CELLSPERML" IS NULL THEN 0 ELSE 1 END) +
	SUM(CASE WHEN "PICOEUKARYOTES_CELLSPERML" IS NULL THEN 0 ELSE 1 END) AS no_measurements_with_data,
	min("LONGITUDE") AS lon,
	min("LATITUDE") AS lat,
	NULL AS min_depth,
	NULL AS max_depth
  FROM anmn_nrs_bgc.anmn_nrs_bgc_picoplankton_data
	GROUP BY "STATION_NAME", "NRS_TRIP_CODE"
UNION ALL
  SELECT 'Plankton biomass' AS data_type, 
	"STATION_NAME" AS station_name,
	"NRS_TRIP_CODE" AS trip_code,
	COUNT("NRS_SAMPLE_CODE") AS no_samples,
	1 AS total_no_parameters,
	CASE WHEN SUM(CASE WHEN "MG_PER_M3" IS NULL THEN 0 ELSE 1 END) = 0 THEN 0 ELSE 1 END AS no_parameters_measured,
	COUNT("NRS_SAMPLE_CODE") AS total_no_measurements,
	SUM(CASE WHEN "MG_PER_M3" IS NULL THEN 0 ELSE 1 END) AS no_measurements_with_data,
	min("LONGITUDE") AS lon,
	min("LATITUDE") AS lat,
	NULL AS min_depth,
	NULL AS max_depth
  FROM anmn_nrs_bgc.anmn_nrs_bgc_plankton_biomass_data
	GROUP BY "STATION_NAME", "NRS_TRIP_CODE"
UNION ALL
  SELECT 'Phytoplankton' AS data_type, 
	"STATION_NAME" AS station_name,
	"NRS_TRIP_CODE" AS trip_code,
	COUNT("NRS_SAMPLE_CODE") AS no_samples,
	3 AS total_no_parameters,
	CASE WHEN SUM(CASE WHEN "TAXON_NAME" IS NULL THEN 0 ELSE 1 END) = 0 THEN 0 ELSE 1 END +
	CASE WHEN SUM(CASE WHEN "CELL_PER_LITRE" IS NULL THEN 0 ELSE 1 END) = 0 THEN 0 ELSE 1 END +
	CASE WHEN SUM(CASE WHEN "BIOVOLUME_UM3_PER_L" IS NULL THEN 0 ELSE 1 END) = 0 THEN 0 ELSE 1 END AS no_parameters_measured,
	COUNT("NRS_SAMPLE_CODE") * 3 AS total_no_measurements,
	SUM(CASE WHEN "TAXON_NAME" IS NULL THEN 0 ELSE 1 END) +
	SUM(CASE WHEN "CELL_PER_LITRE" IS NULL THEN 0 ELSE 1 END) +
	SUM(CASE WHEN "BIOVOLUME_UM3_PER_L" IS NULL THEN 0 ELSE 1 END) AS no_measurements_with_data,
	min("LONGITUDE") AS lon,
	min("LATITUDE") AS lat,
	NULL AS min_depth,
	NULL AS max_depth
  FROM anmn_nrs_bgc.anmn_nrs_bgc_plankton_phytoplankton_data
	GROUP BY "STATION_NAME", "NRS_TRIP_CODE"
UNION ALL
  SELECT 'Zooplankton' AS data_type, 
	"STATION_NAME" AS station_name,
	"NRS_TRIP_CODE" AS trip_code,
	COUNT("NRS_SAMPLE_CODE") AS no_samples,
	2 AS total_no_parameters,
	CASE WHEN SUM(CASE WHEN "TAXON_NAME" IS NULL THEN 0 ELSE 1 END) = 0 THEN 0 ELSE 1 END +
	CASE WHEN SUM(CASE WHEN "TAXON_PER_M3" IS NULL THEN 0 ELSE 1 END) = 0 THEN 0 ELSE 1 END AS no_parameters_measured,
	COUNT("NRS_SAMPLE_CODE") * 2 AS total_no_measurements,
	SUM(CASE WHEN "TAXON_NAME" IS NULL THEN 0 ELSE 1 END) +
	SUM(CASE WHEN "TAXON_PER_M3" IS NULL THEN 0 ELSE 1 END) AS no_measurements_with_data,
	min("LONGITUDE") AS lon,
	min("LATITUDE") AS lat,
	NULL AS min_depth,
	NULL AS max_depth
  FROM anmn_nrs_bgc.anmn_nrs_bgc_plankton_zooplankton_data
	GROUP BY "STATION_NAME", "NRS_TRIP_CODE"
UNION ALL
  SELECT 'Suspended matter' AS data_type, 
	"STATION_NAME" AS station_name,
	"NRS_TRIP_CODE" AS trip_code,
	COUNT("NRS_SAMPLE_CODE") AS no_samples,
	3 AS total_no_parameters,
	CASE WHEN SUM(CASE WHEN "TSS_MG_PER_L" IS NULL THEN 0 ELSE 1 END) = 0 THEN 0 ELSE 1 END +
	CASE WHEN SUM(CASE WHEN "INORGANIC_FRACTION_MG_PER_L" IS NULL THEN 0 ELSE 1 END) = 0 THEN 0 ELSE 1 END +
	CASE WHEN SUM(CASE WHEN "ORGANIC_FRACTION_MG_PER_L" IS NULL THEN 0 ELSE 1 END) = 0 THEN 0 ELSE 1 END AS no_parameters_measured,
	COUNT("NRS_SAMPLE_CODE") * 3 AS total_no_measurements,
	SUM(CASE WHEN "TSS_MG_PER_L" IS NULL THEN 0 ELSE 1 END) +
	SUM(CASE WHEN "INORGANIC_FRACTION_MG_PER_L" IS NULL THEN 0 ELSE 1 END) +
	SUM(CASE WHEN "ORGANIC_FRACTION_MG_PER_L" IS NULL THEN 0 ELSE 1 END) AS no_measurements_with_data,
	min("LONGITUDE") AS lon,
	min("LATITUDE") AS lat,
	NULL AS min_depth,
	NULL AS max_depth
  FROM anmn_nrs_bgc.anmn_nrs_bgc_tss_secchi_data
	GROUP BY "STATION_NAME", "NRS_TRIP_CODE"),
b AS ( SELECT data_type,
	station_name,
	trip_code,
	to_date(substring(trip_code,'[0-9]+'),'YYYYMMDD') AS sample_date,
	
	CASE WHEN data_type = 'Chemistry' THEN SUM(total_no_parameters) END AS total_no_parameters_chemistry,
	CASE WHEN data_type = 'Phytoplankton pigment' THEN SUM(total_no_parameters) END AS total_no_parameters_phypig,
	CASE WHEN data_type = 'Picoplankton' THEN SUM(total_no_parameters) END AS total_no_parameters_picoplankton,
	CASE WHEN data_type = 'Plankton biomass' THEN SUM(total_no_parameters) END AS total_no_parameters_plankton_biomass,
	CASE WHEN data_type = 'Phytoplankton' THEN SUM(total_no_parameters) END AS total_no_parameters_phytoplankton,
	CASE WHEN data_type = 'Zooplankton' THEN SUM(total_no_parameters) END AS total_no_parameters_zooplankton,
	CASE WHEN data_type = 'Suspended matter' THEN SUM(total_no_parameters) END AS total_no_parameters_suspended_matter,

	CASE WHEN data_type = 'Chemistry' THEN SUM(no_parameters_measured) END AS no_parameters_measured_chemistry,
	CASE WHEN data_type = 'Phytoplankton pigment' THEN SUM(no_parameters_measured) END AS no_parameters_measured_phypig,
	CASE WHEN data_type = 'Picoplankton' THEN SUM(no_parameters_measured) END AS no_parameters_measured_picoplankton,
	CASE WHEN data_type = 'Plankton biomass' THEN SUM(no_parameters_measured) END AS no_parameters_measured_plankton_biomass,
	CASE WHEN data_type = 'Phytoplankton' THEN SUM(no_parameters_measured) END AS no_parameters_measured_phytoplankton,
	CASE WHEN data_type = 'Zooplankton' THEN SUM(no_parameters_measured) END AS no_parameters_measured_zooplankton,
	CASE WHEN data_type = 'Suspended matter' THEN SUM(no_parameters_measured) END AS no_parameters_measured_suspended_matter,
	
	CASE WHEN data_type = 'Chemistry' THEN SUM(total_no_measurements) END AS total_no_measurements_chemistry,
	CASE WHEN data_type = 'Phytoplankton pigment' THEN SUM(total_no_measurements) END AS total_no_measurements_phypig,
	CASE WHEN data_type = 'Picoplankton' THEN SUM(total_no_measurements) END AS total_no_measurements_picoplankton,
	CASE WHEN data_type = 'Plankton biomass' THEN SUM(total_no_measurements) END AS total_no_measurements_plankton_biomass,
	CASE WHEN data_type = 'Phytoplankton' THEN SUM(total_no_measurements) END AS total_no_measurements_phytoplankton,
	CASE WHEN data_type = 'Zooplankton' THEN SUM(total_no_measurements) END AS total_no_measurements_zooplankton,
	CASE WHEN data_type = 'Suspended matter' THEN SUM(total_no_measurements) END AS total_no_measurements_suspended_matter,
	
	CASE WHEN data_type = 'Chemistry' THEN SUM(no_measurements_with_data) END AS no_measurements_with_data_chemistry,
	CASE WHEN data_type = 'Phytoplankton pigment' THEN SUM(no_measurements_with_data) END AS no_measurements_with_data_phypig,
	CASE WHEN data_type = 'Picoplankton' THEN SUM(no_measurements_with_data) END AS no_measurements_with_data_picoplankton,
	CASE WHEN data_type = 'Plankton biomass' THEN SUM(no_measurements_with_data) END AS no_measurements_with_data_plankton_biomass,
	CASE WHEN data_type = 'Phytoplankton' THEN SUM(no_measurements_with_data) END AS no_measurements_with_data_phytoplankton,
	CASE WHEN data_type = 'Zooplankton' THEN SUM(no_measurements_with_data) END AS no_measurements_with_data_zooplankton,
	CASE WHEN data_type = 'Suspended matter' THEN SUM(no_measurements_with_data) END AS no_measurements_with_data_suspended_matter,
	min(lon) AS lon,
	min(lat) AS lat,
	min(min_depth) AS min_depth,
	max(max_depth) AS max_depth
  FROM a
	GROUP BY data_type, station_name, trip_code
	ORDER BY station_name,  sample_date)
  SELECT station_name,
	sample_date,
	COALESCE(MAX(no_parameters_measured_chemistry)||'/'||MAX(total_no_parameters_chemistry)) AS parameter_status_chemistry,
	COALESCE(MAX(no_parameters_measured_phypig)||'/'||MAX(total_no_parameters_phypig)) AS parameter_status_phypig,
	COALESCE(MAX(no_parameters_measured_picoplankton)||'/'||MAX(total_no_parameters_picoplankton)) AS parameter_status_picoplankton,
	COALESCE(MAX(no_parameters_measured_plankton_biomass)||'/'||MAX(total_no_parameters_plankton_biomass)) AS parameter_status_plankton_biomass,
	COALESCE(MAX(no_parameters_measured_phytoplankton)||'/'||MAX(total_no_parameters_phytoplankton)) AS parameter_status_phytoplankton,
	COALESCE(MAX(no_parameters_measured_zooplankton)||'/'||MAX(total_no_parameters_zooplankton)) AS parameter_status_zooplankton,
	COALESCE(MAX(no_parameters_measured_suspended_matter)||'/'||MAX(total_no_parameters_suspended_matter)) AS parameter_status_suspended_matter,

	COALESCE(SUM(no_measurements_with_data_chemistry)||'/'||SUM(total_no_measurements_chemistry)) AS measurement_status_chemistry,
	COALESCE(SUM(no_measurements_with_data_phypig)||'/'||SUM(total_no_measurements_phypig)) AS measurement_status_phypig,
	COALESCE(SUM(no_measurements_with_data_picoplankton)||'/'||SUM(total_no_measurements_picoplankton)) AS measurement_status_picoplankton,
	COALESCE(SUM(no_measurements_with_data_plankton_biomass)||'/'||SUM(total_no_measurements_plankton_biomass)) AS measurement_status_plankton_biomass,
	COALESCE(SUM(no_measurements_with_data_phytoplankton)||'/'||SUM(total_no_measurements_phytoplankton)) AS measurement_status_phytoplankton,
	COALESCE(SUM(no_measurements_with_data_zooplankton)||'/'||SUM(total_no_measurements_zooplankton)) AS measurement_status_zooplankton,
	COALESCE(SUM(no_measurements_with_data_suspended_matter)||'/'||SUM(total_no_measurements_suspended_matter)) AS measurement_status_suspended_matter,
	
	MAX(total_no_parameters_chemistry) AS total_no_chemistry_parameters,
	MAX(total_no_parameters_phypig) AS total_no_phypig_parameters,
	MAX(total_no_parameters_picoplankton) AS total_no_picoplankton_parameters,
	MAX(total_no_parameters_plankton_biomass) AS total_no_plankton_biomass_parameters,
	MAX(total_no_parameters_phytoplankton) AS total_no_phytoplankton_parameters,
	MAX(total_no_parameters_zooplankton) AS total_no_zooplankton_parameters,
	MAX(total_no_parameters_suspended_matter) AS total_no_suspended_matter_parameters,

	MAX(no_parameters_measured_chemistry) AS no_chemistry_parameters_measured,
	MAX(no_parameters_measured_phypig) AS no_phypig_parameters_measured,
	MAX(no_parameters_measured_picoplankton) AS no_picoplankton_parameters_measured,
	MAX(no_parameters_measured_plankton_biomass) AS no_plankton_biomass_parameters_measured,
	MAX(no_parameters_measured_phytoplankton) AS no_phytoplankton_parameters_measured,
	MAX(no_parameters_measured_zooplankton) AS no_zooplankton_parameters_measured,
	MAX(no_parameters_measured_suspended_matter) AS no_suspended_matter_parameters_measured,
	
	SUM(total_no_measurements_chemistry) AS total_no_chemistry_measurements,
	SUM(total_no_measurements_phypig) AS total_no_phypig_measurements,
	SUM(total_no_measurements_picoplankton) AS total_no_picoplankton_measurements,
	SUM(total_no_measurements_plankton_biomass) AS total_no_plankton_biomass_measurements,
	SUM(total_no_measurements_phytoplankton) AS total_no_phytoplankton_measurements,
	SUM(total_no_measurements_zooplankton) AS total_no_zooplankton_measurements,
	SUM(total_no_measurements_suspended_matter) AS total_no_suspended_matter_measurements,
	
	SUM(no_measurements_with_data_chemistry) AS no_chemistry_measurements_with_data,
	SUM(no_measurements_with_data_phypig) AS no_phypig_measurements_with_data,
	SUM(no_measurements_with_data_picoplankton) AS no_picoplankton_measurements_with_data,
	SUM(no_measurements_with_data_plankton_biomass) AS no_plankton_biomass_measurements_with_data,
	SUM(no_measurements_with_data_phytoplankton) AS no_phytoplankton_measurements_with_data,
	SUM(no_measurements_with_data_zooplankton) AS no_zooplankton_measurements_with_data,
	SUM(no_measurements_with_data_suspended_matter) AS no_suspended_matter_measurements_with_data,
	round(min(lon)::numeric,1) AS lon,
	round(min(lat)::numeric,1) AS lat,
	round(min(min_depth)::numeric,1) AS min_depth,
	round(max(max_depth)::numeric,1) AS max_depth
  FROM b
    WHERE station_name != 'Port Hacking 4' -- Get rid of erroneous metadata from Port Hacking 4
	GROUP BY station_name, sample_date
	ORDER BY station_name, sample_date;

grant all on anmn_nrs_bgc_all_deployments_view to public;

---- Data summary
CREATE VIEW anmn_nrs_bgc_data_summary_view AS
  SELECT 'Chemistry' AS product, 
	station_name, 
	min(sample_date) AS first_sample, 
	max(sample_date) AS last_sample, 
	COUNT(*) AS ntrip_total, 
	SUM(CASE WHEN total_no_chemistry_parameters = no_chemistry_parameters_measured THEN 1 ELSE 0 END) AS ntrip_full_data,
	SUM(CASE WHEN no_chemistry_parameters_measured < total_no_chemistry_parameters AND no_chemistry_parameters_measured != 0 THEN 1 ELSE 0 END) AS ntrip_partial_data,
	SUM(CASE WHEN no_chemistry_parameters_measured = 0 THEN 1 ELSE 0 END) AS ntrip_no_data,
	ROUND((SUM(CASE WHEN no_chemistry_parameters_measured > 0 THEN 1 ELSE 0 END)/COUNT(*)::numeric)::numeric * 100, 1) AS percent_ok,
	min(lon) AS lon,
	min(lat) AS lat,
	round(min(min_depth)::numeric,1) AS min_depth,
	round(max(max_depth)::numeric,1) AS max_depth	
  FROM anmn_nrs_bgc_all_deployments_view
  WHERE parameter_status_chemistry IS NOT NULL
  GROUP BY station_name
UNION ALL
  SELECT 'Phytoplankton pigment' AS product, 
  	station_name, 
	min(sample_date) AS first_sample, 
	max(sample_date) AS last_sample, 
	COUNT(*) AS ntrip_total, 
	SUM(CASE WHEN total_no_phypig_parameters = no_phypig_parameters_measured THEN 1 ELSE 0 END) AS ntrip_full_data,
	SUM(CASE WHEN no_phypig_parameters_measured < total_no_phypig_parameters AND no_phypig_parameters_measured != 0 THEN 1 ELSE 0 END) AS ntrip_partial_data,
	SUM(CASE WHEN no_phypig_parameters_measured = 0 THEN 1 ELSE 0 END) AS ntrip_no_data,
	ROUND((SUM(CASE WHEN no_phypig_parameters_measured > 0 THEN 1 ELSE 0 END)/COUNT(*)::numeric)::numeric * 100, 1) AS percent_ok,
	min(lon) AS lon,
	min(lat) AS lat,
	round(min(min_depth)::numeric,1) AS min_depth,
	round(max(max_depth)::numeric,1) AS max_depth
  FROM anmn_nrs_bgc_all_deployments_view
  WHERE parameter_status_phypig IS NOT NULL
  GROUP BY station_name
UNION ALL
  SELECT 'Picoplankton' AS product, 
    	station_name, 
	min(sample_date) AS first_sample, 
	max(sample_date) AS last_sample, 
	COUNT(*) AS ntrip_total, 
	SUM(CASE WHEN total_no_picoplankton_parameters = no_picoplankton_parameters_measured THEN 1 ELSE 0 END) AS ntrip_full_data,
	SUM(CASE WHEN no_picoplankton_parameters_measured < total_no_picoplankton_parameters AND no_picoplankton_parameters_measured != 0 THEN 1 ELSE 0 END) AS ntrip_partial_data,
	SUM(CASE WHEN no_picoplankton_parameters_measured = 0 THEN 1 ELSE 0 END) AS ntrip_no_data,
	ROUND((SUM(CASE WHEN no_picoplankton_parameters_measured > 0 THEN 1 ELSE 0 END)/COUNT(*)::numeric)::numeric * 100, 1) AS percent_ok,
	min(lon) AS lon,
	min(lat) AS lat,
	round(min(min_depth)::numeric,1) AS min_depth,
	round(max(max_depth)::numeric,1) AS max_depth
  FROM anmn_nrs_bgc_all_deployments_view
  WHERE parameter_status_picoplankton IS NOT NULL
  GROUP BY station_name
UNION ALL
  SELECT 'Plankton biomass' AS product,
	station_name, 
	min(sample_date) AS first_sample, 
	max(sample_date) AS last_sample, 
	COUNT(*) AS ntrip_total, 
	SUM(CASE WHEN total_no_plankton_biomass_parameters = no_plankton_biomass_parameters_measured THEN 1 ELSE 0 END) AS ntrip_full_data,
	SUM(CASE WHEN no_plankton_biomass_parameters_measured < total_no_plankton_biomass_parameters AND no_plankton_biomass_parameters_measured != 0 THEN 1 ELSE 0 END) AS ntrip_partial_data,
	SUM(CASE WHEN no_plankton_biomass_parameters_measured = 0 THEN 1 ELSE 0 END) AS ntrip_no_data,
	ROUND((SUM(CASE WHEN no_plankton_biomass_parameters_measured > 0 THEN 1 ELSE 0 END)/COUNT(*)::numeric)::numeric * 100, 1) AS percent_ok,
	min(lon) AS lon,
	min(lat) AS lat,
	round(min(min_depth)::numeric,1) AS min_depth,
	round(max(max_depth)::numeric,1) AS max_depth
  FROM anmn_nrs_bgc_all_deployments_view
  WHERE parameter_status_plankton_biomass IS NOT NULL
  GROUP BY station_name
UNION ALL
  SELECT 'Phytoplankton' AS product,
	station_name, 
	min(sample_date) AS first_sample, 
	max(sample_date) AS last_sample, 
	COUNT(*) AS ntrip_total, 
	SUM(CASE WHEN total_no_phytoplankton_parameters = no_phytoplankton_parameters_measured THEN 1 ELSE 0 END) AS ntrip_full_data,
	SUM(CASE WHEN no_phytoplankton_parameters_measured < total_no_phytoplankton_parameters AND no_phytoplankton_parameters_measured != 0 THEN 1 ELSE 0 END) AS ntrip_partial_data,
	SUM(CASE WHEN no_phytoplankton_parameters_measured = 0 THEN 1 ELSE 0 END) AS ntrip_no_data,
	ROUND((SUM(CASE WHEN no_phytoplankton_parameters_measured > 0 THEN 1 ELSE 0 END)/COUNT(*)::numeric)::numeric * 100, 1) AS percent_ok,
	min(lon) AS lon,
	min(lat) AS lat,
	round(min(min_depth)::numeric,1) AS min_depth,
	round(max(max_depth)::numeric,1) AS max_depth
  FROM anmn_nrs_bgc_all_deployments_view
  WHERE parameter_status_phytoplankton IS NOT NULL
  GROUP BY station_name
UNION ALL
  SELECT 'Zooplankton' AS product,
   	station_name, 
	min(sample_date) AS first_sample, 
	max(sample_date) AS last_sample, 
	COUNT(*) AS ntrip_total, 
	SUM(CASE WHEN total_no_zooplankton_parameters = no_zooplankton_parameters_measured THEN 1 ELSE 0 END) AS ntrip_full_data,
	SUM(CASE WHEN no_zooplankton_parameters_measured < total_no_zooplankton_parameters AND no_zooplankton_parameters_measured != 0 THEN 1 ELSE 0 END) AS ntrip_partial_data,
	SUM(CASE WHEN no_zooplankton_parameters_measured = 0 THEN 1 ELSE 0 END) AS ntrip_no_data,
	ROUND((SUM(CASE WHEN no_zooplankton_parameters_measured > 0 THEN 1 ELSE 0 END)/COUNT(*)::numeric)::numeric * 100, 1) AS percent_ok,
	min(lon) AS lon,
	min(lat) AS lat,
	round(min(min_depth)::numeric,1) AS min_depth,
	round(max(max_depth)::numeric,1) AS max_depth
  FROM anmn_nrs_bgc_all_deployments_view
  WHERE parameter_status_zooplankton IS NOT NULL
  GROUP BY station_name
UNION ALL
  SELECT 'Suspended matter' AS product,
     	station_name, 
	min(sample_date) AS first_sample, 
	max(sample_date) AS last_sample, 
	COUNT(*) AS ntrip_total, 
	SUM(CASE WHEN total_no_suspended_matter_parameters = no_suspended_matter_parameters_measured THEN 1 ELSE 0 END) AS ntrip_full_data,
	SUM(CASE WHEN no_suspended_matter_parameters_measured < total_no_suspended_matter_parameters AND no_suspended_matter_parameters_measured != 0 THEN 1 ELSE 0 END) AS ntrip_partial_data,
	SUM(CASE WHEN no_suspended_matter_parameters_measured = 0 THEN 1 ELSE 0 END) AS ntrip_no_data,
	ROUND(((COUNT(*) - SUM(CASE WHEN no_suspended_matter_parameters_measured = 0 THEN 1 ELSE 0 END))/COUNT(*)::numeric)::numeric * 100, 1) AS percent_ok,
	min(lon) AS lon,
	min(lat) AS lat,
	round(min(min_depth)::numeric,1) AS min_depth,
	round(max(max_depth)::numeric,1) AS max_depth
  FROM anmn_nrs_bgc_all_deployments_view
  WHERE parameter_status_suspended_matter IS NOT NULL
  GROUP BY station_name
  ORDER BY station_name, product;

grant all on anmn_nrs_bgc_data_summary_view to public;