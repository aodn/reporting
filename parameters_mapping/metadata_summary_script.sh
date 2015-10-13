export PGPASSWORD='MicroCuts2001!';
echo @@@@@@@@ Metadata summary view - AATAMS Biologging Penguin @@@@@@@@
psql -h dbprod.emii.org.au -U xavier -d harvest < SQL_metadata_summary_queries/aatams_biologging_penguin.sql;
echo @@@@@@@@ Metadata summary view - AATAMS Biologging Shearwater @@@@@@@@
psql -h dbprod.emii.org.au -U xavier -d harvest < SQL_metadata_summary_queries/aatams_biologging_shearwater.sql;
echo @@@@@@@@ Metadata summary view - AATAMS Biologging Snow Petrel @@@@@@@@
psql -h dbprod.emii.org.au -U xavier -d harvest < SQL_metadata_summary_queries/aatams_biologging_snowpetrel.sql;
echo @@@@@@@@ Metadata summary view - AATAMS Satellite tagging DM @@@@@@@@
psql -h dbprod.emii.org.au -U xavier -d harvest < SQL_metadata_summary_queries/aatams_sattag_dm.sql;
echo @@@@@@@@ Metadata summary view - AATAMS Satellite tagging NRT @@@@@@@@
psql -h dbprod.emii.org.au -U xavier -d harvest < SQL_metadata_summary_queries/aatams_sattag_nrt.sql;
echo @@@@@@@@ Metadata summary views - ABOS SOFS FL @@@@@@@@
psql -h dbprod.emii.org.au -U xavier -d harvest < SQL_metadata_summary_queries/abos_sofs_fl.sql;
echo @@@@@@@@ Metadata summary views - ABOS SOFS SP @@@@@@@@
psql -h dbprod.emii.org.au -U xavier -d harvest < SQL_metadata_summary_queries/abos_sofs_sp.sql;
echo @@@@@@@@ Metadata summary views - ABOS TS @@@@@@@@
psql -h dbprod.emii.org.au -U xavier -d harvest < SQL_metadata_summary_queries/abos_ts.sql;
echo @@@@@@@@ Metadata summary views - ANFOG DM @@@@@@@@
psql -h dbprod.emii.org.au -U xavier -d harvest < SQL_metadata_summary_queries/anfog_dm.sql;
echo @@@@@@@@ Metadata summary views - ANFOG RT @@@@@@@@
psql -h dbprod.emii.org.au -U xavier -d harvest < SQL_metadata_summary_queries/anfog_rt.sql;
echo @@@@@@@@ Metadata summary views - ANMN AM DM @@@@@@@@
psql -h dbprod.emii.org.au -U xavier -d harvest < SQL_metadata_summary_queries/anmn_am_dm.sql;
echo @@@@@@@@ Metadata summary views - ANMN AM NRT @@@@@@@@
psql -h dbprod.emii.org.au -U xavier -d harvest < SQL_metadata_summary_queries/anmn_am_nrt.sql;
echo @@@@@@@@ Metadata summary views - ANMN BURST AVG @@@@@@@@
psql -h dbprod.emii.org.au -U xavier -d harvest < SQL_metadata_summary_queries/anmn_burst_avg.sql;
echo @@@@@@@@ Metadata summary views - ANMN MHL WAVE @@@@@@@@
psql -h dbprod.emii.org.au -U xavier -d harvest < SQL_metadata_summary_queries/anmn_mhlwave.sql;
echo @@@@@@@@ Metadata summary views - ANMN NRS BGC @@@@@@@@
psql -h dbprod.emii.org.au -U xavier -d harvest < SQL_metadata_summary_queries/anmn_nrs_bgc.sql;
echo @@@@@@@@ Metadata summary views - ANMN NRS CTD @@@@@@@@
psql -h dbprod.emii.org.au -U xavier -d harvest < SQL_metadata_summary_queries/anmn_nrs_ctd.sql;
echo @@@@@@@@ Metadata summary views - ANMN NRS DAR YON @@@@@@@@
psql -h dbprod.emii.org.au -U xavier -d harvest < SQL_metadata_summary_queries/anmn_nrs_dar_yon.sql;
echo @@@@@@@@ Metadata summary views - ANMN RT BIO @@@@@@@@
psql -h dbprod.emii.org.au -U xavier -d harvest < SQL_metadata_summary_queries/anmn_nrs_rt_bio.sql;
echo @@@@@@@@ Metadata summary views - ANMN RT METEO @@@@@@@@
psql -h dbprod.emii.org.au -U xavier -d harvest < SQL_metadata_summary_queries/anmn_nrs_rt_meteo.sql;
echo @@@@@@@@ Metadata summary views - ANMN RT WAVE @@@@@@@@
psql -h dbprod.emii.org.au -U xavier -d harvest < SQL_metadata_summary_queries/anmn_nrs_rt_wave.sql;
echo @@@@@@@@ Metadata summary views - ANMN T REGRIDDED @@@@@@@@
psql -h dbprod.emii.org.au -U xavier -d harvest < SQL_metadata_summary_queries/anmn_t_regridded.sql;
echo @@@@@@@@ Metadata summary views - ANMN TS @@@@@@@@
psql -h dbprod.emii.org.au -U xavier -d harvest < SQL_metadata_summary_queries/anmn_ts.sql;
echo @@@@@@@@ Metadata summary views - AODN NT SATTAG HAWKSBILL @@@@@@@@
psql -h dbprod.emii.org.au -U xavier -d harvest < SQL_metadata_summary_queries/aodn_nt_sattag_hawksbill.sql;
echo @@@@@@@@ Metadata summary views - AODN NT SATTAG OLIVE RIDLEY @@@@@@@@
psql -h dbprod.emii.org.au -U xavier -d harvest < SQL_metadata_summary_queries/aodn_nt_sattag_oliveridley.sql;
echo @@@@@@@@ Metadata summary views - Argo @@@@@@@@
psql -h dbprod.emii.org.au -U xavier -d harvest < SQL_metadata_summary_queries/argo.sql;
echo @@@@@@@@ Metadata summary views - AUV @@@@@@@@
psql -h dbprod.emii.org.au -U xavier -d harvest < SQL_metadata_summary_queries/auv.sql;
echo @@@@@@@@ Metadata summary views - NOAA Drifters @@@@@@@@
psql -h dbprod.emii.org.au -U xavier -d harvest < SQL_metadata_summary_queries/noaa_drifters.sql;
echo @@@@@@@@ Metadata summary views - SOOP ASF MFT @@@@@@@@
psql -h dbprod.emii.org.au -U xavier -d harvest < SQL_metadata_summary_queries/soop_asf_mft.sql;
echo @@@@@@@@ Metadata summary views - SOOP ASF MT @@@@@@@@
psql -h dbprod.emii.org.au -U xavier -d harvest < SQL_metadata_summary_queries/soop_asf_mt.sql;
echo @@@@@@@@ Metadata summary views - SOOP CO2 @@@@@@@@
psql -h dbprod.emii.org.au -U xavier -d harvest < SQL_metadata_summary_queries/soop_co2.sql;
echo @@@@@@@@ Metadata summary views - SOOP SST @@@@@@@@
psql -h dbprod.emii.org.au -U xavier -d harvest < SQL_metadata_summary_queries/soop_sst.sql;
echo @@@@@@@@ Metadata summary views - SOOP TMV NRT @@@@@@@@
psql -h dbprod.emii.org.au -U xavier -d harvest < SQL_metadata_summary_queries/soop_tmv_nrt.sql;
echo @@@@@@@@ Metadata summary views - SOOP TMV @@@@@@@@
psql -h dbprod.emii.org.au -U xavier -d harvest < SQL_metadata_summary_queries/soop_tmv.sql;
echo @@@@@@@@ Metadata summary views - SOOP TRV @@@@@@@@
psql -h dbprod.emii.org.au -U xavier -d harvest < SQL_metadata_summary_queries/soop_trv.sql;
echo @@@@@@@@ Metadata summary views - SOOP XBT DM @@@@@@@@
psql -h dbprod.emii.org.au -U xavier -d harvest < SQL_metadata_summary_queries/soop_xbt_dm.sql;
echo @@@@@@@@ Metadata summary views - SOOP XBT NRT @@@@@@@@
psql -h dbprod.emii.org.au -U xavier -d harvest < SQL_metadata_summary_queries/soop_xbt_nrt.sql;
echo @@@@@@@@ Metadata summary views - SRS Altimetry @@@@@@@@
psql -h dbprod.emii.org.au -U xavier -d harvest < SQL_metadata_summary_queries/srs_altimetry.sql;
