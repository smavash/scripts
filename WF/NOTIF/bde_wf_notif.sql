set term off;
set serveroutput on;
/*$Header: bde_wf_notif.sql 11.5.2                                           03/06/02 */

/*
 TITLE bde_wf_notif.sql
  
DESCRIPTION

 This script is designed to be used to output Workflow related data for an single
 Notification and is designed to be used in conjunction with the output of bde_wf_item.sql
 You will be prompted for the NOTIFICATION_ID.  It will output data for:

    AQ$WF_SMTP_O_1_TABLE
    WF_NOTIFICATIONS
    WF_MESSAGES
    WF_MESSAGE_ATTRIBUTES
    WF_ACTIVITIES for the NOTIFICATION
    WF_ACTIVITY_ATTRIBUTES for the NOTIFICATION
    Output of the WF_MAIL.GETMESSAGE

 In addition it outputs error information and the status of the workflow error 
 process.

 NOTE: Because of line wrapping the output of the HTML Body when viewed through a browser
       may not be accurate.

UPDATES

03/06/02  Modified to include the workflow queue information, sysdate, and         rnmercer
          output of the WF_SMTP_O_1_TABLE information for this one notification.

EXECUTION

 Run the script from a SQL*Plus session logged in as the APPS user.  The output 
 spools to a file called bde_wf_notif.lst. 

 NOTES

 1. The output can be FTP'd to a PC and then loaded into wordpad.  
    Go to Page Setup and select Landscape as the Paper Size.
    Modify all 4 Margins to 0.5".
    Select all your document (Ctrl-A) and use Format Font to change the current
    font to Courier or New Courier 8.  
    With all your document selected (Ctrl-A) use Format Parragraph to set both
    Before and After Spacing to 0.  It comes with null causing a one line 
    spacing between lines.

 DISCLAIMER 
 
 This script is provided for educational purposes only.  It is not supported 
 by Oracle World Wide Technical Support.  The script has been tested and 
 appears to works as intended.  However, you should always test any script 
 before relying on it. 
 
 Proofread this script prior to running it!  Due to differences in the way text 
 editors, email packages and operating systems handle text formatting (spaces, 
 tabs and carriage returns), this script may not be in an executable state 
 when you first receive it.  Check over the script to ensure that errors of 
 this type are corrected. 

 This script can be given to customers.  Do not remove disclaimer paragraph.

 HISTORY 
 
 27-AUG-01 Created                                                   rnmercer 

*/
set echo off;
set verify off;
set linesize 141;
set pagesize 100;
set term off;

spool bde_wf_notif.lst

accept notification_id_selected prompt 'Please enter NOTIFICATION_ID: '

prompt Current System Date
select to_char(sysdate,'DD-MON-RR HH24:MI:SS') SYSTEM_DATE from dual;

column owner        format a8;
column QUEUE_TABLE  format a20;
column user_comment format a38;
column corrid       format a12;
column state        format a13;
column name         format a20;
column value        format a20;

prompt Database Init.ora Parameter Values
select name NAME, value Value
from v$parameter
where upper(name) in ('AQ_TM_PROCESSES','JOB_QUEUE_PROCESSES','JOB_QUEUE_INTERVAL');


prompt Workflow Queues
select owner, name,queue_table, enqueue_enabled,dequeue_enabled, user_comment
from dba_queues
where name like 'WF%'
order by 6;

column CORR_ID format a15;
alter session set nls_date_format = 'DD-MON-RR HH24:MI:SS';
prompt WF_SMTP_O_1_TABLE for notification
select * from applsys.AQ$WF_SMTP_O_1_TABLE where corr_id = 'APPS:&notification_id_selected';
alter session set nls_date_format = 'DD-MON-RR';


