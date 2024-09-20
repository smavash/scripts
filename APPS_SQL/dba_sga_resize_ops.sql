SELECT component, parameter, initial_size, final_size, status, 
          to_char(end_time ,'mm/dd/yyyy hh24:mi:ss') changed
     FROM v$sga_resize_ops
ORDER BY component;


SELECT component, min(final_size) low, (min(final_size/1024/1024)) lowMB,
          max(final_size) high, (max(final_size/1024/1024)) highMB
     FROM v$sga_resize_ops
 GROUP BY component
 ORDER BY component;


