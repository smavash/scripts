#!/bin/ksh



DATE=`date +"%d-%b-%Y-%H%M"`
DATE_M=`date +"%OM"`
DATE_W=`date +"%a"`
DATE_H=`date +"%H"`
ALL_REPORTS="/tmp"
REPORT="${ALL_REPORTS}/CManalyse__Weekly_${DATE}.txt"


sqlplus -s apps/$APPLPWD <<EOF

set pagesize 60 echo off feed off veri off linesize 80
set termout off
col CONCURRENT_QUEUE_NAME format a10 heading 'Manager' trunc
col ucpname format a35 trunc
col minwait format 999.99 head 'Min|wait' noprint
col maxwait format 999.99 head 'Max|wait' noprint
col avgwait format 999.99 head 'Avg|wait'
col mintime format 999.99 head 'Min|Time' noprint
col maxtime format 999.99 head 'Max|Time' noprint
col avgtime format 999.99 head 'Avg|Time'
col sumtimemin format 99999.99 head "Count*Avg"
col count format 99999

break on report
compute sum of sumtimemin  on report
compute sum of Count  on report

set termout off
col from_day new_value from_day
col to_day new_value to_day
select Decode('$1','Day',Sysdate-1,Sysdate-8) from_day,Sysdate to_day
from dual
/
set termout on
rem define day=Trunc(Sysdate)
define from_h=$2
define to_h=$3

Spool $REPORT

ttitle skip 1 center "ANALYZE CONCURRENT MANAGERS REPORT" skip 1 -
       center "From &from_day to &to_day Hours from &from_h to &to_h" skip 1

SELECT CONCURRENT_QUEUE_NAME,
      DECODE (Fcr.DESCRIPTION,
      NULL,
      Fcp.USER_CONCURRENT_PROGRAM_NAME,
      Fcr.DESCRIPTION||' ('||Fcp.USER_CONCURRENT_PROGRAM_NAME||')') ucpname,
       COUNT(*) Count,
       MIN((Fcr.ACTUAL_START_DATE
           -Fcr.REQUESTED_START_DATE)*1440)                     minwait, 
       AVG((Fcr.ACTUAL_START_DATE
           -Fcr.REQUESTED_START_DATE)*1440)                     avgwait, 
       MAX((Fcr.ACTUAL_START_DATE
           -Fcr.REQUESTED_START_DATE)*1440)                     maxwait, 
       MIN((Fcr.ACTUAL_COMPLETION_DATE
           -Fcr.ACTUAL_START_DATE)*1440)                        mintime, 
       AVG((Fcr.ACTUAL_COMPLETION_DATE
           -Fcr.ACTUAL_START_DATE)*1440)                        avgtime, 
       MAX((Fcr.ACTUAL_COMPLETION_DATE
           -Fcr.ACTUAL_START_DATE)*1440)                        maxtime, 
       COUNT(*)*AVG((Fcr.ACTUAL_COMPLETION_DATE
                    -Fcr.ACTUAL_START_DATE)*1440)               sumtimemin
 from Fnd_Concurrent_Queues Fcq,
       Fnd_Concurrent_Requests Fcr,
       Fnd_Concurrent_Programs_vl Fcp,
       Fnd_Concurrent_Processes Fpro
 where
       Fcr.Controlling_Manager = Concurrent_Process_Id       And
      (Fcq.Concurrent_Queue_Id = Fpro.Concurrent_Queue_Id    And
       Fcq.Application_Id      = Fpro.Queue_Application_Id ) And
      (Fcr.Concurrent_Program_Id = Fcp.Concurrent_Program_Id And
       Fcr.Program_Application_Id = Fcp.Application_Id )     And
(TRUNC(Fcr.REQUEST_DATE) BETWEEN '&from_day' AND '&to_day'
 AND TO_CHAR(Fcr.REQUEST_DATE,'Day') <> 'Saturday'
 AND TO_CHAR(Fcr.REQUEST_DATE, 'hh24') BETWEEN &from_h 
                                       AND &to_h)
 AND  Fcr.CONCURRENT_PROGRAM_ID=Fcp.CONCURRENT_PROGRAM_ID
