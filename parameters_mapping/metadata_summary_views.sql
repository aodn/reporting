SET SEARCH_PATH = parameters_mapping, contr_vocab_db, public; 

-- AATAMS Biologging penguin
CREATE OR REPLACE VIEW aatams_biologging_penguin_metadata_summary AS
WITH p AS (
  SELECT '# ' || variable_name || ',' || cf_standard_name || ',' || imos_vocabulary_name || ',' || uv.name || ',' || uv.short_name || ',' || uv.definition
  FROM parameters_mapping pm
  LEFT JOIN unit_view uv ON pm.unit_id = uv.id
  LEFT JOIN parameters p ON p.unique_id = pm.parameter_id
	WHERE facility = 'AATAMS' AND subfacility = 'biologging' AND product = 'penguin'
	ORDER BY variable_name || ',' || cf_standard_name || ',' || imos_vocabulary_name || ',' || uv.name || ',' || uv.short_name || ',' || uv.definition)
  SELECT '# data_column_name' || ',' || 'cf_standard_name' || ',' || 'imos_vocabulary_name' || ',' || 'unit_name' || ',' || 'unit_short_name' || ',' || 'uv.definition'
UNION ALL
  SELECT * FROM p WHERE "?column?" IS NOT NULL;

GRANT SELECT ON aatams_biologging_penguin_metadata_summary TO harvest_read_group;

-- AATAMS Biologging shearwater
CREATE OR REPLACE VIEW aatams_biologging_shearwater_metadata_summary AS
WITH p AS (
  SELECT '# ' || variable_name || ',' || cf_standard_name || ',' || imos_vocabulary_name || ',' || uv.name || ',' || uv.short_name || ',' || uv.definition
  FROM parameters_mapping pm
  LEFT JOIN unit_view uv ON pm.unit_id = uv.id
  LEFT JOIN parameters p ON p.unique_id = pm.parameter_id
	WHERE facility = 'AATAMS' AND subfacility = 'biologging' AND product = 'shearwater'
	ORDER BY variable_name || ',' || cf_standard_name || ',' || imos_vocabulary_name || ',' || uv.name || ',' || uv.short_name || ',' || uv.definition),
 a AS (SELECT DISTINCT animal_id,substring(animal_id,'(.*)_')::text AS id FROM aatams_biologging_shearwater.aatams_biologging_shearwater_map ORDER BY substring(animal_id,'(.*)_')),
 b AS (SELECT '# ' || a.animal_id || ',' || tag_type || ',' || tag_code || ',' || tag_id || ',' || round(release_longitude::numeric,3) || ',' || round(release_latitude::numeric,3) || ',' || 
COALESCE(mass_at_release::text,'') || ',' || COALESCE(round(culman_length::numeric,1)::text,'') || ',' || COALESCE(round(culman_height::numeric,1)::text,'')
FROM a
JOIN aatams_biologging_shearwater.aatams_biologging_shearwater_metadata m ON m.tag_id::text = a.id
ORDER BY a.animal_id)
  SELECT '# data_column_name' || ',' || 'cf_standard_name' || ',' || 'imos_vocabulary_name' || ',' || 'unit_name' || ',' || 'unit_short_name' || ',' || 'uv.definition'
UNION ALL
  SELECT * FROM p WHERE "?column?" IS NOT NULL
UNION ALL
  SELECT '#'
UNION ALL
  SELECT '# animal_id' || ',' || 'tag_type' || ',' || 'tag_code' || ',' || 'tag_id' || ',' || 'release_longitude' || ',' || 'release_latitude' || ',' || 'mass_at_release_g' || ',' ||
	'culman_length_cm' || ',' || 'culman_height_cm'
UNION ALL
  SELECT * FROM b;

GRANT SELECT ON aatams_biologging_shearwater_metadata_summary TO harvest_read_group;

-- AATAMS sattag dm
CREATE OR REPLACE VIEW aatams_sattag_dm_metadata_summary AS
WITH p AS (
  SELECT '# ' || variable_name || ',' || cf_standard_name || ',' || imos_vocabulary_name || ',' || uv.name || ',' || uv.short_name || ',' || uv.definition
  FROM parameters_mapping pm
  LEFT JOIN unit_view uv ON pm.unit_id = uv.id
  LEFT JOIN parameters p ON p.unique_id = pm.parameter_id
	WHERE facility = 'AATAMS' AND subfacility = 'sattag' AND product = 'dm'
	ORDER BY variable_name || ',' || cf_standard_name || ',' || imos_vocabulary_name || ',' || uv.name || ',' || uv.short_name || ',' || uv.definition),
 a AS (SELECT DISTINCT device_id FROM aatams_sattag_dm.aatams_sattag_dm_profile_map ORDER BY device_id),
 b AS (SELECT '# ' || a.device_id || ',' || m.device_wmo_ref || ',' || m.tag_type || ',' || m.common_name || ',' || m.release_site || ',' || COALESCE(m.release_lon::text,'') || ',' || COALESCE(m.release_lat::text,'') || ',' || m.state_country  || ',' || 
	COALESCE(date(m.release_date)::text,'') || ',' || COALESCE(date(m.recovery_date)::text,'') || ',' || m.age_class || ',' || m.sex || ',' || COALESCE(m.length::text,'') || ',' || 
	COALESCE(m.girth::text,'') || ',' || COALESCE(m.estimated_mass::text,'') || ',' || COALESCE(m.actual_mass::text,'') || ',' || m.sample || ',' || m.comment || ',' || m.pi || ',' || m.institution
  FROM a
  LEFT JOIN aatams_sattag_nrt.aatams_sattag_nrt_metadata m ON a.device_id = m.device_id
  	ORDER BY a.device_id)
  SELECT '# data_column_name' || ',' || 'cf_standard_name' || ',' || 'imos_vocabulary_name' || ',' || 'unit_name' || ',' || 'unit_short_name' || ',' || 'uv.definition'
UNION ALL
  SELECT * FROM p WHERE "?column?" IS NOT NULL
UNION ALL
  SELECT '#'
UNION ALL
  SELECT '# device_id' || ',' || 'device_wmo_ref' || ',' || 'tag_type' || ',' || 'common_name' || ',' || 'release_site' || ',' || 'release_lon' || ',' ||
	'release_lat' || ',' || 'state_country' || ',' || 'release_date' || ',' || 'recovery_date' || ',' || 'age_class' || ',' || 'sex' || ',' ||
	'length' || ',' || 'girth' || ',' || 'estimated_mass' || ',' || 'actual_mass' || ',' || 'sample' || ',' || 'comment' || ',' || 'principal investigator' || ',' || 'institution'
UNION ALL
  SELECT * FROM b;

GRANT SELECT ON aatams_sattag_dm_metadata_summary TO harvest_read_group;

-- AATAMS sattag nrt
CREATE OR REPLACE VIEW aatams_sattag_nrt_metadata_summary AS
WITH p AS (
  SELECT '# ' || variable_name || ',' || cf_standard_name || ',' || imos_vocabulary_name || ',' || uv.name || ',' || uv.short_name || ',' || uv.definition
  FROM parameters_mapping pm
  LEFT JOIN unit_view uv ON pm.unit_id = uv.id
  LEFT JOIN parameters p ON p.unique_id = pm.parameter_id
	WHERE facility = 'AATAMS' AND subfacility = 'sattag' AND product = 'nrt'
	ORDER BY variable_name || ',' || cf_standard_name || ',' || imos_vocabulary_name || ',' || uv.name || ',' || uv.short_name || ',' || uv.definition),
 a AS (SELECT DISTINCT device_id FROM aatams_sattag_nrt.aatams_sattag_nrt_profile_map ORDER BY device_id),
 b AS (SELECT '# ' || a.device_id || ',' || m.device_wmo_ref || ',' || m.tag_type || ',' || m.common_name || ',' || m.release_site || ',' || COALESCE(m.release_lon::text,'') || ',' || COALESCE(m.release_lat::text,'') || ',' || m.state_country  || ',' || 
	COALESCE(date(m.release_date)::text,'') || ',' || COALESCE(date(m.recovery_date)::text,'') || ',' || m.age_class || ',' || m.sex || ',' || COALESCE(m.length::text,'') || ',' || 
	COALESCE(m.girth::text,'') || ',' || COALESCE(m.estimated_mass::text,'') || ',' || COALESCE(m.actual_mass::text,'') || ',' || m.sample || ',' || m.comment || ',' || m.pi || ',' || m.institution
  FROM a
  LEFT JOIN aatams_sattag_nrt.aatams_sattag_nrt_metadata m ON a.device_id = m.device_id
  	ORDER BY a.device_id)
  SELECT '# data_column_name' || ',' || 'cf_standard_name' || ',' || 'imos_vocabulary_name' || ',' || 'unit_name' || ',' || 'unit_short_name' || ',' || 'uv.definition'
