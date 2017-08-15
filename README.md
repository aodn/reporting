reporting
=========

The 'SQL_reporting_queries' folder contains all the SQL queries to generate the tables and views used to produce the IMOS data reports.

The 'MS Word reporting templates' folder contains Word files detailing how the data reports should be produced using iReport.


To address:
* Argo and AATAMS acoustic reporting views contain too many records, Jac can't pdf the corresponding data reports.
* AATAMS satellite tagging: 1/ Headers need to mention MEOP; 2/ Campaigns without species names; 3/ DM QC: Inconsistencies in species names; 4/ No DM QC in totals
* Argo: 1/ No new data since end of June, no active floats; 2/ Query to generate views too slow; 3/ Problem with time range.
* ABOS: Problem with time range.
* ANMN: 1/ Summary report too long; 2/ RT: Problem with time range + null site name.
* ACORN: null station code for radials. Misspelling of Turquoise Coast site code
* SOOP XBT NRT: Problem with time range.
* FAIMMS: Problem with MYRWS site name. Should it be Myrmidon Reef instead? 
* ANFOG:  Problem with total numbers of platforms and deployments in the "OceanGliders" summary report
