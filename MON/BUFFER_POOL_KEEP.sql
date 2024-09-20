prompt The following will size your init.ora KEEP POOL,

prompt based on Oracle8 KEEP Pool assignment values

prompt

 

select
'BUFFER_POOL_KEEP = ('||trunc(sum(s.blocks)*1.2)||',2)'
from
   dba_segments s
where
   s.buffer_pool = 'KEEP'
;


