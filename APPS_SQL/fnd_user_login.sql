select u.user_name,
       u.description,
       ff.FULL_NAME,
       u.last_logon_date,
       U.END_DATE
from fnd_user u,
       per_people_x ff
where 1 = 1
   and u.employee_id = ff.PERSON_ID(+)
   and u.last_logon_date > sysdate - 90
   and (U.END_DATE IS  NULL OR U.END_DATE > SYSDATE)
 

        ;


select * from fnd_nodes;


select CONCURRENT_QUEUE_NAME, CONTROL_CODE , TARGET_NODE, NODE_NAME 
from FND_CONCURRENT_QUEUES;

select   u.user_name, u.description , u.last_logon_date , u.end_date
from     fnd_user u
where    
--u.last_logon_date < sysdate - 90 
-- u.last_logon_date is null
 u.end_date is null or  u.end_date > SYSDATE
-- u.user_name like 'SMA%'
order by 3 desc



