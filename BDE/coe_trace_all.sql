/*$Header: coe_trace_all.sql 8.0-9.0 156971.1 2002/09/03        csierra coe $*/
SET term off ver off;
/*=============================================================================

coe_trace_all.sql - Turns SQL Trace ON for all open DB Sessions (8.0-9.0)

    *************************************************************
    This article is being delivered in Draft form and may contain
    errors.  Please use the MetaLink "Feedback" button to advise
    Oracle of any issues related to this article.
    *************************************************************


 Overview
 --------

    coe_trace_all.sql turns SQL Trace ON and OFF for all connected sessions.

    It is a workaround to modifying init.ora file to turn SQL Trace ON at the
    instance level and bouncing the database.


 Instructions
 ------------

 1. Copy this whole Note into a text file and name it coe_trace_all.sql

 2. Run coe_trace_all.sql with no parameters from system or apps.

    # sqlplus apps/apps@vis11i

    SQL> START coe_trace_all.sql;

 3. It will prompt to start tracing all sessions and to stop tracing them.  It
    will create one SQL Trace file per session, under the udump directory.


 Program Notes
 -------------

 1. Always download latest version from Metalink (Note:156971.1), or ftp from

    ftp://oracle-ftp.oracle.com/apps/patchsets/AOL/SCRIPTS/PERFORMANCE/

    In order to avoid cut and paste or word wraping issues, use better ftp

 2. This script has been tested on Oracle Apps 11.5.4 with Oracle 8.1.7.

 3. For other SQL Tuning scripts, search on Metalink using keyword coescripts.

 4. A practical guide in Troubleshooting Oracle ERP Applications Performance
    Issues can be found on Metalink under Note:169935.1


 Parameters
 ----------

    None.


 Caution
 -------

    The sample program in this article is provided for educational purposes
    only and is NOT supported by Oracle Support Services.  It has been tested
    internally, however, and works as documented.  We do not guarantee that it
    will work for you, so be sure to test it in your environment before
    relying on it.


 Portal
 ------

    Abstract: coe_trace_all.sql - Turns SQL Trace ON for all open DB Sessions
    Author: Carlos Sierra
    Date: 03-SEP-02
    Description: Equivalent to an ALTER SYSTEM SET SQL_TRACE TRUE;
    EMail: carlos.sierra@oracle.com
    Internal_Only: N
    Keywords: CoE Script sqltuning optimizer performance appsperf
    Metalink_Note: 156971.1
    New_Win: Y
    Product: SQL*Plus script
    Version: 8.0-9.0 2002/09/03
    Download: coe_trace_all.zip

=============================================================================*/

SET term on ver off;

Pause Hit Enter to START tracing
Prompt Tracing now...
BEGIN
    FOR sess_rec IN ( SELECT sid, serial#
                        FROM v$session )
    LOOP
        sys.dbms_system.set_sql_trace_in_session
           ( sess_rec.sid, sess_rec.serial#, TRUE );
    END LOOP;
END;
/
Pause Hit Enter to STOP tracing
BEGIN
    FOR sess_rec IN ( SELECT sid, serial#
                        FROM v$session )
    LOOP
        sys.dbms_system.set_sql_trace_in_session
           ( sess_rec.sid, sess_rec.serial#, FALSE );
    END LOOP;
END;
/