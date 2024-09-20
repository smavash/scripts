select t1.begin_interval_time,fs.readtim * 10 / fs.phyrds
   from dba_hist_filestatxs fs,
     dba_hist_snapshot t1
  where 
  --filename like '%a_txn_data%.dbf'
    t1.snap_id=fs.snap_id
  order by t1.snap_id desc;
  
  
select t2.begin_interval_time,t1.begin_interval_time,s1.event_name,(s1.total_waits-s2.total_waits),
       (s1.total_timeouts-s2.total_timeouts),
       (s1.time_waited_micro-s2.time_waited_micro),
       round((s1.time_waited_micro-s2.time_waited_micro)/(s1.total_waits-s2.total_waits)/1000,2) "Avg time"
 from dba_hist_system_event s1,
      dba_hist_snapshot t1,
      dba_hist_system_event s2,
      dba_hist_snapshot t2
where  t1.snap_id=t2.snap_id+1
  and s1.event_name=s2.event_name
  and s1.snap_id=t1.snap_id
  and s2.snap_id=t2.snap_id
--  and s1.event_name='db file sequential read'--'buffer busy waits'--'db file sequential read'
  and (s1.total_waits-s2.total_waits)> 0
--  and t1.snap_time> '31-dec-2009'
order by t1.begin_interval_time desc ;              



select ddf.file_name,
       round(ddf.bytes/1024/1024/1024) "Size Gb",
       round(fs.readtim * 10 / fs.PHYRDS,2) "R Time",
       round(fs.SINGLEBLKRDTIM * 10 / fs.SINGLEBLKRDS,2) "R Time Single",
       round((1- fs.SINGLEBLKRDS/fs.PHYRDS)*100,2) "% Full Scan",
       fs.*
  from v$filestat fs, dba_data_files ddf
 where fs.FILE# = ddf.file_id
 order by fs.phyrds desc;
