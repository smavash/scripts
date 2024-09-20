#!/bin/ksh 



export DATE=`date +"%d-%b-%Y-%H%M"`

sqlplus '/as sysdba'<<EOF 



spool /u01_share/DBA/awr_SQLID_$DATE.html;

set pagesize 0
set linesize 121
col instart_fmt noprint;
col inst_name format a12 heading 'Instance';
col db_name format a12 heading 'DB Name';
col snap_id format 99999990 heading 'Snap Id';
col snapdat format a18 heading 'Snap Started' just c;
col lvl format 99 heading 'Snap|Level';
set heading on;
break on inst_name on db_name on host on instart_fmt skip 1;
ttitle off;



select output
  -- ERP -- from table(dbms_workload_repository.AWR_SQL_REPORT_HTML(120624187,1,30185,30188,'&id'))
  from table(dbms_workload_repository.AWR_SQL_REPORT_HTML(1454872049,1,48350,48354,'&id'))
/




spool off;

exit





EOF
