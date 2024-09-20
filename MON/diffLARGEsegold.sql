-- Intersect 
 col ts for a20
 col owner for a12
 col segm for a30
 col type for a12  
 set lin 200 pages 600
select  s.tablespace_name ts,
       s.owner,
       s.segment_name segm,s.segment_type type,round(s.BYTES / 1024 / 1024) sz from dba_segments s 
       where  /*s.segment_type in ('INDEX', 'TABLE') and*/ s.BYTES / 1024 / 1024 > 500
minus
select  t.* 
from xxdba_large_segs_tbl@TO_PTCH.TNUVA.CO.IL t;
