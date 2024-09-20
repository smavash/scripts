Alter system kill session '1436,3569';

select * from fnd_user where user_id =1420;
 

    SELECT /*+rule */
    decode(fcr.description, null, fcpt.user_concurrent_program_name,
    fcr.description||' ('||fcpt.user_concurrent_program_name||')'), --count(*)
    fu.user_id,
    fcr.program_application_id,
    fcr.request_id req_id,
    fcr.phase_code,fcr.hold_flag ,
    fcr.status_code ,
    fcr.parent_request_id,
    'kill -9 '||fcr.oracle_process_id UNIX_PID,
    fcr.requested_start_date,
    ROUND (((fcr.actual_completion_date - fcr.actual_start_date) * 24*60),2) Dur_Min ,--Hours,
    to_char(fcr.actual_start_date,'dd-mon-yy hh24:mi:ss') Start_Date,
    to_char(fcr.actual_completion_date,'dd-mon-yy hh24:mi:ss') Completion_date,
    fu.user_name,
    fu.description USER_DECRIPTION,
    decode(fcr.phase_code,'C','Completed', 'I','Inactive', 'P','Pending', 'R','Running',
    fcr.phase_code) phase, 
    decode(fcr.status_code,'C','Normal', 'X','Terminated', 'R','Normal', 'E','Error', 'W','Paused',
    'T','Terminating','I','Scheduled', 'D','Cancelled','Q','Standby','G','Warning',
    fcr.status_code) status,
    fcr.ARGUMENT_TEXT,
    fcr.request_date, fcr.outfile_name, fcr.logfile_name, fcr.printer, fcr.number_of_copies
    FROM
    fnd_concurrent_requests fcr,
    fnd_concurrent_programs_tl fcpt,
    fnd_user fu
    WHERE
fcpt.application_id = fcr.program_application_id
--  and fcr.oracle_process_id = 27184
--    and fcr.os_process_id = 
  --  AND ROUND (((fcr.actual_completion_date - fcr.actual_start_date) * 24*60),2) > 100
--    and ( fcr.phase_code = 'P'or fcr.status_code in ('I','Q','W') )
--     AND fcr.hold_flag != 'Y' and fcr.phase_code = 'P'
-- and fcr.status_code =    'E' --'X'
--and fcr.request_id =  &1 -- 6471532
    -- 4069412 
/*  and fcr.request_id in ( 
  48520177
   )*/
--and fcr.parent_request_id = &pid
AND fu.user_id = fcr.requested_by
AND fcpt.concurrent_program_id = fcr.concurrent_program_id
AND fcpt.language = 'US'
-- and fcr.phase_code = 'R' 
AND fcr.actual_start_date > to_date('05-Jan-20 15:00:00','dd-mon-yy hh24:mi:ss')
--AND fcr.actual_completion_date < to_date('05-Jan-20 23:00:00','dd-mon-yy hh24:mi:ss')

--AND fcpt.user_concurrent_program_name  like
--'Posting%'
-- and fcr.actual_start_date < to_date('02-Oct-11 20:00:00','dd-mon-yy hh24:mi:ss')
    --AND fcr.actual_completion_date is null
  --  AND fcr.request_date > sysdate - 1/24*100 
--  AND fcr.requested_start_date between to_date('30/05/2007 16:00','dd/mm/yyyy hh24:mi')
  -- and to_date('18/09/2006 16:00','dd/mm/yyyy hh24:mi')
-- and fu.user_name   like '%'
    --group by fcpt.user_concurrent_program_name 
  -- and fcr.argument_text like '%OID%'
-- and fcr.printer = '%'
--and fcr.number_of_copies > 0
  --and hold_flag = 'Y'
  
  ORDER BY fcr.actual_start_date DESC;

select file_name, language, creation_date, document_id from fnd_documents_tl  order by creation_date desc;




    
  
SELECT fcpp.concurrent_request_id req_id, fcp.node_name, fcp.logfile_name
  FROM fnd_conc_pp_actions fcpp, fnd_concurrent_processes fcp
 WHERE fcpp.processor_id = fcp.concurrent_process_id
   AND fcpp.action_type = 6
   AND fcpp.concurrent_request_id = 8093313



  
  


      


