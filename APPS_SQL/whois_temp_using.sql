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
group  by s.osuser, s.process, s.username, s.serial#, vp.value
/
