
 select distinct 'exec dbms_stats.gather_table_stats (ownname => '''|| owner || ''', tabname => '''|| table_name || ''', estimate_percent => 100, method_opt => ''for all columns size auto'', cascade => true, degree => 24);'
 from dba_TAB_COL_STATISTICS
 where HISTOGRAM != 'NONE'
 and owner not in ('SYS', 'MDSYS', 'SYSTEM','XDB','SYS','MDSYS','SYSTEM','XDB','CTXSYS','OLAPSYS','ORDSYS', 'DBSNMP')
;

select distinct 'exec dbms_stats.gather_table_stats (ownname => '''|| owner || ''', tabname => '''|| table_name || ''', estimate_percent => 100, method_opt => ''for all columns size auto'', cascade => true, degree => 32);'
 from dba_TAB_COL_STATISTICS
 where 
 owner not in ('SYS', 'MDSYS', 'SYSTEM','XDB','SYS','MDSYS','SYSTEM','XDB','CTXSYS','OLAPSYS','ORDSYS', 'DBSNMP')
