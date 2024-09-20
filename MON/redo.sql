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
