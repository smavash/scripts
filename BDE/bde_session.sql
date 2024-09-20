/*$Header: bde_session.sql 8.1-9.0 169630.1 2002/09/03          csierra coe $*/
SET term off;
/*=============================================================================

bde_session.sql - Expensive SQL and resources utilization for given Session ID

    *************************************************************
    This article is being delivered in Draft form and may contain
    errors.  Please use the MetaLink "Feedback" button to advise
    Oracle of any issues related to this article.
    *************************************************************


 Overview
 --------

    bde_session.sql creates a report with relevant information for one session
    that is either performing poorly or not responding (hanging).

    The database session that performs poor or hangs, can be linked to a FORM
    or Concurrent Program (if using Oracle Apps), or it could be linked to any
    other type of database connection including SQL*Plus and PL/SQL.

    bde_session.sql takes only one execution parameter, which is the session
    id, also known as sid.

    If you are interested on finding out why one Apps Concurrent Request is
    hanging or not completing, use script bde_request.sql (Note:187504.1),
    which given a request_id finds its session id and executes this script
    bde_session.sql.

    bde_session.sql creates a spool file report with the details of the session
    requested, as well as the blocker session when the requested one is waiting
    on a lock being hold by a blocker.

    When a lock in the session is detected, it includes the object (table)
    being locked, as well as the rowid and all the column values for that
    particular row the session is trying to place a lock.

    bde_session.sql also shows session wait events and session statistics.  It
    displays all open SQL statements linked to the requested session and
    ranks them according to 7 categories related to logical and physical reads,
    memory utilization and number of executions.

    If the session is just performing poorly, it identifies the most expensive
    open SQL cursors, displays all their text, and executes the bde_x.sql
    script (Note:174603.1) to display their explain plan in separate spool
    files.  It also identifies and displays the SQL statement currently being
    executed (if any).

    The bde_session.sql is used to diagnose performance issues where one
    particular transaction is 'hanging' and SQL Trace was not turned on when
    the transaction started.  In some cases the transactions has been executing
    for many hours or days, and a quick and easy snapshot of its status is
    required to find out where it is at, and why it is hanging.

    For more details in detecting and resolving locking issues, read
    Note:102925.1


 Instructions
 ------------

 1. Copy this whole Note into a text file and name it bde_session.sql.

 2. Create a dedicated O/S directory and place on it this script
    bde_session.sql.

 3. Download script bde_x.sql from Note:174603.1, and place it on same
    directory with bde_session.sql.

    The spool files get created on same directory from which this script is
    executed. On NT, files may get created under $ORACLE_HOME/bin.

 4. Execute bde_session.sql with parameter of database Session ID.

    Use APPS user if used within Oracle Applications.  Use SYSTEM or any other
    user with access to V$ views for non Oracle Apps.

    # sqlplus apps/apps@vis11i
    SQL> START bde_session.sql <sid>;

 5. If sending results to Oracle, use WinZip to compress all spooled files into
    one single file.  Name it bde_results.zip before uploading.


 Program Notes
 -------------

 1. Always download latest version from Metalink (Note:169630.1), or ftp from

    ftp://oracle-ftp.oracle.com/apps/patchsets/AOL/SCRIPTS/PERFORMANCE/

    In order to avoid cut and paste or word wraping issues, use better ftp

 2. Set the fixed parameter p_top to value desired.  Suggested values are
    between 3 and 10.  Default and seeded value is 5, generating simple
    explain plan for the Top 5 (most expensive) open SQL statements linked
    to the session.

 3. If you need/want to suppress the automatic execution of bde_x.sql for
    each SQL statement identified as expensive, remove line at the end that
    has execution 'START bde_start_x.sql;'.

 4. Expensive SQL for which a flat file is generated and the bde_x.sql is
    executed, is defined as Top 'n' SQL stetements according to Logical Reads
    per Execution.

 5. For other SQL Tuning scripts, search on Metalink using keyword coescripts.

 6. A practical guide in Troubleshooting Oracle ERP Applications Performance
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


 Seeded Parameters
 -----------------

 1. p_top - Top 'n'

    This is the 'n' on the 'Top n' SQL statements.  Seeded at a value of 5 to
    generate simple explain plan for the Top 'n' open SQL statements linked to
    the session, and ranked according to logical reads per execution.


 Caution
 -------

    The sample program in this article is provided for educational purposes
    only and is NOT supported by Oracle Support Services.  It has been tested
    internally, however, and works as documented.  We do not guarantee that it
    will work for you, so be sure to test it in your environment before
    relying on it.


 Portal
 ------

    Abstract: bde_session.sql - Expensive SQL and resource usage for a Session
    Author: Carlos Sierra
    Date: 03-SEP-02
    Description: Top SQL, Explain Plans and Resource usage for one DB Session
    EMail: carlos.sierra@oracle.com
    Internal_Only: N
    Keywords: CoE sqltuning coescripts appsperf appssqltuning enqueue hang lock
    Metalink_Note: 169630.1
    New_Win: Y
    Product: SQL*Plus script
    Version: 8.1-9.0 2002/09/03
    Download: bde_session.zip

=============================================================================*/

