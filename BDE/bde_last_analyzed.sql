/*$Header: bde_last_analyzed.sql 11.5 163208.1 2002/09/03       csierra bde $*/
SET term off feed off pages 30000 lin 1000 trims on serveroutput on size 10000;
/*=============================================================================

bde_last_analyzed.sql - Verifies Statistics for all installed Apps modules 11.5

    *************************************************************
    This article is being delivered in Draft form and may contain
    errors.  Please use the MetaLink "Feedback" button to advise
    Oracle of any issues related to this article.
    *************************************************************


 Overview
 --------

    bde_last_analyzed.sql verifies the statistics in the data dictionary for
    all tables.

    It also validates the statistics on tables and indexes owned by 'SYS'.

    This script is used when bad overall database performance is noticed.

    Due to CBO use of statistics to generate optimal execution plans, verifying
    that CBO stats are current is the first step to troubleshoot an overall
    Apps performance issue.

    The generated reports bde_last_analyzed.txt, present the total of tables
    and indexes analyzed per module and per date.

    If some modules have not been analyzed, or they have but not recently,
    these Apps objects must be analyzed using FND_STATS or coe_stats.sql if
    belonging to Oracle Apps.  Otherwise use DBMS_STATS.

    If tables or indexes owned by 'SYS' have CBO stats generated, you need to
    drop such statistics using DBMS_STATS.


 Instructions
 ------------

 1. Copy this whole Note into a text file and name it bde_last_analyzed.sql.

 2. Remove any lines before the '$Header' line and after the 'SPOOL OFF' and
    'SET' command, at the very end of the script.

 3. Run bde_last_analyzed.sql from sqlplus using APPS with no parameters.
    Non Oracle Apps databases can use SYSTEM.

       sqlplus apps/apps@vis11i
       SQL> START bde_last_analyzed.sql;

 4. Review spool output files bde_last_analyzed.txt file.  Spool files get
    created on same directory from which this script is executed.  On NT,
    files may get created under $ORACLE_HOME/bin.

    Concentrate in the Summary section at the beginning of the spool file.

 5. If statistics are more then one month old, you must gather new stats on
    affected modules(schemas).

    If Oracle Apps, use corresponding concurrent program with an estimate of
    10%, or execute equivalent FND_STATS procedure from
    SQL*Plus:

       sqlplus apps/apps@vis11i
       SQL> exec fnd_stats.gather_schema_statistics('APPLSYS');

    Where 'APPLSYS' is the module(schema) that requires new statistics.

 6. If only a few tables require to have their statistics gathered, use the
    corresponding concurrent program to gather stats by table, or execute
    equivalent FND_STATS procedure from SQL*Plus:

       sqlplus apps/apps@vis11i
       SQL> exec fnd_stats.gather_table_stats('MRP','MRP_FORECAST_DATES');

    Where 'MRP' is the schema owner, and 'MRP_FORECAST_DATES' is the table
    name.  This syntax is only for non-partitioned Tables.

 7. If USER 'SYS' have objects with statistics gathered, other than table
    SYS.DUAL, delete the statistics of all their schema objects using
    corresponding DBMS_STATS procedure, and re-gather stats for table
    SYS.DUAL:

       sqlplus apps/apps@vis11i
       SQL> exec dbms_stats.delete_schema_stats('SYS');
       SQL> exec fnd_stats.gather_table_stats('SYS','DUAL');
       SQL> exec dbms_stats.delete_schema_stats('SYSTEM');

    Be aware that deleting or gathering stats of any object, causes any parsed
    SQL statement referencing that object to be invalidated from the shared
    pool or library cache.  This means that deleting or gathering stats should
    be done during a quiet period in order to reduce users impact.

 8. If gathering new stats was necessary and performed, execute this script
    again to produce new reports bde_last_analyzed.txt.  Review Summary
    section again to certify all stats are correct.

 9. Once your statistics are current, validate if your entire Application is
    still performing poorly and proceed to monitor system/db performance with
    OS tools (VMSTAT, IOSTAT, MPSTAT and TOP) and db STATSPACK package.

10. If any Partitioned Table requires its Global Stats being rebuilt, it is
    because at some point you gathered Stats on the table using a granularity
    of DEFAULT or GLOBAL.  Once a Partitioned Table gets its Stats gathered
    at the GLOBAL level (DEFAULT also gathers GLOBAL), a flag is set causing
    the automatic rollup of PARTITION Stats to stop working, i.e. the sync
    between global stats at the Table level and partition stats at the
    Partition level gets broken.  From that moment on, every time you gather
    stats with the granularity of PARTITION, the CBO stats does not rollup into
    the global stats and the latter become outdated.  There are two ways to fix
    this: deleting the global stats and gathering one or more partitions with
    the granularity of PARTITION; or, deleting all stats and regathering all
    partitions with granularity = 'PARTITION'.  See second method below:

       begin
         dbms_stats.delete_table_stats(ownname => 'APPLSYS',
                                       tabname => 'WF_ITEM_ACTIVITY_STATUSES');
         fnd_stats.gather_table_stats (ownname => 'APPLSYS',
                                       tabname => 'WF_ITEM_ACTIVITY_STATUSES',
                                       granularity => 'PARTITION');
       end;
       /

    Once you fix your stats, be sure to ALWAYS use the granularity of
    PARTITION for partitioned tables.  Be aware that GATHER_SCHEMA_STATISTICS
    of the FND_STATS package issues the partitioned table command correctly,
    including the granularity of PARTITION.  On the other hand, the
    GATHER_TABLE_STATS defaults to granularity of DEFAULT, breaking the sync
    of global v.s. partition stats on a partitioned table.  Therefore, every
    time you gather stats for a partition tabled using the GATHER_TABLE_STATS
    procedure directly (SQL*Plus or Concurrent Program), be sure to manually
    specify the granularity of PARTITION.


 Program Notes
 -------------

 1. Always download latest version from Metalink (Note:163208.1), or ftp from

    ftp://oracle-ftp.oracle.com/apps/patchsets/AOL/SCRIPTS/PERFORMANCE/

    In order to avoid cut and paste or word wraping issues, use better ftp

 2. This script has been tested on Oracle Apps 11.5.4 with Oracle 8.1.7.

 3. This bde_last_analyzed.sql script should be run whenever you notice the
    performance of several Apps transactions is poor.  Bad stats is the
    number 1 reason to experience bad performance in Oracle Apps 11i.

 4. To gather stats, use FND_STATS from SQL*Plus or from corresponding
    concurrent program under SYSADMIN reponsibility.  Use 'Gather Schema
    Statistics' (pass only schema name) or 'Gather Table Statistics' (pass only
    owner and table name).  You may want to consider using script coe_stats.sql
    as an alternative to schedule stats gathering (see Note:156968.1).

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

    Abstract: bde_last_analyzed.sql - Verifies Statistics for all Apps modules
    Author: Carlos Sierra
    Date: 03-SEP-02
    Description: Validation of Apps CBO statistics per date and module
    EMail: carlos.sierra@oracle.com
    Internal_Only: N
    Keywords: CoE stats statistics gathering coescripts bdescripts BDE
    Metalink_Note: 163208.1
    New_Win: Y
    Product: SQL*Plus script
    Version: 11.5 2002/09/03
    Download: bde_last_analyzed.zip

=============================================================================*/

