SET search_path = reporting, public;
DROP VIEW IF EXISTS facility_summary_view CASCADE;

-------------------------------
-- VIEW FOR Facility summary;
-------------------------------
-- All deployments view
CREATE OR REPLACE VIEW facility_summary_view AS 
  SELECT facility.acronym AS facility_acronym,
	COALESCE(to_char(to_timestamp (date_part('month',facility_summary.reporting_date)::text, 'MM') ,'TMMon')||' '||date_part('year',facility_summary.reporting_date)) AS reporting_month,
	facility_summary.summary AS updates, 
	facility_summary_item.name AS issues,
	facility_summary.reporting_date
  FROM report.facility_summary
  FULL JOIN report.facility ON facility_summary.facility_name_id = facility.id
  LEFT JOIN report.facility_summary_item ON facility_summary.summary_item_id = facility_summary_item.row_id
	ORDER BY facility_acronym, reporting_date DESC, issues;

grant all on table facility_summary_view to public;