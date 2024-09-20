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


execute dbms_stats.gather_schema_stats('XXTNV',cascade=>TRUE,degree=>10);

exit
!



echo ""
echo ""
echo "Status as of `date`"
echo ""

