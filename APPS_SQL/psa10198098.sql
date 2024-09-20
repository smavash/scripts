 
REM I script name psa10198098.sql for data fix. 
REM The data fix script can be run as follows:
REM sqlplus apps/<apps pwd>databasename psa10198098.sql


REM +=======================================================================================+
REM |                        Copyright (c) 2010 Oracle Corporation                          |
REM |                           Redwood Shores, California, USA                             |
REM |                                All rights reserved                                    |
REM +=======================================================================================+
REM =========================================================================================
REM  File Name     :  psa10198098.sql
REM
REM  Tables Created:  None
REM
REM  Bug           :  10198098
REM
REM  Warning       :  This script must not be run without consulting Oracle Support.
REM
REM  Patchset Info :  This file should not be included in future patchsets.
REM
REM  Parameters    :  p_ledger_id - The ledger for which this script must be run
REM
REM  Usage         :  sqlplus apps/&lt;apps pwd&gt;@databasename @ psa10198098.sql
REM
REM
REM  History       :
REM
REM      14-Oct-2010  vensubra         Created
REM =========================================================================================

SET LINE 400;
SET SERVEROUTPUT ON SIZE 1000000;

WHENEVER SQLERROR EXIT FAILURE ROLLBACK;
WHENEVER OSERROR  EXIT FAILURE ROLLBACK;

SPOOL /u01_share/DBA/psa10198098_log.txt;

CREATE TABLE psa_inv_dist_bug_10198098 AS
SELECT * FROM ap_invoice_distributions_all
WHERE invoice_id = 85674;


BEGIN

DBMS_OUTPUT.PUT_LINE('10198098 - Start of Data fix');

UPDATE ap_invoice_distributions_all
SET bc_event_id = NULL
WHERE invoice_id = 85674
  AND invoice_distribution_id IN (1494359,1494358)
  AND bc_event_id IS NOT NULL
  AND encumbered_flag = 'N';

DBMS_OUTPUT.PUT_LINE('10198098 - Number of rows updated:'|| SQL%ROWCOUNT);
  
COMMIT;

EXCEPTION
	WHEN OTHERS THEN
	    DBMS_OUTPUT.PUT_LINE('10198098 - Error SQLERRM='||SQLERRM);
		ROLLBACK;
END;
/
SPOOL OFF;
EXIT;
