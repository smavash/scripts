SET SERVEROUTPUT ON


DECLARE
  l_sql_tune_task_id  VARCHAR2(100);
BEGIN
  l_sql_tune_task_id := DBMS_SQLTUNE.create_tuning_task (
                          begin_snap  => 16128,
                          end_snap    => 16129,
                          sql_id      => '5ztbyrb46vfbr',
                          scope       => DBMS_SQLTUNE.scope_comprehensive,
                          time_limit  => 60,
                          task_name   => '5ztbyrb46vfbr_AWR_tuning_task',
                          description => 'Tuning task for statement 5ztbyrb46vfbr in PROD AWR.');
  DBMS_OUTPUT.put_line('l_sql_tune_task_id: ' || l_sql_tune_task_id); END; 
/
