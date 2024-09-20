#!/bin/bash 

. ~/.bash_profile

#MAILLIST=anatolyr@eds.co.il,amith@eds.co.il,irinat@eds.co.il
MAILLIST=anatolyr@eds.co.il,orenc@eds.co.il,lilach.ashenberg@eds.co.il,amith@eds.co.il,sagits@eds.co.il,oferb@eds.co.il,dovratd@eds.co.il
#MAILLIST=anatolyr@eds.co.il

ISBLCKER=`sqlplus -s '/as sysdba' << EOF
set timing off echo off feed off verify off head off pages 0 term on
col tt for 99999
select COUNT(*) from dba_blockers
exit ;	
EOF`

## echo "ISBLCKER = $ISBLCKER"

if [ $ISBLCKER -gt 0 ]; then

    V=`sqlplus -s 'apps/snf_apps' << EOF
    set echo off termout off feedback off heading off verify off linesize 100 pagesize 0 serveroutput on size 1000000
    spool /u01_share/DBA/scripts/MON/locks_big.log
    exec XXHA_CHECK_FOR_LOCKS.Locks;
    spool off 
    exit;
    EOF`
    
    grep -v SQL /u01_share/DBA/scripts/MON/locks_big.log > /u01_share/DBA/scripts/MON/locks_big.txt
    unix2dos /u01_share/DBA/scripts/MON/locks_big.txt
    cat /u01_share/DBA/scripts/MON/locks_big.txt >> /u01_share/DBA/scripts/MON/locks_to_big_log.txt
fi
