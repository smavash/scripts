/*$Header: coe_import_stattab.sql 8.1-9.0 156964.1 2002/09/03   csierra coe $*/
SET term off;
/*=============================================================================

coe_import_stattab.sql - Imports CBO Stats from COE_STATTAB_XYZ into Dictionary

    *************************************************************
    This article is being delivered in Draft form and may contain
    errors.  Please use the MetaLink "Feedback" button to advise
    Oracle of any issues related to this article.
    *************************************************************


 Overview
 --------

    coe_import_stattab.sql uploads data dictionary statistics from table
    COE_STATTAB_XYZ in order to reproduce same explain plan from another
    instance.  This script is used in conjunction to coe_xplain.sql.


 Instructions
 ------------

 1. Copy this whole Note into a text file and name it coe_import_stattab.sql

 2. In source instance, execute coe_xplain.sql with SQL to diagnose.  It will
    download objects CBO stats (table, indexes and column stats) into table
    COE_STATTAB_XYZ in source instance.  No data, just dictionary stats.

 3. In source instance, export table COE_STATTAB_XYZ using export utility.
    Use Oracle account in OS to run 'exp' command below:

    # exp apps/apps file=COE_STATTAB_XYZ tables=COE_STATTAB_XYZ

 4. Transfer generated BINARY file COE_STATTAB_XYZ.dmp from source instance
    into destination instance.  Source instance could be client's environment
    and destination could be internal instance.  It could also be production
    and test, etc.  Transfer method must be BINARY.  Both instances must have
    same objects according to enhanced explain plan from coe_xplain.sql.

 5. In destination instance, drop or truncate COE_STATTAB_XYZ from apps.

    SQL> TRUNCATE TABLE coe_stattab_xyz;

 6. In destination instance, import objects stats (tables, indexes and columns)
    from COE_STATTAB_XYZ.dmp file into COE_STATTAB_XYZ table using command
    below from Oracle user in OS:

    # imp apps/apps file=COE_STATTAB_XYZ.dmp tables=COE_STATTAB_XYZ ignore=y

 7. In destination instance, execute this script coe_import_stattab.sql to
    upload stats from COE_STATTAB_XYZ table into data dictionary.

    # sqlplus apps/apps@vis11i
    SQL> START coe_import_stattab.sql;

 Program Notes
 -------------

 1. Always download latest version from Metalink (Note:156964.1), or ftp from

    ftp://oracle-ftp.oracle.com/apps/patchsets/AOL/SCRIPTS/PERFORMANCE/

    In order to avoid cut and paste or word wraping issues, use better ftp

 2. COE_STATTAB_XYZ.dmp is a BINARY file.  Don't xfr using ASCII method.

 3. This script has been tested up to Oracle Apps 11.5.4 with Oracle 8.1.7.

 4. Download coe_xplain.sql from Metalink Note:156958.1

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

    Abstract: coe_import_stattab.sql - Imports CBO Stats from COE_STATTAB_XYZ
    Author: Carlos Sierra
    Date: 03-SEP-02
    Description: Upload object stats based on coe_xplain.sql from other db
    EMail: carlos.sierra@oracle.com
    Internal_Only: N
    Keywords: CoE Script Statistics Export Import Gather
    Metalink_Note: 156964.1
    New_Win: Y
    Product: SQL*Plus script
    Version: 8.1-9.0 2002/09/03
    Download: coe_import_stattab.zip

=============================================================================*/
SET pages 0;
SET lin 200;
SET term on;

SELECT CST.C5||'.'||CST.C1||'.'||CST.C4 "Missing"
  FROM COE_STATTAB_XYZ CST
 WHERE CST.TYPE = 'C'
   AND NOT EXISTS (SELECT NULL
                     FROM ALL_TAB_COLUMNS ATC
                    WHERE ATC.OWNER       = CST.C5
                      AND ATC.TABLE_NAME  = CST.C1
                      AND ATC.COLUMN_NAME = CST.C4);

DELETE COE_STATTAB_XYZ CST
 WHERE CST.TYPE = 'C'
   AND NOT EXISTS (SELECT NULL
                     FROM ALL_TAB_COLUMNS ATC
                    WHERE ATC.OWNER       = CST.C5
                      AND ATC.TABLE_NAME  = CST.C1
                      AND ATC.COLUMN_NAME = CST.C4);

SPOOL coe_fix_stats.sql;
SELECT
    'EXEC DBMS_STATS.IMPORT_TABLE_STATS('''||
    C5||''','''||C1||
    ''',NULL,''COE_STATTAB_XYZ'',''COE_XPLAIN'',TRUE,''APPS'');'
FROM   COE_STATTAB_XYZ
WHERE  STATID = 'COE_XPLAIN'
AND    TYPE   = 'T';
SPOOL OFF;
START coe_fix_stats.sql;