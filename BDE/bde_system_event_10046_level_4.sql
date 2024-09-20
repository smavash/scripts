/*$Header: bde_system_event_10046.sql 8.1-9.0 179848.1 2002/09/03   csierra $*/
SET term off;
/*=============================================================================

bde_system_event_10046.sql - SQL Trace any transaction with Event 10046 8.1-9.0

    *************************************************************
    This article is being delivered in Draft form and may contain
    errors.  Please use the MetaLink "Feedback" button to advise
    Oracle of any issues related to this article.
    *************************************************************


 Overview
 --------

    Turns EVENT 10046 LEVEL 4 for all new sessions (system wide).

    This script is used to turn SQL Trace ON with LEVEL 4 for any Concurrent
    Program that starts its execution AFTER the EVENT 10046 is turned ON at
    the SYSTEM level.

    This script can be used for any Apps or non-Apps instances using RDBMS
    Releases between 8.1 and 9.0.


 Instructions
 ------------

 1. Copy this whole Note into a text file as bde_session_event_10046.sql

 2. Read instructions embedded in PROMPT commands below.

 3. Execute from SQL*Plus using APPS account:

    # sqlplus apps/apps@vis11i

    SQL> START bde_session_event_10046_level_4.sql;


 Program Notes
 -------------

 1. Always download latest version from Metalink (Note:179848.1), or ftp from

    ftp://oracle-ftp.oracle.com/apps/patchsets/AOL/SCRIPTS/PERFORMANCE/

    In order to avoid cut and paste or word wraping issues, use better ftp

 2. This script has been tested up to Oracle Apps 11.5.4 with Oracle 8.1.7 but
    it can be used on RDBMS Releases between 8.1 and 9.0.

 3. Event 10046 Level 4 reports Bind Variables values on raw SQL Trace.

    Level 8 reports database and idle Waits on raw SQL Trace.

    Level 4 reports both Bind Variables and Waits on SQL Trace file.

    Level 1 produces standard SQL Trace.

 4. For other SQL Tuning scripts, search on Metalink using keyword coescripts.

 5. A practical guide in Troubleshooting Oracle ERP Applications Performance
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

    Abstract: bde_session_event_10046.sql - SQL Trace with Event 10046 8.1+
    Author: Carlos Sierra
    Date: 03-SEP-02
    Description: Uses event 10046 to report binds and waits on raw SQL Trace
    EMail: carlos.sierra@oracle.com
    Internal_Only: N
    Keywords: CoE BDE Bind Variables Database Waits coescripts sqltuning
    Metalink_Note: 179848.1
    New_Win: Y
    Product: SQL*Plus script
    Version: 8.1-9.0 2002/09/03
    Download: bde_session_event_10046.zip

=============================================================================*/
var v_mdfs varchar2(30);
var v_ts   varchar2(30);

BEGIN
   SELECT value
     INTO :v_mdfs
     FROM v$parameter
    WHERE name = 'max_dump_file_size';

   SELECT value
     INTO :v_ts
     FROM v$parameter
    WHERE name = 'timed_statistics';
END;
/

SET term on;

PROMPT
PROMPT You are about to turn SQL Trace ON for ALL new database connections,
PROMPT by using EVENT 10046 with LEVEL 4 (WAITS plus BIND VARIABLES).
PROMPT
PROMPT This method is used to Trace with Level 4 any Concurrent Program that
PROMPT gets submited AFTER this EVENT 10046 is SET at the SYSTEM level.
PROMPT
PROMPT Your Concurrent Program should NOT have Trace Enabled using the Form
PROMPT Concurrent Program Define.  Nor a Profile turning Trace ON should be
PROMPT used either.
PROMPT
PROMPT Navigate to the Form that submits your Concurrent Program, and just
PROMPT before clicking the SUBMIT button, click ENTER in this SQL*Plus session
PROMPT
PROMPT Once you click ENTER in this SQL*Plus session, ALL new database
PROMPT connections will start with EVENT 10046 turned on.  ALL pre-existing
PROMPT sessions will not be affected (i.e. will not be traced).
PROMPT
PROMPT To minimize the number of sessions to be traced, turn OFF this
PROMPT EVENT 10046 as soon as possible (i.e. as soon as your Concurrent
PROMPT Program changes its status from Pending to Running).
PROMPT
PROMPT If you need to CANCEL at this time, use <Ctrl-c>
PROMPT

PAUSE  Click ENTER to TURN ON EVENT 10046 for ALL new sessions

SELECT TO_CHAR(sysdate,'DD-MON-YY HH24:MI:SS') "Start" FROM dual;
ALTER SYSTEM SET max_dump_file_size = unlimited;
ALTER SYSTEM SET timed_statistics = true;
ALTER SYSTEM SET EVENTS '10046 trace name context forever, level 4';

PROMPT
PROMPT ALL new sessions will have EVENT 10046 turned ON with LEVEL 4
PROMPT
PROMPT Query the status of your Concurrent Program.  Once it changes from
PROMPT Pending to Running, proceed to TURN OFF this EVENT 10046
PROMPT

PAUSE  Click ENTER to TURN OFF EVENT 10046 for ALL new sessions

ALTER SYSTEM SET EVENTS '10046 trace name context off';
DECLARE
   v_sql        VARCHAR2(1000);
BEGIN
   v_sql:='ALTER SYSTEM SET timed_statistics = '||:v_ts;
   EXECUTE IMMEDIATE v_sql;
   v_sql:='ALTER SYSTEM SET max_dump_file_size = '||:v_mdfs;
   EXECUTE IMMEDIATE v_sql;
END;
/
PROMPT
PROMPT New sessions will not have EVENT 10046 turned ON.  Be aware that ALL
PROMPT sessions that started between the time the EVENT 10046 was turned ON
PROMPT and the time it was turned OFF, will continue to be traced until
PROMPT they complete.
PROMPT
PROMPT Find your raw SQL Trace with WAITS and BIND VARIABLES under the
PROMPT UDUMP directory.  There may be several other traces as well.
PROMPT

SELECT TO_CHAR(sysdate,'DD-MON-YY HH24:MI:SS') "End" FROM dual;

