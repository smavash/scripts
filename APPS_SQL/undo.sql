select max(maxquerylen) from v$undostat;


select inst_id,
       to_char(begin_time, 'MM/DD/YYYY HH24:MI') begin_time,
       UNXPSTEALCNT,
       EXPSTEALCNT,
       SSOLDERRCNT,
       NOSPACEERRCNT,
       MAXQUERYLEN
  from gv$undostat
 where begin_time between to_date('8/08/2013 15:00', 'MM/DD/YYYY HH24:MI') and
       to_date('8/08/2013 17:00', 'MM/DD/YYYY HH24:MI')
 order by inst_id,  begin_time desc;





;


SELECT (SUM(undoblks))/ SUM ((end_time - begin_time) * 7000)
FROM v$undostat
where BEGIN_TIME > sysdate - 1;


SELECT (UR * (UPS * DBS)) + (DBS * 24) AS "Bytes"
  FROM (SELECT value AS UR FROM v$parameter WHERE name = 'undo_retention'),
       (SELECT (SUM(undoblks) / SUM(((end_time - begin_time) * 6000*7))) AS UPS
          FROM v$undostat where BEGIN_TIME > sysdate - 1),
       (select block_size as DBS
          from dba_tablespaces
         where tablespace_name =
               (select upper(value)
                  from v$parameter
                 where name = 'undo_tablespace'));

select 
to_char( ust.BEGIN_TIME ,'yyyy-mm-dd HH24:MI')   as time ,
ust.UNDOBLKS,ust.EXPBLKREUCNT,
ust.UNXPSTEALCNT,  ust.SSOLDERRCNT ,ust.MAXQUERYLEN
from v$undostat ust
where ust.BEGIN_TIME > sysdate - 30
order by 1 desc;


  SELECT d.undo_size/(1024*1024) "ACTUAL UNDO SIZE [MByte]",
       SUBSTR(e.value,1,25) "UNDO RETENTION [Sec]",
       ROUND((d.undo_size / (to_number(f.value) *
       g.undo_block_per_sec))) "OPTIMAL UNDO RETENTION [Sec]"
  FROM (
       SELECT SUM(a.bytes) undo_size
          FROM v$datafile a,
               v$tablespace b,
               dba_tablespaces c
         WHERE c.contents = 'UNDO'
           AND c.status = 'ONLINE'
           AND b.name = c.tablespace_name
           AND a.ts# = b.ts#
       ) d,
       v$parameter e,
       v$parameter f,
       (
       SELECT MAX(undoblks/((end_time-begin_time)*6000*24))
              undo_block_per_sec
         FROM v$undostat
       ) g
WHERE e.name = 'undo_retention'
  AND f.name = 'db_block_size';
  
  
  

SELECT d.undo_size/(1024*1024) "ACTUAL UNDO SIZE [MByte]",
       SUBSTR(e.value,1,25) "UNDO RETENTION [Sec]",
       (TO_NUMBER(e.value) * TO_NUMBER(f.value) *
       g.undo_block_per_sec) / (1024*1024) 
       "NEEDED UNDO SIZE [MByte]"
  FROM (
       SELECT SUM(a.bytes) undo_size
         FROM v$datafile a,
              v$tablespace b,
              dba_tablespaces c
        WHERE c.contents = 'UNDO'
          AND c.status = 'ONLINE'
          AND b.name = c.tablespace_name
          AND a.ts# = b.ts#
       ) d,
       v$parameter e,
       v$parameter f,
       (
       SELECT MAX(undoblks/((end_time-begin_time)*6000*24))
          undo_block_per_sec
         FROM v$undostat
       ) g
 WHERE e.name = 'undo_retention'
  AND f.name = 'db_block_size';


