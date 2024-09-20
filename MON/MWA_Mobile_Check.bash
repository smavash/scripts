#!/bin/bash 
#==============================================================
#    Monitor Oracle IMAP Workflow Notification Services
#
#    Created By          Date               Refrence
# ------------------   ----------  ----------------------------
#
#    Updated By          Date               Refrence
# ------------------   ----------  ----------------------------
#
#==============================================================

COUNT=`ps -ef|grep mwa|grep 22222|grep -v grep|wc -l`

#echo $COUNT

if [ $COUNT -eq 0 ]; then
    echo "Mobile listener of port 22222 doesn't running !"
    logger -t ORA_CKERP -p user.err -i "Mobile listener of port 22222 doesn't running on ulmutap01 server, call Oracle DBA ..."
else
    echo "Mobile listener of port 22222 work properly"
fi

echo "Test MWA port 22222 connection done "

