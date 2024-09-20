/*$Header: coe_trace_11.sql 11.0 156970.1 2002/09/03            csierra coe $*/
set term off;
/*=============================================================================

coe_trace_11.sql - SQL Tracing Apps online transactions with Event 10046 (11.0)

    *************************************************************
    This article is being delivered in Draft form and may contain
    errors.  Please use the MetaLink "Feedback" button to advise
    Oracle of any issues related to this article.
    *************************************************************


 Overview
 --------

    Generates SQL Trace with bind variables and waits information for an
    Oracle Applications form (equivalent of Event 10046 level 12)


 Instructions
 ------------

 1. Copy this whole Note into a text file and name it coe_trace_11.sql

 2. Set Profile option 'Sign-On:Audit Level' to 'FORM' for the user to be
    traced (USER) at any level (site, apps, resp or user) user level is better

 3. Close any open session for USER (Exit Oracle Applications) and open a new
    fresh session for USER.

 4. Navigate to Form that needs to be traced and get ready to start the
    transaction to be traced.  Try to make the transaction as short as possible

 5. Open a SQL*Plus session connecting as APPS

 6. Run this script coe_trace_11.sql providing USER_NAME (same as USER when you
    login into the Application)

 7. Begin the trace from the script, perform the transaction on Form, end the
    trace from the script

 8. Close the Form

 9. Recover the SQL Trace file from Server created under your udump directory.
    It shows bind variables and waits.


 Program Notes
 -------------

 1. Always download latest version from Metalink (Note:156970.1), or ftp from

    ftp://oracle-ftp.oracle.com/apps/patchsets/AOL/SCRIPTS/PERFORMANCE/

    In order to avoid cut and paste or word wraping issues, use better ftp

 2. This script uses package DBMS_SYSTEM created by catproc.sql

 3. If only interested in Bind Variables and not in DB Waits set Level to 4.

 4. If only interested in DB Waits and not in Bind Variables sel Level to 8.

 5. For Oracle Apps 11.5 use coe_trace.sql from Note:156969.1

    For Oracle Apps 11.0 use coe_trace_11.sql from Note:156970.1

    For others use coe_event_10046.sql from Note:156966.1

 6. For other SQL Tuning scripts, search on Metalink using keyword coescripts.

 7. A practical guide in Troubleshooting Oracle ERP Applications Performance
    Issues can be found on Metalink under Note:169935.1


 Caution
 -------

    The sample program in this article is provided for educational purposes
    only and is NOT supported by Oracle Support Services.  It has been tested
    internally, however, and works as documented.  We do not guarantee that it
    will work for you, so be sure to test it in your environment before
    relying on it.


 Portal
 ------

    Abstract: coe_trace_11.sql - SQL Tracing Apps online with Event 10046 11.0
    Author: Carlos Sierra
    Date: 03-SEP-02
    Description: Generates Trace using Event 10046 (Bind Variables and Waits)
    EMail: carlos.sierra@oracle.com
    Internal_Only: N
    Keywords: CoE Script sqltuning coescripts appsperf appssqltuning
    Metalink_Note: 156970.1
    New_Win: Y
    Product: SQL*Plus script
    Version: 11.0 2002/09/03
    Download: coe_trace_11.zip

=============================================================================*/

variable user_id      number;
variable login_id     number;
variable audsid       number;
variable sid          number;
variable process_spid varchar2(30);
variable serial#      number;

column user_name      format a20 heading 'User';
column spid           format a10;
column process_spid   format a10 heading 'Trace|File|Name';
column user_form_name format a40 heading 'Form to be Traced';

set term on ver off feed off;
prompt;

begin

    select                                -- user_id is needed
        user_id
    into
        :user_id
    from
        fnd_user
    where
        user_name = upper('&user_name')
    and rownum = 1;

    select                                -- similar to 'Monitor Users Form'
        login_id,                         -- System Administrator:
        process_spid                      --    Security
    into                                  --       User
        :login_id,                        --          Monitor
        :process_spid
    from
        fnd_logins
    where
        login_id = (select max(login_id)
                    from   fnd_logins
                    where  user_id   = :user_id
                    and    end_time  is null
                    and    pid       is not null
                    and    serial#   is not null
                    and    start_time > sysdate - 1);

    select                                -- Audit session id
        audsid
    into
        :audsid
    from
        fnd_login_resp_forms
    where
        audsid = (select max(audsid)
                  from   fnd_login_resp_forms
                  where  login_id = :login_id
                  and    end_time is null);

    select                                -- Session id and serial# to
        sid,                              -- be used in dbms_support package
        serial#
    into
        :sid,
        :serial#
    from
        v$session
    where
        audsid = :audsid
    and rownum = 1;

end;
/

alter session set nls_date_format = 'DD-MON-RR HH24:MI:SS';

select
    user_id,
    user_name
from
    fnd_user
where
    user_id = :user_id;

select
    login_id,
    start_time,
--  pid,
--  spid,
    process_spid
from
    fnd_logins
where
    login_id = :login_id;

select
    lf.audsid,
    f.user_form_name
from
    fnd_login_resp_forms lf,
    fnd_form_tl f
where
    lf.login_id      = :login_id
and lf.audsid        = :audsid
and f.application_id = lf.form_appl_id
and f.form_id        = lf.form_id;

select
    sid,
    serial#
from
    v$session
where
    audsid  = :audsid
and sid     = :sid
and serial# = :serial#;

prompt;

pause Click <Enter> to START tracing;

-- exec dbms_support.start_trace_in_session(:sid,:serial#,true,true);
EXEC DBMS_SYSTEM.SET_EV(:sid,:serial#,10046,12,'');

prompt Tracing your Form with Event 10046;
prompt;
pause Click <Enter> to STOP tracing;

-- exec dbms_support.stop_trace_in_session(:sid,:serial#);
EXEC DBMS_SYSTEM.SET_EV(:sid,:serial#,10046,0,'');


select
    value||'/*'||:process_spid||'*'
    "Raw SQL Trace File"
from
    v$parameter
where
    name = 'user_dump_dest';

prompt;
undef user_name;
set ver on feed on;