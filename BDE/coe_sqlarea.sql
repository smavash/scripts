/*$Header: coe_sqlarea.sql 8.1-9.0 156967.1 2002/09/23          csierra coe $*/
SET term off ver off feed off trims on pages 0 lin 78 long 32767 longc 78;
SET recsep off sqlp '' sqln off serveroutput on size 1000000;
/*=============================================================================

coe_sqlarea.sql - Top 10 Expensive SQL from SQL Area (8.1-9.0)

    *************************************************************
    This article is being delivered in Draft form and may contain
    errors.  Please use the MetaLink "Feedback" button to advise
    Oracle of any issues related to this article.
    *************************************************************


 Overview
 --------

    coe_sqlarea.sql scans sql area and sql text v$ dynamic performance views
    and displays Top n SQL Statements in terms of resources utilization.

    Top n can be set to any number.  Default value for n is 10. Recommended
    values are between 5 and 10, but there is no hard-coded restriction.

    Reports Top n expensive SQL for following 5 resource categories.
    All totals reported, derived from v$ dynamic views, are since instance
    startup or since flushing the shared pool.

 1. Logical Reads (in Blocks).  Also known as Buffer Gets.  SQL statements
    executed one or many times, with a total number of logical reads really
    high (compared to total logical reads recorded on SQL area for all SQL).

 2. Physical Reads (in Blocks).  Also known as Disk Reads.  SQL statements
    executed one or many times, with a total number of physical reads really
    high (compared to total physical reads recorded on SQL area for all SQL).

 3. Number of Executions.  SQL statements executed thousands of times.

 4. Logical Reads (in Blocks) per Execution.  SQL statements performing a high
    number of logical reads per execution (average).

 5. Physical Reads (in Blocks) per Execution.  SQL statements performing a high
    number of physical reads per execution (average).

    This script is used when overall system performance is poor.  If only one
    process is hanging, use bde_session.sql instead (Note:169630.1).

    The coe_sqlarea.sql provides a quick way to browse the SQL area looking
    for 'bad SQL'.  In many cases, bad SQL is culprit of overall bad system
    performance.

    Once the bad SQL has been identified, use the bde_x.sql script to generate
    explain plans.  Find this bde_x.sql script under Note: 174603.1

    This coe_sqlarea.sql scripts selects from logical reads categories, those
    SQL statements executed by APPS and that are not calls to stored
    procedures.  These selected SQL statements are massaged into staging table
    COE_TEXT, and a text file is created for each of them.  Last, it executes
    the bde_x.sql script for each of these SQL statements in order to generate
    their explain plans.


 Instructions
 ------------

 1. Copy this whole Note into a text file and name it coe_sqlarea.sql.

 2. Create a dedicated O/S directory and place on it this script
    coe_sqlarea.sql.

 3. Download script bde_x.sql the same way from Note: 174603.1, and place it
    under same directory with coe_sqlarea.sql.  Latter calls bde_x.sql.

    On NT, files may get created under $ORACLE_HOME/bin.

 4. Download script coe_view.sql the same way from Note: 156972.1, and place
    it on same directory with coe_sqlarea.sql and bde_x.sql.  Latter calls
    coe_view.sql.

    On NT, files may get created under $ORACLE_HOME/bin.

 5. Execute coe_sqlarea.sql with no parameters.  Use APPS user if used within
    Oracle Applications.  Use SYSTEM or any other user for non Oracle Apps.

    # sqlplus  apps/apps@vis11i
    SQL> START coe_sqlarea.sql;

 6. Use O/S command (i.e. tar and compress for UNIX, or winzip for Windows) to
    consolidate all created ASCII files.  The spool files get created on same
    directory from which this coe_sqlarea.sql script is executed.  On NT, files
    may get created under $ORACLE_HOME/bin.

 7. Send or upload consolidated and compressed output file.  Name compressed
    file coesqlarea.zip.


 Program Notes
 -------------

 1. Always download latest version from Metalink (Note:156967.1), or ftp from

    ftp://oracle-ftp.oracle.com/apps/patchsets/AOL/SCRIPTS/PERFORMANCE/

    In order to avoid cut and paste or word wraping issues, use better ftp

 2. Set the fixed parameter p_top to value desired.  Suggested values are
    between 5 and 10.  Default and seeded value is 10, to report the Top 10.

 3. Temp COE_SQLAREA table is populated only with SQL statements above
    threshold values.  Threshold is defined here as 0.2% of the total SUM of
    corresponding resource category.  For example, thershold for logical reads
    is 0.2% of the total logical reads in SQL area.  This arbitrary 0.2%
    initial limit is to keep the COE_SQLAREA temp table very small.

    If 'n' (on Top 'n') is set to a high number, and coe_sqlarea.sql does not
    extract the Top 'n' statements, try decreasing the size of p_factor_th
    from seeded value of 0.0020 to lower values: 0.0010 or 0.0004

 4. If you want to suppress the display of expensive SQL executed by SYS, just
    remove the comment (--) placed in front of the corresponding condition
    within the query that feeds the insert into COE_SQLAREA
    (PARSING_USER_ID <> 0 AND).  USER_ID is zero for user SYS.

 5. For 8.1 or 9.0 use coe_sqlarea.sql from Note:156967.1

    For 8.0 use coe_sqlarea_80.sql from Note:163209.1

 6. If you need/want to suppress the automatic execution of bde_x.sql for
    each SQL statement identified as expensive, remove line at the end that
    has execution 'START bde_start_xplain.sql;'.

 7. Expensive SQL for which a flat file is generated and the bde_x.sql is
    executed, is defined as SQL stetements in the Top 'n' list for Logical
    Reads or Logical Reads per Execution, executed by any user with the
    exception of 'SYS', and verifying that SQL statement is not a call to a
    procedure.

 8. For other SQL Tuning scripts, search on Metalink using keyword coescripts.

 9. A practical guide in Troubleshooting Oracle ERP Applications Performance
    Issues can be found on Metalink under Note:169935.1


 User Parameters
 ---------------

    None.


 Seeded Parameters
 -----------------

 1. p_top - Top 'n'

    This is the 'n' on the 'Top n' SQL statements.  Seeded at a value of 10 to
    report the Top 10 SQL statements per resource category.  Change it to any
    desired value.  Recommended range is between 5 and 10.

 2. p_factor_th - Factor for initial threshold

    In most cases, expensive SQL consumes more than 0.2% of the total resources
    within its category.  In other words, expensive SQL in terms of logical
    reads for example, will consume more than 0.2% of total logical reads found
    on SQL area.  The only reason to set this factor is to reduce the size of
    the staging table COE_SQLAREA.  If for any reason, this coe_sqlarea.sql
    script does not report the Top 'n' SQL requested, but a lower number than
    'n', modify p_factor_th value to increase the size of the staging table.
    Try 0.0010 first.  If still the number of SQL statements displayed is less
    than 'n', set the p_factor_th to a lower number (i.e. 0.0004)
    This parameter is seeded to 0.0020 (0.2%).


 Caution
 -------

    The sample program in this article is provided for educational purposes
    only and is NOT supported by Oracle Support Services.  It has been tested
    internally, however, and works as documented.  We do not guarantee that it
    will work for you, so be sure to test it in your environment before
    relying on it.


 Portal
 ------

    Abstract: coe_sqlarea.sql - Top 10 Expensive SQL from SQL Area (8.1-9.0)
    Author: Carlos Sierra
    Date: 03-SEP-02
    Description: Top 10 SQL Statements per resource category (LR, PR, Exec)
    EMail: carlos.sierra@oracle.com
    Internal_Only: N
    Keywords: CoE sqltuning coescripts appsperf appssqltuning coe_xplain.sql
    Metalink_Note: 156967.1
    New_Win: Y
    Product: SQL*Plus script
    Version: 8.1-9.0 2002/09/03
    Download: coe_sqlarea.zip

=============================================================================*/

