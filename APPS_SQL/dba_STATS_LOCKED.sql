select OWNER,TABLE_NAME, STATTYPE_LOCKED 
from dba_tab_statistics 
where owner !='SYS' 
and STATTYPE_LOCKED is not null 
order by 2;

exec apps.FND_STATS.GATHER_TABLE_STATS( 'APPLSYS','FND_SOA_JMS_OUT' ,20 ,1);
exec apps.FND_STATS.GATHER_TABLE_STATS( 'APPLSYS','FND_SOA_JMS_IN' ,20 ,1);
exec apps.FND_STATS.GATHER_TABLE_STATS( 'APPLSYS','FND_CP_GSM_IPC_AQTBL' ,20 ,1);

exec dbms_stats.unlock_table_stats('APPLSYS', 'FND_SOA_JMS_OUT');
exec dbms_stats.unlock_table_stats('APPLSYS', 'FND_SOA_JMS_IN');
exec dbms_stats.unlock_table_stats('APPLSYS', 'FND_CP_GSM_IPC_AQTBL');