UNION ALL
  SELECT * FROM p WHERE "?column?" IS NOT NULL
UNION ALL
  SELECT '#'
UNION ALL
  SELECT '# device_id' || ',' || 'device_wmo_ref' || ',' || 'tag_type' || ',' || 'common_name' || ',' || 'release_site' || ',' || 'release_lon' || ',' ||
	'release_lat' || ',' || 'state_country' || ',' || 'release_date' || ',' || 'recovery_date' || ',' || 'age_class' || ',' || 'sex' || ',' ||
	'length' || ',' || 'girth' || ',' || 'estimated_mass' || ',' || 'actual_mass' || ',' || 'sample' || ',' || 'comment' || ',' || 'principal investigator' || ',' || 'institution'
UNION ALL
  SELECT * FROM b;

GRANT SELECT ON aatams_sattag_nrt_metadata_summary TO harvest_read_group;

-- ABOS timeseries
CREATE OR REPLACE VIEW abos_ts_metadata_summary AS
WITH p AS (
  SELECT '# ' || variable_name || ',' || cf_standard_name || ',' || imos_vocabulary_name || ',' || uv.name || ',' || uv.short_name || ',' || uv.definition
  FROM parameters_mapping pm
  LEFT JOIN unit_view uv ON pm.unit_id = uv.id
  LEFT JOIN parameters p ON p.unique_id = pm.parameter_id
	WHERE facility = 'ABOS' AND product = 'timeseries'
	ORDER BY variable_name || ',' || cf_standard_name || ',' || imos_vocabulary_name || ',' || uv.name || ',' || uv.short_name || ',' || uv.definition),
  q AS (
    SELECT DISTINCT '# ' || qc_scheme_short_name || ',' || flag_value || ',' || flag_meaning || ',' || flag_description
  FROM parameters_mapping pm
  LEFT JOIN qc_scheme qs ON qs.qc_scheme_id = pm.qc_scheme_id
  LEFT JOIN qc_flags qf ON qf.qc_scheme_id = qs.qc_scheme_id
	WHERE facility = 'ABOS' AND product = 'timeseries'
	ORDER BY '# ' || qc_scheme_short_name || ',' || flag_value || ',' || flag_meaning || ',' || flag_description)
  SELECT '# data_column_name' || ',' || 'cf_standard_name' || ',' || 'imos_vocabulary_name' || ',' || 'unit_name' || ',' || 'unit_short_name' || ',' || 'uv.definition'
UNION ALL
  SELECT * FROM p WHERE "?column?" IS NOT NULL
UNION ALL
  SELECT '#'
UNION ALL
  SELECT '# qc_scheme_short_name' || ',' || 'flag_value' || ',' || 'flag_meaning' || ',' || 'flag_description'
UNION ALL
  SELECT * FROM q;

GRANT SELECT ON abos_ts_metadata_summary TO harvest_read_group;

-- ABOS SOFS fl
CREATE OR REPLACE VIEW abos_sofs_fl_metadata_summary AS
WITH p AS (
  SELECT '# ' || variable_name || ',' || cf_standard_name || ',' || imos_vocabulary_name || ',' || uv.name || ',' || uv.short_name || ',' || uv.definition
  FROM parameters_mapping pm
  LEFT JOIN unit_view uv ON pm.unit_id = uv.id
  LEFT JOIN parameters p ON p.unique_id = pm.parameter_id
	WHERE facility = 'ABOS' AND subfacility = 'SOFS' AND product = 'surface fluxes'
	ORDER BY variable_name || ',' || cf_standard_name || ',' || imos_vocabulary_name || ',' || uv.name || ',' || uv.short_name || ',' || uv.definition),
  q AS (
    SELECT DISTINCT '# ' || qc_scheme_short_name || ',' || flag_value || ',' || flag_meaning || ',' || flag_description
  FROM parameters_mapping pm
  LEFT JOIN qc_scheme qs ON qs.qc_scheme_id = pm.qc_scheme_id
  LEFT JOIN qc_flags qf ON qf.qc_scheme_id = qs.qc_scheme_id
	WHERE facility = 'ABOS' AND subfacility = 'SOFS' AND product = 'surface fluxes'
	ORDER BY '# ' || qc_scheme_short_name || ',' || flag_value || ',' || flag_meaning || ',' || flag_description)
  SELECT '# data_column_name' || ',' || 'cf_standard_name' || ',' || 'imos_vocabulary_name' || ',' || 'unit_name' || ',' || 'unit_short_name' || ',' || 'uv.definition'
UNION ALL
  SELECT * FROM p WHERE "?column?" IS NOT NULL
UNION ALL
  SELECT '#'
UNION ALL
  SELECT '# qc_scheme_short_name' || ',' || 'flag_value' || ',' || 'flag_meaning' || ',' || 'flag_description'
UNION ALL
  SELECT * FROM q;

GRANT SELECT ON abos_sofs_fl_metadata_summary TO harvest_read_group;

-- ABOS SOFS sp
CREATE OR REPLACE VIEW abos_sofs_sp_metadata_summary AS
WITH p AS (
  SELECT '# ' || variable_name || ',' || cf_standard_name || ',' || imos_vocabulary_name || ',' || uv.name || ',' || uv.short_name || ',' || uv.definition
  FROM parameters_mapping pm
  LEFT JOIN unit_view uv ON pm.unit_id = uv.id
  LEFT JOIN parameters p ON p.unique_id = pm.parameter_id
	WHERE facility = 'ABOS' AND subfacility = 'SOFS' AND product = 'surface properties'
	ORDER BY variable_name || ',' || cf_standard_name || ',' || imos_vocabulary_name || ',' || uv.name || ',' || uv.short_name || ',' || uv.definition),
  q AS (
    SELECT DISTINCT '# ' || qc_scheme_short_name || ',' || flag_value || ',' || flag_meaning || ',' || flag_description
  FROM parameters_mapping pm
  LEFT JOIN qc_scheme qs ON qs.qc_scheme_id = pm.qc_scheme_id
  LEFT JOIN qc_flags qf ON qf.qc_scheme_id = qs.qc_scheme_id
	WHERE facility = 'ABOS' AND subfacility = 'SOFS' AND product = 'surface properties'
	ORDER BY '# ' || qc_scheme_short_name || ',' || flag_value || ',' || flag_meaning || ',' || flag_description)
  SELECT '# data_column_name' || ',' || 'cf_standard_name' || ',' || 'imos_vocabulary_name' || ',' || 'unit_name' || ',' || 'unit_short_name' || ',' || 'uv.definition'
UNION ALL
  SELECT * FROM p WHERE "?column?" IS NOT NULL
UNION ALL
  SELECT '#'
UNION ALL
  SELECT '# qc_scheme_short_name' || ',' || 'flag_value' || ',' || 'flag_meaning' || ',' || 'flag_description'
UNION ALL
  SELECT * FROM q;

GRANT SELECT ON abos_sofs_sp_metadata_summary TO harvest_read_group;

-- ANFOG DM
CREATE OR REPLACE VIEW anfog_dm_metadata_summary AS
WITH p AS (
  SELECT '# ' || variable_name || ',' || cf_standard_name || ',' || imos_vocabulary_name || ',' || uv.name || ',' || uv.short_name || ',' || uv.definition
  FROM parameters_mapping pm
  LEFT JOIN unit_view uv ON pm.unit_id = uv.id
  LEFT JOIN parameters p ON p.unique_id = pm.parameter_id
	WHERE facility = 'ANFOG'
	ORDER BY variable_name || ',' || cf_standard_name || ',' || imos_vocabulary_name || ',' || uv.name || ',' || uv.short_name || ',' || uv.definition),
  q AS (
    SELECT DISTINCT '# ' || qc_scheme_short_name || ',' || flag_value || ',' || flag_meaning || ',' || flag_description
  FROM parameters_mapping pm
  LEFT JOIN qc_scheme qs ON qs.qc_scheme_id = pm.qc_scheme_id
  LEFT JOIN qc_flags qf ON qf.qc_scheme_id = qs.qc_scheme_id
	WHERE facility = 'ANFOG'
	ORDER BY '# ' || qc_scheme_short_name || ',' || flag_value || ',' || flag_meaning || ',' || flag_description)
  SELECT '# data_column_name' || ',' || 'cf_standard_name' || ',' || 'imos_vocabulary_name' || ',' || 'unit_name' || ',' || 'unit_short_name' || ',' || 'uv.definition'