-- Seeded Parameters
DEFINE p_top       = 10;
DEFINE p_factor_th = 0.0020;

SET term off ver off feed off trims on pages 0 lin 78 long 32767 longc 78;
SET recsep off sqlp '' sqln off serveroutput on size 1000000;

variable v_count       number;
variable v_buffer_gets number;
variable v_disk_reads  number;
variable v_executions  number;
variable v_bg_per_exec number;
variable v_dr_per_exec number;
variable v_istartup    varchar2(15);

SET term on;
PROMPT
PROMPT Calculating SQL Area totals per category...
SET term off;

BEGIN
    SELECT COUNT(*),
           TRUNC(SUM(ABS(BUFFER_GETS))),
           TRUNC(SUM(ABS(DISK_READS))),
           TRUNC(SUM(ABS(EXECUTIONS))),
           TRUNC(SUM(ABS(BUFFER_GETS)/
           DECODE(NVL(ABS(EXECUTIONS),0),0,1,ABS(EXECUTIONS)))),
           TRUNC(SUM(ABS(DISK_READS)/
           DECODE(NVL(ABS(EXECUTIONS),0),0,1,ABS(EXECUTIONS))))
      INTO :v_count,
           :v_buffer_gets,
           :v_disk_reads,
           :v_executions,
           :v_bg_per_exec,
           :v_dr_per_exec
      FROM V$SQLAREA;
    SELECT TO_CHAR(STARTUP_TIME,'DD-MON-YY HH24:MI')
      INTO :v_istartup
      FROM V$INSTANCE
     WHERE ROWNUM = 1;