column context           format A25;
column RESPONDER         format a18;
column RECIPIENT_ROLE    format a14;
column ACCESS_KEY        format a10;
column USER_COMMENT      format a20;
column CALLBACK          format a20;
column ORIGINAL_REC      format a20;
column FROM_USER         format a15;
column TO_USER           format a30;
column SUBJECT           format a60;
column MAIL_STAT         format a09;
column STATUS            format a09;
column BEGIN_DATE        format a10;
column END_DATE          format a10;
column PRI               format 999;

prompt ******* WF_NOTIFICATIONS *******

select
     NTF.NOTIFICATION_ID                NOTIF_ID
    ,NTF.CONTEXT                        CONTEXT
    ,NTF.GROUP_ID                       GROUP_ID
    ,NTF.STATUS                         STATUS
    ,NTF.MAIL_STATUS                    MAIL_STAT
    ,NTF.MESSAGE_TYPE                   MES_TYPE
    ,NTF.MESSAGE_NAME                   MESSAGE_NAME
    ,NTF.ACCESS_KEY                     ACCESS_KEY
    ,NTF.PRIORITY                       PRI
    ,NTF.BEGIN_DATE                     BEGIN_DATE
    ,NTF.END_DATE                       END_DATE
    ,NTF.DUE_DATE                       DUE_DATE
    --,NTF.USER_COMMENT                   USER_COMMENT
    ,NTF.CALLBACK                       CALLBACK
    ,NTF.RECIPIENT_ROLE                 RECIPIENT_ROLE
    ,NTF.RESPONDER                      RESPONDER
    ,NTF.ORIGINAL_RECIPIENT             ORIGINAL_REC
    ,NTF.FROM_USER                      FROM_USER
    ,NTF.TO_USER                        TO_USER
    --,NTF.LANGUAGE                       LANGUAGE
    --,NTF.MORE_INFO_ROLE                 MORE_INFO_ROLE
    ,NTF.SUBJECT                        SUBJECT
from WF_NOTIFICATIONS          NTF
where NTF.NOTIFICATION_ID = &notification_id_selected;


column ROLE_NAME   format a20;
column ROLE_SYS    format a8;
column USER_NAME   format a30;
column USER_SYS    format a8;

prompt ******* USER ROLES *******
select
     URL.ROLE_NAME                      ROLE_NAME
    ,URL.ROLE_ORIG_SYSTEM               ROLE_SYS
    ,URL.ROLE_ORIG_SYSTEM_ID            ROLE_SYS_ID
    ,URL.USER_NAME                      USER_NAME
    ,URL.USER_ORIG_SYSTEM               USER_SYS
    ,URL.USER_ORIG_SYSTEM_ID            USER_SYS_ID
from WF_USER_ROLES          URL,
     WF_NOTIFICATIONS       NTF
where URL.ROLE_NAME       = NTF.RECIPIENT_ROLE 
 AND  NTF.NOTIFICATION_ID = &notification_id_selected;

prompt ******* ROLES *******

column   DISPLAY_NAME   format a25;
column   DESCRIPTION    format a30;
column   NOTIF_PREF     format a10;
column   EMAIL_ADDRESS  format a40;
column   LANGUAGE       format a8;
column   TERRITORY      format a8;
column   ORIG_SYS       format a8;

select
     ROL.NAME                           ROLE_NAME
    ,ROL.DISPLAY_NAME                   DISPLAY_NAME
    ,ROL.DESCRIPTION                    DESCRIPTION
    ,ROL.STATUS                         STATUS
    ,ROL.EMAIL_ADDRESS                  EMAIL_ADDRESS
    ,ROL.NOTIFICATION_PREFERENCE        NOTIF_PREF
    ,ROL.LANGUAGE                       LANGUAGE
    ,ROL.TERRITORY                      TERRITORY
    --,ROL.FAX                            FAX
    ,ROL.ORIG_SYSTEM                    ORIG_SYS
    ,ROL.ORIG_SYSTEM_ID                 ORIG_SYS_ID
    ,ROL.EXPIRATION_DATE                EXPIR_DATE