SET term off ver off feed off trims on pages 0 lin 4050 long 32767 longc 78;
SET recsep off sqlp '' sqln off serveroutput on size 1000000 num 14;

DEFINE   p_top = 5;

VARIABLE v_top             NUMBER;

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
PROMPT bde_session.sql - Expensive SQL and Resource usage for one Session
PROMPT ========================================================================
PROMPT
PROMPT Usage:
PROMPT sqlplus apps/apps
PROMPT SQL> START bde_session.sql <sid>
PROMPT

BEGIN
    :v_top := TO_NUMBER('&&p_top');

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

DROP   TABLE coe_sqlarea_&&p_sid;
CREATE TABLE coe_sqlarea_&&p_sid
    (hash_value NUMBER,address RAW(20),buffer_gets$ NUMBER,disk_reads$ NUMBER,
     mem NUMBER,executions$ NUMBER,bg_per_exec NUMBER,dr_per_exec NUMBER,
     mem_per_exec NUMBER,parsing_user_id NUMBER,module VARCHAR2(64),
     action VARCHAR2(64),sql_text VARCHAR2(64),username VARCHAR2(30),
     row_num NUMBER,top_bg NUMBER,top_dr NUMBER,top_mem NUMBER,top_exec NUMBER,
     top_bgpe NUMBER,top_drpe NUMBER,top_mempe NUMBER, bde_x VARCHAR2(3))
     NOLOGGING CACHE;

DROP   TABLE coe_sqltext_&&p_sid;
CREATE TABLE coe_sqltext_&&p_sid
    (row_num NUMBER,piece NUMBER,sql_text VARCHAR2(64)) NOLOGGING CACHE;

DROP   TABLE coe_text_&&p_sid;
CREATE TABLE coe_text_&&p_sid
    (row_num NUMBER,text CLOB) NOLOGGING CACHE;

DROP   TABLE bde_$values_&&p_sid;
CREATE TABLE bde_$values_&&p_sid
    (column_id NUMBER,column_name VARCHAR2(30),column_values VARCHAR2(4000))
    NOLOGGING CACHE;

DROP   TABLE bde_$selection_&&p_sid;
CREATE TABLE bde_$selection_&&p_sid AS
SELECT * FROM dual;

PROMPT WARNING: "ORA-00942: table or view does not exist" ARE EXPECTED, PLEASE WAIT...

INSERT INTO coe_sqlarea_&&p_sid
SELECT  sa.hash_value,
        sa.address,
        ABS(sa.buffer_gets),
        ABS(sa.disk_reads),
        ABS(sa.sharable_mem)+ABS(sa.persistent_mem)+ABS(sa.runtime_mem),
        ABS(sa.executions),
        ROUND(ABS(sa.buffer_gets)/
        DECODE(NVL(ABS(sa.executions),0),0,1,ABS(sa.executions))),
        ROUND(ABS(sa.disk_reads)/
        DECODE(NVL(ABS(sa.executions),0),0,1,ABS(sa.executions))),
        ROUND((ABS(sa.sharable_mem)+ABS(sa.persistent_mem)+ABS(sa.runtime_mem))/
        DECODE(NVL(ABS(sa.executions),0),0,1,ABS(sa.executions))),
        sa.parsing_user_id,
        sa.module,
        sa.action,
        SUBSTR(sa.sql_text,1,64),
        NULL,
        NULL,
        NULL,
        NULL,
        NULL,
        NULL,
        NULL,
        NULL,
        NULL,
        NULL
   FROM v$sqlarea     sa,
        v$open_cursor oc
  WHERE oc.saddr      = :v_saddr
    AND oc.sid        = :v_sid
    AND sa.hash_value = oc.hash_value
    AND sa.address    = oc.address;