END;
/

SET term on;
PROMPT
PROMPT Creating staging COE tables...
SET term off;

DROP   TABLE COE_SQLAREA;
CREATE TABLE COE_SQLAREA
    (ROW_NUM NUMBER,HASH_VALUE NUMBER,ADDRESS RAW(20),BUFFER_GETS NUMBER,
     DISK_READS NUMBER,EXECUTIONS NUMBER,BG_PER_EXEC NUMBER,DR_PER_EXEC NUMBER,
     PARSING_USER_ID NUMBER,MODULE VARCHAR2(64),ACTION VARCHAR2(64),
     SQL_TEXT VARCHAR2(64),P_BUFFER_GETS NUMBER,P_DISK_READS NUMBER,
     P_EXECUTIONS NUMBER,P_BG_PER_EXEC NUMBER,P_DR_PER_EXEC NUMBER,
     USERNAME VARCHAR2(30),T_BUFFER_GETS NUMBER,T_DISK_READS NUMBER,
     T_EXECUTIONS NUMBER,T_BG_PER_EXEC NUMBER,T_DR_PER_EXEC NUMBER) NOLOGGING;

DROP   TABLE COE_SQLTEXT;
CREATE TABLE COE_SQLTEXT
    (ROW_NUM NUMBER,PIECE NUMBER,SQL_TEXT VARCHAR2(64)) NOLOGGING;

DROP   TABLE COE_TEXT;
CREATE TABLE COE_TEXT
    (ROW_NUM NUMBER,TEXT CLOB) NOLOGGING;

INSERT INTO COE_SQLAREA
SELECT  ROWNUM,
        HASH_VALUE,
        ADDRESS,
        ABS(BUFFER_GETS),
        ABS(DISK_READS),
        ABS(EXECUTIONS),
        ROUND(ABS(BUFFER_GETS)/
        DECODE(NVL(ABS(EXECUTIONS),0),0,1,ABS(EXECUTIONS))),
        ROUND(ABS(DISK_READS)/
        DECODE(NVL(ABS(EXECUTIONS),0),0,1,ABS(EXECUTIONS))),
        PARSING_USER_ID,
        MODULE,
        ACTION,
        SUBSTR(SQL_TEXT,1,64),
        ROUND(ABS(BUFFER_GETS)*100/:v_buffer_gets,3),
        ROUND(ABS(DISK_READS)*100/:v_disk_reads,3),
        ROUND(ABS(EXECUTIONS)*100/:v_executions,3),
        ROUND((ABS(BUFFER_GETS)/
        DECODE(NVL(ABS(EXECUTIONS),0),0,1,ABS(EXECUTIONS)))*100/
              :v_bg_per_exec,3),
        ROUND((ABS(DISK_READS)/
        DECODE(NVL(ABS(EXECUTIONS),0),0,1,ABS(EXECUTIONS)))*100/
              :v_dr_per_exec,3),
        NULL,
        NULL,
        NULL,
        NULL,
        NULL,
        NULL
   FROM V$SQLAREA
  WHERE
--      PARSING_USER_ID <> 0 AND
       (ABS(BUFFER_GETS)
        > TO_NUMBER('&&p_factor_th')*:v_buffer_gets
     OR ABS(DISK_READS)
        > TO_NUMBER('&&p_factor_th')*:v_disk_reads
     OR ABS(EXECUTIONS)
        > TO_NUMBER('&&p_factor_th')*:v_executions
     OR ABS(BUFFER_GETS)/DECODE(NVL(ABS(EXECUTIONS),0),0,1,ABS(EXECUTIONS))
        > TO_NUMBER('&&p_factor_th')*:v_bg_per_exec
     OR ABS(DISK_READS)/DECODE(NVL(ABS(EXECUTIONS),0),0,1,ABS(EXECUTIONS))
        > TO_NUMBER('&&p_factor_th')*:v_dr_per_exec);

UPDATE COE_SQLAREA CS
   SET USERNAME = (SELECT USERNAME
                     FROM ALL_USERS
                    WHERE USER_ID=CS.PARSING_USER_ID);

SET term on;
PROMPT
PROMPT Calculating Top &&p_top SQL per category...
SET term off;

DECLARE
    c_top     NUMBER;
    c_rownum  NUMBER;
    cursor C1 is
        SELECT ROW_NUM
          FROM COE_SQLAREA
         ORDER BY BUFFER_GETS DESC;
    cursor C2 is
        SELECT ROW_NUM
          FROM COE_SQLAREA
         ORDER BY DISK_READS DESC;
    cursor C3 is
        SELECT ROW_NUM
          FROM COE_SQLAREA
         ORDER BY EXECUTIONS DESC;
    cursor C4 is
        SELECT ROW_NUM
          FROM COE_SQLAREA
         ORDER BY BG_PER_EXEC DESC;
    cursor C5 is
        SELECT ROW_NUM
          FROM COE_SQLAREA
         ORDER BY DR_PER_EXEC DESC;
