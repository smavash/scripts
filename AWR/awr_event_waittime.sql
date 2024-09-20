SELECT a.snap_id,
       to_char(b.begin_interval_time, 'yyyy-mm-dd hh24:mi:ss') snap_time,
       a.stat_name,
       round((a.value - lag(a.value)
              over(partition BY a.stat_name ORDER BY a.stat_name, a.snap_id)) / 3600) "redo size byes/per second"
  FROM dba_hist_sysstat a, dba_hist_snapshot b
 WHERE a.stat_name LIKE '%redo size%'
   AND a.instance_number = 1
   AND a.snap_id = b.snap_id
   AND a.instance_number = b.instance_number
   and b.begin_interval_time >  TO_DATE('10-01-2012 17:00:00', 'DD-MM-YYYY HH24:MI:SS')
 ORDER BY a.snap_id;
 
 
 
 
SELECT a.instance_number,
       to_char(b.begin_interval_time, 'yyyy-mm-dd hh24:mi:ss') snap_time,
       event_name,
       wait_class,
       TOTAL_WAITS - lag(TOTAL_WAITS) over(partition BY event_name ORDER BY event_name, a.snap_id) waits,
       TIME_WAITED_MICRO - lag(TIME_WAITED_MICRO) over(partition BY event_name ORDER BY event_name, a.snap_id) wait_time,
       round((TIME_WAITED_MICRO - lag(TIME_WAITED_MICRO)
              over(partition BY event_name ORDER BY event_name, a.snap_id)) /
             (TOTAL_WAITS - lag(TOTAL_WAITS)
              over(partition BY event_name ORDER BY event_name, a.snap_id)) / 1000) "Avg wait Time(ms)"
  FROM dba_hist_system_event a, dba_hist_snapshot b
 WHERE event_name IN ('log file sync',
                      'log file parallel write',
                      'db file parallel write',
                      'control file parallel write')
 AND a.instance_number = 1
   AND a.snap_id = b.snap_id
   AND a.instance_number = b.instance_number
   and b.begin_interval_time >  TO_DATE('10-01-2012 15:00:00', 'DD-MM-YYYY HH24:MI:SS')
      and b.begin_interval_time <  TO_DATE('11-01-2012 1:00:00', 'DD-MM-YYYY HH24:MI:SS')
 ORDER BY event_name, a.snap_id