from WF_ROLES           ROL,
     WF_NOTIFICATIONS   NTF
where ROL.NAME            = NTF.RECIPIENT_ROLE 
 AND  NTF.NOTIFICATION_ID = &notification_id_selected;


prompt ******* USERS *******

select
     USR.NAME                           USER_NAME
    ,USR.DISPLAY_NAME                   DISPLAY_NAME
    ,USR.DESCRIPTION                    DESCRIPTION
    ,USR.STATUS                         STATUS
    ,USR.EMAIL_ADDRESS                  EMAIL_ADDRESS
    ,USR.NOTIFICATION_PREFERENCE        NOTIF_PREF
    ,USR.LANGUAGE                       LANGUAGE
    ,USR.TERRITORY                      TERRITORY
    --,USR.FAX                            FAX
    ,USR.ORIG_SYSTEM                    ORIG_SYS
    ,USR.ORIG_SYSTEM_ID                 ORIG_SYS_ID
    ,USR.EXPIRATION_DATE                EXPIR_DATE
from WF_USERS           USR,
     WF_NOTIFICATIONS   NTF
where (USR.NAME            = NTF.ORIGINAL_RECIPIENT 
    OR USR.DISPLAY_NAME    = NTF.TO_USER
    OR USR.DISPLAY_NAME    = NTF.FROM_USER
    OR USR.NAME            = NTF.RESPONDER)
 AND  NTF.NOTIFICATION_ID = &notification_id_selected;


column NOTIFICATION       format  a23;
column MESSAGE            format  a25;
column PRTY               format 9999;
column SUBJECT            format a55;
column DISPLAY_NAME       format a50;

prompt ******* MESSAGES *******

SELECT 
    B.NAME                        MESSAGE
  , T.DISPLAY_NAME                DISPLAY_NAME
  , B.DEFAULT_PRIORITY            PRTY
  , T.SUBJECT   SUBJECT
  , 'Text Body = ' || wf_core.newline  
                   ||T.BODY       TEXT_BODY
  , wf_core.newline ||'HTML Body = ' || wf_core.newline 
                   ||T.HTML_BODY  HTML_BODY 
FROM WF_MESSAGES     B
  , WF_MESSAGES_TL   T 
  , WF_NOTIFICATIONS N
WHERE B.TYPE             = T.TYPE
   AND B.NAME            = T.NAME
   AND T.LANGUAGE        = USERENV('LANG')
   AND B.TYPE            = N.MESSAGE_TYPE
   AND B.NAME            = N.MESSAGE_NAME
   AND N.NOTIFICATION_ID = &notification_id_selected;


column MSG_NAME      format a20;
column TYPE          format a8;
column VAL_TYPE      format a8;
column SUBTYPE       format a7;
column SEQ           format 999;
column FORMAT        format a20;
column DEFAULT_VALUE format a25;
column DISPLAY_NAME  format a30;

prompt ******* MESSAGE ATTRIBUTES *******

SELECT 
    --B.MESSAGE_NAME  MSG_NAME
    B.NAME          NAME
  , T.DISPLAY_NAME  DISPLAY_NAME
  , B.SEQUENCE      SEQ
  , B.TYPE          TYPE
  , B.SUBTYPE       SUBTYPE
  , B.VALUE_TYPE    VAL_TYPE
  ,DECODE(B.TYPE,
          'DATE',   TO_CHAR(B.DATE_DEFAULT),
          'NUMBER', TO_CHAR(B.NUMBER_DEFAULT),
          B.TEXT_DEFAULT)           DEFAULT_VALUE
  , B.FORMAT        FORMAT
FROM WF_MESSAGE_ATTRIBUTES    B
   , WF_MESSAGE_ATTRIBUTES_TL T 
   , WF_NOTIFICATIONS         N