BEGIN
    c_top := 1;
    OPEN C1;
    LOOP
        FETCH C1 into c_rownum;
        EXIT when C1%NOTFOUND;
        EXIT when c_top = TO_NUMBER('&&p_top')+1;
        UPDATE COE_SQLAREA
           SET T_BUFFER_GETS = c_top
         WHERE ROW_NUM       = c_rownum
           AND BUFFER_GETS   > TO_NUMBER('&&p_factor_th')*:v_buffer_gets;
        c_top := c_top+1;
    END LOOP;
    CLOSE C1;
    c_top := 1;
    OPEN C2;
    LOOP
        FETCH C2 into c_rownum;
        EXIT when C2%NOTFOUND;
        EXIT when c_top = TO_NUMBER('&&p_top')+1;
        UPDATE COE_SQLAREA
           SET T_DISK_READS = c_top
         WHERE ROW_NUM      = c_rownum
           AND DISK_READS   > TO_NUMBER('&&p_factor_th')*:v_disk_reads;
        c_top := c_top+1;
    END LOOP;
    CLOSE C2;
    c_top := 1;
    OPEN C3;
    LOOP
        FETCH C3 into c_rownum;
        EXIT when C3%NOTFOUND;
        EXIT when c_top = TO_NUMBER('&&p_top')+1;
        UPDATE COE_SQLAREA
           SET T_EXECUTIONS = c_top
         WHERE ROW_NUM      = c_rownum
           AND EXECUTIONS   > TO_NUMBER('&&p_factor_th')*:v_executions;
        c_top := c_top+1;
    END LOOP;
    CLOSE C3;
    c_top := 1;
    OPEN C4;
    LOOP
        FETCH C4 into c_rownum;
        EXIT when C4%NOTFOUND;
        EXIT when c_top = TO_NUMBER('&&p_top')+1;
        UPDATE COE_SQLAREA
           SET T_BG_PER_EXEC = c_top
         WHERE ROW_NUM       = c_rownum
           AND BUFFER_GETS/DECODE(NVL(EXECUTIONS,0),0,1,EXECUTIONS)
                             > TO_NUMBER('&&p_factor_th')*:v_bg_per_exec;
        c_top := c_top+1;
    END LOOP;
    CLOSE C4;
    c_top := 1;
    OPEN C5;
    LOOP
        FETCH C5 into c_rownum;
        EXIT when C5%NOTFOUND;
        EXIT when c_top = TO_NUMBER('&&p_top')+1;
        UPDATE COE_SQLAREA
           SET T_DR_PER_EXEC = c_top
         WHERE ROW_NUM       = c_rownum
           AND DISK_READS/DECODE(NVL(EXECUTIONS,0),0,1,EXECUTIONS)
                             > TO_NUMBER('&&p_factor_th')*:v_dr_per_exec;
        c_top := c_top+1;
    END LOOP;
    CLOSE C5;
END;
/

SET term on;
PROMPT
PROMPT Shrinking staging table COE_SQLAREA...
SET term off;

DELETE COE_SQLAREA CS
 WHERE CS.T_BUFFER_GETS IS NULL
   AND CS.T_DISK_READS  IS NULL
   AND CS.T_EXECUTIONS  IS NULL
   AND CS.T_BG_PER_EXEC IS NULL
   AND CS.T_DR_PER_EXEC IS NULL;

UPDATE COE_SQLAREA CS
   SET CS.ROW_NUM = ROWNUM;

SET term on;
PROMPT
PROMPT Storing SQL Text of selected statements into staging table...
SET term off;

INSERT INTO COE_SQLTEXT
SELECT DISTINCT
       CS.ROW_NUM,
       ST.PIECE,
       ST.SQL_TEXT
  FROM COE_SQLAREA CS,
       V$SQLTEXT   ST
 WHERE
       CS.HASH_VALUE      = ST.HASH_VALUE
   AND CS.ADDRESS         = ST.ADDRESS;

SET term on;
PROMPT
PROMPT Massaging SQL Text of expensive SQL (LR) to create Text files...
SET term off;

INSERT INTO COE_TEXT CT
SELECT CS.ROW_NUM,NULL
  FROM COE_SQLAREA CS
 WHERE (CS.T_BUFFER_GETS IS NOT NULL
    OR  CS.T_BG_PER_EXEC IS NOT NULL)
