select 
  name, 
  path, version, serial_number, last_synchronized
  from fnd_oam_context_files;

select owner, table_name, stattype_locked 
from dba_tab_statistics  where stattype_locked = 'ALL';


 select owner, table_name, stattype_locked
  from dba_tab_statistics
  where stattype_locked is not null
  and owner<>'SYS'
  
  
  exec dbms_stats.unlock_table_stats('APPLSYS','FND_CP_GSM_OPP_AQTBL');
