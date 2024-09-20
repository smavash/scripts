#!/bin/bash 

. ~/.profile

MAILLIST=dl-oradba@tnuva.co.il

DATE=`date +"%d-%b-%Y-%H%M"`
ALL_REPORTS="/tmp"
APPSPWD=`env|grep APPLPWD= |awk -F= '{print $2}'`

INVALIDS_CNT=`sqlplus -s apps/$APPSPWD << EOF
set timing off echo off feed off verify off head off pages 0 term on line 1000 serveroutput on
select count(*) from dba_objects where status <> 'VALID';
EOF`




if [ "$INVALIDS_CNT" -gt 20 ]; then 

 
 sqlplus -s APPS/$APPLPWD @$AD_TOP/sql/adutlrcmp.sql APPLSYS $APPLPWD APPS $APPLPWD tnvmgr 2  0 NONE FALSE > /tmp/inv.lst
 cat  /tmp/inv.lst| mailx -s  "ALERT: Total number of invalid objects exceeded 20 in $TWO_TASK. " $MAILLIST
 logger -t ERP -p user.err -i "##### ALERT: Total number of invalids is unnormal in $TWO_TASK. Please call DBA Team Leader ######## "
fi