-- AND CS.USERNAME = USER
   AND CS.USERNAME <> 'SYS'
   AND NOT UPPER(CS.SQL_TEXT) LIKE '%BEGIN%'
   AND NOT UPPER(CS.SQL_TEXT) LIKE '%DECLARE%';

DECLARE
    c_rownum   NUMBER;
    c_sql_text VARCHAR2(64);
    c_text     VARCHAR2(32767);
    cursor C6 is
        SELECT ROW_NUM
          FROM COE_TEXT
         ORDER BY ROW_NUM;
    cursor C7 is
        SELECT SQL_TEXT
          FROM COE_SQLTEXT
         WHERE ROW_NUM = c_rownum
         ORDER BY PIECE;
BEGIN
    OPEN C6;
    LOOP
        FETCH C6 into c_rownum;
        EXIT when C6%NOTFOUND;
        c_text := NULL;
        OPEN C7;
        LOOP
            FETCH C7 into c_sql_text;
            EXIT when C7%NOTFOUND;
            c_text := c_text||c_sql_text;
        END LOOP;
        UPDATE COE_TEXT
           SET TEXT = c_text
         WHERE ROW_NUM = c_rownum;
        CLOSE C7;
    END LOOP;
    CLOSE C6;
END;
/

COMMIT;

SET term on;
PROMPT
PROMPT Extracting expensive SQL (LR) into O/S Text files...
PROMPT
SET term off;

COLUMN TEXT FORMAT A78 WOR;
SPOOL coe_sql_txt.sql;
DECLARE
    c_rownum   VARCHAR2(3);
    cursor C8 is
        SELECT TO_CHAR(ROW_NUM)
          FROM COE_TEXT
         ORDER BY ROW_NUM;
BEGIN
    OPEN C8;
    LOOP
        FETCH C8 into c_rownum;
        EXIT when C8%NOTFOUND;
        DBMS_OUTPUT.PUT_LINE('SET term on;');
        DBMS_OUTPUT.PUT_LINE('PROMPT Extracting SQL statement '||c_rownum);
        DBMS_OUTPUT.PUT_LINE('SET term off;');
        DBMS_OUTPUT.PUT_LINE('SPOOL sql'||c_rownum||'.txt');
        DBMS_OUTPUT.PUT_LINE('SELECT text FROM coe_text WHERE row_num = '||
                             TO_NUMBER(c_rownum)||';');
        DBMS_OUTPUT.PUT_LINE('SPOOL OFF;');
    END LOOP;
    CLOSE C8;
END;
/
SPOOL OFF;
START coe_sql_txt.sql;

SET term on;
PROMPT
PROMPT Creating bde_start_xplain.sql script...
PROMPT
SET term off;

SPOOL bde_start_xplain.sql;
DECLARE
    c_rownum   VARCHAR2(3);
    cursor C9 is
        SELECT TO_CHAR(ROW_NUM)
          FROM COE_TEXT
         ORDER BY ROW_NUM;
BEGIN
    OPEN C9;
    LOOP
        FETCH C9 into c_rownum;
        EXIT when C9%NOTFOUND;
        DBMS_OUTPUT.PUT_LINE('START bde_x.sql sql'||c_rownum||'.txt;');
    END LOOP;
    CLOSE C9;
END;
/
SPOOL OFF;


COLUMN NAMESPACE FORMAT A15 HEADING 'Component';
COLUMN GETS FORMAT 999,999,999,999 HEADING 'Get Requests';
COLUMN GETHITRATIO FORMAT 999.9 HEADING 'Get|Hit|Ratio|Pct';
COLUMN PINS FORMAT 999,999,999,999 HEADING 'Pin Requests';
COLUMN PINHITRATIO FORMAT 999.9 HEADING 'Pin|Hit|Ratio|Pct';
COLUMN RELOADS FORMAT 999,999,999,999 HEADING 'Reloads'
COLUMN PINRELOADRATIO FORMAT 999.9 HEADING 'Pin|Reload|Ratio|Pct';
COLUMN INVALIDATIONS FORMAT 999,999,999,999 HEADING 'Invalidations';
COLUMN POOL_NAME FORMAT A20 HEADING 'SGA Structure';
COLUMN POOL_BYTES FORMAT 99,999,999,999 HEADING 'Size in Bytes';
COLUMN POOL_MBYTES FORMAT 99,999.9 HEADING 'Size in MB';
COLUMN SQL_COUNT FORMAT 999,999,999 HEADING 'SQL Count';
COLUMN S_BUFFER_GETS FORMAT 999,999,999,999 -
       HEADING '(A)|SQL Area Sum of|Logical Reads|(Buffer Gets)';
COLUMN S_DISK_READS  FORMAT 999,999,999,999 -
       HEADING '(B)|SQL Area Sum of|Physical Reads|(Disk Reads)';
