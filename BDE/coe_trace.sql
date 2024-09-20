/*$Header: coe_trace.sql 11.5 156969.1 2002/09/03               csierra coe $*/
set term off;
/*=============================================================================

coe_trace.sql - SQL Tracing Apps online transactions with Event 10046 (11.5)

    *************************************************************
    This article is being delivered in Draft form and may contain
    errors.  Please use the MetaLink "Feedback" button to advise
    Oracle of any issues related to this article.
    *************************************************************


 Overview
 --------

    Generates SQL Trace with bind variables and waits information for an
    Oracle Applications Form (equivalent of Event 10046 level 12)

    Use only if patch for Bug 1552649 has not been applied, since this patch
    provide same functionality from standard FORM menu.


 Instructions
 ------------

 1. Copy this whole Note into a text file and name it coe_trace.sql

 2. Login into your Apps 11i instance and navigate to the Form you want to
    trace with event 10046.  Get ready to start the transaction to be traced.
    Try to make the transaction as short as possible

 3. From the toolbar do: Help -> About Oracle Applications.

 4. Find the VERSION_DATABASE_PROCESS value under Database Server paragraph
    and the Form name under the Forms paragraph.

 5. Run this coe_trace.sql script from a SQL*Plus session using APPS.

    # sqlplus apps/apps@vis11i
    SQL> START coe_trace.sql;

 6. Pass the required parameter VERSION_DATABASE_PROCESS value.

 7. From the list generated, enter your 'sid' and 'serial' for your Form.

 8. Do your transaction and go back to your SQL*Plus session to get the trace
    name generated.

 9. Recover the SQL Trace file from Server created under your udump directory.
    It shows bind variables and waits.


 Program Notes
 -------------

 1. Use only if patch for Bug 1552649 has not been applied, since this patch
    provide same functionality from standard FORM menu.

 2. Always download latest version from Metalink (Note:156969.1), or ftp from

    ftp://oracle-ftp.oracle.com/apps/patchsets/AOL/SCRIPTS/PERFORMANCE/

    In order to avoid cut and paste or word wraping issues, use better ftp

 3. This script uses package DBMS_SYSTEM created by catproc.sql

 4. If only interested in Bind Variables and not in DB Waits set Level to 4.

 5. If only interested in DB Waits and not in Bind Variables sel Level to 8.

 6. For Oracle Apps 11.5 use coe_trace.sql from Note:156969.1

    For Oracle Apps 11.0 use coe_trace_11.sql from Note:156970.1

    For others use coe_event_10046.sql from Note:156966.1

 7. For other SQL Tuning scripts, search on Metalink using keyword coescripts.

 8. A practical guide in Troubleshooting Oracle ERP Applications Performance
    Issues can be found on Metalink under Note:169935.1

 9. Read Note:171647.1 for alternate methods to trace with Event 10046.


 Caution
 -------

    The sample program in this article is provided for educational purposes
    only and is NOT supported by Oracle Support Services.  It has been tested
    internally, however, and works as documented.  We do not guarantee that it
    will work for you, so be sure to test it in your environment before
    relying on it.


 Portal
 ------

    Abstract: coe_trace.sql - SQL Tracing Apps online with Event 10046 (11.5)
    Author: Carlos Sierra
    Date: 03-SEP-02
    Description: Generates Trace using Event 10046 (Bind Variables and Waits)
    EMail: carlos.sierra@oracle.com
    Internal_Only: N
    Keywords: CoE Script sqltuning coescripts appsperf appssqltuning
    Metalink_Note: 156969.1
    New_Win: Y
    Product: SQL*Plus script
    Version: 11.5 2002/09/03
    Download: coe_trace.zip

=============================================================================*/

column c_sid            format 99999999 heading 'sid';
column c_serial         format 99999999 heading 'serial';
column c_module         format a12      heading 'module';
column c_logon_time     format a18      heading 'logon time';

set term on ver off feed off;
prompt;

    select
        s.sid     c_sid,
        s.serial# c_serial,
        s.module  c_module,
        to_char(s.logon_time,'DD-MON-YY HH24:MI:SS') c_logon_time
    from
        v$session s,
        v$process p
    where
        p.spid = &&version_database_process
    and p.addr = s.paddr
    and s.module is not null;

prompt;
accept sid    prompt 'Enter <sid> corresponding to your Form: ';
accept serial prompt 'Enter corresponding <serial>          : ';
prompt;

pause Click <Enter> to START tracing;

-- exec dbms_support.start_trace_in_session(&&sid,&&serial,true,true);
EXEC DBMS_SYSTEM.SET_EV(&&sid,&&serial,10046,12,'');

prompt Tracing your Form with Event 10046;
prompt;
pause Click <Enter> to STOP tracing;

-- exec dbms_support.stop_trace_in_session(&sid,&serial);
EXEC DBMS_SYSTEM.SET_EV(&&sid,&&serial,10046,0,'');

select
    value||'/*'||'&VERSION_DATABASE_PROCESS'||'*'
    "Raw SQL Trace File"
from
    v$parameter
where
    name = 'user_dump_dest';

prompt;
undef version_database_process sid serial;
set ver on feed on;