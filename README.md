Reporting
=========
The 'report/SQL_reporting_queries' folder contains all the SQL queries to generate the tables and views used to produce the IMOS data reports. These SQL queries are run manually at the start of each month for reporting purposes to the IMOS office and facilities, using the bash script in the report folder. Additionally the latter triggers an R script (not included in this repo) that generates a plot showing the number of tags and detections embargoed through time for the IMOS ATF acoustic facility. These embargo plots are then uploaded to Sheryll as part of the same R script.
At the end of this process 10 tables and 34 views should be present in the 'reporting' schema. The fact of having views instead of tables in the reporting schema is problematic when modifications are required on underlying schemas used by the reporting queries. 

This ad-hoc workflow could be improved by:
 * creating tables only instead of views
 * moving to a simple harvester approach for automation purposes and to solve privileges issues
 * coming up with a better approach to generate embargo plots on the fly	

The 'report/MS Word reporting templates' folder contains Word files detailing how the data reports should be produced using Jasper iReport.

How to run
==========

* 1) edit ```report/config.conf```
  * add db password for reporting username
  * add utas credentials in order to mount sheryl
* 2) run ```./report/reporting_script.sh```


Automatic reporting & notification
=========

For automatic reporting, the following software are required:

1.sendmail
2.ssmtp

The conditions required are:

1. Setup a cronjob to call `trigger_reporting_and_email.sh`
2. Ssmtp is properly configured
3. You can execute the reporting script.
4. The Sheryl folder is always mounted.
5. You edit trigger_reporting_and_email.sh to send email to right persons.

Use The wrapper `trigger_reporting_and_email.sh` will trigger the reporting_script.sh, the checker and a sendmail job.

The email body is templated to include a link to the webserver. This will also need to be changed/verified.

Webserver
=========

A simple flask webserver can be run to serve a simple table and the Embargo plots.

Software requirements:

python==3.8.0
flask==1.1.1
waitress==1.3.1

Configuration:

1. You will need to change the IP address in flask_reporting.py.
2. You will need to make sure the `trigger_reporting_and_email.sh` run successfully.
3. You will need to make sure the emIISheryl path is always mounted - see reporting scripts.


Further improvements
========

Send the embargo/logs to an s3 bucket.
Completely remove the sheryl folder dependency.
Call the sql query from lambda/batch.
Enable cronjob like behaviour in AWS to trigger query/reporting.
Substitute the flask webserver by a static website serving the s3 files.
Sendemail via AWS easy send instead of using sendmail.
