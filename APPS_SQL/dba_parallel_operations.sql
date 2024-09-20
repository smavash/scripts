select s.INST_ID,  s.sid,s.serial#,spid,
s.last_call_et,sql_text,s.module,s.action,fetches,executions,s.OSUSER,sql.SQL_FULLTEXT,
     disk_reads,buffer_gets,rows_processed,optimizer_mode,
     optimizer_cost,cpu_time,elapsed_time,last_load_time,s.process,s.program,sql.sql_id,s.event,s.WAIT_CLASS,p.PGA_ALLOC_MEM
 from gv$sql sql,
      gv$session s,
      gv$process p
where s.sql_id=sql.sql_id(+)
  and s.SQL_CHILD_NUMBER=sql.CHILD_NUMBER(+)
  and s.paddr =p.addr
  and status='ACTIVE' 
  --and s.SQL_ID = 'czkngybnp7vkj'
  and s.type !='BACKGROUND'
  and s.inst_id=sql.inst_id(+)
  and s.inst_id=p.inst_id;
  
  
  
select
decode(px.qcinst_id,NULL,username,
' - '||lower(substr(pp.SERVER_NAME,
length(pp.SERVER_NAME)-4,4) ) )"Username",
decode(px.qcinst_id,NULL, 'QC', '(Slave)') "QC/Slave" ,
to_char( px.server_set) "SlaveSet",
to_char(s.sid) "SID",
to_char(px.inst_id) "Slave INST",
decode(sw.state,'WAITING', 'WAIT', 'NOT WAIT' ) as STATE,    
case  sw.state WHEN 'WAITING' THEN substr(sw.event,1,30) ELSE NULL end as wait_event ,
decode(px.qcinst_id, NULL ,to_char(s.sid) ,px.qcsid) "QC SID",
to_char(px.qcinst_id) "QC INST",
px.req_degree "Req. DOP",
px.degree "Actual DOP"
from gv$px_session px,
gv$session s ,
gv$px_process pp,
gv$session_wait sw
where px.sid=s.sid (+)
and px.serial#=s.serial#(+)
and px.inst_id = s.inst_id(+)
and px.sid = pp.sid (+)
and px.serial#=pp.serial#(+)
and sw.sid = s.sid 
and sw.inst_id = s.inst_id  
order by
  decode(px.QCINST_ID,  NULL, px.INST_ID,  px.QCINST_ID),
  px.QCSID,
  decode(px.SERVER_GROUP, NULL, 0, px.SERVER_GROUP),
  px.SERVER_SET,
  px.INST_ID
  ;
  
  
  
  select
  sw.SID as RCVSID,
  decode(pp.server_name,
         NULL, 'A QC',
         pp.server_name) as RCVR,
  sw.inst_id as RCVRINST,
case  sw.state WHEN 'WAITING' THEN substr(sw.event,1,30) ELSE NULL end as wait_event ,
  decode(bitand(p1, 65535),
         65535, 'QC',
         'P'||to_char(bitand(p1, 65535),'fm000')) as SNDR,
  bitand(p1, 16711680) - 65535 as SNDRINST,
  decode(bitand(p1, 65535),
         65535, ps.qcsid,
         (select
            sid
          from
            gv$px_process
          where
            server_name = 'P'||to_char(bitand(sw.p1, 65535),'fm000') and
            inst_id = bitand(sw.p1, 16711680) - 65535)
        ) as SNDRSID,
   decode(sw.state,'WAITING', 'WAIT', 'NOT WAIT' ) as STATE    
from
  gv$session_wait sw,
  gv$px_process pp,
  gv$px_session ps
where
  sw.sid = pp.sid (+) and
  sw.inst_id = pp.inst_id (+) and
  sw.sid = ps.sid (+) and
  sw.inst_id = ps.inst_id (+) and
  p1text  = 'sleeptime/senderid' and
  bitand(p1, 268435456) = 268435456
order by
  decode(ps.QCINST_ID,  NULL, ps.INST_ID,  ps.QCINST_ID),
  ps.QCSID,
  decode(ps.SERVER_GROUP, NULL, 0, ps.SERVER_GROUP),
  ps.SERVER_SET,
  ps.INST_ID
  ;
  
  
  Select
decode(px.qcinst_id,NULL,username,
' - '||lower(substr(pp.SERVER_NAME,
length(pp.SERVER_NAME)-4,4) ) )"Username",
decode(px.qcinst_id,NULL, 'QC', '(Slave)') "QC/Slave" ,
to_char( px.server_set) "SlaveSet",
to_char(px.inst_id) "Slave INST",
substr(opname,1,30)  operation_name,
substr(target,1,30) target,
sofar,
totalwork,
units,
start_time,
timestamp,
decode(px.qcinst_id, NULL ,to_char(s.sid) ,px.qcsid) "QC SID",
to_char(px.qcinst_id) "QC INST"
from gv$px_session px,
gv$px_process pp,
gv$session_longops s
where px.sid=s.sid
and px.serial#=s.serial#
and px.inst_id = s.inst_id
and px.sid = pp.sid (+)
and px.serial#=pp.serial#(+)
and totalwork - sofar > 0
order by
  decode(px.QCINST_ID,  NULL, px.INST_ID,  px.QCINST_ID),
  px.QCSID,
  decode(px.SERVER_GROUP, NULL, 0, px.SERVER_GROUP),
  px.SERVER_SET,
  px.INST_ID
; 

select * from fnd_user
where user_name like 'ADM%'
;

select EVENT,
       sum(TOTAL_WAITS),
       SUM(TOTAL_TIMEOUTS),
       SUM(TIME_WAITED),
       AVG(AVERAGE_WAIT),
       MAX(MAX_WAIT)
  from v$session_event
 where sid in (select sid from v$px_session)
 group by EVENT;


select * from V$PX_BUFFER_ADVICE;

select 
decode(px.qcinst_id,NULL,username, 
' - '||lower(substr(s.program,length(s.program)-4,4) ) ) "Username", 
decode(px.qcinst_id,NULL, 'QC', '(Slave)') "QC/Slave" , 
to_char( px.server_set) "Slave Set", 
to_char(s.sid) "SID", 
decode(px.qcinst_id, NULL ,to_char(s.sid) ,px.qcsid) "QC SID", 
px.req_degree "Requested DOP", 
px.degree "Actual DOP" 
from 
v$px_session px, 
v$session s 
where 
px.sid=s.sid (+) 
and 
px.serial#=s.serial# 
order by 5 , 1 desc;


select * from v$pq_sysstat
