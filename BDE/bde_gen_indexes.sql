/*$Header: bde_gen_indexes.sql 8.0-9.0 174607.1 2002/09/03      csierra bde $*/
SET term off ver off trims on serveroutput on size 1000000 feed off;
/*=============================================================================

bde_gen_indexes.sql - Drop and Create non-partitioned B*Tree Indexes (8.0-9.0)

    *************************************************************
    This article is being delivered in Draft form and may contain
    errors.  Please use the MetaLink "Feedback" button to advise
    Oracle of any issues related to this article.
    *************************************************************


 Overview
 --------

    bde_gen_indexes.sql drops and recreates non-partitioned B*Tree indexes for
    all schemas, or one schema, or one table, or just for one index.

    During some circumstances, Oracle Apps Development request to drop and
    recreate one or several indexes.  This script helps to automate the process
    of index droping and recreation, using the same attributes and storage
    parameters than the original index or indexes.

    When executed, the bde_gen_indexes.sql creates dynamically another script
    named BDE_DROP_AND_CREATE_INDEXES.SQL with all necessary commands to drop
    and recreate all indexes selected according to execution parameters:

    schema owner(opt), table name(opt), and index suffix(opt).


 Instructions
 ------------

 1. Copy this whole Note into a text file.  Name it bde_gen_indexes.sql when
    saving your text file.  Be sure filename is bde_gen_indexes.sql.

 2. Execute bde_gen_indexes.sql from SQL*Plus connected as user with access to
    all tables for which you want to recreate the indexes.

    If you are using bde_gen_indexes.sql within an Apps 11i instance, connect
    as APPS, otherwise use SYSTEM:

      # sqlplus apps/apps@vis11i

      SQL> START bde_gen_indexes.sql;

 3. When prompted, enter schama name, table name and index suffix.

 4. Review and edit output file (spool): BDE_DROP_AND_CREATE_INDEXES.SQL.
    The spool file gets created on same directory from which
    bde_gen_indexes.sql is executed.  On NT, files may get created under
    $ORACLE_HOME/bin.


 Program Notes
 -------------

 1. Always download latest version from Metalink (Note:174607.1), or ftp from

    ftp://oracle-ftp.oracle.com/apps/patchsets/AOL/SCRIPTS/PERFORMANCE/

    In order to avoid cut and paste or word wraping issues, use better ftp

 2. If you need to ftp the spool file accross servers, use ASCII.

 3. Dynamically generated script BDE_DROP_AND_CREATE_INDEXES.SQL, should be
    executed only if requested by Oracle Support.

 4. For other SQL Tuning scripts, search on Metalink using keyword coescripts.

 5. A practical guide in Troubleshooting Oracle ERP Applications Performance
    Issues can be found on Metalink under Note:169935.1


 Parameters
 ----------

    Execution parameters work with AND conditions.  To select an index, it
    should match all parameters.

 1. Owner of Table(s) (Schema) <opt>:

        Schema name, or all schemas (if hit enter with no value).
        All non-partitioned B*Tree indexes belonging to selected schema
        (or all schemas if none is entered) will be selected for recreation.

 2. Table Name <opt>:

        All non-partitioned B*Tree indexes belonging to selected table will be
        selected for recreation.

 3. Index Name or Index Suffix <opt>:

        All non-partitioned B*Tree indexes which name contains the value
        entered (usually a suffix like U1), will be selected for recreation.

        These indexes, besides matching the 'Index Name or Index Suffix', must
        also match the other two parameters in order to be selected for
        recreation.


 Caution
 -------

    The sample program in this article is provided for educational purposes
    only and is NOT supported by Oracle Support Services.  It has been tested
    internally, however, and works as documented.  We do not guarantee that it
    will work for you, so be sure to test it in your environment before
    relying on it.


 Portal
 ------

    Abstract: bde_gen_indexes.sql - Drop and Create Indexes (8.0-9.0)
    Author: Carlos Sierra
    Date: 03-SEP-02
    Description: Drop and Create non-partitioned B*Tree Indexes (8.0-9.0)
    EMail: carlos.sierra@oracle.com
    Internal_Only: N
    Keywords: sqltuning coescripts appsperf appssqltuning coe bde
    Metalink_Note: 174607.1
    New_Win: Y
    Product: SQL*Plus script
    Version: 8.0-9.0 2002/09/03
    Download: bde_gen_indexes.zip

   ========================================================================= */

SET ver off trims on serveroutput on size 1000000 feed off;
SET term on pages 0 lin 255;
ACCEPT schema     PROMPT 'Enter Owner of Table(s) (Schema) <opt>: ';
ACCEPT table_name PROMPT 'Enter Table Name................ <opt>: ';
ACCEPT index_name PROMPT 'Enter Index Name or Index Suffix <opt>: ';

