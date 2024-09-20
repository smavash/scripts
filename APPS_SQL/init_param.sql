SELECT decode(substr (value,1,instr(value,',') -1) ,
                 null ,value ,
                 substr (value,1,instr(value,',') -1))  
  FROM   v$parameter
  WHERE  name = 'utl_file_dir';


SELECT name, value
  FROM v$parameter 
 WHERE name in ('db_cache_size', 'large_pool_size', 'java_pool_size',
                'shared_pool_size', 'streams_pool_size', 'sga_target', 
                'sga_max_size', 'statistics_level')

