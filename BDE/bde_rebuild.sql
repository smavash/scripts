/*$Header: bde_rebuild.sql 8.0-9.0 182699.1 2002/09/03          csierra bde $*/
SET term off ver off trims on serveroutput on size 1000000 feed off;
/*=============================================================================

bde_rebuild.sql - Validates and Rebuilds Fragmentated Indexes (8.0-9.0)

    *************************************************************
    This article is being delivered in Draft form and may contain
    errors.  Please use the MetaLink "Feedback" button to advise
    Oracle of any issues related to this article.
    *************************************************************


 Overview
 --------

    bde_rebuild.sql selects indexes according to execution parameters of
    schema_owner, table_name and index_name (all 3 optional).
    It validates if selected indexes according to execution parameters are
    fragmentated.

    Once fragmenetated indexes are determined, it proceeds to generate a
    dynamic script to rebuild them.

    The execution of the dynamically generated script to rebuild the
    fragmentated indexes is commented out "--" near the end of this script.
    You can either remove the comment characters "--" and let the execution
    of the index rebuild script proceed automatically, or you can execute
    manually after your revision.

    Index fragmentation occurs when a key value changes, and the index row is
    deleted from one place (Leaf Block) and inserted into another.
    Deleted Leaf Rows are not reused.  Therefore, indexes whose columns are
    subject to value change must be rebuilt periodically, since they become
    naturally fragmentated.

    An index is considered to be 'fragmentated' when more than 20% of its
    Leaf Rows space is empty because of the implicit deletes caused by indexed
    columns value changes.

    Fragmentated indexes degrade the performance of index range scan
    operations.

     WARNING: This script blocks DML commands on indexes beign analyzed,
              including SELECT statements.
              Execute in Production during a low online user activity period.
              Blocking time lasts between a few secs to a few minutes,
              depending on index size.



 Instructions
 ------------

 1. Copy this whole Note into a text file.  Name it bde_rebuild.sql when
    saving your text file.

 2. Decide if you want to enable the automatic execution of the dynamically
    generated script to rebuild fragmentated indexes.  If you do, remove the
    "--" from the corresponding command near the end of this script.

 3. Execute bde_rebuild.sql from SQL*Plus connected as user with access
    to all indexes, with ANALYZE and ALTER permission on them.
    If you are using bde_rebuild.sql within an Apps 11i instance, connect
    as APPS, otherwise use SYSTEM:

      # sqlplus apps/apps@vis11i
      SQL> START bde_rebuild.sql;

 4. Review output files (spool):

      BDE_REBUILD_REPORT.TXT    - Stats Report
      BDE_VALIDATE_STRCTURE.TXT - Log
      BDE_REBUILD_INDEXES.TXT   - Log  (if it was enabled as per 2 above)

    The spool files get created on same directory from which the script is
    executed.

    On NT, files may get created under $ORACLE_HOME/bin.

 5. Provide to Support generated spool files, if requested.

 6. The dynamically generated bde_rebuild_indexes.sql script rebuilds all
    selected indexes with wasted space caused by deleted leaf rows > 20%


 Program Notes
 -------------

 1. Always download latest version from Metalink (Note:182699.1), or ftp from

    ftp://oracle-ftp.oracle.com/apps/patchsets/AOL/SCRIPTS/PERFORMANCE/

    In order to avoid cut and paste or word wraping issues, use better ftp

 2. If you need to ftp spool files from UNIX to any other system, use ASCII.

 3. Open the spooled files using WordPad, change the font to Courier New, style
    regular and size 8.  Set up the page to Lanscape with all 4 margins 0.2 in.

 4. This script has been tested up to Oracle Apps 11.5.4 with Oracle 8.1.7.

 5. For other SQL Tuning scripts, search on Metalink using keyword coescripts.

 6. A practical guide in Troubleshooting Oracle ERP Applications Performance
    Issues can be found on Metalink under Note:169935.1

 7. This script uses the ANALYZE INDEX VALIDATE STRUCTURE command to generate
    the required statistics to determine index fragmentation on the selected
    indexes.

    WARNING: This script blocks DML commands on indexes beign analyzed,
             including SELECT statements.
             Execute in Production during a low online user activity period.
             Blocking time lasts between a few secs to a few minutes,
             depending on index size.


 Parameters
 ----------

    Execution parameters work with AND conditions.  To select an index for
    analysis and validation, it should match all parameters.

 1. Owner of Table(s) (Schema) <opt>:

        Schema name, or all schemas (if hit enter with no value).
        All indexes belonging to selected schema (or all schemas if none is
        entered) will be selected for fragmentation validation.

 2. Table Name <opt>:

        All indexes belonging to selected table will be selected for
        fragmentation validation.

 3. Index Name or Index Suffix <opt>:

        All indexes which name contains the value entered (usually a suffix
        like U1), will be selected for fragmentation validation.


    All selected indexes are validated and reported in the stats report.
    From the selected indexes according to execution parameters, only those
    with fragmentation > 20% are included into the bde_rebuild_indexes.sql
    dynamic script.


 Caution
 -------

    The sample program in this article is provided for educational purposes
    only and is NOT supported by Oracle Support Services.  It has been tested
    internally, however, and works as documented.  We do not guarantee that it
    will work for you, so be sure to test it in your environment before
    relying on it.


 Portal
 ------

    Abstract: bde_rebuild.sql - Validate/Rebuild Fragmentated Indexes (8.0-9.0)
    Author: Carlos Sierra
    Date: 03-SEP-02
    Description: Validates and Rebuilds Fragmentated Indexes (8.0-9.0)
    EMail: carlos.sierra@oracle.com
    Internal_Only: N
    Keywords: sqltuning coescripts appsperf appssqltuning coe bde fragmentation
    Metalink_Note: 182699.1
    New_Win: Y
    Product: SQL*Plus script
    Version: 8.0-9.0 2002/09/03
    Download: bde_rebuild.zip

   ========================================================================= */

