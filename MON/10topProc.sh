#!/bin/bash

. ~/.profile

MAILLIST=slava.mavashev@tnuva.co.il,irina.tsibulsky@tnuva.co.il,DBA-Team

DATE=`date +"%d-%b-%Y-%H%M"`
ALL_REPORTS="/tmp"
REPORT="${ALL_REPORTS}/CM_long_${DATE}.txt"
APPSPWD=`env|grep APPLPWD= |awk -F= '{print $2}'`

top -n1 -c > $REPORT


sqlplus -s <<!
APPS/$APPSPWD
set pagesize 24 echo off feed off linesize 130
col qname format a9  heading 'Manager' trunc
col sdate format a12 heading 'Start Time'
col reqid format 99999999 heading 'ReqID'
col concprog format a60 heading 'Concurrent Program Name'
col ospid format a12
col Username format a10


spool $REPORT

Select * from dual
/
spool off
exit
!


LINES=`cat $REPORT| wc -l`
if [ $LINES -gt 0 ]; then 

cat $REPORT | mail  "ALERT: 10 Programs in top on PROD."  $MAILLIST

fi



