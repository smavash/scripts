/*$Header: coe_view.sql 8.0-9.0 156972.1 2002/09/03             csierra coe $*/
SET term off ver off feed off trims on pages 0 lin 78 long 600000;
/*=============================================================================

coe_view.sql - Clones views across instances for SQL tuning exercises (8.0-9.0)

    *************************************************************
    This article is being delivered in Draft form and may contain
    errors.  Please use the MetaLink "Feedback" button to advise
    Oracle of any issues related to this article.
    *************************************************************


 Overview
 --------

    coe_view.sql uses dynamic SQL to generate a SQL*Plus script with the
    necessary commands to recreate any Apps view.

    The view name on the generated script has the prefix 'COE_'.

    The new view is generated with a different name to keep the original view
    untouched, in case the generated script gets executed on same instance.

    The generated script can be used to recreate the view from one instance
    into another.  Very common while diagnosing performance issues.

    Any SQL being debugged that uses this view, needs to be altered to
    reference the new view with its prefix 'COE_'.


 Instructions
 ------------

 1. Copy this whole Note into a text file and name it coe_view.sql

 2. Run coe_view.sql with one inline parameters:  The view name to duplicate.

    # sqlplus apps/apps@vis11i
    SQL> START coe_view.sql <view_name>;

    Example:
    SQL> START coe_view.sql so_lines;

 3. Review output file (spool): <view_name>.sql.  The spool file gets created
    on same directory from which this script is executed.  On NT, files may
    get created under $ORACLE_HOME/bin.

 5. Provide to Support spool file compressed into an *.zip file.

 6. Use the generated script into another instance, to duplicate the view.


 Program Notes
 -------------

 1. Always download latest version from Metalink (Note:156972.1), or ftp from

    ftp://oracle-ftp.oracle.com/apps/patchsets/AOL/SCRIPTS/PERFORMANCE/

    In order to avoid cut and paste or word wraping issues, use better ftp

 2. This script has been tested on Oracle Apps 11.5.4 with Oracle 8.1.7.

 3. Be sure you don't paste a space at the end of the view name.

 4. For other SQL Tuning scripts, search on Metalink using keyword coescripts.

 5. A practical guide in Troubleshooting Oracle ERP Applications Performance
    Issues can be found on Metalink under Note:169935.1


 Parameters
 ----------

 1. View Name.


 Caution
 -------

    The sample program in this article is provided for educational purposes
    only and is NOT supported by Oracle Support Services.  It has been tested
    internally, however, and works as documented.  We do not guarantee that it
    will work for you, so be sure to test it in your environment before
    relying on it.


 Portal
 ------

    Abstract: coe_view.sql - Clones views across instances for SQL tuning
    Author: Carlos Sierra
    Date: 03-SEP-02
    Description: To diagnose performance issues copying views across instances
    EMail: carlos.sierra@oracle.com
    Internal_Only: N
    Keywords: CoE Script coe_xplain.sql coescripts appsperf appssqltuning
    Metalink_Note: 156972.1
    New_Win: Y
    Product: SQL*Plus script
    Version: 8.0-9.0 2002/09/03
    Download: coe_view.zip

=============================================================================*/

SET term off ver off feed off trims on pages 0 lin 78 long 600000;
SET term on autotrace off;
PROMPT
PROMPT coe_view.sql - Creates dynamic script to duplicate any Apps view
PROMPT
PROMPT Parameter 1 specifies view name
PROMPT

VAR v_max_column_id NUMBER;

SELECT 'Creating script &&1..sql'
  FROM all_views
 WHERE owner = user
   AND view_name = RTRIM(UPPER('&&1'));

BEGIN
   SELECT MAX(column_id)
     INTO :v_max_column_id
     FROM all_tab_columns
    WHERE owner      = user
      AND table_name = RTRIM(UPPER('&&1'));
END;
/

COLUMN text WOR;
SPOOL &&1..sql;

SELECT '/*$Header: &&1..sql '||TO_CHAR(sysdate,'YYYY/MM/DD')||
       '  coe_view.sql */'
  FROM sys.dual;

SELECT 'CREATE OR REPLACE VIEW COE_&&1 ('
  FROM sys.dual;

SELECT '    '||column_name||','
  FROM all_tab_columns
 WHERE owner       = user
   AND table_name  = RTRIM(UPPER('&&1'))
   AND column_id+0 < :v_max_column_id
 ORDER BY column_id;

SELECT '    '||column_name||' ) AS '
  FROM all_tab_columns
 WHERE owner       = user
   AND table_name  = RTRIM(UPPER('&&1'))
   AND column_id+0 = :v_max_column_id;

SELECT text
  FROM all_views
 WHERE owner = user
   AND view_name = RTRIM(UPPER('&&1'));

SELECT '/'
  FROM sys.dual;

SPOOL off;
UNDEFINE 1;
SET ver on feed on trims off pages 24 lin 80 long 80;