UNION ALL
  SELECT * FROM p WHERE "?column?" IS NOT NULL
UNION ALL
  SELECT '#'
UNION ALL
  SELECT '# qc_scheme_short_name' || ',' || 'flag_value' || ',' || 'flag_meaning' || ',' || 'flag_description'
UNION ALL
  SELECT * FROM q;

GRANT SELECT ON anfog_dm_metadata_summary TO harvest_read_group;

-- ANFOG RT
CREATE OR REPLACE VIEW anfog_rt_metadata_summary AS
WITH p AS (
  SELECT '# ' || variable_name || ',' || cf_standard_name || ',' || imos_vocabulary_name || ',' || uv.name || ',' || uv.short_name || ',' || uv.definition
  FROM parameters_mapping pm
  LEFT JOIN unit_view uv ON pm.unit_id = uv.id
  LEFT JOIN parameters p ON p.unique_id = pm.parameter_id
	WHERE facility = 'ANFOG'
	ORDER BY variable_name || ',' || cf_standard_name || ',' || imos_vocabulary_name || ',' || uv.name || ',' || uv.short_name || ',' || uv.definition),
  q AS (
    SELECT DISTINCT '# ' || qc_scheme_short_name || ',' || flag_value || ',' || flag_meaning || ',' || flag_description
  FROM parameters_mapping pm
  LEFT JOIN qc_scheme qs ON qs.qc_scheme_id = pm.qc_scheme_id
  LEFT JOIN qc_flags qf ON qf.qc_scheme_id = qs.qc_scheme_id
	WHERE facility = 'ANFOG'
	ORDER BY '# ' || qc_scheme_short_name || ',' || flag_value || ',' || flag_meaning || ',' || flag_description)
  SELECT '# data_column_name' || ',' || 'cf_standard_name' || ',' || 'imos_vocabulary_name' || ',' || 'unit_name' || ',' || 'unit_short_name' || ',' || 'uv.definition'
UNION ALL
  SELECT * FROM p WHERE "?column?" IS NOT NULL
UNION ALL
  SELECT '#'
UNION ALL
  SELECT '# qc_scheme_short_name' || ',' || 'flag_value' || ',' || 'flag_meaning' || ',' || 'flag_description'
UNION ALL
  SELECT * FROM q;

GRANT SELECT ON anfog_rt_metadata_summary TO harvest_read_group;

-- ANMN burst averaged
CREATE OR REPLACE VIEW anmn_burst_avg_metadata_summary AS
WITH p AS (
  SELECT '# ' || variable_name || ',' || cf_standard_name || ',' || imos_vocabulary_name || ',' || uv.name || ',' || uv.short_name || ',' || uv.definition
  FROM parameters_mapping pm
  LEFT JOIN unit_view uv ON pm.unit_id = uv.id
  LEFT JOIN parameters p ON p.unique_id = pm.parameter_id
	WHERE facility = 'ANMN' AND product = 'burst averaged'
	ORDER BY variable_name || ',' || cf_standard_name || ',' || imos_vocabulary_name || ',' || uv.name || ',' || uv.short_name || ',' || uv.definition),
  q AS (
    SELECT DISTINCT '# ' || qc_scheme_short_name || ',' || flag_value || ',' || flag_meaning || ',' || flag_description
  FROM parameters_mapping pm
  LEFT JOIN qc_scheme qs ON qs.qc_scheme_id = pm.qc_scheme_id
  LEFT JOIN qc_flags qf ON qf.qc_scheme_id = qs.qc_scheme_id
  	WHERE facility = 'ANMN' AND product = 'burst averaged'
	ORDER BY '# ' || qc_scheme_short_name || ',' || flag_value || ',' || flag_meaning || ',' || flag_description)
  SELECT '# data_column_name' || ',' || 'cf_standard_name' || ',' || 'imos_vocabulary_name' || ',' || 'unit_name' || ',' || 'unit_short_name' || ',' || 'uv.definition'
UNION ALL
  SELECT * FROM p WHERE "?column?" IS NOT NULL
UNION ALL
  SELECT '#'
UNION ALL
  SELECT '# qc_scheme_short_name' || ',' || 'flag_value' || ',' || 'flag_meaning' || ',' || 'flag_description'
UNION ALL
  SELECT * FROM q;

GRANT SELECT ON anmn_burst_avg_metadata_summary TO harvest_read_group;

-- ANMN MHL wave
CREATE OR REPLACE VIEW anmn_mhlwave_metadata_summary AS
WITH p AS (
  SELECT '# ' || variable_name || ',' || cf_standard_name || ',' || imos_vocabulary_name || ',' || uv.name || ',' || uv.short_name || ',' || uv.definition
  FROM parameters_mapping pm
  LEFT JOIN unit_view uv ON pm.unit_id = uv.id
  LEFT JOIN parameters p ON p.unique_id = pm.parameter_id
	WHERE facility = 'ANMN' AND product = 'MHL wave'
	ORDER BY variable_name || ',' || cf_standard_name || ',' || imos_vocabulary_name || ',' || uv.name || ',' || uv.short_name || ',' || uv.definition),
  q AS (
    SELECT DISTINCT '# ' || qc_scheme_short_name || ',' || flag_value || ',' || flag_meaning || ',' || flag_description
  FROM parameters_mapping pm
  LEFT JOIN qc_scheme qs ON qs.qc_scheme_id = pm.qc_scheme_id
  LEFT JOIN qc_flags qf ON qf.qc_scheme_id = qs.qc_scheme_id
	WHERE facility = 'ANMN' AND product = 'MHL wave'
	ORDER BY '# ' || qc_scheme_short_name || ',' || flag_value || ',' || flag_meaning || ',' || flag_description)
  SELECT '# data_column_name' || ',' || 'cf_standard_name' || ',' || 'imos_vocabulary_name' || ',' || 'unit_name' || ',' || 'unit_short_name' || ',' || 'uv.definition'
UNION ALL
  SELECT * FROM p WHERE "?column?" IS NOT NULL
UNION ALL
  SELECT '#'
UNION ALL
  SELECT '# qc_scheme_short_name' || ',' || 'flag_value' || ',' || 'flag_meaning' || ',' || 'flag_description'
UNION ALL
  SELECT * FROM q;

GRANT SELECT ON anmn_mhlwave_metadata_summary TO harvest_read_group;

-- ANMN temperature gridded
CREATE OR REPLACE VIEW anmn_t_regridded_metadata_summary AS
WITH p AS (
  SELECT '# ' || variable_name || ',' || cf_standard_name || ',' || imos_vocabulary_name || ',' || uv.name || ',' || uv.short_name || ',' || uv.definition
  FROM parameters_mapping pm
  LEFT JOIN unit_view uv ON pm.unit_id = uv.id
  LEFT JOIN parameters p ON p.unique_id = pm.parameter_id
	WHERE facility = 'ANMN' AND product = 'temperature gridded'
	ORDER BY variable_name || ',' || cf_standard_name || ',' || imos_vocabulary_name || ',' || uv.name || ',' || uv.short_name || ',' || uv.definition),
  q AS (
    SELECT DISTINCT '# ' || qc_scheme_short_name || ',' || flag_value || ',' || flag_meaning || ',' || flag_description
  FROM parameters_mapping pm
  LEFT JOIN qc_scheme qs ON qs.qc_scheme_id = pm.qc_scheme_id
  LEFT JOIN qc_flags qf ON qf.qc_scheme_id = qs.qc_scheme_id
	WHERE facility = 'ANMN' AND product = 'temperature gridded'
	ORDER BY '# ' || qc_scheme_short_name || ',' || flag_value || ',' || flag_meaning || ',' || flag_description)
  SELECT '# data_column_name' || ',' || 'cf_standard_name' || ',' || 'imos_vocabulary_name' || ',' || 'unit_name' || ',' || 'unit_short_name' || ',' || 'uv.definition'
UNION ALL
  SELECT * FROM p WHERE "?column?" IS NOT NULL
