/*$Header: coe_sqlarea_80.sql 8.0 163209.1 2002/09/03           csierra coe $*/
SET term off ver off feed off trims on;
/*=============================================================================

coe_sqlarea_80.sql - Top 10 Expensive SQL from SQL Area (8.0)

    *************************************************************
    This article is being delivered in Draft form and may contain
    errors.  Please use the MetaLink "Feedback" button to advise
    Oracle of any issues related to this article.
    *************************************************************


 Overview
 --------

    coe_sqlarea_80.sql scans sql area and sql text v$ dynamic performance views
    and displays Top n SQL Statements in terms of resources utilization.

    Top n can be set to any number.  Default value for n is 10. Recommended
    values are between 5 and 10, but there is no real limit.

    Reports Top n expensive SQL for following 5 resource categories:

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

    This script is used when a process is hanging and SQL trace was not turned
    on at the beginning of the transaction.  If the transaction is spinning
    executing a SQL statement (usually a query), the SQL doing the spin can
    be usually found by this script (if it is quite expensive).  Run the
    coe_sqlarea_80.sql script while the process performing poorly is either
    still executing, or just after completion.

    The coe_sqlarea_80.sql provides a quick way to browse the SQL area looking
    for 'bad SQL'.  In many cases, bad SQL is culprit of overall bad system
    performance.

    Once the bad SQL has been identified, use the coe_xplain.sql script to
    generate comprehensive explain plans and related information.  Find this
    coe_xplain.sql script under Note: 156958.1


 Instructions
 ------------

 1. Copy this whole Note into a text file and name it coe_sqlarea_80.sql

 2. Execute coe_sqlarea_80.sql with no parameters.  Use apps user if used for
    Oracle Applications.  Use system or any other user for non Oracle Apps.

    # sqlplus apps/apps@vis11

    SQL> START coe_sqlarea_80.sql;

 3. Send output spool file to Oracle Support.  The spool file gets created
    on same directory from which this script is executed.  On NT, files may
    get created under $ORACLE_HOME/bin.


 Program Notes
 -------------

 1. Always download latest version from Metalink (Note:163209.1), or ftp from

    ftp://oracle-ftp.oracle.com/apps/patchsets/AOL/SCRIPTS/PERFORMANCE/

    In order to avoid cut and paste or word wraping issues, use better ftp

 2. Set the fixed parameter p_top to value desired.  Suggested values are
    between 5 and 10.  Default is 10.

 3. Temp COE_SQLAREA table is populated only with SQL statements above
    threshold values.  Threshold is defined here as 0.4% of the total SUM of
    corresponding resource category.  For example, thershold for logical reads
    is 0.4% of the total logical reads in SQL area.  This arbitrary 0.4%
    initial limit is to keep the COE_SQLAREA temp table very small.

    If 'n' (on Top 'n') is set to a high number, and coe_sqlarea_80.sql does
    not extract the Top 'n' statements, try decreasing the size of p_factor_th
    from seeded value of 0.0040 to lower values: 0.0020 or 0.0010

 4. If you want to suppress the display of expensive SQL executed by SYS, just
    remove the comment (--) placed in front of the corresponding condition
    within the query that feeds the insert into COE_SQLAREA
    (PARSING_USER_ID <> 0 AND).  USER_ID is zero for user SYS.

 5. For 8.1 use coe_sqlarea.sql from Note:156967.1

    For 8.0 use coe_sqlarea_80.sql from Note:163209.1

 6. For other SQL Tuning scripts, search on Metalink using keyword coescripts.

 7. A practical guide in Troubleshooting Oracle ERP Applications Performance
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

    In most cases, expensive SQL consumes more than 0.4% of the total resources
    within its category.  In other words, expensive SQL in terms of logical
    reads for example, will consume more than 0.4% of total logical reads found
    on SQL area.  The only reason to set this factor is to reduce the size of
    the temp table COE_SQLAREA.  If for any reason, this coe_sqlarea_80.sql
    script does not report the Top 'n' SQL requested, but a lower number than
    'n', modify p_factor_th value to increase the size of the temp table.

    Try 0.0020 first.  If still the number of SQL statements displayed is less
    than 'n', set the p_factor_th to a lower number (i.e. 0.0010)
    This parameter is seeded to 0.0040 (0.4%).


 Caution
 -------

    The sample program in this article is provided for educational purposes
    only and is NOT supported by Oracle Support Services.  It has been tested
    internally, however, and works as documented.  We do not guarantee that it
    will work for you, so be sure to test it in your environment before
    relying on it.


 Portal
 ------

    Abstract: coe_sqlarea_80.sql - Top 10 Expensive SQL from SQL Area (8.0)
    Author: Carlos Sierra
    Date: 03-SEP-02
    Description: Top n SQL Statements per resource category (LR, PR, Exec)
    EMail: carlos.sierra@oracle.com
    Internal_Only: N
    Keywords: CoE sqltuning coescripts appsperf appssqltuning coe_xplain.sql
    Metalink_Note: 163209.1
    New_Win: Y
    Product: SQL*Plus script
    Version: 8.0 2002/09/03
    Download: coe_sqlarea_80.zip

=============================================================================*/

