
This is the IMOS Reporting repo containing queries and scripts to estimate summary statistics.

Requirements
=========

To be able to run the scripts manually, you will need:

1. ```bash```
2. ```psql```
3. ```R``` and the ```RPostgreSQL,RPostgres,gmt,plyr``` libraries
   
To be able to setup a cronjob that send scheduled emails with a job summary, you will need:
   
4. a ```cron``` service
5. ```sendmail```
6. ```ssmtp``` service properly configured (``/etc/ssmtp.conf```)

To be able to serve a website with a job status page you will also need:

8. python3.8
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

At the end of this process, 10 tables and 34 views should be present in the 'reporting' schema. The fact of having views instead of tables in the reporting schema is problematic when modifications are required on underlying schemas used by the reporting queries. 

This ad-hoc workflow could be improved by:
 
 * creating tables only instead of views
 * moving to a simple harvester approach for automation purposes and to solve privileges issues
 * coming up with a better approach to generate embargo plots on the fly
 
The 'report/MS Word reporting templates' folder contains Word files detailing how the data reports should be produced using Jasper iReport.

The ```reporting_improvements``` branch was created to:

  * avoid sheryl mount calls (folders are assumed as always mounted).
  * try individual sql queries 5 times before returning a fail.
  * allow sending scheduled emails with attachemnts/logs of the reporting task.
  * allow serving a webpage with the reporting status.
  
How to run
==========

1) go to ```report/```
1) edit ```config.conf```
    * add username ```reporting```
    * add password from ```chef-private/data_bags/postgresql_roles/dbprod_main.json```
    * add your utas credentials in order to mount sheryl
2) run ```./reporting_script.sh```

You may want to schedule the report script to be run every month:
* 3) add the line ```0 0 1 * * cd <YOUR_REPORTING_GIT_REPO>/report && ./reporting_script.sh``` to your crontab.


It is recommended that the reporting is performed over a time window of low load and away from DB maintenance schedules(e.g. backups). In practice, scheduling at 00:00am resulted in less fails/faster queries.


How to run the email scheduling (optional)
========== 
This requires you to use the ```reporting_improvements``` branch. Please note that this branch assumes the sheryl folder is always mounted so we don't need to provide UTAS permissions or mount anything.

3) configure and test the `/etc/ssmtp.conf` and the `sendmail` functionality, otherwise, emails will fail.
4) setup destination addresses in `report/email_receivers.conf`:
    * ```mail_to=youremail@utas.edu.au```
5) Instead of running the bare reporting script, you will need to trigger the ```trigger_report_and_email.sh``` script:
    * Include the line: ```0 0 1 * * cd <YOUR_REPORTING_GIT_REPO>/report && ./trigger_report_and_email.sh```
    * This script requires the following folders to exist at the root level of the repo: ```figures,report_logs,checker_logs,checked_statuses,report_statuses```
 
How to run the webserver html page
==========
The webserver is quite simple and watches the folders and files written by the email reporting scripts to serve a simple html page. The page contains the latest embargo figure and status from the reporting task as a whole. The webserver is a simple python flask service and completely optional. A further enhancement to this would be to allow certain users to trigger the reporting with a button. However, this requires some protection from abuse/user authentication.

The configuration below assumes the service is installed in the home folder of a `reporting` user, and pyenv is properly installed, and setup to use python3.8.0 as a global and local python.

6) Run the webserver manually:
    * ```python <YOUR_REPORTING_GIT_REPO>/flask_reporting.py```
    * The service will watch the required folders above and present a simple html page at ```http://localhost:8000```
7) You may want to configure the webserver as a linux service. In ```openrc``` this is done by a service file, ```/etc/init.d/reporting-service```, with the following content:

```bash
#!/sbin/openrc-run
depend() {
	after mount-ro
	after localmount
}

start() {
	ebegin "starting flask app"
	PYTHONPATH=/home/reporting/.pyenv/versions/3.8.0 /home/reporting/.pyenv/shims/python /home/reporting/reporting/flask_reporting.py &
   #^update path if required.
	eend $? "failed to start flask app"
}

stop() {
	ebegin "closing flask app"
	pid=$(pgrep -af -u root flask_reporting.py | cut -d " " -f1)
	if [ -z "$pid" ]; then
	  eend 0 "no flask app running"
	else
          kill $pid
	  eend $?
	fi
}
```
8) and asking it to run every time the machine is booted: ```rc-update add reporting-server default```
