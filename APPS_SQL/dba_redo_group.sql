select l.group#, lf.member, l.bytes/1024/1024 mb,  l.status, l.archived
from v$logfile lf, v$log l
where l.group# = lf.group#
order by 1, 2;


alter database drop logfile group 1;
alter database drop logfile group 2;
alter database drop logfile group 5;

alter database drop logfile group 2;

ALTER DATABASE ADD LOGFILE GROUP 1 ('/oracle1/TST3/oradata/log01a.dbf') SIZE 1024M
ALTER DATABASE ADD LOGFILE GROUP 2 ('/oracle1/TST3/oradata/log02a.dbf') SIZE 1024M
ALTER DATABASE ADD LOGFILE GROUP 4 ('/oracle1/TST3/oradata/log04a.dbf') SIZE 1024M;
ALTER DATABASE ADD LOGFILE GROUP 5 ('/oracle1/TST3/oradata/log05a.dbf') SIZE 1024M;
ALTER DATABASE ADD LOGFILE GROUP 6 ('/oracle1/TST3/oradata/log06a.dbf') SIZE 1024M;
ALTER DATABASE ADD LOGFILE GROUP 7 ('/oracle1/TST3/oradata/log07a.dbf') SIZE 1024M;
ALTER DATABASE ADD LOGFILE GROUP 8 ('/oracle1/TST3/oradata/log08a.dbf') SIZE 1024M;
ALTER DATABASE ADD LOGFILE GROUP 3 ('/oracle1/TST3/oradata/log03a.dbf') SIZE 1024M;



