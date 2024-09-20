#!/bin/bash 

. ~/.profile

MAIL_USERS=amith@eds.co.il,anatolyr@eds.co.il

RESPOND_COUNT=`sqlplus -s "apps/\$APPLPWD@\$TWO_TASK"<<EOF
set timing off echo off feed off verify off head off pages 0 term on
select count(*)
from   wf_notifications a
where  a.responder like 'email:%@%'
and    a.end_date  > sysdate - 1/24*5;
exit;
EOF`
if [ $RESPOND_COUNT -eq 0 ];then
      ##echo "ERP Workflow Mailer probably has a problem with respond process"
      echo "ERP Workflow Mailer probably has a problem with respond process. If the problem persist, Restart ERP Workflow Mailer Immediate "|mailx -s "ERP WF Mailer Respond Process" $MAIL_USERS
fi

