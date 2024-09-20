/*$Header: coe_stats.sql 11.5 156968.1 2002/09/03               csierra coe $*/
SET term off ver off echo off feed off trims on;
/*=============================================================================

coe_stats.sql - Automates CBO Stats Gathering using FND_STATS and Table sizes

    *************************************************************
    This article is being delivered in Draft form and may contain
    errors.  Please use the MetaLink "Feedback" button to advise
    Oracle of any issues related to this article.
    *************************************************************


 Overview
 --------

    coe_stats.sql verifies the statistics in the data dictionary for all tables
    owned by installed Oracle Apps modules.  It generates a dynamic script
    coe_fix_stats.sql and a report COE_STATS.TXT.

    The generated report COE_STATS.TXT contains the list of tables that need
    to be analyzed, including the actual (former) number of rows and the
    suggested sample size for the next statistics gathering.

    The dynamic script generated coe_fix_stats.sql includes the commands to
    execute the FND_STATS packege to gather the statistics based on the number
    of days since last analyzed and the size of the table.

    The following ranges, percentages and frequencies are arbitrary, and must
    be reviewed and adjusted by each client according to specific needs:

 1. Tables that have no statistics: Estimates statistics with sample of 10%.

 2. If Table Number of Rows is between 1 and 10K: Computes statistics every 3
    weeks.  An estimate of 99.999999 causes a compute.  100% errors out.

 3. If Num Rows between 10K and 100K: Estimate 16% sample size, every 4 weeks.

 4. If Num Rows between 100K and 1M: Estimate 12% sample size, every 5 weeks.

 5. If Num Rows between 1M and 10M: Estimate 8% sample size, every 6 weeks.

 6. If Num Rows between 10M and 100M: Estimate 4% sample size, every 7 weeks.

 7. If Num Rows is greater than 100M: Estimate 2% sample size, every 8 weeks.


 Instructions
 ------------

 1. Copy this whole Note into a text file and name it coe_stats.sql

 2. Review and adjust ranges, percentages and frequencies accordingly.

    Run coe_stats.sql from apps with no parameters:

    # sqlplus apps/apps
    SQL> START coe_stats.sql;

 3. Review spooled output file COE_STATS.TXT file.  The spool file gets
    created on same directory from which this script is executed.  On NT,
    files may get created under $ORACLE_HOME/bin.

 4. This script coe_stats.sql executes at the end the dynamically generated
    script coe_fix_stats.sql.  If you want to disable the automatic execution
    of the generated script refreshing your stats, delete the line at the end
    containing the execution command 'START coe_fix_stats;'.


 Program Notes
 -------------

 1. Always download latest version from Metalink (Note:156968.1), or ftp from

    ftp://oracle-ftp.oracle.com/apps/patchsets/AOL/SCRIPTS/PERFORMANCE/

    In order to avoid cut and paste or word wraping issues, use better ftp

 2. This script has been tested on Oracle Apps 11.5.4 with Oracle 8.1.7.

 3. This coe_stats.sql script should be run once per week, during a quiet
    period.

 4. Be aware that deleting or gathering stats of any object, causes any parsed
    SQL statement referencing that object to be invalidated from the shared
    pool or library cache.  This means that deleting or gathering stats should
    be done during a quiet period in order to reduce users impact.

 5. For other SQL Tuning scripts, search on Metalink using keyword coescripts.

 6. A practical guide in Troubleshooting Oracle ERP Applications Performance
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

    Abstract: coe_stats.sql - Automates CBO Stats Gathering using FND_STATS
    Author: Carlos Sierra
    Date: 03-SEP-02
    Description: Creates dynamic SQL to gather stats based on table size
    EMail: carlos.sierra@oracle.com
    Internal_Only: N
    Keywords: CoE Script automate stats statistics gathering
    Metalink_Note: 156968.1
    New_Win: Y
    Product: SQL*Plus script
    Version: 11.5 2002/09/03
    Download: coe_stats.zip

=============================================================================*/

SET term off ver off echo off feed off trims on;
SET term on;
PROMPT
PROMPT Generating COE staging tables...
PROMPT
SET term off;