select 
          sysdate,
          tB.SID,
          tA.SQL_TEXT,tA.SQL_ID,
          tB.SERIAL#,
          tB.status,
          tB.MODULE,
          tB.ACTION,
          tB.PROGRAM,  
          tB.OSUSER,
          tB.MACHINE,
          tB.EVENT,
          tB.PROCESS "Remote PID",
          tB.SQL_ADDRESS,
          tB.BLOCKING_SESSION,
          tB.BLOCKING_SESSION_STATUS,
          tB.STATE,tB.SECONDS_IN_WAIT/60 "Mins waite",tB.WAIT_CLASS
from
v$sql tA, v$session tB
where 
tA.hASH_VALUE = tB.SQL_HASH_VALUE
and tA.ADDRESS= tB.SQL_ADDRESS
and tB.SID = 328;
;

select 
* from
v$sql tA
where  UPPER (substr(tA.sql_text,0,3000))   like '%FND_USER%'
and UPPER (substr(tA.sql_text,0,3000))   like '%UPDATE%'
order by tA.ACTION;




    select 
    tB.*, tC.*
    from 
         v$session tB,  
         v$process tC
    where          
    tB.paddr = tC.addr
    and tC.sPID = 1954014
   ;

   select * from v$process;

 


  
  
  
select 
*
from
FND_CONCURRENT_REQUESTS fcr
where hold_flag = 'Y'
and PHASE_CODE = 'P' and requested_By != 0
;


select 
*
from
FND_CONCURRENT_REQUESTS fcr
where hold_flag = 'N'
and COMPLETION_TEXT = 'Hold by R12 script '
;

update FND_CONCURRENT_REQUESTS
set 
   HOLD_flag = 'N'
   ,LAST_UPDATE_DATE       = sysdate
   ,LAST_UPDATED_BY        = 1134  
where 
COMPLETION_TEXT = 'Hold by R12 script ' 
and hold_flag = 'Y'
;


  
  
SELECT req.request_id, prog.user_concurrent_program_name, req.argument_text, 
               to_char(req.actual_start_date,'dd-Mon-yyyy hh24:mi:ss') "Start Date",
               u.user_name, u.description, decode(req.phase_code,'C','Completed', 
                                                                 'I','Inactive',
                                                                 'P','Pending',
                                                                 'R','Running',
                                                                     req.phase_code) phase, 
                                           decode(req.status_code,'C','Normal',
                                                                  'X','Terminated',
                                                                  'R','Normal',
                                                                  'E','Error',
                                                                  'W','Paused',
                                                                  'I','Scheduled',
                                                                  'G','Warning',
                                                                      req.status_code) status
        FROM   fnd_concurrent_requests req, fnd_concurrent_programs_tl prog, fnd_user u,
               (SELECT max(req.request_id) request_id
               FROM   fnd_concurrent_requests req
               WHERE  req.oracle_process_id = '59153897') max_req ----Unix PID               
        WHERE  req.request_id = max_req.request_id
        AND    req.program_application_id = prog.application_id
        AND    req.concurrent_program_id = prog.concurrent_program_id
        AND    u.user_id = req.requested_by
        AND prog.language = 'US'
;
        

select * from v$instance;



  
  
  
  
  
select * from FND_CONCURRENT_PROCESSES k where k.concurrent_process_id = 158431 for update;

select
  t.request_id, k.*
  from Fnd_Concurrent_Requests t,
       FND_CONCURRENT_PROCESSES k,
       Fnd_Concurrent_Queues_TL QTL,
       Fnd_Concurrent_Programs_TL PTL 
  where k.concurrent_process_id = t.controlling_manager
    and QTL.Concurrent_Queue_Id = k.concurrent_queue_id
    and ptl.concurrent_program_id=t.concurrent_program_id
    and qtl.language='US'
    and t.request_id = 59153897;

    
    

 

 

