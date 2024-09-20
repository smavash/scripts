#!/bin/bash -x

. .profile

MAILLIST=

DATE=`date +"%d-%b-%Y-%H%M"`

export SESS_HW=`sqlplus -s '/as sysdba'<<!
set timing off echo off feed off verify off head off pages 0 term on
select  trunc (100*(current_utilization/limit_value)) from v\\$resource_limit where resource_name = 'sessions';
exit
!`

if [ $SESS_HW -gt 60 ]; then 

	logger -t ORA-CKERP -p user.err -i "##### Alert:  Max Procees usage exxeded 60% ########"	
        echo  "#####  ALERT:  Max Procees usage exxeded $SESS_HW % in $ENVNAME.  ######## " |mailx  $MAILLIST

fi


if [ $SESS_HW -gt 90 ]; then

        logger -t ORA-CKERP -p user.err -i "##### Critical ALERT:  Max Procees usage exxeded 90% in PROD . Please Call DBA Team . ########"
        echo  "#####  ALERT:  Max Procees usage exxeded $SESS_HW % in $ENVNAME.  ######## " |mailx  $MAILLIST

fi


