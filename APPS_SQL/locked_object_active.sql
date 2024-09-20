

-- Alter system kill session '1854,29079';


  select 'Alter system kill session '||''''||substr(to_char(l.session_id)||','||to_char(s.serial#),1,12)||''''||';'  sid_ser,
substr(l.os_user_name||'/'||l.oracle_username,1,12) username,
l.process,
p.spid,
substr(o.owner||'.'||o.object_name,1,35) owner_object,
decode(l.locked_mode,
1,'No Lock', 
2,'Row Share', 
3,'Row Exclusive', 
4,'Share', 
5,'Share Row Excl', 
6,'Exclusive',null) locked_mode,
s.SQL_HASH_VALUE,
substr(s.status,1,8) status
from
v$locked_object l,         
all_objects o,
v$session s,
v$process p
where
l.object_id = o.object_id
and s.STATUS = 'ACTIVE'
and l.session_id = s.sid
and s.paddr = p.addr
--and s.status != 'KILLED'
--and  o.object_name like '%AR%'  
--and o.object_name like '%XX%' 
--and p.spid = 604
--and s.sid = 911
--and o.owner  in  ('ONT')

;


-- Run the following to determine what tables are locked:
SELECT a.object_id, a.session_id, substr(b.object_name, 1, 40)
FROM v$locked_object a, dba_objects b
WHERE a.object_id = b.object_id
--AND b.object_name like 'AP_%'
ORDER BY b.object_name;


/* Look at the results and insert whatever AP_% tables are returned from a) into the script below:

SELECT l.*, o.owner object_owner, o.object_name
FROM SYS.all_objects o, v$lock l
WHERE l.TYPE = 'TM'
AND o.object_id = l.id1
AND o.object_name in ('AP_INVOICES_ALL', 'AP_INVOICE_LINES_ALL', 'AP_INVOICE_DISTRIBUTIONS_ALL');


SELECT SID, SERIAL#
FROM v$session
WHERE SID = <SID from b)>;
               
-- Once the locking sessions have been identified, 
-- please use the below command to kill such sessions.

ALTER SYSTEM KILL SESSION 'sid,serial#' IMMEDIATE;
    
Note: SID and serial# to be taken from the output from 1c).
*/          

