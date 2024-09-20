insert into dbamon.dbamon_collect_buffered_sql
(
WHEN_CHECKED ,
USERNAME ,
SID , 
OSPID ,
SQL ,
MODULE , 
ACTION ,
PROGRAM ,
FETCHES ,
EXECUTIONS ,
DISK_READS ,
BUFFER_GETS ,
ROWS_PROCESSED ,
OPTIMIZER_MODE  ,
OPTIMIZER_COST,
SQLADDR_DBG  
)
select 
sysdate,
t2.MACHINE,
t2.sid||','||t2.SERIAL#,
t3.spid,
substr(t1.sql_text,0,3000),
t1.MODULE,
t1.ACTION,
t2.PROGRAM,
t1.FETCHES,
t1.EXECUTIONS,
t1.DISK_READS,
t1.BUFFER_GETS,
t1.ROWS_PROCESSED,
t1.OPTIMIZER_MODE,
t1.OPTIMIZER_COST,
t2.SQL_ADDRESS 
from v$sql t1,
     v$session t2,
     v$process t3
where t2.status='ACTIVE'
  and t2.paddr = t3.addr
  and t1.hASH_VALUE = t2.SQL_HASH_VALUE
  and t1.ADDRESS= t2.SQL_ADDRESS 
  and t1.BUFFER_GETS  > 500000
  order by t1.BUFFER_GETS desc  
/
