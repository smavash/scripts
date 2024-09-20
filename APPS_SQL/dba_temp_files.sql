select (s.tot_used_blocks / f.total_blocks) * 100 as "percent used"
  from (select sum(used_blocks) tot_used_blocks
          from v$sort_segment
         where tablespace_name like 'TEMP1') s,
       (select sum(blocks) total_blocks
          from dba_temp_files
         where tablespace_name like 'TEMP1') f;

SELECT a.sid
  FROM v$session a, v$sort_usage b, v$sqlarea c
 WHERE a.saddr = b.session_addr
   AND c.address = a.sql_address
   AND c.hash_value = a.sql_hash_value
   and b.blocks > 700;

select * from v$sort_segment;

select * from dba_temp_files;


alter database tempfile '/oracle/BIAPPSTEST/11g/oradata/BIDWHTES/temp01.dbf' resize 32000m;