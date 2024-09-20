#!/bin/bash
#set -x

. /db/orainst/PROD/db/tech_st/11.1.0/PROD_uapdb1.env

USERS=anatolyr@eds.co.il,amith@eds.co.il

process=\$process
session=\$session

COUNT=`sqlplus -s '/as sysdba' << EOF
set echo off termout off feedback off heading off verify off 
select count(*)
from v$process p, v$session s
where p.addr = s.paddr 
and   s.USERNAME is not null
and   p.spid /* Unix PID */ in (SELECT fcr.oracle_process_id UNIX_PID												   
                                FROM   applsys.fnd_concurrent_requests fcr
                                WHERE  fcr.phase_code = 'C'
                                AND    fcr.status_code = 'X'
                                AND    fcr.oracle_process_id is not null
                                AND    fcr.actual_completion_date  > sysdate - 1/24*2
                                ) ;
exit
EOF`

if [ $COUNT -eq 0 ]; then
  echo "There are no Terminated concurrent requests in the DB" 
  exit 0
fi 


sqlplus -s '/as sysdba' << EOF > /tmp/check_term_conc.log 2>&1
set echo off termout off feedback off heading off verify off linesize 250
select 'Unix PID ='||p.spid||'; Alter system kill session '||''''||s.sid||','|| s.serial#||''''||'; Module: '||S.MODULE||' ; Program: '||s.program||chr(10) STR
from v$process p, v$session s
where p.addr = s.paddr 
and   s.USERNAME is not null
and   p.spid /* Unix PID */ in (SELECT fcr.oracle_process_id UNIX_PID												   
                                FROM   applsys.fnd_concurrent_requests fcr
                                WHERE  fcr.phase_code = 'C'
                                AND    fcr.status_code = 'X'
                                AND    fcr.oracle_process_id is not null
                                AND    fcr.actual_completion_date  > sysdate - 1/24*2
                                );
exit 
EOF

cat /tmp/check_term_conc.log | mailx -s "Terminated concurrent requests are running in the DB of ERP PROD !!!" $USERS

### rm /tmp/check_term_conc.log

