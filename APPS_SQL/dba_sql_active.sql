Alter system kill session '3936,4990';
Alter system kill session '3904,19598';
Alter system kill session '3887,14458';
Alter system kill session '3943,16967';
Alter system kill session '3919,13970';



Alter system kill session '1836,6';


 select  
          'Alter system kill session '||''''||tB.sid||','||tB.serial#||''''||';', --tB.SID,tB.SERIAL#,
          sysdate,
          tB.SID,
          tB.SERIAL#,
          tB.MODULE,
          tB.ACTION,
          tB.PROGRAM,  
          tB.OSUSER,
          tB.MACHINE,
          tB.EVENT,
          'kill -9  '||tB.PROCESS ,
          tB.SQL_ADDRESS,
          tB.BLOCKING_SESSION,
          tB.BLOCKING_SESSION_STATUS,
          tB.SQL_ID,
          tB.STATE,
          tB.SECONDS_IN_WAIT/60 "Wait min",
          tB.WAIT_CLASS
          from v$session tB 
          where     
--program = 'dis51usr.exe'--

--tB.SID in (1756,2118)

--tB.SID = 8287

--tB.BLOCKING_SESSION is not null

--tB.PROCESS =       '20220'
--tB.MODULE like 'XXAU_REFRESH_MATERIALIZED_VIEW%'
-- tb.MODULE = 'ARXTWMAI'
         tB.status = 'ACTIVE'
--tB.BLOCKING_SESSION =1622
--tB.ACTION like '%TNV%'
--tB.MODULE like '%JGZZVATSP%'
--and machine = 'uaperp2'
;

select * from v$sql s1 where  s1.SQL_TEXT like '%EMAN%' ;
and module = 'APXPAWKB';

select 
*
--substr(s1.SQL_TEXT,1,9999), s1.SQL_ID, s1.MODULE  
from v$sql s1 
where 
SQL_TEXT like '%v$sql%';
--s1.SQL_ID = 'czkngybnp7vkj';






select 
      --       tB.sid||','||tB.SERIAL#,
             'Alter system kill session '||''''||tB.sid||','||tB.serial#||''''||';' "To Kill",
             'kill -9 '||tC.spid "LOCAL SPID",
             tB.status,
             substr(tA.sql_text,0,9000) sss,
             tA.MODULE,
             tB.ACTION,
             tB.USERNAME,
      --       tA.ACTION,
             tB.PROGRAM,  
             tB.OSUSER,
             tB.MACHINE,
             tB.PROCESS "Remote PID",
             tA.FETCHES,
             tA.EXECUTIONS,
             tA.DISK_READS,
             tA.BUFFER_GETS,
             tA.ROWS_PROCESSED,
             tA.OPTIMIZER_MODE,
             tA.OPTIMIZER_COST,
             tB.SQL_ADDRESS,
             ta.HASH_VALUE
      from 
           v$sql tA,
           v$session tB,  
           v$process tC
      where          
 tB.status = 'ACTIVE'  and 
      tB.paddr = tC.addr
        and tA.hASH_VALUE = tB.SQL_HASH_VALUE
        and tA.ADDRESS= tB.SQL_ADDRESS
-- and tC.SPID in ( 16068716 ,17764456,16822276)
--and tC.SPID = 14679
--   and sid  in (3960)
  --in  ( SELECT s.sid FROM v$session s, v$transaction t WHERE s.taddr = t.addr and t.used_ublk > 5)
--       in    ( SELECT a.sid FROM v$session a, v$sort_usage b, v$sqlarea c WHERE a.saddr = b.session_addr AND c.address= a.sql_address AND c.hash_value = a.sql_hash_value and  b.blocks > 300 )
      --- and tA.HASH_VALUE in ( select distinct  HASH_VALUE from v$vpd_policy, v$sql where HASH_VALUE=v$vpd_policy.SQL_HASH and v$vpd_policy.POLICY like 'XXTSJTFJTF_NOTES_B%'-- and  substr(tA.sql_text,0,11000)   like '%WF%'
      --and (  UPPER( substr(tA.sql_text,0,11000) )  like '%UPDATE%' or  UPPER( substr(tA.sql_text,0,11000) )  like '%INSERT%' or  UPPER( substr(tA.sql_text,0,11000) )  like '%DELETE%')
      --and tB.MACHINE in ('eaplprod','eaplsrv')
  --and UPPER (substr(tA.sql_text,0,3000))   like '%MTL%'
  --and tB.MACHINE  like 'ECI_DOMAIN%'
  --and tB.OSUSER like '%ftjerp%'
      --and tA.MODULE  like '%r2i.isup%'
      --and tA.MODULE  like '%Disco%'FND_DESCR_FLEX_COLUMN_USAG_A 
--  and tA.MODULE like 'CMCTCM%'
--   and tA.MODULE like '%XXARINV_ARC%'
  --and tB.SQL_ADDRESS = '07000000518064D8'
  --    and tA.HASH_VALUE = 2080262863
    --  order by 5,  tA.BUFFER_GETS desc -- I/O
      --tA.EXECUTIONS
      --ta.MODULE    
--      and tB.program like 'plsqldev%'
      ;
      

