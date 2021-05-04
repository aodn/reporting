#!/usr/bin/env sh

success_email() {
( 
echo "TO: $person
FROM: <$from>
SUBJECT: $subject
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary=mixed_boundary

--mixed_boundary
Content-Type: multipart/related; boundary=related_boundary

--related_boundary
Content-Type: multipart/alternative; boundary=alternative_boundary

--alternative_boundary
Content-type: text/html; charset=utf-8
Content-Transfer-Encoding: quoted-printable

<html>
<head>
<meta http-equiv=\"content-type\" content=\"text/html\"; charset=\"utf-8\">
</head>
<img src=3D=22cid:logo.png=40qcode.co.uk=22 width 200 height=3D60

<p> The status of reporting is <font color=\"green\">$logstats</font> </p>
<p> The Embargo file is attached and also located at emiiSheryl/eMII_data_report/AATAMS_EmbargoPlots/$image_name </p>
<p> You may can also obtain the file here: <a href=\"http://131.217.38.73:8000/\">StatusServer</a></p>
<p> The Report log file is also attached.</p>
</body>
</html>
--alternative_boundary--

--related_boundary
Content-Type: text/txt; name=reporting.log
Content-Description: reporting.txt
Content-Disposition: inline;filename=reporting.txt
Content-ID: <aodnreporting@gmail.com>
"
cat $log
echo "
--related_boundary
Content-Type: image/jpgeg;name=embargo.jpeg
Content-Description: embargo_file
Content-Transfer-Encoding: base64
Content-Disposition: inline;
Content-ID: <aodnreporting@gmail.com>
"
openssl base64 < $file
echo "
--related_boundary--
--mixed_boundary--
"
) | sendmail -v -t
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

log_name=$(basename "$log")
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