UPDATE coe_sqlarea_&&p_sid cs
   SET username = (SELECT username
                     FROM all_users
                    WHERE user_id=cs.parsing_user_id);

UPDATE coe_sqlarea_&&p_sid cs
   SET bde_x = 'YES'
 WHERE (    cs.hash_value = TO_NUMBER('&&p_sql_hash_value')
        AND cs.address    = '&&p_sql_address')
    OR (    cs.hash_value = TO_NUMBER('&&p_prev_hash_value')
        AND cs.address    = '&&p_prev_sql_addr');


DECLARE
    c_top     NUMBER;

    CURSOR c1 IS
        SELECT rowid
          FROM coe_sqlarea_&&p_sid
         ORDER BY buffer_gets$ DESC;

    CURSOR c2 IS
        SELECT rowid
          FROM coe_sqlarea_&&p_sid
         ORDER BY disk_reads$  DESC,
                  buffer_gets$ DESC;

    CURSOR c3 IS
        SELECT rowid
          FROM coe_sqlarea_&&p_sid
         ORDER BY mem          DESC,
                  buffer_gets$ DESC;

    CURSOR c4 IS
        SELECT rowid
          FROM coe_sqlarea_&&p_sid
         ORDER BY executions$  DESC,
                  buffer_gets$ DESC;

    CURSOR c5 IS
        SELECT rowid
          FROM coe_sqlarea_&&p_sid
         ORDER BY bg_per_exec  DESC;

    CURSOR c6 IS
        SELECT rowid
          FROM coe_sqlarea_&&p_sid
         ORDER BY dr_per_exec  DESC,
                  buffer_gets$ DESC;

    CURSOR c7 IS
        SELECT rowid
          FROM coe_sqlarea_&&p_sid
         ORDER BY mem_per_exec DESC,
                  buffer_gets$ DESC;

BEGIN
    c_top := 1;
    FOR t IN c1 LOOP
        UPDATE coe_sqlarea_&&p_sid cs
           SET top_bg = c_top
         WHERE rowid  = t.rowid;
        c_top := c_top+1;
    END LOOP;

    c_top := 1;
    FOR t IN c2 LOOP
        UPDATE coe_sqlarea_&&p_sid cs
           SET top_dr = c_top
         WHERE rowid  = t.rowid;
        c_top := c_top+1;
    END LOOP;

    c_top := 1;
    FOR t IN c3 LOOP
        UPDATE coe_sqlarea_&&p_sid cs
           SET top_mem = c_top
         WHERE rowid   = t.rowid;
        c_top := c_top+1;
    END LOOP;

    c_top := 1;
    FOR t IN c4 LOOP
        UPDATE coe_sqlarea_&&p_sid cs
           SET top_exec = c_top
         WHERE rowid    = t.rowid;
        c_top := c_top+1;
    END LOOP;

    c_top := 1;
    FOR t IN c5 LOOP
        UPDATE coe_sqlarea_&&p_sid cs
           SET row_num  = c_top,
               top_bgpe = c_top
         WHERE rowid    = t.rowid;
        c_top := c_top+1;
    END LOOP;

    c_top := 1;
    FOR t IN c6 LOOP
        UPDATE coe_sqlarea_&&p_sid cs
           SET top_drpe = c_top
         WHERE rowid    = t.rowid;
        c_top := c_top+1;
    END LOOP;

    c_top := 1;
    FOR t IN c7 LOOP
        UPDATE coe_sqlarea_&&p_sid cs
           SET top_mempe = c_top
         WHERE rowid    = t.rowid;
        c_top := c_top+1;
    END LOOP;