SET term off ver off trims on serveroutput on size 1000000 feed off;

DROP   TABLE bde_index_stats;
CREATE TABLE bde_index_stats
       AS SELECT * FROM index_stats WHERE 1=2;
ALTER  TABLE bde_index_stats
       ADD (index_owner VARCHAR2(30),index_name VARCHAR2(30),
            analyzed DATE,row_num NUMBER);

SET term on pages 0 lin 255;
ACCEPT schema     PROMPT 'Enter Owner of Table(s) (Schema) <opt>: ';
ACCEPT table_name PROMPT 'Enter Table Name................ <opt>: ';
ACCEPT index_name PROMPT 'Enter Index Name or Index Suffix <opt>: ';
PROMPT
PROMPT Generating bde_validate_structure&&schema&&table_name&&index_name..sql;
PROMPT
SET term off;

VARIABLE v_count NUMBER;

SPOOL bde_validate_structure&&schema&&table_name&&index_name..sql;
DECLARE
   v_sql        VARCHAR2(1000);
   v_dbversion  v$instance.version%TYPE;
   CURSOR c1 IS
      SELECT owner,
             index_name
        FROM all_indexes
       WHERE table_owner LIKE RTRIM(UPPER('&&schema'))||'%'
         AND table_name  LIKE RTRIM(UPPER('&&table_name'))||'%'
         AND index_name  LIKE '%'||RTRIM(UPPER('&&index_name'))||'%'
         AND table_owner <> 'SYS'
         AND owner       <> 'SYS'
         AND table_owner <> 'SYSTEM'
         AND owner       <> 'SYSTEM'
       ORDER BY
             owner,
             index_name;
