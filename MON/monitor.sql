REM 
REM START OF SQL
REM
set echo on
set timing on
set feedback on
set pagesize 132
set linesize 110
col username form a10
col program form a30
col how_many forma 9999
col machine form a25
col module form a50
--
rem show time
select to_char(sysdate, 'DD-MON-RR HH24:MI:SS') START_TIME from dual
/
rem Instance identification
select *
from v$instance
/
REM Summary of database connections
select s.module, s.machine, s.username, count(*) how_many
from (select distinct PROGRAM, PADDR, machine, username, module, inst_id from gV$SESSION) s,
gv$process p
where s.paddr = p.addr
and p.inst_id = s.inst_id
group by rollup(s.module,s.machine,s.username)
/
REM Connections by machine and instance 
select s.machine, s.username, s.module, s.inst_id, count(*) how_many
from (select distinct PROGRAM, PADDR, machine, username, module, inst_id from gV$SESSION) s,
gv$process p
where s.paddr = p.addr
and p.inst_id = s.inst_id
group by s.machine,s.username, s.module, s.inst_id
/
REM 
REM Get count of number of connected users
REM 
col user_name format a15
col first_connect format a18
col last_connect format a18
col How_many_user_sessions format 9999999999
col How_many_sessions format 9999999999
REM
REM Summary of how many users
REM 
select 'Number of user sessions : ' || count( distinct session_id) How_many_user_sessions
from icx_sessions icx
where disabled_flag != 'Y'
and PSEUDO_FLAG = 'N'
and (last_connect + decode(FND_PROFILE.VALUE('ICX_SESSION_TIMEOUT'), NULL,limit_time, 0,limit_time,FND_PROFILE.VALUE('ICX_SESSION_TIMEOUT')/60)/24) > sysdate 
and counter < limit_connects
/
REM 
REM END OF SQL
REM