VARIABLE V_DEGREE VARCHAR2;
BEGIN
    SELECT TO_CHAR(MIN(TO_NUMBER(VALUE)))
      INTO :V_DEGREE
      FROM V$PARAMETER
     WHERE NAME IN ('parallel_max_servers','cpu_count');
END;
/

DROP   TABLE COE_SCHEMAS;
CREATE TABLE COE_SCHEMAS
    (OWNER VARCHAR2(30)) NOLOGGING CACHE;
DROP   TABLE COE_TABLES;
CREATE TABLE COE_TABLES
    (OWNER VARCHAR2(30),TABLE_NAME VARCHAR2(30),
     NUM_ROWS NUMBER, LAST_ANALYZED DATE,
     PERCENT NUMBER, PARTITIONED VARCHAR2(3)) NOLOGGING CACHE;

INSERT INTO COE_SCHEMAS
SELECT DISTINCT
       FOU.ORACLE_USERNAME
FROM
       FND_ORACLE_USERID         FOU,
       FND_PRODUCT_INSTALLATIONS FPI
WHERE
       FPI.ORACLE_ID        = FOU.ORACLE_ID
AND    FOU.ORACLE_USERNAME != 'SYS';

INSERT INTO COE_TABLES
SELECT AT.OWNER,
       AT.TABLE_NAME,
       AT.NUM_ROWS,
       AT.LAST_ANALYZED,
       DECODE(NVL(AT.NUM_ROWS,0),0,10,                  -- NULL or 0 (10%)
       DECODE(SIGN(AT.NUM_ROWS-    10000),-1,99.999999, -- 1-10K (100%)
       DECODE(SIGN(AT.NUM_ROWS-   100000),-1,16,        -- 10K-100K (16%)
       DECODE(SIGN(AT.NUM_ROWS-  1000000),-1,12,        -- 100K-1M (12%)
       DECODE(SIGN(AT.NUM_ROWS- 10000000),-1,8,         -- 1M-10M (8%)
       DECODE(SIGN(AT.NUM_ROWS-100000000),-1,4,2)))))), -- 10M-100M (4%)
       AT.PARTITIONED                                   -- >100M (2%)
FROM
       ALL_TABLES  AT,
       COE_SCHEMAS CS
WHERE
       CS.OWNER                  = AT.OWNER
AND   (AT.IOT_TYPE              IS NULL
OR     AT.IOT_TYPE              <> 'IOT_OVERFLOW')
AND    AT.TEMPORARY              = 'N'
AND   ((NVL(AT.NUM_ROWS,0)       =         0
AND     AT.LAST_ANALYZED         IS NULL)
OR     (NVL(AT.NUM_ROWS,0)      >=         0
AND     NVL(AT.NUM_ROWS,0)       <     10000
AND     TRUNC(AT.LAST_ANALYZED) <= TRUNC(SYSDATE) - 21)
OR     (AT.NUM_ROWS             >=     10000
AND     AT.NUM_ROWS              <    100000
AND     TRUNC(AT.LAST_ANALYZED) <= TRUNC(SYSDATE) - 28)
OR     (AT.NUM_ROWS             >=    100000
AND     AT.NUM_ROWS              <   1000000
AND     TRUNC(AT.LAST_ANALYZED) <= TRUNC(SYSDATE) - 35)
OR     (AT.NUM_ROWS             >=   1000000
AND     AT.NUM_ROWS              <  10000000
AND     TRUNC(AT.LAST_ANALYZED) <= TRUNC(SYSDATE) - 42)
OR     (AT.NUM_ROWS             >=  10000000
AND     AT.NUM_ROWS              < 100000000
AND     TRUNC(AT.LAST_ANALYZED) <= TRUNC(SYSDATE) - 49)
OR     (AT.NUM_ROWS             >= 100000000
AND     TRUNC(AT.LAST_ANALYZED) <= TRUNC(SYSDATE) - 56))
AND    NOT EXISTS (SELECT NULL
                   FROM FND_EXCLUDE_TABLE_STATS FETS
                   WHERE FETS.TABLE_NAME = AT.TABLE_NAME);

