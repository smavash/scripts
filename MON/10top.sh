#!/bin/bash

. ~/.profile
MAILLIST=irina.tsibulsky@tnuva.co.il
#slava.mavashev@tnuva.co.il,

DATE=`date +"%d-%b-%Y-%H%M"`
PROCESS_ID=""
ALL_REPORTS="/tmp"
REPORT="${ALL_REPORTS}/10_top_${DATE}.txt"
APPSPWD=`env|grep APPLPWD= |awk -F= '{print $2}'`

#top -n1 -c > $REPORT
#top -b -n1 -c|awk '{print $1}'|xargs 
sqlplus -s <<!
apps/apps
set pagesize 24 echo off feed off linesize 130 
select * from dual
/
exit
!

