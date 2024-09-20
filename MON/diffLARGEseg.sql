--UAT

-- Intersect 
 col ts for a20
 col owner for a12
 col segm for a30
 col type for a23  
 set lin 200 pages 600

select s.ts,
       s.owner,
       s.segm,
       s.type,
       s.BYTES - NVL(ptch.BYTES, 0) "DeltaSz",
       s.BYTES "ProdSz",
       ptch.BYTES "ClonEnvSz",
       sum(s.BYTES) over(partition by 1) "prodSUM",
       sum(ptch.BYTES) over(partition by 1) "ClonEnvSUM"
  from (select s.tablespace_name ts,
                s.owner,
                s.segment_name segm,
                s.segment_type type,
                round(sum(s.BYTES) / 1024 / 1024) BYTES
           from dba_segments s
          where /*s.segment_type in ('INDEX', 'TABLE') and*/
          s.BYTES / 1024 / 1024 > 500
       and s.tablespace_name not like '%UNDO%'
          group by s.tablespace_name, s.owner, s.segment_type, s.segment_name) s,
       xxdba_large_segs_tbl@TO_UAT.TNUVA.CO.IL ptch
 where s.ts = ptch.ts
   and s.owner = ptch.owner
   and s.type = ptch.type
   and s.segm = ptch.segm
   and s.BYTES != ptch.BYTES
    order by 5 desc;
  
