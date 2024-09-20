select 
--sum(bytes/1024/1024) Mb, segment_name,segment_type 
*
from dba_segments   ds
 where  
 --tablespace_name = 'XXTNVD'  
-- and segment_name like 'XXAR_INTERFACE_LINES_ALL_HIST%'  
-- and segment_type='TABLE'  
 --group by segment_name,segment_type order by 1 asc 
 
;




select sum(bytes/1024/1024) Mb, segment_name,segment_type from dba_segments  
 where  tablespace_name = 'SYSAUX'  
 and segment_name like '%OPT%'  
 and segment_type='INDEX'  
 group by segment_name,segment_type order by 1 asc  
;





select
        s.tablespace_name ts,s.owner,
        s.segment_name  segn,
        s.segment_type  type,
        --s.initial_extent init,
        --s.next_extent   next,
        --s.extents       exts,
        trunc(s.bytes/1024/1024) sz
from dba_segments s
where
--s.segment_name like  'XX%'
  (s.bytes/1024/1024) > 10000
--and s.tablespace_name != 'APPS_TS_TX_DATA'
--order by 1,7
;




select * from dba_tables dt
where dt.LAST_ANALYZED < TO_DATE('14-06-2013 00:00:00', 'DD-MM-YYYY HH24:MI:SS')
and dt.owner not in ('SYS', 'MDSYS', 'SYSTEM','XDB','SYS','MDSYS','SYSTEM','XDB','CTXSYS','OLAPSYS','ORDSYS', 'DBSNMP')

