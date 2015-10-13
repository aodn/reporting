SET SEARCH_PATH = parameters_mapping, contr_vocab_db, public; 
DROP VIEW IF EXISTS aatams_biologging_penguin_metadata_summary;

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

GRANT SELECT ON aatams_biologging_penguin_metadata_summary TO harvest_read_group, public;