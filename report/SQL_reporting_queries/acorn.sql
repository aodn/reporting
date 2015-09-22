SET search_path = report_test, public;
DROP TABLE IF EXISTS acorn_hourly_vectors_all_deployments_view CASCADE;
DROP TABLE IF EXISTS acorn_radials_all_deployments_view CASCADE;
DROP TABLE IF EXISTS acorn_hourly_vectors_data_summary_view CASCADE;
DROP TABLE IF EXISTS acorn_radials_data_summary_view CASCADE;

-------------------------------
-- VIEW FOR ACORN; The report.acorn_manual table is not being used for reporting anymore.
-------------------------------
-- All hourly vectors data
CREATE TABLE acorn_hourly_vectors_all_deployments_view AS
WITH a AS (
  SELECT timeseries_id,
	site_code,
	to_char(to_timestamp (date_part('month',time)::text, 'MM'), 'Month') AS month,
	date_part('year',time)::text AS year
  FROM acorn_hourly_avg_qc.acorn_hourly_avg_qc_timeseries_url),
     b AS (
  SELECT timeseries_id,
	site_code,
	to_char(to_timestamp (date_part('month',time)::text, 'MM'), 'Month') AS month,
	date_part('year',time)::text AS year
  FROM acorn_hourly_avg_nonqc.acorn_hourly_avg_nonqc_timeseries_url)
  SELECT 'Hourly vectors - QC' AS data_type, 
	substring(u.site_code,'\, (.*)') AS site,
	COUNT(u.timeseries_id) AS no_files,
	date(min(time)) AS time_start,
	date(max(time)) AS time_end,
	round((date_part('day',max(time)-min(time)) + date_part('hours',max(time)-min(time))/24)::numeric, 1) AS coverage_duration,
	round(COUNT(u.timeseries_id) / (round((DATE_PART('days', DATE_TRUNC('month', min(time)) + '1 MONTH'::INTERVAL - DATE_TRUNC('month', min(time))))::numeric, 0) * 24) * 100, 1) AS monthly_coverage,
	COALESCE(a.month || ' ' || a.year) AS month_year,
	a.month,
	a.year
  FROM acorn_hourly_avg_qc.acorn_hourly_avg_qc_timeseries_url u
  JOIN a ON a.timeseries_id = u.timeseries_id
	GROUP BY data_type, u.site_code, month, year

UNION ALL

  SELECT 'Hourly vectors - non QC' AS data_type, 
	substring(u.site_code,'\, (.*)') AS site,
	COUNT(u.timeseries_id) AS no_files,
	date(min(time)) AS time_start,
	date(max(time)) AS time_end,
	round((date_part('day',max(time)-min(time)) + date_part('hours',max(time)-min(time))/24)::numeric, 1) AS coverage_duration,
	round(COUNT(u.timeseries_id) / (round((DATE_PART('days', DATE_TRUNC('month', min(time)) + '1 MONTH'::INTERVAL - DATE_TRUNC('month', min(time))))::numeric, 0) * 24) * 100, 1) AS monthly_coverage,
	COALESCE(b.month || ' ' || b.year) AS month_year,
	b.month,
	b.year
  FROM acorn_hourly_avg_nonqc.acorn_hourly_avg_nonqc_timeseries_url u
  JOIN b ON b.timeseries_id = u.timeseries_id
	GROUP BY data_type, u.site_code, month, year
	ORDER BY data_type, site, time_start DESC;

grant all on table acorn_hourly_vectors_all_deployments_view to public;