SET term off feed off pages 30000 lin 1000 trims on serveroutput on size 10000;

SET term on;
PROMPT Generating BDE_SCHEMAS staging table...
SET term off;

DROP   TABLE BDE_SCHEMAS;
CREATE TABLE BDE_SCHEMAS
    (OWNER VARCHAR2(30));

INSERT INTO BDE_SCHEMAS
SELECT DISTINCT
       FOU.ORACLE_USERNAME
  FROM FND_ORACLE_USERID         FOU,
       FND_PRODUCT_INSTALLATIONS FPI
 WHERE FPI.ORACLE_ID        = FOU.ORACLE_ID
   AND FOU.ORACLE_USERNAME <> 'SYS';


SET term on;
PROMPT Generating BDE_TABLES staging table...
SET term off;
col OWNER format a5
col CHAIN_CNT format 999

DROP   TABLE BDE_TABLES;
CREATE TABLE BDE_TABLES AS
SELECT OWNER,
       TABLE_NAME,
       INI_TRANS,
       FREELISTS,
       FREELIST_GROUPS,
       LOGGING,
       NUM_ROWS,
       BLOCKS,
       CHAIN_CNT,
       DEGREE,
       CACHE,
       LAST_ANALYZED,
       PARTITIONED,
       IOT_TYPE,
       GLOBAL_STATS
  FROM ALL_TABLES
 WHERE ( IOT_TYPE IS NULL
    OR   IOT_TYPE <> 'IOT_OVERFLOW' )
   AND TEMPORARY  = 'N';


