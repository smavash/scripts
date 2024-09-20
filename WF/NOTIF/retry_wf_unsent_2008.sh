#!/usr/bin/ksh 

. ~/.profile
. /u002/app/applmgr/${ENVNAME}appl/APPS${ENVNAME}.env

###DATE=`date +"%d-%b-%Y-%H%M"`
DATE=`date +"%d-%b-%Y"`
ALL_REPORTS="/tmp"
REPORT="${ALL_REPORTS}/ALL_unsent_nids_${DATE}.txt"
export NID_DATA_DIR="/db_appl/dba_stuff/dba/WorkFlow11i/NOTIF"




sqlplus -s apps/$APPLPWD << EOF

set linesize 140 pagesize 9999 head on feed off 

col notification_id format 9999999 heading "NID"
col message_type format a10
col context format a10
col subject format a20
col priority format 999
col from_user format a12
col to_user format a12
col start_date format a19

spool ${REPORT}

select 
notification_id,
TO_char( begin_date,'DD-MM-YY HH24:MI:SS') start_date ,
message_type,
context,
subject,
priority,
status,
mail_status,
to_user
from wf_notifications wfn
where 
mail_status <>  'SENT' 
and  status = 'OPEN'
and message_type = 'WFERROR'
and begin_date >TO_DATE( '04-06-2008 14:50:00', 'DD-MM-YYYY HH24:MI:SS')
order by begin_date
/
exit
EOF


export MIN_NID=`sqlplus -s apps/$APPLPWD << EOF
set timing off echo off feed off verify off head off pages 0 term on line 10000
select
min(notification_id)
from wf_notifications wfn
where
mail_status <>  'SENT'
and  status = 'OPEN'
and message_type = 'WFERROR'
and begin_date >TO_DATE( '04-06-2008 14:50:00', 'DD-MM-YYYY HH24:MI:SS')
order by begin_date
/
exit
EOF`


export MAX_NID=`sqlplus -s apps/$APPLPWD << EOF
set timing off echo off feed off verify off head off pages 0 term on line 10000
select
max (notification_id)
from wf_notifications wfn
where
mail_status <>  'SENT'
and  status = 'OPEN'
and message_type = 'WFERROR'
and begin_date >TO_DATE( '04-06-2008 14:50:00', 'DD-MM-YYYY HH24:MI:SS')
order by begin_date
/
exit
EOF`

echo "=============================================================================================="
echo "\nThe problem started with notification-id ='$MIN_NID'."
echo "\nThe problem ended with notification-id ='$MAX_NID'."

sqlplus -s apps/$APPLPWD << EOF
@$NID_DATA_DIR/bde_wf_notif.sql 
${MIN_NID}
/
exit
EOF

cd $NID_DATA_DIR/

cat $FND_TOP/patch/115/sql/wfntfqup_slava.sql | sed  "s/FIRSTTOSTART/${MAX_NID}/g" > wfntfqup_${DATE}.sql

echo "\nIMPORTANT!!!  Please review 2 reportis: "
echo "\n$NID_DATA_DIR/bde_wf_notif.lst \n${REPORT}"
echo "=============================================================================================="
echo "\n\nAnd, after review , please run manualy next command :"
echo "sqlplus apps/<apps_pwd> @$NID_DATA_DIR/wfntfqup_${DATE}.sql  apps <apps_pwd> applsys"
