SELECT *
FROM FND_CONC_REQ_SUMMARY_V a
WHERE 1=1
and A.RESPONSIBILITY_ID=50670 -- Receivable Manager
and a.CONCURRENT_PROGRAM_ID=48126 --Create Accounting
and (trunc(request_date) >= trunc(sysdate-1))
and (REQUESTED_BY = 1337) -- TNVINTER
order by REQUEST_ID DESC




SELECT ROWID,
       INCOMPATIBILITY_TYPE,
       TO_RUN_TYPE,
       RUNNING_APPLICATION_ID,
       RUNNING_CONCURRENT_PROGRAM_ID,
       TO_RUN_APPLICATION_ID,
       TO_RUN_CONCURRENT_PROGRAM_ID,
       LAST_UPDATE_DATE,
       LAST_UPDATED_BY,
       CREATION_DATE,
       CREATED_BY,
       LAST_UPDATE_LOGIN,
       UPDATE_SECURITY_GROUP_ID,
       RUNNING_TYPE
  FROM FND_CONCURRENT_PROGRAM_SERIAL
 WHERE TO_RUN_CONCURRENT_PROGRAM_ID in
       (select CONCURRENT_PROGRAM_ID
          from FND_CONCURRENT_PROGRAMS_VL
         where USER_CONCURRENT_PROGRAM_NAME =
               'Account Analysis - (180 Char) (XML) - Not Supported: Reserved For Future Use')
   and (RUNNING_APPLICATION_ID = 101)
   and (RUNNING_CONCURRENT_PROGRAM_ID = 50784)
 order by to_run_application_id, to_run_concurrent_program_id



SELECT a2.application_name,
       a1.user_concurrent_program_name,
       DECODE(running_type, 'P', 'Program', 'S', 'Request set', 'UNKNOWN') "Type",
       b2.application_name "Incompatible App",
       b1.user_concurrent_program_name "Incompatible_Prog",
       DECODE(to_run_type, 'P', 'Program', 'S', 'Request set', 'UNKNOWN') incompatible_type
  FROM apps.fnd_concurrent_program_serial cps,
       apps.fnd_concurrent_programs_tl    a1,
       apps.fnd_concurrent_programs_tl    b1,
       apps.fnd_application_tl            a2,
       apps.fnd_application_tl            b2
 WHERE a1.application_id = cps.running_application_id
   AND a1.concurrent_program_id = cps.running_concurrent_program_id
   AND a2.application_id = cps.running_application_id
   AND b1.application_id = cps.to_run_application_id
   AND b1.concurrent_program_id = cps.to_run_concurrent_program_id
   AND b2.application_id = cps.to_run_application_id
   AND a1.language = 'US'
   AND a2.language = 'US'
   AND b1.language = 'US'
   AND b2.language = 'US'
AND a1.user_concurrent_program_name = 'Tnuva - Receivables - Out Interfaces';
