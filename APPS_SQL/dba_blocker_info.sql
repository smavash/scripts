SELECT *  FROM DBA_BLOCKERS;
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
   AND s.sid = 2312;
   
   
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
  
  
  
  
  
  SELECT v.audsid audsid,
l.sid sid,
v.module,
v.action,
v.process,
v.serial#,
v.username oracle_user,
v.osuser,
v.program,
DECODE(l.lmode, 1, NULL, 2, 'Row Share', 3, 'Row Exclusive', 4, 'Share', 5, 'Share Row Exclusive', 6, 'Exclusive', 'None') lock_held,
DECODE(l.request, 1, NULL, 2, 'Row Share', 3, 'Row Exclusive', 4, 'Share', 5, 'Share Row Exclusive', 6, 'Exclusive', 'None') lock_mode,
DECODE(l.type, 'MR', 'Media Recovery', 'RT', 'Redo Thread', 'UN', 'User Name', 'TX', 'Transaction', 'TM', 'DML', 'UL', 'PL/SQL User Lock', 'DX', 'Distributed Xaction', 'CF', 'Control File', 'IS', 'Instance State', 'FS', 'File Set', 'IR', 'Instance Recovery', 'ST', 'Disk Space Transaction', 'TS', 'Temp Segment', 'IV', 'Library Cache Invalidation', 'LS', 'Log Start or Log Switch', 'RW', 'Row Wait', 'SQ', 'Sequence Number', 'TE', 'Extend Table', 'TT', 'Temp Table', l.type) lock_type,
o.owner object_owner,
o.object_name object_name,
o.object_type object_type,
ROUND( l.ctime/60, 2 ) lock_in_minuts
FROM v$session v,
dba_objects o,
v$lock l,
dba_tables t
WHERE l.id1 = o.object_id
AND v.sid = l.sid
AND o.owner = t.owner
AND o.object_name = t.table_name
AND o.owner != 'SYS'
AND l.type = 'TM'
ORDER BY module desc;


select /*+ rule */ l.start_time, u.description, FT.USER_FORM_NAME, l.login_id, l.spid,
       s.sid, s.serial#, s.process, s.status, s.module, s.action, S.AUDSID, p.pid, p.spid, s.logon_time
from   FND_LOGINS L, FND_USER U, FND_LOGIN_RESP_FORMS F, FND_FORM_TL FT,
       v$process p, v$session s
where  1 = 1
and    p.addr=s.paddr
and    l.process_spid = p.SPID
and    l.pid = p.PID
and    l.user_id=u.user_id
and    FT.FORM_ID = F.FORM_ID
and    FT.APPLICATION_ID = F.FORM_APPL_ID
and    F.LOGIN_ID = L.LOGIN_ID
and    FT.LANGUAGE = 'US'
--and FT.USER_FORM_NAME IN ('Inventory Transactions','Transact Move Orders','Shipping Transactions Form')
--and    u.user_name = 'A003330'
--and    p.SPID /* Unix PID */ = '17793066'
--and    s.STATUS = 'ACTIVE'
--and    s.process /* Form Unix PID(f60runm) */ = '1118442' 
--and    s.SID = 49



SELECT s.status "Status", 
s.TYPE "Type", 
s.username "DB_User", 
s.osuser "Client_User", 
s.server "Server", 
s.machine "Machine", 
s.module "Module", 
s.logon_time "Connect Time", 
s.process "Process", 
p.spid, 
p.pid, 
s.SID, 
s.audsid, 
SYSDATE - (s.last_call_et / 86400) "Last_Call" 
FROM v$session s, 
v$process p 
WHERE s.paddr = p.addr(+) 
--AND s.process = '&1'
--and s.status = 'ACTIVE'
and s.SID = 2683
;




select d.user_name "User Name",
       b.sid SID,
       b.serial# "Serial#",
       c.spid "srvPID",
       a.SPID "ClPID",
       to_char(START_TIME, 'DD-MON-YY HH:MM:SS') "STime"
  from fnd_logins a, v$session b, v$process c, fnd_user d
where b.paddr = c.addr
and a.pid = c.pid
and a.spid = b.process
and d.user_id = a.user_id
-- and(d.user_name = 'USER_NAME' OR 1 = 1)
--   and a.SPID = &PID
;


SELECT SUBSTR(d.user_name,1,30) "User Name"
, a.pid
, b.sid
, b.process
,a.spid
FROM v$process a, v$session b, fnd_logins c, fnd_user d
WHERE a.pid = c.pid
AND d.user_id = c.user_id
--and d.user_name='&User_name'
AND a.addr = b.paddr
AND c.end_time IS NULL;







 
 

