/*$Header: bde_session_locks.sql 8.1-9.0  200590.1 2002/09/03   csierra coe $*/
SET term off;
/*=============================================================================

bde_session_locks.sql - Locks for given Session ID (8.1-9.0)

    *************************************************************
    This article is being delivered in Draft form and may contain
    errors.  Please use the MetaLink "Feedback" button to advise
    Oracle of any issues related to this article.
    *************************************************************


 Overview
 --------

    bde_session_locks.sql creates a report with locks for one session that is
    not responding (hanging), because of a Lock.

    The database session that hangs, can be linked to a FORM or Concurrent
    Program (if using Oracle Apps), or it could be linked to any other type of
    database connection including SQL*Plus and PL/SQL.

    bde_session_locks.sql takes only one execution parameter, which is the
    session id, also known as sid, of the session waiting for the lock.

    If you are interested on finding out why one Apps Concurrent Request is
    hanging or not completing, use script bde_request.sql (Note:187504.1),
    which given a request_id finds its session id.

    bde_session_locks.sql creates a spool file report with the details of the
    session requested, as well as the blocker session when the requested one is
    waiting on a lock being hold by a blocker.

    When a lock in the session is detected, it includes the object (table)
    being locked, as well as the rowid and all the column values for that
    particular row the session is trying to place a lock.

    bde_session_locks.sql also shows session wait events and session stats

    This script is a subset of bde_session.sql (Note:169630.1)

    For more details in detecting and resolving locking issues, read
    Note:102925.1


 Instructions
 ------------

 1. Copy this whole Note into a text file and name it bde_session_locks.sql.

 2. Create a dedicated O/S directory and place on it this script
    bde_session_locks.sql.

 3. The spool files get created on same directory from which this script is
    executed. On NT, files may get created under $ORACLE_HOME/bin.

 4. Execute bde_session_locks.sql with parameter of database Session ID.  To
    find locked sessions, use coe_locks.sql (Note:156965.1)

    Use APPS user if used within Oracle Applications.  Use SYSTEM or any other
    user with access to V$ views for non Oracle Apps.

    # sqlplus apps/apps@vis11i
    SQL> START bde_session_locks.sql <sid>;

 5. If sending results to Oracle, use WinZip to compress all spooled files into
    one single file.  Name it bde_results.zip before uploading.


 Program Notes
 -------------

 1. Always download latest version from Metalink (Note:200590.1), or ftp from

    ftp://oracle-ftp.oracle.com/apps/patchsets/AOL/SCRIPTS/PERFORMANCE/

    In order to avoid cut and paste or word wraping issues, use better ftp

 2. For other SQL Tuning scripts, search on Metalink using keyword coescripts.

 3. A practical guide in Troubleshooting Oracle ERP Applications Performance
    Issues can be found on Metalink under Note:169935.1


 User Parameters
 ---------------

 1. Database Session ID (SID).

    If using Oracle Apps, and the session corresponds to an online transaction,
    use Menu -> Help -> About Oracle Applications, and look for Session SID
    under Database Server section.

    Similarly, if session corresponds to Oracle Apps Concurrent Request, use
    bde_request.sql Note:187504.1, passing request_id as its execution
    parameter.

    To find locked sessions, use coe_locks.sql (Note:156965.1)


 Caution
 -------

    The sample program in this article is provided for educational purposes
    only and is NOT supported by Oracle Support Services.  It has been tested
    internally, however, and works as documented.  We do not guarantee that it
    will work for you, so be sure to test it in your environment before
    relying on it.


 Portal
 ------

    Abstract: bde_session_locks.sql - Locks for given Session ID (8.1-9.0)
    Author: Carlos Sierra
    Date: 03-SEP-02
    Description: Locks for given Session ID (8.1-9.0)
    EMail: carlos.sierra@oracle.com
    Internal_Only: N
    Keywords: CoE sqltuning coescripts appsperf appssqltuning enqueue hang lock
    Metalink_Note: 200590.1
    New_Win: Y
    Product: SQL*Plus script
    Version: 8.1-9.0 2002/09/03
    Download: bde_session_locks.zip

=============================================================================*/

SET term off ver off feed off trims on pages 0 lin 4050 long 32767 longc 78;
SET recsep off sqlp '' sqln off serveroutput on size 1000000 num 14;