Select /*+ RULE */
       'kill -9 '|| Fpro.os_process_id ospid ,
       Request_Id                                               reqid,
       To_Char(Actual_Start_Date, 'DD-MON HH24:MI')             sdate,
      DECODE (Fcr.DESCRIPTION,
      NULL,
      USER_CONCURRENT_PROGRAM_NAME ,
      Fcr.DESCRIPTION||' ('||USER_CONCURRENT_PROGRAM_NAME||')')     concprog,
       Concurrent_Queue_Name                                    qname,
       substr(User_name,1,10)                                   Username
  from Fnd_User ,
       Fnd_Concurrent_Queues Fcq, 
       Fnd_Concurrent_Requests Fcr,
       Fnd_Concurrent_Programs_vl Fcp, 
       Fnd_Concurrent_Processes Fpro
 where
--       Phase_Code = 'C' And
--       Fcr.status_code = 'C' And
       Fcr.Controlling_Manager = Concurrent_Process_Id       And
      (Fcq.Concurrent_Queue_Id = Fpro.Concurrent_Queue_Id    And
       Fcq.Application_Id      = Fpro.Queue_Application_Id ) And
      (Fcr.Concurrent_Program_Id = Fcp.Concurrent_Program_Id And
       Fcr.Program_Application_Id = Fcp.Application_Id )     And
       Fcr.Requested_By = User_Id 
--        ( SYSDATE - Actual_Start_Date )* 24 *60 > 30 
 Order by Actual_Start_Date /*Concurrent_Queue_Name*/
 ;
 
 select * from Fnd_Concurrent_Queues
 
 
SELECT CONCURRENT_QUEUE_NAME,
      DECODE (Fcr.DESCRIPTION,
      NULL,
      Fcp.USER_CONCURRENT_PROGRAM_NAME,
      Fcr.DESCRIPTION||' ('||Fcp.USER_CONCURRENT_PROGRAM_NAME||')') ucpname,
       COUNT(*) Count,
       MIN((Fcr.ACTUAL_START_DATE
           -Fcr.REQUESTED_START_DATE)*1440)                     minwait,
       AVG((Fcr.ACTUAL_START_DATE
           -Fcr.REQUESTED_START_DATE)*1440)                     avgwait,
       MAX((Fcr.ACTUAL_START_DATE
           -Fcr.REQUESTED_START_DATE)*1440)                     maxwait,
       MIN((Fcr.ACTUAL_COMPLETION_DATE
           -Fcr.ACTUAL_START_DATE)*1440)                        mintime,
       AVG((Fcr.ACTUAL_COMPLETION_DATE
           -Fcr.ACTUAL_START_DATE)*1440)                        avgtime,
       MAX((Fcr.ACTUAL_COMPLETION_DATE
           -Fcr.ACTUAL_START_DATE)*1440)                        maxtime,
       COUNT(*)*AVG((Fcr.ACTUAL_COMPLETION_DATE
                    -Fcr.ACTUAL_START_DATE)*1440)               sumtimemin
 from Fnd_Concurrent_Queues Fcq,
       Fnd_Concurrent_Requests Fcr,
       Fnd_Concurrent_Programs_vl Fcp,
       Fnd_Concurrent_Processes Fpro
 where
       Fcr.Controlling_Manager = Concurrent_Process_Id       And
      (Fcq.Concurrent_Queue_Id = Fpro.Concurrent_Queue_Id    And
       Fcq.Application_Id      = Fpro.Queue_Application_Id ) And
      (Fcr.Concurrent_Program_Id = Fcp.Concurrent_Program_Id And
       Fcr.Program_Application_Id = Fcp.Application_Id )     And
(TRUNC(Fcr.REQUEST_DATE) BETWEEN sysdate - 12  AND sysdate - 2
 AND TO_CHAR(Fcr.REQUEST_DATE,'Day') <> 'Saturday'
 AND TO_CHAR(Fcr.REQUEST_DATE, 'hh24') BETWEEN 0
                                       AND 24)
 AND  Fcr.CONCURRENT_PROGRAM_ID=Fcp.CONCURRENT_PROGRAM_ID
