SELECT  substr(ln.name, 1, 20), gets, misses, immediate_gets, immediate_misses 
FROM v$latch l, v$latchname ln 
WHERE   ln.name in ('redo allocation', 'redo copy') 
                and ln.latch# = l.latch#; 
                
                
SELECT name, value 
FROM v$sysstat 
WHERE name = 'redo log space requests'; 
                
ALTER DATABASE ADD LOGFILE MEMBER
'/db/oradata/PROD/data/log05b.dbf' TO GROUP 5;

select 
count(*) 
from 
v$log_history
where first_time > to_date('01-Dec-10 10:00:00','dd-mon-yy hh24:mi:ss')
and first_time < to_date('01-Dec-10 13:00:00','dd-mon-yy hh24:mi:ss')
;



select 
       MAX(first_time) ord, 
       to_char(first_time,'DD-MON-YYYY') date_,
       count(recid) no, count(recid) *   1048.570  no_size
from 
v$log_history
where first_time > to_date('03-Nov-10 00:00:00','dd-mon-yy hh24:mi:ss')
group by to_char(first_time,'DD-MON-YYYY')
order by ord 
/


alter database add logfile group 2 
( '/db/oraredo2/PROD/log02a.dbf','/db/oraredo2/PROD/log02b.dbf') size 850m;

alter database add logfile group 4 
( '/db/oradata/PROD/data/log04a.dbf','/db/oradata/PROD/data/log04b.dbf') size 850m;

select v1.group#, v1.STATUS, member, sequence#, first_change#
  from v$log v1, v$logfile v2
 where v1.group# = v2.group#;

alter system switch logfile;

alter database drop logfile group 2;
alter database drop logfile group 3;

alter system switch logfile;
Alter system archive log current;
ALTER SYSTEM ARCHIVE LOG ALL;

alter database add logfile group 3 
( '/db/oradata/PROD/data/log03a.dbf','/db/oradata/PROD/data/log03b.dbf') size 850m;


alter database drop logfile group 5;


alter database add logfile group 1 
( '/db/oraredo1/PROD/log01a.dbf','/db/oraredo1/PROD/log01b.dbf') size 850m;



alter database add logfile group 5 
( '/db/oradata/PROD/data/log05a.dbf','/db/oradata/PROD/data/log05b.dbf') size 850m;



select * from v$backup 

where status = 'ACTIVE';


alter database add logfile group 5 
( '/dwh/data/oradata/BIDWH_PR/log05a.dbf','/dwh/data/oradata/BIDWH_PR/log05b.dbf') size 1000m;
