#!/bin/bash 
#==============================================================
#    Check size of Linux FILE $XDO_TOP/temp/xdo.log
#
#    Created By          Date               Refrence
# ------------------   ----------  ----------------------------
#
#    Updated By          Date               Refrence
# ------------------   ----------  ----------------------------
#
#==============================================================

USERS=slava.m@unitask-inc.com


SIZE=`du -k $XDO_TOP/temp/xdo.log|awk '{print $1}'`

#echo SIZE=$SIZE

if [ $SIZE -gt 1048576 ]; then
   #echo "Size of $XDO_TOP/temp/xdo.log more then 1 GB !!!"
  echo "Size of $XDO_TOP/temp/xdo.log file more then 1 GB !!!"|mailx -s "Size of xdo.log file more then 1 GB !!!" $USERS
fi

#echo "End of Script"