Having COUNT(*)*AVG((Fcr.ACTUAL_COMPLETION_DATE
                    -Fcr.ACTUAL_START_DATE)*1440) > 1
GROUP BY CONCURRENT_QUEUE_NAME,
      DECODE (Fcr.DESCRIPTION,
      NULL,
      Fcp.USER_CONCURRENT_PROGRAM_NAME,
      Fcr.DESCRIPTION||' ('||Fcp.USER_CONCURRENT_PROGRAM_NAME||')')
ORDER BY COUNT(*)*AVG((Fcr.ACTUAL_COMPLETION_DATE
                      -Fcr.ACTUAL_START_DATE)*1440) DESC
;
 

 

 

 

       select r.request_id,   
       p.user_concurrent_program_name || nvl2(r.description,' ('||r.description||')',null) Conc_prog,   
       r.argument_text arguments,   
       r.requested_start_date next_run,   
       r.hold_flag on_hold,   
       r.increment_dates,   
       decode(c.class_type,   
              'P', 'Periodic',   
              'S', 'On Specific Days',   
              'X', 'Advanced',   
              c.class_type) schedule_type,   
       case  
         when c.class_type = 'P' then  
          'Repeat every ' ||   
          substr(c.class_info, 1, instr(c.class_info, ':') - 1) ||   
          decode(substr(c.class_info, instr(c.class_info, ':', 1, 1) + 1, 1),   
                 'N', ' minutes',   
                 'M', ' months',   
                 'H', ' hours',   
                 'D', ' days') ||   
          decode(substr(c.class_info, instr(c.class_info, ':', 1, 2) + 1, 1),   
                 'S', ' from the start of the prior run',   
                 'C', ' from the completion of the prior run')   
         when c.class_type = 'S' then  
          nvl2(dates.dates, 'Dates: ' || dates.dates || '. ', null) ||   
          decode(substr(c.class_info, 32, 1), '1', 'Last day of month ') ||   
          decode(sign(to_number(substr(c.class_info, 33))),   
                 '1', 'Days of week: ' ||   
                 decode(substr(c.class_info, 33, 1), '1', 'Su ') ||   
                 decode(substr(c.class_info, 34, 1), '1', 'Mo ') ||   
                 decode(substr(c.class_info, 35, 1), '1', 'Tu ') ||   
                 decode(substr(c.class_info, 36, 1), '1', 'We ') ||   
                 decode(substr(c.class_info, 37, 1), '1', 'Th ') ||   
                 decode(substr(c.class_info, 38, 1), '1', 'Fr ') ||   
                 decode(substr(c.class_info, 39, 1), '1', 'Sa '))   
       end as schedule,   
       c.date1 start_date,   
       c.date2 end_date,   
       c.class_info   
  from fnd_concurrent_requests    r,   
       fnd_conc_release_classes   c,   
       fnd_concurrent_programs_tl p,   
       (with date_schedules as (   
            select release_class_id,   
                   rank() over(partition by release_class_id order by s) a, s   
              from (select c.class_info, l,   
                           c.release_class_id,   
                           decode(substr(c.class_info, l, 1), '1', to_char(l)) s   
                      from (select level l from dual connect by level <= 31),   
                           fnd_conc_release_classes c   
                     where c.class_type = 'S'  
                       and instr(substr(c.class_info, 1, 31), '1') > 0)   
             where s is not null)   
      SELECT release_class_id, substr(max(SYS_CONNECT_BY_PATH(s, ' ')), 2) dates   
        FROM date_schedules   
       START WITH a = 1   
      CONNECT BY nocycle PRIOR a = a - 1   
       group by release_class_id) dates   
          where r.phase_code = 'P'  
            and c.application_id = r.release_class_app_id   
            and c.release_class_id = r.release_class_id   
            and nvl(c.date2, sysdate + 1) > sysdate   
            and c.class_type is not null  
            and p.concurrent_program_id = r.concurrent_program_id   
            and p.language = 'US'  
            and dates.release_class_id(+) = r.release_class_id   
