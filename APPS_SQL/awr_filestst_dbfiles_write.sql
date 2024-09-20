select to_char(begin_interval_time, 'yyyy-mm-dd hh24:mi') snap_time,
       filename,
       phywrts
  from dba_hist_filestatxs natural
  join dba_hist_snapshot
 where phywrts > 0
   and phywrts * 4 > (select avg(value) all_phys_writes
                        from dba_hist_sysstat natural
                        join dba_hist_snapshot
                       where stat_name = 'physical writes'
                         and value > 0)
 order by to_char(begin_interval_time, 'yyyy-mm-dd hh24:mi'), phywrts desc;