COLUMN S_EXECUTIONS  FORMAT 999,999,999,999 -
       HEADING '(C)|SQL Area Sum of|Number of|Executions';
COLUMN S_BG_PER_EXEC FORMAT 999,999,999,999 -
       HEADING '(D)|SQL Area Sum of|Logical Reads|per Execution';
COLUMN S_DR_PER_EXEC FORMAT 999,999,999,999 -
       HEADING '(E)|SQL Area Sum of|Physical Reads|per Execution';
COLUMN DATE_TIME FORMAT A15 HEADING 'Execution|Date and Time';
COLUMN ISTARTUP FORMAT A15 HEADING 'Instance|Startup';
COLUMN T_BUFFER_GETS FORMAT 9999 HEADING 'Top|LR';
COLUMN T_DISK_READS  FORMAT 9999 HEADING 'Top|PR';
COLUMN T_EXECUTIONS  FORMAT 9999 HEADING 'Top|Exec';
COLUMN T_BG_PER_EXEC FORMAT 9999 HEADING 'Top|LR|per|Exec';
COLUMN T_DR_PER_EXEC FORMAT 9999 HEADING 'Top|PR|per|Exec';
COLUMN BUFFER_GETS FORMAT 99,999,999,999 -
       HEADING '(F)|Logical Reads|(Buffer Gets)';
COLUMN DISK_READS  FORMAT 99,999,999,999 -
       HEADING '(G)|Physical Reads|(Disk Reads)';
COLUMN EXECUTIONS  FORMAT 99,999,999,999 -
       HEADING '(H)|Number of|Executions';
COLUMN BG_PER_EXEC FORMAT 99,999,999,999 -
       HEADING '(I)|Logical Reads|per Execution';
COLUMN DR_PER_EXEC FORMAT 99,999,999,999 -
       HEADING '(J)|Physical Reads|per Execution';
COLUMN P_BUFFER_GETS FORMAT 999.999 -
       HEADING 'LR(*)|percent|(F/A)';
COLUMN P_DISK_READS  FORMAT 999.999 -
       HEADING 'PR(*)|percent|(G/B)';
COLUMN P_EXECUTIONS  FORMAT 999.999 -
       HEADING 'Exec(*)|percent|(H/C)';
COLUMN P_BG_PER_EXEC FORMAT 999.999 -
       HEADING 'LR(*)|per Exe|percent|(I/D)';
COLUMN P_DR_PER_EXEC FORMAT 999.999 -
       HEADING 'PR(*)|per Exe|percent|(J/E)';
COLUMN ROW_NUM FORMAT 999999 HEADING 'SQL ID';
COLUMN USERNAME FORMAT A10 HEADING 'User';
COLUMN MODULE_ACTION FORMAT A40 HEADING 'Source (Module and Action)';
COLUMN SQL_TEXT_L1 FORMAT A64 HEADING 'SQL Text (first 64 bytes)';
COLUMN SQL_TEXT    FORMAT A64 HEADING 'SQL Text';
COLUMN HASH_VALUE  FORMAT 999999999999999 HEADING 'Hash Value';
COLUMN PIECE NOPRINT;
COLUMN DUMMY NOPRINT;
COLUMN P_TIMESTAMP NEW_VALUE P_TIMESTAMP FORMAT A12;

SELECT TO_CHAR( SYSDATE,'YYYYMMDDHH24MI') P_TIMESTAMP FROM DUAL;


SET term on;
PROMPT
PROMPT Generating Report (coe_sqlarea_&&P_TIMESTAMP..txt spool file)...
PROMPT
PROMPT
SET term off;

SET ver off feed off trims on long 32767 longc 78;
SET sqlp '' sqln off serveroutput on size 1000000;
SET term on pages 10000 lin 156 recsep wr;
SPOOL coe_sqlarea_&&P_TIMESTAMP..txt;

PROMPT Library Cache statistics for SQL and PL/SQL
PROMPT ===========================================

SELECT NAMESPACE,
       GETS,
       ROUND(GETHITRATIO*100,1) GETHITRATIO,
       PINS,
       ROUND(PINHITRATIO*100,1) PINHITRATIO,
       RELOADS,
       ROUND((PINS-RELOADS)*100/DECODE(NVL(PINS,0),0,1,PINS),1) PINRELOADRATIO,
       INVALIDATIONS
  FROM V$LIBRARYCACHE
 WHERE NAMESPACE IN ('SQL AREA',
                     'TABLE/PROCEDURE',
                     'BODY',
                     'TRIGGER');
PROMPT
PROMPT
PROMPT Related Shared Pool SGA Structures
PROMPT ==================================

