set lines 100 pages 80
set linesize 140
col username format a15
col message format a80
col remaining format 9999
select	username
,	to_char(start_time, 'hh24:mi:ss dd/mm/yy') started
,	time_remaining remaining
,	message
from	v$session_longops
where	time_remaining != 0
order by time_remaining desc
/


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