VARIABLE v_saddr           VARCHAR2(8);
VARIABLE v_sid             NUMBER;
VARIABLE v_serial#         NUMBER;
VARIABLE v_paddr           VARCHAR2(8);
VARIABLE v_command         NUMBER;
VARIABLE v_taddr           VARCHAR2(8);
VARIABLE v_lockwait        VARCHAR2(8);
VARIABLE v_prev_sql_addr   VARCHAR2(8);
VARIABLE v_prev_hash_value NUMBER;
VARIABLE v_sql_address     VARCHAR2(8);
VARIABLE v_sql_hash_value  NUMBER;
VARIABLE v_row_wait_obj#   NUMBER;
VARIABLE v_row_wait_file#  NUMBER;
VARIABLE v_row_wait_block# NUMBER;
VARIABLE v_row_wait_row#   NUMBER;

VARIABLE v_latchwait       VARCHAR2(8);
VARIABLE v_latchspin       VARCHAR2(8);

VARIABLE v_object_owner    VARCHAR2(30);
VARIABLE v_object_name     VARCHAR2(128);

VARIABLE v_blocker_sid     NUMBER;
VARIABLE v_blocker_paddr   VARCHAR2(8);
VARIABLE v_blocker_taddr   VARCHAR2(8);

ALTER SESSION SET nls_date_format = 'DD-MON-YYYY HH24:MI:SS';

SET term on;

PROMPT
PROMPT ========================================================================
PROMPT bde_session_locks.sql - Locks for one Session
PROMPT ========================================================================
PROMPT
PROMPT Usage:
PROMPT sqlplus apps/apps
PROMPT SQL> START bde_session_locks.sql <sid>
PROMPT

BEGIN
    SELECT saddr,
           sid,
           serial#,
           paddr,
           command,
           taddr,
           lockwait,
           prev_sql_addr,
           prev_hash_value,
           sql_address,
           sql_hash_value,
           row_wait_obj#,
           row_wait_file#,
           row_wait_block#,
           row_wait_row#
      INTO :v_saddr,
           :v_sid,
           :v_serial#,
           :v_paddr,
           :v_command,
           :v_taddr,
           :v_lockwait,
           :v_prev_sql_addr,
           :v_prev_hash_value,
           :v_sql_address,
           :v_sql_hash_value,
           :v_row_wait_obj#,
           :v_row_wait_file#,
           :v_row_wait_block#,
           :v_row_wait_row#
      FROM v$session
     WHERE sid    = TO_NUMBER('&&1')
       AND rownum = 1;

    SELECT latchwait,
           latchspin
      INTO :v_latchwait,
           :v_latchspin
      FROM v$process
     WHERE addr   = :v_paddr
       AND rownum = 1;

    IF :v_row_wait_obj# = -1 THEN
       :v_object_owner := 'SYS';
       :v_object_name  := 'DUAL';
    ELSE
       SELECT owner,
              object_name
         INTO :v_object_owner,
              :v_object_name
         FROM all_objects
        WHERE object_id = :v_row_wait_obj#
          AND rownum    = 1;
    END IF;

    IF :v_lockwait IS NOT NULL THEN
       SELECT blocker.sid
         INTO :v_blocker_sid
         FROM v$lock blocker
        WHERE blocker.sid <> :v_sid
          AND (blocker.type, blocker.id1, blocker.id2) IN
              (SELECT locked.type, locked.id1, locked.id2
                 FROM v$lock locked
                WHERE locked.sid   = :v_sid
                  AND locked.kaddr = :v_lockwait)
          AND rownum = 1;
    END IF;

    IF :v_blocker_sid IS NOT NULL THEN
       SELECT paddr,
              taddr
         INTO :v_blocker_paddr,
              :v_blocker_taddr
         FROM v$session
        WHERE sid = :v_blocker_sid
          AND rownum = 1;
    END IF;
END;
/

CLEAR BREAKS COLUMNS;

COLUMN p_saddr           NEW_VALUE p_saddr           FORMAT A8;
COLUMN p_sid             NEW_VALUE p_sid             FORMAT A8;
COLUMN p_serial          NEW_VALUE p_serial          FORMAT A8;
COLUMN p_paddr           NEW_VALUE p_paddr           FORMAT A8;
COLUMN p_command         NEW_VALUE p_command         FORMAT A8;
COLUMN p_taddr           NEW_VALUE p_taddr           FORMAT A8;
COLUMN p_lockwait        NEW_VALUE p_lockwait        FORMAT A8;
COLUMN p_prev_sql_addr   NEW_VALUE p_prev_sql_addr   FORMAT A8;
COLUMN p_prev_hash_value NEW_VALUE p_prev_hash_value FORMAT A12;
COLUMN p_sql_address     NEW_VALUE p_sql_address     FORMAT A8;
COLUMN p_sql_hash_value  NEW_VALUE p_sql_hash_value  FORMAT A12;
COLUMN p_row_wait_obj    NEW_VALUE p_row_wait_obj    FORMAT A8;
COLUMN p_row_wait_file   NEW_VALUE p_row_wait_file   FORMAT A8;
COLUMN p_row_wait_block  NEW_VALUE p_row_wait_block  FORMAT A8;
COLUMN p_row_wait_row    NEW_VALUE p_row_wait_row    FORMAT A8;

