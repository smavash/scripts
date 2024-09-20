select count(*)
from dba_tables
where table_name not in 
(select distinct table_name
from dba_constraints
where constraint_type in ('P','U'))
and owner not in ('SYS','SYSTEM','DBSNMP','SYSMAN','SYSAUX', 'OUTLN','MDSYS','ODM_MTR','SSOSDK','ORDSYS',
'SQLTXPLAIN','SCOTT','OLAPSYS','TSMSYS','DMSYS')
and table_name not like '%GLT%'


select owner || '.' || table_name
from dba_tables
where table_name not in 
(select distinct table_name
from dba_constraints
where constraint_type in ('P','U'))
and owner like 'XX%'
order by 1 desc


and table_name not like '%GLT%'



select distinct owner
from dba_tables
where table_name not in 
(select table_name
from dba_constraints
where constraint_type = 'P')
and owner not in ('SYS','SYSTEM','DBSNMP','SYSMAN','SYSAUX', 'OUTLN','MDSYS','ODM_MTR','SSOSDK','ORDSYS',
'SQLTXPLAIN','SCOTT','OLAPSYS','TSMSYS','DMSYS',');

