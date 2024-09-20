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



exec fnd_stats.gather_table_stats('AR','AR_ADJUSTMENTS_ALL',percent=>90, cascade => TRUE );
exec fnd_stats.gather_table_stats('AR','AR_CASH_RECEIPTS_ALL',percent=>90, cascade => TRUE );
exec fnd_stats.gather_table_stats('AR','AR_CASH_RECEIPT_HISTORY_ALL',percent=>90, cascade => TRUE );
exec fnd_stats.gather_table_stats('AR','AR_DISTRIBUTIONS_ALL',percent=>90, cascade => TRUE );
exec fnd_stats.gather_table_stats('AR','AR_MISC_CASH_DISTRIBUTIONS_ALL',percent=>90, cascade => TRUE );
exec fnd_stats.gather_table_stats('AR','AR_RECEIVABLE_APPLICATIONS_ALL',percent=>90, cascade => TRUE );
exec fnd_stats.gather_table_stats('APPLSYS','FND_LOOKUP_VALUES',percent=>90, cascade => TRUE );
exec fnd_stats.gather_table_stats('GL','GL_CODE_COMBINATIONS',percent=>90, cascade => TRUE );
exec fnd_stats.gather_table_stats('AR','RA_CUSTOMER_TRX_ALL',percent=>90, cascade => TRUE );
exec fnd_stats.gather_table_stats('AR','RA_CUST_TRX_LINE_GL_DIST_ALL',percent=>90, cascade => TRUE );


exit
!



echo ""
echo ""
echo "Status as of `date`"
echo ""