WHERE  B.MESSAGE_NAME    = T.MESSAGE_NAME
   AND B.MESSAGE_TYPE    = T.MESSAGE_TYPE
   AND B.NAME            = T.NAME
   AND T.LANGUAGE        = USERENV('LANG')
   AND B.MESSAGE_TYPE    = N.MESSAGE_TYPE
   AND B.MESSAGE_NAME     = N.MESSAGE_NAME
   AND N.NOTIFICATION_ID = &notification_id_selected
order by SEQ;

column NOTIFICATION       format  a23;
column MESSAGE            format  a25;
column PLSQL_FUNCTION format  a20;
column VAL            format  a03;
column RESULT         format a25;
column DISPLAY_NAME   format a30;

prompt ******* NOTIFICATION ACTIVITY *******

SELECT DISTINCT
    ACT.NAME             NOTIFICATION
  , ACT.RESULT_TYPE      RESULT
  , ACT.MESSAGE          MESSAGE
  , ACT.FUNCTION         PLSQL_FUNCTION
  , decode((select STATUS from all_objects
     where OBJECT_NAME = substr(ACT.FUNCTION,1,instr(ACT.FUNCTION,'.')-1)
     and OWNER = 'APPS'
     and OBJECT_TYPE = 'PACKAGE BODY'),
    'VALID',   'Y',
    'INVALID', 'N',
    'X') VAL
  , T.DISPLAY_NAME     DISPLAY_NAME 
from WF_ACTIVITIES               ACT
   , WF_ACTIVITIES_TL            T
   , WF_PROCESS_ACTIVITIES       PRO
   , WF_ITEM_ACTIVITY_STATUSES   STA
   , WF_ITEMS                    ITM
where  STA.NOTIFICATION_ID  = &notification_id_selected
   and ACT.ITEM_TYPE  = T.ITEM_TYPE
   and ACT.NAME      = T.NAME
   and ACT.VERSION   = T.VERSION
   and T.LANGUAGE  = userenv('LANG')
   and STA.PROCESS_ACtIVITY = PRO.INSTANCE_ID
   and ITM.ITEM_TYPE        = STA.ITEM_TYPE
   and ITM.ITEM_KEY         = STA.ITEM_KEY
   and ITM.BEGIN_DATE      >= ACT.BEGIN_DATE
   and ITM.BEGIN_DATE       < nvl(ACT.END_DATE,ITM.BEGIN_DATE+1)
   and ACT.NAME             = PRO.ACTIVITY_NAME
   and ACT.ITEM_TYPE        = PRO.ACTIVITY_ITEM_TYPE;

column NTF_NAME_VERS     format a20;

prompt ******* Notification Attributes *******

break on NTF_NAME_VERS skip 2;

SELECT 
    --B.ACTIVITY_NAME ||' - ' || B.ACTIVITY_VERSION NTF_NAME_VERS
    B.NAME 
  , T.DISPLAY_NAME 
  , B.SEQUENCE                                    SEQ
  , B.TYPE 
  , B.VALUE_TYPE 
  , B.FORMAT 
  ,DECODE(B.TYPE,
          'DATE',   TO_CHAR(B.DATE_DEFAULT),
          'NUMBER', TO_CHAR(B.NUMBER_DEFAULT),
          B.TEXT_DEFAULT)           DEFAULT_VALUE
FROM WF_ACTIVITY_ATTRIBUTES      B
   , WF_ACTIVITY_ATTRIBUTES_TL   T 
   , WF_ACTIVITIES               ACT
   , WF_PROCESS_ACTIVITIES       PRO
   , WF_ITEM_ACTIVITY_STATUSES   STA
   , WF_ITEMS                    ITM
