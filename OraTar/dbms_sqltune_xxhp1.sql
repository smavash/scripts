SET SERVEROUTPUT ON

DECLARE

  l_sql_tune_task_id  VARCHAR2(100);
BEGIN
  l_sql_tune_task_id := DBMS_SQLTUNE.create_tuning_task (
                          begin_snap  => 53343, 
                          end_snap    => 53347,
                          sql_id      => 'bcqxs21kqdmu6',
                          scope       => DBMS_SQLTUNE.scope_comprehensive,
                          time_limit  => 600,
                          task_name   => 'bcqxs21kqdmu6_AWR_tuning_task',
                          description => 'Tuning task bcqxs21kqdmu6 for statement  in BIDWHP11 AWR .');
  DBMS_OUTPUT.put_line('l_sql_tune_task_id: ' || l_sql_tune_task_id);
END;
/