END;
/

UPDATE coe_sqlarea_&&p_sid cs
   SET cs.bde_x = 'YES'
 WHERE cs.top_bgpe  < :v_top+1
   AND cs.username <> 'SYS'
   AND NOT UPPER(cs.sql_text) LIKE '%BEGIN%'
   AND NOT UPPER(cs.sql_text) LIKE '%DECLARE%';

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

SET term on;
PROMPT
PROMPT Storing SQL Text of selected statements into staging table...
SET term off;

INSERT INTO coe_sqltext_&&p_sid
SELECT DISTINCT
       cs.row_num,
       st.piece,
       st.sql_text
  FROM coe_sqlarea_&&p_sid cs,
       v$sqltext   st
 WHERE
       (    cs.top_bg    <= :v_top
         OR cs.top_dr    <= :v_top
         OR cs.top_mem   <= :v_top
         OR cs.top_exec  <= :v_top
         OR cs.top_bgpe  <= :v_top
         OR cs.top_drpe  <= :v_top
         OR cs.top_mempe <= :v_top
         OR cs.bde_x      = 'YES'
        )
   AND cs.hash_value = st.hash_value
   AND cs.address    = st.address;

SET term on;
PROMPT
PROMPT Massaging SQL Text of expensive SQL (Top LR) to create Text files...
SET term off;

DECLARE
    c_rownum   NUMBER;
    c_text     VARCHAR2(32767);

    CURSOR c1 IS
        SELECT row_num
          FROM coe_sqlarea_&&p_sid
         WHERE bde_x = 'YES'
         ORDER BY row_num;

    CURSOR c2 IS
        SELECT sql_text
          FROM coe_sqltext_&&p_sid
         WHERE row_num = c_rownum
         ORDER BY piece;
BEGIN
    FOR t1 IN c1 LOOP
        c_rownum := t1.row_num;
        c_text   := NULL;

        FOR t2 IN c2 LOOP
            c_text := c_text||t2.sql_text;
        END LOOP;

        INSERT INTO coe_text_&&p_sid
        VALUES (t1.row_num,c_text);
    END LOOP;
END;
/

COMMIT;

SET term on;
PROMPT
PROMPT Extracting expensive SQL (Top LR per Exec) into O/S Text files...
PROMPT
SET term off;

SPOOL coe_sql_txt_&&p_sid..sql;
DECLARE
    CURSOR c1 IS
        SELECT TO_CHAR(row_num) row_num
          FROM coe_sqlarea_&&p_sid
         WHERE bde_x = 'YES'
         ORDER BY row_num;
BEGIN
    FOR t1 IN c1 LOOP
        DBMS_OUTPUT.PUT_LINE('SPOOL sql_'||
                             TO_CHAR(:v_sid)||
                             '_'||t1.row_num||'.txt');
        DBMS_OUTPUT.PUT_LINE('SELECT text '||
                               'FROM coe_text_&&p_sid '||
                              'WHERE row_num = '||t1.row_num||';');
        DBMS_OUTPUT.PUT_LINE('SPOOL OFF;');
    END LOOP;
END;
/
SPOOL OFF;
START coe_sql_txt_&&p_sid..sql;

SET term on;
PROMPT
PROMPT Creating bde_start_x.sql script...
PROMPT
SET term off;

SPOOL bde_start_x_&&p_sid..sql;
DECLARE
    CURSOR c1 IS
        SELECT TO_CHAR(row_num) row_num
          FROM coe_sqlarea_&&p_sid
         WHERE bde_x = 'YES'
         ORDER BY row_num;
BEGIN
    FOR t1 IN c1 LOOP
        DBMS_OUTPUT.PUT_LINE('START bde_x.sql sql_'||
                             TO_CHAR(:v_sid)||
                             '_'||t1.row_num||'.txt;');
    END LOOP;
END;
/
SPOOL OFF;


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
COLUMN BUFFER_GETS$ FORMAT 99,999,999,999 -
       HEADING 'Total|Logical Reads|(Buffer Gets)';
