set lines 125
col report for a125
set serveroutput on size 999999
set long 999999
exec dbms_sqltune.execute_tuning_task ('78yghw50c7rtq_AWR_tuning_task');

spool xxhp1_advise

select dbms_sqltune.report_tuning_task ('78yghw50c7rtq_AWR_tuning_task') report from dual;

spool off
