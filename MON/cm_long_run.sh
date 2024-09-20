#!/bin/bash

. ~/.profile

MAILLIST=lilach.ashenberg@eds.co.il


DATE=`date +"%d-%b-%Y-%H%M"`
ALL_REPORTS="/tmp"
REPORT="${ALL_REPORTS}/CM_long_${DATE}.txt"
APPSPWD=`env|grep APPLPWD= |awk -F= '{print $2}'`

sqlplus -s <<!
APPS/$APPSPWD
set pagesize 24 echo off feed off linesize 130
col qname format a9  heading 'Manager' trunc
col sdate format a12 heading 'Start Time'
col reqid format 99999999 heading 'ReqID'
col concprog format a60 heading 'Concurrent Program Name'
col ospid format a12
col Username format a10


spool $REPORT

Select /*+ RULE */
       Fpro.os_process_id ospid ,
       Request_Id                                               reqid,
       To_Char(Actual_Start_Date, 'DD-MON HH24:MI')             sdate,
      DECODE (Fcr.DESCRIPTION,
      NULL,
      USER_CONCURRENT_PROGRAM_NAME ,
      Fcr.DESCRIPTION||' ('||USER_CONCURRENT_PROGRAM_NAME||')')     concprog,
       Concurrent_Queue_Name                                    qname,
       substr(User_name,1,10)                                   Username
  from Fnd_User ,
       Fnd_Concurrent_Queues Fcq, 
       Fnd_Concurrent_Requests Fcr,
       Fnd_Concurrent_Programs_vl Fcp, 
       Fnd_Concurrent_Processes Fpro
 where
       Phase_Code = 'R' And
       Fcr.status_code = 'R' And
       Fcr.Controlling_Manager = Concurrent_Process_Id       And
      (Fcq.Concurrent_Queue_Id = Fpro.Concurrent_Queue_Id    And
       Fcq.Application_Id      = Fpro.Queue_Application_Id ) And
      (Fcr.Concurrent_Program_Id = Fcp.Concurrent_Program_Id And
       Fcr.Program_Application_Id = Fcp.Application_Id )     And
       Fcr.Requested_By = User_Id and
	( SYSDATE - Actual_Start_Date )* 24 *60 > 1440 -- 24 hours in minutes 
 Order by Actual_Start_Date /*Concurrent_Queue_Name*/
/
spool off
exit
!


LINES=`cat $REPORT| wc -l`
if [ $LINES -gt 0 ]; then 

cat $REPORT | mail  -s "ALERT: Programs  running more than 24 hours on PROD."  $MAILLIST

fi



