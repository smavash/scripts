#!/bin/ksh

. ~/.bash_profile


DATE=`date +"%d-%b-%Y-%H%M"`
LOG_ALERT_DIR=$ORACLE_HOME/admin/PROD_uapdb1/diag/rdbms/prod/PROD/trace/


cd $LOG_ALERT_DIR
cp -p alert_PROD.log $LOG_ALERT_DIR/alert_PROD.log.$DATE  && cat /dev/null > alert_PROD.log