UNION ALL
  SELECT '#'
UNION ALL
  SELECT '# qc_scheme_short_name' || ',' || 'flag_value' || ',' || 'flag_meaning' || ',' || 'flag_description'
UNION ALL
  SELECT * FROM q;

GRANT SELECT ON anmn_t_regridded_metadata_summary TO harvest_read_group;

-- ANMN TS
CREATE OR REPLACE VIEW anmn_ts_metadata_summary AS
WITH p AS (
  SELECT '# ' || variable_name || ',' || cf_standard_name || ',' || imos_vocabulary_name || ',' || uv.name || ',' || uv.short_name || ',' || uv.definition
  FROM parameters_mapping pm
  LEFT JOIN unit_view uv ON pm.unit_id = uv.id
  LEFT JOIN parameters p ON p.unique_id = pm.parameter_id
	WHERE facility = 'ANMN' AND product = 'timeseries'
	ORDER BY variable_name || ',' || cf_standard_name || ',' || imos_vocabulary_name || ',' || uv.name || ',' || uv.short_name || ',' || uv.definition),
  q AS (
    SELECT DISTINCT '# ' || qc_scheme_short_name || ',' || flag_value || ',' || flag_meaning || ',' || flag_description
  FROM parameters_mapping pm
  LEFT JOIN qc_scheme qs ON qs.qc_scheme_id = pm.qc_scheme_id
  LEFT JOIN qc_flags qf ON qf.qc_scheme_id = qs.qc_scheme_id
	WHERE facility = 'ANMN' AND product = 'timeseries'
	ORDER BY '# ' || qc_scheme_short_name || ',' || flag_value || ',' || flag_meaning || ',' || flag_description)
  SELECT '# data_column_name' || ',' || 'cf_standard_name' || ',' || 'imos_vocabulary_name' || ',' || 'unit_name' || ',' || 'unit_short_name' || ',' || 'uv.definition'
UNION ALL
  SELECT * FROM p WHERE "?column?" IS NOT NULL
UNION ALL
  SELECT '#'
UNION ALL
  SELECT '# qc_scheme_short_name' || ',' || 'flag_value' || ',' || 'flag_meaning' || ',' || 'flag_description'
UNION ALL
  SELECT * FROM q;

GRANT SELECT ON anmn_ts_metadata_summary TO harvest_read_group;

-- ANMN AM delayed mode
CREATE OR REPLACE VIEW anmn_am_dm_metadata_summary AS
WITH p AS (
  SELECT '# ' || variable_name || ',' || cf_standard_name || ',' || imos_vocabulary_name || ',' || uv.name || ',' || uv.short_name || ',' || uv.definition
  FROM parameters_mapping pm
  LEFT JOIN unit_view uv ON pm.unit_id = uv.id
  LEFT JOIN parameters p ON p.unique_id = pm.parameter_id
	WHERE facility = 'ANMN' AND subfacility = 'AM' AND product = 'delayed mode'
	ORDER BY variable_name || ',' || cf_standard_name || ',' || imos_vocabulary_name || ',' || uv.name || ',' || uv.short_name || ',' || uv.definition),
  q AS (
    SELECT DISTINCT '# ' || qc_scheme_short_name || ',' || flag_value || ',' || flag_meaning || ',' || flag_description
  FROM parameters_mapping pm
  LEFT JOIN qc_scheme qs ON qs.qc_scheme_id = pm.qc_scheme_id
  LEFT JOIN qc_flags qf ON qf.qc_scheme_id = qs.qc_scheme_id
	WHERE facility = 'ANMN' AND subfacility = 'AM' AND product = 'delayed mode'
	ORDER BY '# ' || qc_scheme_short_name || ',' || flag_value || ',' || flag_meaning || ',' || flag_description)
  SELECT '# data_column_name' || ',' || 'cf_standard_name' || ',' || 'imos_vocabulary_name' || ',' || 'unit_name' || ',' || 'unit_short_name' || ',' || 'uv.definition'
UNION ALL
  SELECT * FROM p WHERE "?column?" IS NOT NULL
UNION ALL
  SELECT '#'
UNION ALL
  SELECT '# qc_scheme_short_name' || ',' || 'flag_value' || ',' || 'flag_meaning' || ',' || 'flag_description'
UNION ALL
  SELECT * FROM q;

GRANT SELECT ON anmn_am_dm_metadata_summary TO harvest_read_group;

-- ANMN AM real-time
CREATE OR REPLACE VIEW anmn_acidification_nrt_metadata_summary AS
WITH p AS (
  SELECT '# ' || variable_name || ',' || cf_standard_name || ',' || imos_vocabulary_name || ',' || uv.name || ',' || uv.short_name || ',' || uv.definition
  FROM parameters_mapping pm
  LEFT JOIN unit_view uv ON pm.unit_id = uv.id
  LEFT JOIN parameters p ON p.unique_id = pm.parameter_id
	WHERE facility = 'ANMN' AND subfacility = 'AM' AND product = 'real-time'
	ORDER BY variable_name || ',' || cf_standard_name || ',' || imos_vocabulary_name || ',' || uv.name || ',' || uv.short_name || ',' || uv.definition)
  SELECT '# data_column_name' || ',' || 'cf_standard_name' || ',' || 'imos_vocabulary_name' || ',' || 'unit_name' || ',' || 'unit_short_name' || ',' || 'uv.definition'
UNION ALL
  SELECT * FROM p WHERE "?column?" IS NOT NULL;

GRANT SELECT ON anmn_acidification_nrt_metadata_summary TO harvest_read_group;

-- ANMN NRS BGC
CREATE OR REPLACE VIEW anmn_nrs_bgc_metadata_summary AS
WITH p AS (
  SELECT '# ' || substring(product,'[^/BGC ]+') || ',' || variable_name || ',' || cf_standard_name || ',' || imos_vocabulary_name || ',' || uv.name || ',' || uv.short_name || ',' || uv.definition
  FROM parameters_mapping pm
  LEFT JOIN unit_view uv ON pm.unit_id = uv.id
  LEFT JOIN parameters p ON p.unique_id = pm.parameter_id
	WHERE facility = 'ANMN' AND subfacility = 'NRS' AND substring(product,'BGC') = 'BGC'
	ORDER BY product || ',' || variable_name || ',' || cf_standard_name || ',' || imos_vocabulary_name || ',' || uv.name || ',' || uv.short_name || ',' || uv.definition),
	  q AS (
    SELECT DISTINCT '# ' || qc_scheme_short_name || ',' || flag_value || ',' || flag_meaning || ',' || flag_description
  FROM parameters_mapping pm
  LEFT JOIN qc_scheme qs ON qs.qc_scheme_id = pm.qc_scheme_id
  LEFT JOIN qc_flags qf ON qf.qc_scheme_id = qs.qc_scheme_id
	WHERE facility = 'ANMN' AND subfacility = 'NRS' AND product LIKE 'BGC%'
	ORDER BY '# ' || qc_scheme_short_name || ',' || flag_value || ',' || flag_meaning || ',' || flag_description)
  SELECT '# data_product_name' || ',' || 'data_column_name' || ',' || 'cf_standard_name' || ',' || 'imos_vocabulary_name' || ',' || 'unit_name' || ',' || 'unit_short_name' || ',' || 'uv.definition'
UNION ALL
  SELECT * FROM p WHERE "?column?" IS NOT NULL
UNION ALL
  SELECT '#'
UNION ALL
  SELECT '# qc_scheme_short_name' || ',' || 'flag_value' || ',' || 'flag_meaning' || ',' || 'flag_description'
UNION ALL
  SELECT * FROM q;

GRANT SELECT ON anmn_nrs_bgc_metadata_summary TO harvest_read_group;