where  STA.NOTIFICATION_ID  = &notification_id_selected
   AND B.ACTIVITY_ITEM_TYPE = T.ACTIVITY_ITEM_TYPE
   AND B.ACTIVITY_NAME      = T.ACTIVITY_NAME
   AND B.ACTIVITY_VERSION   = T.ACTIVITY_VERSION 
   and T.LANGUAGE           = userenv('LANG')
   AND B.ACTIVITY_ITEM_TYPE = ACT.ITEM_TYPE
   AND B.ACTIVITY_NAME      = ACT.NAME
   AND B.ACTIVITY_VERSION   = ACT.VERSION
   and STA.PROCESS_ACtIVITY = PRO.INSTANCE_ID
   and ITM.ITEM_TYPE        = STA.ITEM_TYPE
   and ITM.ITEM_KEY         = STA.ITEM_KEY
   and ITM.BEGIN_DATE      >= ACT.BEGIN_DATE
   and ITM.BEGIN_DATE       < nvl(ACT.END_DATE,ITM.BEGIN_DATE+1)
   and ACT.NAME             = PRO.ACTIVITY_NAME
   and ACT.ITEM_TYPE        = PRO.ACTIVITY_ITEM_TYPE;

prompt ******* Notification Attribute Values *******

column text_value format a60;
SELECT 
     NTA.NOTIFICATION_ID                NOTIF_ID
    ,NTA.NAME                           NAME
    ,NTA.NUMBER_VALUE                   NUMBER_VALUE
    ,NTA.DATE_VALUE                     DATE_VALUE
    ,NTA.TEXT_VALUE                     TEXT_VALUE
FROM WF_NOTIFICATION_ATTRIBUTES NTA
where  NTA.NOTIFICATION_ID  = &notification_id_selected;

update wf_notifications 
 set status = 'OPEN', 
 mail_status = 'MAIL'
where notification_id = &notification_id_selected;

declare 
    nid           number;
    node          varchar2(100);
    agent         varchar2(100);
    replyto       varchar2(100);
    subject       varchar2(2000);
    text_body     varchar2(32000);
    html_body     varchar2(32000);
    body_atth     varchar2(32000);
    error_result  varchar2(100);
    z             number;
    body_length   number;

begin
dbms_output.enable(100000);

   wf_mail.getmessage(
		&notification_id_selected,
            'node',
            NULL,
            'replyto@node.com',
            subject,
            text_body,
            html_body,
            body_atth,
            error_result);

dbms_output.put_line('****************************** SUBJECT IS ******************************');

z:=1;
body_length := 0;
body_length := length(subject);
if body_length > 0  then
  loop 
     if body_length < z+255 then
       dbms_output.put_line(substr(subject, z, body_length - z +1));            
     else
       dbms_output.put_line(substr(subject, z , 255));
     end if;

     exit when z > body_length;
     z := z+255;
  end loop;
end if;


dbms_output.put_line('****************************** TEXT BODY IS ******************************');
z:=1;
body_length := 0;
body_length := length(text_body);
if body_length > 0  then
  loop 
     if body_length < z+255 then
       dbms_output.put_line(substr(text_body, z, body_length - z+1));            
     else
       dbms_output.put_line(substr(text_body, z , 255));
     end if;

     exit when z > body_length;
     z := z+255;
  end loop;
end if;
dbms_output.put_line('****************************** HTML BODY IS ******************************');
z:=1;
body_length := 0;
body_length := length(html_body);
if body_length > 0  then
  loop 
     if body_length < z+255 then
       dbms_output.put_line(substr(html_body, z, body_length - z+1));            
     else
       dbms_output.put_line(substr(html_body, z , 255));
     end if;
     exit when z > body_length;
     z := z+255;
  end loop;
end if;

dbms_output.put_line('****************************** HTML ATTH IS ******************************');
z:=1;
body_length := 0;
body_length := length(body_atth);
if body_length > 0  then
  loop 
     if body_length < z+255 then
       dbms_output.put_line(substr(body_atth, z, body_length - z+1));            
     else
       dbms_output.put_line(substr(body_atth, z , 255));
     end if;

     exit when z > body_length;
     z := z+255;
  end loop;
end if;

end;
/


rollback;

clear breaks;
clear columns;

spool off;
