/*$Header: bde_x.sql 8.1-9.0 174603.1 2002/09/03                csierra bde $*/
SET pages 255 lin 255 term off ver off trims on feed off autotrace off;
/*=============================================================================

bde_x.sql - Simple Explain Plan for given SQL Statement (8.1-9.0)

    *************************************************************
    This article is being delivered in Draft form and may contain
    errors.  Please use the MetaLink "Feedback" button to advise
    Oracle of any issues related to this article.
    *************************************************************


 Overview
 --------

    bde_x.sql generates a Simple Explain Plan for one SQL statement, required
    to diagnose apps performance issues (transaction tuning).

    bde_x.sql can be used as a short alternative to more detailed script
    coe_xplain.sql.

    It includes list of indexes for tables accessed according to Explain Plan.


 Instructions
 ------------

 1. Copy this whole Note into a text file.  Name it bde_x.sql when saving your
    text file.  Be sure filename is bde_x.sql.

 2. Create a flat file with one SQL statement for which you want to generate
    its explain plan.  Name this text file sql.txt.  It should have one and
    only one SQL statement.  Your SQL statement should NOT have a semicolon at
    the end.  It should end with either a space, or a single blank line.
    The space at the end is because in some environments, the last character
    of the SQL statement in sql.txt gets truncated, so if you add a space ' '
    or a single blank line at the end, your SQL statement will be still
    complete.  Do not include more than one single blank line at the end.

 3. There is no need to remove any bind variable from your SQL statement.  Do
    not replace bind variables with literals either.

 4. Save your sql.txt file.  Name of text file is not hardcoded, therefore you
    can use sql1.txt, sql2.txt and so on.

 5. Place the bde_x.sql and your file sql.txt into same dedicated directory.
    Be aware that bde_x.sql will try to open sql.txt under same directory.

 6. Execute bde_x.sql from SQL*Plus connected as user with access to all
    objects referenced by SQL statement in sql.txt.

    If you are using bde_x.sql within an Apps instance, connect as APPS,
    otherwise connect as corresponding user with access to all objects
    referenced by SQL statement:

    # sqlplus apps/apps@vis11i
    SQL> START bde_x.sql sql.txt;

 7. Review output file (spool): BDE_X_SQL.TXT.

    The spool file gets created on same directory from which bde_x.sql is
    executed.  SQL.TXT suffix represents filename provided in parameter 1.

    On NT, files may get created under $ORACLE_HOME/bin.

 8. If you need to provide to Oracle Support an Explain Plan for your SQL
    statement, use coe_xplain.sql instead.


 Program Notes
 -------------

 1. Always download latest version from Metalink (Note:174603.1), or ftp from

    ftp://oracle-ftp.oracle.com/apps/patchsets/AOL/SCRIPTS/PERFORMANCE/

    In order to avoid cut and paste or word wraping issues, use better ftp

 2. The Explain Plan is spooled into file BDE_X_SQL.TXT.

    The original SQL statement is also spooled into BDE_X_SQL.TXT

    SQL.TXT suffix represents filename provided in parameter 1.

 3. If you need to ftp spool files from UNIX to any other server, use ASCII.

 4. Open the spooled file using WordPad, change the font to Courier New, style
    regular and size 8.  Set up the page to Lanscape with all 4 margins 0.2 in.

 5. This script has been tested up to Oracle Apps 11.5.4 with Oracle 8.1.7.

 6. If you need a detailed Explain Plan with CBO Stats for all relates objects,
    use coe_xplain.sql from Note:156958.1

 7. If bde_x.sql errors because of a missing column on PLAN_TABLE or because
    the table itself is missing, recreate the PLAN_TABLE:

    # sqlplus apps/apps@vis11i
    SQL> drop table PLAN_TABLE;
    SQL> START $ORACLE_HOME/rdbms/admin/utlxplan.sql;

 8. If the performance of the query to display the indexes is poor, delete
    the stats on PLAN_TABLE and truncate it.  Better yet, drop the PLAN_TABLE
    and create it back according to note 7 above.

 9. If you get no info in the bde_x_sql.txt report and a message similar to
    'Bind variable "B2" not declared', review your sql.txt file since it may
    have more than one blank line at the end.

10. For other SQL Tuning scripts, search on Metalink using keyword coescripts.

11. A practical guide in Troubleshooting Oracle ERP Applications Performance
    Issues can be found on Metalink under Note:169935.1


 Parameters
 ----------

    bde_x.sql requires one user parameter to specify the name of the file
    containing the SQL statement to be explained.  This parameter is passed
    on the same command line used to execute the bde_x.sql script.

    # sqlplus apps/apps@vis11i
    SQL> START bde_x.sql sql.txt;


 Caution
 -------

    The sample program in this article is provided for educational purposes
    only and is NOT supported by Oracle Support Services.  It has been tested
    internally, however, and works as documented.  We do not guarantee that it
    will work for you, so be sure to test it in your environment before
    relying on it.


 Portal
 ------

    Abstract: bde_x.sql - Simple Explain Plan for given SQL Statement (8.1-9.0)
    Author: Carlos Sierra
    Date: 03-SEP-02
    Description: Non-intrusive SQL Tuning tool to diagnose performance issues
    EMail: carlos.sierra@oracle.com
    Internal_Only: N
    Keywords: explainplan sqltuning coescripts appsperf appssqltuning coe bde
    Metalink_Note: 174603.1
    New_Win: Y
    Product: SQL*Plus script
    Version: 8.1-9.0 2002/09/03
    Download: bde_x.zip

 =========================================================================== */

