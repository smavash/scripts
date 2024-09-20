set lines 125
col report for a125
set serveroutput on size 999999
set long 999999

exec dbms_sqltune.execute_tuning_task ('bcqxs21kqdmu6_AWR_tuning_task');

spool xxhp1_bidwhp11_advise
select dbms_sqltune.report_tuning_task ('bcqxs21kqdmu6_AWR_tuning_task') report from dual;
spool off