-- ANMN NRS CTD PROFILES
CREATE OR REPLACE VIEW anmn_nrs_ctd_profiles_metadata_summary AS
WITH p AS (
  SELECT '# ' || variable_name || ',' || cf_standard_name || ',' || imos_vocabulary_name || ',' || uv.name || ',' || uv.short_name || ',' || uv.definition
  FROM parameters_mapping pm
  LEFT JOIN unit_view uv ON pm.unit_id = uv.id
  LEFT JOIN parameters p ON p.unique_id = pm.parameter_id
	WHERE facility = 'ANMN' AND subfacility = 'NRS' AND product = 'CTD profiles'
	ORDER BY variable_name || ',' || cf_standard_name || ',' || imos_vocabulary_name || ',' || uv.name || ',' || uv.short_name || ',' || uv.definition),
  q AS (
    SELECT DISTINCT '# ' || qc_scheme_short_name || ',' || flag_value || ',' || flag_meaning || ',' || flag_description
  FROM parameters_mapping pm
  LEFT JOIN qc_scheme qs ON qs.qc_scheme_id = pm.qc_scheme_id
  LEFT JOIN qc_flags qf ON qf.qc_scheme_id = qs.qc_scheme_id
	WHERE facility = 'ANMN' AND subfacility = 'NRS' AND product = 'CTD profiles'
	ORDER BY '# ' || qc_scheme_short_name || ',' || flag_value || ',' || flag_meaning || ',' || flag_description)
  SELECT '# data_column_name' || ',' || 'cf_standard_name' || ',' || 'imos_vocabulary_name' || ',' || 'unit_name' || ',' || 'unit_short_name' || ',' || 'uv.definition'
UNION ALL
  SELECT * FROM p WHERE "?column?" IS NOT NULL
UNION ALL
  SELECT '#'
UNION ALL
  SELECT '# qc_scheme_short_name' || ',' || 'flag_value' || ',' || 'flag_meaning' || ',' || 'flag_description'
UNION ALL
  SELECT * FROM q;

GRANT SELECT ON anmn_nrs_ctd_profiles_metadata_summary TO harvest_read_group;

-- ANMN NRS RT bio
CREATE OR REPLACE VIEW anmn_nrs_rt_bio_metadata_summary AS
WITH p AS (
  SELECT '# ' || variable_name || ',' || cf_standard_name || ',' || imos_vocabulary_name || ',' || uv.name || ',' || uv.short_name || ',' || uv.definition
  FROM parameters_mapping pm
  LEFT JOIN unit_view uv ON pm.unit_id = uv.id
  LEFT JOIN parameters p ON p.unique_id = pm.parameter_id
	WHERE facility = 'ANMN' AND subfacility = 'NRS' AND product = 'realtime bio'
	ORDER BY variable_name || ',' || cf_standard_name || ',' || imos_vocabulary_name || ',' || uv.name || ',' || uv.short_name || ',' || uv.definition),
  q AS (
    SELECT DISTINCT '# ' || qc_scheme_short_name || ',' || flag_value || ',' || flag_meaning || ',' || flag_description
  FROM parameters_mapping pm
  LEFT JOIN qc_scheme qs ON qs.qc_scheme_id = pm.qc_scheme_id
  LEFT JOIN qc_flags qf ON qf.qc_scheme_id = qs.qc_scheme_id
	WHERE facility = 'ANMN' AND subfacility = 'NRS' AND product = 'realtime bio'
	ORDER BY '# ' || qc_scheme_short_name || ',' || flag_value || ',' || flag_meaning || ',' || flag_description)
  SELECT '# data_column_name' || ',' || 'cf_standard_name' || ',' || 'imos_vocabulary_name' || ',' || 'unit_name' || ',' || 'unit_short_name' || ',' || 'uv.definition'
UNION ALL
  SELECT * FROM p WHERE "?column?" IS NOT NULL
UNION ALL
  SELECT '#'
UNION ALL
  SELECT '# qc_scheme_short_name' || ',' || 'flag_value' || ',' || 'flag_meaning' || ',' || 'flag_description'
UNION ALL
  SELECT * FROM q;

GRANT SELECT ON anmn_nrs_rt_bio_metadata_summary TO harvest_read_group;

-- ANMN NRS dar_yon
CREATE OR REPLACE VIEW anmn_nrs_dar_yon_metadata_summary AS
WITH p AS (
  SELECT '# ' || variable_name || ',' || cf_standard_name || ',' || imos_vocabulary_name || ',' || uv.name || ',' || uv.short_name || ',' || uv.definition
  FROM parameters_mapping pm
  LEFT JOIN unit_view uv ON pm.unit_id = uv.id
  LEFT JOIN parameters p ON p.unique_id = pm.parameter_id
	WHERE facility = 'ANMN' AND subfacility = 'NRS' AND product = 'realtime darwin yongala'
	ORDER BY variable_name || ',' || cf_standard_name || ',' || imos_vocabulary_name || ',' || uv.name || ',' || uv.short_name || ',' || uv.definition),
  q AS (
    SELECT DISTINCT '# ' || qc_scheme_short_name || ',' || flag_value || ',' || flag_meaning || ',' || flag_description
  FROM parameters_mapping pm
  LEFT JOIN qc_scheme qs ON qs.qc_scheme_id = pm.qc_scheme_id
  LEFT JOIN qc_flags qf ON qf.qc_scheme_id = qs.qc_scheme_id
	WHERE facility = 'ANMN' AND subfacility = 'NRS' AND product = 'realtime darwin yongala'
	ORDER BY '# ' || qc_scheme_short_name || ',' || flag_value || ',' || flag_meaning || ',' || flag_description)
  SELECT '# data_column_name' || ',' || 'cf_standard_name' || ',' || 'imos_vocabulary_name' || ',' || 'unit_name' || ',' || 'unit_short_name' || ',' || 'uv.definition'
UNION ALL
  SELECT * FROM p WHERE "?column?" IS NOT NULL
UNION ALL
  SELECT '#'
UNION ALL
  SELECT '# qc_scheme_short_name' || ',' || 'flag_value' || ',' || 'flag_meaning' || ',' || 'flag_description'
UNION ALL
  SELECT * FROM q;

GRANT SELECT ON anmn_nrs_dar_yon_metadata_summary TO harvest_read_group;

-- ANMN NRS realtime meteo
CREATE OR REPLACE VIEW anmn_nrs_rt_meteo_metadata_summary AS
WITH p AS (
  SELECT '# ' || variable_name || ',' || cf_standard_name || ',' || imos_vocabulary_name || ',' || uv.name || ',' || uv.short_name || ',' || uv.definition
  FROM parameters_mapping pm
  LEFT JOIN unit_view uv ON pm.unit_id = uv.id
  LEFT JOIN parameters p ON p.unique_id = pm.parameter_id
	WHERE facility = 'ANMN' AND subfacility = 'NRS' AND product = 'realtime meteo'
	ORDER BY variable_name || ',' || cf_standard_name || ',' || imos_vocabulary_name || ',' || uv.name || ',' || uv.short_name || ',' || uv.definition),
  q AS (
    SELECT DISTINCT '# ' || qc_scheme_short_name || ',' || flag_value || ',' || flag_meaning || ',' || flag_description
  FROM parameters_mapping pm
  LEFT JOIN qc_scheme qs ON qs.qc_scheme_id = pm.qc_scheme_id
  LEFT JOIN qc_flags qf ON qf.qc_scheme_id = qs.qc_scheme_id
	WHERE facility = 'ANMN' AND subfacility = 'NRS' AND product = 'realtime meteo'
	ORDER BY '# ' || qc_scheme_short_name || ',' || flag_value || ',' || flag_meaning || ',' || flag_description)
  SELECT '# data_column_name' || ',' || 'cf_standard_name' || ',' || 'imos_vocabulary_name' || ',' || 'unit_name' || ',' || 'unit_short_name' || ',' || 'uv.definition'
UNION ALL
  SELECT * FROM p WHERE "?column?" IS NOT NULL
UNION ALL
  SELECT '#'
UNION ALL
  SELECT '# qc_scheme_short_name' || ',' || 'flag_value' || ',' || 'flag_meaning' || ',' || 'flag_description'
UNION ALL
  SELECT * FROM q;

GRANT SELECT ON anmn_nrs_rt_meteo_metadata_summary TO harvest_read_group;

