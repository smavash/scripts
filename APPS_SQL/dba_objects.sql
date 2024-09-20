select 
do.owner,
do.object_name,
do.object_type,
do.status,
do.last_ddl_time
from dba_objects do
where 
--do.last_ddl_time > TO_DATE('03-03-2011 08:00:00', 'DD-MM-YYYY HH24:MI:SS')
-- do.last_ddl_time > TO_DATE('15-12-2008 00:00:00', 'DD-MM-YYYY HH24:MI:SS')
 do.status  <> 'VALID'

-- and do.object_name   like 'CSD%'
--and   do.object_name   not like '%EUL5%'
-- and do.object_name  not like    '%DISCO%'
-- do.object_name like 'XXINV_KIT_RETURN%'
-- and do.owner = 'SYS'
-- and do.object_type not in ('TABLE','INDEX' )
order by do.last_ddl_time desc