-- All radials data
CREATE TABLE acorn_radials_all_deployments_view AS
WITH c AS (
  SELECT timeseries_id,
	site_code,
	to_char(to_timestamp (date_part('month',time)::text, 'MM'), 'Month') AS month,
	date_part('year',time)::text AS year
  FROM acorn_radial_qc.acorn_radial_qc_timeseries_url),
         d AS (
  SELECT timeseries_id,
	site_code,
	to_char(to_timestamp (date_part('month',time)::text, 'MM'), 'Month') AS month,
	date_part('year',time)::text AS year,
	substring("ssr_Radar", 'WERA|SeaSonde') AS "ssr_Radar"
  FROM acorn_radial_nonqc.acorn_radial_nonqc_timeseries_url)
  SELECT 'Radials - QC' AS data_type, 
	CASE WHEN u.site_code = 'BONC' THEN 'Bonney Coast' 
	     WHEN u.site_code = 'CBG' THEN 'Capricorn Bunker Group'
	     WHEN u.site_code = 'TURQ' THEN 'Turqoise Coast'
	     WHEN u.site_code = 'SAG' THEN 'South Australia Gulf'
	     WHEN u.site_code = 'ROT' THEN 'Rottnest Shelf'
	     WHEN u.site_code = 'COF' THEN 'Coffs Harbour' END AS site,
	u.platform_code,
	COUNT(u.timeseries_id) AS no_files,
	date(min(time)) AS time_start,
	date(max(time)) AS time_end,
	round((date_part('day',max(time)-min(time)) + date_part('hours',max(time)-min(time))/24)::numeric, 1) AS coverage_duration,
	round(COUNT(u.timeseries_id) / (round((DATE_PART('days', DATE_TRUNC('month', min(time)) + '1 MONTH'::INTERVAL - DATE_TRUNC('month', min(time))))::numeric, 0) * 6*24) * 100, 1) AS monthly_coverage,
	COALESCE(c.month || ' ' || c.year) AS month_year,
	c.month,
	c.year
  FROM acorn_radial_qc.acorn_radial_qc_timeseries_url u
  JOIN c ON c.timeseries_id = u.timeseries_id
	GROUP BY data_type, u.site_code, u.platform_code, month, year

UNION ALL

  SELECT 'Radials - non QC' AS data_type, 
	CASE WHEN u.site_code = 'BONC' THEN 'Bonney Coast' 
	     WHEN u.site_code = 'CBG' THEN 'Capricorn Bunker Group'
	     WHEN u.site_code = 'TURQ' THEN 'Turqoise Coast'
	     WHEN u.site_code = 'SAG' THEN 'South Australia Gulf'
	     WHEN u.site_code = 'ROT' THEN 'Rottnest Shelf'
	     WHEN u.site_code = 'COF' THEN 'Coffs Harbour' END AS site,
	u.platform_code,
	COUNT(u.timeseries_id) AS no_files,
	date(min(time)) AS time_start,
	date(max(time)) AS time_end,
	round((date_part('day',max(time)-min(time)) + date_part('hours',max(time)-min(time))/24)::numeric, 1) AS coverage_duration,
	round(COUNT(u.timeseries_id) / (round((DATE_PART('days', DATE_TRUNC('month', min(time)) + '1 MONTH'::INTERVAL - DATE_TRUNC('month', min(time))))::numeric, 0) * 
		(CASE WHEN d."ssr_Radar" = 'WERA' THEN 6*24 WHEN d."ssr_Radar" = 'SeaSonde' THEN 24 END)) * 100, 1) AS monthly_coverage,
	COALESCE(d.month || ' ' || d.year) AS month_year,
	d.month,
	d.year
  FROM acorn_radial_nonqc.acorn_radial_nonqc_timeseries_url u
  JOIN d ON d.timeseries_id = u.timeseries_id
	GROUP BY data_type, u.site_code, u.platform_code, month, year, d."ssr_Radar"
	ORDER BY data_type, site, time_start DESC, platform_code;

grant all on table acorn_radials_all_deployments_view to public;

-- Hourly vectors data summary view
CREATE TABLE acorn_hourly_vectors_data_summary_view AS
  SELECT data_type,
	site,
	SUM(no_files) AS total_no_files,
	min(time_start) AS time_start,
	max(time_end) AS time_end,
	round(((max(time_end)-min(time_start))::numeric)/365.25, 1) AS coverage_duration,
	round(SUM(no_files) / (round((max(time_end)-min(time_start))::numeric, 0) * 24) * 100, 1) AS percentage_coverage
  FROM acorn_hourly_vectors_all_deployments_view
	GROUP BY data_type, site
	ORDER BY data_type, site;

grant all on table acorn_hourly_vectors_data_summary_view to public;

-- Radials data summary view
CREATE TABLE acorn_radials_data_summary_view AS
  SELECT data_type,
	site,
	platform_code,
	SUM(no_files) AS total_no_files,
	min(time_start) AS time_start,
	max(time_end) AS time_end,
	round(((max(time_end)-min(time_start))::numeric)/365.25, 1) AS coverage_duration,
	round((SUM(monthly_coverage)/COUNT(*))::numeric, 1) AS percentage_coverage
  FROM acorn_radials_all_deployments_view
	GROUP BY data_type, site, platform_code
	ORDER BY data_type, site, platform_code;

grant all on table acorn_radials_data_summary_view to public;