COLUMN DISK_READS$  FORMAT 99,999,999,999 -
       HEADING 'Total|Physical Reads|(Disk Reads)';
COLUMN MEM          FORMAT 99,999,999,999 -
       HEADING 'Total|Memory|(bytes)';
COLUMN EXECUTIONS$  FORMAT 99,999,999,999 -
       HEADING 'Total|Number of|Executions';
COLUMN BG_PER_EXEC  FORMAT 99,999,999,999 -
       HEADING 'Logical Reads|per Execution|(db blocks)';
COLUMN DR_PER_EXEC  FORMAT 99,999,999,999 -
       HEADING 'Physical Reads|per Execution|(db blocks)';
COLUMN MEM_PER_EXEC FORMAT 99,999,999,999 -
       HEADING 'Memory|per Execution|(bytes)';
COLUMN TOP_BGPE     FORMAT 9999 -
       HEADING 'Top|LR|per|Exec';
COLUMN TOP_DRPE     FORMAT 9999 -
       HEADING 'Top|PR|per|Exec';
COLUMN TOP_MEMPE    FORMAT 9999 -
       HEADING 'Top|Mem|per|Exec';
COLUMN TOP_EXEC     FORMAT 9999 -
       HEADING 'Top|Num|of|Exec';
COLUMN TOP_BG       FORMAT 9999 -
       HEADING 'Top|Logc|Read|LR'
COLUMN TOP_DR       FORMAT 9999 -
       HEADING 'Top|Phys|Read|PR';
COLUMN TOP_MEM      FORMAT 9999 -
       HEADING 'Top|Mem';
COLUMN ROW_NUM FORMAT 999999 HEADING 'SQL ID';
COLUMN USERNAME FORMAT A10 HEADING 'User';
COLUMN MODULE_ACTION FORMAT A50 HEADING 'Source (Module and Action)';
COLUMN SQL_TEXT_L1 FORMAT A64 HEADING 'SQL Text (first 64 bytes)';
COLUMN SQL_TEXT    FORMAT A64 HEADING 'SQL Text';
COLUMN HASH_VALUE  FORMAT 999999999999999 HEADING 'Hash Value';
COLUMN SQLADDRESS  FORMAT A8 HEADING 'Address';
COLUMN PIECE NOPRINT;
COLUMN DUMMY NOPRINT;

SET term on;
PROMPT
PROMPT Generating Report (bde_session_&&p_sid..txt spool file)...
PROMPT
PROMPT
SET term off;

SPOOL bde_session_&&p_sid..txt;
SET term on recsep wr;


SET pages 0;

PROMPT bde_session.sql 8.1-9.0 169630.1 2002/06/01   SID: &&p_sid

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
PROMPT Summary of SQL Statements linked to Session ( &&p_sid )
PROMPT ===========================================

SELECT cs.row_num,
       cs.bg_per_exec,
       cs.dr_per_exec,
       cs.mem_per_exec,
       cs.executions$,
       cs.buffer_gets$,
       cs.disk_reads$,
       cs.mem,
       cs.top_bgpe,
       cs.top_drpe,
       cs.top_mempe,
       cs.top_exec,
       cs.top_bg,
       cs.top_dr,
       cs.top_mem
  FROM coe_sqlarea_&&p_sid cs
 ORDER BY cs.row_num;

SELECT cs.row_num,
       sql_text sql_text_l1,
       SUBSTR(username,1,10) username,
       cs.hash_value,
       cs.address sqladdress,
       SUBSTR(module||' '||action,1,80) module_action
  FROM coe_sqlarea_&&p_sid cs
 ORDER BY cs.row_num;


SET pages 0;

PROMPT
PROMPT
PROMPT Top SQL in terms of Logical Reads per Execution ( &&p_sid )
PROMPT ===============================================
PROMPT

DROP   TABLE bde_$selection_&&p_sid;
CREATE TABLE bde_$selection_&&p_sid AS
SELECT cs.top_bgpe row_$num,
       cs.bg_per_exec,
       cs.row_num sql_id,
       v.*
  FROM coe_sqlarea_&&p_sid cs,
       v$sqlarea   v
 WHERE cs.top_bgpe  <= TO_NUMBER('&&p_top')
   AND cs.hash_value = v.hash_value
   AND cs.address    = v.address
 ORDER BY
       cs.top_bgpe;

