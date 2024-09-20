#!/bin/bash
#set -x
   
. ~/.profile

MAILLIST=anatolyr@eds.co.il,amith@eds.co.il
REPORT=/tmp/old_trans.log

DATE=`date +"%d-%b-%Y-%H%M"`

sqlplus -s apps/$APPLPWD <<EOF
set pagesize 24 echo off feed off linesize 130
set serveroutput on size 1000000
spool $REPORT

exec XXHA_CHECK_FOR_LOCKS.Old_Transactions;
spool off
exit
EOF

LINES=`cat $REPORT| wc -l`
if [ $LINES -gt 1 ]; then 
echo "Send eMail"

#cat $REPORT | mail  -s "ALERT: DASH TO EREZ ZILKA."  $MAILLIST
uuencode $REPORT load_avrg.txt|mail  -s "24 Hours old Transactions" $MAILLIST


fi