SET term on;
PROMPT Generating BDE_INDEXES staging table...
SET term off;

DROP   TABLE BDE_INDEXES;
CREATE TABLE BDE_INDEXES AS
SELECT OWNER,
       INDEX_NAME,
       INDEX_TYPE,
       TABLE_OWNER,
       TABLE_NAME,
       UNIQUENESS,
       INI_TRANS,
       FREELISTS,
       FREELIST_GROUPS,
       PCT_FREE,
       LOGGING,
       LEAF_BLOCKS,
       NUM_ROWS,
       LAST_ANALYZED,
       SUBSTR(DEGREE,1,10) DEGREE,
       PARTITIONED,
       GLOBAL_STATS
  FROM ALL_INDEXES
 WHERE INDEX_TYPE <> 'DOMAIN'
   AND TEMPORARY  = 'N';


SET term on;
PROMPT Generating BDE_TABLES_SUMMARY staging table...
SET term off;

DROP   TABLE BDE_TABLES_SUMMARY;
CREATE TABLE BDE_TABLES_SUMMARY AS
SELECT OWNER,
       NVL(TO_CHAR(LAST_ANALYZED,'YYYY-MM-DD'),'0000-00-00') LAST_ANALYZED,
       TRUNC(SYSDATE)-TRUNC(LAST_ANALYZED) AGE,
       COUNT(*) TABLES
  FROM BDE_TABLES
 GROUP BY
       OWNER,
       NVL(TO_CHAR(LAST_ANALYZED,'YYYY-MM-DD'),'0000-00-00'),
       TRUNC(SYSDATE)-TRUNC(LAST_ANALYZED);


SET term on;
PROMPT Generating BDE_INDEXES_SUMMARY staging table...
SET term off;

DROP   TABLE BDE_INDEXES_SUMMARY;
CREATE TABLE BDE_INDEXES_SUMMARY AS
SELECT OWNER,
       NVL(TO_CHAR(LAST_ANALYZED,'YYYY-MM-DD'),'0000-00-00') LAST_ANALYZED,
       TRUNC(SYSDATE)-TRUNC(LAST_ANALYZED) AGE,
       COUNT(*) INDEXES
  FROM BDE_INDEXES
 GROUP BY
       OWNER,
       NVL(TO_CHAR(LAST_ANALYZED,'YYYY-MM-DD'),'0000-00-00'),
       TRUNC(SYSDATE)-TRUNC(LAST_ANALYZED);


SET term on;
PROMPT Generating BDE_TAB_PARTITIONS staging table...
SET term off;

DROP   TABLE BDE_TAB_PARTITIONS;
CREATE TABLE BDE_TAB_PARTITIONS AS
SELECT TABLE_OWNER,
       TABLE_NAME,
       PARTITION_NAME,
       SUBPARTITION_COUNT,
       PARTITION_POSITION,
       INI_TRANS,
       FREELISTS,
       FREELIST_GROUPS,
       LOGGING,
       NUM_ROWS,
       BLOCKS,
       CHAIN_CNT,
       LAST_ANALYZED,
       GLOBAL_STATS
  FROM ALL_TAB_PARTITIONS;


SET term on;
PROMPT Generating BDE_IND_PARTITIONS staging table...
SET term off;

DROP   TABLE BDE_IND_PARTITIONS;
CREATE TABLE BDE_IND_PARTITIONS AS
SELECT INDEX_OWNER,
       INDEX_NAME,
       PARTITION_NAME,
       SUBPARTITION_COUNT,
       PARTITION_POSITION,
       INI_TRANS,
       FREELISTS,
       FREELIST_GROUPS,
       LOGGING,
       LEAF_BLOCKS,
       NUM_ROWS,
       LAST_ANALYZED,
       GLOBAL_STATS
  FROM ALL_IND_PARTITIONS;


