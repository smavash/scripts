prompt ********************************************************************************
prompt Abstract: 11i - Scripts to Retrieve SQL Statement Causing the Process to Hang
prompt Date: 11-AUG-2000
prompt Description: Usage is intended to retrieve the SQL in process when forms in Oracle Applications hang or a severe performance issue is encountered. The first script returns the active sessions on the system, and the next displays the sql that is hanging.
prompt EMail: daniel.miller@oracle.com
prompt Product_Code: 510
prompt Sub_Component: AOL
prompt ********************************************************************************
set linesize 130
prompt The following script returns the active sessions on the system.
prompt Note down the session_id (SID) for the forms process.

col sid format 9999
col serial# format 99999
col username heading 'User' format a13
col osuser format a10 trunc
col process format a8 trunc
col program format a15 trunc
col lt format a14
select s.sid, s.serial#, to_char(logon_time ,'mm/dd hh24:mi:ss') lt, 
       s.username, s.osuser, p.spid, s.program
from v$session s, v$process p
where s.status = 'ACTIVE'
and s.username is not null
and s.paddr = p.addr
order by 3
/

prompt Using the SID from the above script, run the following SQL which 
prompt displays the SQL that is hanging.
prompt To determine the correct SID, compare the time stamps on the log
prompt file of the process being investigated.  

spool <path/filename>
set veri off
select /*+ ORDERED */ sql_text
from v$session s, v$sqltext t
where t.address = s.sql_address
and s.sid = &1 
order by piece
/
prompt Run the above script four times at fifteen minute intervals.  If the 
prompt SQL changes then the process is not hung but reflects a performance issue.
prompt in which case a trace with time statistics will be more valuable.
prompt There may be instances where the SQL will change but will constantly cycle 
prompt through the same two statements at infinitum which can be considered 
prompt a hung process.


