#!/usr/bin/env sh


email_trigger() {
    ./reporting_email_sender.sh "$cdate" ../report_logs/"$cdate" ../report_statuses/"$cdate" ../figures/eMII_data_report/AATAMS_EmbargoPlots/EmbargoPlot_"$zdate".jpeg aodnreporting@gmail.com "hugo.oliveira@utas.edu.au" #"jacqui.hope@utas.edu.au"
}

# Drive the report script
ntry=5
zdate=$(date +%Y-%m-%d)
cdate=$(date +%Y%m%dT%H%M%S)

for k in $(seq 1 $ntry);do
    ./reporting_script.sh > ../report_logs/"$cdate" || failreport=yes
    ./check_report_tables.sh > ../checker_logs/"$cdate" || failcheck=yes
    [ -n "$failreport" ] && echo "Error: Report script failed" && echo "Bad" > ../report_statuses/"$cdate"
    [ -n "$failcheck" ] && echo "Error: Incomplete Tables" && echo "Bad" > ../report_statuses/"$cdate"
    { [ -z "$failreport" ] || [ -z "$failcheck" ]; } && echo "SUCCESS: All reporting tables are alive and updated." && echo "Good" > ../report_statuses/"$cdate" && echo "Good" > ../checker_statuses/"$cdate" && email_trigger && break
#    { [ -z "$failreport" ] || [ -z "$failcheck" ]; } && echo "SUCCESS: All reporting tables are alive and updated." && echo "Good" > ../report_statuses/"$cdate" && echo "Good" > ../checker_statuses/"$cdate" && break

done
