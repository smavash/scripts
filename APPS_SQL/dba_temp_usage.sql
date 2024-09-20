select * from dba_temp_files;


SELECT b.tablespace,
       ROUND(((b.blocks*p.value)/1024/1024),2)||'M' "SIZE",
       a.sid||','||a.serial# SID_SERIAL,
      a.username,
       a.program
   FROM sys.v_$session a,
        sys.v_$sort_usage b,
         sys.v_$parameter p
   WHERE p.name  = 'db_block_size'
     AND a.saddr = b.session_addr
  ORDER BY b.tablespace, b.blocks; 

SELECT tablespace_name, SUM(bytes_used), SUM(bytes_free)
FROM   V$temp_space_header
GROUP  BY tablespace_name;


select s.username, u."USER", u.tablespace, u.contents, u.extents, u.blocks
from   sys.v_$session s, sys.v_$sort_usage u
where  s.saddr = u.session_addr
/

select s.osuser, s.process, s.username, s.serial#,
       sum(u.blocks)*vp.value/1024/1024 sort_size
from   sys.v_$session s, sys.v_$sort_usage u, sys.v_$parameter vp
where  s.saddr = u.session_addr
  and  vp.name = 'db_block_size'
--  and  s.osuser like '&1'
group  by s.osuser, s.process, s.username, s.serial#, vp.value;


select  s.sid, --s.osuser, s. process, 
        s.sql_id, tmp.segtype, 
       ((tmp.blocks*8)/1024)MB, tmp.tablespace
from  
       v$tempseg_usage tmp,  
       v$session s
where tmp.session_num=s.serial#
and segtype in ('HASH','SORT')
order by blocks desc;