Having COUNT(*)*AVG((Fcr.ACTUAL_COMPLETION_DATE
                    -Fcr.ACTUAL_START_DATE)*1440) > 1
GROUP BY CONCURRENT_QUEUE_NAME,
      DECODE (Fcr.DESCRIPTION,
      NULL,
      Fcp.USER_CONCURRENT_PROGRAM_NAME,
      Fcr.DESCRIPTION||' ('||Fcp.USER_CONCURRENT_PROGRAM_NAME||')')
ORDER BY COUNT(*)*AVG((Fcr.ACTUAL_COMPLETION_DATE
                      -Fcr.ACTUAL_START_DATE)*1440) DESC
/

Define minutes=2
ttitle skip 1 center "ANALYZE CONCURRENT MANAGERS REPORT" skip 1 -
       center "From &from_day to &to_day Hours from &from_h to &to_h" skip 1 -
       center "Requests that are wait more then &minutes minutes" skip 1

SELECT CONCURRENT_QUEUE_NAME,
      DECODE (Fcr.DESCRIPTION,
      NULL,
      Fcp.USER_CONCURRENT_PROGRAM_NAME,
      Fcr.DESCRIPTION||' ('||Fcp.USER_CONCURRENT_PROGRAM_NAME||')') ucpname,
       COUNT(*) Count,
       MIN((Fcr.ACTUAL_START_DATE
           -Fcr.REQUESTED_START_DATE)*1440)                     minwait, 
       AVG((Fcr.ACTUAL_START_DATE
           -Fcr.REQUESTED_START_DATE)*1440)                     avgwait, 
       MAX((Fcr.ACTUAL_START_DATE
           -Fcr.REQUESTED_START_DATE)*1440)                     maxwait, 
       MIN((Fcr.ACTUAL_COMPLETION_DATE
           -Fcr.ACTUAL_START_DATE)*1440)                        mintime, 
       AVG((Fcr.ACTUAL_COMPLETION_DATE
           -Fcr.ACTUAL_START_DATE)*1440)                        avgtime, 
       MAX((Fcr.ACTUAL_COMPLETION_DATE
           -Fcr.ACTUAL_START_DATE)*1440)                        maxtime, 
       COUNT(*)*AVG((Fcr.ACTUAL_COMPLETION_DATE
                    -Fcr.ACTUAL_START_DATE)*1440)               sumtimemin
 from Fnd_Concurrent_Queues Fcq,
       Fnd_Concurrent_Requests Fcr,
       Fnd_Concurrent_Programs_vl Fcp,
       Fnd_Concurrent_Processes Fpro
 where
       Fcr.Controlling_Manager = Concurrent_Process_Id       And
      (Fcq.Concurrent_Queue_Id = Fpro.Concurrent_Queue_Id    And
       Fcq.Application_Id      = Fpro.Queue_Application_Id ) And
      (Fcr.Concurrent_Program_Id = Fcp.Concurrent_Program_Id And
       Fcr.Program_Application_Id = Fcp.Application_Id )     And
(TRUNC(Fcr.REQUEST_DATE) BETWEEN '&from_day' AND '&to_day'
 AND TO_CHAR(Fcr.REQUEST_DATE,'Day') <> 'Saturday'
 AND TO_CHAR(Fcr.REQUEST_DATE, 'hh24') BETWEEN &from_h 
                                       AND &to_h)
 AND  Fcr.CONCURRENT_PROGRAM_ID=Fcp.CONCURRENT_PROGRAM_ID
Having AVG((Fcr.ACTUAL_START_DATE
           -Fcr.REQUESTED_START_DATE)*1440) > &minutes
