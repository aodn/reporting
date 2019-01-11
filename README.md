Reporting
=========
The 'report/SQL_reporting_queries' folder contains all the SQL queries to generate the tables and views used to produce the IMOS data reports. These SQL queries are run manually at the start of each month for reporting purposes to the IMOS office and facilities, using the bash script in the report folder. Additionally the latter triggers an R script (not included in this repo) that generates a plot showing the number of tags and detections embargoed through time for the IMOS ATF acoustic facility. These embargo plots are then uploaded to Sheryll as part of the same R script.
At the end of this process 10 tables and 34 views should be present in the 'reporting' schema. The fact of having views instead of tables in the reporting schema is problematic when modifications are required on underlying schemas used by the reporting queries. 

This ad-hoc workflow could be improved by:
 * creating tables only instead of views
 * moving to a simple harvester approach for automation purposes and to solve privileges issues
 * coming up with a better approach to generate embargo plots on the fly	

The 'report/MS Word reporting templates' folder contains Word files detailing how the data reports should be produced using Jasper iReport.
