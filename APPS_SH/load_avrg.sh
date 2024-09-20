#!/bin/bash
#set -x
   
. ~/.profile

#PASSWD=$1
#MAILLIST=
REPORT=/tmp/load_avrg.log

DATE=`date +"%d-%b-%Y-%H%M"`

LA=`uptime|awk '{print $10}'`
LA=`echo $LA|sed s/,//g`

echo $LA

COMP=`x=$LA; y=15; echo "$x $y" | awk '{if ($1 > $2) print "BOLSHE"; else print "MENSHE"}'`
echo "COMP = $COMP"

if [ $COMP == "MENSHE" ]; then
    echo "The Server Under 15% Load Average"
    exit 0
else 
    echo "The Server Above 15% Load Average"
fi

PID=`ps -ef|grep -v TTY|grep -v TIME|grep -v CMD|grep oraprd|awk '{printf "%10s * %10s * %5s \n",$1,$2,$4,$5,$7,$8}'|sort -t "*" -k 3 -n -r|awk '{print $3}'|head -3`
echo PID=$PID

PID=`echo $PID`

#sqlplus -s apps/$PASSWD <<EOF
sqlplus -s apps/$APPLPWD <<EOF
set pagesize 24 echo off feed off linesize 130
set serveroutput on size 1000000
spool $REPORT

exec XXHA_CHECK_FOR_LOCKS.Session_Info('$PID')
spool off
exit
EOF

LINES=`cat $REPORT| wc -l`
if [ $LINES -gt 0 ]; then 
echo "Send eMail"

#cat $REPORT | mail  -s "ALERT: DASH TO EREZ ZILKA."  $MAILLIST
uuencode $REPORT load_avrg.doc|mail  -s "Heavy Load Avrg on ERP DB is $LA%" $MAILLIST


fi



