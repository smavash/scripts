  select 
total.tablespace_name , 
total.file_name                             fname, 
trunc( total.bytes/1024/1024) tot_size,
 nvl(sum(free.bytes)/1024/1024,0)                 avasiz, 
(1-nvl(sum(free.bytes),0)/total.bytes)*100  pctusd 
from 
  dba_data_files  total, 
  dba_free_space  free 
where 
      total.tablespace_name = free.tablespace_name(+) 
  and total.file_id=free.file_id(+)
  group by 
  total.tablespace_name, 
  total.file_name,
    total.bytes
order by 4 desc
;
