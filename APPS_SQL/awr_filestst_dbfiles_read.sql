select begin_interval_time, filename, phyrds
  from dba_hist_filestatxs natural
  join dba_hist_snapshot
 order by begin_interval_time;