SET term on;
PROMPT Generating BDE_TABLES spool file...
SET term off;

SPOOL bde_last_analyzed_tables.txt;
SELECT *
  FROM bde_tables
 ORDER BY
       owner,
       table_name;
SPOOL OFF;


SET term on;
PROMPT Generating BDE_INDEXES spool file...
SET term off;

SPOOL bde_last_analyzed_indexes.txt;
SELECT *
  FROM bde_indexes
 ORDER BY
       owner,
       index_name;
SPOOL OFF;


SET term on;
PROMPT Generating BDE_TAB_PARTITIONS spool file...
SET term off;

SPOOL bde_last_analyzed_tab_partitions.txt;
SELECT *
  FROM bde_tab_partitions
 ORDER BY
       table_owner,
       table_name,
       partition_name;
SPOOL OFF;


SET term on;
PROMPT Generating BDE_IND_PARTITIONS spool file...
SET term off;

SPOOL bde_last_analyzed_ind_partitions.txt;
SELECT *
  FROM bde_ind_partitions
 ORDER BY
       index_owner,
       index_name,
       partition_name;
SPOOL OFF;


SET term on;
PROMPT Generating BDE_SUMMARY spool file...
SET term off;

SPOOL bde_last_analyzed_summary.txt;
SET term off feed off pages 30000 lin 1000 trims on serveroutput on size 10000;

COLUMN DUMMY NOPRINT;
COLUMN TODAY FORMAT A22 HEADING 'bde_last_analyzed.sql';
COLUMN LAST_ANALYZED FORMAT A10 HEADING 'Last|Analyzed';
COLUMN AGE FORMAT 999999 HEADING 'Age(*)|in days';
COLUMN TABLES FORMAT 999,999 HEADING 'Num of|Tables';
COLUMN APPS FORMAT A6 HEADING 'Oracle|Apps';
COLUMN INDEXES FORMAT 999,999 HEADING 'Num of|Indexes';
COLUMN MODULES FORMAT 999,999 HEADING 'Num of|Modules';
COLUMN OWNER FORMAT A30 HEADING 'Module';
COLUMN MESSAGE FORMAT A30 HEADING 'Message';
COLUMN TABLE_NAME FORMAT A40 HEADING 'Table Name';
COLUMN INDEX_NAME FORMAT A40 HEADING 'Index Name';
COLUMN GLOBAL_LA FORMAT A10 HEADING 'Global|CBO stats';
COLUMN PART_LA FORMAT A10 HEADING 'Partition|CBO stats';
COLUMN DAYS_T FORMAT 9999999999 -
       HEADING 'CBO stats|average age|in days|(Tables)';
COLUMN DAYS_I FORMAT 9999999999 -
       HEADING 'CBO stats|average age|in days|(Indexes)';
COLUMN PARTITIONING_TYPE FORMAT A15 HEADING 'Partitioning|Type';
COLUMN SUBPARTITIONING_TYPE FORMAT A15 HEADING 'Subpartitioning|Type';
COLUMN PARTITION_COUNT FORMAT 999999999 HEADING 'Partition|Count';


SELECT TO_CHAR(SYSDATE,'YYYY-MM-DD HH24:MI') TODAY FROM DUAL;

PROMPT
PROMPT CBO stats age
PROMPT =============
PROMPT

SELECT DAYS_T,
       DAYS_I
  FROM ( SELECT ROUND(AVG(SYSDATE-LAST_ANALYZED)) DAYS_T
         FROM BDE_TABLES )  T,
       ( SELECT ROUND(AVG(SYSDATE-LAST_ANALYZED)) DAYS_I
         FROM BDE_INDEXES ) I;

CLEAR BREAKS COMPUTE;
BREAK ON DUMMY;
COMPUTE SUM OF TABLES ON DUMMY;
SELECT NULL DUMMY,
       LAST_ANALYZED,
       SUM(TABLES) TABLES
  FROM BDE_TABLES_SUMMARY
 GROUP BY
       LAST_ANALYZED;

