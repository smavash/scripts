-- You MUST connect as SYS to run this script
-- The query shown below utilizes the x$bh view to identify all the objects that reside in blocks averaging over five touches and occupying over twenty blocks in the cache.  It finds tables and indexes that are referenced frequently and are good candidates for inclusion in the KEEP pool.  

set pages 999
set lines 92
spool keep_syn.lst

drop table t1;
create table t1 as
select
   o.owner          owner,
   o.object_name    object_name,
   o.subobject_name subobject_name,
   o.object_type    object_type,
   count(distinct file# || block#)         num_blocks
from
   dba_objects  o,
   v$bh         bh
where
   o.data_object_id  = bh.objd
and
   o.owner not in ('SYS','SYSTEM')
and
   bh.status != 'free'
group by
   o.owner,
   o.object_name,
   o.subobject_name,
   o.object_type
order by
   count(distinct file# || block#) desc
;


select 'alter ' || s.segment_type || ' ' || t1.owner || '.' ||
       s.segment_name || ' storage (buffer_pool keep);'
  from t1, dba_segments s
 where s.segment_name = t1.object_name
   and s.owner = t1.owner
   and s.segment_type = t1.object_type
   and nvl(s.partition_name, '-') = nvl(t1.subobject_name, '-')
   and buffer_pool <> 'KEEP'
   and object_type in ('TABLE', 'INDEX')
 group by s.segment_type, t1.owner, s.segment_name
having(sum(num_blocks) / greatest(sum(blocks), .001)) * 100 > 80;

spool off
