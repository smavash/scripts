
select * from v$archived_log
where first_time > TO_DATE('13-08-2011 06:00:00', 'DD-MM-YYYY HH24:MI:SS')
and first_time < TO_DATE('13-08-2011 12:00:00', 'DD-MM-YYYY HH24:MI:SS')
;


select v1.group#, v1.STATUS, member, sequence#, first_change#
  from v$log v1, v$logfile v2
 where v1.group# = v2.group#;
 
alter system switch logfile;



SELECT DECODE(archived, 'YES', 1, 0), status ,thread#, sequence#  FROM v$log 
--WHERE thread# = :ora_thread AND  sequence# = :ora_seq_no
; 
SELECT sequence#,thread#,status  FROM v$log 
--WHERE thread# = :ora_thread AND status in ('INVALIDATED', 'CURRENT', 'ACTIVE')
; 
SELECT DECODE(status, 'STALE', 1, 0),member FROM v$logfile 
--WHERE member = :log_name
; 
SELECT *  FROM V$LOGFILE 
WHERE(STATUS NOT IN ('STALE', 'INVALID') OR STATUS IS NULL) ;
AND MEMBER <> :log_name 
AND EXISTS ( SELECT 1 FROM V$LOG WHERE GROUP#  = V$LOGFILE.GROUP# AND THREAD# = :ora_thread AND SEQUENCE# = :ora_seq_no ) AND ROWNUM = 1
;



