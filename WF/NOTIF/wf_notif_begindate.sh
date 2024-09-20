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
col message_name format a15
col context format a10
col subject format a20
col RECIPIENT_ROLE format a13
col priority format 999
col to_user format a12
col start_date format a19

spool ${REPORT}

@/db_appl/dba_stuff/dba/WorkFlow11i/NOTIF/wf_notif_begindate.sql

spool off 
exit
EOF