EXEC bde_$v2_&&p_sid..format_values(num_rows_in => :v_top, column_length_in => 30);

SELECT SUBSTR(column_name,1,30) column_name,
       column_values
  FROM bde_$values_&&p_sid
 WHERE TRIM(column_values) IS NOT NULL
 ORDER BY
       column_id;


PROMPT
PROMPT
PROMPT Top SQL in terms of Physical Reads per Execution ( &&p_sid )
PROMPT ================================================
PROMPT

DROP   TABLE bde_$selection_&&p_sid;
CREATE TABLE bde_$selection_&&p_sid AS
SELECT cs.top_drpe row_$num,
       cs.dr_per_exec,
       cs.row_num sql_id,
       v.*
  FROM coe_sqlarea_&&p_sid cs,
       v$sqlarea   v
 WHERE cs.top_drpe  <= TO_NUMBER('&&p_top')
   AND cs.hash_value = v.hash_value
   AND cs.address    = v.address
 ORDER BY
       cs.top_drpe;

EXEC bde_$v2_&&p_sid..format_values(num_rows_in => :v_top, column_length_in => 30);

SELECT SUBSTR(column_name,1,30) column_name,
       column_values
  FROM bde_$values_&&p_sid
 WHERE TRIM(column_values) IS NOT NULL
 ORDER BY
       column_id;


PROMPT
PROMPT
PROMPT Top SQL in terms of Memory per Execution ( &&p_sid )
PROMPT ========================================
PROMPT

DROP   TABLE bde_$selection_&&p_sid;
CREATE TABLE bde_$selection_&&p_sid AS
SELECT cs.top_mempe row_$num,
       cs.mem_per_exec,
       cs.row_num sql_id,
       v.*
  FROM coe_sqlarea_&&p_sid cs,
       v$sqlarea   v
 WHERE cs.top_mempe  <= TO_NUMBER('&&p_top')
   AND cs.hash_value  = v.hash_value
   AND cs.address     = v.address
 ORDER BY
       cs.top_mempe;

EXEC bde_$v2_&&p_sid..format_values(num_rows_in => :v_top, column_length_in => 30);

SELECT SUBSTR(column_name,1,30) column_name,
       column_values
  FROM bde_$values_&&p_sid
 WHERE TRIM(column_values) IS NOT NULL
 ORDER BY
       column_id;


PROMPT
PROMPT
PROMPT Top SQL in terms of Total Number of Executions ( &&p_sid )
PROMPT ==============================================
PROMPT

DROP   TABLE bde_$selection_&&p_sid;
CREATE TABLE bde_$selection_&&p_sid AS
SELECT cs.top_exec row_$num,
       cs.executions$,
       cs.row_num sql_id,
       v.*
  FROM coe_sqlarea_&&p_sid cs,
       v$sqlarea   v
 WHERE cs.top_exec  <= TO_NUMBER('&&p_top')
   AND cs.hash_value = v.hash_value
   AND cs.address    = v.address
 ORDER BY
       cs.top_exec;

EXEC bde_$v2_&&p_sid..format_values(num_rows_in => :v_top, column_length_in => 30);

SELECT SUBSTR(column_name,1,30) column_name,
       column_values
  FROM bde_$values_&&p_sid
 WHERE TRIM(column_values) IS NOT NULL
 ORDER BY
       column_id;


PROMPT
PROMPT
PROMPT Top SQL in terms of Total Logical Reads ( &&p_sid )
PROMPT =======================================
PROMPT

DROP   TABLE bde_$selection_&&p_sid;
CREATE TABLE bde_$selection_&&p_sid AS
SELECT cs.top_bg row_$num,
       cs.buffer_gets$,
       cs.row_num sql_id,
       v.*
  FROM coe_sqlarea_&&p_sid cs,
       v$sqlarea   v
 WHERE cs.top_bg    <= TO_NUMBER('&&p_top')
   AND cs.hash_value = v.hash_value
   AND cs.address    = v.address
 ORDER BY
       cs.top_bg;

