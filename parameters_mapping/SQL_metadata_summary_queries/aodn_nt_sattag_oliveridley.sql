SET SEARCH_PATH = parameters_mapping, contr_vocab_db, public; 
DROP VIEW IF EXISTS aodn_nt_sattag_oliveridley_metadata_summary;

-- AODN NT SATTAG OLIVE RIDLEY
CREATE OR REPLACE VIEW aodn_nt_sattag_oliveridley_metadata_summary AS
WITH p AS (
  SELECT '# ' || variable_name || ',' || cf_standard_name || ',' || imos_vocabulary_name || ',' || uv.name || ',' || uv.short_name || ',' || uv.definition
  FROM parameters_mapping pm
  LEFT JOIN unit_view uv ON pm.unit_id = uv.id
  LEFT JOIN parameters p ON p.unique_id = pm.parameter_id
	WHERE facility = 'AATAMS' AND subfacility = 'sattag' AND product = 'dm'
	ORDER BY variable_name || ',' || cf_standard_name || ',' || imos_vocabulary_name || ',' || uv.name || ',' || uv.short_name || ',' || uv.definition),
 a AS (SELECT DISTINCT device_id FROM aodn_nt_sattag_oliveridley.aodn_nt_sattag_oliveridley_profile_map ORDER BY device_id),
 b AS (SELECT '# ' || a.device_id || ',' || m.tag_type || ',' || m.common_name || ',' || m.release_site || ',' || COALESCE(m.release_lon::text,'') || ',' || COALESCE(m.release_lat::text,'') || ',' || m.state_country  || ',' || 
	COALESCE(date(m.release_date)::text,'') || ',' || m.age_class || ',' || m.sex || ',' || COALESCE(m.curved_carapace_length_cm::text,'') || ',' || 
	COALESCE(m.curved_carapace_width_cm::text,'') || ',' || COALESCE(m.mass_kg::text,'') || ',' || m.sample || ',' || m.comment || ',' || m.pi || ',' || m.institution
  FROM a
  LEFT JOIN aodn_nt_sattag_oliveridley.aodn_nt_sattag_oliveridley_metadata m ON a.device_id = m.device_id
  	ORDER BY a.device_id)
  SELECT '# data_column_name' || ',' || 'cf_standard_name' || ',' || 'imos_vocabulary_name' || ',' || 'unit_name' || ',' || 'unit_short_name' || ',' || 'uv.definition'
UNION ALL
  SELECT * FROM p WHERE "?column?" IS NOT NULL
UNION ALL
  SELECT '#'
UNION ALL
  SELECT '# device_id' || ',' || 'device_wmo_ref' || ',' || 'tag_type' || ',' || 'common_name' || ',' || 'release_site' || ',' || 'release_lon' || ',' ||
	'release_lat' || ',' || 'state_country' || ',' || 'release_date' || ',' || 'age_class' || ',' || 'sex' || ',' ||
	'curved_carapace_length_cm' || ',' || 'curved_carapace_width_cm' || ',' || 'mass_kg' || ',' || 'sample' || ',' || 'comment' || ',' || 'principal investigator' || ',' || 'institution'
UNION ALL
  SELECT * FROM b;

GRANT SELECT ON aodn_nt_sattag_oliveridley_metadata_summary TO harvest_read_group, public;