-- ANMN NRS realtime wave
CREATE OR REPLACE VIEW anmn_nrs_rt_wave_metadata_summary AS
WITH p AS (
  SELECT '# ' || variable_name || ',' || cf_standard_name || ',' || imos_vocabulary_name || ',' || uv.name || ',' || uv.short_name || ',' || uv.definition
  FROM parameters_mapping pm
  LEFT JOIN unit_view uv ON pm.unit_id = uv.id
  LEFT JOIN parameters p ON p.unique_id = pm.parameter_id
	WHERE facility = 'ANMN' AND subfacility = 'NRS' AND product = 'realtime wave'
	ORDER BY variable_name || ',' || cf_standard_name || ',' || imos_vocabulary_name || ',' || uv.name || ',' || uv.short_name || ',' || uv.definition),
  q AS (
    SELECT DISTINCT '# ' || qc_scheme_short_name || ',' || flag_value || ',' || flag_meaning || ',' || flag_description
  FROM parameters_mapping pm
  LEFT JOIN qc_scheme qs ON qs.qc_scheme_id = pm.qc_scheme_id
  LEFT JOIN qc_flags qf ON qf.qc_scheme_id = qs.qc_scheme_id
	WHERE facility = 'ANMN' AND subfacility = 'NRS' AND product = 'realtime wave'
	ORDER BY '# ' || qc_scheme_short_name || ',' || flag_value || ',' || flag_meaning || ',' || flag_description)
  SELECT '# data_column_name' || ',' || 'cf_standard_name' || ',' || 'imos_vocabulary_name' || ',' || 'unit_name' || ',' || 'unit_short_name' || ',' || 'uv.definition'
UNION ALL
  SELECT * FROM p WHERE "?column?" IS NOT NULL
UNION ALL
  SELECT '#'
UNION ALL
  SELECT '# qc_scheme_short_name' || ',' || 'flag_value' || ',' || 'flag_meaning' || ',' || 'flag_description'
UNION ALL
  SELECT * FROM q;

GRANT SELECT ON anmn_nrs_rt_wave_metadata_summary TO harvest_read_group;

-- Argo
CREATE OR REPLACE VIEW argo_metadata_summary AS
WITH p AS (
  SELECT '# ' || variable_name || ',' || cf_standard_name || ',' || imos_vocabulary_name || ',' || uv.name || ',' || uv.short_name || ',' || uv.definition
  FROM parameters_mapping pm
  LEFT JOIN unit_view uv ON pm.unit_id = uv.id
  LEFT JOIN parameters p ON p.unique_id = pm.parameter_id
	WHERE facility = 'Argo'
	ORDER BY variable_name || ',' || cf_standard_name || ',' || imos_vocabulary_name || ',' || uv.name || ',' || uv.short_name || ',' || uv.definition),
  q AS (
    SELECT DISTINCT '# ' || qc_scheme_short_name || ',' || flag_value || ',' || flag_meaning || ',' || flag_description
  FROM parameters_mapping pm
  LEFT JOIN qc_scheme qs ON qs.qc_scheme_id = pm.qc_scheme_id
  LEFT JOIN qc_flags qf ON qf.qc_scheme_id = qs.qc_scheme_id
	WHERE facility = 'Argo'
	ORDER BY '# ' || qc_scheme_short_name || ',' || flag_value || ',' || flag_meaning || ',' || flag_description)
  SELECT '# data_column_name' || ',' || 'cf_standard_name' || ',' || 'imos_vocabulary_name' || ',' || 'unit_name' || ',' || 'unit_short_name' || ',' || 'uv.definition'
UNION ALL
  SELECT * FROM p WHERE "?column?" IS NOT NULL
UNION ALL
  SELECT '#'
UNION ALL
  SELECT '# qc_scheme_short_name' || ',' || 'flag_value' || ',' || 'flag_meaning' || ',' || 'flag_description'
UNION ALL
  SELECT * FROM q;

GRANT SELECT ON argo_metadata_summary TO harvest_read_group;

-- AUV
CREATE OR REPLACE VIEW auv_metadata_summary AS
WITH p AS (
  SELECT '# ' || variable_name || ',' || cf_standard_name || ',' || imos_vocabulary_name || ',' || uv.name || ',' || uv.short_name || ',' || uv.definition
  FROM parameters_mapping pm
  LEFT JOIN unit_view uv ON pm.unit_id = uv.id
  LEFT JOIN parameters p ON p.unique_id = pm.parameter_id
	WHERE facility = 'AUV'
	ORDER BY variable_name || ',' || cf_standard_name || ',' || imos_vocabulary_name || ',' || uv.name || ',' || uv.short_name || ',' || uv.definition),
  q AS (
    SELECT DISTINCT '# ' || qc_scheme_short_name || ',' || flag_value || ',' || flag_meaning || ',' || flag_description
  FROM parameters_mapping pm
  LEFT JOIN qc_scheme qs ON qs.qc_scheme_id = pm.qc_scheme_id
  LEFT JOIN qc_flags qf ON qf.qc_scheme_id = qs.qc_scheme_id
	WHERE facility = 'AUV'
	ORDER BY '# ' || qc_scheme_short_name || ',' || flag_value || ',' || flag_meaning || ',' || flag_description)
  SELECT '# data_column_name' || ',' || 'cf_standard_name' || ',' || 'imos_vocabulary_name' || ',' || 'unit_name' || ',' || 'unit_short_name' || ',' || 'uv.definition'
UNION ALL
  SELECT * FROM p WHERE "?column?" IS NOT NULL
UNION ALL
  SELECT '#'
UNION ALL
  SELECT '# qc_scheme_short_name' || ',' || 'flag_value' || ',' || 'flag_meaning' || ',' || 'flag_description'
UNION ALL
  SELECT * FROM q;
  
GRANT SELECT ON auv_metadata_summary TO harvest_read_group;


-- NOAA Drifters
CREATE OR REPLACE VIEW noaa_drifters_metadata_summary AS
WITH p AS (
  SELECT '# ' || variable_name || ',' || cf_standard_name || ',' || imos_vocabulary_name || ',' || uv.name || ',' || uv.short_name || ',' || uv.definition
  FROM parameters_mapping pm
  LEFT JOIN unit_view uv ON pm.unit_id = uv.id
  LEFT JOIN parameters p ON p.unique_id = pm.parameter_id
	WHERE facility = 'NOAA' AND product = 'drifters'
	ORDER BY variable_name || ',' || cf_standard_name || ',' || imos_vocabulary_name || ',' || uv.name || ',' || uv.short_name || ',' || uv.definition),
  q AS (
    SELECT DISTINCT '# ' || qc_scheme_short_name || ',' || flag_value || ',' || flag_meaning || ',' || flag_description
  FROM parameters_mapping pm
  LEFT JOIN qc_scheme qs ON qs.qc_scheme_id = pm.qc_scheme_id
  LEFT JOIN qc_flags qf ON qf.qc_scheme_id = qs.qc_scheme_id
	WHERE facility = 'NOAA' AND product = 'drifters'
	ORDER BY '# ' || qc_scheme_short_name || ',' || flag_value || ',' || flag_meaning || ',' || flag_description)
  SELECT '# data_column_name' || ',' || 'cf_standard_name' || ',' || 'imos_vocabulary_name' || ',' || 'unit_name' || ',' || 'unit_short_name' || ',' || 'uv.definition'
UNION ALL
  SELECT * FROM p WHERE "?column?" IS NOT NULL
UNION ALL
  SELECT '#'
UNION ALL
  SELECT '# qc_scheme_short_name' || ',' || 'flag_value' || ',' || 'flag_meaning' || ',' || 'flag_description'
UNION ALL
  SELECT * FROM q;

GRANT SELECT ON noaa_drifters_metadata_summary TO harvest_read_group;

-- SOOP ASF MFT
CREATE OR REPLACE VIEW soop_asf_mft_metadata_summary AS
WITH p AS (
  SELECT '# ' || variable_name || ',' || cf_standard_name || ',' || imos_vocabulary_name || ',' || uv.name || ',' || uv.short_name || ',' || uv.definition
  FROM parameters_mapping pm
  LEFT JOIN unit_view uv ON pm.unit_id = uv.id
  LEFT JOIN parameters p ON p.unique_id = pm.parameter_id
	WHERE facility = 'SOOP' AND subfacility = 'ASF' AND product = 'MFT'
	ORDER BY variable_name || ',' || cf_standard_name || ',' || imos_vocabulary_name || ',' || uv.name || ',' || uv.short_name || ',' || uv.definition),
  q AS (
    SELECT DISTINCT '# ' || qc_scheme_short_name || ',' || flag_value || ',' || flag_meaning || ',' || flag_description
  FROM parameters_mapping pm
  LEFT JOIN qc_scheme qs ON qs.qc_scheme_id = pm.qc_scheme_id
  LEFT JOIN qc_flags qf ON qf.qc_scheme_id = qs.qc_scheme_id
	WHERE facility = 'SOOP' AND subfacility = 'ASF' AND product = 'MFT'
	ORDER BY '# ' || qc_scheme_short_name || ',' || flag_value || ',' || flag_meaning || ',' || flag_description)
  SELECT '# data_column_name' || ',' || 'cf_standard_name' || ',' || 'imos_vocabulary_name' || ',' || 'unit_name' || ',' || 'unit_short_name' || ',' || 'uv.definition'
