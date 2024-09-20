
spool plan.lst
 
set echo off
set feedback on
 
set pages 999;
column nbr_FTS  format 99,999
column num_rows format 999,999
column blocks   format 9,999
column owner    format a10;
column name     format a30;
column ch       format a1;
column time     heading "Snapshot Time"        format a15
 
column object_owner heading "Owner"            format a12;
column ct           heading "# of SQL selects" format 999,999;
 
break on time
 
select
   object_owner,
   count(*)   ct
from
   dba_hist_sql_plan
where
   object_owner is not null
group by
   object_owner
order by
   ct desc
;
 
 
--spool access.lst;
 
set heading on;
set feedback on;
 
ttitle 'full table scans and counts|  |The "K" indicates that the table is in the KEEP Pool (Oracle8).'
select
   to_char(sn.end_interval_time,'mm/dd/rr hh24') time,
   p.owner,
   p.name,
   t.num_rows,
--   ltrim(t.cache) ch,
   decode(t.buffer_pool,'KEEP','Y','DEFAULT','N') K,
   s.blocks blocks,
   sum(a.executions_delta  ) nbr_FTS
from
   dba_tables     t,
   dba_segments   s,
   dba_hist_sqlstat      a,
   dba_hist_snapshot sn,
   (select distinct
     pl.sql_id,
     object_owner owner,
     object_name name
   from
      dba_hist_sql_plan pl
   where
      operation = 'TABLE ACCESS'
      and
      options = 'FULL') p
where
   a.snap_id = sn.snap_id
   and
   a.sql_id = p.sql_id
   and
   t.owner = s.owner
   and
   t.table_name = s.segment_name
   and
   t.table_name = p.name
   and
   t.owner = p.owner
   and
   t.owner not in ('SYS','SYSTEM')
having
   sum(a.executions_delta  ) > 1
group by
   to_char(sn.end_interval_time,'mm/dd/rr hh24'),p.owner, p.name, t.num_rows, t.cache, t.buffer_pool, s.blocks
order by
   1 asc;
 
 
column nbr_RID  format 999,999,999
column num_rows format 999,999,999
column owner    format a15;
column name     format a25;
 
ttitle 'Table access by ROWID and counts'
select
   to_char(sn.end_interval_time,'mm/dd/rr hh24') time,
   p.owner,
   p.name,
   t.num_rows,
   sum(a.executions_delta  ) nbr_RID
from
   dba_tables   t,
   dba_hist_sqlstat      a,
   dba_hist_snapshot sn,
  (select distinct
     pl.sql_id,
     object_owner owner,
     object_name name
   from
      dba_hist_sql_plan pl
   where
      operation = 'TABLE ACCESS'
      and
      options = 'BY USER ROWID') p
where
   a.snap_id = sn.snap_id
   and
   a.sql_id = p.sql_id
   and
   t.table_name = p.name
   and
   t.owner = p.owner
having
   sum(a.executions_delta  ) > 9
group by
   to_char(sn.end_interval_time,'mm/dd/rr hh24'),p.owner, p.name, t.num_rows
order by
   1 asc;
 
--*************************************************
--  Index Report Section
--*************************************************
 
column nbr_scans  format 999,999,999
column num_rows   format 999,999,999
column tbl_blocks format 999,999,999
column owner      format a9;
column table_name format a20;
column index_name format a20;
 
ttitle 'Index full scans and counts'
select
   to_char(sn.end_interval_time,'mm/dd/rr hh24') time,
   p.owner,
   d.table_name,
   p.name index_name,
   seg.blocks tbl_blocks,
   sum(s.executions_delta  ) nbr_scans
from
   dba_segments   seg,
   dba_indexes   d,
   dba_hist_sqlstat      s,
   dba_hist_snapshot sn,
  (select distinct
     pl.sql_id,
     object_owner owner,
     object_name name
   from
      dba_hist_sql_plan pl
   where
      operation = 'INDEX'
      and
      options = 'FULL SCAN') p
where
   d.index_name = p.name
   and
   s.snap_id = sn.snap_id
   and
   s.sql_id = p.sql_id
   and
   d.table_name = seg.segment_name
   and
   seg.owner = p.owner
having
   sum(s.executions_delta  ) > 9
group by
   to_char(sn.end_interval_time,'mm/dd/rr hh24'),p.owner, d.table_name, p.name, seg.blocks
order by
   1 asc;
 
 
ttitle 'Index range scans and counts'
select
   to_char(sn.end_interval_time,'mm/dd/rr hh24') time,
   p.owner,
   d.table_name,
   p.name index_name,
   seg.blocks tbl_blocks,
   sum(s.executions_delta  ) nbr_scans
from
   dba_segments   seg,
   dba_hist_sqlstat      s,
   dba_hist_snapshot sn,
   dba_indexes   d,
  (select distinct
     pl.sql_id,
     object_owner owner,
     object_name name
   from
      dba_hist_sql_plan pl
   where
      operation = 'INDEX'
      and
      options = 'RANGE SCAN') p
where
   d.index_name = p.name
   and
   s.snap_id = sn.snap_id
   and
   s.sql_id = p.sql_id
   and
   d.table_name = seg.segment_name
   and
   seg.owner = p.owner
having
   sum(s.executions_delta  ) > 9
group by
   to_char(sn.end_interval_time,'mm/dd/rr hh24'),p.owner, d.table_name, p.name, seg.blocks
order by
   1 asc;
 
ttitle 'Index unique scans and counts'
select
   to_char(sn.end_interval_time,'mm/dd/rr hh24') time,
   p.owner,
   d.table_name,
   p.name index_name,
   sum(s.executions_delta  ) nbr_scans
from
   dba_hist_sqlstat      s,
   dba_hist_snapshot sn,
   dba_indexes   d,
  (select distinct
     pl.sql_id,
     object_owner owner,
     object_name name
   from
      dba_hist_sql_plan pl
   where
      operation = 'INDEX'
      and
      options = 'UNIQUE SCAN') p
where
   d.index_name = p.name
   and
   s.snap_id = sn.snap_id
   and
   s.sql_id = p.sql_id
having
   sum(s.executions_delta  ) > 9
group by
   to_char(sn.end_interval_time,'mm/dd/rr hh24'),p.owner, d.table_name, p.name
order by
   1 asc;
 
spool off
