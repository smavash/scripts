#!/bin/bash 
#==============================================================
#    Check if Statistics failed on ERP
#
#    Created By          Date               Refrence
# ------------------   ----------  ----------------------------
#	Slava Mavashev
#
#    Updated By          Date               Refrence
# ------------------   ----------  ----------------------------
#
#==============================================================

USERS=slava.m@unitask-inc.com



WITHOUT_STATS_COUNT=`sqlplus -s '/as sysdba' <<EOF
set timing off echo off feed off verify off head off pages 0 term on
Select fcrt.status_code FROM APPS.fnd_concurrent_requests fcrt, APPS.fnd_concurrent_programs fcp
WHERE fcrt.concurrent_program_id = fcp.concurrent_program_id and fcp.concurrent_program_name = 'FNDGSCST' and fcrt.actual_completion_date >= trunc(sysdate) - 1;

exit ;	
EOF`

echo "WITHOUT_STATS_COUNT='$WITHOUT_STATS_COUNT'"

      if [ "$WITHOUT_STATS_COUNT" != "C" ]; then
 	     echo  "Statistics of ERP are OLDER then 1 days  "|mailx -s "ERP DB Statistics" $USERS
 
      fi

