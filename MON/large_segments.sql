select
        s.tablespace_name ts,
        s.segment_name  segn,
        s.segment_type  type,
        s.initial_extent init,
        s.next_extent   next,
        s.extents       exts,
        trunc(s.bytes/1024/1024) sz
from dba_segments s
where
(s.bytes/1024/1024) > 1000
order by 1,7
;
