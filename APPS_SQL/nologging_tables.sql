select table_owner || '.' || table_name from
(
select distinct table_owner, table_name from dba_tab_partitions
where logging = 'NO'
union all
select distinct owner, table_name from dba_tables
where logging = 'NO'
) where table_owner not in ('SYS','SYSTEM','DBSNMP','SYSMAN','SYSAUX', 'OUTLN','MDSYS','ODM_MTR','SSOSDK','ORDSYS',
'SQLTXPLAIN','SCOTT','OLAPSYS','TSMSYS','DMSYS','CTXSYS','XDB','MSC') and table_name not like '%GLT%' and table_name not like 'MLOG$%'
and table_name not like 'AQ$%' and table_name not like '%$%' and table_name not like '%TEMP%' 
and table_name not like '%IOT%' and table_name not like '%GT%' and table_name not like '%TMP%'
order by 1