SELECT NAME                   POOL_NAME,
       BYTES                  POOL_BYTES,
       ROUND(BYTES/1048576,1) POOL_MBYTES
  FROM V$SGASTAT
 WHERE POOL = 'shared pool'
   AND NAME IN ('free memory',
                'sessions',
                'dictionary cache',
                'library cache',
                'sql area')
UNION ALL
SELECT 'Shared Pool Reserved',
       TO_NUMBER(VALUE),
       ROUND(TO_NUMBER(VALUE)/1048576,1)
  FROM V$PARAMETER
 WHERE NAME = 'shared_pool_reserved_size'
UNION ALL
SELECT 'Total Shared Pool',
       TO_NUMBER(VALUE),
       ROUND(TO_NUMBER(VALUE)/1048576,1)
  FROM V$PARAMETER
 WHERE NAME = 'shared_pool_size';

PROMPT
PROMPT
PROMPT SQL Area grand totals per category
PROMPT ==================================

SELECT :v_count                             SQL_COUNT,
       :v_buffer_gets                       S_BUFFER_GETS,
       :v_disk_reads                        S_DISK_READS,
       :v_executions                        S_EXECUTIONS,
       :v_bg_per_exec                       S_BG_PER_EXEC,
       :v_dr_per_exec                       S_DR_PER_EXEC,
       TO_CHAR(SYSDATE,'DD-MON-YY HH24:MI') DATE_TIME,
       :v_istartup                          ISTARTUP
  FROM DUAL;

PROMPT
PROMPT
PROMPT Top &&p_top most expensive SQL Statements per category
PROMPT =================================================

PROMPT
PROMPT
PROMPT Total Logical Reads
PROMPT ===================

BREAK ON DUMMY;
COMPUTE SUM OF BUFFER_GETS P_BUFFER_GETS ON DUMMY;
SELECT NULL DUMMY,
       T_BUFFER_GETS,
       ROW_NUM,
       BUFFER_GETS,
       P_BUFFER_GETS,
       SUBSTR(USERNAME,1,10) USERNAME,
       SUBSTR(MODULE||' '||ACTION,1,40) MODULE_ACTION,
       SQL_TEXT SQL_TEXT_L1
  FROM COE_SQLAREA
 WHERE T_BUFFER_GETS < TO_NUMBER('&&p_top')+1
 ORDER BY T_BUFFER_GETS;

PROMPT
PROMPT
PROMPT Total Physical Reads
PROMPT ====================

COMPUTE SUM OF DISK_READS P_DISK_READS ON DUMMY;
SELECT NULL DUMMY,
       T_DISK_READS,
       ROW_NUM,
       DISK_READS,
       P_DISK_READS,
       SUBSTR(USERNAME,1,10) USERNAME,
       SUBSTR(MODULE||' '||ACTION,1,40) MODULE_ACTION,
       SQL_TEXT SQL_TEXT_L1
  FROM COE_SQLAREA
 WHERE T_DISK_READS < TO_NUMBER('&&p_top')+1
 ORDER BY T_DISK_READS;

PROMPT
PROMPT
PROMPT Number of Executions
PROMPT ====================

COMPUTE SUM OF EXECUTIONS P_EXECUTIONS ON DUMMY;
SELECT NULL DUMMY,
       T_EXECUTIONS,
       ROW_NUM,
       EXECUTIONS,
       P_EXECUTIONS,
       SUBSTR(USERNAME,1,10) USERNAME,
       SUBSTR(MODULE||' '||ACTION,1,40) MODULE_ACTION,
       SQL_TEXT SQL_TEXT_L1
  FROM COE_SQLAREA
 WHERE T_EXECUTIONS < TO_NUMBER('&&p_top')+1
 ORDER BY T_EXECUTIONS;

PROMPT
PROMPT
PROMPT Logical Reads per Execution
PROMPT ===========================

COMPUTE SUM OF BG_PER_EXEC P_BG_PER_EXEC ON DUMMY;
SELECT NULL DUMMY,
       T_BG_PER_EXEC,
       ROW_NUM,
       BG_PER_EXEC,
       P_BG_PER_EXEC,
       SUBSTR(USERNAME,1,10) USERNAME,
       SUBSTR(MODULE||' '||ACTION,1,40) MODULE_ACTION,
       SQL_TEXT SQL_TEXT_L1
  FROM COE_SQLAREA
 WHERE T_BG_PER_EXEC < TO_NUMBER('&&p_top')+1
 ORDER BY T_BG_PER_EXEC;

PROMPT
PROMPT
PROMPT Physical Reads per Execution
PROMPT ============================