COLUMN p_latchwait       NEW_VALUE p_latchwait       FORMAT A8;
COLUMN p_latchspin       NEW_VALUE p_latchspin       FORMAT A8;

COLUMN p_object_owner    NEW_VALUE p_object_owner    FORMAT A30;
COLUMN p_object_name     NEW_VALUE p_object_name     FORMAT A128;

COLUMN p_blocker_sid     NEW_VALUE p_blocker_sid     FORMAT A8;
COLUMN p_blocker_paddr   NEW_VALUE p_blocker_paddr   FORMAT A8;
COLUMN p_blocker_taddr   NEW_VALUE p_blocker_taddr   FORMAT A8;

COLUMN text FORMAT A78 WOR;

SELECT TO_CHAR(:v_sid)             p_sid,
       TO_CHAR(:v_serial#)         p_serial,
       :v_saddr                    p_saddr,
       :v_paddr                    p_paddr,
       TO_CHAR(:v_command)         p_command,
       :v_taddr                    p_taddr,
       :v_lockwait                 p_lockwait,
       :v_prev_sql_addr            p_prev_sql_addr,
       TO_CHAR(:v_prev_hash_value) p_prev_hash_value,
       :v_sql_address              p_sql_address,
       TO_CHAR(:v_sql_hash_value)  p_sql_hash_value,
       TO_CHAR(:v_row_wait_obj#)   p_row_wait_obj,
       TO_CHAR(:v_row_wait_file#)  p_row_wait_file,
       TO_CHAR(:v_row_wait_block#) p_row_wait_block,
       TO_CHAR(:v_row_wait_row#)   p_row_wait_row,
       :v_latchwait                p_latchwait,
       :v_latchspin                p_latchspin,
       :v_object_owner             p_object_owner,
       :v_object_name              p_object_name,
       TO_CHAR(:v_blocker_sid)     p_blocker_sid,
       :v_blocker_paddr            p_blocker_paddr,
       :v_blocker_taddr            p_blocker_taddr
  FROM dual;

PROMPT
PROMPT Creating COE staging objects...

DROP   TABLE bde_$values_&&p_sid;
CREATE TABLE bde_$values_&&p_sid
    (column_id NUMBER,column_name VARCHAR2(30),column_values VARCHAR2(4000))
    NOLOGGING CACHE;

DROP   TABLE bde_$selection_&&p_sid;
CREATE TABLE bde_$selection_&&p_sid AS
SELECT * FROM dual;


PROMPT WARNING: "ORA-00942: table or view does not exist" ARE EXPECTED, PLEASE WAIT...

CREATE OR REPLACE PACKAGE bde_$v2_&&p_sid AS
PROCEDURE format_values
( num_rows_in      IN NUMBER,
  column_length_in IN NUMBER );
END bde_$v2_&&p_sid;
/

CREATE OR REPLACE PACKAGE BODY bde_$v2_&&p_sid AS
PROCEDURE format_values
( num_rows_in      IN NUMBER,
  column_length_in IN NUMBER )
IS
    v_sql          VARCHAR2(2000);
    CURSOR columns_cursor IS
      SELECT column_name
        FROM bde_$values_&&p_sid;
BEGIN
    EXECUTE IMMEDIATE 'ALTER TABLE bde_$selection_&&p_sid CACHE';

    EXECUTE IMMEDIATE 'TRUNCATE TABLE bde_$values_&&p_sid';

    EXECUTE IMMEDIATE 'INSERT INTO bde_$values_&&p_sid '||
                      'SELECT column_id, column_name, NULL '||
                        'FROM user_tab_columns '||
                       'WHERE table_name = ''BDE_$SELECTION_&&p_sid''';

    FOR i IN 1..num_rows_in LOOP
        FOR columns_record IN columns_cursor LOOP
            v_sql:='UPDATE bde_$values_&&p_sid '||
                      'SET column_values = column_values || '||
                          '( SELECT RPAD(SUBSTR("'||columns_record.column_name||
                          '",1,'||TO_CHAR(column_length_in)||')||'' '','||
                                 TO_CHAR(column_length_in+1)||') '||
                              'FROM bde_$selection_&&p_sid '||
                             'WHERE row_$num = '||TO_CHAR(i)||' ) '||
                    'WHERE column_name = '''||columns_record.column_name||'''';
            BEGIN
                EXECUTE IMMEDIATE v_sql;
            EXCEPTION
                WHEN OTHERS THEN
                    DBMS_OUTPUT.PUT_LINE(SUBSTR('*** ERROR: '||v_sql,1,255));
            END;
        END LOOP;
    END LOOP;
END format_values;
END bde_$v2_&&p_sid;
/

COLUMN SID          FORMAT 99999999;
COLUMN SESSION_ID   FORMAT 9999999999;
COLUMN SEQ#         FORMAT 99999999;
COLUMN EVENT        FORMAT A40;
COLUMN ORACLE_USERNAME FORMAT A15;
COLUMN WAIT_TIME    FORMAT 99999999 HEADING 'WAIT|TIME';
COLUMN SECONDS_IN_WAIT FORMAT 99999999 HEADING 'SECONDS|IN WAIT';
COLUMN CLASS        FORMAT A20;
COLUMN XIDUSN       FORMAT 99999999;
COLUMN XIDSLOT      FORMAT 99999999;
COLUMN XIDSQN       FORMAT 99999999;
COLUMN OBJECT_NAME  FORMAT A50;

SET term on;
PROMPT
PROMPT Generating Report (bde_session_locks_&&p_sid..txt spool file)...
PROMPT
PROMPT
SET term off;

SPOOL bde_session_locks_&&p_sid..txt;
SET term on recsep wr;


SET pages 0;

PROMPT bde_session_locks.sql 8.1-9.0 200590.1 2002/06/21   SID: &&p_sid

PROMPT
PROMPT V$SESSION - Session ( &&p_sid &&p_blocker_sid )
PROMPT ===================
PROMPT

DROP   TABLE bde_$selection_&&p_sid;
CREATE TABLE bde_$selection_&&p_sid AS
SELECT 1 row_$num,
       v.*
  FROM v$session v
 WHERE v.saddr   = '&&p_saddr'
   AND v.sid     = TO_NUMBER('&&p_sid')
   AND v.serial# = TO_NUMBER('&&p_serial')
 UNION ALL
 SELECT 2 row_$num,
       v.*
  FROM v$session v
 WHERE v.sid     = TO_NUMBER('&&p_blocker_sid');

EXEC bde_$v2_&&p_sid..format_values(num_rows_in => 2, column_length_in => 30);

SELECT SUBSTR(column_name,1,30) column_name,
       column_values
  FROM bde_$values_&&p_sid
 WHERE TRIM(column_values) IS NOT NULL
   AND column_name      <> 'ROW_$NUM'
 ORDER BY
       column_id;

PROMPT

SELECT RPAD('COMMAND (in progress): '||TO_CHAR(action),31)||name
  FROM audit_actions
 WHERE action = :v_command;

PROMPT

SELECT RPAD('ROW_WAIT_OBJ#: '||TO_CHAR(:v_row_wait_obj#),31)||
       owner||'.'||object_name||' ('||object_type||')  ROWID: '||
       DBMS_ROWID.ROWID_CREATE(1,
                               NVL(TO_NUMBER('&&p_row_wait_obj'),0),
                               NVL(TO_NUMBER('&&p_row_wait_file'),0),
                               NVL(TO_NUMBER('&&p_row_wait_block'),0),
                               NVL(TO_NUMBER('&&p_row_wait_row'),0))
  FROM all_objects
 WHERE object_id = :v_row_wait_obj#;

PROMPT

DROP   TABLE bde_$selection_&&p_sid;
CREATE TABLE bde_$selection_&&p_sid AS
SELECT rownum row_$num,
       v.*
  FROM &&p_object_owner..&&p_object_name v
 WHERE TO_NUMBER('&&p_row_wait_obj') <> -1
   AND v.rowid =
       DBMS_ROWID.ROWID_CREATE(1,
                               NVL(TO_NUMBER('&&p_row_wait_obj'),0),
                               NVL(TO_NUMBER('&&p_row_wait_file'),0),
                               NVL(TO_NUMBER('&&p_row_wait_block'),0),
                               NVL(TO_NUMBER('&&p_row_wait_row'),0));

EXEC bde_$v2_&&p_sid..format_values(num_rows_in => 1, column_length_in => 150);

SELECT SUBSTR(column_name,1,30) column_name,
       column_values
  FROM bde_$values_&&p_sid
 WHERE TRIM(column_values) IS NOT NULL
   AND column_name      <> 'ROW_$NUM'
 ORDER BY
       column_id;


SET pages 1000;

PROMPT
PROMPT
PROMPT V$LOCK - Locks ( &&p_lockwait &&p_sid &&p_blocker_sid )
PROMPT ==============

SELECT *
  FROM v$lock
 WHERE sid IN (:v_sid, :v_blocker_sid)
 ORDER BY
       DECODE(sid,:v_sid,1,2),
       type,
       id1,
       id2;

PROMPT
PROMPT LMODE/REQUEST on V$LOCK rows ( &&p_sid &&p_blocker_sid )
PROMPT ============================
PROMPT 0: None
PROMPT 1: Null (NULL)
PROMPT 2: Row-S (SS) Row Share
PROMPT 3: Row-X (SX) Row Exclusive
PROMPT 4: Share (S) Share
PROMPT 5: S/Row-X (SSX) Share/Row Exclusive
PROMPT 6: Exclusive (X)


PROMPT
PROMPT
PROMPT V$LOCKED_OBJECT - Locked Objects ( &&p_sid &&p_blocker_sid )
PROMPT ================================

SELECT l.*,
       o.owner||'.'||o.object_name object_name
  FROM v$locked_object l,
       all_objects     o
 WHERE l.session_id IN (:v_sid, :v_blocker_sid)
   AND l.object_id = o.object_id
 ORDER BY
       DECODE(l.session_id,:v_sid,1,2),
       l.xidusn,
       l.xidslot,
       l.xidsqn;


PROMPT
PROMPT
PROMPT V$SESSION_EVENT - Waits for an Event ( &&p_sid &&p_blocker_sid )
PROMPT ====================================

SELECT *
  FROM v$session_event
 WHERE sid IN (:v_sid, :v_blocker_sid)
 ORDER BY
       DECODE(sid,:v_sid,1,2),
       event;


PROMPT
PROMPT
PROMPT V$SESSION_WAIT - Resources or Events waiting for ( &&p_sid &&p_blocker_sid )
PROMPT ================================================

SELECT sid,
       seq#,
       event,
       p1raw,
       p2raw,
       p3raw,
       p1,
       p2,
       p3,
       wait_time,
       seconds_in_wait,
       state
  FROM v$session_wait
 WHERE sid IN (:v_sid, :v_blocker_sid)
 ORDER BY
       DECODE(sid,:v_sid,1,2),
       event;


PROMPT
PROMPT
PROMPT V$SESSTAT - Session Statistics ( &&p_sid &&p_blocker_sid )
PROMPT ==============================

SELECT s.sid,
       s.value,
       n.name,
       TO_CHAR(n.class)||
       DECODE(n.class,1,'   User',2,'   Redo',4,'   Enqueue',8,'   Cache',
                      16,'  OS',32,'  Parallel Server',64,'  SQL',128,' Debug',
                      72,'  Cache + SQL',
                      NULL) class
  FROM v$sesstat  s,
       v$statname n
 WHERE s.statistic# = n.statistic#
   AND s.value <> 0
   AND s.sid IN (:v_sid, :v_blocker_sid)
 ORDER BY
       DECODE(s.sid,:v_sid,1,2),
       n.name;

SET pages 0;


PROMPT
PROMPT
PROMPT V$SQLAREA - Currently Executing ( &&p_sql_address &&p_sql_hash_value )
PROMPT ===============================
PROMPT

DROP   TABLE bde_$selection_&&p_sid;
CREATE TABLE bde_$selection_&&p_sid AS
SELECT rownum row_$num,
       '&&p_sid' sid,
       v.*
  FROM v$sqlarea v
 WHERE v.address    = '&&p_sql_address'
   AND v.hash_value = TO_NUMBER('&&p_sql_hash_value');

EXEC bde_$v2_&&p_sid..format_values(num_rows_in => 1, column_length_in => 1000);

SELECT column_values text
  FROM bde_$values_&&p_sid
 WHERE column_name = 'SQL_TEXT';

SELECT SUBSTR(column_name,1,30) column_name,
       column_values
  FROM bde_$values_&&p_sid
 WHERE TRIM(column_values) IS NOT NULL
   AND column_name NOT IN ('ROW_$NUM', 'SQL_TEXT')
 ORDER BY
       column_id;


PROMPT
PROMPT
PROMPT V$SQLAREA - Previous Execution ( &&p_prev_sql_addr &&p_prev_hash_value )
PROMPT ==============================
PROMPT

DROP   TABLE bde_$selection_&&p_sid;
CREATE TABLE bde_$selection_&&p_sid AS
SELECT rownum row_$num,
       '&&p_sid' sid,
       v.*
  FROM v$sqlarea v
 WHERE v.address    = '&&p_prev_sql_addr'
   AND v.hash_value = TO_NUMBER('&&p_prev_hash_value');

EXEC bde_$v2_&&p_sid..format_values(num_rows_in => 1, column_length_in => 1000);

SELECT column_values text
  FROM bde_$values_&&p_sid
 WHERE column_name = 'SQL_TEXT';

SELECT SUBSTR(column_name,1,30) column_name,
       column_values
  FROM bde_$values_&&p_sid
 WHERE TRIM(column_values) IS NOT NULL
   AND column_name NOT IN ('ROW_$NUM', 'SQL_TEXT')
 ORDER BY
       column_id;


PROMPT
PROMPT
PROMPT V$PROCESS - Process ( &&p_sid &&p_paddr &&p_blocker_sid &&p_blocker_paddr )
PROMPT ===================
PROMPT

DROP   TABLE bde_$selection_&&p_sid;
CREATE TABLE bde_$selection_&&p_sid AS
SELECT 1 row_$num,
       '&&p_sid' sid,
       v.*
  FROM v$process v
 WHERE v.addr  = '&&p_paddr'
 UNION ALL
SELECT 2 row_$num,
       '&&p_blocker_sid' sid,
       v.*
  FROM v$process v
 WHERE v.addr  = '&&p_blocker_paddr';

EXEC bde_$v2_&&p_sid..format_values(num_rows_in => 2, column_length_in => 30);

SELECT SUBSTR(column_name,1,30) column_name,
       column_values
  FROM bde_$values_&&p_sid
 WHERE TRIM(column_values) IS NOT NULL
   AND column_name      <> 'ROW_$NUM'
 ORDER BY
       column_id;


PROMPT
PROMPT
PROMPT V$TRANSACTION - Transaction ( &&p_sid &&p_taddr &&p_blocker_sid &&p_blocker_taddr )
PROMPT ===========================
PROMPT

DROP   TABLE bde_$selection_&&p_sid;
CREATE TABLE bde_$selection_&&p_sid AS
SELECT 1 row_$num,
       '&&p_sid' sid,
       v.*
  FROM v$transaction v
 WHERE v.addr  = '&&p_taddr'
 UNION ALL
SELECT 2 row_$num,
       '&&p_blocker_sid' sid,
       v.*
  FROM v$transaction v
 WHERE v.addr  = '&&p_blocker_taddr';

EXEC bde_$v2_&&p_sid..format_values(num_rows_in => 2, column_length_in => 30);

SELECT SUBSTR(column_name,1,30) column_name,
       column_values
  FROM bde_$values_&&p_sid
 WHERE TRIM(column_values) IS NOT NULL
   AND column_name      <> 'ROW_$NUM'
 ORDER BY
       column_id;

SET pages 10000;


PROMPT
PROMPT bde_session_locks_&&p_sid..txt has been generated.
PROMPT
PROMPT Recover the bde_session_locks_&&p_sid..txt spool file.
PROMPT Consolidate and compress together with other files generated into same directory.
PROMPT Upload consolidated/compressed file bde_results.zip file for further analysis.
PROMPT On NT, files may get created under $ORACLE_HOME/bin.
PROMPT

SPOOL off;

DROP PACKAGE bde_$v2_&&p_sid;
DROP TABLE   bde_$values_&&p_sid;
DROP TABLE   bde_$selection_&&p_sid;

SET ver on feed on trims off long 80 pages 24 lin 80 feed on;
SET sqlp SQL> sqln on serveroutput off num 10;
CLEAR BREAKS COLUMNS;

PROMPT
COLUMN ENDEDSE FORMAT A27 HEADING 'bde_session_locks.sql ended';
SELECT TO_CHAR(sysdate,'YYYY-MM-DD HH24:MI:SS') endedse FROM sys.dual;