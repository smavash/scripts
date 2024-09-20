select substr(s1.SQL_TEXT,1,999)  from v$sql s1 where SQL_TEXT like 'select%dba%hist%';

select substr(s1.SQL_TEXT,1,9999), s1.SQL_ID  from v$sql s1 where SQL_TEXT like 'insert%GL_JE_HEADER%';

select substr(s1.SQL_TEXT,1,9999), s1.SQL_ID  from v$sql s1 where SQL_TEXT like 'insert%GL_JE_LINES%';


select count(*) from v$sql;



SELECT * FROM 
(SELECT substr(sql_text,1,60) sql,
        sharable_mem, executions, hash_value,address
   FROM V$SQLAREA
  WHERE sharable_mem > 10000
 ORDER BY sharable_mem DESC)
WHERE rownum <= 10;


SELECT sql_text "Stmt", count(*),
sum(sharable_mem)/1024/1024 "Mem - MB",
sum(users_opening) "Open",
sum(executions) "Exec"
FROM v$sql 
--where (sql_text like '%fnd_user%' or sql_text like '%FND_USER%')
--and sql_text not like '%SELECT%'
GROUP BY sql_text
HAVING sum(sharable_mem) > 409600
order by 3 desc; 


SELECT 
sum(sharable_mem)/1024/1024 "Mem - MB"
FROM v$sql;




select substr(s1.SQL_TEXT,1,70),count(*)  from v$sql s1
group by  substr(s1.SQL_TEXT,1,70)
having count(*) > 1
order by count(*) desc;



select '#'||sql_text||'#',sql_id,optimizer_mode,hash_value,address,plan_hash_value,module,action 
from  v$sql s1 where s1.SQL_TEXT like '%OPT_DYN_SAMP%';

