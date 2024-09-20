SELECT u.user_name,u.user_id, u.description, tr.responsibility_name, tr.description,u.end_date,g.END_DATE
  FROM FND_USER_RESP_GROUPS g, FND_RESPONSIBILITY_TL tr, fnd_user u
 WHERE g.responsibility_id = tr.responsibility_id
   and g.responsibility_application_id = tr.application_id
   and tr.language = 'US'
         and u.user_id = g.user_id
         and u.user_name like 'SYSADMIN%'
order by u.user_name, tr.responsibility_name;