SPOOL bde_x_&&1;
SET pages 255 lin 255 term off ver off trims on feed off autotrace off;
SET term on;
PROMPT
PROMPT ========================================================================
PROMPT bde_x.sql - Simple Explain Plan for given SQL Statement (8.1-9.0)
PROMPT ========================================================================
PROMPT
PROMPT Parameter 1 specifies filename of flat file containing SQL statement
PROMPT

GET &&1
0 EXPLAIN PLAN SET STATEMENT_ID = 'BDE_X_XYZ' FOR
/

COLUMN EXECORD    FORMAT 9999 HEADING 'Exec|Ord';
COLUMN PLANLINE   FORMAT A94  HEADING 'Explain Plan';
COLUMN INDX       FORMAT A55  HEADING 'Used Owner.Index';
COLUMN UNIQUENESS FORMAT A10  HEADING 'Uniqueness';
COLUMN COLNAME    FORMAT A30  HEADING 'Column Name';

SELECT EXECORD,
       PLANLINE
  FROM (SELECT PLANLINE,
               ROWNUM EXECORD,
               ID,
               RID
          FROM (SELECT PLANLINE,
                       ID,
                       RID,
                       LEV
                  FROM (SELECT lpad(' ',LEVEL+1,rpad(' ',80,'....|'))||
                               OPERATION||' '||                 -- Operation
                               DECODE(OPTIONS,NULL,'','('||OPTIONS||
                               ') ')||                          -- Options
                               DECODE(OBJECT_OWNER,null,'','OF '''||
                               OBJECT_OWNER||'.')||             -- Owner
                               DECODE(OBJECT_NAME,null,'',OBJECT_NAME||
                               ''' ')||                         -- Object Name
                               DECODE(OBJECT_TYPE,null,'','('||OBJECT_TYPE||
                               ') ')||                          -- Object Type
                               DECODE(ID,0,'Opt_Mode:')||       -- Optimizer
                               DECODE(OPTIMIZER,null,'','ANALYZED','',
                               OPTIMIZER)
                               PLANLINE,
                               ID,
                               LEVEL LEV,
                               (SELECT MAX(ID)
                                  FROM PLAN_TABLE PL2
                               CONNECT BY
                                       PRIOR ID = PARENT_ID
                                   AND PRIOR STATEMENT_ID = STATEMENT_ID
                                 START WITH
                                       ID = PL1.ID
                                   AND STATEMENT_ID = PL1.STATEMENT_ID) RID
                          FROM PLAN_TABLE PL1
                       CONNECT BY
                               PRIOR ID = PARENT_ID
                           AND PRIOR STATEMENT_ID = STATEMENT_ID
                         START WITH
                               ID = 0
                           AND STATEMENT_ID = 'BDE_X_XYZ')
                 ORDER BY
                       RID, -LEV))
 ORDER BY
       ID;

BREAK ON INDX SKIP 1 ON UNIQUENESS;
SELECT
       NVL((SELECT 'YES  '
              FROM PLAN_TABLE PT
             WHERE PT.OPERATION    = 'INDEX'
               AND PT.OBJECT_OWNER = AIC.INDEX_OWNER
               AND PT.OBJECT_NAME  = AIC.INDEX_NAME
               AND PT.STATEMENT_ID = 'BDE_X_XYZ'
               AND ROWNUM          = 1),'     ')||
       RPAD(SUBSTR(AIC.INDEX_OWNER||'.'||AIC.INDEX_NAME,1,50),50,'.') INDX,
       (SELECT AI.UNIQUENESS
          FROM ALL_INDEXES AI
         WHERE AI.OWNER      = AIC.INDEX_OWNER
           AND AI.INDEX_NAME = AIC.INDEX_NAME) UNIQUENESS,
       AIC.COLUMN_NAME COLNAME
  FROM ALL_IND_COLUMNS AIC
 WHERE (AIC.INDEX_OWNER,AIC.INDEX_NAME)
    IN (SELECT OWNER,
               INDEX_NAME
          FROM ALL_INDEXES
         WHERE (TABLE_OWNER,TABLE_NAME)
            IN (SELECT OBJECT_OWNER,
                       OBJECT_NAME
                  FROM PLAN_TABLE
                 WHERE OPERATION    = 'TABLE ACCESS'
                   AND STATEMENT_ID = 'BDE_X_XYZ'
                 UNION
                SELECT TABLE_OWNER,
                       TABLE_NAME
                  FROM ALL_INDEXES
                 WHERE (OWNER,INDEX_NAME)
                    IN (SELECT OBJECT_OWNER,
                               OBJECT_NAME
                          FROM PLAN_TABLE
                         WHERE OPERATION = 'INDEX'
                           AND STATEMENT_ID = 'BDE_X_XYZ')))
 ORDER BY
       AIC.INDEX_OWNER||'.'||AIC.INDEX_NAME,
       AIC.COLUMN_POSITION;

SPOOL OFF;
ROLLBACK;
SET pages 24 lin 80 ver on trims off feed on;
UNDEFINE 1;