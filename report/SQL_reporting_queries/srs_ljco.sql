select 'SRS - Lucinda Jetty' AS subfacility,
'Aeronet' AS parameter_site,
file_id::text AS deployment_code,
NULL::character varying AS sensor_name,
count(*) as nb_measurements,
min("TIME") AS start_date,
max("TIME") AS end_date,
round((date_part('days', (max("TIME") - min("TIME"))) + date_part('hours', (max("TIME") - min("TIME")))/24)::numeric, 1) AS coverage_duration,
NULL::numeric AS lat,
NULL::numeric AS lon
FROM srs_oc_ljco_aeronet.srs_oc_ljco_aeronet_map
GROUP BY file_id

UNION ALL

select 'SRS - Lucinda Jetty' AS subfacility,
'WQM' AS parameter_site,
NULL::text AS deployment_code,
NULL::character varying AS sensor_name,
count(DISTINCT file_id) as nb_measurements,
min(time_coverage_start) AS start_date,
max(time_coverage_end) AS end_date,
round((date_part('days', (max(time_coverage_end) - min(time_coverage_start))) + date_part('hours', (max(time_coverage_end) - min(time_coverage_start)))/24)::numeric, 1) AS coverage_duration,
NULL::numeric AS lat,
NULL::numeric AS lon
FROM srs_oc_ljco_wws.srs_oc_ljco_wws_hourly_wqm_fv01_timeseries_map