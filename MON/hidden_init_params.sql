set linesize 140
set pagesize 999


col Parameter format a35
col "Session Value" format  a25
col "Instance Value" format  a25
select a.ksppinm  "Parameter", b.ksppstvl "Session Value", c.ksppstvl "Instance Value"
  from x$ksppi a, x$ksppcv b, x$ksppsv c
 where a.indx = b.indx and a.indx = c.indx
   and substr(ksppinm,1,1)='_'
order by a.ksppinm;