BEGIN
   SELECT version INTO v_dbversion FROM v$instance;
   v_sql:='/*$Header: bde_validate_structure'||
          '&&schema&&table_name&&index_name..sql '||
          '(8.0-9.0) '||TO_CHAR(sysdate,'YYYY/MM/DD')||
          '   gen by bde_rebuild.sql   csierra bde $*/';
   DBMS_OUTPUT.PUT_LINE(v_sql);
   v_sql:='SET echo on feed on;';
   DBMS_OUTPUT.PUT_LINE(v_sql);
   v_sql:='SPOOL bde_validate_structure&&schema&&table_name&&index_name..txt;';
   DBMS_OUTPUT.PUT_LINE(v_sql);
   :v_count:=0;
   FOR c1_rec IN c1 LOOP
      :v_count:=:v_count+1;
      v_sql:='ANALYZE INDEX '||c1_rec.owner||'.'||c1_rec.index_name||
             ' VALIDATE STRUCTURE;';
      DBMS_OUTPUT.PUT_LINE(v_sql);
      v_sql:='INSERT INTO bde_index_stats '||
             'SELECT ixs.*, '''||c1_rec.owner||''', '''||c1_rec.index_name||''', '||
             'sysdate, '||:v_count||
              ' FROM index_stats ixs;';
      DBMS_OUTPUT.PUT_LINE(v_sql);
   END LOOP;
   v_sql:='COMMIT;';
   DBMS_OUTPUT.PUT_LINE(v_sql);
   v_sql:='SPOOL off;';
   DBMS_OUTPUT.PUT_LINE(v_sql);
   v_sql:='SET echo off feed off;';
   DBMS_OUTPUT.PUT_LINE(v_sql);
END;
/
SPOOL off;

SET term on;
PROMPT
EXEC DBMS_OUTPUT.PUT_LINE('Number of indexes selected: '||TO_CHAR(:v_count));
PROMPT
PROMPT Ready to execute generated script to validate selected indexes:
PROMPT bde_validate_structure&&schema&&table_name&&index_name..sql;
PROMPT
PROMPT *** WARNING ***
PROMPT This script blocks DML commands on indexes beign analyzed, including
PROMPT SELECT statements.
PROMPT Execute in Production during a low online user activity period.
PROMPT Blocking time lasts between a few secs to a few minutes, depending on
PROMPT index size.
PROMPT
PAUSE Click <Enter> to continue, or <Ctrl-c> to cancel
PROMPT
PROMPT Executing bde_validate_structure&&schema&&table_name&&index_name..sql;
PROMPT
START bde_validate_structure&&schema&&table_name&&index_name..sql;
PROMPT
PROMPT
PROMPT Generating bde_rebuild_indexes&&schema&&table_name&&index_name..sql;
PROMPT
SET term off;

SPOOL bde_rebuild_indexes&&schema&&table_name&&index_name..sql;
DECLARE
   v_sql        VARCHAR2(1000);
   v_dbversion  v$instance.version%TYPE;
   CURSOR c1 IS
      SELECT index_owner,
             index_name
        FROM bde_index_stats
       WHERE SIGN(del_lf_rows_len/DECODE(lf_rows_len,0,1,lf_rows_len)-0.2)=1
       ORDER BY
             index_owner,
             index_name;
BEGIN
   SELECT version INTO v_dbversion FROM v$instance;
   v_sql:='/*$Header: bde_rebuild_indexes'||
          '&&schema&&table_name&&index_name..sql '||
          '(8.0-9.0) '||TO_CHAR(sysdate,'YYYY/MM/DD')||
          '   gen by bde_rebuild.sql   csierra bde $*/';
   DBMS_OUTPUT.PUT_LINE(v_sql);
   v_sql:='SET echo on feed on;';
   DBMS_OUTPUT.PUT_LINE(v_sql);
   v_sql:='SPOOL bde_rebuild_indexes&&schema&&table_name&&index_name..txt;';
   DBMS_OUTPUT.PUT_LINE(v_sql);
   :v_count:=0;
   FOR c1_rec IN c1 LOOP
      :v_count:=:v_count+1;
      v_sql:='ALTER INDEX '||c1_rec.index_owner||'.'||c1_rec.index_name||
             ' REBUILD ';
      IF v_dbversion > '8.1' THEN
         v_sql:=v_sql||'ONLINE ';
      END IF;
      v_sql:=v_sql||'NOLOGGING;';
      DBMS_OUTPUT.PUT_LINE(v_sql);
      v_sql:='ALTER INDEX '||c1_rec.index_owner||'.'||c1_rec.index_name||
             ' LOGGING;';
      DBMS_OUTPUT.PUT_LINE(v_sql);
      v_sql:='ANALYZE INDEX '||c1_rec.index_owner||'.'||c1_rec.index_name||
             ' COMPUTE STATISTICS;';
      DBMS_OUTPUT.PUT_LINE(v_sql);
   END LOOP;
   v_sql:='SPOOL off;';
   DBMS_OUTPUT.PUT_LINE(v_sql);
   v_sql:='SET echo off;';
   DBMS_OUTPUT.PUT_LINE(v_sql);
END;
/
SPOOL off;

SET term on;
PROMPT
PROMPT Generating bde_rebuild_report&&schema&&table_name&&index_name..txt
PROMPT
SET term off numf 999,999,999,999,999 pages 10000 lin 500;

CLEAR COLUMNS BREAKS COMPUTES;
COLUMN NAME                   FORMAT A60 HEADING -
    'Segment Name|[OWNER.INDEX_NAME.PARTITION_NAME]';
COLUMN NAME2                  FORMAT A60 HEADING -
    'Segment Name|[OWNER.INDEX_NAME]';
COLUMN HEIGHT                 HEADING -
    'Index Depth|[HEIGHT]';
COLUMN BLOCKS                 HEADING -
    'Segment Size|[BLOCKS]';
COLUMN NUM_ROWS               HEADING -
    'Num of Rows|[LF_ROWS]';
COLUMN LF_ROWS                HEADING -
    'Num of Leaf Rows|[LF_ROWS]';
COLUMN LF_BLKS                HEADING -
    'Num of Leaf Blocks|[LF_BLKS]';
COLUMN LF_ROWS_LEN            HEADING -
    'Sum of lengths|of all Leaf Rows|[LF_ROWS_LEN]';
COLUMN LF_BLK_LEN             HEADING -
    'Average length of|a Leaf Block|[LF_BLK_LEN]';
COLUMN BR_ROWS                HEADING -
    'Num of|Branch Rows|[BR_ROWS]';
COLUMN BR_BLKS                HEADING -
    'Num of|Branch Blocks|[BR_BLKS]';
COLUMN BR_ROWS_LEN            HEADING -
    'Sum of lengths|of all|Branch Rows|[BR_ROWS_LEN]';
COLUMN BR_BLK_LEN             HEADING -
    'Average length of|a Branch Block|[BR_BLK_LEN]';
COLUMN DEL_LF_ROWS            HEADING -
    'Num of Deleted|Leaf Rows|[DEL_LF_ROWS]';
COLUMN DEL_LF_ROWS_LEN        HEADING -
    'Sum of lengths|of all|Deleted Leaf Rows|[DEL_LF_ROWS_LEN]';
COLUMN DISTINCT_KEYS          HEADING -
    'Num of|[DISTINCT_KEYS]';
COLUMN MOST_REPEATED_KEY      HEADING -
    'Times Most|Repeated Key|is Repeated|[MOST_REPEATED_KEY]';
COLUMN BTREE_SPACE            HEADING -
    'Allocated and|Usable Space|[BTREE_SPACE]';
COLUMN USED_SPACE             HEADING -
    '[USED_SPACE]';
COLUMN PCT_USED               HEADING -
    'Percent of|Allocated Space|being used|[PCT_USED]';
COLUMN ROWS_PER_KEY           HEADING -
    'Average Num of Rows|per Distinct Key|[ROWS_PER_KEY]';
COLUMN BLKS_GETS_PER_ACCESS   HEADING -
  'Logical Reads|Expected to access|one Distinct Key|[BLKS_GETS_| PER_ACCESS]';
COLUMN WASTED_SPACE           HEADING -
    'Percent of (*)|Wasted Space|caused by|Deleted Leaf Rows';
COLUMN ANALYZED               FORMAT A19 HEADING -
    'Analyzed|Validate|Structure';
COLUMN ROW_NUM                HEADING -
    'Row Number|during Analyze';

SPOOL bde_rebuild_report&&schema&&table_name&&index_name..txt;
SET term on;

PROMPT
PROMPT Fragmentated Indexes selected for Rebuild
PROMPT =========================================
PROMPT

SELECT RPAD(SUBSTR(index_owner||'.'||index_name||
       DECODE(partition_name,NULL,NULL,'.'||
              partition_name),1,60),60,'.') name,
       ROUND(del_lf_rows_len*100/DECODE(lf_rows_len,0,1,lf_rows_len))
           wasted_space
  FROM bde_index_stats
 WHERE SIGN(del_lf_rows_len/DECODE(lf_rows_len,0,1,lf_rows_len)-0.2)=1
ORDER BY 1;

SET term off;
PROMPT
PROMPT
PROMPT INDEX_STATS
PROMPT ===========
PROMPT

SELECT RPAD(SUBSTR(index_owner||'.'||index_name||
       DECODE(partition_name,NULL,NULL,'.'||
              partition_name),1,60),60,'.') name,
       height,
       blocks,
       lf_blks,
       br_blks,
       btree_space,
       used_space,
       pct_used
  FROM bde_index_stats
 ORDER BY 1;

SELECT RPAD(SUBSTR(index_owner||'.'||index_name||
       DECODE(partition_name,NULL,NULL,'.'||
              partition_name),1,60),60,'.') name,
       lf_rows num_rows,
       distinct_keys,
       rows_per_key,
       blks_gets_per_access,
       most_repeated_key
  FROM bde_index_stats
ORDER BY 1;

SELECT RPAD(SUBSTR(index_owner||'.'||index_name||
       DECODE(partition_name,NULL,NULL,'.'||
              partition_name),1,60),60,'.') name,
       lf_blks,
       lf_blk_len,
       lf_rows,
       lf_rows_len,
       del_lf_rows,
       del_lf_rows_len,
       ROUND(del_lf_rows_len*100/DECODE(lf_rows_len,0,1,lf_rows_len))
           wasted_space
  FROM bde_index_stats
ORDER BY 1;

PROMPT
PROMPT Note(*): Fragmentated Indexes with Wasted Space > 20% should be rebuilt
PROMPT

SELECT RPAD(SUBSTR(index_owner||'.'||index_name||
       DECODE(partition_name,NULL,NULL,'.'||
              partition_name),1,60),60,'.') name,
       br_blks,
       br_blk_len,
       br_rows,
       br_rows_len,
       TO_CHAR(analyzed,'DD-MON-YY HH24:MI:SS') analyzed,
       row_num
  FROM bde_index_stats
ORDER BY 1;

SPOOL OFF;

SET term on;
PROMPT
PROMPT Report and Log file have been generated
PROMPT
EXEC DBMS_OUTPUT.PUT_LINE('Fragmentated indexes: '||TO_CHAR(:v_count));
PROMPT
PROMPT Ready to execute generated script to rebuild fragmentated indexes:
PROMPT bde_rebuild_indexes&&schema&&table_name&&index_name..sql;
PROMPT
-- START bde_rebuild_indexes&&schema&&table_name&&index_name..sql;
CLEAR COLUMNS BREAKS COMPUTES;
SET pages 24 lin 80 ver on trims off feed on numf 9999999999 serveroutput off;