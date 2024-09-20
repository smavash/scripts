create table xxdba_large_segs_tbl tablespace XXCUST  
as (select  s.tablespace_name ts,
       s.owner,
       s.segment_name segm,s.segment_type type, 
       round(sum(s.BYTES) / 1024 / 1024)BYTES
       from dba_segments s 
       where /*s.segment_type in ('INDEX', 'TABLE') and*/ s.BYTES / 1024 / 1024 > 500  
       and   s.tablespace_name not like '%UNDO%'  
       group by s.tablespace_name ,
       s.owner,s.segment_type ,s.segment_name)
     
