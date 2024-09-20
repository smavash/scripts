col c format 999,999,999,999 heading 'Wait Block'
col f format 99999 heading 'File Number'
col n format a50 heading 'File Name'
SELECT 
	count c, file# f, name n
FROM 
	x$kcbfwait, v$datafile
WHERE 
	indx + 1 = file#
ORDER BY count
/
/*
select t2.sid,t3.spid,t1.sql_text,t1.MODULE,t1.ACTION,t2.PROGRAM,t1.FETCHES,t1.EXECUTIONS,t1.DISK_READS,t1.BUFFER_GETS,t1.ROWS_PROCESSED,t1.OPTIMIZER_MODE,t1.OPTIMIZER_COST 
from v$sql t1,
     v$session t2,
     v$process t3
where t2.status='ACTIVE'
  and t2.paddr = t3.addr
  and t1.hASH_VALUE = t2.SQL_HASH_VALUE
  and t1.ADDRESS= t2.SQL_ADDRESS 
  order by t1.BUFFER_GETS desc  
/
*/