CLEAR BREAKS COMPUTE;
BREAK ON DUMMY;
COMPUTE SUM OF INDEXES ON DUMMY;
SELECT NULL DUMMY,
       LAST_ANALYZED,
       SUM(INDEXES) INDEXES
  FROM BDE_INDEXES_SUMMARY
 GROUP BY
       LAST_ANALYZED;

CLEAR BREAKS COMPUTE;
SELECT SM.OWNER,
       DECODE(BS.OWNER,NULL,'NO','YES') APPS,
       SUM(SM.DAYS_T) DAYS_T,
       SUM(SM.DAYS_I) DAYS_I
  FROM (
SELECT OWNER,
       NVL(ROUND(AVG(SYSDATE-LAST_ANALYZED)),999999) DAYS_T,
       0                                             DAYS_I
  FROM BDE_TABLES
 GROUP BY
       OWNER
 UNION ALL
SELECT OWNER,
       0                                             DAYS_T,
       NVL(ROUND(AVG(SYSDATE-LAST_ANALYZED)),999999) DAYS_I
  FROM BDE_INDEXES
 GROUP BY
       OWNER
       ) SM,
       BDE_SCHEMAS BS
 WHERE SM.OWNER = BS.OWNER(+)
 GROUP BY
       SM.OWNER,
       DECODE(BS.OWNER,NULL,'NO','YES');


PROMPT
PROMPT
PROMPT Data dictionary objects with CBO stats
PROMPT ======================================

SELECT COUNT(*) TABLES,
       DECODE(COUNT(*),0,'OK','*** ERROR ***') MESSAGE
  FROM BDE_TABLES
 WHERE OWNER = 'SYS'
   AND LAST_ANALYZED IS NOT NULL
   AND TABLE_NAME <> 'DUAL';

SELECT COUNT(*) INDEXES,
       DECODE(COUNT(*),0,'OK','*** ERROR ***') MESSAGE
  FROM BDE_INDEXES
 WHERE OWNER = 'SYS'
   AND LAST_ANALYZED IS NOT NULL;

SELECT DECODE(LAST_ANALYZED,NULL,'*** ERROR ***','OK') "SYS.DUAL"
  FROM BDE_TABLES
 WHERE OWNER = 'SYS'
   AND TABLE_NAME = 'DUAL';


PROMPT
PROMPT
PROMPT Partitioned objects
PROMPT ===================

SELECT OWNER||'.'||TABLE_NAME TABLE_NAME,
       PARTITIONING_TYPE,
       SUBPARTITIONING_TYPE,
       PARTITION_COUNT
  FROM ALL_PART_TABLES
 ORDER BY
       OWNER||'.'||TABLE_NAME;

SELECT OWNER||'.'||INDEX_NAME INDEX_NAME,
       PARTITIONING_TYPE,
       SUBPARTITIONING_TYPE,
       PARTITION_COUNT
  FROM ALL_PART_INDEXES
 ORDER BY
       OWNER||'.'||INDEX_NAME;


PROMPT
PROMPT
PROMPT Partitioned objects with Global CBO stats out of sync
PROMPT =====================================================
PROMPT

SELECT RPAD(BT.OWNER||'.'||BT.TABLE_NAME,40,'.') TABLE_NAME,
       TRUNC(BT.LAST_ANALYZED) GLOBAL_LA,
       BTP.LAST_ANALYZED PART_LA,
       '*** DELETE GLOBAL STATS ***' MESSAGE
  FROM BDE_TABLES BT,
       ( SELECT TABLE_OWNER OWNER,
                TABLE_NAME,
                TRUNC(MAX(LAST_ANALYZED)) LAST_ANALYZED
           FROM BDE_TAB_PARTITIONS
          GROUP BY
                TABLE_OWNER,
                TABLE_NAME ) BTP
 WHERE BT.PARTITIONED           = 'YES'
   AND BT.GLOBAL_STATS          = 'YES'
   AND BT.OWNER                 = BTP.OWNER
   AND BT.TABLE_NAME            = BTP.TABLE_NAME
   AND TRUNC(BT.LAST_ANALYZED) <> BTP.LAST_ANALYZED
 ORDER BY
       BT.OWNER||'.'||BT.TABLE_NAME;

