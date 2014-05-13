SET search_path = report_test, pg_catalog, public;

CREATE OR REPLACE VIEW acorn_all_deployments_view AS
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
  SELECT 'Gridded product - QC' AS data_type, 
	substring(u.site_code,'\, (.*)') AS site,
	COUNT(u.timeseries_id) AS no_files,
	date(min(time)) AS time_start,
	date(max(time)) AS time_end,
	round((date_part('day',max(time)-min(time)) + date_part('hours',max(time)-min(time))/24)::numeric, 0) AS coverage_duration,
	round(COUNT(u.timeseries_id) / (round((DATE_PART('days', DATE_TRUNC('month', min(time)) + '1 MONTH'::INTERVAL - DATE_TRUNC('month', min(time))))::numeric, 0) * 24) * 100, 1) AS monthly_coverage,
	COALESCE(a.month || ' ' || a.year) AS month_year,
	a.month,
	a.year
  FROM acorn_hourly_avg_qc.acorn_hourly_avg_qc_timeseries_url u
  JOIN a ON a.timeseries_id = u.timeseries_id
	GROUP BY data_type, u.site_code, month, year

UNION ALL

  SELECT 'Gridded product - non QC' AS data_type, 
	substring(u.site_code,'\, (.*)') AS site,
	COUNT(u.timeseries_id) AS no_files,
	date(min(time)) AS time_start,
	date(max(time)) AS time_end,
	round((date_part('day',max(time)-min(time)) + date_part('hours',max(time)-min(time))/24)::numeric, 0) AS coverage_duration,
	round(COUNT(u.timeseries_id) / (round((DATE_PART('days', DATE_TRUNC('month', min(time)) + '1 MONTH'::INTERVAL - DATE_TRUNC('month', min(time))))::numeric, 0) * 24) * 100, 1) AS monthly_coverage,
	COALESCE(b.month || ' ' || b.year) AS month_year,
	b.month,
	b.year
  FROM acorn_hourly_avg_nonqc.acorn_hourly_avg_nonqc_timeseries_url u
  JOIN b ON b.timeseries_id = u.timeseries_id
	GROUP BY data_type, u.site_code, month, year
	ORDER BY data_type, site, time_start;

grant all on table acorn_all_deployments_view to public;

CREATE OR REPLACE VIEW acorn_data_summary_view AS
  SELECT data_type,
	site,
	SUM(no_files) AS total_no_files,
	min(time_start) AS time_start,
	max(time_end) AS time_end,
	round((max(time_end)-min(time_start))::numeric, 0) AS coverage_duration,
	round(SUM(no_files) / (round((max(time_end)-min(time_start))::numeric, 0) * 24) * 100, 1) AS percentage_coverage
  FROM acorn_all_deployments_view
	GROUP BY data_type, site
	ORDER BY data_type, site;