-- Seeded Parameters
define p_top       = 10;
define p_factor_th = 0.0040;

variable v_count       number;
variable v_buffer_gets number;
variable v_disk_reads  number;
variable v_executions  number;
variable v_bg_per_exec number;
variable v_dr_per_exec number;
variable v_istartup    varchar2(15);

SET term on ver off feed off trims on;
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
PROMPT Creating COE_SQLAREA temp table...
SET term off;
DROP   TABLE COE_SQLAREA;
CREATE TABLE COE_SQLAREA
    (ROW_NUM NUMBER,HASH_VALUE NUMBER,ADDRESS RAW(4),BUFFER_GETS NUMBER,
     DISK_READS NUMBER,EXECUTIONS NUMBER,BG_PER_EXEC NUMBER,DR_PER_EXEC NUMBER,
     PARSING_USER_ID NUMBER,MODULE VARCHAR2(64),ACTION VARCHAR2(64),
     SQL_TEXT VARCHAR2(64),P_BUFFER_GETS NUMBER,P_DISK_READS NUMBER,
     P_EXECUTIONS NUMBER,P_BG_PER_EXEC NUMBER,P_DR_PER_EXEC NUMBER,
     USERNAME VARCHAR2(30),T_BUFFER_GETS NUMBER,T_DISK_READS NUMBER,
     T_EXECUTIONS NUMBER,T_BG_PER_EXEC NUMBER,T_DR_PER_EXEC NUMBER) NOLOGGING;

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
    c_top := 1;
    OPEN C2;
    LOOP
        FETCH C2 into c_rownum;
        EXIT when C2%NOTFOUND;
        EXIT when c_top = TO_NUMBER('&&p_top')+1;
        UPDATE COE_SQLAREA
           SET T_DISK_READS = c_top
         WHERE ROW_NUM       = c_rownum
           AND DISK_READS   > TO_NUMBER('&&p_factor_th')*:v_disk_reads;
        c_top := c_top+1;
    END LOOP;
    c_top := 1;
    OPEN C3;
    LOOP
        FETCH C3 into c_rownum;
        EXIT when C3%NOTFOUND;
        EXIT when c_top = TO_NUMBER('&&p_top')+1;
        UPDATE COE_SQLAREA
           SET T_EXECUTIONS = c_top
         WHERE ROW_NUM       = c_rownum
           AND EXECUTIONS    > TO_NUMBER('&&p_factor_th')*:v_executions;
        c_top := c_top+1;
    END LOOP;
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
END;
/