SELECT RPAD(BI.OWNER||'.'||BI.INDEX_NAME,40,'.') INDEX_NAME,
       TRUNC(BI.LAST_ANALYZED) GLOBAL_LA,
       BIP.LAST_ANALYZED PART_LA,
       '*** DELETE GLOBAL STATS ***' MESSAGE
  FROM BDE_INDEXES BI,
       ( SELECT INDEX_OWNER OWNER,
                INDEX_NAME,
                TRUNC(MAX(LAST_ANALYZED)) LAST_ANALYZED
           FROM BDE_IND_PARTITIONS
          GROUP BY
                INDEX_OWNER,
                INDEX_NAME ) BIP
 WHERE BI.PARTITIONED           = 'YES'
   AND BI.GLOBAL_STATS          = 'YES'
   AND BI.OWNER                 = BIP.OWNER
   AND BI.INDEX_NAME            = BIP.INDEX_NAME
   AND TRUNC(BI.LAST_ANALYZED) <> BIP.LAST_ANALYZED
 ORDER BY
       BI.OWNER||'.'||BI.INDEX_NAME;


PROMPT
PROMPT
PROMPT Last Analyzed per Module - Tables
PROMPT =================================

CLEAR BREAKS COMPUTE;
BREAK ON DUMMY ON OWNER SKIP 1 ON APPS;
COMPUTE SUM OF TABLES ON DUMMY;
SELECT NULL DUMMY,
       RPAD(BTS.OWNER,30,'.') OWNER,
       DECODE(BS.OWNER,NULL,'NO','YES') APPS,
       BTS.LAST_ANALYZED,
       BTS.AGE,
       BTS.TABLES
  FROM BDE_TABLES_SUMMARY BTS,
       BDE_SCHEMAS        BS
 WHERE BTS.OWNER = BS.OWNER(+)
 ORDER BY
       BTS.OWNER,
       BTS.LAST_ANALYZED;


PROMPT
PROMPT
PROMPT Last Analyzed per Module - Indexes
PROMPT ==================================

CLEAR BREAKS COMPUTE;
BREAK ON DUMMY ON OWNER SKIP 1 ON APPS;
COMPUTE SUM OF INDEXES ON DUMMY;
SELECT NULL DUMMY,
       RPAD(BTS.OWNER,30,'.') OWNER,
       DECODE(BS.OWNER,NULL,'NO','YES') APPS,
       BTS.LAST_ANALYZED,
       BTS.AGE,
       BTS.INDEXES
  FROM BDE_INDEXES_SUMMARY BTS,
       BDE_SCHEMAS         BS
 WHERE BTS.OWNER = BS.OWNER(+)
 ORDER BY
       BTS.OWNER,
       BTS.LAST_ANALYZED;


PROMPT
PROMPT
PROMPT Last Analyzed per Date - Tables
PROMPT ===============================

CLEAR BREAKS COMPUTE;
BREAK ON LAST_ANALYZED SKIP 1 ON AGE;
SELECT BTS.LAST_ANALYZED,
       BTS.AGE,
       RPAD(BTS.OWNER,30,'.') OWNER,
       DECODE(BS.OWNER,NULL,'NO','YES') APPS,
       BTS.TABLES
  FROM BDE_TABLES_SUMMARY BTS,
       BDE_SCHEMAS        BS
 WHERE BTS.OWNER = BS.OWNER(+)
 ORDER BY
       BTS.LAST_ANALYZED,
       BTS.OWNER;


PROMPT
PROMPT
PROMPT Last Analyzed per Date - Indexes
PROMPT ================================

CLEAR BREAKS COMPUTE;
BREAK ON LAST_ANALYZED SKIP 1 ON AGE;
SELECT BTS.LAST_ANALYZED,
       BTS.AGE,
       RPAD(BTS.OWNER,30,'.') OWNER,
       DECODE(BS.OWNER,NULL,'NO','YES') APPS,
       BTS.INDEXES
  FROM BDE_INDEXES_SUMMARY BTS,
       BDE_SCHEMAS         BS
 WHERE BTS.OWNER = BS.OWNER(+)
 ORDER BY
       BTS.LAST_ANALYZED,
       BTS.OWNER;


