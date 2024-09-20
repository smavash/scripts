select to_char(sysdate ,'DD-MON-YY HH24:MI') "DATE" from dual;

SELECT NAME, BLOCK_SIZE, SUM(BUFFERS)
  FROM V$BUFFER_POOL
 GROUP BY NAME, BLOCK_SIZE
 HAVING SUM(BUFFERS) > 0;

SELECT o.object_name, COUNT(1) number_of_blocks
  FROM DBA_OBJECTS o, V$BH bh
 WHERE o.object_id  = bh.objd
   AND o.owner     != 'SYS'
 GROUP BY o.object_name
 ORDER BY count(1) desc;

