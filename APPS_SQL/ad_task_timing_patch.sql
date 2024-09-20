select * from vijay_failed_jobs;

create or replace view vijay_failed_jobs as
--Collect all sql jobs which are failed in the last 30 days 
  select '' || decode(command,
                      'sqlplus_single',
                      'sqlplus',
                      'sqlplus',
                      'sqlplus',
                      'sql',
                      'sqlplus') || '' ||
         ' apps/aps @/app/appl/PROD/apps/apps_st/appl' || '' || PRODUCT || '' ||
         '/11.5.0/' || '' || SUBDIRECTORY || '' || '/' || '' || job_name || ' ' COMMAND,
         START_TIME
    from ad_task_timing
   where end_time is null
     and START_TIME > SYSDATE - 30
     and command like '%sql%'
  --Collect all fnd loader jobs which are failed in the last 30 days 
  UNION
  select ' FNDLOAD apps/apps ' || substr(arguments, 10) || ' ' COMMAND,
         start_time
    from ad_task_timing
   where end_time is null
     and START_TIME > SYSDATE - 30
     and (command = 'bin')
     and arguments like '%LOAD%'
  --Collect all attachment uploads which are failed in the last 30 days 
  UNION
  select ' FNDGFU apps/apps ' || substr(arguments, 10) || ' ' COMMAND,
         start_time
    from ad_task_timing
   where end_time is null
     and START_TIME > SYSDATE - 30
     and command = 'bin'
     and arguments not like '%UPLOAD%'
  --collect all odf jobs which are failed in the last 30 days 
  UNION
  select 'adodfcmp priv_schema=system/manager userid=inv/apps touser=apps/apps change_db=yes odffile=/ora/prod/prod10appl/' || '' ||
         PRODUCT || '' || '/11.5.0/' || '' || SUBDIRECTORY || '' || '/' || '' ||
         job_name || ' ' || arguments || ' ' COMMAND,
         start_time
    from ad_task_timing
   where end_time is null
     and START_TIME > SYSDATE - 30
     and command = 'odf';
