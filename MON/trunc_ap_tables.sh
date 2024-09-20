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

TRUNCATE TABLE zx.ZX_REP_ACTG_EXT_T;
TRUNCATE TABLE zx.ZX_REP_TRX_JX_EXT_T;
TRUNCATE TABLE zx.ZX_REP_TRX_DETAIL_T;
TRUNCATE TABLE zx.ZX_REP_CONTEXT_T;



exit
!



echo ""
echo ""
echo "Status as of `date`"
echo ""

