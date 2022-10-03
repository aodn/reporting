SET search_path = reporting, public;
DROP VIEW IF EXISTS anmn_nrs_bgc_all_deployments_view CASCADE;

-------------------------------
-- VIEWS FOR ANMN_NRS_BGC
-------------------------------
-- All deployments
CREATE VIEW anmn_nrs_bgc_all_deployments_view AS
WITH a AS (
  SELECT 'Chemistry' AS data_type,
        "StationName" AS station_name,
        "TripCode" AS trip_code,
        COUNT("SampleID") AS no_samples,
        7 AS total_no_parameters,
        CASE WHEN SUM(CASE WHEN "Salinity" IS NULL THEN 0 ELSE 1 END) = 0 THEN 0 ELSE 1 END +
        CASE WHEN SUM(CASE WHEN "Silicate_umolL" IS NULL THEN 0 ELSE 1 END) = 0 THEN 0 ELSE 1 END +
        CASE WHEN SUM(CASE WHEN "Nitrate_umolL" IS NULL THEN 0 ELSE 1 END) = 0 THEN 0 ELSE 1 END +
        CASE WHEN SUM(CASE WHEN "Phosphate_umolL" IS NULL THEN 0 ELSE 1 END) = 0 THEN 0 ELSE 1 END +
        CASE WHEN SUM(CASE WHEN "Ammonium_umolL" IS NULL THEN 0 ELSE 1 END) = 0 THEN 0 ELSE 1 END +
        CASE WHEN SUM(CASE WHEN "DIC_umolkg" IS NULL THEN 0 ELSE 1 END) = 0 THEN 0 ELSE 1 END +
        CASE WHEN SUM(CASE WHEN "Alkalinity_umolkg" IS NULL THEN 0 ELSE 1 END) = 0 THEN 0 ELSE 1 END AS no_parameters_measured,
        COUNT("SampleID") * 7 AS total_no_measurements,
        SUM(CASE WHEN "Salinity" IS NULL THEN 0 ELSE 1 END) +
        SUM(CASE WHEN "Silicate_umolL" IS NULL THEN 0 ELSE 1 END) +
        SUM(CASE WHEN "Nitrate_umolL" IS NULL THEN 0 ELSE 1 END) +
        SUM(CASE WHEN "Phosphate_umolL" IS NULL THEN 0 ELSE 1 END) +
        SUM(CASE WHEN "Ammonium_umolL" IS NULL THEN 0 ELSE 1 END) +
        SUM(CASE WHEN "DIC_umolkg" IS NULL THEN 0 ELSE 1 END) +
        SUM(CASE WHEN "Alkalinity_umolkg" IS NULL THEN 0 ELSE 1 END) AS no_measurements_with_data,
        min("Longitude") AS lon,
        min("Latitude") AS lat,
        min("SampleDepth_m") AS min_depth,
        max("SampleDepth_m") AS max_depth
  FROM imos_bgc_db.bgc_chemistry_data
        GROUP BY "StationName", "TripCode"
UNION ALL
  SELECT 'Phytoplankton pigment' AS data_type,
        "StationName" AS station_name,
        "TripCode" AS trip_code,
        COUNT("SampleID") AS no_samples,
        41 AS total_no_parameters,
        CASE WHEN SUM(CASE WHEN "CphlC3_mgm3" IS NULL THEN 0 ELSE 1 END) = 0 THEN 0 ELSE 1 END +
        CASE WHEN SUM(CASE WHEN "MgDvp_mgm3" IS NULL THEN 0 ELSE 1 END) = 0 THEN 0 ELSE 1 END +
        CASE WHEN SUM(CASE WHEN "CphlC2_mgm3" IS NULL THEN 0 ELSE 1 END) = 0 THEN 0 ELSE 1 END +
        CASE WHEN SUM(CASE WHEN "CphlC1_mgm3" IS NULL THEN 0 ELSE 1 END) = 0 THEN 0 ELSE 1 END +
        CASE WHEN SUM(CASE WHEN "CphlC1C2_mgm3" IS NULL THEN 0 ELSE 1 END) = 0 THEN 0 ELSE 1 END +
        CASE WHEN SUM(CASE WHEN "CphlideA_mgm3" IS NULL THEN 0 ELSE 1 END) = 0 THEN 0 ELSE 1 END +
        CASE WHEN SUM(CASE WHEN "PhideA_mgm3" IS NULL THEN 0 ELSE 1 END) = 0 THEN 0 ELSE 1 END +
        CASE WHEN SUM(CASE WHEN "Perid_mgm3" IS NULL THEN 0 ELSE 1 END) = 0 THEN 0 ELSE 1 END +
        CASE WHEN SUM(CASE WHEN "PyrophideA_mgm3" IS NULL THEN 0 ELSE 1 END) = 0 THEN 0 ELSE 1 END +
        CASE WHEN SUM(CASE WHEN "Butfuco_mgm3" IS NULL THEN 0 ELSE 1 END) = 0 THEN 0 ELSE 1 END +
        CASE WHEN SUM(CASE WHEN "Fuco_mgm3" IS NULL THEN 0 ELSE 1 END) = 0 THEN 0 ELSE 1 END +
        CASE WHEN SUM(CASE WHEN "Neo_mgm3" IS NULL THEN 0 ELSE 1 END) = 0 THEN 0 ELSE 1 END +
        CASE WHEN SUM(CASE WHEN "Ketohexfuco_mgm3" IS NULL THEN 0 ELSE 1 END) = 0 THEN 0 ELSE 1 END +
        CASE WHEN SUM(CASE WHEN "Pras_mgm3" IS NULL THEN 0 ELSE 1 END) = 0 THEN 0 ELSE 1 END +
        CASE WHEN SUM(CASE WHEN "Viola_mgm3" IS NULL THEN 0 ELSE 1 END) = 0 THEN 0 ELSE 1 END +
        CASE WHEN SUM(CASE WHEN "Hexfuco_mgm3" IS NULL THEN 0 ELSE 1 END) = 0 THEN 0 ELSE 1 END +
        CASE WHEN SUM(CASE WHEN "Asta_mgm3" IS NULL THEN 0 ELSE 1 END) = 0 THEN 0 ELSE 1 END +
        CASE WHEN SUM(CASE WHEN "Diadchr_mgm3" IS NULL THEN 0 ELSE 1 END) = 0 THEN 0 ELSE 1 END +
        CASE WHEN SUM(CASE WHEN "Diadino_mgm3" IS NULL THEN 0 ELSE 1 END) = 0 THEN 0 ELSE 1 END +
        CASE WHEN SUM(CASE WHEN "Dino_mgm3" IS NULL THEN 0 ELSE 1 END) = 0 THEN 0 ELSE 1 END +
        CASE WHEN SUM(CASE WHEN "Anth_mgm3" IS NULL THEN 0 ELSE 1 END) = 0 THEN 0 ELSE 1 END +
        CASE WHEN SUM(CASE WHEN "Allo_mgm3" IS NULL THEN 0 ELSE 1 END) = 0 THEN 0 ELSE 1 END +
        CASE WHEN SUM(CASE WHEN "Diato_mgm3" IS NULL THEN 0 ELSE 1 END) = 0 THEN 0 ELSE 1 END +
        CASE WHEN SUM(CASE WHEN "Zea_mgm3" IS NULL THEN 0 ELSE 1 END) = 0 THEN 0 ELSE 1 END +
        CASE WHEN SUM(CASE WHEN "Lut_mgm3" IS NULL THEN 0 ELSE 1 END) = 0 THEN 0 ELSE 1 END +
        CASE WHEN SUM(CASE WHEN "Cantha_mgm3" IS NULL THEN 0 ELSE 1 END) = 0 THEN 0 ELSE 1 END +
        CASE WHEN SUM(CASE WHEN "Gyro_mgm3" IS NULL THEN 0 ELSE 1 END) = 0 THEN 0 ELSE 1 END +
        CASE WHEN SUM(CASE WHEN "DvCphlB_mgm3" IS NULL THEN 0 ELSE 1 END) = 0 THEN 0 ELSE 1 END +
        CASE WHEN SUM(CASE WHEN "CphlB_mgm3" IS NULL THEN 0 ELSE 1 END) = 0 THEN 0 ELSE 1 END +
        CASE WHEN SUM(CASE WHEN "DvCphlB+CphlB_mgm3" IS NULL THEN 0 ELSE 1 END) = 0 THEN 0 ELSE 1 END +
        CASE WHEN SUM(CASE WHEN "DvCphlA_mgm3" IS NULL THEN 0 ELSE 1 END) = 0 THEN 0 ELSE 1 END +
        CASE WHEN SUM(CASE WHEN "CphlA_mgm3" IS NULL THEN 0 ELSE 1 END) = 0 THEN 0 ELSE 1 END +
        CASE WHEN SUM(CASE WHEN "DvCphlA+CphlA_mgm3" IS NULL THEN 0 ELSE 1 END) = 0 THEN 0 ELSE 1 END +
        CASE WHEN SUM(CASE WHEN "Echin_mgm3" IS NULL THEN 0 ELSE 1 END) = 0 THEN 0 ELSE 1 END +
        CASE WHEN SUM(CASE WHEN "PhytinB_mgm3" IS NULL THEN 0 ELSE 1 END) = 0 THEN 0 ELSE 1 END +
        CASE WHEN SUM(CASE WHEN "PhytinA_mgm3" IS NULL THEN 0 ELSE 1 END) = 0 THEN 0 ELSE 1 END +
        CASE WHEN SUM(CASE WHEN "Lyco_mgm3" IS NULL THEN 0 ELSE 1 END) = 0 THEN 0 ELSE 1 END +
        CASE WHEN SUM(CASE WHEN "BetaEpiCar_mgm3" IS NULL THEN 0 ELSE 1 END) = 0 THEN 0 ELSE 1 END +
        CASE WHEN SUM(CASE WHEN "BetaBetaCar_mgm3" IS NULL THEN 0 ELSE 1 END) = 0 THEN 0 ELSE 1 END +
        CASE WHEN SUM(CASE WHEN "AlphaBetaCar_mgm3" IS NULL THEN 0 ELSE 1 END) = 0 THEN 0 ELSE 1 END +
        CASE WHEN SUM(CASE WHEN "PyrophytinA_mgm3" IS NULL THEN 0 ELSE 1 END) = 0 THEN 0 ELSE 1 END AS no_parameters_measured,
        COUNT("SampleID") * 41 AS total_no_measurements,
        SUM(CASE WHEN "CphlC3_mgm3" IS NULL THEN 0 ELSE 1 END) +
        SUM(CASE WHEN "MgDvp_mgm3" IS NULL THEN 0 ELSE 1 END) +
        SUM(CASE WHEN "CphlC2_mgm3" IS NULL THEN 0 ELSE 1 END) +
        SUM(CASE WHEN "CphlC1_mgm3" IS NULL THEN 0 ELSE 1 END) +
        SUM(CASE WHEN "CphlC1C2_mgm3" IS NULL THEN 0 ELSE 1 END) +
        SUM(CASE WHEN "CphlideA_mgm3" IS NULL THEN 0 ELSE 1 END) +
        SUM(CASE WHEN "PhideA_mgm3" IS NULL THEN 0 ELSE 1 END) +
        SUM(CASE WHEN "Perid_mgm3" IS NULL THEN 0 ELSE 1 END) +
        SUM(CASE WHEN "PyrophideA_mgm3" IS NULL THEN 0 ELSE 1 END) +
        SUM(CASE WHEN "Butfuco_mgm3" IS NULL THEN 0 ELSE 1 END) +
        SUM(CASE WHEN "Fuco_mgm3" IS NULL THEN 0 ELSE 1 END) +
        SUM(CASE WHEN "Neo_mgm3" IS NULL THEN 0 ELSE 1 END) +
        SUM(CASE WHEN "Ketohexfuco_mgm3" IS NULL THEN 0 ELSE 1 END) +
        SUM(CASE WHEN "Pras_mgm3" IS NULL THEN 0 ELSE 1 END) +
        SUM(CASE WHEN "Viola_mgm3" IS NULL THEN 0 ELSE 1 END) +
        SUM(CASE WHEN "Hexfuco_mgm3" IS NULL THEN 0 ELSE 1 END) +
        SUM(CASE WHEN "Asta_mgm3" IS NULL THEN 0 ELSE 1 END) +
        SUM(CASE WHEN "Diadchr_mgm3" IS NULL THEN 0 ELSE 1 END) +
        SUM(CASE WHEN "Diadino_mgm3" IS NULL THEN 0 ELSE 1 END) +
        SUM(CASE WHEN "Dino_mgm3" IS NULL THEN 0 ELSE 1 END) +
        SUM(CASE WHEN "Anth_mgm3" IS NULL THEN 0 ELSE 1 END) +
        SUM(CASE WHEN "Allo_mgm3" IS NULL THEN 0 ELSE 1 END) +
        SUM(CASE WHEN "Diato_mgm3" IS NULL THEN 0 ELSE 1 END) +
        SUM(CASE WHEN "Zea_mgm3" IS NULL THEN 0 ELSE 1 END) +
        SUM(CASE WHEN "Lut_mgm3" IS NULL THEN 0 ELSE 1 END) +
        SUM(CASE WHEN "Cantha_mgm3" IS NULL THEN 0 ELSE 1 END) +
        SUM(CASE WHEN "Gyro_mgm3" IS NULL THEN 0 ELSE 1 END) +
        SUM(CASE WHEN "DvCphlB_mgm3" IS NULL THEN 0 ELSE 1 END) +
        SUM(CASE WHEN "CphlB_mgm3" IS NULL THEN 0 ELSE 1 END) +
        SUM(CASE WHEN "DvCphlB+CphlB_mgm3" IS NULL THEN 0 ELSE 1 END) +
        SUM(CASE WHEN "DvCphlA_mgm3" IS NULL THEN 0 ELSE 1 END) +
        SUM(CASE WHEN "CphlA_mgm3" IS NULL THEN 0 ELSE 1 END) +
        SUM(CASE WHEN "DvCphlA+CphlA_mgm3" IS NULL THEN 0 ELSE 1 END) +
        SUM(CASE WHEN "Echin_mgm3" IS NULL THEN 0 ELSE 1 END) +
        SUM(CASE WHEN "PhytinB_mgm3" IS NULL THEN 0 ELSE 1 END) +
        SUM(CASE WHEN "PhytinA_mgm3" IS NULL THEN 0 ELSE 1 END) +
        SUM(CASE WHEN "Lyco_mgm3" IS NULL THEN 0 ELSE 1 END) +
        SUM(CASE WHEN "BetaEpiCar_mgm3" IS NULL THEN 0 ELSE 1 END) +
        SUM(CASE WHEN "BetaBetaCar_mgm3" IS NULL THEN 0 ELSE 1 END) +
        SUM(CASE WHEN "AlphaBetaCar_mgm3" IS NULL THEN 0 ELSE 1 END) +
        SUM(CASE WHEN "PyrophytinA_mgm3" IS NULL THEN 0 ELSE 1 END) AS no_measurements_with_data,
        min("Longitude") AS lon,
        min("Latitude") AS lat,
        min("SampleDepth_m") AS min_depth,
        max("SampleDepth_m") AS max_depth
  FROM imos_bgc_db.bgc_pigments_data
        GROUP BY "StationName", "TripCode"
UNION ALL
  SELECT 'Picoplankton' AS data_type,
        "StationName" AS station_name,
        "TripCode" AS trip_code,
        COUNT("SampleID") AS no_samples,
        3 AS total_no_parameters,
        CASE WHEN SUM(CASE WHEN "Prochlorococcus_cellsmL" IS NULL THEN 0 ELSE 1 END) = 0 THEN 0 ELSE 1 END +
        CASE WHEN SUM(CASE WHEN "Synechococcus_cellsmL" IS NULL THEN 0 ELSE 1 END) = 0 THEN 0 ELSE 1 END +
        CASE WHEN SUM(CASE WHEN "Picoeukaryotes_cellsmL" IS NULL THEN 0 ELSE 1 END) = 0 THEN 0 ELSE 1 END AS no_parameters_measured,
        COUNT("SampleID") * 3 AS total_no_measurements,
        SUM(CASE WHEN "Prochlorococcus_cellsmL" IS NULL THEN 0 ELSE 1 END) +
        SUM(CASE WHEN "Synechococcus_cellsmL" IS NULL THEN 0 ELSE 1 END) +
        SUM(CASE WHEN "Picoeukaryotes_cellsmL" IS NULL THEN 0 ELSE 1 END) AS no_measurements_with_data,
        min("Longitude") AS lon,
        min("Latitude") AS lat,
        min("SampleDepth_m") AS min_depth,
        max("SampleDepth_m") AS max_depth
  FROM imos_bgc_db.bgc_picoplankton_data
        GROUP BY "StationName", "TripCode"
UNION ALL
  SELECT 'Plankton biomass' AS data_type,
        "StationName" AS station_name,
        "TripCode" AS trip_code,
        COUNT("TripCode") AS no_samples,
        1 AS total_no_parameters,
        CASE WHEN SUM(CASE WHEN "Biomass_mgm3" IS NULL THEN 0 ELSE 1 END) = 0 THEN 0 ELSE 1 END AS no_parameters_measured,
        COUNT("TripCode") AS total_no_measurements,
        SUM(CASE WHEN "Biomass_mgm3" IS NULL THEN 0 ELSE 1 END) AS no_measurements_with_data,
        min("Longitude") AS lon,
        min("Latitude") AS lat,
        NULL AS min_depth,
        NULL AS max_depth
  FROM imos_bgc_db.bgc_trip_metadata
        GROUP BY "StationName", "TripCode"
UNION ALL
  SELECT 'Phytoplankton' AS data_type,
        "StationName" AS station_name,
        "trip_code" AS trip_code,
        COUNT("trip_code") AS no_samples,
        3 AS total_no_parameters,
        CASE WHEN SUM(CASE WHEN "taxon_name" IS NULL THEN 0 ELSE 1 END) = 0 THEN 0 ELSE 1 END +
        CASE WHEN SUM(CASE WHEN "cell_l" IS NULL THEN 0 ELSE 1 END) = 0 THEN 0 ELSE 1 END +
        CASE WHEN SUM(CASE WHEN "biovolume_um3l" IS NULL THEN 0 ELSE 1 END) = 0 THEN 0 ELSE 1 END AS no_parameters_measured,
        COUNT("trip_code") * 3 AS total_no_measurements,
        SUM(CASE WHEN "taxon_name" IS NULL THEN 0 ELSE 1 END) +
        SUM(CASE WHEN "cell_l" IS NULL THEN 0 ELSE 1 END) +
        SUM(CASE WHEN "biovolume_um3l" IS NULL THEN 0 ELSE 1 END) AS no_measurements_with_data,
        min("Longitude") AS lon,
        min("Latitude") AS lat,
        NULL AS min_depth,
        NULL AS max_depth
  FROM imos_bgc_db.bgc_phyto_raw r
        INNER JOIN imos_bgc_db.bgc_trip_metadata b USING (trip_code)
        GROUP BY "StationName", "trip_code"
UNION ALL
  SELECT 'Zooplankton' AS data_type,
        "StationName" AS station_name,
        "trip_code" AS trip_code,
        COUNT("trip_code") AS no_samples,
        2 AS total_no_parameters,
        CASE WHEN SUM(CASE WHEN "taxon_name" IS NULL THEN 0 ELSE 1 END) = 0 THEN 0 ELSE 1 END +
        CASE WHEN SUM(CASE WHEN "zoop_abundance_m3" IS NULL THEN 0 ELSE 1 END) = 0 THEN 0 ELSE 1 END AS no_parameters_measured,
        COUNT("trip_code") * 2 AS total_no_measurements,
        SUM(CASE WHEN "taxon_name" IS NULL THEN 0 ELSE 1 END) +
        SUM(CASE WHEN "zoopsampledepth_m" IS NULL THEN 0 ELSE 1 END) AS no_measurements_with_data,
        min("Longitude") AS lon,
        min("Latitude") AS lat,
        NULL AS min_depth,
        NULL AS max_depth
  FROM imos_bgc_db.bgc_zoop_raw
        INNER JOIN imos_bgc_db.bgc_trip_metadata b USING (trip_code)
        GROUP BY "StationName", "trip_code"
UNION ALL
  SELECT 'Suspended matter' AS data_type,
        "StationName" AS station_name,
        "TripCode" AS trip_code,
        COUNT("SampleID") AS no_samples,
        3 AS total_no_parameters,
        CASE WHEN SUM(CASE WHEN "TSS_mgL" IS NULL THEN 0 ELSE 1 END) = 0 THEN 0 ELSE 1 END +
        CASE WHEN SUM(CASE WHEN "TSSinorganic_mgL" IS NULL THEN 0 ELSE 1 END) = 0 THEN 0 ELSE 1 END +
        CASE WHEN SUM(CASE WHEN "TSSorganic_mgL" IS NULL THEN 0 ELSE 1 END) = 0 THEN 0 ELSE 1 END AS no_parameters_measured,
        COUNT("SampleID") * 3 AS total_no_measurements,
        SUM(CASE WHEN "TSS_mgL" IS NULL THEN 0 ELSE 1 END) +
        SUM(CASE WHEN "TSSinorganic_mgL" IS NULL THEN 0 ELSE 1 END) +
        SUM(CASE WHEN "TSSorganic_mgL" IS NULL THEN 0 ELSE 1 END) AS no_measurements_with_data,
        min("Longitude") AS lon,
        min("Latitude") AS lat,
        NULL AS min_depth,
        NULL AS max_depth
  FROM imos_bgc_db.bgc_tss_data
        GROUP BY "StationName", "TripCode"),
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

-- ALTER VIEW anmn_nrs_bgc_all_deployments_view OWNER TO harvest_reporting_write_group;
-- ALTER VIEW anmn_nrs_bgc_data_summary_view OWNER TO harvest_reporting_write_group;
