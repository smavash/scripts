select 'add trandata ' || owner || '.' || table_name
from dba_tables
where table_name not in 
(
select table_name
from dba_log_groups
)
and owner not in ('SYS','SYSTEM','DBSNMP','SYSMAN','SYSAUX', 'OUTLN','MDSYS','ODM_MTR','SSOSDK','ORDSYS',
'SQLTXPLAIN','SCOTT','OLAPSYS','TSMSYS','DMSYS','CTXSYS','XDB')
and table_name not like '%GLT%' and table_name not like 'MLOG$%'
and table_name not like 'AQ$%' and table_name not like '%$%' and table_name not like '%TEMP%' 
and table_name not like '%IOT%' and table_name not like '%GT%' and table_name not like '%TMP%'
order by 1 asc