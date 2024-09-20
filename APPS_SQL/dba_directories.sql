select * from dba_directories

create directory 
DATA_PUMP_DIR_ORABIUPG
--DATA_PUMP_DIR_ORABIPOC
as  '/oracle/ExpImpBIPROD';
--as '/BIPOC/BACKUP';
GRANT read, write ON DIRECTORY DATA_PUMP_DIR_ORABIUPG to system;


GRANT EXP_FULL_DATABASE  to system;
grant EXEMPT ACCESS POLICY to system;
