set lines 125
col report for a125
set serveroutput on size 999999
set long 999999
exec dbms_sqltune.execute_tuning_task ('5ztbyrb46vfbr_AWR_tuning_task');

spool 5ztbyrb46vfbr.lst

select dbms_sqltune.report_tuning_task ('5ztbyrb46vfbr_AWR_tuning_task') report from dual;

spool off