COMPUTE SUM OF DR_PER_EXEC P_DR_PER_EXEC ON DUMMY;
SELECT NULL DUMMY,
       T_DR_PER_EXEC,
       ROW_NUM,
       DR_PER_EXEC,
       P_DR_PER_EXEC,
       SUBSTR(USERNAME,1,10) USERNAME,
       SUBSTR(MODULE||' '||ACTION,1,40) MODULE_ACTION,
       SQL_TEXT SQL_TEXT_L1
  FROM COE_SQLAREA
 WHERE T_DR_PER_EXEC < TO_NUMBER('&&p_top')+1
 ORDER BY T_DR_PER_EXEC;

PROMPT
PROMPT Note(*): Percentage of grand total for SQL Area, per resource category
PROMPT

PROMPT
PROMPT Summary of SQL Statements on the 5 Top &&p_top lists
PROMPT ===============================================

BREAK ON DUMMY;
COMPUTE SUM OF BUFFER_GETS P_BUFFER_GETS DISK_READS P_DISK_READS -
               EXECUTIONS P_EXECUTIONS BG_PER_EXEC P_BG_PER_EXEC -
               DR_PER_EXEC P_DR_PER_EXEC ON DUMMY;
SELECT NULL DUMMY,
       CS.ROW_NUM,
       CS.BUFFER_GETS,
       CS.P_BUFFER_GETS,
       CS.DISK_READS,
       CS.P_DISK_READS,
       CS.EXECUTIONS,
       CS.P_EXECUTIONS,
       CS.BG_PER_EXEC,
       CS.P_BG_PER_EXEC,
       CS.DR_PER_EXEC,
       CS.P_DR_PER_EXEC
  FROM COE_SQLAREA CS
 ORDER BY CS.ROW_NUM;

PROMPT
PROMPT Note(*): Percentage of grand total for SQL Area, per resource category
PROMPT

SELECT CS.ROW_NUM,
       CS.T_BUFFER_GETS,
       CS.T_DISK_READS,
       CS.T_EXECUTIONS,
       CS.T_BG_PER_EXEC,
       CS.T_DR_PER_EXEC,
       CS.HASH_VALUE,
       SUBSTR(CS.USERNAME,1,10) USERNAME,
       SUBSTR(CS.MODULE||' '||CS.ACTION,1,40) MODULE_ACTION
  FROM COE_SQLAREA CS
 ORDER BY CS.ROW_NUM;

PROMPT
PROMPT
PROMPT Full text of identified expensive SQL Statements ordered by SQL ID
PROMPT ==================================================================

BREAK ON ROW_NUM SKIP 1 ON T_BUFFER_GETS ON T_DISK_READS -
      ON T_EXECUTIONS ON T_BG_PER_EXEC ON T_DR_PER_EXEC -
      ON USERNAME ON MODULE_ACTION;
SELECT CSA.ROW_NUM,
       CST.PIECE,
       CST.SQL_TEXT,
       CSA.T_BUFFER_GETS,
       CSA.T_DISK_READS,
       CSA.T_EXECUTIONS,
       CSA.T_BG_PER_EXEC,
       CSA.T_DR_PER_EXEC,
       SUBSTR(CSA.USERNAME,1,10) USERNAME,
       SUBSTR(CSA.MODULE||' '||CSA.ACTION,1,40) MODULE_ACTION
  FROM COE_SQLAREA CSA,
       COE_SQLTEXT CST
 WHERE CSA.ROW_NUM = CST.ROW_NUM
 ORDER BY CSA.ROW_NUM, CST.PIECE;

PROMPT coe_sqlarea_&&P_TIMESTAMP..txt has been generated.
PROMPT
PROMPT Recover the coe_sqlarea.txt spool file.  Consolidate and compress
PROMPT together with other files generated into same directory.  Upload
PROMPT the resulting consolidated/compressed file coesqlarea.zip file for
PROMPT further analysis.  On NT, files may get created under $ORACLE_HOME/bin.
PROMPT
PROMPT If you wish to print the spool file nicely, open it in Wordpad or Word.
PROMPT Use File -> Page Setup (menu option) to change Orientation to Landscape.
PROMPT Using same menu option make all 4 Margins 0.2".  Exit this menu option.
PROMPT Do a 'Select All' (Ctrl+A) and change Font to 'Courier New' Size 8.
PROMPT
SPOOL off;
UNDEFINE p_top,p_factor_th;
SET ver on feed on trims off long 80 pages 24 lin 80 feed on;
SET sqlp SQL> sqln on serveroutput off;
PROMPT
PROMPT Executing bde_x.sql for Expensive SQL statements
PROMPT
START bde_start_xplain.sql;
PROMPT
COLUMN ENDEDSA FORMAT A21 HEADING 'coe_sqlarea.sql ended';
SELECT TO_CHAR(SYSDATE,'YYYY-MM-DD HH24:MI:SS') ENDEDSA FROM SYS.DUAL;