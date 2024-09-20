SELECT snap_interval, retention, most_recent_purge_time 
FROM sys.wrm$_wr_control;

exec dbms_workload_repository.awr_set_report_thresholds(top_n_sql=>100,top_n_sql_max=>100);

execute dbms_workload_repository.modify_snapshot_settings(interval => 10);


/*
select output
  from table(dbms_workload_repository.awr_sql_report_html .awr_report_html(l_dbid     => 120624187,
                                                      l_inst_num => 1,
                                                      l_bid      => 29443,
                                                      l_eid      => 29449))
*/
select output
  from table(dbms_workload_repository.AWR_SQL_REPORT_HTML(120624187,1,29443,29449,'&id'))

