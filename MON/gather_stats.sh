#!/usr/bin/ksh


#==============================================================
#    Monitor Oracle Workflow Services
#
#    Created By          Date               Refrence
# ------------------   ----------  ----------------------------
# Slava Mavashev       31/08/2010      Initial Creation  
#
#    Updated By          Date               Refrence
# ------------------   ----------  ----------------------------
#
#==============================================================

#-- 1 --  Initialize 
#--------------------------------------
. ~/.profile



DATE=`date +"%d-%b-%Y-%H%M"`
ALL_REPORTS="/tmp"
APPSPWD=`env|grep APPLPWD= |awk -F= '{print $2}'`

sqlplus -s <<!
APPS/$APPSPWD


exec DBMS_STATS.GATHER_TABLE_STATS(OWNNAME => 'XXTNV', TABNAME => 'XXAR_INTERFACE_LINES_ALL_HIST',CASCADE  =>  TRUE, METHOD_OPT =>  'FOR COLUMNS SIZE AUTO');

exec DBMS_STATS.GATHER_TABLE_STATS(OWNNAME => 'XXTNV', TABNAME => 'XXAR_INTERFACE_LINES_TEMP_HIST',CASCADE  =>  TRUE, METHOD_OPT =>  'FOR COLUMNS SIZE AUTO');


exit
!



echo ""
echo ""
echo "Status as of `date`"
echo ""