UNION ALL
  SELECT * FROM p WHERE "?column?" IS NOT NULL
UNION ALL
  SELECT '#'
UNION ALL
  SELECT '# qc_scheme_short_name' || ',' || 'flag_value' || ',' || 'flag_meaning' || ',' || 'flag_description'
UNION ALL
  SELECT * FROM q;

GRANT SELECT ON soop_asf_mft_metadata_summary TO harvest_read_group;

-- SOOP ASF MT
CREATE OR REPLACE VIEW soop_asf_mt_metadata_summary AS
WITH p AS (
  SELECT '# ' || variable_name || ',' || cf_standard_name || ',' || imos_vocabulary_name || ',' || uv.name || ',' || uv.short_name || ',' || uv.definition
  FROM parameters_mapping pm
  LEFT JOIN unit_view uv ON pm.unit_id = uv.id
  LEFT JOIN parameters p ON p.unique_id = pm.parameter_id
	WHERE facility = 'SOOP' AND subfacility = 'ASF' AND product = 'MT'
	ORDER BY variable_name || ',' || cf_standard_name || ',' || imos_vocabulary_name || ',' || uv.name || ',' || uv.short_name || ',' || uv.definition),
  q AS (
    SELECT DISTINCT '# ' || qc_scheme_short_name || ',' || flag_value || ',' || flag_meaning || ',' || flag_description
  FROM parameters_mapping pm
  LEFT JOIN qc_scheme qs ON qs.qc_scheme_id = pm.qc_scheme_id
  LEFT JOIN qc_flags qf ON qf.qc_scheme_id = qs.qc_scheme_id
	WHERE facility = 'SOOP' AND subfacility = 'ASF' AND product = 'MT'
	ORDER BY '# ' || qc_scheme_short_name || ',' || flag_value || ',' || flag_meaning || ',' || flag_description)
  SELECT '# data_column_name' || ',' || 'cf_standard_name' || ',' || 'imos_vocabulary_name' || ',' || 'unit_name' || ',' || 'unit_short_name' || ',' || 'uv.definition'
UNION ALL
  SELECT * FROM p WHERE "?column?" IS NOT NULL
UNION ALL
  SELECT '#'
UNION ALL
  SELECT '# qc_scheme_short_name' || ',' || 'flag_value' || ',' || 'flag_meaning' || ',' || 'flag_description'
UNION ALL
  SELECT * FROM q;

GRANT SELECT ON soop_asf_mt_metadata_summary TO harvest_read_group;


-- SOOP CO2
CREATE OR REPLACE VIEW soop_co2_metadata_summary AS
WITH p AS (
  SELECT '# ' || variable_name || ',' || cf_standard_name || ',' || imos_vocabulary_name || ',' || uv.name || ',' || uv.short_name || ',' || uv.definition
  FROM parameters_mapping pm
  LEFT JOIN unit_view uv ON pm.unit_id = uv.id
  LEFT JOIN parameters p ON p.unique_id = pm.parameter_id
	WHERE facility = 'SOOP' AND subfacility = 'CO2'
	ORDER BY variable_name || ',' || cf_standard_name || ',' || imos_vocabulary_name || ',' || uv.name || ',' || uv.short_name || ',' || uv.definition),
  q AS (
    SELECT DISTINCT '# ' || qc_scheme_short_name || ',' || flag_value || ',' || flag_meaning || ',' || flag_description
  FROM parameters_mapping pm
  LEFT JOIN qc_scheme qs ON qs.qc_scheme_id = pm.qc_scheme_id
  LEFT JOIN qc_flags qf ON qf.qc_scheme_id = qs.qc_scheme_id
	WHERE facility = 'SOOP' AND subfacility = 'CO2'
	ORDER BY '# ' || qc_scheme_short_name || ',' || flag_value || ',' || flag_meaning || ',' || flag_description)
  SELECT '# data_column_name' || ',' || 'cf_standard_name' || ',' || 'imos_vocabulary_name' || ',' || 'unit_name' || ',' || 'unit_short_name' || ',' || 'uv.definition'
UNION ALL
  SELECT * FROM p WHERE "?column?" IS NOT NULL
UNION ALL
  SELECT '#'
UNION ALL
  SELECT '# qc_scheme_short_name' || ',' || 'flag_value' || ',' || 'flag_meaning' || ',' || 'flag_description'
UNION ALL
  SELECT * FROM q;

GRANT SELECT ON soop_co2_metadata_summary TO harvest_read_group;

  
-- SOOP SST
CREATE OR REPLACE VIEW soop_sst_metadata_summary AS
WITH p AS (
  SELECT '# ' || variable_name || ',' || cf_standard_name || ',' || imos_vocabulary_name || ',' || uv.name || ',' || uv.short_name || ',' || uv.definition
  FROM parameters_mapping pm
  LEFT JOIN unit_view uv ON pm.unit_id = uv.id
  LEFT JOIN parameters p ON p.unique_id = pm.parameter_id
	WHERE facility = 'SOOP' AND subfacility = 'SST'
	ORDER BY variable_name || ',' || cf_standard_name || ',' || imos_vocabulary_name || ',' || uv.name || ',' || uv.short_name || ',' || uv.definition),
  q AS (
    SELECT DISTINCT '# ' || qc_scheme_short_name || ',' || flag_value || ',' || flag_meaning || ',' || flag_description
  FROM parameters_mapping pm
  LEFT JOIN qc_scheme qs ON qs.qc_scheme_id = pm.qc_scheme_id
  LEFT JOIN qc_flags qf ON qf.qc_scheme_id = qs.qc_scheme_id
	WHERE facility = 'SOOP' AND subfacility = 'SST'
	ORDER BY '# ' || qc_scheme_short_name || ',' || flag_value || ',' || flag_meaning || ',' || flag_description)
  SELECT '# data_column_name' || ',' || 'cf_standard_name' || ',' || 'imos_vocabulary_name' || ',' || 'unit_name' || ',' || 'unit_short_name' || ',' || 'uv.definition'
UNION ALL
  SELECT * FROM p WHERE "?column?" IS NOT NULL
UNION ALL
  SELECT '#'
UNION ALL
  SELECT '# qc_scheme_short_name' || ',' || 'flag_value' || ',' || 'flag_meaning' || ',' || 'flag_description'
UNION ALL
  SELECT * FROM q;
  
GRANT SELECT ON soop_sst_metadata_summary TO harvest_read_group;


-- SOOP TMV
CREATE OR REPLACE VIEW soop_tmv_metadata_summary AS
WITH p AS (
  SELECT '# ' || variable_name || ',' || cf_standard_name || ',' || imos_vocabulary_name || ',' || uv.name || ',' || uv.short_name || ',' || uv.definition
  FROM parameters_mapping pm
  LEFT JOIN unit_view uv ON pm.unit_id = uv.id
  LEFT JOIN parameters p ON p.unique_id = pm.parameter_id
	WHERE facility = 'SOOP' AND subfacility = 'TMV' AND product != 'NRT'
	ORDER BY variable_name || ',' || cf_standard_name || ',' || imos_vocabulary_name || ',' || uv.name || ',' || uv.short_name || ',' || uv.definition),
  q AS (
    SELECT DISTINCT '# ' || qc_scheme_short_name || ',' || flag_value || ',' || flag_meaning || ',' || flag_description
  FROM parameters_mapping pm
  LEFT JOIN qc_scheme qs ON qs.qc_scheme_id = pm.qc_scheme_id
  LEFT JOIN qc_flags qf ON qf.qc_scheme_id = qs.qc_scheme_id
	WHERE facility = 'SOOP' AND subfacility = 'TMV' AND product != 'NRT'
	ORDER BY '# ' || qc_scheme_short_name || ',' || flag_value || ',' || flag_meaning || ',' || flag_description)
  SELECT '# data_column_name' || ',' || 'cf_standard_name' || ',' || 'imos_vocabulary_name' || ',' || 'unit_name' || ',' || 'unit_short_name' || ',' || 'uv.definition'
UNION ALL
  SELECT * FROM p WHERE "?column?" IS NOT NULL
UNION ALL
  SELECT '#'
UNION ALL
  SELECT '# qc_scheme_short_name' || ',' || 'flag_value' || ',' || 'flag_meaning' || ',' || 'flag_description'
