select 'You may need to increase the SHARED_POOL_RESERVED_SIZE' Description,
       'Request Failures = '||REQUEST_FAILURES  Logic
from    v$shared_pool_reserved
where   REQUEST_FAILURES > 0
and     0 != (
        select  to_number(VALUE) 
        from    v$parameter 
        where   NAME = 'shared_pool_reserved_size')
union
select 'You may be able to decrease the SHARED_POOL_RESERVED_SIZE' Description,
       'Request Failures = '||REQUEST_FAILURES Logic
from    v$shared_pool_reserved
where   REQUEST_FAILURES < 5
and     0 != ( 
        select  to_number(VALUE) 
        from    v$parameter 
        where   NAME = 'shared_pool_reserved_size');
        




select cr_shared_pool_size,
       sum_obj_size,
       sum_sql_size,
       sum_user_size,
       (sum_obj_size + sum_sql_size + sum_user_size) * 1.3 min_shared_pool
  from (select sum(sharable_mem) sum_obj_size
          from v$db_object_cache
         where type <> 'CURSOR'),
       (select sum(sharable_mem) sum_sql_size from v$sqlarea),
       (select sum(250 * users_opening) sum_user_size from v$sqlarea),
       (select to_Number(b.ksppstvl) cr_shared_pool_size
          from x$ksppi a, x$ksppcv b, x$ksppsv c
         where a.indx = b.indx
           and a.indx = c.indx
           and a.ksppinm = '__shared_pool_size');
           

SELECT KSMCHCLS CLASS,
       COUNT(KSMCHCLS) NUM,
       SUM(KSMCHSIZ) SIZ,
       To_char(((SUM(KSMCHSIZ) / COUNT(KSMCHCLS) / 1024)), '999,999.00') || 'k' "AVG SIZE"
  FROM X$KSMSP
 GROUP BY KSMCHCLS;