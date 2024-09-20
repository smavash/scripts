#!/bin/bash  

#==============================================================
#    Check if we have Database Statistics GAP 
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
Select  count(*) From dba_tables Where LAST_ANALYZED < sysdate - 7 ;
exit ;	
EOF`
      if [ $WITHOUT_STATS_COUNT -gt 2000 ]; then
		echo  "Statistics of ERP are OLDER then 7 days  " |mailx -s "ERP DB Statistics" $USERS
      fi

