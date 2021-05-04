
This is the IMOS Reporting repo containing queries and scripts to estimate summary statistics.

Requirements
=========

To be able to run the scripts manually, you will need:

1. ```bash```
2. ```psql```
3. ```R``` and the ```RPostgreSQL,RPostgres,gmt,plyr``` libraries
   
To be able to setup a cronjob that send schedule emails with the status of the summary job, you will need:
   
4. a ```cron``` service
5. ```sendmail```
6. ```ssmtp``` service properly configured (``/etc/ssmtp.conf```)

To be able to serve a website with a status page you will also need:

8. python3-8
   a. waitress-1.4.4+
   b. Flask-1.1.2+

For both email scheduling and webserver functionality, you will need to use the ```reporting_improvements``` branch.

Reporting
=========

The reporting task consists of two sub-tasks:

1. Running summary SQL queries 
2. Creating figures

The 'report/SQL_reporting_queries' folder contains all the SQL queries to generate the tables and views used to produce the IMOS data reports. 

These SQL queries create summary statistics from several tables for reporting purposes to the IMOS office and facilities. Every summary requires monthly updates. Hence, they can be run manually at the start of each month using the bash script `report/reporting_script.sh` or properly scheduled.

This script also triggers an R script that generates a plot showing the number of tags and detections embargoed through time for the IMOS ATF acoustic facility. 

These embargo plots are then uploaded to Sheryll as part of the same R script.

At the end of this process 10 tables and 34 views should be present in the 'reporting' schema. The fact of having views instead of tables in the reporting schema is problematic when modifications are required on underlying schemas used by the reporting queries. 

This ad-hoc workflow could be improved by:
 
 * creating tables only instead of views
 * moving to a simple harvester approach for automation purposes and to solve privileges issues
 * coming up with a better approach to generate embargo plots on the fly
 
The 'report/MS Word reporting templates' folder contains Word files detailing how the data reports should be produced using Jasper iReport.

The ```reporting_improvements``` branch was created to:

  * avoid sheryl mount calls (folders are assumed as always mounted).
  * try individual sql queries for 5 times before returning a fail.
  * may send scheduled emails with attachemnts/logs of the reporting task
  * may serve a webpage with the reporting status
  
How to run
==========

1) edit ```report/config.conf```
    * add db password for reporting username
    * add utas credentials in order to mount sheryl
2) run ```./report/reporting_script.sh```

You may want to schedule the report script to be run every month:
* 3) add the line ```0 0 1 * * cd <YOUR_REPORTING_GIT_REPO>/report && ./reporting_script.sh``` to your crontab.


How to run the email scheduling (optional)
========== 
This requires you to use the ```reporting_improvements``` branch. Please note that this branch assumes the sheryl folder is always mounted (if not, the email/server still work).


3) configure and test the ssmtp.conf and the sendmail functionality, otherwise emails will fail.
4) setup destination addresses in email_receivers.conf:
    * ```mail_to=youremail@utas.edu.au```
5) Instead of running the bare reporting script, you will need to trigger the ```trigger_report_and_email.sh``` script:
    * Include the line: ```0 0 1 * * cd <YOUR_REPORTING_GIT_REPO>/report && ./trigger_report_and_email.sh```
    * The script requires the following folders to exist at the root level of the repo: ```figures,report_logs,checker_logs,checked_statuses,report_statuses,```
 
How to run the webserver html page
==========
The webserver is quite simple and watches the folders used by the email reporting scripts to serve a simple html page. The page contains the latest embargo figure and some status from the reporting task. The webserver is a simple python flask service and completely optional. A further enhancement to this would be to allow certain users to trigger the reporting with a button. However, this requires some protection from abuse/user authentication.


6) Run the webserver manually:
    * ```python3 <YOUR_REPORTING_GIT_REPO>/flask_reporting.py```
    * The service will watch the required folders above and present a simple html page at ```http://localhost:8000```
7) You may want to configure the webserver as a linux service. In ```openrc``` this is equivalent to creating a ```/etc/init.d/reporting-server``` file with the content:
  ```bash
  #!/sbin/openrc-run
depend() {       
        after mount-ro
        after localmount
}

start() {
        ebegin "Starting the IMOS Reporting flask service"
        <YOUR_PYTHON3_PATH> <YOUR_GIT_REPO_PATH>/flask_reporting.py > /tmp/flask_reporting.log &
        eend $? "failed to start IMOS Reporting flask service"
}
```
8) and asking it to run every time the machine is booted: ```rc-update add reporting-server default```

