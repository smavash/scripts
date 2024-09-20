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