PROMPT
PROMPT
PROMPT COUNT(*) on relevant TABLE attributes
PROMPT =====================================

SELECT RPAD(DECODE(NVL(CHAIN_CNT,0),0,'NO','YES'),12) CHAINED_ROWS,
       COUNT(*),
       DECODE(NVL(CHAIN_CNT,0),0,'OK') MESSAGE
  FROM BDE_TABLES
 GROUP BY
       DECODE(NVL(CHAIN_CNT,0),0,'NO','YES'),
       DECODE(NVL(CHAIN_CNT,0),0,'OK');

SELECT RPAD(LOGGING,7) LOGGING,
       COUNT(*),
       DECODE(LOGGING,'YES','OK') MESSAGE
  FROM BDE_TABLES
 GROUP BY
       LOGGING,
       DECODE(LOGGING,'YES','OK');

SELECT DEGREE,
       COUNT(*),
       DECODE(DEGREE,1,'OK') MESSAGE
  FROM BDE_TABLES
 GROUP BY
       DEGREE,
       DECODE(DEGREE,1,'OK');

SELECT CACHE,
       COUNT(*),
       DECODE(SUBSTR(CACHE,5,1),'N','OK') MESSAGE
  FROM BDE_TABLES
 GROUP BY
       CACHE,
       DECODE(SUBSTR(CACHE,5,1),'N','OK');

SELECT INI_TRANS,
       COUNT(*),
       DECODE(SIGN(5-INI_TRANS),1,'OK') MESSAGE
  FROM BDE_TABLES
 GROUP BY
       INI_TRANS,
       DECODE(SIGN(5-INI_TRANS),1,'OK');

SELECT FREELIST_GROUPS,
       FREELISTS,
       FREELIST_GROUPS*FREELISTS TOTAL_FREELISTS,
       COUNT(*),
       DECODE(SIGN(17-FREELIST_GROUPS*FREELISTS),1,'OK') MESSAGE
  FROM BDE_TABLES
 GROUP BY
       FREELIST_GROUPS,
       FREELISTS,
       DECODE(SIGN(17-FREELIST_GROUPS*FREELISTS),1,'OK');

SELECT RPAD(PARTITIONED,11) PARTITIONED,
       COUNT(*)
  FROM BDE_TABLES
 GROUP BY
       PARTITIONED;

SELECT IOT_TYPE,
       COUNT(*)
  FROM BDE_TABLES
 GROUP BY
       IOT_TYPE;


PROMPT
PROMPT
PROMPT COUNT(*) on relevant INDEX attributes
PROMPT =====================================

SELECT RPAD(LOGGING,7) LOGGING,
       COUNT(*),
       DECODE(LOGGING,'YES','OK') MESSAGE
  FROM BDE_INDEXES
 GROUP BY
       LOGGING,
       DECODE(LOGGING,'YES','OK');

SELECT DEGREE,
       COUNT(*),
       DECODE(DEGREE,'1','OK') MESSAGE
  FROM BDE_INDEXES
 GROUP BY
       DEGREE,
       DECODE(DEGREE,'1','OK');

SELECT INDEX_TYPE,
       COUNT(*),
       DECODE(INDEX_TYPE,'NORMAL','OK') MESSAGE
  FROM BDE_INDEXES
 GROUP BY
       INDEX_TYPE,
       DECODE(INDEX_TYPE,'NORMAL','OK');

SELECT INI_TRANS,
       COUNT(*),
       DECODE(SIGN(9-INI_TRANS),1,'OK') MESSAGE
  FROM BDE_INDEXES
 GROUP BY
       INI_TRANS,
       DECODE(SIGN(9-INI_TRANS),1,'OK');

SELECT FREELIST_GROUPS,
       FREELISTS,
       FREELIST_GROUPS*FREELISTS TOTAL_FREELISTS,
       COUNT(*),
       DECODE(SIGN(17-FREELIST_GROUPS*FREELISTS),1,'OK') MESSAGE
  FROM BDE_INDEXES
 GROUP BY
       FREELIST_GROUPS,
       FREELISTS,
       DECODE(SIGN(17-FREELIST_GROUPS*FREELISTS),1,'OK');

