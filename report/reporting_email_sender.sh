#!/usr/bin/env sh

success_email() {
sendmail -v -t <<EOT
TO: $person
FROM: <$from>
SUBJECT: $subject
MIME-Version: 1.0
Content-Type: text/html; charset=utf-8

<html>
<head>
<meta http-equiv="content-type" content="text/html; charset=utf-8">
</head>
<p> The status of reporting is <font color="green">$logstats</font> </p>
<p> The Embargo file is located at emiiSheryl/eMII_data_report/AATAMS_EmbargoPlots/$image_name </p>
<p>You can also obtain the file here: <a href="http://131.217.38.73:8000/">StatusServer</a></p>
<p>The log file content is:</p>
<pre>$logstr</pre>
</body>
</html>
EOT
}

failed_email() {
sendmail -v -t <<EOT
TO: $person
FROM: <$from>
SUBJECT: $subject
MIME-Version: 1.0

Content-Type: text/html; charset=utf-8

<html>
<head>
<meta http-equiv="content-type" content="text/html; charset=utf-8">
</head>
<p> The status of reporting is <font color="red">$logstats</font> </p>
<p> Check also here <a href="http://131.217.38.73:8000/">StatusServer</a> </p>
<p></p>
<p>The log file content is:</p>
<pre>$logstr</pre>
</body>
</html>
EOT
}

cdate=$1
log=$2
stat=$3
file=$4
from=$5
person=$6

logstr=$(cat $log)
edate=$(echo $cdate | cut -d "T" -f1)
logstats=$(cat $stat)
image_name=$(basename "$file")

if [[ "$logstats" == "Good" ]];then
    subject="Report Checker - SUCCESS - $edate"
    success_email
else
    subject="Report Checker - FAILED - $edate"
    failed_email
fi