--            and r.requested_by = 1101
          order by on_hold, next_run;  



 


SELECT 
       p.spid "Local pid",
       USR.USER_NAME    UserN,
       RSP.RESPONSIBILITY_NAME  ResponcibilityName,
 --      FRM.USER_FORM_NAME FormName,
       ss.value "%CPU",
       FLOOR((SYSDATE - L.START_TIME) * 24) || ':' ||
       LTRIM(TO_CHAR(ROUND(((SYSDATE - L.START_TIME) * 24 -
                           FLOOR((SYSDATE - L.START_TIME) * 24)) * 60),
                     '09')) TIME,
       s.sid||','||s.serial#  "SID",
       MACHINE "MACHINE"
--       substr(sa.SQL_TEXT, 1, 40) "SQL"
FROM 
       FND_LOGINS                 L,
       FND_LOGIN_RESPONSIBILITIES R,
       FND_LOGIN_RESP_FORMS       F,
       FND_USER                   USR,
       FND_RESPONSIBILITY_VL      RSP,
       FND_FORM_VL                FRM,
       v$process                  p ,
       v$session                  s, 
       v$sesstat                  ss , 
       v$sqlarea                  sa
WHERE 
          R.LOGIN_ID = F.LOGIN_ID(+) 
      AND L.LOGIN_ID = R.LOGIN_ID(+) 
      AND L.END_TIME IS NULL 
      AND R.END_TIME IS NULL 
      AND F.END_TIME IS NULL 
      AND L.USER_ID = USR.USER_ID 
      AND R.RESPONSIBILITY_ID = RSP.RESPONSIBILITY_ID(+) 
      AND R.RESP_APPL_ID = RSP.APPLICATION_ID(+) 
      AND F.FORM_ID = FRM.FORM_ID(+) 
      AND F.FORM_APPL_ID = FRM.APPLICATION_ID(+) 