GROUP BY CONCURRENT_QUEUE_NAME,
      DECODE (Fcr.DESCRIPTION,
      NULL,
      Fcp.USER_CONCURRENT_PROGRAM_NAME,
      Fcr.DESCRIPTION||' ('||Fcp.USER_CONCURRENT_PROGRAM_NAME||')')
ORDER BY COUNT(*)*AVG((Fcr.ACTUAL_COMPLETION_DATE
             -Fcr.ACTUAL_START_DATE)*1440) Desc
/

Define minutes=10
ttitle skip 1 center "ANALYZE CONCURRENT MANAGERS REPORT" skip 1 -
       center "From &from_day to &to_day Hours from &from_h to &to_h" skip 1 -
       center "Requests in 'Heavy Jobs' queue and that ran less then &minutes minutes" skip 1

SELECT CONCURRENT_QUEUE_NAME,
      DECODE (Fcr.DESCRIPTION,
      NULL,
      Fcp.USER_CONCURRENT_PROGRAM_NAME,
      Fcr.DESCRIPTION||' ('||Fcp.USER_CONCURRENT_PROGRAM_NAME||')') ucpname,
       COUNT(*) Count,
       MIN((Fcr.ACTUAL_START_DATE
           -Fcr.REQUESTED_START_DATE)*1440)                     minwait, 
       AVG((Fcr.ACTUAL_START_DATE
           -Fcr.REQUESTED_START_DATE)*1440)                     avgwait, 
       MAX((Fcr.ACTUAL_START_DATE
           -Fcr.REQUESTED_START_DATE)*1440)                     maxwait, 
       MIN((Fcr.ACTUAL_COMPLETION_DATE
           -Fcr.ACTUAL_START_DATE)*1440)                        mintime, 
       AVG((Fcr.ACTUAL_COMPLETION_DATE
           -Fcr.ACTUAL_START_DATE)*1440)                        avgtime, 
       MAX((Fcr.ACTUAL_COMPLETION_DATE
           -Fcr.ACTUAL_START_DATE)*1440)                        maxtime, 
       COUNT(*)*AVG((Fcr.ACTUAL_COMPLETION_DATE
                    -Fcr.ACTUAL_START_DATE)*1440)               sumtimemin
 from Fnd_Concurrent_Queues Fcq,
       Fnd_Concurrent_Requests Fcr,
       Fnd_Concurrent_Programs_vl Fcp,
       Fnd_Concurrent_Processes Fpro
 where
       Fcr.Controlling_Manager = Concurrent_Process_Id       And
      (Fcq.Concurrent_Queue_Id = Fpro.Concurrent_Queue_Id    And
       Fcq.Application_Id      = Fpro.Queue_Application_Id ) And
      (Fcr.Concurrent_Program_Id = Fcp.Concurrent_Program_Id And
       Fcr.Program_Application_Id = Fcp.Application_Id )     And
(TRUNC(Fcr.REQUEST_DATE) BETWEEN '&from_day' AND '&to_day'
 AND TO_CHAR(Fcr.REQUEST_DATE,'Day') <> 'Saturday'
 AND TO_CHAR(Fcr.REQUEST_DATE, 'hh24') BETWEEN &from_h 
                                       AND &to_h)
 AND  Fcr.CONCURRENT_PROGRAM_ID=Fcp.CONCURRENT_PROGRAM_ID
 And  CONCURRENT_QUEUE_NAME = 'Heavy Jobs'
Having AVG((Fcr.ACTUAL_COMPLETION_DATE
                    -Fcr.ACTUAL_START_DATE)*1440) < &minutes
GROUP BY CONCURRENT_QUEUE_NAME,
      DECODE (Fcr.DESCRIPTION,
      NULL,
      Fcp.USER_CONCURRENT_PROGRAM_NAME,
      Fcr.DESCRIPTION||' ('||Fcp.USER_CONCURRENT_PROGRAM_NAME||')') 
ORDER BY AVG((Fcr.ACTUAL_COMPLETION_DATE
                      -Fcr.ACTUAL_START_DATE)*1440) 
/

EOF

