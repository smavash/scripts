#!/bin/bash  


. ~/.bash_profile

ISBLCKER=`sqlplus -s '/as sysdba' << EOF
set timing off echo off feed off verify off head off pages 0 term on
--select count(*) from dba_blockers;
select ctime from v\\$lock Where sid in (select * from dba_blockers) and block > 0;
exit ;	
EOF`

echo "ISBLCKER = $ISBLCKER"

      if [ $ISBLCKER -gt 600 ]; then

	INSTANCE=`sqlplus -s '/as sysdba' << EOF
	set echo off termout off feedback off heading off verify off linesize 100 pagesize 0
	select 'instance '||upper(instance_name)||' running on '||upper(host_name)||' server !!!' as text
	from v\\$instance;
	exit;
	EOF`

 	### echo  "##### ALERT: BLOCKED session  in $ENVNAME.  ######## " |mailx -s "ALERT: BLOCKED session  in $ENVNAME." slava.mavashev@tnuva.co.il
       logger -t ORA_CKERP -p user.err -i "##### BLOCKED session  exist in $INSTANCE. Please call to Oracle DBA ######## "
      fi

