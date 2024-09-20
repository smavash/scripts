#!/bin/ksh

echo "Top 10 forms PID by CPU usage report... "
echo ""
echo "---------------------------------------------------"
echo ""
ps -eo pid,pcpu,comm | sort -n -k2 | grep 'frmweb'|tail -10|awk '{ORS="% "; system("pwdx " $1); print $2}'
echo ""
echo "---------------------------------------------------"
echo ""

sqlplus -s <<EOF
APPS/apps

set verify off
set linesize 140
col "Local user" form a10
col "Local pid"  form a8 heading "Local|pid"
col "Remote pid" form a8 heading "Remote|pid"
col "MACHINE" form a8
col "Oracle user" form a16
col "Remote PROGRAM" form a60 word wrap
col "Sid,Ser#" form a12
col "User Name" form a10
col "Resp Name" form a15
col "Form Name" form a30
col "frmweb PID" form a10
col "frmweb HOST" form a15

col "DB name" form a20

select value "DB name"
from v\$parameter
where name='db_name'
/

select s.sid||','||s.serial# "Sid,Ser#" ,
       p.username "Local user",p.spid "Local pid",s.PROCESS "Remote pid",
       MACHINE "MACHINE",
       s.username "Oracle user",
/* p.PROGRAM "Current PROGRAM", */
s.PROGRAM || ' ' || s.MODULE "Remote PROGRAM"
from v\$process p ,v\$session s
where p.addr=s.paddr
and s.PROGRAM like 'sqlplus%'
/

def Ospid=$1

select s.sid||','||s.serial# "Sid,Ser#",
       p.username "Local user",p.spid "Local pid",s.PROCESS "Remote pid",
       MACHINE "MACHINE",
       s.username "Oracle user",
/* p.PROGRAM "Current PROGRAM", */
s.PROGRAM || ' ' || s.MODULE "Remote PROGRAM"
from v\$process p ,v\$session s
where p.addr=s.paddr
and (p.spid = To_char(&&Ospid) or s.PROCESS = To_char(&&Ospid))
/





SELECT L.USER_ID
      ,S.SID
      ,S.SERIAL#
      ,USR.USER_NAME  "User Name"
    --  ,RSP.RESPONSIBILITY_NAME "Resp Name"
      ,FRM.USER_FORM_NAME "Form Name"
      ,S.PROCESS            "frmweb PID" 
      ,S.MACHINE            "frmweb HOST"
      ,NVL(F.START_TIME, NVL(R.START_TIME, L.START_TIME))           Logon_Time
  FROM FND_RESPONSIBILITY_TL RSP
      ,FND_FORM_TL          FRM
      ,FND_USER             USR
      ,FND_LOGINS           L
      ,FND_LOGIN_RESPONSIBILITIES R
      ,FND_LOGIN_RESP_FORMS F
      ,GV\$SESSION           S
      ,FND_OAM_FORMS_RTI    RTI
      ,FND_OAM_FRD_LOG      FRD
WHERE 
       R.LOGIN_ID = F.LOGIN_ID
   AND R.LOGIN_RESP_ID = F.LOGIN_RESP_ID
   AND L.LOGIN_ID = R.LOGIN_ID
   AND L.END_TIME IS NULL
   AND R.END_TIME IS NULL
   AND F.END_TIME IS NULL
   AND L.USER_ID = USR.USER_ID
   AND R.RESPONSIBILITY_ID = RSP.RESPONSIBILITY_ID
   AND R.RESP_APPL_ID = RSP.APPLICATION_ID
   AND RSP.LANGUAGE = 'US'--USERENV('LANG')
   AND F.FORM_ID = FRM.FORM_ID
   AND F.FORM_APPL_ID = FRM.APPLICATION_ID
   AND FRM.LANGUAGE = 'US'--USERENV('LANG')
   AND F.AUDSID = S.AUDSID 
   AND RTI.PID (+)= S.PROCESS 
   AND FRD.RTI_ID (+)=RTI.RTI_ID
   AND S.SID in (
		select distinct s.sid
		from v\$process p ,v\$session s
		where p.addr=s.paddr
		and (p.spid = To_char(&&Ospid) or s.PROCESS = To_char(&&Ospid))
)
/




exit

EOF
