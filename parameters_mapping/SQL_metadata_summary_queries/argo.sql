SET SEARCH_PATH = parameters_mapping, contr_vocab_db, public; 
DROP VIEW IF EXISTS argo_metadata_summary;

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

GRANT SELECT ON argo_metadata_summary TO harvest_read_group, public;