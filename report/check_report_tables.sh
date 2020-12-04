#!/usr/bin/env bash

read_tables() {
    while read -r line
    do
        #skip noise
        skiptop=$(echo "$line" | grep "viewname")
        skipdiv=$(echo "$line" | grep "\-\-\-\-\-\-\-\-")
        if [ -z "$line" ] || [ -n "$skiptop" ] || [ -n "$skipdiv" ]; then
            continue
        fi

        #bot n rows
        bot=$(echo "$line" | grep "row")
        if [ -n "$bot" ]; then
            nrows=$(echo "$line" | tr "(" " " | cut -d " " -f2)
            echo "$nrows"
            continue;
        fi

        #view names
        viewname=$(echo "$line" | grep "view")
        if [ -z "$viewname" ]; then
            msg="ERROR: Output $line is not a reporting view.";
            fail=yes
        fi
        echo "$viewname"
    done
}

check_inputs () {

if [ -z "$expected_nviews" ]; then
    msg=$msg"\nError: Couldn't estimate the number of expected views. Please check the list_of_views_sorted file."
    fail=yes
fi

if [ -z "$expected_vnames" ]; then
    echo 2
    msg=$msg"\nError: Couldn't obtain the expected view names. Please check the list_of_view_sorted file."
    fail=yes
fi

}

#load data
. config.conf
export PGPASSWORD=$PASS;

#check inputs
if ! [ -f list_of_views_sorted ]; then
    msg="Error: list_of_views_sorted doesn't exist"
    echo "$msg"
    exit 1
fi


expected_vnames=$(cat list_of_views_sorted)
expected_nviews=$(printf '%s\n' ${expected_vnames[@]} | wc -l)
check_inputs
if [ -n "$fail" ];then
    echo "$msg"
    exit 1
fi

readarray -t results < <(psql -h $HOST -U $USER -d harvest < SQL_reporting_queries/checking_completion.sql | read_tables)

for k in ${results[@]}; do
    found=
    for kk in ${expected_vnames[@]}; do
        if [[ $k =~ ^[0-9]+$ ]]; then
            nviews=$k
            found=yes
            break
        fi
        if [[ $kk == "$k" ]]; then
            result_nviews=$result_nviews"$k"
            echo -e "View $k found"
            found=yes
            break
        fi
    done
    if [ -z "$found" ];then
         msg=$msg"\nError: Missing view $k"
         fail=yes
    fi
done
if [[ "$nviews" = "$expected_nviews" ]];then
    echo -e "All views included."
else
    echo ${results[@]}
    msg=$msg"\nError: Incomplete number of reporting views"
    fail=yes
fi

#finish
if [ -z "$fail" ];then
    echo "All good"
else
    echo "$msg"
    exit 1
fi
