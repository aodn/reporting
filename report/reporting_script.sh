## After having run this script, the reporting schema should have 10 tables and 34 views.

# Load config values
source config.conf

export PGPASSWORD=$PASS;
echo @@@@@@@@ Reporting view - AATAMS Acoustic @@@@@@@@
psql -h $HOST -U $USER -d harvest < SQL_reporting_queries/aatams_acoustic.sql;
echo @@@@@@@@ Reporting view - AATAMS Biologging @@@@@@@@
psql -h $HOST -U $USER -d harvest < SQL_reporting_queries/aatams_biologging.sql;
echo @@@@@@@@ Reporting view - AATAMS Satellite tagging @@@@@@@@
psql -h $HOST -U $USER -d harvest < SQL_reporting_queries/aatams_sattag.sql;
echo @@@@@@@@ Reporting views - ABOS @@@@@@@@
psql -h $HOST -U $USER -d harvest < SQL_reporting_queries/abos.sql;
echo @@@@@@@@ Reporting views - ACORN @@@@@@@@
psql -h $HOST -U $USER -d harvest < SQL_reporting_queries/acorn.sql;
echo @@@@@@@@ Reporting views - ANFOG @@@@@@@@
psql -h $HOST -U $USER -d harvest < SQL_reporting_queries/anfog.sql;
echo @@@@@@@@ Reporting views - ANMN NRS BGC @@@@@@@@
psql -h $HOST -U $USER -d harvest < SQL_reporting_queries/anmn_nrs_bgc.sql;
echo @@@@@@@@ Reporting views - ANMN NRS RT @@@@@@@@
psql -h $HOST -U $USER -d harvest < SQL_reporting_queries/anmn_rt.sql;
echo @@@@@@@@ Reporting views - ANMN PA @@@@@@@@
psql -h $HOST -U $USER -d harvest < SQL_reporting_queries/anmn_pa.sql;
echo @@@@@@@@ Reporting views - ANMN @@@@@@@@
psql -h $HOST -U $USER -d harvest < SQL_reporting_queries/anmn.sql;
# echo @@@@@@@@ Reporting views - Argo @@@@@@@@
# psql -h $HOST -U $USER -d harvest < SQL_reporting_queries/argo.sql;
echo @@@@@@@@ Reporting views - AUV @@@@@@@@
psql -h $HOST -U $USER -d harvest < SQL_reporting_queries/auv.sql;
echo @@@@@@@@ Reporting views - Facility summary @@@@@@@@
psql -h $HOST -U $USER -d harvest < SQL_reporting_queries/facility_summary.sql;
echo @@@@@@@@ Reporting views - FAIMMS @@@@@@@@
psql -h $HOST -U $USER -d harvest < SQL_reporting_queries/faimms.sql;
echo @@@@@@@@ Reporting views - SOOP CPR @@@@@@@@
psql -h $HOST -U $USER -d harvest < SQL_reporting_queries/soop_cpr.sql;
echo @@@@@@@@ Reporting views - SOOP @@@@@@@@
psql -h $HOST -U $USER -d harvest < SQL_reporting_queries/soop.sql;
echo @@@@@@@@ Reporting views - SRS @@@@@@@@
psql -h $HOST -U $USER -d harvest < SQL_reporting_queries/srs.sql;
echo @@@@@@@@ Reporting views - Totals @@@@@@@@
psql -h $HOST -U $USER -d harvest < SQL_reporting_queries/totals.sql;
echo @@@@@@@@ Reporting views - Summary totals @@@@@@@@
psql -h $HOST -U $USER -d harvest < SQL_reporting_queries/summary_totals.sql;
echo @@@@@@@@ Reporting views - Monthly snapshot @@@@@@@@
psql -h $HOST -U $USER -d harvest < SQL_reporting_queries/monthly_snapshot.sql;
echo @@@@@@@@ Reporting views - Asset map @@@@@@@@
psql -h $HOST -U $USER -d harvest < SQL_reporting_queries/asset_map.sql;
echo @@@@@@@@ R script - AATAMS Embargo plots @@@@@@@@
Rscript $RPATH/AATAMS_embargo_alldata.R;
