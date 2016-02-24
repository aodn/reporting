export PGPASSWORD='MicroCuts2001!';
echo @@@@@@@@ Reporting view - AATAMS Acoustic @@@@@@@@
psql -h dbprod.emii.org.au -U xavier -d harvest < SQL_reporting_queries/aatams_acoustic.sql;
echo @@@@@@@@ Reporting view - AATAMS Biologging @@@@@@@@
psql -h dbprod.emii.org.au -U xavier -d harvest < SQL_reporting_queries/aatams_biologging.sql;
echo @@@@@@@@ Reporting view - AATAMS Satellite tagging @@@@@@@@
psql -h dbprod.emii.org.au -U xavier -d harvest < SQL_reporting_queries/aatams_sattag.sql;
echo @@@@@@@@ Reporting views - ABOS @@@@@@@@
psql -h dbprod.emii.org.au -U xavier -d harvest < SQL_reporting_queries/abos.sql;
echo @@@@@@@@ Reporting views - ACORN @@@@@@@@
psql -h dbprod.emii.org.au -U xavier -d harvest < SQL_reporting_queries/acorn.sql;
echo @@@@@@@@ Reporting views - ANFOG @@@@@@@@
psql -h dbprod.emii.org.au -U xavier -d harvest < SQL_reporting_queries/anfog.sql;
echo @@@@@@@@ Reporting views - ANMN NRS BGC @@@@@@@@
psql -h dbprod.emii.org.au -U xavier -d harvest < SQL_reporting_queries/anmn_nrs_bgc.sql;
echo @@@@@@@@ Reporting views - ANMN NRS RT @@@@@@@@
psql -h dbprod.emii.org.au -U xavier -d harvest < SQL_reporting_queries/anmn_rt.sql;
echo @@@@@@@@ Reporting views - ANMN PA @@@@@@@@
psql -h dbprod.emii.org.au -U xavier -d harvest < SQL_reporting_queries/anmn_pa.sql;
echo @@@@@@@@ Reporting views - ANMN @@@@@@@@
psql -h dbprod.emii.org.au -U xavier -d harvest < SQL_reporting_queries/anmn.sql;
echo @@@@@@@@ Reporting views - Argo @@@@@@@@
psql -h dbprod.emii.org.au -U xavier -d harvest < SQL_reporting_queries/argo.sql;
echo @@@@@@@@ Reporting views - AUV @@@@@@@@
psql -h dbprod.emii.org.au -U xavier -d harvest < SQL_reporting_queries/auv.sql;
echo @@@@@@@@ Reporting views - Facility summary @@@@@@@@
psql -h dbprod.emii.org.au -U xavier -d harvest < SQL_reporting_queries/facility_summary.sql;
echo @@@@@@@@ Reporting views - FAIMMS @@@@@@@@
psql -h dbprod.emii.org.au -U xavier -d harvest < SQL_reporting_queries/faimms.sql;
echo @@@@@@@@ Reporting views - SOOP CPR @@@@@@@@
psql -h dbprod.emii.org.au -U xavier -d harvest < SQL_reporting_queries/soop_cpr.sql;
echo @@@@@@@@ Reporting views - SOOP @@@@@@@@
psql -h dbprod.emii.org.au -U xavier -d harvest < SQL_reporting_queries/soop.sql;
echo @@@@@@@@ Reporting views - SRS @@@@@@@@
psql -h dbprod.emii.org.au -U xavier -d harvest < SQL_reporting_queries/srs.sql;
echo @@@@@@@@ Reporting views - Totals @@@@@@@@
psql -h dbprod.emii.org.au -U xavier -d harvest < SQL_reporting_queries/totals.sql;
echo @@@@@@@@ Reporting views - Summary totals @@@@@@@@
psql -h dbprod.emii.org.au -U xavier -d harvest < SQL_reporting_queries/summary_totals.sql;
echo @@@@@@@@ Reporting views - Monthly snapshot @@@@@@@@
psql -h dbprod.emii.org.au -U xavier -d harvest < SQL_reporting_queries/monthly_snapshot.sql;
echo @@@@@@@@ Reporting views - Asset map @@@@@@@@
psql -h dbprod.emii.org.au -U xavier -d harvest < SQL_reporting_queries/asset_map.sql;
echo @@@@@@@@ R script - AATAMS Embargo plots @@@@@@@@
Rscript /Users/xavierhoenner/Work/AATAMS_AcousticTagging/Outcomes/Embargo_plots/AATAMS_embargo_alldata.R;