EXEC bde_$v2_&&p_sid..format_values(num_rows_in => :v_top, column_length_in => 30);

SELECT SUBSTR(column_name,1,30) column_name,
       column_values
  FROM bde_$values_&&p_sid
 WHERE TRIM(column_values) IS NOT NULL
 ORDER BY
       column_id;


PROMPT
PROMPT
PROMPT Top SQL in terms of Total Physical Reads ( &&p_sid )
PROMPT ========================================
PROMPT

DROP   TABLE bde_$selection_&&p_sid;
CREATE TABLE bde_$selection_&&p_sid AS
SELECT cs.top_dr row_$num,
       cs.disk_reads$,
       cs.row_num sql_id,
       v.*
  FROM coe_sqlarea_&&p_sid cs,
       v$sqlarea   v
 WHERE cs.top_dr    <= TO_NUMBER('&&p_top')
   AND cs.hash_value = v.hash_value
   AND cs.address    = v.address
 ORDER BY
       cs.top_dr;

EXEC bde_$v2_&&p_sid..format_values(num_rows_in => :v_top, column_length_in => 30);

SELECT SUBSTR(column_name,1,30) column_name,
       column_values
  FROM bde_$values_&&p_sid
 WHERE TRIM(column_values) IS NOT NULL
 ORDER BY
       column_id;


PROMPT
PROMPT
PROMPT Top SQL in terms of Total Memomy ( &&p_sid )
PROMPT ================================
PROMPT

DROP   TABLE bde_$selection_&&p_sid;
CREATE TABLE bde_$selection_&&p_sid AS
SELECT cs.top_mem row_$num,
       cs.mem,
       cs.row_num sql_id,
       v.*
  FROM coe_sqlarea_&&p_sid cs,
       v$sqlarea   v
 WHERE cs.top_mem   <= TO_NUMBER('&&p_top')
   AND cs.hash_value = v.hash_value
   AND cs.address    = v.address
 ORDER BY
       cs.top_mem;

EXEC bde_$v2_&&p_sid..format_values(num_rows_in => :v_top, column_length_in => 30);

SELECT SUBSTR(column_name,1,30) column_name,
       column_values
  FROM bde_$values_&&p_sid
 WHERE TRIM(column_values) IS NOT NULL
 ORDER BY
       column_id;


SET pages 10000;

PROMPT
PROMPT
PROMPT Full text of identified expensive SQL Statements ordered by SQL ID ( &&p_sid )
PROMPT ==================================================================

BREAK ON ROW_NUM SKIP 1;
SELECT csa.row_num,
       cst.piece,
       cst.sql_text
  FROM coe_sqlarea_&&p_sid csa,
       coe_sqltext_&&p_sid cst
 WHERE csa.row_num = cst.row_num
 ORDER BY
       csa.row_num,
       cst.piece;


PROMPT
PROMPT bde_session_&&p_sid..txt has been generated.
PROMPT
PROMPT Recover the bde_session_&&p_sid..txt spool file.
PROMPT Consolidate and compress together with other files generated into same directory.
PROMPT Upload consolidated/compressed file bde_results.zip file for further analysis.
PROMPT On NT, files may get created under $ORACLE_HOME/bin.
PROMPT

SPOOL off;

DROP PACKAGE bde_$v2_&&p_sid;
DROP TABLE   coe_sqlarea_&&p_sid;
DROP TABLE   coe_sqltext_&&p_sid;
DROP TABLE   coe_text_&&p_sid;
DROP TABLE   bde_$values_&&p_sid;
DROP TABLE   bde_$selection_&&p_sid;

SET ver on feed on trims off long 80 pages 24 lin 80 feed on;
SET sqlp SQL> sqln on serveroutput off num 10;
CLEAR BREAKS COLUMNS;

PROMPT
PROMPT Executing bde_x.sql for Expensive SQL statements
PROMPT
START bde_start_x_&&p_sid..sql;
PROMPT
COLUMN ENDEDSE FORMAT A21 HEADING 'bde_session.sql ended';
SELECT TO_CHAR(sysdate,'YYYY-MM-DD HH24:MI:SS') endedse FROM sys.dual;