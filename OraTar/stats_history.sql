-- Show retention time of history 
select dbms_stats.get_stats_history_retention from dual;
select dbms_stats.get_stats_history_availability from dual;


--  will ensure that statistics history will be retained for at least 30 days
exec dbms_stats.alter_stats_history_retention(60);  
