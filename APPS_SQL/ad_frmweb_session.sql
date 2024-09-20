
select sid, serial#, logon_time, client_identifier, module, status, machine, seconds_in_wait
from gv$session
where program like 'frmweb%'
order by logon_time;


select d.user_name "User Name",
b.sid SID,b.serial# "Serial#", c.spid "srvPID", a.SPID "AP_OS_PID",
to_char(START_TIME,'DD-MON-YY HH:MM:SS') "STime"
from fnd_logins a, v$session b, v$process c, fnd_user d
where b.paddr = c.addr
and a.pid=c.pid
and a.spid = b.process
and d.user_id = a.user_id
and (d.user_name = 'USER_NAME' OR 1=1)
and b.sid = &sid
--AND a.SPID = &PID
;




select /*+ rule */
 to_char(s.logon_time, 'mm/dd/yy hh:mi:ssAM') startedat,
 a.time,
 floor(s.last_call_et / 3600) || ':' ||
 floor(mod(s.last_call_et, 3600) / 60) || ':' ||
 mod(mod(s.last_call_et, 3600), 60) "LastCallET",
 u.user_name,
 u.description,
 s.module || ' - ' || a.user_form_name forminfo
  from applsys.fnd_logins         l,
       applsys.fnd_user           u,
       apps.fnd_signon_audit_view a,
       v$process                  p,
       v$session                  s
 where 
 --s.sid = &trgtsid   and 
 s.paddr = p.addr
   and p.pid = l.pid
   and l.end_time is null
   and l.spid = s.process
   and l.start_time is not null
    and l.start_time = u.last_logon_date
    and l.session_number = u.session_number
   and l.user_id = u.user_id
   and u.user_id = a.user_id
   and p.pid = a.pid
   and l.start_time = (select max(l2.start_time)
                         from applsys.fnd_logins l2
                        where l2.pid = l.pid)
 group by to_char(s.logon_time, 'mm/dd/yy hh:mi:ssAM'),
          floor(s.last_call_et / 3600) || ':' ||
          floor(mod(s.last_call_et, 3600) / 60) || ':' ||
          mod(mod(s.last_call_et, 3600), 60),
          u.user_name,
          u.description,
          a.time,
          s.module || ' - ' || a.user_form_name
 order by to_char(s.logon_time, 'mm/dd/yy hh:mi:ssAM'), a.time;



  
select  s.sid "PID REMOTE",
       p.SPID  "LOCAL SPID",
       sql.sql_text,
     --  dbms_xplan.display_awr(sql.sql_id) SQL_PLAN,
       trim(to_char(sql.rows_processed,'999,999,999,999')) rows_processed,
       sql.SQL_FULLTEXT,
       decode(buffer_gets, 0, -1, cpu_time / buffer_gets) buffer_gets,
       s.action,
       sql.fetches,
       sql.executions,
       s.OSUSER,
       sql.disk_reads,
       sql.buffer_gets,
       sql.cpu_time,
       sql.elapsed_time,
       sql.last_load_time,
       s.program,
       s.event,
       s.WAIT_CLASS,
       s.MACHINE,
       s.USERNAME
  from SYS.GV_$SESSION s, gv$sql sql, gv$process p
 where s.sql_id = sql.sql_id
  and s.paddr = p.addr
   and s.inst_id = sql.inst_id
	 and s.inst_id = p.inst_id
   	 and s.SQL_CHILD_NUMBER = sql.CHILD_NUMBER(+)
--    and s.type != 'BACKGROUND'
--   and s.status = 'ACTIVE'
--and s.program like '%frmweb%'
--and s.sid = 19065

;


