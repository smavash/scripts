select v$sql.SQL_TEXT,
       sid,
       serial#,
       target,
       totalwork,
       sofar,
       ((elapsed_seconds * (totalwork - sofar)) / sofar) estimated_complition_time
  from (select sid,
               serial#,
               opname,
               target,
               sofar,
               totalwork,
               units,
               elapsed_seconds,
               message,
               START_TIME,
               SQL_ID
          from v$session_longops
          where START_TIME like sysdate
         order by start_time desc) sess,v$sql
where totalwork <> sofar
and sess.SQL_ID = v$sql.sql_id
;


select  RPAD(opname,10,' '),RPAD('Case '||target||
' had been processed',35,' ') Amessage,
RPAD(sofar||' of '||totalwork||' cases done',25,' ') Bmessage,
RPAD(totalwork-sofar||' cases left',16, ' ') Cmessage
from v$session_longops l, v$session s
where l.sid=s.sid and l.serial# = s.serial#
and time_remaining > 0
;

select b.*,((elapsed_seconds * (totalwork - sofar)) / sofar) estimated_complition_time
  from v$session a, v$session_longops b
 where a.sid = b.sid
   and a.serial# = b.serial#
  ; 
   

Select substr(sql_text,14,instr(sql_text,'(')-16) table_name, 
       rows_processed, 
       round((sysdate
              - to_date(first_load_time,'yyyy-mm-dd hh24:mi:ss'))
             *24*60, 1) minutes, 
       trunc(rows_processed / 
                ((sysdate-to_date(first_load_time,'yyyy-mm-dd hh24:mi:ss'))
             *24*60)) rows_per_min 
from v$sqlarea 
where 
--upper(sql_text) like 'INSERT INTO "%' 
  --and command_type = 2 
   open_versions > 0;






