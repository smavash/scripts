col PID format 9999
col "Local pid" format 99999
col "Remote pid" format 99999
col "Local user" format a10
col "Oracle user" format a11
col "Current PROGRAM" format a20
col "Remote PROGRAM" format a30
col "MACHINE" format a16
col "SID" format a10



select s.sid||','||s.serial#  "SID",
        p.username "Local user",p.spid "Local pid",s.PROCESS "Remote pid",
        MACHINE "MACHINE",
        s.username "Oracle user",
        ss.value "%CPU", 
 /* p.PROGRAM "Current PROGRAM", */
s.PROGRAM || ' ' || s.MODULE "Remote PROGRAM"
from v$process p ,v$session s, v$sesstat ss
where p.addr=s.paddr
and ss.statistic# in (select statistic# from v$statname where name = 'CPU used by this session') 
 and ss.sid = s.sid
order by 7,8
/