SPOOL bde_drop_and_create_indexes.sql;
DECLARE
    sql0 VARCHAR2(1000);
    col1 all_ind_columns.column_name%TYPE;
    dbversion v$instance.version%TYPE;
    irec all_indexes%ROWTYPE;
    CURSOR C_index IS
        SELECT ai.*
          FROM all_indexes     ai
         WHERE ai.table_owner LIKE RTRIM(UPPER('&&schema'))||'%'
           AND ai.table_name  LIKE RTRIM(UPPER('&&table_name'))||'%'
           AND ai.index_name  LIKE '%'||RTRIM(UPPER('&&index_name'))||'%'
           AND ai.index_type  =  'NORMAL'
           AND ai.partitioned =  'NO'
           AND ai.table_owner <> 'SYS'
           AND ai.owner       <> 'SYS'
           AND ai.table_owner <> 'SYSTEM'
           AND ai.owner       <> 'SYSTEM';
    CURSOR C_columns IS
        SELECT aic.column_name
          FROM all_ind_columns aic
         WHERE aic.index_owner     = irec.owner
           AND aic.index_name      = irec.index_name
           AND aic.column_position > 1
         ORDER BY aic.column_position;
BEGIN
    SELECT version INTO dbversion FROM v$instance;
    sql0:='/*$Header: bde_drop_and_create_indexes.sql (8.0-9.0) ';
    sql0:=sql0||TO_CHAR(sysdate,'YYYY/MM/DD');
    sql0:=sql0||'   gen by bde_gen_indexes.sql   csierra bde $*/';
    DBMS_OUTPUT.PUT_LINE(sql0);
    sql0:='/* Note: Do not execute, unless requested by Oracle Support.  ';
    sql0:=sql0||'Review and edit accordingly before execution. */';
    DBMS_OUTPUT.PUT_LINE(sql0);
    sql0:='SET echo on;';
    DBMS_OUTPUT.PUT_LINE(sql0);
    sql0:='SPOOL bde_drop_and_create_indexes.txt;';
    DBMS_OUTPUT.PUT_LINE(sql0);
    OPEN C_index;
    LOOP
        FETCH C_index INTO irec;
        EXIT WHEN C_index%NOTFOUND;
        sql0:='/**/';
        DBMS_OUTPUT.PUT_LINE(sql0);
        sql0:=RPAD('/**/ DROP',19)||'INDEX '||irec.owner||'.';
        sql0:=sql0||irec.index_name||';';
        DBMS_OUTPUT.PUT_LINE(sql0);
        sql0:='/**/ CREATE ';
        IF irec.uniqueness = 'UNIQUE' THEN
           sql0:=sql0||'UNIQUE ';
        ELSE
           sql0:=sql0||'       ';
        END IF;
        sql0:=sql0||'INDEX '||irec.owner||'.'||irec.index_name;
        sql0:=sql0||' ON '||irec.table_owner||'.'||irec.table_name;
        DBMS_OUTPUT.PUT_LINE(sql0);
        SELECT aic.column_name
          INTO col1
          FROM all_ind_columns aic
         WHERE aic.index_owner     = irec.owner
           AND aic.index_name      = irec.index_name
           AND aic.column_position = 1;
        sql0:=RPAD('/**/',25)||'( '||col1;
        DBMS_OUTPUT.PUT_LINE(sql0);
        OPEN C_columns;
        LOOP
            FETCH C_columns INTO col1;
            EXIT WHEN C_columns%NOTFOUND;
            sql0:=RPAD('/**/',25)||', '||col1;
            DBMS_OUTPUT.PUT_LINE(sql0);
        END LOOP;
        CLOSE C_columns;
        sql0:=RPAD('/**/',25)||')';
        DBMS_OUTPUT.PUT_LINE(sql0);
        sql0:=RPAD('/**/',25)||'PCTFREE '||irec.pct_free||' ';
        sql0:=sql0||'INITRANS '||irec.ini_trans||' ';
        sql0:=sql0||'MAXTRANS '||irec.max_trans;
        DBMS_OUTPUT.PUT_LINE(sql0);
        sql0:=RPAD('/**/',25)||'STORAGE ( ';
        sql0:=sql0||'INITIAL '||irec.initial_extent||' ';
        sql0:=sql0||'NEXT '||irec.next_extent||' ';
        sql0:=sql0||'MINEXTENTS '||irec.min_extents||' ';
        sql0:=sql0||'MAXEXTENTS '||irec.max_extents;
        DBMS_OUTPUT.PUT_LINE(sql0);
        sql0:=RPAD('/**/',35)||'PCTINCREASE '||irec.pct_increase||' ';
        sql0:=sql0||'FREELISTS '||irec.freelists||' ';
        sql0:=sql0||'FREELIST GROUPS '||irec.freelist_groups||' ';
        sql0:=sql0||')';
        DBMS_OUTPUT.PUT_LINE(sql0);
        sql0:=RPAD('/**/',25);
        sql0:=sql0||'NOLOGGING ';
        IF dbversion > '8.1' THEN
           sql0:=sql0||'COMPUTE STATISTICS ';
        END IF;
        sql0:=sql0||'TABLESPACE '||irec.tablespace_name||' ';
        sql0:=sql0||';';
        DBMS_OUTPUT.PUT_LINE(sql0);
        sql0:=RPAD('/**/ ALTER',19)||'INDEX '||irec.owner||'.';
        sql0:=sql0||irec.index_name||' LOGGING;';
        DBMS_OUTPUT.PUT_LINE(sql0);
    END LOOP;
    CLOSE C_index;
    sql0:='SPOOL off;';
    DBMS_OUTPUT.PUT_LINE(sql0);
    sql0:='SET echo off;';
    DBMS_OUTPUT.PUT_LINE(sql0);
END;
/
SPOOL off;
SET pages 24 lin 80 ver on trims off serveroutput off feed on;