select * from v$db_cache_advice;

select * from v$shared_pool_advice;

select * from v$pga_target_advice;

select * from v$resource_limit;

select count(*) from v$process;

select * from   V$SQL_SHARED_CURSOR;

select sum(value) from v$sga;

select sum(bytes) from v$sgastat;

select sum(current_size) from v$sga_dynamic_components;

select * from v$sga_dynamic_free_memory;



Select 
sum(bytes)/1024/1024 "Total Mem MB" 
from v$sgastat where pool='shared pool'; 





select 
   component, 
   oper_type, 
   oper_mode, 
   initial_size/1024/1024 "Initial", 
   TARGET_SIZE/1024/1024  "Target", 
   FINAL_SIZE/1024/1024   "Final", 
   status 
from 
   v$sga_resize_ops;


select 
   component, 
   current_size/1024/1024 "CURRENT_SIZE", 
   min_size/1024/1024 "MIN_SIZE",
   user_specified_size/1024/1024 "USER_SPECIFIED_SIZE", 
   last_oper_type "TYPE" 
from 
   v$sga_dynamic_components;



 
 