SET term off ver off echo off feed off trims on;
SET head off pages 0 lin 200;
SPOOL coe_fix_stats.sql;
COLUMN DUMMY1 FORMAT A30 NOPRINT;
SELECT OWNER||TABLE_NAME||'1' DUMMY1,
    SUBSTR('EXEC DBMS_STATS.DELETE_TABLE_STATS('||
    'ownname => '''||OWNER||''', '||
    'tabname => '''||TABLE_NAME||''');',1,200)
FROM
    COE_TABLES
UNION ALL
SELECT OWNER||TABLE_NAME||'2' DUMMY1, -- COMPUTES: EMPTY_BLOCKS,
    SUBSTR('ANALYZE TABLE '||         -- AVG_SPACE, AVG_ROW_LEN
    OWNER||'.'||TABLE_NAME||
    ' ESTIMATE STATISTICS SAMPLE 1 ROWS;',1,200)
FROM
    COE_TABLES
UNION ALL
SELECT OWNER||TABLE_NAME||'3',
    SUBSTR('EXEC FND_STATS.GATHER_TABLE_STATS('||
    'ownname=>'''||OWNER||''','||
    'tabname=>'''||TABLE_NAME||''','||
    'percent=>'||TO_CHAR(PERCENT)||','||
    'degree=>'||
    DECODE(SIGN(NVL(NUM_ROWS,0)-10000),-1,'1',0,'1',:V_DEGREE)||','||
    'granularity=>'||DECODE(PARTITIONED,'YES','''PARTITION''','''DEFAULT''')||
    ');',1,200)
FROM
    COE_TABLES
ORDER BY 1;
SPOOL off;

COLUMN OWNER_TABLE FORMAT A40 HEADING 'Owner.Table';
COLUMN PARTITIONED FORMAT A6 HEADING 'Parti-|tioned';
COLUMN NUM_ROWS FORMAT B999,999,999 HEADING 'Former|Num Rows';
COLUMN DAYS FORMAT B9,999,999.9 HEADING 'Days since|last analyze';
COLUMN PERCENT FORMAT B99,999 HEADING 'Sample|Percent';
COLUMN SAMPLE_ROWS FORMAT B999,999,999 HEADING 'Sample|Rows';
COLUMN MODULE FORMAT A10 HEADING 'Module';
COLUMN MODULE_TOTAL FORMAT 99,999,999 -
       HEADING 'Tables|Requiring|Stats|Gathering';
COLUMN LAST_ANALYZED_DATE FORMAT A14 HEADING 'Last Analyzed';
COLUMN TABLES FORMAT 999,999 HEADING 'Tables';

SET head on pages 1000 feed on;
SPOOL coe_stats.txt;
SELECT
    OWNER||'.'||TABLE_NAME
        OWNER_TABLE,
    PARTITIONED,
    NUM_ROWS,
    SYSDATE - LAST_ANALYZED
        DAYS,
    ROUND(PERCENT)
        PERCENT,
    ROUND(PERCENT * NUM_ROWS / 100)
        SAMPLE_ROWS
FROM
    COE_TABLES
ORDER BY OWNER||'.'||TABLE_NAME;

SET term on;

SELECT NVL(TO_CHAR(LAST_ANALYZED,'YYYY-MM-DD'),'Never Analyzed')
       LAST_ANALYZED_DATE,
       COUNT(*) TABLES
  FROM COE_TABLES
 GROUP BY NVL(TO_CHAR(LAST_ANALYZED,'YYYY-MM-DD'),'Never Analyzed');

SELECT
    SUBSTR(OWNER,1,10) MODULE,
    COUNT(*)           MODULE_TOTAL
FROM
    COE_TABLES
GROUP BY
    SUBSTR(OWNER,1,10);

SELECT
    COUNT(*)           MODULE_TOTAL
FROM
    COE_TABLES;

SET pages 0 echo on;
START coe_fix_stats.sql;
SPOOL off;
SET ver on trims off pages 24 lin 80;