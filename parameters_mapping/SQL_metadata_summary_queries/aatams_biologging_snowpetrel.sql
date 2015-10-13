SET SEARCH_PATH = parameters_mapping, contr_vocab_db, public; 
DROP VIEW IF EXISTS aatams_biologging_snowpetrel_metadata_summary;

-- AATAMS Biologging snowpetrel
CREATE OR REPLACE VIEW aatams_biologging_snowpetrel_metadata_summary AS
WITH p AS (
  SELECT '# ' || variable_name || ',' || cf_standard_name || ',' || imos_vocabulary_name || ',' || uv.name || ',' || uv.short_name || ',' || uv.definition
  FROM parameters_mapping pm
  LEFT JOIN unit_view uv ON pm.unit_id = uv.id
  LEFT JOIN parameters p ON p.unique_id = pm.parameter_id
	WHERE facility = 'AATAMS' AND subfacility = 'biologging' AND product = 'shearwater'
	ORDER BY variable_name || ',' || cf_standard_name || ',' || imos_vocabulary_name || ',' || uv.name || ',' || uv.short_name || ',' || uv.definition),
 a AS (SELECT DISTINCT animal_id FROM aatams_biologging_snowpetrel.aatams_biologging_snowpetrel_map ORDER BY animal_id),
 b AS (SELECT '# ' || a.animal_id || ',' || tag_type || ',' || tag_code || ',' || tag_id || ',' || round(release_longitude::numeric,3) || ',' || round(release_latitude::numeric,3) || ',' || 
COALESCE(mass_at_release::text,'') || ',' || COALESCE(round(culman_length::numeric,1)::text,'') || ',' || COALESCE(round(culman_height::numeric,1)::text,'')
FROM a
JOIN aatams_biologging_snowpetrel.aatams_biologging_snowpetrel_metadata m ON m.tag_id::text = a.animal_id
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

GRANT SELECT ON aatams_biologging_snowpetrel_metadata_summary TO harvest_read_group, public;