--      AND (L.SPID, L.LOGIN_NAME) IN (SELECT SPID, USERNAME FROM FND_V$PROCESS) 
      and l.process_spid = p.SPID
      and p.addr=s.paddr
      and ss.statistic# in 
      (select statistic# from v$statname where name = 'CPU used by this session')
      and ss.sid = s.sid
      and s.SQL_HASH_VALUE = sa.HASH_VALUE
order by 5 desc
;
 

 
Alter system kill session '479,1204';




 

SELECT * FROM DBA_BLOCKERS;
SELECT * FROM DBA_WAITERS;

SELECT s.sid,
       w.state,
       w.event,
       w.seconds_in_wait siw,
       s.sql_address,
       s.sql_hash_value hash_value,
       w.p1,
       w.p2,
       w.p3
  FROM v$session s, v$session_wait w
 WHERE s.sid = w.sid
   AND s.sid = 4486;
   
   
select  
        p.SPID ,w.SECONDS_IN_WAIT
from 
        v$process p, v$session s,
        v$session_wait w
where    
         w.SID = s.SID and
         s.PADDR   = p.ADDR and 
         s.SID 
         
          in 
(  select  
        dl.session_id sid
from 
        dba_locks dl
where dl.blocking_others =  'Blocking' 
);



  --sessions waiting for a TX lock:
select * from v$lock where type='TX' and request>0;
-- sessions holding a TX lock:
select * from v$lock where type='TX' and lmode>0;


     
select SESSION_ID,NAME,P1,P2,P3,WAIT_TIME,CURRENT_OBJ#,CURRENT_FILE#,CURRENT_BLOCK# 
       from v$active_session_history ash, v$event_name enm 
       where ash.event#=enm.event# 
       and 
       --SESSION_ID=&SID and 
       name = 'enq: TX - row lock contention' and
       SAMPLE_TIME>=(sysdate-&minute/(24*60)); 
       
       
       
SELECT SUBSTR(TO_CHAR(w.session_id),1,5) WSID, p1.spid WPID,
SUBSTR(s1.username,1,12) "WAITING User",
SUBSTR(s1.osuser,1,8) "OS User",
SUBSTR(s1.program,1,20) "WAITING Program",
s1.client_info "WAITING Client",
SUBSTR(TO_CHAR(h.session_id),1,5) HSID, p2.spid HPID,
SUBSTR(s2.username,1,12) "HOLDING User",
SUBSTR(s2.osuser,1,8) "OS User",
SUBSTR(s2.program,1,20) "HOLDING Program",
s2.client_info "HOLDING Client",
o.object_name "HOLDING Object"
FROM gv$process p1, gv$process p2, gv$session s1,
gv$session s2, dba_locks w, dba_locks h, dba_objects o
WHERE w.last_convert > 60
AND h.mode_held != 'None'
AND h.mode_held != 'Null'
AND w.mode_requested != 'None'
AND s1.row_wait_obj# = o.object_id
AND w.lock_type(+) = h.lock_type
AND w.lock_id1(+) = h.lock_id1
AND w.lock_id2 (+) = h.lock_id2
AND w.session_id = s1.sid (+)
AND h.session_id = s2.sid (+)
AND s1.paddr = p1.addr (+)
AND s2.paddr = p2.addr (+)
ORDER BY w.last_convert desc;


select /* all_rows */ w1.sid  waiting_session,
        h1.sid  holding_session,
        w.kgllktype lock_or_pin,
        w.kgllkhdl address,
        decode(h.kgllkmod,  0, 'None', 1, 'Null', 2, 'Share', 3,
'Exclusive',
           'Unknown') mode_held,
        decode(w.kgllkreq,  0, 'None', 1, 'Null', 2, 'Share', 3,
'Exclusive',
           'Unknown') mode_requested
  from dba_kgllock w, dba_kgllock h, v$session w1, v$session h1
 where
  (((h.kgllkmod != 0) and (h.kgllkmod != 1)
     and ((h.kgllkreq = 0) or (h.kgllkreq = 1)))
   and
     (((w.kgllkmod = 0) or (w.kgllkmod= 1))
     and ((w.kgllkreq != 0) and (w.kgllkreq != 1))))
  and  w.kgllktype       =  h.kgllktype
  and  w.kgllkhdl        =  h.kgllkhdl
  and  w.kgllkuse     =   w1.saddr
  and  h.kgllkuse     =   h1.saddr;
  

  select /* all_rows */ w1.sid  waiting_session,
        h1.sid  holding_session,
        w.kgllktype lock_or_pin,
        w.kgllkhdl address,
        decode(h.kgllkmod,  0, 'None', 1, 'Null', 2, 'Share', 3,
'Exclusive',
           'Unknown') mode_held,
        decode(w.kgllkreq,  0, 'None', 1, 'Null', 2, 'Share', 3,
'Exclusive',
           'Unknown') mode_requested
  from dba_kgllock w, dba_kgllock h, v$session w1, v$session h1
 where
  (((h.kgllkmod != 0) and (h.kgllkmod != 1)
     and ((h.kgllkreq = 0) or (h.kgllkreq = 1)))
   and
     (((w.kgllkmod = 0) or (w.kgllkmod= 1))
     and ((w.kgllkreq != 0) and (w.kgllkreq != 1))))
  and  w.kgllktype       =  h.kgllktype
  and  w.kgllkhdl        =  h.kgllkhdl
  and  w.kgllkuse     =   w1.saddr
  and  h.kgllkuse     =   h1.saddr;
  
  


select * from v$sqlarea tA,v$session tB
where 
--          tA.hASH_VALUE = tB.SQL_HASH_VALUE
       tA.ADDRESS= tB.SQL_ADDRESS
      and sql_text like '%delete xxau_log_control %';
      
      select * from v$sqlarea
where sql_text like '%delete xxau_log_control %'





 

select usr.user_name "Apps Username"
,i.first_connect "First Connect Date"
,ses.sid
,ses.serial#
,ses.module
,v.spid "Oracle Server Process"
,ses.process "Application Server Process"
,rsp.responsibility_name "Responsibility Name"
,null "Responsibility Start Time"
,fuc.function_name "Function Name"
,i.function_type "Function Type"
,i.last_connect "Function Start Time"
from icx_sessions i
,fnd_logins l
,fnd_appl_sessions a
,fnd_user usr
,fnd_responsibility_tl rsp
,fnd_form_functions fuc
,gv$process v
,gv$session ses
where i.disabled_flag = 'N'
and i.login_id = l.login_id
and l.end_time is null
and i.user_id = usr.user_id
and l.login_id = a.login_id
and a.audsid = ses.audsid
and l.pid = v.pid
and l.serial# = v.serial#
and i.responsibility_application_id = rsp.application_id(+)
and i.responsibility_id = rsp.responsibility_id(+)
and i.function_id = fuc.function_id(+)
and i.responsibility_id not in (select t1.responsibility_id
from fnd_login_responsibilities t1
where t1.login_id = l.login_id)
and rsp.language(+) = 'US'
and v.SPID = 19644562
;
union

;
select usr.user_name
,l.start_time
,ses.sid
,ses.serial#
,ses.module
,v.spid
,ses.process
,rsp.responsibility_name
,r.start_time
,null
,null
,null form_start_time
from fnd_logins l
,fnd_login_responsibilities r
,fnd_user usr
,fnd_responsibility_tl rsp
,gv$process v
,gv$session ses
where l.end_time is null
and l.user_id = usr.user_id
and l.pid = v.pid
and l.serial# = v.serial#
and v.addr = ses.paddr
and l.login_id = r.login_id(+)
and r.end_time is null
and r.responsibility_id = rsp.responsibility_id(+)
and r.resp_appl_id = rsp.application_id(+)
and rsp.language(+) = 'US'
and r.audsid = ses.audsid
and ses.SID = 3478
--and v.SPID = 21348450
;

union
select usr.user_name
,l.start_time
,ses.sid
,ses.serial#
,ses.module
,v.spid
,ses.process
,null
,null
,frm.user_form_name
,ff.type
,f.start_time
from fnd_logins l
,fnd_login_resp_forms f
,fnd_user usr
,fnd_form_tl frm
,fnd_form_functions ff
,gv$process v
,gv$session ses
where l.end_time is null
and l.user_id = usr.user_id
and l.pid = v.pid
and l.serial# = v.serial#
and v.addr = ses.paddr
and l.login_id = f.login_id(+)
and f.end_time is null
and f.form_id = frm.form_id(+)
and f.form_appl_id = frm.application_id(+)
and frm.language(+) = 'US'
and f.audsid = ses.audsid
and ff.form_id = frm.form_id
--and v.SPID = 21348450
;

 

 

 

select  /*+rule */ 
'Alter system kill session '||''''||s.sid||','||s.serial#||''''||';' "To Kill",
l.start_time, 
s.LOGON_TIME, 
u.user_name,
u.description, 
l.pid, 
l.spid "Local", 
s.process "Remote", 
--s.sid, 
--s.serial#, 
s.status, 
s.module, 
s.action, 
S.AUDSID,
l.login_id,
l.user_id
from 
     fnd_logins l, 
     fnd_user u, 
     v$process p, 
     v$session s
where 
      l.user_id = u.user_id
      and l.end_time is null
--      and u.user_name = /*'SMAVASH' --*/'SMAVASH'
--      and l.start_time > TO_DATE('20-02-2006 17:20:00', 'DD-MM-YYYY HH24:MI:SS')
--      and s.LOGON_TIME > TO_DATE('20-02-2006 16:00:00', 'DD-MM-YYYY HH24:MI:SS')
--and s.LOGON_TIME  > sysdate-1
      and p.PID = l.pid
      and p.addr = s.paddr
--      and s.sid = 4800
        and l.spid = s.PROCESS
--        and l.spid = 16363560
--      and s.STATUS = 'ACTIVE'
--      and u.user_id = 2488
--      and s.MODULE != 'JDBC Thin Client'
ORDER BY  l.start_time DESC

 

 