UNION ALL
  SELECT * FROM q;

GRANT SELECT ON soop_tmv_metadata_summary TO harvest_read_group;


-- SOOP TMV NRT
CREATE OR REPLACE VIEW soop_tmv_nrt_metadata_summary AS
WITH p AS (
  SELECT '# ' || variable_name || ',' || cf_standard_name || ',' || imos_vocabulary_name || ',' || uv.name || ',' || uv.short_name || ',' || uv.definition
  FROM parameters_mapping pm
  LEFT JOIN unit_view uv ON pm.unit_id = uv.id
  LEFT JOIN parameters p ON p.unique_id = pm.parameter_id
	WHERE facility = 'SOOP' AND subfacility = 'TMV' AND product = 'NRT'
	ORDER BY variable_name || ',' || cf_standard_name || ',' || imos_vocabulary_name || ',' || uv.name || ',' || uv.short_name || ',' || uv.definition)
  SELECT '# data_column_name' || ',' || 'cf_standard_name' || ',' || 'imos_vocabulary_name' || ',' || 'unit_name' || ',' || 'unit_short_name' || ',' || 'uv.definition'
UNION ALL
  SELECT * FROM p WHERE "?column?" IS NOT NULL;

GRANT SELECT ON soop_tmv_nrt_metadata_summary TO harvest_read_group;


-- SOOP TRV
CREATE OR REPLACE VIEW soop_trv_metadata_summary AS
WITH p AS (
  SELECT '# ' || variable_name || ',' || cf_standard_name || ',' || imos_vocabulary_name || ',' || uv.name || ',' || uv.short_name || ',' || uv.definition
  FROM parameters_mapping pm
  LEFT JOIN unit_view uv ON pm.unit_id = uv.id
  LEFT JOIN parameters p ON p.unique_id = pm.parameter_id
	WHERE facility = 'SOOP' AND subfacility = 'TRV'
	ORDER BY variable_name || ',' || cf_standard_name || ',' || imos_vocabulary_name || ',' || uv.name || ',' || uv.short_name || ',' || uv.definition),
  q AS (
    SELECT DISTINCT '# ' || qc_scheme_short_name || ',' || flag_value || ',' || flag_meaning || ',' || flag_description
  FROM parameters_mapping pm
  LEFT JOIN qc_scheme qs ON qs.qc_scheme_id = pm.qc_scheme_id
  LEFT JOIN qc_flags qf ON qf.qc_scheme_id = qs.qc_scheme_id
	WHERE facility = 'SOOP' AND subfacility = 'TRV'
	ORDER BY '# ' || qc_scheme_short_name || ',' || flag_value || ',' || flag_meaning || ',' || flag_description)
  SELECT '# data_column_name' || ',' || 'cf_standard_name' || ',' || 'imos_vocabulary_name' || ',' || 'unit_name' || ',' || 'unit_short_name' || ',' || 'uv.definition'
UNION ALL
  SELECT * FROM p WHERE "?column?" IS NOT NULL
UNION ALL
  SELECT '#'
UNION ALL
  SELECT '# qc_scheme_short_name' || ',' || 'flag_value' || ',' || 'flag_meaning' || ',' || 'flag_description'
UNION ALL
  SELECT * FROM q;
  
GRANT SELECT ON soop_trv_metadata_summary TO harvest_read_group;

  
-- SOOP XBT DM
CREATE OR REPLACE VIEW soop_xbt_dm_metadata_summary AS
WITH p AS (
  SELECT '# ' || variable_name || ',' || cf_standard_name || ',' || imos_vocabulary_name || ',' || uv.name || ',' || uv.short_name || ',' || uv.definition
  FROM parameters_mapping pm
  LEFT JOIN unit_view uv ON pm.unit_id = uv.id
  LEFT JOIN parameters p ON p.unique_id = pm.parameter_id
	WHERE facility = 'SOOP' AND subfacility = 'XBT'
	ORDER BY variable_name || ',' || cf_standard_name || ',' || imos_vocabulary_name || ',' || uv.name || ',' || uv.short_name || ',' || uv.definition),
  q AS (
    SELECT DISTINCT '# ' || qc_scheme_short_name || ',' || flag_value || ',' || flag_meaning || ',' || flag_description
  FROM parameters_mapping pm
  LEFT JOIN qc_scheme qs ON qs.qc_scheme_id = pm.qc_scheme_id
  LEFT JOIN qc_flags qf ON qf.qc_scheme_id = qs.qc_scheme_id
	WHERE facility = 'SOOP' AND subfacility = 'XBT'
	ORDER BY '# ' || qc_scheme_short_name || ',' || flag_value || ',' || flag_meaning || ',' || flag_description)
  SELECT '# data_column_name' || ',' || 'cf_standard_name' || ',' || 'imos_vocabulary_name' || ',' || 'unit_name' || ',' || 'unit_short_name' || ',' || 'uv.definition'
UNION ALL
  SELECT * FROM p WHERE "?column?" IS NOT NULL
UNION ALL
  SELECT '#'
UNION ALL
  SELECT '# qc_scheme_short_name' || ',' || 'flag_value' || ',' || 'flag_meaning' || ',' || 'flag_description'
UNION ALL
  SELECT * FROM q;

GRANT SELECT ON soop_xbt_dm_metadata_summary TO harvest_read_group;


-- SOOP XBT NRT
CREATE OR REPLACE VIEW soop_xbt_nrt_metadata_summary AS
WITH p AS (
  SELECT '# ' || variable_name || ',' || cf_standard_name || ',' || imos_vocabulary_name || ',' || uv.name || ',' || uv.short_name || ',' || uv.definition
  FROM parameters_mapping pm
  LEFT JOIN unit_view uv ON pm.unit_id = uv.id
  LEFT JOIN parameters p ON p.unique_id = pm.parameter_id
	WHERE facility = 'SOOP' AND subfacility = 'XBT'
	ORDER BY variable_name || ',' || cf_standard_name || ',' || imos_vocabulary_name || ',' || uv.name || ',' || uv.short_name || ',' || uv.definition)
  SELECT '# data_column_name' || ',' || 'cf_standard_name' || ',' || 'imos_vocabulary_name' || ',' || 'unit_name' || ',' || 'unit_short_name' || ',' || 'uv.definition'
UNION ALL
  SELECT * FROM p WHERE "?column?" IS NOT NULL;
  
GRANT SELECT ON soop_xbt_nrt_metadata_summary TO harvest_read_group;

-- SRS altimetry
CREATE OR REPLACE VIEW srs_altimetry_metadata_summary AS
WITH p AS (
  SELECT '# ' || variable_name || ',' || cf_standard_name || ',' || imos_vocabulary_name || ',' || uv.name || ',' || uv.short_name || ',' || uv.definition
  FROM parameters_mapping pm
  LEFT JOIN unit_view uv ON pm.unit_id = uv.id
  LEFT JOIN parameters p ON p.unique_id = pm.parameter_id
	WHERE facility = 'SRS' AND product = 'altimetry'
	ORDER BY variable_name || ',' || cf_standard_name || ',' || imos_vocabulary_name || ',' || uv.name || ',' || uv.short_name || ',' || uv.definition),
  q AS (
    SELECT DISTINCT '# ' || qc_scheme_short_name || ',' || flag_value || ',' || flag_meaning || ',' || flag_description
  FROM parameters_mapping pm
  LEFT JOIN qc_scheme qs ON qs.qc_scheme_id = pm.qc_scheme_id
  LEFT JOIN qc_flags qf ON qf.qc_scheme_id = qs.qc_scheme_id
	WHERE facility = 'SRS' AND product = 'altimetry'
	ORDER BY '# ' || qc_scheme_short_name || ',' || flag_value || ',' || flag_meaning || ',' || flag_description)
  SELECT '# data_column_name' || ',' || 'cf_standard_name' || ',' || 'imos_vocabulary_name' || ',' || 'unit_name' || ',' || 'unit_short_name' || ',' || 'uv.definition'
UNION ALL
  SELECT * FROM p WHERE "?column?" IS NOT NULL
UNION ALL
  SELECT '#'
UNION ALL
  SELECT '# qc_scheme_short_name' || ',' || 'flag_value' || ',' || 'flag_meaning' || ',' || 'flag_description'
UNION ALL
  SELECT * FROM q;

GRANT SELECT ON srs_altimetry_metadata_summary TO harvest_read_group;
