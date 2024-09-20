#!/bin/ksh 



export DATE=`date +"%d-%b-%Y-%H%M"`

sqlplus '/as sysdba'<<EOF 


set pagesize 2000
set linesize 140
col instart_fmt noprint;
col inst_name format a12 heading 'Instance';
col db_name format a12 heading 'DB Name';
col snap_id format 99999990 heading 'Snap Id';
col snapdat format a18 heading 'Snap Started' just c;
col lvl format 99 heading 'Snap|Level';
set heading on;
break on inst_name on db_name on host on instart_fmt skip 1;
ttitle off;


spool /u01_share/DBA/awr_htm_$DATE.html;



select output
  from table(dbms_workload_repository.awr_report_html(l_dbid     => 1454872049,
                                                      l_inst_num => 1,
                                                      l_bid      => 48350,
                                                      l_eid      => 48406 ))
/

--from table(dbms_workload_repository.awr_report_html(l_dbid     => 120624187,
--                                                  l_inst_num => 1,
--                                                l_bid      => 29489,
--                                              l_eid      => 29491 ))

spool off;

exit





EOF