SELECT SUBSTR(usr.user_name, 1, 10) "USER_NAME",
       s.username "User",
       p.pid "PID",
       a.application_name "APPLICATION_NAME",
       r.responsibility_name "RESPONSIBILITY_NAME",
       'Navigator' "PROGRAM",
       NVL(s.module, 'Navigator') "MODULE",
       s.status,
       'FORM' "LOGIN_TYPE",
       TO_CHAR(lr.start_time, 'DD-MON-RR HH24:MI:SS') "START_TIME",
       s.SID "SID",
       s.serial# "SERIAL#",
       l.spid "SESSION_SPID",
       l.process_spid "SHADOW_SPID",
       s.sql_address
  FROM fnd_logins                 l,
       fnd_user                   usr,
       fnd_application_tl         a,
       fnd_responsibility_tl      r,
       v$process                  p,
       v$session                  s,
       fnd_login_responsibilities lr
 WHERE l.login_id = lr.login_id
   AND lr.end_time IS NULL
   AND s.module IS NULL
   AND lr.resp_appl_id = a.application_id
   AND r.application_id = a.application_id
   AND lr.responsibility_id = r.responsibility_id
   AND l.user_id = usr.user_id
   AND p.addr = s.paddr
   AND p.serial# = l.serial#
   AND l.pid = p.pid
      --AND l.spid = 13109
   AND l.end_time IS NULL
   AND (l.spid, l.login_name) IN (SELECT spid, username FROM fnd_v$process)

UNION ALL

SELECT --/*+rule*/ 
 SUBSTR(usr.user_name, 1, 10),
 s.username "User",
 p.pid  ,
 a.application_name,
 TO_CHAR(r.request_id),
 progtl.user_concurrent_program_name,
 s.module,
 'CONCURRENT',
 s.status,
 TO_CHAR(r.actual_start_date, 'DD-MON-RR HH24:MI:SS'),
 s.SID,
 s.serial#,
 r.os_process_id "OS Sess ID",
 r.oracle_process_id "OS Shadow ID",
 s.sql_address
  FROM fnd_concurrent_requests    r,
       fnd_user                   usr,
       fnd_application_tl         a,
       v$session                  s,
       v$process                  p,
       fnd_concurrent_programs_vl progtl
 WHERE r.actual_completion_date IS NULL
   AND r.requested_by = usr.user_id
   AND r.concurrent_program_id = progtl.concurrent_program_id
   AND r.program_application_id = progtl.application_id
   AND progtl.concurrent_program_name = s.module
   AND progtl.application_id = a.application_id
   AND r.oracle_process_id = p.spid
   AND r.os_process_id = s.process
   AND s.paddr = p.addr
;
UNION ALL 
;
SELECT SUBSTR(usr.user_name, 1, 10),
       s.username "User",
       p.pid,
       a.application_name,
       r.responsibility_name,
       ftl.user_form_name,
       s.module,
       s.status,
       'FORM',
       TO_CHAR(lf.start_time, 'DD-MON-RR HH24:MI:SS'),
       s.SID,
       s.serial#,
       l.spid "OS Sess ID",
       l.process_spid "OS Shadow ID",
       s.sql_address
  FROM fnd_logins                 l,
       fnd_user                   usr,
       fnd_application_tl         a,
       fnd_responsibility_tl      r,
       v$process                  p,
       v$session                  s,
       fnd_login_responsibilities lr,
       fnd_login_resp_forms       lf,
       fnd_form_tl                ftl,
       fnd_form                   f
 WHERE l.login_id = lr.login_id
   AND l.user_id = usr.user_id
   AND lr.resp_appl_id = a.application_id
   AND lr.responsibility_id = r.responsibility_id
   AND r.application_id = a.application_id
   AND lr.login_id = lf.login_id
   AND lr.login_resp_id = lf.login_resp_id
   --AND lf.end_time IS NULL
   AND lf.form_id = f.form_id
   AND lf.form_appl_id = f.application_id
   AND p.addr = s.paddr
   AND p.serial# = l.serial#
   AND l.pid = p.pid
      --AND l.spid = 13109
--   AND l.end_time IS NULL
   -- AND (l.spid, l.login_name) IN (SELECT spid, username FROM fnd_v$process)
--   AND s.module IS NOT NULL
   AND s.module = f.form_name
   AND ftl.form_id = f.form_id
   --AND ftl.application_id = f.application_id
;
UNION ALL 

SELECT --/*+rule*/ 
 s.osuser,
 s.username "User",
 p.pid,
 s.machine,
 s.terminal,
 s.program,
 s.module,
 s.status,
 'CLIENT SERVER',
 '',
 s.SID,
 s.serial#,
 s.process ,
 p.spid,
 s.sql_address
  FROM v$process p, v$session s
 WHERE p.addr = s.paddr
   AND SUBSTR(s.terminal, 1, 7) <> 'UNKNOWN'
   AND s.TYPE <> 'BACKGROUND'
