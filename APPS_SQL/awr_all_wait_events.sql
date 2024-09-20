  select
     event "Event Name",
     waits "Waits",
     timeouts "Timeouts",
     round(time) "Wait Time (s)",
     avgwait "Avg Wait (ms)",
     waitclass "Wait Class"
from
    (select e.event_name event
          , e.total_waits - nvl(b.total_waits,0)  waits
          , e.total_timeouts - nvl(b.total_timeouts,0) timeouts
          , (e.time_waited_micro - nvl(b.time_waited_micro,0))/1000000  time
          ,  decode ((e.total_waits - nvl(b.total_waits, 0)), 0, to_number(NULL),
            ((e.time_waited_micro - nvl(b.time_waited_micro,0))/1000) / (e.total_waits - nvl(b.total_waits,0)) ) avgwait
          , e.wait_class waitclass
     from
        dba_hist_system_event b ,
        dba_hist_system_event e
     where
                      b.snap_id(+)          = 29443 --&pBgnSnap 
                  and e.snap_id             = 29449 --&pEndSnap and 
                   and b.dbid(+)             = 120624187 --120624187 --&pDbId
                  and e.dbid                = 120624187 --120624187 --&pDbId
                  and b.instance_number(+)  = 1 --&pInstNum
                  and e.instance_number     = 1 --&pInstNum
                  and b.event_id(+)         = e.event_id
                  and e.total_waits         > nvl(b.total_waits,0)
                  and e.wait_class          <> 'Idle' )
order by time desc, waits desc