SELECT PCT_FREE,
       COUNT(*),
       DECODE(PCT_FREE,0,'OK') MESSAGE
  FROM BDE_INDEXES
 GROUP BY
       PCT_FREE,
       DECODE(PCT_FREE,0,'OK');

SELECT RPAD(PARTITIONED,11) PARTITIONED,
       COUNT(*)
  FROM BDE_INDEXES
 GROUP BY
       PARTITIONED;


PROMPT
PROMPT
PROMPT COUNT(*) on relevant TAB_PARTITION attributes
PROMPT =============================================

SELECT RPAD(DECODE(NVL(CHAIN_CNT,0),0,'NO','YES'),12) CHAINED_ROWS,
       COUNT(*),
       DECODE(NVL(CHAIN_CNT,0),0,'OK') MESSAGE
  FROM BDE_TAB_PARTITIONS
 GROUP BY
       DECODE(NVL(CHAIN_CNT,0),0,'NO','YES'),
       DECODE(NVL(CHAIN_CNT,0),0,'OK');

SELECT RPAD(LOGGING,7) LOGGING,
       COUNT(*),
       DECODE(LOGGING,'YES','OK') MESSAGE
  FROM BDE_TAB_PARTITIONS
 GROUP BY
       LOGGING,
       DECODE(LOGGING,'YES','OK');

SELECT INI_TRANS,
       COUNT(*),
       DECODE(SIGN(5-INI_TRANS),1,'OK') MESSAGE
  FROM BDE_TAB_PARTITIONS
 GROUP BY
       INI_TRANS,
       DECODE(SIGN(5-INI_TRANS),1,'OK');

SELECT FREELIST_GROUPS,
       FREELISTS,
       FREELIST_GROUPS*FREELISTS TOTAL_FREELISTS,
       COUNT(*),
       DECODE(SIGN(17-FREELIST_GROUPS*FREELISTS),1,'OK') MESSAGE
  FROM BDE_TAB_PARTITIONS
 GROUP BY
       FREELIST_GROUPS,
       FREELISTS,
       DECODE(SIGN(17-FREELIST_GROUPS*FREELISTS),1,'OK');

SELECT SUBPARTITION_COUNT,
       COUNT(*)
  FROM BDE_TAB_PARTITIONS
 GROUP BY
       SUBPARTITION_COUNT;


PROMPT
PROMPT
PROMPT COUNT(*) on relevant IND_PARTITION attributes
PROMPT =============================================

SELECT RPAD(LOGGING,7) LOGGING,
       COUNT(*),
       DECODE(LOGGING,'YES','OK') MESSAGE
  FROM BDE_IND_PARTITIONS
 GROUP BY
       LOGGING,
       DECODE(LOGGING,'YES','OK');

SELECT INI_TRANS,
       COUNT(*),
       DECODE(SIGN(9-INI_TRANS),1,'OK') MESSAGE
  FROM BDE_IND_PARTITIONS
 GROUP BY
       INI_TRANS,
       DECODE(SIGN(9-INI_TRANS),1,'OK');

SELECT FREELIST_GROUPS,
       FREELISTS,
       FREELIST_GROUPS*FREELISTS TOTAL_FREELISTS,
       COUNT(*),
       DECODE(SIGN(17-FREELIST_GROUPS*FREELISTS),1,'OK') MESSAGE
  FROM BDE_IND_PARTITIONS
 GROUP BY
       FREELIST_GROUPS,
       FREELISTS,
       DECODE(SIGN(17-FREELIST_GROUPS*FREELISTS),1,'OK');

SELECT SUBPARTITION_COUNT,
       COUNT(*)
  FROM BDE_IND_PARTITIONS
 GROUP BY
       SUBPARTITION_COUNT;

SET term on;

PROMPT
PROMPT
PROMPT All bde_last_analyzed.txt spool files have been generated.
PROMPT
PROMPT Recover and compress bde_last_analyzed.txt spool files into one zip file.
PROMPT
PROMPT Upload or send compressed (zip) file for further analysis.
PROMPT

SPOOL OFF;
SET feed on pages 24 lin 80 trims off serveroutput off;