UPDATE COE_SQLAREA CS
   SET CS.ROW_NUM = ROWNUM
 WHERE ( CS.T_BUFFER_GETS < TO_NUMBER('&&p_top')+1 OR
         CS.T_DISK_READS  < TO_NUMBER('&&p_top')+1 OR
         CS.T_EXECUTIONS  < TO_NUMBER('&&p_top')+1 OR
         CS.T_BG_PER_EXEC < TO_NUMBER('&&p_top')+1 OR
         CS.T_DR_PER_EXEC < TO_NUMBER('&&p_top')+1 );

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

SET term on;
PROMPT Generating SPOOL file...
PROMPT
PROMPT
SET term off;

SET term on pages 10000 lines 156;
SPOOL coe_sqlarea_80.txt;

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
 WHERE ( CS.T_BUFFER_GETS < TO_NUMBER('&&p_top')+1 OR
         CS.T_DISK_READS  < TO_NUMBER('&&p_top')+1 OR
         CS.T_EXECUTIONS  < TO_NUMBER('&&p_top')+1 OR
         CS.T_BG_PER_EXEC < TO_NUMBER('&&p_top')+1 OR
         CS.T_DR_PER_EXEC < TO_NUMBER('&&p_top')+1 )
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
 WHERE ( CS.T_BUFFER_GETS < TO_NUMBER('&&p_top')+1 OR
         CS.T_DISK_READS  < TO_NUMBER('&&p_top')+1 OR
         CS.T_EXECUTIONS  < TO_NUMBER('&&p_top')+1 OR
         CS.T_BG_PER_EXEC < TO_NUMBER('&&p_top')+1 OR
         CS.T_DR_PER_EXEC < TO_NUMBER('&&p_top')+1 )
 ORDER BY CS.ROW_NUM;

PROMPT
PROMPT
PROMPT Full text of identified expensive SQL Statements ordered by SQL ID
PROMPT ==================================================================

BREAK ON ROW_NUM SKIP 1 ON T_BUFFER_GETS ON T_DISK_READS -
      ON T_EXECUTIONS ON T_BG_PER_EXEC ON T_DR_PER_EXEC -
      ON USERNAME ON MODULE_ACTION;
SELECT CS.ROW_NUM,
       ST.PIECE,
       ST.SQL_TEXT,
       CS.T_BUFFER_GETS,
       CS.T_DISK_READS,
       CS.T_EXECUTIONS,
       CS.T_BG_PER_EXEC,
       CS.T_DR_PER_EXEC,
       SUBSTR(CS.USERNAME,1,10) USERNAME,
       SUBSTR(CS.MODULE||' '||CS.ACTION,1,40) MODULE_ACTION
  FROM COE_SQLAREA CS,
       V$SQLTEXT   ST
 WHERE
       CS.HASH_VALUE      = ST.HASH_VALUE
   AND CS.ADDRESS         = ST.ADDRESS
   AND ( CS.T_BUFFER_GETS < TO_NUMBER('&&p_top')+1 OR
         CS.T_DISK_READS  < TO_NUMBER('&&p_top')+1 OR
         CS.T_EXECUTIONS  < TO_NUMBER('&&p_top')+1 OR
         CS.T_BG_PER_EXEC < TO_NUMBER('&&p_top')+1 OR
         CS.T_DR_PER_EXEC < TO_NUMBER('&&p_top')+1 )
 ORDER BY CS.ROW_NUM, ST.PIECE;

PROMPT coe_sqlarea_80.txt has been generated.
PROMPT
PROMPT Recover the coe_sqlarea_80.txt spool file, compress into file
PROMPT coesqlarea.zip and send/upload the resulting coesqlarea.zip file for
PROMPT further analysis.
PROMPT
PROMPT If you wish to print the spool file nicely, open it in Wordpad or Word.
PROMPT Use File -> Page Setup (menu option) to change Orientation to Landscape.
PROMPT Using same menu option make all 4 Margins 0.2".  Exit this menu option.
PROMPT Do a 'Select All' (Ctrl+A) and change Font to 'Courier New' Size 8.
PROMPT
SPOOL off;
UNDEFINE p_top,p_factor_th;
SET ver on feed on trims off long 80 pages 24 lin 80 feed on;
SET sqlp SQL> sqln on;