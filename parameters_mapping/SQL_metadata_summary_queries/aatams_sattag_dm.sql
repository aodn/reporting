SET SEARCH_PATH = parameters_mapping, contr_vocab_db, public; 
DROP VIEW IF EXISTS aatams_sattag_dm_metadata_summary;

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

GRANT SELECT ON aatams_sattag_dm_metadata_summary TO harvest_read_group, public;