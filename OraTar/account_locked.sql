select profile , resource_name, limit from dba_profiles where resource_name like '%FAIL%'; 
select username, profile from dba_users where username='APPS'; 
select username, profile from dba_users where username='APPLSYS'; 




alter profile AD_PATCH_MONITOR_PROFILE limit failed_login_attempts unlimited;
alter profile default limit failed_login_attempts unlimited password_lock_time 1/1440;
alter user apps account unlock;


