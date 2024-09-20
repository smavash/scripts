/*$Header: coe_event_10046.sql 7.3-9.0 156966.1 2002/09/03      csierra coe $*/
SET term off;
/*=============================================================================

coe_event_10046.sql - SQL Tracing online transactions using Event 10046 7.3-9.0

    *************************************************************
    This article is being delivered in Draft form and may contain
    errors.  Please use the MetaLink "Feedback" button to advise
    Oracle of any issues related to this article.
    *************************************************************


 Overview
 --------

    Turns tracing with event 10046 level 12 for specified session.

    This script is used to SQL Tracing with Event 10046 any Apps online.

    It can be used for 10.7, CRM or any other application.


 Instructions
 ------------

 1. Copy this whole Note into a text file and name it coe_event_10046.sql

 2. Find your session and serial# corresponding to online transaction.

    You may have to query a row from the online Form, make a dummy or fake
    change (modify any field value with same value).  This is just to force
    a row lock.  Then use coe_locks.sql from SQL*Plus to identify corresponding
    session/serial#.  Last, execute this script coe_event_10046.sql with found
    session and serial# of the session holding the row lock on table
    corresponding to dummy lock.

 3. Find coe_locks.sql on Note:156965.1.

 4. Execute from SQL*Plus using APPS account:

    # sqlplus apps/apps@vis11i

    SQL> START coe_event_10046.sql;


 Program Notes
 -------------

 1. Always download latest version from Metalink (Note:156966.1), or ftp from

    ftp://oracle-ftp.oracle.com/apps/patchsets/AOL/SCRIPTS/PERFORMANCE/

    In order to avoid cut and paste or word wraping issues, use better ftp

 2. This script has been tested up to Oracle Apps 11.5.4 with Oracle 8.1.7 but
    it can be used on earlier Releases.

 3. Event 10046 Level 4 reports Bind Variables values on raw SQL Trace.

    Level 8 reports database and idle Waits on raw SQL Trace.

    Level 12 reports both Bind Variables and Waits on SQL Trace file.

    Level 1 produces standard SQL Trace.

 4. Use coe_locks.sql to find sessions with locked rows.  Note:156965.1

 5. If you have any other method to find the session and serial# for the online
    transaction you want to turn on this Event, there is no need then to do a
    dummy lock and find session and serial# with coe_locks.sql.  Some Apps
    Releases provide session and serial# from the Menu.

 6. For Apps 11i use coe_trace.sql instead (Note:156969.1).  For Apps 11.0 use
    coe_trace_11.sql (Note:156970.1).

 7. For other SQL Tuning scripts, search on Metalink using keyword coescripts.

 8. A practical guide in Troubleshooting Oracle ERP Applications Performance
    Issues can be found on Metalink under Note:169935.1


 Parameters
 ----------

 1. session (sid) - usually from coe_locks.sql

 2. serial number (serial#) - usually from coe_locks.sql

 3. event number (set to 10046)

 4. level (set to 12, but you can modify to 1, 4 or 8)

 5. event context (set to '')


 Caution
 -------

    The sample program in this article is provided for educational purposes
    only and is NOT supported by Oracle Support Services.  It has been tested
    internally, however, and works as documented.  We do not guarantee that it
    will work for you, so be sure to test it in your environment before
    relying on it.


 Portal
 ------

    Abstract: coe_event_10046.sql - SQL Tracing online using Event 10046 7.3+
    Author: Carlos Sierra
    Date: 03-SEP-02
    Description: Uses event 10046 to report binds and waits on raw SQL Trace
    EMail: carlos.sierra@oracle.com
    Internal_Only: N
    Keywords: CoE BDE Bind Variables Database Waits coescripts sqltuning
    Metalink_Note: 156966.1
    New_Win: Y
    Product: SQL*Plus script
    Version: 7.3-9.0 2002/09/03
    Download: coe_event_10046.zip

=============================================================================*/
set term on;

-- alter session set events '10046 trace name context forever, level 12';
-- exec dbms_support.start_trace_in_session(&sid,&serial,true,true);

-- begin
-- execute immediate ('alter session set events ''10046 trace name context forever, level 12''');
-- end;
-- /



EXEC DBMS_SYSTEM.SET_EV(&sid,&serial,10046,12,'');
