REM $Header: AP_GDF_DIAG_SLA.sql V4
REM
REM dbdrv: none
REM
REM +=======================================================================+
REM |    Copyright (c) 2001 Oracle Corporation, Redwood Shores, CA, USA     |
REM |                         All rights reserved.                          |
REM +=======================================================================+
REM | FILENAME                                                              |
REM |     AP_GDF_DIAG_SLA.sql			            |
REM | DESCRIPTION                                                           |
REM |      This file give what generic known issues are applicable for SLA  |
REM | HISTORY                                                               |
REM |   13-APR-2010       VIRENDRA BHANDARI                                 |
REM |   26-MAY-2010       VIRENDRA BHANDARI                                 |
REM | Below cases are coeverd	
REM +=======================================================================+

REM Note  874904.1 R12 Generic Data Fix (GDF) patch for Accounting Dates for Invoice or Payment not in sync with Subledger Tables  
REM Note  874705.1 R12 Generic Data Fix (GDF) patch for Payment event types that can not be accounted after patch 7594938 
REM Note  742429.1 R12 Generic Data Fix (GDF) for Invoice/Payment events that can not be accounted after all holds are released  
REM Note  788135.1 R12 Generic Data Fix (GDF) patch to Delete Orphan Records in XLA Tables for Payables
REM Note  874710.1 R12 Generic Data Fix (GDF) patch for incorrect event_id for Payment Type Adjusted events 
REM Note  875012.1 R12 Generic Data Fix (GDF) patch for Unaccounted Payables Transactions in a closed period  
REM Note  970912.1 R12 Generic Data Fix (GDF) patch Prepayment Applied/Unapplied events that can not be accounted after the invoice is Cancelled. 
REM Note  970956.1 R12 Generic Data Fix (GDF) patch to delete Payment Adjusted events with out corresponding distributions. 
REM Note  972261.1 R12 Generic Data Fix (GDF) Patch 8966238 - Approved Invoice Distributions and / or Payments Missing ACCOUNTING_EVENT_ID 
REM Note 1054299.1 R12 GDF TO POPULATE MISSING XDL FOR ALL MIGRATED TRANSACTIONS 
REM Note 1054322.1 R12 GDF TO POPULATE MISSING XDL FOR UPSTREAM TRANSACTIONS 
REM Note 1071876.1 R12 POSTED FLAGS ARE INCORRECT FOR ACCOUNTED INVOICES/PAYMENTS 
REM Note 1083599.1 R12 Generic Data Fix (GDF) patch for upgraded invoices on Trial Balance due to Party ID mismatch 
REM Note 1089119.1 R12 Generic Data Fix (GDF) patch for PAYMENT ACCOUNTING IS WRONG WHEN THERE IS DISCOUNT 
REM Note 1089156.1 R12 GDF:DELETION OF MANUAL PAYMENT ADJUSTED EVENTS FOR QUICK PAYMENTS 
REM Note 1089168.1 R12 GDF:Related_event_id missing on reversal events (upgraded) 
REM Note 1088872.1 R12 Generic Data Fix (GDF) patch to correct the data corruption for posted flag having value as 'S' 
REM Note 1109933.1 R12 Generic Data Fix (GDF) Patch to Correct Upgraded Accounting Lines for Prepayment Invoices Missing  Business 
REM Note 1118703.1 R12 GDF: REISSUED CHECKS ACCOUNTED INCORRECTLY 
REM Note 1146638.1 R12 GDF: Payment clearing event do not get accounted when recon_accounting_flag is changed after payment accounting 
REM Note 1177653.1 R12 GDF :PAYMENT CLEARING EVENT - ERROR 0 THE APPLIED-TO SOURCES PROVIDED FOR THIS 
REM Note 1190473.1 R12 Generic Data Fix (GDF) patch for Prepayment reissue 0 amount accounting 
REM Note 1193313.1 R12 GDF : EC12 ERROR IN JOURNAL IMPORT - WRONG PAYMENT CLEARING ACCOUNTING 



SET SERVEROUTPUT ON
SET VERIFY OFF

DECLARE
v_temp number;
v_filedir varchar2(100);
l_message varchar2(1000);
l_count number;
l_count1              NUMBER;
l_exists              NUMBER :=0;
l_count_2               NUMBER;
l_count_1               Number; 
l_date                  DATE ;

l_dummy               NUMBER;
l_bug_no              VARCHAR2(100) ;
l_driver_inv_tab      ALL_TABLES.TABLE_NAME%TYPE;
l_driver_chk_tab      ALL_TABLES.TABLE_NAME%TYPE;
l_affected_pay_tab    ALL_TABLES.TABLE_NAME%TYPE;
l_debug_info          FND_LOG_MESSAGES.MESSAGE_TEXT%TYPE;
l_error_log           FND_LOG_MESSAGES.MESSAGE_TEXT%TYPE;
l_select_list         LONG;
l_table_name          ALL_TABLES.TABLE_NAME%TYPE;
l_where_clause        LONG;
l_sql_stmt            LONG;
l_calling_sequence    FND_LOG_MESSAGES.MESSAGE_TEXT%TYPE;
L_DRIVER_TAB          ALL_TABLES.TABLE_NAME%TYPE;
L_DRIVER_TAB1          ALL_TABLES.TABLE_NAME%TYPE;  
l_check_fail            NUMBER ;
l_current_date              VARCHAR2(500);
l_database				  VARCHAR2(500); 
l_undoAcctg_tab       ALL_TABLES.TABLE_NAME%TYPE;
	

Begin

	SELECT decode(instr(value,','),0,value, SUBSTR (value,1,instr(value,',') - 1)) 
	INTO v_filedir
	FROM v$parameter 
	WHERE name = 'utl_file_dir';
	
	 AP_Acctg_Data_Fix_PKG.Open_Log_Out_Files ('GDF_SLA-diag',v_filedir);
     AP_Acctg_Data_Fix_PKG.Print('<html><body>');
	 
	 
	  AP_Acctg_Data_Fix_PKG.Print('<h2>**********GDF Diagnostic Output for SLA issues**********</h2>');
	  AP_Acctg_Data_Fix_PKG.Print('--------------------------------------------------------');
	  
	  select to_char (sysdate,'DD-MON-YYYY HH:MI:SS') 
		INTO l_current_date From DUAL;
  
	  select name INTO l_database from v$database;
        AP_Acctg_Data_Fix_PKG.Print('You are running the script version : '|| '<B>' ||'V4'||'</B>');  
		AP_Acctg_Data_Fix_PKG.Print('Script Run Time Is     : '|| '<B>' ||l_current_date||'</B>'); 
        AP_Acctg_Data_Fix_PKG.Print('Script Run Database Is : '|| '<B>' ||l_database ||'</B>');
		
	l_message := '_______________________________________'||
                 '_______________________________________'||
				 '_______________________________________'||
				 '_______________________________________';
    AP_Acctg_Data_Fix_PKG.Print(l_message); 	
  
	
 /*=======================================================================+
 | FILENAME                                                              |
 |     ap_AcctgDateOutOfSynch_sel.sql                                    |
 |                                                                       |
 | DESCRIPTION                                                           |
 |     This script is to select the checks and invoices with accounting  |
 |     out of synch accounting dates when compared to date in xla_events.|
 | HISTORY Created by imandal                                            |
 +=======================================================================*/

	BEGIN
    Execute Immediate
      'DROP TABLE ap_temp_data_driver_8531305';

    EXCEPTION
    WHEN OTHERS THEN
     Null;
	
    END;
	
	BEGIN
    Execute Immediate 'CREATE TABLE ap_temp_data_driver_8531305
      (
	INVOICE_ID                NUMBER(15),
	INVOICE_NUM               VARCHAR2(50),
	INVOICE_DISTRIBUTION_ID   NUMBER(15),
	DETAIL_TAX_DIST_ID        NUMBER,
	CHECK_ID                  NUMBER(15),
	CHECK_NUMBER              NUMBER(15),
        INVOICE_PAYMENT_ID        NUMBER(15),
	PAYMENT_HISTORY_ID        NUMBER(15),
	PREPAY_HISTORY_ID	  NUMBER(15),
	EVENT_ID                  NUMBER(15),
	POSTED_FLAG               VARCHAR2(1),
	ORG_ID                    NUMBER(15),
	TRANSACTION_DATE          DATE,
	EVENT_DATE                DATE,
	SELF_ASSESSED_FLAG	  VARCHAR2(1),
	PROCESS_FLAG              VARCHAR2(1) DEFAULT ''Y''
      )';
    EXCEPTION
    WHEN OTHERS THEN
     l_message := 'EXCEPTION :: '||SQLERRM ||
	             ' in Creating acctgdate_sel_inv_8531305';
     FND_File.Put_Line(fnd_file.output,l_message);
	
     l_message := 'in side ap_AcctgDateOutOfSynch_sel.sql';
     FND_File.Put_Line(fnd_file.output,l_message);
    END;
	
	BEGIN
    Execute Immediate
      'Insert into ap_temp_data_driver_8531305
      (
        INVOICE_ID,
        INVOICE_NUM,
        TRANSACTION_DATE,
	EVENT_DATE,
	EVENT_ID,
        INVOICE_DISTRIBUTION_ID,
        POSTED_FLAG,
        ORG_ID,
	SELF_ASSESSED_FLAG,
        PROCESS_FLAG
      )
     (SELECT   aid.invoice_id 
	      ,ai.invoice_num
              ,aid.accounting_date
	      ,xe.event_date 
	      ,xe.event_id         
              ,aid.invoice_distribution_id
              ,aid.posted_flag    
              ,aid.org_id
	      ,''N''
	      ,''Y''
      FROM     AP_INVOICE_DISTRIBUTIONS_ALL aid
	      ,XLA_EVENTS xe 
	      ,AP_INVOICES_ALL ai
      WHERE   aid.ACCOUNTING_EVENT_ID = xe.EVENT_ID 
      AND     xe.application_id = 200 
      AND     ai.invoice_id = aid.invoice_id
      AND     trunc(aid.ACCOUNTING_date) <> trunc(xe.EVENT_DATE)
     )';
  EXCEPTION
    WHEN OTHERS THEN
      l_message := 'EXCEPTION :: '||SQLERRM ||
	             ' while inserting into ap_temp_data_driver_8531305 for Invoice distributions';
      FND_File.Put_Line(fnd_file.output,l_message);
	
  END;   

  BEGIN
    Execute Immediate
      'Insert into ap_temp_data_driver_8531305
      (
        INVOICE_ID,
        INVOICE_NUM,
        TRANSACTION_DATE,
	EVENT_DATE,
	EVENT_ID,
        INVOICE_DISTRIBUTION_ID,
        POSTED_FLAG,
        ORG_ID,
	SELF_ASSESSED_FLAG,
        PROCESS_FLAG
      )
     (SELECT   aid.invoice_id 
	      ,ai.invoice_num
              ,aid.accounting_date
	      ,xe.event_date 
	      ,xe.event_id         
              ,aid.invoice_distribution_id
              ,aid.posted_flag    
              ,aid.org_id
	      ,''Y''
	      ,''Y''
      FROM     AP_SELF_ASSESSED_TAX_DIST_ALL aid
	      ,XLA_EVENTS xe 
	      ,AP_INVOICES_ALL ai
      WHERE   aid.ACCOUNTING_EVENT_ID = xe.EVENT_ID 
      AND     xe.application_id = 200 
      AND     ai.invoice_id = aid.invoice_id
      AND     trunc(aid.ACCOUNTING_date) <> trunc(xe.EVENT_DATE)
     )';
  EXCEPTION
    WHEN OTHERS THEN
      l_message := 'EXCEPTION :: '||SQLERRM ||
	             ' while inserting into ap_temp_data_driver_8531305 for Invoice distributions'||
		     ' from ap_self_assessed_tax_dist_all';
      FND_File.Put_Line(fnd_file.output,l_message);
	
  END;   

  BEGIN
    Execute Immediate
      'Insert into ap_temp_data_driver_8531305
      (
        INVOICE_ID,
        INVOICE_NUM,
        TRANSACTION_DATE,
	EVENT_DATE,
	EVENT_ID,
        DETAIL_TAX_DIST_ID,
        POSTED_FLAG,
        ORG_ID,
        PROCESS_FLAG
      )
     (SELECT   DISTINCT 
               aid.invoice_id 
	      ,ai.invoice_num
	      ,zrnd.gl_date
              ,xe.event_date
	      ,xe.event_id
	      ,zrnd.rec_nrec_tax_dist_id
	      ,aid.posted_flag
              ,aid.org_id
	      ,''Y''
      FROM     ZX_REC_NREC_DIST zrnd
	      ,AP_INVOICE_DISTRIBUTIONS_ALL aid
	      ,AP_INVOICES_ALL ai
              ,XLA_EVENTS XE 
      WHERE   aid.ACCOUNTING_EVENT_ID = XE.EVENT_ID 
      AND     aid.detail_tax_dist_id  = zrnd.rec_nrec_tax_dist_id
      AND     zrnd.application_id = 200
      AND     zrnd.entity_code = ''AP_INVOICES''
      AND     zrnd.event_class_code IN (''STANDARD INVOICES'', ''PREPAYMENT INVOICES'', ''EXPENSE REPORTS'')
      AND     zrnd.trx_id = aid.invoice_id 
      AND     aid.invoice_id = ai.invoice_id
      AND     xe.application_id = 200 
      AND     trunc(zrnd.GL_date) <> trunc(XE.EVENT_DATE)
     )';
  EXCEPTION
    WHEN OTHERS THEN
      l_message := 'EXCEPTION :: '||SQLERRM ||
	             ' while inserting into ap_temp_data_driver_8531305 for Tax distributions'||
		     ' from ap_invoice_distributions_all';
      FND_File.Put_Line(fnd_file.output,l_message);
	
  END;

  BEGIN
    Execute Immediate
      'Insert into ap_temp_data_driver_8531305
      (
        INVOICE_ID,
        INVOICE_NUM,
        TRANSACTION_DATE,
	EVENT_DATE,
	EVENT_ID,
        DETAIL_TAX_DIST_ID,
        POSTED_FLAG,
        ORG_ID,
        PROCESS_FLAG
      )
     (SELECT   aid.invoice_id 
	      ,ai.invoice_num
	      ,zrnd.gl_date
              ,xe.event_date
	      ,xe.event_id
	      ,zrnd.rec_nrec_tax_dist_id
	      ,aid.posted_flag
              ,aid.org_id
	      ,''Y''
      FROM     ZX_REC_NREC_DIST zrnd
	      ,AP_SELF_ASSESSED_TAX_DIST_ALL aid
	      ,AP_INVOICES_ALL ai
              ,XLA_EVENTS XE 
      WHERE   aid.ACCOUNTING_EVENT_ID = XE.EVENT_ID 
      AND     aid.detail_tax_dist_id  = zrnd.rec_nrec_tax_dist_id
      AND     zrnd.application_id = 200
      AND     zrnd.entity_code = ''AP_INVOICES''
      AND     zrnd.event_class_code IN (''STANDARD INVOICES'', ''PREPAYMENT INVOICES'', ''EXPENSE REPORTS'')
      AND     zrnd.trx_id = aid.invoice_id
      AND     aid.invoice_id = ai.invoice_id
      AND     xe.application_id = 200 
      AND     trunc(zrnd.GL_date) <> trunc(XE.EVENT_DATE)
     )';
    EXCEPTION
    WHEN OTHERS THEN
      l_message := 'EXCEPTION :: '||SQLERRM ||
	             ' while inserting into ap_temp_data_driver_8531305 for Tax distributions'||
		     ' from ap_self_assessed_tax_dist_all';
      FND_File.Put_Line(fnd_file.output,l_message);
	
    END;

    BEGIN
    Execute Immediate
      'Insert into ap_temp_data_driver_8531305
      (
        INVOICE_ID,
        INVOICE_NUM,
        TRANSACTION_DATE,
	EVENT_DATE,
	EVENT_ID,
        PREPAY_HISTORY_ID,
        POSTED_FLAG,
        ORG_ID,
        PROCESS_FLAG
      )
     (SELECT   apph.invoice_id 
	      ,ai.invoice_num
              ,apph.accounting_date
	      ,xe.event_date 
	      ,xe.event_id         
              ,apph.prepay_history_id 
              ,apph.posted_flag    
              ,apph.org_id
	      ,''Y''
      FROM     ap_prepay_history_all apph
	      ,XLA_EVENTS xe 
	      ,AP_INVOICES_ALL ai
      WHERE   apph.ACCOUNTING_EVENT_ID = xe.EVENT_ID 
      AND     xe.application_id = 200 
      AND     ai.invoice_id = apph.invoice_id
      AND     trunc(apph.ACCOUNTING_date) <> trunc(xe.EVENT_DATE)
     )';
    EXCEPTION
    WHEN OTHERS THEN
      l_message := 'EXCEPTION :: '||SQLERRM ||
	             ' while inserting into ap_temp_data_driver_8531305 for Invoice distributions'||
		     ' from ap_self_assessed_tax_dist_all ';
      FND_File.Put_Line(fnd_file.output,l_message);
	
    END;   

    BEGIN
    Execute Immediate
      'Insert into ap_temp_data_driver_8531305
      ( 
        CHECK_ID,
        CHECK_NUMBER,
        TRANSACTION_DATE,
	EVENT_DATE,
	EVENT_ID,
	INVOICE_PAYMENT_ID,
        POSTED_FLAG,
        ORG_ID,
        PROCESS_FLAG
      )
     (SELECT   aip.check_id  
	      ,ac.check_number
              ,aip.accounting_date
	      ,xe.event_date
	      ,xe.event_id
	      ,aip.invoice_payment_id 
	      ,aip.posted_flag
              ,aip.org_id 
	      ,''Y''
      FROM     AP_INVOICE_PAYMENTS_ALL aip
              ,AP_CHECKS_ALL ac
              ,XLA_EVENTS XE 
      WHERE   aip.ACCOUNTING_EVENT_ID = XE.EVENT_ID 
      AND     xe.application_id = 200 
      AND     ac.check_id = aip.check_id
      AND     trunc(aip.ACCOUNTING_date) <> trunc(XE.EVENT_DATE)
      )';

    EXCEPTION
     WHEN OTHERS THEN
      l_message := 'EXCEPTION :: '||SQLERRM ||
	             ' while inserting into ap_temp_data_driver_8531305 for Invoice Payments';
      FND_File.Put_Line(fnd_file.output,l_message);
    END;

    BEGIN
    Execute Immediate
     'Insert into ap_temp_data_driver_8531305
     (  
        CHECK_ID,
        CHECK_NUMBER,
        TRANSACTION_DATE,
        EVENT_DATE,
        EVENT_ID,
        PAYMENT_HISTORY_ID,
        POSTED_FLAG,
        ORG_ID,
        PROCESS_FLAG
      )
     (SELECT   aph.check_id 
	      ,ac.check_number
              ,aph.accounting_date
	      ,xe.event_date
	      ,xe.event_id 
	      ,aph.payment_history_id
	      ,aph.posted_flag
              ,aph.org_id
	      ,''Y''
      FROM     AP_PAYMENT_HISTORY_ALL aph
	      ,AP_CHECKS_ALL ac
              ,XLA_EVENTS XE 
      WHERE   aph.ACCOUNTING_EVENT_ID = XE.EVENT_ID 
      AND     ac.check_id = aph.check_id
      AND     xe.application_id = 200 
      AND     trunc(aph.ACCOUNTING_date) <> trunc(XE.EVENT_DATE)
      )'; 

    EXCEPTION
     WHEN OTHERS THEN
       l_message := 'EXCEPTION :: '||SQLERRM ||
	             ' while Inserting in ap_temp_data_driver_8531305 for payment history';
       FND_File.Put_Line(fnd_file.output,l_message);
	
       l_message := 'in side ap_AcctgDateOutOfSynch_sel.sql';
       FND_File.Put_Line(fnd_file.output,l_message);
    END;
	
	 BEGIN
    Execute Immediate  
      'SELECT COUNT(*) FROM ap_temp_data_driver_8531305 WHERE INVOICE_ID IS NOT NULL '||
      ' AND PREPAY_HISTORY_ID IS NULL' into l_count;
  EXCEPTION
     WHEN OTHERS THEN
       l_message := 'EXCEPTION :: '||SQLERRM ||
	             ' while selecting count of ap_temp_data_driver_8531305';
       FND_File.Put_Line(fnd_file.output,l_message);
	
  END; 
    IF (l_count > 0) THEN 
      AP_Acctg_Data_Fix_PKG.Print('******* Details of the affected invoice distributions '||
        ' from ap_invoice_distribuions_all and ap_self_assessed_tax_dists_all '||
	'where Accounting Dates for Invoice or Payment not in sync with Subledger Tables.'||
	'Please follow note 874904.1 for GDF *******');            
    BEGIN
      AP_Acctg_Data_Fix_PKG.Print_html_table                           
       ('INVOICE_ID,INVOICE_NUM,TRANSACTION_DATE,'||
        'EVENT_DATE,POSTED_FLAG,ORG_ID,PROCESS_FLAG',
	'ap_temp_data_driver_8531305',
	' WHERE INVOICE_ID IS NOT NULL AND PREPAY_HISTORY_ID IS NULL Group by INVOICE_ID,INVOICE_NUM,TRANSACTION_DATE,'||
        'EVENT_DATE,POSTED_FLAG,ORG_ID,PROCESS_FLAG ',
        'ap_AcctgDateOutOfSynch_sel.sql'
       );                                              
    EXCEPTION                                                          
       WHEN OTHERS THEN
          l_message := 'EXCEPTION :: '||SQLERRM ||
	             ' while printing ap_temp_data_driver_8531305 for invoice distributions';
          FND_File.Put_Line(fnd_file.output,l_message);
	
         
    END;
    ELSE
          l_message :=  'There are no rows in ap_invoice_distributions_all  and '||
                'ap_self_assessed_tax_dist_all with this issue where Accounting Dates for Invoice or Payment not in sync with Subledger Tables'
				||'Please follow note 874904.1 for GDF';
          AP_Acctg_Data_Fix_PKG.Print(l_message);
    END IF;
  
  BEGIN
    Execute Immediate  
      'SELECT COUNT(*) FROM ap_temp_data_driver_8531305 WHERE  '||
      ' DETAIL_TAX_DIST_ID IS NOT NULL' into l_count;
  EXCEPTION
     WHEN OTHERS THEN
       l_message := 'EXCEPTION :: '||SQLERRM ||
	             ' while selecting count of ap_temp_data_driver_8531305';
       FND_File.Put_Line(fnd_file.output,l_message);
	
  END; 
   IF (l_count > 0) THEN 
      AP_Acctg_Data_Fix_PKG.Print('******* Details of the affected tax distributions '||
        ' from ap_invoice_distribuions_all and ap_self_assessed_tax_dists_all '||
	'where Accounting Dates for Invoice or Payment not in sync with Subledger Tables.Please follow note 874904.1 for GDF *******');            
    BEGIN
      AP_Acctg_Data_Fix_PKG.Print_html_table                           
       ('INVOICE_ID,INVOICE_NUM,TRANSACTION_DATE,'||
        'EVENT_DATE,POSTED_FLAG,ORG_ID,PROCESS_FLAG',
	'ap_temp_data_driver_8531305',
	' WHERE DETAIL_TAX_DIST_ID IS NOT NULL Group by INVOICE_ID,INVOICE_NUM,TRANSACTION_DATE,'||
        'EVENT_DATE,POSTED_FLAG,ORG_ID,PROCESS_FLAG ',
        'ap_AcctgDateOutOfSynch_sel.sql'
       );                                              
    EXCEPTION                                                          
       WHEN OTHERS THEN
          l_message := 'EXCEPTION :: '||SQLERRM ||
	             ' while printing ap_temp_data_driver_8531305 for Tax distributions';
          FND_File.Put_Line(fnd_file.output,l_message);
	
         
    END;
    ELSE
          l_message :=  'There are no rows in zx_rec_nrec_dist '||
                ' for tax distributions with this issue ';
          AP_Acctg_Data_Fix_PKG.Print(l_message);
    END IF;
  BEGIN
    Execute Immediate  
      'SELECT COUNT(*) FROM ap_temp_data_driver_8531305 WHERE INVOICE_ID IS NOT NULL'|| 
      ' AND PREPAY_HISTORY_ID IS NOT NULL ' into l_count;
  EXCEPTION
     WHEN OTHERS THEN
       l_message := 'EXCEPTION :: '||SQLERRM ||
	             ' while selecting count of ap_temp_data_driver_8531305 for prepay';
       FND_File.Put_Line(fnd_file.output,l_message);
	
  END; 
    IF (l_count > 0) THEN 
      AP_Acctg_Data_Fix_PKG.Print('******* Details of the affected prepay distributions '||
	'where Accounting Dates for Invoice or Payment not in sync with Subledger Tables.Please follow note 874904.1 for GDF *******');            
    BEGIN
      AP_Acctg_Data_Fix_PKG.Print_html_table                           
       ('INVOICE_ID,INVOICE_NUM,TRANSACTION_DATE,'||
        'EVENT_DATE,POSTED_FLAG,ORG_ID,PROCESS_FLAG',
	'ap_temp_data_driver_8531305',
	' WHERE INVOICE_ID IS NOT NULL AND PREPAY_HISTORY_ID IS NOT NULL Group by INVOICE_ID,INVOICE_NUM,TRANSACTION_DATE,'||
        'EVENT_DATE,POSTED_FLAG,ORG_ID,PROCESS_FLAG ',
        'ap_AcctgDateOutOfSynch_sel.sql'
       );                                              
    EXCEPTION                                                          
       WHEN OTHERS THEN
          l_message := 'EXCEPTION :: '||SQLERRM ||
	             ' while printing ap_temp_data_driver_8531305 for prepay distributions';
          FND_File.Put_Line(fnd_file.output,l_message);
	
         
    END;
    ELSE
          l_message :=  'There are no rows in ap_prepay_history_all '||
                ' with this issue  <p>';
          AP_Acctg_Data_Fix_PKG.Print(l_message);
    END IF;

  
  BEGIN
    Execute Immediate  
      'SELECT COUNT(*) FROM ap_temp_data_driver_8531305 WHERE INVOICE_PAYMENT_ID IS NOT NULL' into l_count;
  EXCEPTION
     WHEN OTHERS THEN
       l_message := 'EXCEPTION :: '||SQLERRM ||
	             ' while selecting count of ap_temp_data_driver_8531305 for invoice payments';
       FND_File.Put_Line(fnd_file.output,l_message);
	
  END; 
    IF (l_count > 0) THEN 
      AP_Acctg_Data_Fix_PKG.Print('******* Details of the affected checks in '||
	'ap_invoice_payments_all where Accounting Dates for Invoice or Payment not in sync with Subledger Tables'||
	'.Please follow note 874904.1 for GDF *******');            
    BEGIN
      AP_Acctg_Data_Fix_PKG.Print_html_table                           
       ('CHECK_ID,CHECK_NUMBER,TRANSACTION_DATE,'||
	'EVENT_DATE,ORG_ID,PROCESS_FLAG',
	'ap_temp_data_driver_8531305',
	' WHERE INVOICE_PAYMENT_ID IS NOT NULL Group by CHECK_ID,CHECK_NUMBER,TRANSACTION_DATE,'||
	'EVENT_DATE,ORG_ID,PROCESS_FLAG',
        'ap_AcctgDateOutOfSynch_sel.sql');                                              
    EXCEPTION                                                          
       WHEN OTHERS THEN
          l_message := 'EXCEPTION :: '||SQLERRM ||
	             ' while printing ap_temp_data_driver_8531305 for payment distributions ';
          FND_File.Put_Line(fnd_file.output,l_message);
	
         
    END;
    ELSE
          l_message :=  'There are no rows in ap_invoice_payments_all  '||
                'with this issue ';
          AP_Acctg_Data_Fix_PKG.Print(l_message);
    END IF;

  BEGIN
  Execute Immediate  
      'SELECT COUNT(*) FROM ap_temp_data_driver_8531305 WHERE PAYMENT_HISTORY_ID IS NOT NULL' into l_count;
  EXCEPTION
     WHEN OTHERS THEN
       l_message := 'EXCEPTION :: '||SQLERRM ||
	             ' while selecting count of ap_temp_data_driver_8531305 for payment history';
       FND_File.Put_Line(fnd_file.output,l_message);
	
  END; 
    IF (l_count > 0) THEN 
      AP_Acctg_Data_Fix_PKG.Print('******* Details of the affected checks in'||
	' ap_payment_history_all where Accounting Dates for Invoice or Payment not in sync '||
	'with Subledger Tables.Please follow note 874904.1 for GDF *******');            
    BEGIN
      AP_Acctg_Data_Fix_PKG.Print_html_table                           
       ('CHECK_ID,CHECK_NUMBER,TRANSACTION_DATE,'||
	'EVENT_DATE,ORG_ID,PROCESS_FLAG',
	'ap_temp_data_driver_8531305',
	' WHERE PAYMENT_HISTORY_ID IS NOT NULL Group by CHECK_ID,CHECK_NUMBER,TRANSACTION_DATE,'||
	'EVENT_DATE,ORG_ID,PROCESS_FLAG ',
        'ap_AcctgDateOutOfSynch_sel.sql');                                              
    EXCEPTION                                                          
       WHEN OTHERS THEN
          l_message := 'EXCEPTION :: '||SQLERRM ||
	             ' while printing ap_temp_data_driver_8531305 while printing payment history';
          FND_File.Put_Line(fnd_file.output,l_message);
	
    END;
    ELSE
          l_message :=  'There are no rows in ap_payment_history_all  '||
                'with this issue ';
          AP_Acctg_Data_Fix_PKG.Print(l_message);
    END IF;
	
         
    

 /*=======================================================================+
 | FILENAME                                                              |
 |     ap_acctd_PayCncl_rev_event_sel.sql                           |
 |                                                                       |
 | DESCRIPTION                                                           |
 |     This script is to select the voided checked which have payment    |
 |     cancelled as accounted but the prior events are not accounted.    |
 |                                                                       |
 | HISTORY Created by imandal                                            |
 +=======================================================================*/
	
BEGIN
    Execute Immediate
      'DROP TABLE ap_temp_data_driver_8526084';

  EXCEPTION
    WHEN OTHERS THEN
     Null;
	
  END;

  BEGIN
    Execute Immediate
      'DROP TABLE ap_prob_pay_events_8526084';

  EXCEPTION
    WHEN OTHERS THEN
     Null;

  END;

  BEGIN
    Execute Immediate
      'DROP TABLE ap_prob_pay_history_8526084';

  EXCEPTION
    WHEN OTHERS THEN
     Null;
	
  END;
 
  --------------------------------------------------------------------------
  -- Step 2: create backup tables and driver tables
  --------------------------------------------------------------------------
 
  BEGIN
    Execute Immediate
      'CREATE TABLE ap_temp_data_driver_8526084(
	                                   CHECK_ID            NUMBER(15),
                                           BANK_ACCOUNT_ID     NUMBER(15),                                                                                                                                                                                    
	                                   BANK_ACCOUNT_NAME   VARCHAR2(80),
	                                   AMOUNT              NUMBER,                                                                                                                                                                                        
	                                   CHECK_NUMBER        NUMBER(15),                    
	                                   CHECK_DATE          DATE,
	                                   CURRENCY_CODE       VARCHAR2(15),
	                                   CLEARED_DATE        DATE,
	                                   CLEARED_AMOUNT      NUMBER,
	                                   VOID_DATE           DATE
	                                  )';
   EXCEPTION
     WHEN OTHERS THEN
      l_message := 'EXCEPTION :: '||SQLERRM ||
                  ' in creating ap_temp_data_driver_8526084';
      FND_File.Put_Line(fnd_file.output,l_message);
	
   END;

  Begin
    Execute Immediate
      'CREATE TABLE ap_prob_pay_events_8526084(
	                                   EVENT_ID            NUMBER(15),
                                           APPLICATION_ID      NUMBER(15),                                                                                                                                                                                    
	                                   EVENT_TYPE_CODE     VARCHAR2(30),
	                                   EVENT_DATE          DATE,                                                                                                                                                                                        
	                                   ENTITY_ID           NUMBER(15),                    
	                                   EVENT_STATUS_CODE   VARCHAR2(1),
	                                   PROCESS_STATUS_CODE VARCHAR2(1)
	                                       )';
   EXCEPTION
     WHEN OTHERS THEN
      l_message := 'EXCEPTION :: '||SQLERRM ||
                  ' in creating ap_prob_pay_events_8526084';
      FND_File.Put_Line(fnd_file.output,l_message);
	
    
   END;

    Begin
    Execute Immediate
      'CREATE TABLE ap_prob_pay_history_8526084(
	                                  PAYMENT_HISTORY_ID   NUMBER(15),
                                          CHECK_ID             NUMBER(15),                                                                                                                                                                                    
	                                  ACCOUNTING_DATE      DATE,
	                                  TRANSACTION_TYPE     VARCHAR2(30),                                                                                                                                                                                        
	                                  POSTED_FLAG          VARCHAR2(1),                    
	                                  ACCOUNTING_EVENT_ID  NUMBER(15),
	                                  ORG_ID               NUMBER(15),
	                                  REV_PMT_HIST_ID      NUMBER(15),
	                                  TRX_BANK_AMOUNT      NUMBER,
	                                  TRX_PMT_AMOUNT       NUMBER,
	                                  RELATED_EVENT_ID     NUMBER(15),
	                                  HISTORICAL_FLAG      VARCHAR2(1)
	)';
   EXCEPTION
     WHEN OTHERS THEN
       dbms_output.put_line('could not create ap_prob_pay_history_8526084'
	   ||sqlerrm );
   END;

  BEGIN
    Execute Immediate
      'Insert into ap_temp_data_driver_8526084
      (
        CHECK_ID,
        BANK_ACCOUNT_ID,                                                                                                                                                                                    
	BANK_ACCOUNT_NAME,
	AMOUNT,                                                                                                                                                                                        
	CHECK_NUMBER,                    
	CHECK_DATE,
	CURRENCY_CODE,
	CLEARED_DATE,
	CLEARED_AMOUNT,
	VOID_DATE
      )
     (SELECT DISTINCT ac.check_id,
		      ac.bank_account_id,
		      ac.bank_account_name,
		      ac.amount,
		      ac.check_number,
		      ac.check_date,
		      ac.currency_code,
		      ac.cleared_date,
		      ac.cleared_amount,
		      ac.void_date
      FROM            ap_checks_all ac,
                      ap_payment_history_all aph,
                      xla_events xe
      WHERE aph.check_id = ac.check_id
      AND   aph.accounting_event_id = xe.event_id 
      AND   ac.void_date IS NOT NULL
      AND   ac.status_lookup_code = ''VOIDED''
      AND   nvl(aph.posted_flag, ''N'') = ''Y''
      AND   nvl(xe.event_status_code, ''U'') = ''P''
      AND   nvl(xe.process_status_code, ''U'') = ''P''
      AND   xe.application_id = 200
      AND   aph.transaction_type IN (''PAYMENT CANCELLED'', ''REFUND CANCELLED'')
      AND   EXISTS (SELECT ''unaccounted non-cancelled event''
                    FROM    ap_payment_history_all aph
                    WHERE   aph.check_id = ac.check_id
		    AND     aph.transaction_type NOT IN (''PAYMENT CANCELLED'', ''REFUND CANCELLED'')
                    AND nvl(aph.posted_flag, ''N'') <> ''Y''
                    )
     )';
  EXCEPTION
     WHEN OTHERS THEN
      l_message := 'EXCEPTION :: '||SQLERRM ||
                  ' in inserting in ap_prob_pay_events_8526084';
      FND_File.Put_Line(fnd_file.output,l_message);
	
  END;   

  BEGIN
    Execute Immediate
     'Insert into ap_prob_pay_events_8526084
      (
        EVENT_ID,
        APPLICATION_ID,                                                                                                                                                                                    
	EVENT_TYPE_CODE,
	EVENT_DATE,                                                                                                                                                                                        
	ENTITY_ID,                    
	EVENT_STATUS_CODE,
	PROCESS_STATUS_CODE
      )
     (SELECT DISTINCT xe.EVENT_ID,
		      xe.APPLICATION_ID,
		      xe.EVENT_TYPE_CODE,
		      xe.EVENT_DATE,
		      xe.ENTITY_ID,
		      xe.EVENT_STATUS_CODE,
		      xe.PROCESS_STATUS_CODE
      FROM            xla_events xe
      WHERE  xe.application_id =200
      AND    xe.event_id IN (SELECT DISTINCT accounting_event_id
                             FROM            ap_payment_history_all aph,
                                             ap_temp_data_driver_8526084 atdd
                             WHERE aph.check_id = atdd.check_id
                             AND   nvl(aph.posted_flag, ''N'') <> ''Y'' )
      AND   nvl(xe.event_status_code, ''U'') <> ''P''
      AND   nvl(xe.process_status_code, ''U'') <> ''P''
     )';
  EXCEPTION
     WHEN OTHERS THEN
      l_message := 'EXCEPTION :: '||SQLERRM ||
                  ' in inserting in ap_prob_pay_events_8526084';
      FND_File.Put_Line(fnd_file.output,l_message);

  END; 

Begin
    Execute Immediate
     'Insert into ap_prob_pay_history_8526084
      (
        PAYMENT_HISTORY_ID,
	CHECK_ID,
	ACCOUNTING_DATE,
	TRANSACTION_TYPE,
	POSTED_FLAG,
	ACCOUNTING_EVENT_ID,
	ORG_ID,
	REV_PMT_HIST_ID,
	TRX_BANK_AMOUNT,
	TRX_PMT_AMOUNT,
	RELATED_EVENT_ID,
	HISTORICAL_FLAG
      )
     (SELECT distinct aph.PAYMENT_HISTORY_ID,
		      aph.CHECK_ID,
		      aph.ACCOUNTING_DATE,
		      aph.TRANSACTION_TYPE,
		      aph.POSTED_FLAG,
		      aph.ACCOUNTING_EVENT_ID,
		      aph.ORG_ID,
		      aph.REV_PMT_HIST_ID,
		      aph.TRX_BANK_AMOUNT,
		      aph.TRX_PMT_AMOUNT,
		      aph.RELATED_EVENT_ID,
		      aph.HISTORICAL_FLAG
      FROM   ap_payment_history_all aph   
      WHERE  aph.check_id IN (SELECT DISTINCT atdd.check_id
                          FROM ap_temp_data_driver_8526084 atdd)
      AND    nvl(aph.posted_flag, ''N'') <> ''Y'' 
     )';
  EXCEPTION
     WHEN OTHERS THEN
      l_message := 'EXCEPTION :: '||SQLERRM ||
                  ' in inserting in ap_prob_pay_history_8526084';
      FND_File.Put_Line(fnd_file.output,l_message);
	
  END; 

  ------------------------------------------------------------------
  -- Step 3: Report all the affected transactions in Log file 
  ---------------------------------------------------------------------
  BEGIN
  Execute Immediate  
      'SELECT COUNT(*) FROM ap_temp_data_driver_8526084' into l_count;
  EXCEPTION
     WHEN OTHERS THEN
      l_message := 'EXCEPTION :: '||SQLERRM ||
                  ' in counting date from ap_temp_data_driver_8526084';
      FND_File.Put_Line(fnd_file.output,l_message);
	
   END; 

    IF (l_count > 0) THEN 
      AP_Acctg_Data_Fix_PKG.Print('******* Details of the voided checks'||
	  'where Accounting is not created properly for a refund payment'||
	'.Please follow note 874705.1 *******');            
    BEGIN
      AP_Acctg_Data_Fix_PKG.Print_html_table                           
       ('CHECK_ID,BANK_ACCOUNT_ID,BANK_ACCOUNT_NAME,AMOUNT,'||                                                                                                                                                                                        
	'CHECK_NUMBER,CHECK_DATE,CURRENCY_CODE,CLEARED_DATE,'||
	'CLEARED_AMOUNT,VOID_DATE',
	'ap_temp_data_driver_8526084',
	NULL,
        'ap_acctd_PayCncl_rev_event_sel.sql');                                              
    EXCEPTION                                                          
       WHEN OTHERS THEN
        l_message := 'EXCEPTION :: '||SQLERRM ||
	             'in call to AP_Acctg_Data_Fix_PKG.Print_html_table '||
                     ' during printing data from ap_temp_data_driver_8526084';
        FND_File.Put_Line(fnd_file.output,l_message);
	
    END;
    
END IF;

  BEGIN
  Execute Immediate  
      'SELECT COUNT(*) FROM ap_prob_pay_events_8526084' into l_count1;
  EXCEPTION
      WHEN OTHERS THEN
        l_message := 'EXCEPTION :: '||SQLERRM ||
                  ' in counting data from ap_prob_pay_events_8526084';
        FND_File.Put_Line(fnd_file.output,l_message);
	
  END; 

    IF (l_count1 > 0) THEN 
      AP_Acctg_Data_Fix_PKG.Print('******* Details of the unacctd events '||
	'in XLA_EVENTS where Accounting is not created properly for a refund payment.Please follow note 874705.1 *******');            
    BEGIN
      AP_Acctg_Data_Fix_PKG.Print_html_table                           
       ('EVENT_ID,APPLICATION_ID,EVENT_TYPE_CODE,EVENT_DATE,'||                                                                                                                                                                                        
	'ENTITY_ID,EVENT_STATUS_CODE,PROCESS_STATUS_CODE',
        'ap_prob_pay_events_8526084',
	NULL,
        'ap_acctd_PayCncl_rev_event_sel.sql');                                              
    EXCEPTION                                                          
       WHEN OTHERS THEN
        l_message := 'EXCEPTION :: '||SQLERRM ||
                     'in call to AP_Acctg_Data_Fix_PKG.Print_html_table '||
		     'during printing data from ap_prob_pay_events_8526084';
        FND_File.Put_Line(fnd_file.output,l_message);
	
    END;
    END IF;


  BEGIN
  Execute Immediate  
      'SELECT COUNT(*) FROM ap_prob_pay_history_8526084' into l_count1;
   EXCEPTION
     WHEN OTHERS THEN
      l_message := 'EXCEPTION :: '||SQLERRM ||
                  ' in counting data from ap_prob_pay_history_8526084';
      FND_File.Put_Line(fnd_file.output,l_message);
	
  END; 
 
    IF (l_count1 > 0) THEN 
      AP_Acctg_Data_Fix_PKG.Print('******* Details of the  '||
	'selecting affected pay hist in AP_PAYMENT_HISTORY_ALL.Please follow note 874705.1 *******');            
    BEGIN
      AP_Acctg_Data_Fix_PKG.Print_html_table                           
       ('PAYMENT_HISTORY_ID,CHECK_ID,ACCOUNTING_DATE,TRANSACTION_TYPE,'||
	'POSTED_FLAG,ACCOUNTING_EVENT_ID,ORG_ID,REV_PMT_HIST_ID,'||
	'TRX_BANK_AMOUNT,TRX_PMT_AMOUNT,RELATED_EVENT_ID,HISTORICAL_FLAG',
        'ap_prob_pay_history_8526084',
	 NULL,
        'ap_acctd_PayCncl_rev_event_sel.sql');                                              
    EXCEPTION                                                          
       WHEN OTHERS THEN
        l_message := 'EXCEPTION :: '||SQLERRM ||
                     'in call to AP_Acctg_Data_Fix_PKG.Print_html_table '||
		     'during printing data from ap_prob_pay_history_8526084';
        FND_File.Put_Line(fnd_file.output,l_message);
	
    END;
    

    ELSE
        l_message :=  'No Checks are there with this issue ';
        AP_Acctg_Data_Fix_PKG.Print(l_message);
    END IF;
	
	
 /*+=======================================================================+
 | FILENAME                                                              |
 |     ap_inv_event_status_code_sel.sql                              |
 |                                                                       |
 | DESCRIPTION                                                           |
 |     This script is used to generate reports for all records in        |
 |     xla_events that have invalid event_status_code                    |
 | HISTORY Created by zrehman on 21-April-2008                           |
 +=======================================================================+*/
 
 BEGIN
 
  

  Begin
    Execute Immediate
      'Drop table ap_temp_data_driver_6992111';

  EXCEPTION
    WHEN OTHERS THEN
    AP_Acctg_Data_Fix_PKG.Print('could not delete ap_temp_data_driver_6992111'
	   ||sqlerrm);
  END;


  Begin
    Execute Immediate
      'CREATE TABLE ap_temp_data_driver_6992111(
	    Event_Status_Code VARCHAR2(1),
        event_id NUMBER(15),
        ENTITY_CODE VARCHAR2(30),
        SOURCE_ID NUMBER(15)
    )';
  EXCEPTION
     WHEN OTHERS THEN
       AP_Acctg_Data_Fix_PKG.Print('could not create ap_temp_data_driver_6992111'
	   ||sqlerrm);
   END;
   
    
 /*********  INCOMPLETE EVENT_STATUS_CODE IN XLA_EVENTS TABLE  **********/

  Begin
    Execute Immediate
     'Insert into ap_temp_data_driver_6992111
          (
           event_id,
           event_status_code,
           entity_code,
           source_id
           )
     (SELECT xe.event_id, xe.event_status_code,xte.ENTITY_CODE,
             xte.source_id_int_1 source_id
	    FROM xla_events xe,
                 xla_transaction_entities_upg xte
       WHERE xte.entity_id=xe.entity_id
         AND xte.application_id=200
         AND xe.application_id=200
         AND xe.event_status_code=''I''
         AND NOT exists 
		         (
                 SELECT 1 
		 FROM ap_holds_all AH
		 WHERE invoice_id=xte.source_id_int_1 
		 AND xte.ENTITY_CODE=''AP_INVOICES''
                 AND AH.RELEASE_LOOKUP_CODE is null
                 )
         AND NOT EXISTS
		(
                 select 1 
		 from ap_holds_all AH
		 where invoice_id IN 
                        (SELECT INVOICE_ID 
			 FROM AP_INVOICE_PAYMENTS_ALL AIP 
                         WHERE AIP.CHECK_ID=xte.source_id_int_1 
			 AND AH.RELEASE_LOOKUP_CODE is null
                         AND xte.ENTITY_CODE=''AP_PAYMENTS''
                          )
		)
     )';
  EXCEPTION
     WHEN OTHERS THEN
          AP_Acctg_Data_Fix_PKG.Print('Exception in inserting records into '|| 
		                       'ap_temp_data_driver_6992111 - '||SQLERRM);
  END;     

  ------------------------------------------------------------------
  -- Step 3: Report all the affected events in Log file 
  ---------------------------------------------------------------------
  Begin
    Execute Immediate 
    'SELECT count(*) 
    FROM ap_temp_data_driver_6992111' INTO l_count;
  EXCEPTION
     WHEN OTHERS THEN
          AP_Acctg_Data_Fix_PKG.Print('Exception in getting count from '|| 
		                       'ap_temp_data_driver_6992111 - '||SQLERRM);
  End;  

  IF (l_count > 0) THEN 
    AP_Acctg_Data_Fix_PKG.Print('******* Events with incomplete'||
	 'event status after Invoice/Payment events that can not be accounted'||
	 'after all holds are released . Please follow the GDF Note 742429.1 *******');            
    BEGIN
      AP_Acctg_Data_Fix_PKG.Print_html_table                           
       ('EVENT_ID,ENTITY_CODE,SOURCE_ID,EVENT_STATUS_CODE',
        'ap_temp_data_driver_6992111',                                
        null,                                                         
        'ap_inv_event_status_code_sel.sql');                                              
    EXCEPTION                                                          
       WHEN OTHERS THEN
       NULL;
    END;
  END IF;

End;
  
/*=======================================================================+
 | FILENAME                                                              |
 |     ap_Orphan_Events_Sel.sql                                          |
 |                                                                       |
 | DESCRIPTION                                                           |
 |     This script will detect and show the processed and unprocessed    |
 |     orphan events in xla_events that do not have any corresponding    |
 |     records in ap transaction tables                                  |
 | HISTORY Created by zrehman on 23-April-2008                           |
 +=======================================================================*/
 
 
  --------------------------------------------------------------------------
  -- Step 1: Drop the temporary tables if already exists
  --------------------------------------------------------------------------
  
  Begin
    Execute Immediate
      'Drop table ap_temp_data_driver_6992095';

  EXCEPTION
    WHEN OTHERS THEN
      AP_Acctg_Data_Fix_PKG.Print('could not delete ap_temp_data_driver_6992095'
	   ||sqlerrm );
  END;


  Begin
    Execute Immediate
      'CREATE TABLE ap_temp_data_driver_6992095(
	ORPHAN_TYPE VARCHAR2(10), 
	EVENT_ID NUMBER(15),
        EVENT_STATUS_CODE VARCHAR2(1),
        PROCESS_STATUS_CODE VARCHAR2(1),
        AE_HEADER_ID NUMBER(15),
        source_id NUMBER(15),
	source_table VARCHAR2(30),
	INVOICE_NUM_OR_CHECK_NUMBER VARCHAR2(50),
	event_date date,
        ENTITY_ID NUMBER,
        EVENT_TYPE_CODE VARCHAR2(30),
        BUDGETARY_CONTROL_FLAG VARCHAR2(1),
        UPG_BATCH_ID NUMBER(15,0),
	process_flag VARCHAR2(1) default ''Y''
    )';
  EXCEPTION
     WHEN OTHERS THEN
         AP_Acctg_Data_Fix_PKG.Print('could not create ap_temp_data_driver_6992095'
	   ||sqlerrm );
   END;
--The upg_batch_id is populated for upgraded events and upgraded events may require more work e.g. delete from R11i tables too
--And upg_batch_id is populated with -5672 for AX events and these rows may need other fix then delete.
--And upg_batch_id is also populated with -9999 for Manual entries.   
--hence given the check that upg_batch_id is NULL
    
 /*********  UNPROCESSED ORPHAN EVENTS IN XLA_EVENTS   **********/
  Begin
    Execute Immediate
     'Insert into ap_temp_data_driver_6992095
          (
            ORPHAN_TYPE,
	    EVENT_ID,
	    EVENT_STATUS_CODE,
            PROCESS_STATUS_CODE,
	    AE_HEADER_ID,
            source_id,
	    source_table,
	    INVOICE_NUM_OR_CHECK_NUMBER,
	    event_date,
            entity_id,
            event_type_code,
            budgetary_control_flag,
            upg_batch_id,
	    process_flag
           )
     (SELECT DISTINCT ''EVENT'', xe.EVENT_ID,xe.EVENT_STATUS_CODE,xe.PROCESS_STATUS_CODE,
             xah.ae_header_id, xte.source_id_int_1 SOURCE_ID, 
	     xte.entity_code source_table,
             (case
              when xte.entity_code=''AP_INVOICES'' then
                                       (select invoice_num 
                                                      from ap_invoices_all ai
                                         where ai.invoice_id = xte.source_id_int_1)
              when xte.entity_code=''AP_PAYMENTS'' then
                                       (select to_char(check_number) 
                                                      from ap_checks_all ac,
                                                           ap_invoice_payments_all aip
                                         where ac.check_id = aip.check_id
                                               and ac.check_id = xte.source_id_int_1
                                               and rownum = 1)
              end
                          ) INVOICE_NUM_OR_CHECK_NUMBER,
              xe.event_date,
              xe.entity_id,
              xe.event_type_code,
              xe.budgetary_control_flag,
              xe.upg_batch_id,
              ''Y''
        FROM xla_events xe,
             xla_transaction_entities_upg xte,
             xla_ae_headers xah
       WHERE xe.application_id = xte.application_id
         AND xe.event_status_code <> ''P''
         and xe.event_id = xah.event_id (+)
         and xah.application_id(+) = xe.application_id
         AND xte.entity_id=xe.entity_id
         AND xte.application_id=200
         AND NOT EXISTS
             (SELECT ''No Invoice rows exist for this event''
                FROM ap_invoice_distributions_all aid
               WHERE aid.accounting_event_id = xe.event_id)
         AND NOT EXISTS
             (SELECT ''No Distributions exist for the bc_event_id''
                FROM ap_invoice_distributions_all aid
               WHERE aid.bc_event_id = xe.event_id)
         AND NOT EXISTS
             (SELECT ''No payment rows exist for this event''
                FROM ap_invoice_payments_all aip
               WHERE aip.accounting_event_id = xe.event_id)
         AND NOT EXISTS
             (SELECT ''No payment history rows exists for this event''
                FROM ap_payment_history_all aph
               WHERE aph.accounting_event_id = xe.event_id)
         AND NOT EXISTS
             (SELECT ''No self assessed tax rows exists for this event''
                FROM ap_self_assessed_tax_dist_all asatd
               WHERE asatd.accounting_event_id = xe.event_id)
         AND    NOT EXISTS
             (SELECT ''No self assessed tax rows exists for the bc_event_id''
              FROM   ap_self_assessed_tax_dist_all asatd
              WHERE  asatd.bc_event_id = xe.event_id)
         AND NOT EXISTS
             (SELECT ''No prepay history rows exists for this event''
                FROM ap_prepay_history_all aprh
               WHERE aprh.accounting_event_id = xe.event_id)
         AND NOT EXISTS
             (SELECT ''No prepayment history rows exists for the bc_event_id''
              FROM   ap_prepay_history_all apph
              WHERE  apph.bc_event_id = xe.event_id)
         AND xe.event_type_code not in (''MANUAL'', ''REVERSAL'')
         AND (xe.upg_batch_id is NULL or xe.upg_batch_id = -9999) 
         AND NOT EXISTS
             (SELECT ''No final accounted headers''
              FROM   xla_ae_headers xah
              WHERE  xah.event_id = xe.event_id
              AND    xah.application_id=200
              AND    xah.entity_id = xte.entity_id
              AND    xah.accounting_entry_status_code=''F''
              AND    xah.gl_transfer_status_code=''Y'')
      UNION
      SELECT DISTINCT ''HEADER'', xah.EVENT_ID,null,null,
             xah.ae_header_id, xte.source_id_int_1 SOURCE_ID, 
	     xte.entity_code source_table,
             (case
              when xte.entity_code=''AP_INVOICES'' then
                                       (select invoice_num 
                                                      from ap_invoices_all ai
                                         where ai.invoice_id = xte.source_id_int_1)
              when xte.entity_code=''AP_PAYMENTS'' then
                                       (select to_char(check_number) 
                                                      from ap_checks_all ac,
                                                           ap_invoice_payments_all aip
                                         where ac.check_id = aip.check_id
                                           and ac.check_id = xte.source_id_int_1
                                           and rownum = 1)
              end
                          ) INVOICE_NUM_OR_CHECK_NUMBER,
              xah.accounting_date,
              xah.entity_id,
              xah.event_type_code,
              null,
              xah.upg_batch_id,
              ''Y''
        FROM xla_transaction_entities_upg xte,
             xla_ae_headers xah
       WHERE xah.application_id = xte.application_id
         AND xte.entity_id=xah.entity_id
         AND xte.application_id=200
         AND NOT EXISTS
             (SELECT ''No Invoice rows exist for this event''
                FROM ap_invoice_distributions_all aid
               WHERE aid.accounting_event_id = xah.event_id)
         AND NOT EXISTS
             (SELECT ''No Distributions exist for the bc_event_id''
                FROM ap_invoice_distributions_all aid
               WHERE aid.bc_event_id = xah.event_id)
         AND NOT EXISTS
             (SELECT ''No payment rows exist for this event''
                FROM ap_invoice_payments_all aip
               WHERE aip.accounting_event_id = xah.event_id)
         AND NOT EXISTS
             (SELECT ''No payment history rows exists for this event''
                FROM ap_payment_history_all aph
               WHERE aph.accounting_event_id = xah.event_id)
         AND NOT EXISTS
             (SELECT ''No self assessed tax rows exists for this event''
                FROM ap_self_assessed_tax_dist_all asatd
               WHERE asatd.accounting_event_id = xah.event_id)
         AND    NOT EXISTS
             (SELECT ''No self assessed tax rows exists for the bc_event_id''
              FROM   ap_self_assessed_tax_dist_all asatd
              WHERE  asatd.bc_event_id = xah.event_id)
         AND NOT EXISTS
             (SELECT ''No prepay history rows exists for this event''
                FROM ap_prepay_history_all aprh
               WHERE aprh.accounting_event_id = xah.event_id)
         AND NOT EXISTS
             (SELECT ''No prepayment history rows exists for the bc_event_id''
              FROM   ap_prepay_history_all apph
              WHERE  apph.bc_event_id = xah.event_id)
	 AND NOT EXISTS 
	      (SELECT '' Event for this header does not exist''
	         FROM xla_events xe
		WHERE xe.application_id = xah.application_id
		  AND xe.event_id = xah.event_id)
         AND xah.event_type_code not in (''MANUAL'', ''REVERSAL'')
         AND (xah.upg_batch_id is NULL or xah.upg_batch_id = -9999) 
         AND nvl(xah.gl_transfer_status_code, ''X'') <>''Y''
	 AND nvl(xah.accounting_entry_status_code, ''X'') <> ''F''
     )';
  EXCEPTION
     WHEN OTHERS THEN
       AP_Acctg_Data_Fix_PKG.Print
               ('Exception in inserting records into '|| 
		'ap_temp_data_driver_6992095 for unprocessed '||
		' orphan events - '||SQLERRM );
  END;    
  
 /*********  PROCESSED ORPHAN EVENTS IN XLA_EVENTS   **********/  
    Begin
    Execute Immediate
     'Insert into ap_temp_data_driver_6992095
          (
            ORPHAN_TYPE,
	    EVENT_ID,
	    EVENT_STATUS_CODE,
	    PROCESS_STATUS_CODE,
	    AE_HEADER_ID,
            source_id,
	    source_table,
	    INVOICE_NUM_OR_CHECK_NUMBER,
	    event_date,
            entity_id,
            event_type_code,
            budgetary_control_flag,
            upg_batch_id,   
	    process_flag
           )
     (SELECT DISTINCT ''EVENT'', xe.EVENT_ID,xe.EVENT_STATUS_CODE,xe.PROCESS_STATUS_CODE,
             xah.ae_header_id, xte.source_id_int_1 SOURCE_ID, 
	     xte.entity_code source_table,
             (case 
              when xte.entity_code=''AP_INVOICES'' then 
			               (select invoice_num 
					  from ap_invoices_all ai
			                 where ai.invoice_id = xte.source_id_int_1)
	      when xte.entity_code=''AP_PAYMENTS'' then 
			               (select to_char(check_number) 
		                          from ap_checks_all ac, 
					       ap_invoice_payments_all aip
			                 where ac.check_id = aip.check_id
				           and ac.check_id = xte.source_id_int_1
					   and rownum = 1)
              end
			  ) INVOICE_NUM_OR_CHECK_NUMBER,
			  xe.event_date,
              xe.entity_id,
              xe.event_type_code,
              xe.budgetary_control_flag,
              xe.upg_batch_id,     
             ''Y''
        FROM xla_events xe,
             xla_transaction_entities_upg xte,
             xla_ae_headers xah
       WHERE xe.application_id = 200
         AND xe.event_status_code = ''P''
	 AND xah.application_id = 200
	 AND xah.event_id = xe.event_id
         AND xte.entity_id=xe.entity_id
         AND xte.application_id=200
         AND NOT EXISTS
             (SELECT ''No Invoice rows exist for this event''
                FROM ap_invoice_distributions_all aid
               WHERE aid.accounting_event_id = xe.event_id)
         AND NOT EXISTS
             (SELECT ''No Distributions exist for the bc_event_id''
                FROM ap_invoice_distributions_all aid
               WHERE aid.bc_event_id = xe.event_id)
         AND NOT EXISTS
             (SELECT ''No payment rows exist for this event''
                FROM ap_invoice_payments_all aip
               WHERE aip.accounting_event_id = xe.event_id)
         AND NOT EXISTS
             (SELECT ''No payment history rows exists for this event''
                FROM ap_payment_history_all aph
               WHERE aph.accounting_event_id = xe.event_id)
	 AND NOT EXISTS
             (SELECT ''No self assessed tax rows exists for this event''
                FROM ap_self_assessed_tax_dist_all asatd
               WHERE asatd.accounting_event_id = xe.event_id)
         AND    NOT EXISTS
             (SELECT ''No self assessed tax rows exists for the bc_event_id''
              FROM   ap_self_assessed_tax_dist_all asatd
              WHERE  asatd.bc_event_id = xe.event_id)
	 AND NOT EXISTS
             (SELECT ''No prepay history rows exists for this event''
                FROM ap_prepay_history_all aprh
               WHERE aprh.accounting_event_id = xe.event_id)
         AND NOT EXISTS
             (SELECT ''No prepayment history rows exists for the bc_event_id''
              FROM   ap_prepay_history_all apph
              WHERE  apph.bc_event_id = xe.event_id)
         AND xe.event_type_code not in (''MANUAL'', ''REVERSAL'') 
	 AND (xe.upg_batch_id is NULL or xe.upg_batch_id = -9999)
     )';
  EXCEPTION
     WHEN OTHERS THEN
         AP_Acctg_Data_Fix_PKG.Print(
	        'Exception in inserting records into '|| 
		'ap_temp_data_driver_6992095 for processed '||
		' orphan events - '||SQLERRM );
  END; 
  
  ------------------------------------------------------------------
  -- Step 3: Report all the affected transactions in Log file 
  ---------------------------------------------------------------------
  Begin
  Execute Immediate  
      'SELECT count(*) 
         FROM ap_temp_data_driver_6992095
        WHERE nvl(event_status_code, ''U'') <> ''P'' ' INTO l_count;
  EXCEPTION
     WHEN OTHERS THEN
           AP_Acctg_Data_Fix_PKG.Print(
	        'Exception in selecting count from '|| 
		'ap_temp_data_driver_6992095 for unprocessed '||
		' orphan events - '||SQLERRM );
  END; 

  IF (l_count > 0) THEN 
    AP_Acctg_Data_Fix_PKG.Print('******* Details of the unprocessed orphan '||
	'events/headers in XLA_EVENTS/XLA_AE_HEADERS.Please follow the GDF  Note 788135.1*******');            
    BEGIN
      AP_Acctg_Data_Fix_PKG.Print_html_table                           
       ('ORPHAN_TYPE,EVENT_ID,EVENT_STATUS_CODE,PROCESS_STATUS_CODE,'||
        'EVENT_DATE,AE_HEADER_ID,'||
	'SOURCE_ID,SOURCE_TABLE,INVOICE_NUM_OR_CHECK_NUMBER,'||
        'ENTITY_ID,EVENT_TYPE_CODE,BUDGETARY_CONTROL_FLAG',
        'ap_temp_data_driver_6992095',                                
        'WHERE nvl(EVENT_STATUS_CODE, ''U'' ) <>''P''',                                                         
        'ap_Orphan_Events_Sel.sql');                                              
    EXCEPTION                                                          
       WHEN OTHERS THEN
           AP_Acctg_Data_Fix_PKG.Print(
	        'Exception in call to AP_Acctg_Data_Fix_PKG.Print_html_table'||
		' for unprocessed orphan events - '||SQLERRM);
    END;
  END IF;

 
  Begin
    Execute Immediate 
        'SELECT count(*) 
          FROM ap_temp_data_driver_6992095
         WHERE event_status_code = ''P'' ' INTO l_count;
  EXCEPTION
     WHEN OTHERS THEN
         AP_Acctg_Data_Fix_PKG.Print(
	        'Exception in selecting count from '|| 
		'ap_temp_data_driver_6992095 for processed '||
		' orphan events - '||SQLERRM);
  END;

  IF (l_count > 0) THEN 
    AP_Acctg_Data_Fix_PKG.Print('******* Details of the processed orphan '||
	'events in XLA_EVENTS.Please follow the GDF  Note 788135.1*******');            
    BEGIN
      AP_Acctg_Data_Fix_PKG.Print_html_table                           
       ('ORPHAN_TYPE,EVENT_ID,EVENT_STATUS_CODE,PROCESS_STATUS_CODE,'||
        'EVENT_DATE,AE_HEADER_ID,'||
	'SOURCE_ID,SOURCE_TABLE,INVOICE_NUM_OR_CHECK_NUMBER,'||
        'ENTITY_ID,EVENT_TYPE_CODE,BUDGETARY_CONTROL_FLAG',
        'ap_temp_data_driver_6992095',                                
        'WHERE EVENT_STATUS_CODE = ''P''',                                                         
        'ap_Orphan_Events_Sel.sql');                                              
    EXCEPTION                                                          
       WHEN OTHERS THEN
           AP_Acctg_Data_Fix_PKG.Print(
	        'Exception in call to AP_Acctg_Data_Fix_PKG.Print_html_table'||
		' for processed orphan events - '||SQLERRM);
    END;
  END IF;
  
  
   /*+=======================================================================+
 | FILENAME                                                              |
 |     ap_PayAdjWrongRelEvtId_Sel.sql                                    |
 |                                                                       |
 | DESCRIPTION                                                           |
 |     This script will detect and show the Adjusted Payment events that |
 |     have wrong related event id populated. The value for the same is  |
 |     the accounting_event_id of the same transaction                   |
 | HISTORY Created by zrehman on 19-May-2009                             |
 +=======================================================================+*/
 
 -------------------------------------------------------------------------
  -- Step 1: Drop the temporary tables if already exists
  --------------------------------------------------------------------------
  
  Begin
    Execute Immediate
      'Drop table ap_temp_data_driver_8529749';
  EXCEPTION
    WHEN OTHERS THEN
      FND_File.Put_Line(fnd_file.output,'could not delete '||
                        'ap_temp_data_driver_8529749->' ||sqlerrm );
  END;

  Begin
    Execute Immediate
      'Drop table ap_temp_data_undo_8529749';
  EXCEPTION
    WHEN OTHERS THEN
      FND_File.Put_Line(fnd_file.output,'could not delete '||
                        'ap_temp_data_undo_8529749->' ||sqlerrm );
  END;


  Begin
    Execute Immediate
      'CREATE TABLE ap_temp_data_driver_8529749(
        PAYMENT_HISTORY_ID      NUMBER(15),
	CHECK_ID                NUMBER(15),
	CHECK_NUMBER            VARCHAR2(50),
	TRANSACTION_TYPE        VARCHAR2(50), 
	POSTED_FLAG             VARCHAR2(1), 
	ORG_ID                  NUMBER(15),
	HISTORICAL_FLAG         VARCHAR2(1),
	EVENT_ID                NUMBER(15),
        EVENT_TYPE_CODE         VARCHAR2(30),
        EVENT_STATUS_CODE       VARCHAR2(1),
        PROCESS_STATUS_CODE     VARCHAR2(1),
        EVENT_DATE              DATE,
	OLD_RELATED_EVENT_ID    NUMBER,
	NEW_RELATED_EVENT_ID    NUMBER,
        UPG_BATCH_ID            NUMBER(15,0),
	PROCESS_FLAG            VARCHAR2(1) DEFAULT ''Y''
    )';
  EXCEPTION
     WHEN OTHERS THEN
       FND_File.Put_Line(fnd_file.output,'could not create '||
                         'ap_temp_data_driver_8529749 ->'||sqlerrm );
  END;

  ------------------------------------------------------------------
  -- Step 2: Insert all affected transactions in temporary table 
  ------------------------------------------------------------------

  /*******  PAYMENT TRANSACTIONS WITH INCORRECT RELATED EVENT ID  ******/
  Begin
    Execute Immediate
     'Insert into ap_temp_data_driver_8529749
          (
            PAYMENT_HISTORY_ID,
	    CHECK_ID,
            CHECK_NUMBER,
	    TRANSACTION_TYPE,
	    POSTED_FLAG,
	    ORG_ID,
	    HISTORICAL_FLAG,
	    EVENT_ID,
            EVENT_TYPE_CODE,
            EVENT_STATUS_CODE,
            PROCESS_STATUS_CODE,
            EVENT_DATE,
	    OLD_RELATED_EVENT_ID,
            UPG_BATCH_ID,
	    PROCESS_FLAG
           )
          (SELECT DISTINCT 
                  aph.payment_history_id, aph.check_id, ac.check_number, 
                  aph.transaction_type, aph.posted_flag, ac.org_id,
	          aph.historical_flag,xe.event_id, xe.event_type_code, 
                  xe.event_status_code, xe.process_status_code, xe.event_date,
	          aph.related_event_id, xe.upg_batch_id, ''Y''
            FROM ap_payment_history_all aph,
	         xla_events xe,
	         ap_checks_all ac
           WHERE aph.transaction_type LIKE ''%ADJUSTED''
             AND nvl(aph.historical_flag, ''N'') = ''N''
             AND (aph.accounting_event_id = aph.related_event_id 
	      OR  aph.related_event_id is NULL )
	     AND aph.accounting_event_id = xe.event_id
	     AND xe.application_id = 200
	     AND aph.check_id = ac.check_id
          )';
  EXCEPTION
     WHEN OTHERS THEN
       FND_File.Put_Line(fnd_file.output,'Exception in inserting records into '|| 
	                 'ap_temp_data_driver_8529749 for affected '||
	                 ' transactions - '||SQLERRM );
  END;    

  /*******  PAYMENT TRANSACTIONS WITH INCORRECT RELATED EVENT ID  ******/
  /*******  FOR WHICH UNDO ACCOUNTING IS REQUIRED                 ******/
  Begin
    Execute Immediate
     'CREATE Table ap_temp_data_undo_8529749
	AS
          (SELECT DISTINCT *
             FROM ap_temp_data_driver_8529749 temp
            WHERE temp.posted_flag = ''Y''
	      AND temp.event_status_code = ''P''
          )';
  EXCEPTION
     WHEN OTHERS THEN
       FND_File.Put_Line(fnd_file.output,'Exception in inserting records '|| 
	                 'into ap_temp_data_undo_8529749 for affected '||
	                 ' transactions - '||SQLERRM );
  END;    
  
  ------------------------------------------------------------------
  -- Step 3: Report all the affected transactions in Log file 
  ------------------------------------------------------------------
  /** DISPLAY UNACCOUNTED AFFECTED PAYMENT ADJUSTED TRANSACTIONS **/
  Begin
    Execute Immediate  
      'SELECT count(*) 
         FROM ap_temp_data_driver_8529749
        WHERE event_status_code <> ''P'' ' 
         INTO l_count;
  EXCEPTION
     WHEN OTHERS THEN
          FND_File.Put_Line(fnd_file.output,'Exception in selecting count from'|| 
		            ' ap_temp_data_driver_8529749 for unprocessed'||
			    ' payment transactions ->'||SQLERRM );
  END; 

  IF (l_count > 0) THEN 
    AP_ACCTG_DATA_FIX_PKG.Print('******* Details of the unprocessed payment '||
	'adjusted transactions with incorrect related_event_id. Please follow the GDF Note 874710.1*******');            
    BEGIN
      AP_Acctg_Data_Fix_PKG.Print_html_table                           
       ('CHECK_NUMBER,TRANSACTION_TYPE,CHECK_ID,PAYMENT_HISTORY_ID,OLD_RELATED_EVENT_ID,'||
	'POSTED_FLAG,ORG_ID,EVENT_ID,EVENT_TYPE_CODE,'||
        'EVENT_STATUS_CODE,PROCESS_STATUS_CODE,EVENT_DATE,'||
        'PROCESS_FLAG',
        'ap_temp_data_driver_8529749',                                
        'WHERE EVENT_STATUS_CODE<>''P''',                                                         
        'ap_PayAdjWrongRelEvtId_Sel.sql');                                              
    EXCEPTION                                                          
      WHEN OTHERS THEN
        FND_File.Put_Line(fnd_file.output,'Exception in call to '||
	                 'AP_Acctg_Data_Fix_PKG.Print_html_table for printing'
                         ||' unprocessed adjusted transactions with incorrect'
                         ||' related_event_id ->'||SQLERRM);
    END;
  END IF;
  
  /** DISPLAY ACCOUNTED AFFECTED PAYMENT ADJUSTED TRANSACTIONS **/
  /** FOR WHICH WE NEED TO DO UNDO ACCOUNTING BEFORE STAMPING  **/
  /** THE CORRECT RELATED_EVENT_ID                             **/
  l_count := 0;
  Begin
    Execute Immediate 
        'SELECT count(*) 
          FROM ap_temp_data_undo_8529749 temp' 
          INTO l_count;
  EXCEPTION
    WHEN OTHERS THEN
      FND_File.Put_Line(fnd_file.output,'Exception in selecting count from '||
	                'ap_temp_data_undo_8529749 for processed adjusted '||
			'transactions with incorrect related_event_id for '||
			'which we need to do undo Accounting ->'||SQLERRM);
  END;
  IF (l_count > 0) THEN 
    AP_ACCTG_DATA_FIX_PKG.Print('******* Details of the processed payment '||
	'adjusted transactions with incorrect related_event_id for which we'||
	' need to undo accounting. Please follow the GDF Note 874710.1 *******');             
    BEGIN
      AP_Acctg_Data_Fix_PKG.Print_html_table                           
       ('CHECK_NUMBER,TRANSACTION_TYPE,CHECK_ID,PAYMENT_HISTORY_ID,OLD_RELATED_EVENT_ID,'||
	'POSTED_FLAG,ORG_ID,EVENT_ID,EVENT_TYPE_CODE,'||
        'EVENT_STATUS_CODE,PROCESS_STATUS_CODE,EVENT_DATE,PROCESS_FLAG',
        'ap_temp_data_undo_8529749',                                
         null,                                                         
        'ap_PayAdjWrongRelEvtId_Sel.sql');                                              
    EXCEPTION                                                          
      WHEN OTHERS THEN
        FND_File.Put_Line(fnd_file.output,'Exception in call to '||
	                  'AP_Acctg_Data_Fix_PKG.Print_html_table for '|| 
                          'printing processed adjusted transactions with '||
                          'incorrect related_event_id for which we need to '||
			  'undo accounting->'||SQLERRM);
    END;
  END IF;
  
  
  /*
   +=======================================================================+
 | FILENAME                                                              |
 |   ap_unacct_trx_closed_prd_sel.sql                                    |
 |                                                                       |
 | DESCRIPTION                                                           |
 |   Script to identify all the unaccounted events in closed             |
 |   period into table AP_TEMP_DATA_DRIVER_8529957.                      |
 |                                                                       |
 | HISTORY                                                               |
 |   03-NOV-2008 NJAKKULA Created                                        |
 +=======================================================================+*/
 
  BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE AP_TEMP_DATA_DRIVER_8529957';
  EXCEPTION
  WHEN OTHERS THEN
      Null;
  END;

 

  EXECUTE IMMEDIATE 
   'CREATE TABLE AP_TEMP_DATA_DRIVER_8529957 AS
    SELECT xe.event_id,
           xe.event_type_code event_type,
	   xe.event_date,
	   xte.entity_code,
	   xte.ledger_id,
           xte.source_id_int_1 transaction_id,
	   xte.transaction_number,
	   xte.Security_Id_Int_1 org_id,
	   ''Y'' Process_flag,
	   ''Run fix script'' sweep_to_date
      FROM xla_events xe, xla_transaction_entities_upg xte,
           ap_system_parameters_all asp,gl_period_statuses gps
     WHERE xe.application_id = 200
       AND xte.application_id = 200
       AND xe.entity_id = xte.entity_id
       AND xe.event_status_code IN (''I'',''U'')
       AND xe.process_status_code IN (''I'',''U'',''R'')
       AND xte.Security_Id_Int_1 = asp.org_id
       AND gps.application_id = 200
       AND gps.set_of_books_id = asp.set_of_books_id
       AND trunc(event_date) between gps.start_date and gps.end_date
       AND gps.closing_status not in (''O'',''F'')
       AND NVL(adjustment_period_flag, ''N'') = ''N'' ';

  

  BEGIN
  
  EXECUTE IMMEDIATE 
     'SELECT COUNT(*)
        FROM AP_TEMP_DATA_DRIVER_8529957'
  INTO l_count;

    IF l_count <> 0 THEN

        AP_Acctg_Data_Fix_PKG.Print('Following are the Unaccounted Payables events in a closed period  '||
                                    'Please follow note 875012.1 for more details.');

        AP_Acctg_Data_Fix_PKG.Print('_______________________________________'||
                                    '_______________________________________');

        AP_Acctg_Data_Fix_PKG.Print_html_table
           ('ENTITY_CODE,TRANSACTION_NUMBER,TRANSACTION_ID,EVENT_ID,'||
            'EVENT_TYPE,EVENT_DATE,LEDGER_ID,ORG_ID,PROCESS_FLAG',
	    'AP_TEMP_DATA_DRIVER_8529957',
	    'ORDER BY EVENT_ID',
	    'ap_unacct_trx_closed_prd_sel'); 
		
		 ELSE
      l_message :=  '********NO UNACCOUNTED EVENTS IN CLOSED PERIOD. Please follow the GDF note 874903.1********';
      AP_Acctg_Data_Fix_PKG.Print(l_message);
	  END IF;
  EXCEPTION                                                          
  WHEN OTHERS THEN
     l_message :=  'Error  '|| SQLCODE||';'||SQLERRM ||'<p>';
     AP_Acctg_Data_Fix_PKG.Print(l_message);
  END;   
  
 /*+=======================================================================+
 | FILENAME                                                              |
 |     ap_prepay_apply_unapply_sel.sql                                   |
 |                                                                       |
 | DESCRIPTION                                                           |
 |     This script will SELECT unaccounted prepay apply and  unapply     |
 |     events of cancelled invoice.                                      |
 |                                                                       |
 | HISTORY Created by GKARAMPU                                           |
 +=======================================================================+  */
 
 
  --------------------------------------------------------------------------
  -- Step 1: Drop the temporary tables if already exists
  --------------------------------------------------------------------------
      

  BEGIN
    Execute Immediate
      'DROP TABLE ap_temp_data_driver_8932975';

  EXCEPTION
    WHEN OTHERS THEN
     Null;
	
  END;
 
  --------------------------------------------------------------------------
  -- Step 2: create backup tables and driver tables
  --------------------------------------------------------------------------
 
  BEGIN
    Execute Immediate
      'CREATE TABLE ap_temp_data_driver_8932975 AS
       SELECT transaction_type,
              prepay_history_id,			
              accounting_event_id,
              invoice_id,
	      invoice_line_number,
	      bc_event_id,
	      posted_flag process_flag
         FROM ap_prepay_history_all
        WHERE 1=2';
   EXCEPTION
     WHEN OTHERS THEN
      l_message := 'EXCEPTION :: '||SQLERRM ||
                  ' in creating ap_temp_data_driver_8932975';
      FND_File.Put_Line(fnd_file.output,l_message);
	
   END;

  BEGIN
    Execute Immediate
      'INSERT INTO ap_temp_data_driver_8932975      
       select distinct p.transaction_type,
              p.prepay_history_id,			
              p.accounting_event_id,
              p.invoice_id,
              p.invoice_line_number,
	      p.bc_event_id,
	      ''Y'' process_flag
         from ap_invoices_all i,
              ap_prepay_history_all p,
	      xla_events xe
        where p.invoice_id = i.invoice_id
 	  and p.accounting_event_id = xe.event_id
	  and nvl(p.posted_flag, ''N'') <> ''Y''
	  and xe.application_id =200
	  and xe.process_status_code = ''U''
	  and i.cancelled_date is not null 
	  and i.invoice_amount =0
	  and not exists 
	         (select 1 from ap_invoice_distributions_all d
                   where d.invoice_id = i.invoice_id
		     and prepay_distribution_id is null)
       Union 
       SELECT DISTINCT p.transaction_type,
              p.prepay_history_id,
              p.accounting_event_id,
              p.invoice_id,
              p.invoice_line_number,
              p.bc_event_id,
              ''Y'' process_flag
         FROM ap_invoices_all i,
              ap_prepay_history_all p,
              xla_events xe
        WHERE p.invoice_id = i.invoice_id
          AND p.accounting_event_id = xe.event_id
          AND nvl(p.posted_flag,   ''N'') <> ''Y''
          AND xe.application_id = 200
          AND xe.event_status_code <> ''P''
          AND i.cancelled_date IS NOT NULL
          AND i.invoice_amount = 0
          AND EXISTS
             (SELECT 1
                FROM ap_prepay_history_all app,
                     xla_events xe
               WHERE app.invoice_id = p.invoice_id
                 AND app.invoice_line_number = p.invoice_line_number
                 AND app.transaction_type = ''PREPAYMENT APPLIED''
                 AND xe.event_id(+) = app.bc_event_id
                 AND xe.application_id(+) = 200
                 AND xe.event_status_code(+) <> ''P''
                 AND nvl(app.posted_flag,    ''N'') <> ''Y'')
          AND EXISTS
             (SELECT 1
                FROM ap_prepay_history_all unapp,
                     xla_events xel
               WHERE unapp.invoice_id = p.invoice_id
                 AND unapp.invoice_line_number = p.invoice_line_number
                 AND unapp.transaction_type = ''PREPAYMENT UNAPPLIED''
                 AND xel.event_id(+) = unapp.bc_event_id
                 AND xel.application_id(+) = 200
                 AND xel.event_status_code(+) <> ''P''
                 AND nvl(unapp.posted_flag,    ''N'') <> ''Y'')';
  EXCEPTION
     WHEN OTHERS THEN
      l_message := 'EXCEPTION :: '||SQLERRM ||
                  ' in inserting in ap_temp_data_driver_8932975';
      FND_File.Put_Line(fnd_file.output,l_message);
	
  END;   
  
  ------------------------------------------------------------------
  -- Step 3: Report all the affected transactions in Log file 
  ---------------------------------------------------------------------
  BEGIN
  Execute Immediate  
      'SELECT COUNT(*) FROM ap_temp_data_driver_8932975' into l_count1;
  EXCEPTION
      WHEN OTHERS THEN
        l_message := 'EXCEPTION :: '||SQLERRM ||
                  ' in counting data from ap_temp_data_driver_8932975';
        FND_File.Put_Line(fnd_file.output,l_message);
	
  END; 

    IF (l_count1 > 0) THEN 
      AP_Acctg_Data_Fix_PKG.Print('++++Details of Prepayment Applied/Unapplied events that can not be accounted after'||
                                  'the invoice is Cancelled. Please follow the note 970912.1 ++++');            
    BEGIN
      AP_Acctg_Data_Fix_PKG.Print_html_table                           
       ('TRANSACTION_TYPE,PREPAY_HISTORY_ID,ACCOUNTING_EVENT_ID,'||                                                                               
       'INVOICE_ID,INVOICE_LINE_NUMBER,BC_EVENT_ID',
        'ap_temp_data_driver_8932975',
	    NULL,
        'ap_prepay_apply_unapply_sel.sql');                                              
    EXCEPTION                                                          
       WHEN OTHERS THEN
        l_message := 'EXCEPTION :: '||SQLERRM ||
                     'in call to AP_Acctg_Data_Fix_PKG.Print_html_table '||
		     'during printing data from ap_prob_pay_events_8932975';
        FND_File.Put_Line(fnd_file.output,l_message);
	
    END;
    END IF;
	
/*+=======================================================================+
 |    Copyright (c) 2001 Oracle Corporation, Redwood Shores, CA, USA     |
 |                         All rights reserved.                          |
 +=======================================================================+
 | FILENAME                                                              |
 |     ap_orphan_pay_hist_sel.sql                                        |
 |                                                                       |
 | DESCRIPTION                                                           |
 |     This script will select orphan payment history records            |
 |                                                                       |
 | HISTORY Created by GKARAMPU                                           |
 +=======================================================================+*/
 
 --------------------------------------------------------------------------
  -- Step 1: Drop the temporary tables if already exists
  --------------------------------------------------------------------------
      

  BEGIN
    Execute Immediate
      'DROP TABLE ap_temp_data_driver_8932493';

  EXCEPTION
    WHEN OTHERS THEN
     Null;
	
  END;
 
  --------------------------------------------------------------------------
  -- Step 2: create backup tables and driver tables
  --------------------------------------------------------------------------
 
  BEGIN
    Execute Immediate
      'CREATE TABLE ap_temp_data_driver_8932493 AS
       SELECT transaction_type,
              payment_history_id,
              related_event_id,
              accounting_event_id,
	      invoice_adjustment_event_id,
	      check_id,
	      accounting_date,
	      posted_flag process_flag
         FROM ap_payment_history_all
        WHERE 1=2';
   EXCEPTION
     WHEN OTHERS THEN
      l_message := 'EXCEPTION :: '||SQLERRM ||
                  ' in creating ap_temp_data_driver_8932493';
      FND_File.Put_Line(fnd_file.output,l_message);
	
   END;

  BEGIN
    Execute Immediate
      'INSERT INTO ap_temp_data_driver_8932493      
       SELECT DISTINCT h1.transaction_type,
              h1.payment_history_id,
              h1.related_event_id,
              h1.accounting_event_id,
	      h1.invoice_adjustment_event_id,
	      h1.check_id,
	      h1.accounting_date,
	      ''Y'' process_flag
         FROM ap_payment_history_all h1,
              xla_events xe
        WHERE h1.transaction_type LIKE ''%ADJUSTED''
          AND nvl(h1.posted_flag,   ''N'') <> ''Y''
	  AND h1.transaction_type <> ''MANUAL PAYMENT ADJUSTED''
          AND xe.event_id = h1.accounting_event_id
          AND xe.event_status_code <> ''P''
          AND xe.application_id = 200
          AND NOT EXISTS
                 (SELECT 1
                    FROM ap_invoice_distributions_all aid
                   WHERE aid.accounting_event_id = h1.invoice_adjustment_event_id)';
  EXCEPTION
     WHEN OTHERS THEN
      l_message := 'EXCEPTION :: '||SQLERRM ||
                  ' in inserting in ap_temp_data_driver_8932493';
      FND_File.Put_Line(fnd_file.output,l_message);
	
  END;   
  
  ------------------------------------------------------------------
  -- Step 3: Report all the affected transactions in Log file 
  ---------------------------------------------------------------------
  BEGIN
  Execute Immediate  
      'SELECT COUNT(*) FROM ap_temp_data_driver_8932493' into l_count1;
  EXCEPTION
      WHEN OTHERS THEN
        l_message := 'EXCEPTION :: '||SQLERRM ||
                  ' in counting data from ap_temp_data_driver_8932493';
        FND_File.Put_Line(fnd_file.output,l_message);
	
  END; 

    IF (l_count1 > 0) THEN 
      AP_Acctg_Data_Fix_PKG.Print('++++Details of Orphan Payment History Records. Please follow the GDF note 970956.1 ++++');            
    BEGIN
      AP_Acctg_Data_Fix_PKG.Print_html_table                           
       ('TRANSACTION_TYPE,PAYMENT_HISTORY_ID,ACCOUNTING_EVENT_ID,'||                                                                             
        'INVOICE_ADJUSTMENT_EVENT_ID,CHECK_ID',
        'ap_temp_data_driver_8932493',
	    NULL,
        'ap_orphan_pay_hist_sel.sql');                                              
    EXCEPTION                                                          
       WHEN OTHERS THEN
        l_message := 'EXCEPTION :: '||SQLERRM ||
                     'in call to AP_Acctg_Data_Fix_PKG.Print_html_table '||
		     'during printing data from ap_prob_pay_events_8932493';
        FND_File.Put_Line(fnd_file.output,l_message);
	
    END;
    END IF;
	
	
	
 /*+=======================================================================+
 | FILENAME                                                              |
 |                                                                       |
 | DESCRIPTION   
 |   GDF for generating missing accounting events on AP transactions     |
 | HISTORY                                                               |
 |   Created By : GAGRAWAL                                               |
 +=======================================================================+	*/
 
 l_bug_no := '8966238';
	
	l_driver_inv_tab := 'AP_TEMP_INV_DRIVER_'||l_bug_no;
  BEGIN
     l_sql_stmt :=
          ' DROP TABLE '||l_driver_inv_tab;
    EXECUTE IMMEDIATE l_sql_stmt;
  EXCEPTION
    WHEN OTHERS THEN
      null;
  END;

  l_sql_stmt :=
       ' CREATE TABLE '||l_driver_inv_tab||' AS '||
       ' SELECT DISTINCT ai.invoice_type_lookup_code, '||
       '        ai.invoice_id, '||
       '        aid.invoice_distribution_id, '||
       '        ai.invoice_num, '||
       '        ai.invoice_date, '||
       '        asu.vendor_name, '||
       '        assi.vendor_site_code, '||
       '        ap_invoices_utility_pkg.get_approval_status( '||
       '                   ai.invoice_id, '||
       '                   ai.invoice_amount, '||
       '                   ai.payment_status_flag, '||
       '                   ai.invoice_type_lookup_code) invoice_status, '||
       '        ai.org_id, '||
       '        ''Y'' process_flag '||
       '   FROM ap_invoices_all ai, '||
       '        ap_suppliers asu, '||
       '        ap_supplier_sites_all assi, '||
       '        ap_invoice_distributions_all aid, '||
       '        financials_system_params_all fsp '||
       ' WHERE aid.invoice_id = ai.invoice_id '||
       '   AND ai.vendor_id = asu.vendor_id(+) '||
       '   AND ai.vendor_site_id = assi.vendor_site_id(+) '||
       '   AND nvl(ai.historical_flag,   ''N'') <> ''Y'' '||
       '   AND fsp.org_id = aid.org_id '||
       '   AND ((fsp.purch_encumbrance_flag = ''Y'' AND '||
       '         aid.match_status_flag = ''A'') OR '||
       '        (fsp.purch_encumbrance_flag = ''N'' AND '||
       '         aid.match_status_flag IN(''A'',   ''T'')) '||
       '       ) '||
       '   AND nvl(aid.posted_flag,   ''N'') <> ''Y'' '||
       '   AND aid.accounting_event_id IS NULL ';

  l_debug_info := 'Creating the Driver table containing the selected '||
                  'transactions ';
  EXECUTE IMMEDIATE l_sql_stmt;

  l_driver_chk_tab := 'AP_TEMP_CHK_DRIVER_'||l_bug_no;
  BEGIN
     l_sql_stmt :=
          ' DROP TABLE '||l_driver_chk_tab;
    EXECUTE IMMEDIATE l_sql_stmt;
  EXCEPTION
    WHEN OTHERS THEN
      null;
  END;

  l_sql_stmt :=
       ' CREATE TABLE '||l_driver_chk_tab||' AS '||
       ' SELECT DISTINCT ac.check_id, '||
       '        ac.check_number, '||
       '        ac.check_date, '||
       '        asu.vendor_name, '||
       '        assi.vendor_site_code, '||
       '        ac.amount, '||
       '        ac.status_lookup_code, '||
       '        ac.org_id, '||
       '        ''Y'' process_flag '||
       '   FROM ap_checks_all ac, '||
       '        ap_invoice_payments_all aip, '||
       '        ap_suppliers asu, '||
       '        ap_supplier_sites_all assi '||
       '  WHERE ac.check_id = aip.check_id  '||
       '    AND ac.vendor_id = asu.vendor_id(+) '||
       '    AND ac.vendor_site_id = assi.vendor_site_id(+) '||
       '    AND ((aip.accounting_event_id IS NULL AND '||
       '          nvl(aip.posted_flag, ''N'') <> ''Y'') '||
       '         OR '||
       '         EXISTS '||
       '           (SELECT 1 '||
       '              FROM ap_payment_history_all aph '||
       ' 	    WHERE aph.check_id = ac.check_id '||
       ' 	      AND aph.accounting_event_id IS NULL '||
       '              AND nvl(aph.posted_flag, ''N'') <> ''Y'' '||
       '           ) '||
       '        ) ';

  l_debug_info := 'Creating the Driver table containing the selected '||
                  'transactions ';
  EXECUTE IMMEDIATE l_sql_stmt;




  l_debug_info := 'Prompting the transactions ';
  l_message := ' Following Invoice transactions which are having distributions '||
               ' missing accounting_event_id '||
               '.Please follow the GDF Note 972261.1  ';
  AP_ACCTG_DATA_FIX_PKG.Print(l_message);
  l_message :=  '_______________________________________'||
                '_______________________________________';
  AP_ACCTG_DATA_FIX_PKG.Print(l_message);

  l_debug_info := 'Constructing the select columns ';
  l_select_list :=
          'INVOICE_TYPE_LOOKUP_CODE,'||
          'INVOICE_ID,'||
	  'INVOICE_DISTRIBUTION_ID,'||
          'INVOICE_NUM,'||
          'INVOICE_DATE,'||
          'VENDOR_NAME,'||
          'VENDOR_SITE_CODE,'||
          'INVOICE_STATUS,'||
          'ORG_ID,'||
	  'PROCESS_FLAG';

  l_debug_info := 'Getting the table name ';
  l_table_name :=
         l_driver_inv_tab;

  l_debug_info := 'Constructing the where clause ';
  l_where_clause :=
         'ORDER BY VENDOR_NAME,'||
         '         VENDOR_SITE_CODE,'||
         '         INVOICE_DATE';

  l_debug_info := 'Before calling the Print HTML';
  AP_ACCTG_DATA_FIX_PKG.Print_html_table
    (p_select_list       => l_select_list,
     p_table_in          => l_table_name,
     p_where_in          => l_where_clause,
     P_calling_sequence  => l_calling_sequence);

  l_message := ' Following Payment transactions which are '||
               ' missing accounting_event_id would be fixed as a part of '||
               ' the Data Fix, Please follow the GDF Note 972261.1 ';
  AP_ACCTG_DATA_FIX_PKG.Print(l_message);
  l_message :=  '_______________________________________'||
                '_______________________________________';
  AP_ACCTG_DATA_FIX_PKG.Print(l_message);

  l_debug_info := 'Constructing the select columns ';

  l_select_list :=
       'CHECK_ID,'||
       'CHECK_NUMBER,'||
       'CHECK_DATE,'||
       'VENDOR_NAME,'||
       'VENDOR_SITE_CODE,'||
       'AMOUNT,'||
       'STATUS_LOOKUP_CODE,'||
       'ORG_ID,'||
       'PROCESS_FLAG';

  l_debug_info := 'Getting the table name ';
  l_table_name :=
         l_driver_chk_tab;

  l_debug_info := 'Constructing the where clause ';
  l_where_clause :=
         'ORDER BY VENDOR_NAME,'||
         '         VENDOR_SITE_CODE,'||
         '         CHECK_DATE';

  l_debug_info := 'Before calling the Print HTML';
  AP_ACCTG_DATA_FIX_PKG.Print_html_table
    (p_select_list       => l_select_list,
     p_table_in          => l_table_name,
     p_where_in          => l_where_clause,
     P_calling_sequence  => l_calling_sequence);
	 
 /*+=======================================================================+
 | FILENAME                                                              |
 |   ap_missing_xdl.sql                                                  |
 |                                                                       |
 | DESCRIPTION                                                           |
 |   Script to identify upgraded migrated events missing XDL             |
 |                                                                       |
 |                                                                       |
 | HISTORY                                                               |
 |   03-OCT-2009 NJAKKULA Created                                        |
 +=======================================================================+*/
 
BEGIN

  l_message := 'Start of ap_missing_xdl<p>';
  AP_Acctg_Data_Fix_PKG.Print(l_message );

  BEGIN

    SELECT 1
      INTO l_check_fail
      FROM ap_invoices_upg_control
     WHERE module_name in ('GDF_POPULATE_INV_XDL','GDF_POPULATE_PAY_XDL')
       AND end_date IS NULL
       AND rownum  = 1;

  EXCEPTION

    WHEN NO_DATA_FOUND THEN
      AP_Acctg_Data_Fix_PKG.Print('No previous failures exists');
      l_check_fail := 0;
  END;  

  IF  l_check_fail = 0 THEN
  
    

    BEGIN
      EXECUTE IMMEDIATE 'DROP TABLE ap_temp_driver_xdl_9094386';

    EXCEPTION
      WHEN OTHERS THEN
       Null;

    END;

    

    BEGIN

      EXECUTE IMMEDIATE 
       'CREATE TABLE ap_temp_driver_xdl_9094386 AS
        SELECT /*+ PARALLEL(ai) */ 
               DISTINCT xe.event_id, 
               xte.entity_id,
	       xah.ae_header_id, 
	       xte.source_id_int_1 transaction_id,
               xte.transaction_number, 
	       xte.entity_code, 
	       xte.ledger_id, 
	       ''Y'' process_flag
          FROM xla_events xe,
               xla_transaction_entities_upg xte,
               ap_invoices_all ai,
               gl_period_statuses upg,
               ap_system_parameters_all asp,
               xla_ae_headers xah
         WHERE xe.application_id = 200
           AND xe.event_status_code = ''P''
           AND xe.upg_batch_id is not null
           AND xe.upg_batch_id <> - 9999
           AND xah.application_id = 200
           AND xah.event_id = xe.event_id
           AND xah.upg_batch_id is not null
           AND xte.application_id = 200
           AND xte.ledger_id = xah.ledger_id
           AND xte.entity_code = ''AP_INVOICES''
           AND xte.entity_id = xe.entity_id
           AND ai.invoice_id = nvl(xte.source_id_int_1,-99)
           AND upg.application_id = xte.application_id
           AND upg.ledger_id = xte.ledger_id
           AND asp.set_of_books_id = xte.ledger_id
           AND upg.set_of_books_id = asp.set_of_books_id
           AND asp.org_id = ai.org_id
           AND ai.gl_date BETWEEN upg.start_date AND upg.end_date
           AND upg.migration_status_code = ''U''
           AND upg.closing_status in (''O'',''C'',''P'')
           AND trunc(upg.start_date) < (SELECT MIN(trunc(CREATION_DATE))
                                          FROM ad_applied_patches 
                                         WHERE patch_type=''MAINTENANCE-PACK'' 
                                           AND maint_pack_level LIKE ''12.0%'')
           AND EXISTS (SELECT 1 
                         FROM ap_invoice_distributions_all aid
                        WHERE aid.invoice_id = ai.invoice_id
	  	          AND aid.accounting_event_id = xe.event_id
		          AND aid.Historical_flag = ''Y'')
           AND NOT EXISTS (SELECT 1 
                             FROM xla_distribution_links xdl
                            WHERE xdl.application_id = 200
                              AND xdl.ae_header_id = xah.ae_header_id)
        UNION ALL
         SELECT /*+ PARALLEL(ac) */ 
               DISTINCT xe.event_id, 
               xte.entity_id,
               xah.ae_header_id, 
               xte.source_id_int_1 transaction_id,
               xte.transaction_number, 
               xte.entity_code, 
               xte.ledger_id, 
               ''Y'' process_flag
          FROM xla_events xe,
               xla_transaction_entities_upg xte,
               ap_checks_all ac,
               gl_period_statuses upg,
               ap_system_parameters_all asp,
               xla_ae_headers xah
         WHERE xe.application_id = 200
           AND xe.event_status_code = ''P''
           AND xe.upg_batch_id is not null
           AND xe.upg_batch_id <> - 9999
           AND xah.application_id = 200
           AND xah.event_id = xe.event_id
           AND xah.upg_batch_id is not null
           AND xte.application_id = 200
           AND xte.ledger_id = xah.ledger_id
           AND xte.entity_code = ''AP_PAYMENTS''
           AND xte.entity_id = xe.entity_id
           AND ac.check_id = nvl(xte.source_id_int_1,-99)
           AND upg.application_id = xte.application_id
           AND upg.ledger_id = xte.ledger_id
           AND upg.set_of_books_id = asp.set_of_books_id
           AND asp.set_of_books_id = xte.ledger_id
           AND asp.org_id = ac.org_id
           AND ac.check_date BETWEEN upg.start_date AND upg.end_date
           AND upg.migration_status_code = ''U''
           AND upg.closing_status in (''O'' ,''C'',''P'')
           AND trunc(upg.start_date) < (SELECT MIN(trunc(CREATION_DATE))
                                          FROM ad_applied_patches 
                                         WHERE patch_type=''MAINTENANCE-PACK'' 
                                           AND maint_pack_level LIKE ''12.0%'')
           AND EXISTS (SELECT 1
                         FROM ap_invoice_payments_all aip
  	 	        WHERE aip.check_id = ac.check_id)		
           AND NOT EXISTS (SELECT 1 
                             FROM xla_distribution_links xdl
                            WHERE xdl.application_id = 200
                              AND xdl.ae_header_id = xah.ae_header_id) ';

      

    EXCEPTION

      WHEN OTHERS THEN
        AP_Acctg_Data_Fix_PKG.Print(' exception occured in '||
                   'creating table ap_temp_driver_xdl_9094386');
    END;


    BEGIN
  
      EXECUTE IMMEDIATE 
       'SELECT COUNT(*)
          FROM ap_temp_driver_xdl_9094386'
          INTO l_count;

      IF l_count <> 0 THEN

        AP_Acctg_Data_Fix_PKG.Print('Following are the events which are '||
                                    'missing xdl and for which fix will run.Please follow the Note 1054299.1 for more details '||
			  	    'NOTE:Only 10000 records displayed.');
 
        AP_Acctg_Data_Fix_PKG.Print('_______________________________________'||
                                    '_______________________________________');

        AP_Acctg_Data_Fix_PKG.Print_html_table
           ('ENTITY_CODE,TRANSACTION_NUMBER,TRANSACTION_ID,EVENT_ID,'||
            'LEDGER_ID,PROCESS_FLAG',
	    'AP_TEMP_DRIVER_XDL_9094386',
	    'WHERE ROWNUM <= 10000 ORDER BY EVENT_ID',
	    'ap_missing_xdl'); 

      
      ELSE
        l_message :=  '********NO EVENTS MISSSING XDL FOR INVOICES/PAYMENTS IDENTIFIED********';
        AP_Acctg_Data_Fix_PKG.Print(l_message);

      END IF;

    EXCEPTION   
  
      WHEN OTHERS THEN
        l_message :=  'Error  '|| SQLCODE||';'||SQLERRM ||'<p>';
        AP_Acctg_Data_Fix_PKG.Print(l_message);
    END;   

  ELSE
    l_message :=  '********PREVIOUS RUN FAILED.Please follow the Note 1054299.1 for more details********';
    AP_Acctg_Data_Fix_PKG.Print(l_message);

  END IF;

COMMIT;

EXCEPTION

  WHEN OTHERS THEN
    l_message :=  'Error  '|| SQLCODE||';'||SQLERRM ||'<p>';
    AP_Acctg_Data_Fix_PKG.Print(l_message);
   

END;


 
 /*+=======================================================================+
 |    Copyright (c) 2001 Oracle Corporation, Redwood Shores, CA, USA     |
 |                         All rights reserved.                          |
 +=======================================================================+
 | FILENAME                                                              |
 |   ap_xdl_pop_sel.sql                                                  |
 |                                                                       |
 | DESCRIPTION                                                           |
 |   Script to identify historical upgraded events missing XDL                    |
 |   which disrupt the accounting of downstream events .                 |                                                
 |                                                                       |
 | HISTORY                                                               |
 |   03-OCT-2009 NTHAKKER Created                                        |
 +=======================================================================+*/
 
BEGIN

 
                

  BEGIN

    EXECUTE IMMEDIATE 'DROP TABLE ap_driver_xdl_9127622';

  EXCEPTION
    WHEN OTHERS THEN
     Null;
  END;

  

  EXECUTE IMMEDIATE 
 'CREATE TABLE ap_driver_xdl_9127622 AS
  SELECT DISTINCT l_xdl.event_id, 
         l_xdl.entity_id,
         l_xdl.ae_header_id, 
         l_xdl.transaction_id,
         l_xdl.transaction_number, 
         l_xdl.entity_code, 
         l_xdl.ledger_id, 
         l_xdl.transaction_date,
         l_xdl.PROCESS_FLAG,
         l_xdl.migration_status_code
    FROM 
       (SELECT DISTINCT xe.event_id, 
               xte.entity_id,
               xah.ae_header_id, 
               xte.source_id_int_1 transaction_id,
               xte.transaction_number, 
               xte.entity_code, 
               xte.ledger_id, 
               ai.gl_date transaction_date,
               ''Y'' PROCESS_FLAG ,
               ''N'' migration_status_code
         FROM  ap_invoice_payments_all aip,
               xla_events xe,
               ap_invoices_all ai,
               ap_system_parameters_all asp,
               xla_transaction_entities_upg xte,
               xla_ae_headers xah,
               xla_distribution_links xdl
        WHERE  aip.accrual_posted_flag =''N''
          AND  AIP.ORG_ID=ASP.ORG_ID
          AND  aip.invoice_id=ai.invoice_id
          AND  ai.historical_flag=''Y''
          AND  ai.invoice_id = nvl(xte.source_id_int_1,-99)
          AND  xte.entity_code = ''AP_INVOICES''
          AND  xte.application_id = 200
          AND  xte.entity_id = xe.entity_id
          AND  xe.application_id = 200
          AND  xe.event_status_code = ''P''
          AND  xe.upg_batch_id is not null
          AND  xe.upg_batch_id <> - 9999
          AND  xah.application_id = 200
          AND  xah.upg_batch_id is not null
          AND  xah.event_id = xe.event_id
          AND  xte.ledger_id = xah.ledger_id
          AND  asp.org_id = ai.org_id
          AND  asp.set_of_books_id = xte.ledger_id
          AND  xah.ae_header_id=xdl.ae_header_id (+)
          AND  xdl.ae_header_id is null
       UNION ALL
       SELECT  DISTINCT xe.event_id, 
               xte.entity_id,
               xah.ae_header_id, 
               xte.source_id_int_1 transaction_id,
               xte.transaction_number, 
               xte.entity_code, 
               xte.ledger_id, 
               ac.check_date transaction_date,
               ''Y'' PROCESS_FLAG,
               ''N'' migration_status_code
         FROM  ap_payment_history_all aph,
               ap_checks_all ac,
               xla_events xe,
               ap_system_parameters_all asp,
               xla_transaction_entities_upg xte,
               xla_ae_headers xah,
               xla_distribution_links xdl
        WHERE  aph.posted_flag =''N''
          AND  APH.ORG_ID=ASP.ORG_ID
          AND  aph.check_id=ac.check_id
          AND  ac.check_id = nvl(xte.source_id_int_1,-99)
          AND  xte.entity_code = ''AP_PAYMENTS''
          AND  xte.application_id = 200
          AND  xte.entity_id = xe.entity_id
          AND  xe.application_id = 200
          AND  xe.event_status_code = ''P''
          AND  xe.upg_batch_id is not null
          AND  xe.upg_batch_id <> - 9999
          AND  xah.application_id = 200
          AND  xah.event_id = xe.event_id
          AND  xah.upg_batch_id is not null
          AND  xte.ledger_id = xah.ledger_id
          AND  asp.set_of_books_id = xte.ledger_id
          AND  asp.org_id = ac.org_id
          AND  xah.ae_header_id=xdl.ae_header_id (+)
          AND  xdl.ae_header_id is null
       UNION ALL
       SELECT  DISTINCT xe.event_id, 
               xte.entity_id,
               xah.ae_header_id, 
               xte.source_id_int_1 transaction_id,
               xte.transaction_number, 
               xte.entity_code, 
               xte.ledger_id, 
               ai.gl_date transaction_date,
               ''Y'' PROCESS_FLAG,
               ''N'' migration_status_code
         FROM  ap_invoice_distributions_all aid,
               ap_invoices_all ai,
               xla_events xe,
               ap_system_parameters_all asp,
               xla_transaction_entities_upg xte,
               xla_ae_headers xah,
               xla_distribution_links xdl
        WHERE  aid.posted_flag=''N''
          AND  AID.ORG_ID=ASP.ORG_ID
          AND  aid.invoice_id=ai.invoice_id
          AND  ai.historical_flag=''Y''
          AND  ai.invoice_id = nvl(xte.source_id_int_1,-99)
          AND  xte.entity_code = ''AP_INVOICES''
          AND  xte.application_id = 200
          AND  xte.entity_id = xe.entity_id
          AND  xe.application_id = 200
          AND  xe.event_status_code = ''P''
          AND  xe.upg_batch_id is not null
          AND  xe.upg_batch_id <> - 9999
          AND  xah.application_id = 200
          AND  xah.event_id = xe.event_id
          AND  xah.upg_batch_id is not null
          AND  xte.ledger_id = xah.ledger_id
          AND  asp.org_id = ai.org_id
          AND  asp.set_of_books_id = xte.ledger_id
          AND  xah.ae_header_id=xdl.ae_header_id (+)
          AND  xdl.ae_header_id is null
       UNION ALL
       SELECT  DISTINCT xe.event_id, 
               xte.entity_id,
               xah.ae_header_id, 
               xte.source_id_int_1 transaction_id,
               xte.transaction_number, 
               xte.entity_code, 
               xte.ledger_id, 
               ai.gl_date transaction_date,
               ''Y'' PROCESS_FLAG,
               ''N'' migration_status_code
         FROM  ap_invoice_distributions_all aid,
               ap_invoices_all ai,
               ap_prepay_history_all aph,
               xla_events xe,
               ap_system_parameters_all asp,
               xla_transaction_entities_upg xte,
               xla_ae_headers xah,
               xla_distribution_links xdl
        WHERE  aid.posted_flag=''N''
          AND  aid.prepay_distribution_id is not null
          AND  AID.ORG_ID=ASP.ORG_ID
          AND  aid.accounting_event_id=aph.accounting_event_id
          AND  aid.invoice_id=aph.invoice_id
          AND  aph.prepay_invoice_id=ai.invoice_id
          AND  ai.invoice_id = nvl(xte.source_id_int_1,-99)
          AND  ai.historical_flag=''Y''
          AND  xte.entity_code = ''AP_INVOICES''
          AND  xte.application_id = 200
          AND  xte.entity_id = xe.entity_id
          AND  xe.application_id = 200
          AND  xe.event_status_code =''P''
          AND  xe.upg_batch_id is not null
          AND  xe.upg_batch_id <> - 9999
          AND  xah.application_id = 200
          AND  xah.event_id = xe.event_id
	  AND  xah.upg_batch_id is not null
          AND  xte.ledger_id = xah.ledger_id
          AND  asp.org_id = ai.org_id
          AND  asp.set_of_books_id = xte.ledger_id
          AND  xah.ae_header_id=xdl.ae_header_id (+)
          AND  xdl.ae_header_id is null
        )l_xdl';

  
		
  BEGIN
  
    EXECUTE IMMEDIATE 
    'SELECT COUNT(*)
       FROM AP_DRIVER_XDL_9127622'
       INTO l_count;

    IF l_count <> 0 THEN

      EXECUTE IMMEDIATE
      'UPDATE ap_driver_xdl_9127622 l_xdl
         SET l_xdl.migration_status_code=(SELECT migration_status_code
                                            FROM gl_period_statuses upg
			                   WHERE upg.application_id = 200
                                             AND l_xdl.transaction_date between upg.start_date AND upg.end_date
                                             AND upg.ledger_id = l_xdl.ledger_id
			                     AND upg.adjustment_period_flag=''N''
				             AND upg.closing_status in (''O'',''C'',''P''))';

      EXECUTE IMMEDIATE 
      'SELECT count(*)
         FROM ap_driver_xdl_9127622
        WHERE nvl(migration_status_code, ''N'') <>''U'''
         INTO l_count_1;

      IF  l_count_1 <> 0 THEN

        EXECUTE IMMEDIATE 
        'UPDATE ap_driver_xdl_9127622 l_xdl
            SET l_xdl.PROCESS_FLAG=''N''
          WHERE nvl(migration_status_code, ''N'') <>''U''';

        EXECUTE IMMEDIATE 
        'SELECT min(transaction_date)
           FROM ap_driver_xdl_9127622
          WHERE nvl(migration_status_code, ''N'') <>''U'' ' 
           INTO l_date;


        AP_Acctg_Data_Fix_PKG.Print('Following are the events which have '||
                                    'missing xdl and for which SLA Hot Patch is  '||
	 		 	    'not run .Please run SLA Hot Patch to resolve  ' ||
		 		    'the issue.More details on 1054322.1');

        AP_Acctg_Data_Fix_PKG.Print(' The mininum date for which sla hot patch'||
	                            ' should be run is : '||l_date );

        AP_Acctg_Data_Fix_PKG.Print('_______________________________________'||
                                    '_______________________________________');
 
        AP_Acctg_Data_Fix_PKG.Print_html_table
           ('ENTITY_CODE,TRANSACTION_NUMBER,TRANSACTION_ID,EVENT_ID,'||
            'LEDGER_ID,TRANSACTION_DATE,PROCESS_FLAG',
	    'AP_DRIVER_XDL_9127622',
	    'WHERE nvl(migration_status_code, ''N'') <>''U''',
	    'ap_trx_missing_xdl_mod.sql'); 

      END IF;


      EXECUTE IMMEDIATE 
      'SELECT count(*)
        FROM AP_DRIVER_XDL_9127622
       WHERE migration_status_code=''U'' '
        INTO l_count_2;

 
      IF l_count_2 <> 0 THEN

        AP_Acctg_Data_Fix_PKG.Print('Following are the events which have '||
                                    'missing xdl for upgraded transaction.'||
									'Please follow the note 1054322.1');

        AP_Acctg_Data_Fix_PKG.Print('_______________________________________'||
                                    '_______________________________________');

        AP_Acctg_Data_Fix_PKG.Print_html_table
           ('ENTITY_CODE,TRANSACTION_NUMBER,TRANSACTION_ID,EVENT_ID,'||
            'LEDGER_ID,TRANSACTION_DATE,PROCESS_FLAG',
	    'AP_DRIVER_XDL_9127622',
	    'WHERE migration_status_code=''U''',
	    'ap_trx_missing_xdl_mod.sql'); 

    END IF;

    ELSE
      l_message :=  '********NO EVENTS MISSSING XDL FOR INVOICES/PAYMENTS IDENTIFIED********';
      AP_Acctg_Data_Fix_PKG.Print(l_message);

    END IF;

   
  EXCEPTION 
    WHEN OTHERS THEN
      l_message :=  'Error  '|| SQLCODE||';'||SQLERRM ||'<p>';
      AP_Acctg_Data_Fix_PKG.Print(l_message);
  END;   
  
 /*+=======================================================================+
 | FILENAME                                                              |
 |     ap_incorrect_posted_flag_sel.sql                                  |
 |                                                                       |
 +=======================================================================+ */
  BEGIN

  l_bug_no:='9288086';
  --------------------------------------------------------------------------
  -- Step 1: Drop the temporary tables if already exists
  --------------------------------------------------------------------------

  l_driver_tab  := 'AP_TEMP_DATA_INV_DRV_'||l_bug_no;
  l_driver_tab1 := 'AP_TEMP_DATA_PAY_DRV_'||l_bug_no;  
  BEGIN
     l_sql_stmt :=
          ' DROP TABLE '||l_driver_tab;
    EXECUTE IMMEDIATE l_sql_stmt;
  EXCEPTION
    WHEN OTHERS THEN
      Null;
  END;

  BEGIN
     l_sql_stmt :=
          ' DROP TABLE '||l_driver_tab1;
    EXECUTE IMMEDIATE l_sql_stmt;
  EXCEPTION
    WHEN OTHERS THEN
      Null;
  END;
  
  --------------------------------------------------------------------------
  -- Step 2: create driver tables
  --------------------------------------------------------------------------
  l_debug_info := 'Before Creating the table '||l_driver_tab;
 
  l_sql_stmt :=
          ' CREATE TABLE '||l_driver_tab||
          '   AS '||
          ' SELECT ai.invoice_id                      ,'||
          '        ai.invoice_num                     ,'||
          '        aid.invoice_line_number            ,'||
          '        aid.distribution_line_number       ,'||
		  '        ''ap_invoice_distributions_all'' trx_table,'||
		  '        aid.invoice_distribution_id trx_id,'||
		  '        aid.accrual_posted_flag            ,'||
		  '        aid.cash_posted_flag               ,'||
          '        xe.event_id                        ,'||
          '        aid.org_id                         ,'||
          '        aid.set_of_books_id ledger_id      ,'||
          '        ''Y'' PROCESS_FLAG'||
          '   FROM ap_invoice_distributions_all aid,'||
          '        ap_invoices_all ai              ,'||
          '        xla_events xe'||
          '  WHERE aid.posted_flag        = ''N'''||
          '    AND xe.process_status_code = ''P'''||
          '    AND xe.event_status_code   IN (''N'',''P'')'||		  
          '    AND ai.invoice_id          = aid.invoice_id'||
          '    AND xe.event_id            = aid.accounting_event_id'||
          '    AND xe.application_id      = 200'||
          '  UNION'||
          ' SELECT ai.invoice_id                       ,'||
          '        ai.invoice_num                      ,'||
          '        astd.invoice_line_number            ,'||
          '        astd.distribution_line_number       ,'||
		  '        ''ap_self_assessed_tax_dist_all'' trx_table,'||
		  '        astd.invoice_distribution_id trx_id,'||
		  '        astd.accrual_posted_flag            ,'||
		  '        astd.cash_posted_flag               ,'||
          '        xe.event_id                         ,'||
          '        astd.org_id                         ,'||
          '        astd.set_of_books_id ledger_id      ,'||
          '        ''Y'' PROCESS_FLAG'||
          '   FROM ap_self_assessed_tax_dist_all astd,'||
          '        ap_invoices_all ai                ,'||
          '        xla_events xe'||
          '  WHERE astd.posted_flag       = ''N'''||
          '    AND xe.process_status_code = ''P'''||
          '    AND xe.event_status_code   IN (''N'',''P'')'||		  
          '    AND ai.invoice_id          = astd.invoice_id'||
          '    AND xe.event_id            = astd.accounting_event_id'||
          '    AND xe.application_id      = 200 '||
          ' UNION'||
          ' SELECT aph.prepay_invoice_id invoice_id,'||
          '        ai.invoice_num                  ,'||
          '        aph.prepay_line_num             ,'||
          '        NULL                            ,'||
		  '        ''ap_prepay_history_all'' trx_table,'||
		  '        aph.prepay_history_id trx_id   ,'||
		  '        null                            ,'||
		  '        null                            ,'||
          '        xe.event_id                     ,'||
          '        aph.org_id                      ,'||
          '        xte.ledger_id ledger_id         ,'||
          '        ''Y'' PROCESS_FLAG'||
          '   FROM ap_prepay_history_all aph       ,'||
          '        ap_invoices_all ai              ,'||
          '        xla_transaction_entities_upg xte,'||
          '        xla_events xe'||
          '  WHERE posted_flag           = ''N'''||
          '    AND process_status_code   = ''P'''||
          '    AND xe.event_status_code   IN (''N'',''P'')'||		  
          '    AND ai.invoice_id         = aph.prepay_invoice_id'||
          '    AND xte.security_id_int_1 = aph.org_id'||
          '    AND xe.event_id           = aph.accounting_event_id'||
          '    AND xe.entity_id          = xte.entity_id'||
          '    AND xe.application_id     = xte.application_id'||
          '    AND xte.application_id    = 200';          
          
  EXECUTE IMMEDIATE l_sql_stmt;       

  l_debug_info := 'Before Creating the table '||l_driver_tab1;
 
  l_sql_stmt :=
          ' CREATE TABLE '||l_driver_tab1||
          '   AS '||
          ' SELECT ac.check_id              ,'||
          '        ac.check_number          ,'||    
		  '        ''ap_invoice_payments_all'' trx_table,'||
		  '        aip.invoice_payment_id trx_id,'||
		  '        aip.accrual_posted_flag  ,'||
		  '        aip.cash_posted_flag     ,'||
          '        xe.event_id              ,'||
          '        ac.org_id                ,'||
          '        xte.ledger_id ledger_id  ,'||
          '        ''Y'' PROCESS_FLAG'||
          '   FROM ap_invoice_payments_all aip,'||
          '        ap_checks_all ac,'||
          '        xla_transaction_entities_upg xte,'||
          '        xla_events xe'||
          '  WHERE aip.posted_flag       = ''N'''||
          '    AND xe.process_status_code= ''P'''||
          '    AND xe.event_status_code   IN (''N'',''P'')'||		  
          '    AND ac.check_id           = aip.check_id'||          
          '    AND xe.event_id           = aip.accounting_event_id'||
          '    AND xte.security_id_int_1 = ac.org_id'||
          '    AND xe.entity_id          = xte.entity_id'||
          '    AND xe.application_id     = xte.application_id'||
          '    AND xe.application_id     = 200'||          
          ' UNION'||
          ' SELECT ac.check_id              ,'||
          '        ac.check_number          ,'||    
		  '        ''ap_payment_history_all'' trx_table,'||
		  '        aph.payment_history_id trx_id   ,'||
		  '        null                            ,'||
		  '        null                            ,'||
          '        xe.event_id              ,'||
          '        ac.org_id                ,'||
          '        xte.ledger_id ledger_id  ,'||
          '        ''Y'' PROCESS_FLAG'||
          '   FROM ap_payment_history_all aph,'||
          '        xla_transaction_entities_upg xte,'||
          '        ap_checks_all ac,'||
          '        xla_events xe'||
          '  WHERE aph.posted_flag        = ''N'''||
          '    AND xe.process_status_code = ''P'''||
          '    AND xe.event_status_code   IN (''N'',''P'')'||		  
          '    AND xte.security_id_int_1  = aph.org_id'||
          '    AND xe.event_id            = aph.accounting_event_id'||
          '    AND ac.check_id            = aph.check_id'||          
          '    AND xe.entity_id           = xte.entity_id'||
          '    AND xe.application_id      = xte.application_id'||
          '    AND xte.application_id     = 200';                  
          
  EXECUTE IMMEDIATE l_sql_stmt;      

  ------------------------------------------------------------------
  -- Step 3: Report all the affected transactions in Log file 
  ---------------------------------------------------------------------
  Begin
    l_debug_info := 'Counting the records of the table '||l_driver_tab;
    Execute Immediate  
        'SELECT COUNT(*) from AP_TEMP_DATA_INV_DRV_9288086' into l_count;
        
    l_debug_info := 'Before Creating the table '||l_driver_tab1;
    Execute Immediate  
        'SELECT COUNT(*) from AP_TEMP_DATA_PAY_DRV_9288086' into l_count1;
        
  EXCEPTION
    WHEN OTHERS THEN
          l_message := 'Exception in selecting count from '|| 
               l_driver_tab||' for selecting affected records'||
               SQLERRM ;
          AP_ACCTG_DATA_FIX_PKG.Print(l_message);
  END; 

  IF (l_count > 0) THEN    

    l_debug_info := 'Prompting the invoices ';
    l_message := ' Following invoices is having  posted flags are incorrect for accounted invoices'||
                 ' .Follow the note 1071876.1';
    AP_ACCTG_DATA_FIX_PKG.Print(l_message);
    l_message :=  '_______________________________________'||
                  '_______________________________________';
    AP_ACCTG_DATA_FIX_PKG.Print(l_message);

    l_debug_info := 'Constructing the select columns ';
 
    l_select_list :=
           'INVOICE_ID,'||
           'INVOICE_NUM,'||
           'INVOICE_LINE_NUMBER,'||
           'DISTRIBUTION_LINE_NUMBER,'||
		   'TRX_TABLE,'||
		   'TRX_ID,'||
		   'ACCRUAL_POSTED_FLAG,'||
		   'CASH_POSTED_FLAG,'||
           'EVENT_ID,'||
           'ORG_ID,'||
           'LEDGER_ID'
         ;

    l_debug_info := 'Getting the table name ';
    l_table_name := l_driver_tab;

    l_debug_info := 'Constructing the where clause ';

    l_where_clause :=
           'ORDER BY ORG_ID, LEDGER_ID, INVOICE_ID, INVOICE_LINE_NUMBER,'||
           ' DISTRIBUTION_LINE_NUMBER, EVENT_ID';

    l_debug_info := 'Before calling the Print HTML';
    AP_ACCTG_DATA_FIX_PKG.Print_html_table
      (p_select_list       => l_select_list,
       p_table_in          => l_table_name,
       p_where_in          => l_where_clause,
       P_calling_sequence  => l_calling_sequence);
       
  ELSE 
    l_message := 'No Data to be corrected';
    AP_Acctg_Data_Fix_PKG.Print(l_message);
  END IF;

  IF (l_count1 > 0) THEN    

    l_debug_info := 'Prompting the payments ';
    l_message := ' Following payments is having  posted flags are incorrect for accounted payments'||
                 ' .Follow the note 1071876.1';
				 AP_ACCTG_DATA_FIX_PKG.Print(l_message);
    l_message :=  '_______________________________________'||
                  '_______________________________________';
    AP_ACCTG_DATA_FIX_PKG.Print(l_message);

    l_debug_info := 'Constructing the select columns ';
 
    l_select_list :=
           'CHECK_ID,'||
           'CHECK_NUMBER,'||    
		   'TRX_TABLE,'||
		   'TRX_ID,'||
		   'ACCRUAL_POSTED_FLAG,'||
		   'CASH_POSTED_FLAG,'||
           'EVENT_ID,'||
           'ORG_ID,'||
           'LEDGER_ID'
         ;

    l_debug_info := 'Getting the table name ';
    l_table_name := l_driver_tab1;

    l_debug_info := 'Constructing the where clause ';

    l_where_clause :=
           'ORDER BY ORG_ID, LEDGER_ID, CHECK_ID, EVENT_ID';

    l_debug_info := 'Before calling the Print HTML';
    AP_ACCTG_DATA_FIX_PKG.Print_html_table
      (p_select_list       => l_select_list,
       p_table_in          => l_table_name,
       p_where_in          => l_where_clause,
       P_calling_sequence  => l_calling_sequence);
       
  ELSE 
    l_message := 'No Data to be corrected';
    AP_Acctg_Data_Fix_PKG.Print(l_message);
  END IF;
  
  EXCEPTION 
    WHEN OTHERS THEN
      l_message :=  'Error  '|| SQLCODE||';'||SQLERRM ||'<p>';
      AP_Acctg_Data_Fix_PKG.Print(l_message);
  
  END;
  
  
/*+=======================================================================+
| FILENAME                                                              |
|     ap_party_id_mismatch_sel.sql                                      |
|                                                                       |
| DESCRIPTION                                                           |
|     Identify upgraded invoices with multiple parties and show the     |
|     accociated accounting line(xla_ae_lines) and trial balance        |
|     (xla_trial_balances) data along with the new party information.   |
+=======================================================================+*/


BEGIN

  --------------------------------------------------------
  -------- 1. Drop the tables, if already existing ---------
  --------------------------------------------------------
  BEGIN
    EXECUTE Immediate 'Drop table inv_with_multi_parties_9109280';
  EXCEPTION
  WHEN OTHERS THEN
   NULL;
  END;
  BEGIN
    EXECUTE Immediate 'Drop table affected_invs_pmts_9109280';
  EXCEPTION
  WHEN OTHERS THEN
   NULL;
  END;
  BEGIN
    EXECUTE Immediate 'Drop table ap_temp_data_driver_9109280';
  EXCEPTION
  WHEN OTHERS THEN
    NULL;
  END;
  BEGIN
    EXECUTE Immediate 'Drop table xtb_temp_data_bkp_9109280';
  EXCEPTION
  WHEN OTHERS THEN
    NULL;
  END;
   
  --------------------------------------------------------------------------
  ------- 2. Get all the upgraded invoice ids with multiple parties --------
  --------------------------------------------------------------------------
  BEGIN
    EXECUTE Immediate 
         'CREATE TABLE inv_with_multi_parties_9109280 AS  
           SELECT /*+ parallel(ael) full(ael) */    
                  ael.reference2 "INVOICE_ID",    
                  COUNT(DISTINCT ael.third_party_id ) "NUMBER_OF_PARTIES"  
             FROM ap_ae_lines_all ael  
            WHERE ael.ae_line_type_code = ''LIABILITY''  
            GROUP BY ael.reference2  
           HAVING COUNT(DISTINCT ael.third_party_id ) > 1' ;
  EXCEPTION
  WHEN OTHERS THEN
    AP_Acctg_Data_Fix_PKG.Print('could not create inv_with_multi_parties_9109280' ||sqlerrm);
  END;
  
  -----------------------------------------------------------------------------------------------
  -------- 3. Get the required info for all problematic invoices and associated payments -------
  -----------------------------------------------------------------------------------------------
  BEGIN
    EXECUTE Immediate
    ' CREATE TABLE affected_invs_pmts_9109280 AS
      SELECT DISTINCT              
             inv_pay_info.orig_invoice,              
	     inv_pay_info.ael_source_table,              
	     inv_pay_info.ael_source_id,              
	     xte.*,
             tiv.invoice_num,
             tiv.party_name
        FROM xla_transaction_entities_upg xte ,  
             AP_SLA_INVOICES_TRANSACTION_V tiv,
	    (SELECT /*+parallel(dat)*/DISTINCT     
                    dat.invoice_id "ORIG_INVOICE",    
 		    inv.invoice_id xte_source_id,    
		    ''AP_INVOICES'' xte_source_table,    
		    inv.invoice_id ael_source_id ,        
		    ''AP_INVOICES'' ael_source_table ,        
		    inv.set_of_books_id       
	       FROM inv_with_multi_parties_9109280 dat ,             
		    ap_invoices_all inv  
              WHERE dat.invoice_id = inv.invoice_id    
   	      UNION    
	      SELECT /*+parallel(dat)*/DISTINCT     
  		    dat.invoice_id "ORIG_INVOICE",    
		    invpay.check_id xte_source_id,    
		    ''AP_PAYMENTS'' xte_source_table,    
		    invpay.invoice_payment_id ael_source_id ,        
		    ''AP_INVOICE_PAYMENTS'' ael_source_table ,    
		    invpay.set_of_books_id   
	       FROM inv_with_multi_parties_9109280 dat ,    
		    ap_invoice_payments_all invpay  
	      WHERE dat.invoice_id = invpay.invoice_id  
   	     ) inv_pay_info
       WHERE xte.application_id            = 200
         AND inv_pay_info.orig_invoice = tiv.invoice_id
         AND xte.ledger_id                   = inv_pay_info.set_of_books_id
         AND xte.entity_code                 = inv_pay_info.xte_source_table
         AND NVL(xte.source_id_int_1 , -99 ) = inv_pay_info.xte_source_id
         AND NVL(xte.source_id_int_2 , -99 ) = -99
         AND NVL(xte.source_id_int_3 , -99 ) = -99
         AND NVL(xte.source_id_int_4 , -99 ) = -99
         AND NVL(xte.SOURCE_ID_CHAR_1,'' '')   = '' ''
         AND NVL(xte.SOURCE_ID_CHAR_2,'' '')   = '' ''
         AND NVL(xte.SOURCE_ID_CHAR_3,'' '')   = '' ''
         AND NVL(xte.SOURCE_ID_CHAR_4,'' '')   = '' '' ' ;
  EXCEPTION
  WHEN OTHERS THEN
    AP_Acctg_Data_Fix_PKG.Print('could not create affected_invs_pmts_9109280' ||sqlerrm);
  END;
  
  ------------------------------------------------------------------------------
  -------- 4. Create the driver table along with the new party information -----
  ------------------------------------------------------------------------------
  BEGIN
    EXECUTE Immediate
     'CREATE TABLE ap_temp_data_driver_9109280 AS  
      SELECT v.*, ''Y'' process_flag 
        FROM (SELECT /*+ parallel(xte) */ DISTINCT                 
                     xte.invoice_num,
                     xte.party_name,
                     xal.ae_header_id,     
                     xal.ae_line_num,     
                     xal.party_id,     
                     xal.party_site_id,                 
                     inv.party_id new_party_id,                 
                     inv.party_site_id  new_party_site_id,     
                     xal.source_id,     
                     xal.source_table,                      
                     xte.orig_invoice invoice_id,
                     xah.entity_id source_entity_id,
                     inv.entity_id applied_to_entity_id,
                     xah.ledger_id
                FROM affected_invs_pmts_9109280 xte,    
                     xla_ae_headers xah,    
                     xla_ae_lines xal,    
                     (SELECT /*+ parallel(xte_inv) */ DISTINCT       
                             xal_inv.party_id,      
                             xal_inv.party_site_id,      
                             xte_inv.orig_invoice,      
                             xah_inv.entity_id,
                             rank() OVER (PARTITION BY xte_inv.entity_id                                                                            ORDER BY xah_inv.upg_batch_id DESC,
                                                       xah_inv.ae_header_id DESC,                                                                            xal_inv.ae_line_num DESC) rank    
                        FROM xla_ae_headers xah_inv,      
                             xla_ae_lines xal_inv,      
                             affected_invs_pmts_9109280 xte_inv    
                      WHERE 1 = 1    
                        AND xte_inv.entity_code = ''AP_INVOICES''       
                        AND xah_inv.entity_id =  xte_inv.entity_id    
                        AND xah_inv.ledger_id =   xte_inv.ledger_id        
                        AND xah_inv.accounting_entry_status_code = ''F''    
                        AND xah_inv.gl_transfer_status_code      = ''Y''    
                        AND xah_inv.application_id               = 200    
                        AND xal_inv.ae_header_id                 = xah_inv.ae_header_id    
                        AND xal_inv.accounting_class_code        = ''LIABILITY''    
                        AND xah_inv.event_type_code not like ''PREPAY%APPL%''    
                        AND xal_inv.application_id               = 200    
                       ) inv  
               WHERE 1=1  
                 AND xah.entity_id             = xte.entity_id  
                 AND xah.upg_batch_id         IS NOT NULL  
                 AND xah.upg_batch_id NOT     IN (-9999, -5672)  
                 AND xah.application_id        = 200  
                 AND xal.ae_header_id          = xah.ae_header_id  
                 AND xal.accounting_class_code = ''LIABILITY''  
                 AND xal.source_table          = xte.ael_source_table  
                 AND xal.source_id             = xte.ael_source_id  
                 AND nvl(xal.gl_sl_link_id , 0)      >= 0  
                 AND xal.application_id        = 200  
                 AND xte.orig_invoice          = inv.orig_invoice(+)  
                 AND inv.rank(+)               = 1  
             ) v
       WHERE v.new_party_id IS NOT NULL
         AND v.new_party_site_id IS NOT NULL
         AND (v.party_id   <> v.new_party_id OR v.party_site_id <> v.new_party_site_id)';
  EXCEPTION
  WHEN OTHERS THEN
    AP_Acctg_Data_Fix_PKG.Print('could not create ap_temp_data_driver_9109280' ||sqlerrm);
  END;
  
  BEGIN
    EXECUTE IMMEDIATE
    'CREATE TABLE xtb_temp_data_bkp_9109280 AS
     SELECT /*+ parallel(xtb) */
	    xtb.rowid "ROW_ID" ,
	    bk.new_party_id ,
	    bk.new_party_site_id ,	
	    xtb.*,
            bk.invoice_num,
            bk.party_name
       FROM xla_trial_balances xtb ,
       	    ap_temp_data_driver_9109280 bk
      WHERE bk.ae_header_id  = xtb.ae_header_id
	AND bk.source_entity_id  = xtb.source_entity_id
	AND NVL(bk.applied_to_entity_id,bk.source_entity_id) = 
                  NVL( xtb.applied_to_entity_id , xtb.source_entity_id )' ;
  EXCEPTION
  WHEN OTHERS THEN
    AP_Acctg_Data_Fix_PKG.Print('could not create xtb_temp_data_bkp_9109280' ||sqlerrm);
  END;
  
  BEGIN
    EXECUTE IMMEDIATE
    'SELECT COUNT(*)
       FROM ap_temp_data_driver_9109280' 
       INTO l_count;
  EXCEPTION
  WHEN OTHERS THEN
     AP_Acctg_Data_Fix_PKG.Print('could not query on ap_temp_data_driver_9109280' ||sqlerrm);	
  END;

  IF (l_count > 0) THEN
  l_message := '_______________________________________'||
                 '_______________________________________'||
				 '_______________________________________'||
				 '_______________________________________';
    AP_Acctg_Data_Fix_PKG.Print(l_message); 
    AP_Acctg_Data_Fix_PKG.Print('*****Below are upgraded invoices on Trial Balance due to Party ID mismatch (Doc ID 1083599.1)in XLA_AE_LINES table*****');
    BEGIN
      AP_Acctg_Data_Fix_PKG.Print_html_table (
                 upper('invoice_num,party_name,ae_header_id,ae_line_num,party_id,party_site_id,new_party_id,')|| 
                 upper('new_party_site_id,source_id,source_table,invoice_id'), 
                 upper('ap_temp_data_driver_9109280'), 
                 NULL, 
                 'ap_party_id_mismatch_sel.sql');
    EXCEPTION
    WHEN OTHERS THEN
      AP_Acctg_Data_Fix_PKG.Print('exception while printing xla ae lines' ||sqlerrm);
    END;
    
	AP_Acctg_Data_Fix_PKG.Print('*****Below are upgraded invoices on Trial Balance due to Party ID mismatch (Doc ID 1083599.1)in XLA_TRIAL_BALANCES table*****');
    
   BEGIN
      AP_Acctg_Data_Fix_PKG.Print_html_table (
                 upper('invoice_num,party_name,ae_header_id,definition_code,ledger_id,record_type_code,')|| 
                 upper('source_entity_id,applied_to_entity_id,event_class_code,')||
                 upper('party_id,party_site_id,new_party_id,new_party_site_id'), 
                 upper('xtb_temp_data_bkp_9109280'), 
                 NULL, 
                 'ap_party_id_mismatch_sel.sql');
				 
        l_message := '_______________________________________'||
                 '_______________________________________'||
				 '_______________________________________'||
				 '_______________________________________';
    AP_Acctg_Data_Fix_PKG.Print(l_message); 				 
    EXCEPTION
    WHEN OTHERS THEN
      AP_Acctg_Data_Fix_PKG.Print('exception while prinitng xla trial balances' ||sqlerrm);
    END;
ELSE
    AP_Acctg_Data_Fix_PKG.Print('*** No Data is Corrupted ***');
	l_message := '_______________________________________'||
                 '_______________________________________'||
				 '_______________________________________'||
				 '_______________________________________';
    AP_Acctg_Data_Fix_PKG.Print(l_message); 
  END IF;	


  EXCEPTION 
    WHEN OTHERS THEN
      l_message :=  'Error  '|| SQLCODE||';'||SQLERRM ||'<p>';
      AP_Acctg_Data_Fix_PKG.Print(l_message);
  
  END;
  
/*+=======================================================================+
| FILENAME                                                              |
|     ap_aipXprorateWithDisc_sel.sql                                    |
|                                                                       |
| DESCRIPTION                                                           |
| Issue    :						   	        |
| ------------------------						|
| Payment accounting is going wrong when there is discount bug8975671   |
| Scenario :							        |
+=======================================================================+*/

BEGIN

  --------------------------------------------------------------------------
  -- STEP 1: DROP THE TEMPORARY TABLES IF ALREADY EXISTS
  --------------------------------------------------------------------------
  l_bug_no:='9244675';
  l_driver_tab    := 'AP_TEMP_DATA_DRIVER_'||l_bug_no;
  l_undoAcctg_tab := 'AP_PAY_EVENTS_'||l_bug_no;
  BEGIN
     l_sql_stmt :=
          ' DROP TABLE '||l_driver_tab;
    EXECUTE IMMEDIATE l_sql_stmt;

  EXCEPTION
    WHEN OTHERS THEN
      NULL;
  END;

  BEGIN
     l_sql_stmt :=
          ' DROP TABLE '||l_undoAcctg_tab;
    EXECUTE IMMEDIATE l_sql_stmt;

  EXCEPTION
    WHEN OTHERS THEN
      NULL;
  END;

  --------------------------------------------------------------------------
  -- STEP 2: CREATE DRIVER TABLES AND TABLE FOR UNDO ACCTG
  --------------------------------------------------------------------------
  
  l_sql_stmt :=
          'CREATE TABLE '||l_driver_tab||
          '   AS '||
          'SELECT ac.check_id,                                          '||
	  '       ac.check_number,                                      '||
	  '       ac.org_id,                                            '||
	  '       ac.check_date,                                        '||
	  '       ac.vendor_name,                                       '||
	  '       ac.amount check_amount,                               '||
	  '       aip.invoice_payment_id,                               '||
	  '       aip.amount,                                           '||
	  '       aip.discount_taken,                                   '||
	  '       aip.invoice_id,                                       '||
	  '       aph.transaction_type,                                 '||
	  '       aph.accounting_event_id,                              '|| 
          '       aph.accounting_date,                                  '|| 
	  '       aph.posted_flag,                                      '||
	  '       aph.historical_flag,                                  '||
	  '       ''Y'' process_flag                                    '||
	  '  FROM ap_checks_all ac,                                     '||
          '       ap_invoice_payments_all aip,                          '||
	  '       ap_payment_history_all aph                            '||
          ' WHERE aip.check_id = ac.check_id                            '||
          '   AND ac.void_date IS NULL                                  '||
	  '   AND aph.check_id = aip.check_id                           '||
	  '   AND aph.accounting_event_id = aip.accounting_event_id     '||
          '   AND aip.discount_taken <> 0                               '||
          '   AND aip.posted_flag = ''Y''                               '||
          '   AND aip.reversal_inv_pmt_id IS NULL                       '||
          '   AND aip.amount - NVL(aip.discount_taken, 0) =             '||
          '  (                                                          '||
          '    SELECT SUM(aphd.amount)                                  '||
          '      FROM ap_payment_hist_dists aphd                        '||
          '     WHERE aphd.invoice_payment_id = aip.invoice_payment_id  '||
          '       AND aphd.accounting_event_id = aip.accounting_event_id'||
          '       AND aphd.pay_dist_lookup_code = ''CASH''              '||
          '  )                                                          '||
          '  AND EXISTS                                                 '||
          '  (                                                          '||
          '  SELECT 1                                                   '||
          '    FROM xla_ae_headers xah                                  '||
          '   WHERE xah.event_id = aip.accounting_event_id              '||
          '     AND xah.application_id = 200                            '||
          '     AND xah.ledger_id = aip.set_of_books_id                 '||
          '     AND xah.balance_type_code = ''A''                       '||
          '     AND xah.upg_batch_id IS NULL                            '||
          '   )';

  EXECUTE IMMEDIATE l_sql_stmt;

  
  l_sql_stmt :=
          'CREATE TABLE '||l_undoAcctg_tab||
          '   AS '||
          'SELECT aph.check_id,                                         '||
	  '       atdd.check_number,                                    '||
	  '       aph.org_id,                                           '||
	  '       aph.accounting_date,                                  '||
	  '       aph.accounting_event_id event_id,                     '|| 
          '       aph.transaction_type,                                 '|| 
	  '       aph.posted_flag,                                      '||
	  '       aph.historical_flag,                                  '||
	  '       ''Y'' process_flag                                    '||
	  '  FROM ap_payment_history_all aph,                           '||
                  l_driver_tab ||' atdd	                                '||
          ' WHERE atdd.check_id = aph.check_id                          '||
          '   AND aph.posted_flag = ''Y'' ';


  EXECUTE IMMEDIATE l_sql_stmt;

  ------------------------------------------------------------------
  -- STEP 3: REPORT ALL THE AFFECTED TRANSACTIONS IN LOG FILE 
  ---------------------------------------------------------------------
  Begin
    Execute Immediate  
        'SELECT COUNT(*) from AP_TEMP_DATA_DRIVER_9244675' into l_count;
  EXCEPTION
    WHEN OTHERS THEN
          l_message := 'Exception in selecting count from '|| 
		       l_driver_tab||' for selecting affected records'||
		       SQLERRM ;
          AP_ACCTG_DATA_FIX_PKG.Print(l_message);
  END; 

  IF (l_count > 0) THEN    

    l_debug_info := ' Prompting the transactions ';
    l_message    := '****Accounting is wrong for the following invoice payments. Follow the note 1089119.1****';

    AP_ACCTG_DATA_FIX_PKG.Print(l_message);
    l_message    :=  '_______________________________________'||
                     '_______________________________________';
    AP_ACCTG_DATA_FIX_PKG.Print(l_message);

    l_debug_info := ' Getting the table name ';
    l_table_name := l_driver_tab;

    l_debug_info := ' Constructing the where clause ';

    l_where_clause :=
           'ORDER BY ORG_ID, CHECK_DATE DESC';

    l_debug_info := 'Before calling the Print HTML first time';
    AP_ACCTG_DATA_FIX_PKG.Print_html_table
      (p_select_list       => 'CHECK_ID,CHECK_NUMBER,ORG_ID,CHECK_DATE,'||
       'VENDOR_NAME,CHECK_AMOUNT,INVOICE_PAYMENT_ID,INVOICE_ID,AMOUNT,'||
       'DISCOUNT_TAKEN,TRANSACTION_TYPE,ACCOUNTING_EVENT_ID,'||
       'ACCOUNTING_DATE,POSTED_FLAG,HISTORICAL_FLAG,PROCESS_FLAG',
       p_table_in          => l_table_name,
       p_where_in          => l_where_clause,
       P_calling_sequence  => l_calling_sequence);

    l_debug_info := ' Displaying table for undo accounting';
    l_message    := '****Undo accounting needs to be done for the following events Follow the note 1089119.1****';

    AP_ACCTG_DATA_FIX_PKG.Print(l_message);
    l_message    :=  '_______________________________________'||
                     '_______________________________________';
    AP_ACCTG_DATA_FIX_PKG.Print(l_message);

    l_debug_info := ' Getting the table name for undo acctg';
    l_table_name := l_undoAcctg_tab;

    l_debug_info := ' Constructing the where clause for display of undo acctg entries';

    l_where_clause :=
           'ORDER BY CHECK_ID, ORG_ID';

    l_debug_info := 'Before calling the Print HTML for second time';
    AP_ACCTG_DATA_FIX_PKG.Print_html_table
      (p_select_list       => 'CHECK_ID,CHECK_NUMBER,ORG_ID,ACCOUNTING_DATE,'||
       'EVENT_ID,TRANSACTION_TYPE,POSTED_FLAG,HISTORICAL_FLAG,PROCESS_FLAG' ,
       p_table_in          => l_table_name,
       p_where_in          => l_where_clause,
       P_calling_sequence  => l_calling_sequence);
	l_message    :=  '_______________________________________'||
                     '_______________________________________';
    AP_ACCTG_DATA_FIX_PKG.Print(l_message);
   

 ELSE 
    l_message := '****No Data to be corrected as per note 1089119.1(Payment accounting is wrong when there is discount)****';
    AP_Acctg_Data_Fix_PKG.Print(l_message);
	
	l_message    :=  '_______________________________________'||
                     '_______________________________________';
    AP_ACCTG_DATA_FIX_PKG.Print(l_message);

  END IF;  
	   

EXCEPTION 
    WHEN OTHERS THEN
      l_message :=  'Error  '|| SQLCODE||';'||SQLERRM ||'<p>';
      AP_Acctg_Data_Fix_PKG.Print(l_message);
  
  END;
  
  
/*+=======================================================================+
| FILENAME                                                              |
|     ap_quick_manual_adj_sel.sql                                       |
|                                                                       |
| DESCRIPTION                                                           |
|     Script to select the manual payment adjusted events created       |
|     for a quick payment                                               |
+=======================================================================+*/
BEGIN
  
  
   --------------------------------------------------------------------------
  -- Step 1: Drop the temporary tables if already exists
  --------------------------------------------------------------------------
  --AP_Acctg_Data_Fix_PKG.Print('Dropping and Creating Driver tables');
  Begin
    Execute Immediate
      'Drop table ap_temp_data_driver_9105901';  

  EXCEPTION
    WHEN OTHERS THEN
      NULL;
      
  END;
  
  
  
  Begin
    Execute Immediate
      'CREATE TABLE ap_temp_data_driver_9105901
       AS
       ( select /* +PARALLEL(aph)*/ ac.check_number,aph.*,
                ''Y'' PROCESS_FLAG
           from ap_checks_all ac,
                ap_payment_history_all aph
          where ac.check_id = aph.check_id
            and ac.payment_type_flag = ''Q''
            and aph.transaction_type like ''MANUAL PAYMENT ADJUSTED''
            and aph.posted_flag <> ''Y''
	    and not exists ( select ''No invoice associated''
	                       from ap_invoice_payments_all aip
			      where aip.accounting_event_id = aph.accounting_event_id)	
        )' ;
		  
	
  EXCEPTION
     WHEN OTHERS THEN
       AP_Acctg_Data_Fix_PKG.Print('could not create ap_temp_data_driver_9105901'
       ||sqlerrm);
  END;
   
    
   
   
  ------------------------------------------------------------------
  -- Step 2: Report all the affected events in Log file 
  ---------------------------------------------------------------------
  Begin
    Execute Immediate 
    'SELECT count(*) 
       FROM ap_temp_data_driver_9105901'
       INTO l_count ;
  EXCEPTION
     WHEN OTHERS THEN
          AP_Acctg_Data_Fix_PKG.Print('Exception in getting count from '|| 
		                       'ap_temp_data_driver_9105901 - '||SQLERRM);
  End;  
  
  IF (l_count > 0) THEN 
    AP_Acctg_Data_Fix_PKG.Print('*** Below are Incorrect manual payment adjusted events.Follow note 1089156.1***');            
    BEGIN
      AP_Acctg_Data_Fix_PKG.Print_html_table                           
       ('CHECK_NUMBER,CHECK_ID,ACCOUNTING_EVENT_ID,ORG_ID,TRANSACTION_TYPE,POSTED_FLAG',
        'ap_temp_data_driver_9105901',                                
        null,                                                         
        'ap_quick_manual_adj_sel.sql');    
l_message    :=  '_______________________________________'||
                     '_______________________________________';
    AP_ACCTG_DATA_FIX_PKG.Print(l_message);
		
    EXCEPTION                                                          
       WHEN OTHERS THEN
       NULL;
    END;
	ELSE 
    AP_Acctg_Data_Fix_PKG.Print('*** No Data is Corrupted as per note 1089156.1***');
	l_message    :=  '_______________________________________'||
                     '_______________________________________';
    AP_ACCTG_DATA_FIX_PKG.Print(l_message);

  END IF;

EXCEPTION 
    WHEN OTHERS THEN
      l_message :=  'Error  '|| SQLCODE||';'||SQLERRM ||'<p>';
      AP_Acctg_Data_Fix_PKG.Print(l_message);
  
  END;
  
  
/*+===========================================================================+
| FILENAME                                                                  |
|     ap_rel_evnt_id_upg_sel.sql                                            |
|                                                                           |
| DESCRIPTION                                                               |
|     This script will select transaction data that does not have           |
|     the related event id stamped for payment reversal events              |
+===========================================================================+*/

BEGIN
   --------------------------------------------------------------------------
   -- Step 1: Drop the temporary tables if already exists
   --------------------------------------------------------------------------
   

   BEGIN	
      Execute Immediate
         'DROP TABLE ap_temp_data_driver_H8969038';

   EXCEPTION
      WHEN OTHERS THEN
        NULL;
   END;
 
   --------------------------------------------------------------------------
   -- Step 2: create temp driver tables
   --------------------------------------------------------------------------
   
   
Execute Immediate
      'CREATE TABLE ap_temp_data_driver_H8969038 AS
           SELECT ac.check_number,
                  aph.check_id,
                  check_date,
		  transaction_type,
		  payment_history_id,
		  accounting_event_id,
	 	  rev_pmt_hist_id,
		  related_event_id,              
		  posted_flag, 
		  historical_flag,
		  aph.org_id,
		  ''Y'' process_flag
       FROM ap_payment_history_all aph,
       ap_checks_all ac
       WHERE ac.check_id= aph.check_id
       AND ac.org_id= aph.org_id
       AND 1=2';
   

   --------------------------------------------------------------------------
   -- Step 3:  Insert data into  temp driver tables
   --------------------------------------------------------------------------
   
   
   Execute Immediate
      'INSERT INTO ap_temp_data_driver_H8969038  
       SELECT ac.check_number,
                  aph.check_id,
                  check_date,
		  transaction_type,
		  payment_history_id,
		  accounting_event_id,
		  rev_pmt_hist_id,
		  related_event_id,
		  posted_flag,
		  historical_flag,
	          aph.org_id,
		  ''Y'' process_flag
	FROM ap_payment_history_all aph,
 	ap_checks_all ac
	WHERE related_event_id         IS NULL
	AND transaction_type           IN 
			(''PAYMENT CANCELLED'', ''PAYMENT UNCLEARING'', ''PAYMENT MATURITY REVERSAL'', ''REFUND CANCELLED'')
	AND NVL(historical_flag, ''N'') = ''Y''
	AND posted_flag                <> ''Y''
	AND rev_pmt_hist_id            IS NOT NULL
	AND ac.check_id= aph.check_id
        AND ac.org_id= aph.org_id';   
    

   ------------------------------------------------------------------
   -- Step 4: Report all the affected transactions in Log file 
   ---------------------------------------------------------------------
   
   -- Payment History
   Execute Immediate  
      'SELECT COUNT(*) FROM ap_temp_data_driver_H8969038' into l_count1;

   

  
   IF (l_count1 > 0) THEN 
      AP_Acctg_Data_Fix_PKG.Print('****Details of affected Payment History Records where Related_event_id missing on reversal events (upgraded). Follow the note 1089168.1****');            
  
      BEGIN
    	
         AP_Acctg_Data_Fix_PKG.Print_html_table  	                       
            ('CHECK_NUMBER,CHECK_ID,CHECK_DATE,TRANSACTION_TYPE,PAYMENT_HISTORY_ID,ACCOUNTING_EVENT_ID,'||
		     'REV_PMT_HIST_ID,RELATED_EVENT_ID,POSTED_FLAG,HISTORICAL_FLAG,ORG_ID,PROCESS_FLAG',
             'ap_temp_data_driver_H8969038',
              NULL,
             'ap_rel_evnt_id_upg_sel.sql ');    
			 l_message    :=  '_______________________________________'||
                     '_______________________________________';
    AP_ACCTG_DATA_FIX_PKG.Print(l_message);

                                 
      EXCEPTION                                                          
         WHEN OTHERS THEN
            l_message := 'EXCEPTION :: '||SQLERRM ||
                         'in call to AP_Acctg_Data_Fix_PKG.Print_html_table '||
                         'during printing data from ap_temp_data_driver_H8969038';
            AP_Acctg_Data_Fix_PKG.Print(l_message);
			l_message    :=  '_______________________________________'||
                     '_______________________________________';
    AP_ACCTG_DATA_FIX_PKG.Print(l_message);

	    
      END;
   ELSE
      AP_Acctg_Data_Fix_PKG.Print('****No Payment History records found as per note 1089168.1****');            
   END IF;



EXCEPTION 
    WHEN OTHERS THEN
      l_message :=  'Error  '|| SQLCODE||';'||SQLERRM ||'<p>';
      AP_Acctg_Data_Fix_PKG.Print(l_message);
  
  END;
  
/*+=======================================================================+
| FILENAME                                                              |
|     ap_posted_flag_out_sync_sel.sql                                   |
|                                                                       |
| DESCRIPTION                                                           |
|     This script reports all records in transactions that have         |
|     posted_flag as 'S'. This is a temporary status that is used by    |
|     Create Accounting process .                                       |
|     The valid values are 'Y' and 'N'                                  |
+=======================================================================+*/

BEGIN
  
  --------------------------------------------------------------------------
  -- Step 1: Drop the temporary tables if already exists
  --------------------------------------------------------------------------
  AP_Acctg_Data_Fix_PKG.Print('Dropping and Creating Driver tables');

  Begin
    Execute Immediate
      'Drop table ap_temp_data_driver_6979118';

  EXCEPTION
    WHEN OTHERS THEN
    NULL;
  END;

  Begin
    Execute Immediate
      'CREATE TABLE ap_temp_data_driver_6979118(
	    invoice_id NUMBER(15),
	    invoice_distribution_id NUMBER(15),
        distribution_line_number NUMBER(15),
        invoice_num VARCHAR2(50), 
        posted_flag VARCHAR2(1), 
        Event_Status_Code VARCHAR2(1),
        check_number NUMBER(15),
        invoice_payment_id NUMBER(15),
        payment_history_id NUMBER(15),
        event_id NUMBER(15),
        org_id NUMBER(15),
        events_posted_flag VARCHAR2(1)
    )';
  EXCEPTION
     WHEN OTHERS THEN
       AP_Acctg_Data_Fix_PKG.Print('could not create ap_temp_data_driver_6979118'
	   ||sqlerrm);
   END;
   
    
 /*********  OUT-OF-SYNC POSTED_FLAG IN AP_DISTRIBUTIONS_ALL TABLE  **********/
  Begin
    Execute Immediate
     'Insert into ap_temp_data_driver_6979118
          (
           invoice_id, 
           invoice_distribution_id,
           distribution_line_number,
           invoice_num,
           posted_flag,
           event_status_code,
           event_id,
           org_id,
		   events_posted_flag 
          )
     (SELECT   aid.invoice_id, invoice_distribution_id, distribution_line_number
               ,invoice_num, posted_flag, event_status_code, event_id,aid.org_id
               ,decode(event_status_code, ''P'',''Y'',''N'') events_posted_flag
        FROM   ap_invoice_distributions_all aid,
               ap_invoices_all ai,
               xla_events xe
       WHERE   posted_flag = ''S''
	     AND   xe.event_id = aid.accounting_event_id
		 AND   ai.invoice_id = aid.invoice_id)';
  EXCEPTION
     WHEN OTHERS THEN
           AP_Acctg_Data_Fix_PKG.Print('Exception in inserting records into '|| 
		                       'ap_temp_data_driver_6979118 - '||SQLERRM);
  END;     

 /*********  OUT-OF-SYNC POSTED_FLAG IN AP_INVOICE_PAYMENTS_ALL TABLE  *******
  ***/
  Begin
    Execute Immediate
     'Insert into ap_temp_data_driver_6979118
          (
           invoice_id, 
           invoice_payment_id,
           invoice_num,
           posted_flag,
           event_status_code,
           event_id,
           check_number,
           org_id,
           events_posted_flag
          )
     (SELECT   aip.invoice_id, invoice_payment_id, invoice_num, posted_flag,
               event_status_code, event_id, check_number, aip.org_id,
               decode(event_status_code, ''P'',''Y'',''N'') events_posted_flag
        FROM   ap_invoice_payments_all aip,
               ap_checks_all ac,
               xla_events xe,
               ap_invoices_all ai
       WHERE   posted_flag = ''S''
	     AND   xe.event_id = aip.accounting_event_id
		 AND   ac.check_id = aip.check_id	
         AND   ai.invoice_id = aip.invoice_id )';
  EXCEPTION
     WHEN OTHERS THEN
           AP_Acctg_Data_Fix_PKG.Print(' Exception in inserting records into '|| 
		                       'ap_temp_data_driver_6979118 - '||SQLERRM);
  END; 
  
/*********  OUT-OF-SYNC POSTED_FLAG IN AP_PAYMENT_HISTORY_ALL TABLE  **********/
  Begin
    Execute Immediate
     'Insert into ap_temp_data_driver_6979118
          (
           payment_history_id, posted_flag, event_status_code, event_id 
		   ,check_number,org_id,events_posted_flag
          )
     (SELECT   payment_history_id, posted_flag, event_status_code, event_id ,
	           check_number,aph.org_id,
			   decode(event_status_code, ''P'',''Y'',''N'') events_posted_flag
        FROM   ap_payment_history_all aph,
               xla_events xe,
               ap_checks_all ac
       WHERE   posted_flag = ''S''
	     AND   xe.event_id = aph.accounting_event_id
		 AND   ac.check_id = aph.check_id )';
  EXCEPTION
     WHEN OTHERS THEN
           AP_Acctg_Data_Fix_PKG.Print(' Exception in inserting records into '|| 
		                       'ap_temp_data_driver_6979118 - '||SQLERRM);
  END;      

  ------------------------------------------------------------------
  -- Step 3: Report all the affected transactions in Log file 
  ---------------------------------------------------------------------
  Begin
    Execute Immediate 
      'SELECT count(*) 
         FROM ap_temp_data_driver_6979118
        WHERE invoice_distribution_id IS NOT NULL' INTO l_count; 
  EXCEPTION
     WHEN OTHERS THEN
           AP_Acctg_Data_Fix_PKG.Print(' Exception in getting count '||
	                               'for invoice distribution from '|| 
		                       'ap_temp_data_driver_6979118 - '||SQLERRM);
  END; 


  IF (l_count > 0) THEN 
    AP_Acctg_Data_Fix_PKG.Print('******* Below are the records '||
      'having posted flag S in AP_INVOICE_DISTRIBUTIONS_ALL. Follow the note 1088872.1 *******');            
    BEGIN
      AP_Acctg_Data_Fix_PKG.Print_html_table                           
       ('INVOICE_NUM,DISTRIBUTION_LINE_NUMBER,INVOICE_ID,'||
	    'INVOICE_DISTRIBUTION_ID,POSTED_FLAG,'||
		'EVENT_STATUS_CODE,ORG_ID',
        'ap_temp_data_driver_6979118',                                
        'WHERE invoice_distribution_id IS NOT NULL',                                                         
        'ap_posted_flag_out_sync_sel.sql');   
l_message    :=  '_______________________________________'||
                     '_______________________________________';
    AP_ACCTG_DATA_FIX_PKG.Print(l_message);		
    EXCEPTION                                                          
       WHEN OTHERS THEN
       NULL;
    END;
  END IF;

  Begin
    Execute Immediate 
       'SELECT count(*) 
          FROM ap_temp_data_driver_6979118
         WHERE invoice_payment_id IS NOT NULL' INTO l_count;
  EXCEPTION
    WHEN OTHERS THEN
           AP_Acctg_Data_Fix_PKG.Print(' Exception in getting count '||
	                               'for invoice payment from '|| 
		                       'ap_temp_data_driver_6979118 - '||SQLERRM);
  END; 	 

  IF (l_count > 0) THEN 
    AP_Acctg_Data_Fix_PKG.Print(
    '******* Below are  the records having posted flag S in '||
         'AP_INVOICE_PAYMENT_ALL. Please follow note 1088872.1 *******');            
    BEGIN
      AP_Acctg_Data_Fix_PKG.Print_html_table                           
       ('CHECK_NUMBER,INVOICE_NUM,INVOICE_PAYMENT_ID,POSTED_FLAG,'||
	     'EVENT_STATUS_CODE,ORG_ID',
        'ap_temp_data_driver_6979118',                                
        'invoice_payment_id IS NOT NULL',                                                         
        'ap_posted_flag_out_sync_sel.sql');   
l_message    :=  '_______________________________________'||
                     '_______________________________________';
    AP_ACCTG_DATA_FIX_PKG.Print(l_message);		
    EXCEPTION                                                          
      WHEN OTHERS THEN
      NULL;
    END;
  END IF;

  Begin
    Execute Immediate 
       'SELECT count(*) 
          FROM ap_temp_data_driver_6979118
         WHERE payment_history_id IS NOT NULL' INTO l_count;
  EXCEPTION
    WHEN OTHERS THEN
           AP_Acctg_Data_Fix_PKG.Print(' Exception in getting count '||
	                               'for payment history from '|| 
		                       'ap_temp_data_driver_6979118 - '||SQLERRM);
  END; 

  IF (l_count > 0) THEN 
    AP_Acctg_Data_Fix_PKG.Print(
    '******* Below are the records having posted flag S in '||
    'AP_PAYMENT_HISTORY_ALL. Follow note 1088872.1 *******');            
    BEGIN
      AP_Acctg_Data_Fix_PKG.Print_html_table                           
       ('CHECK_NUMBER,PAYMENT_HISTORY_ID,POSTED_FLAG,'||
	    'EVENT_STATUS_CODE,ORG_ID',
        'ap_temp_data_driver_6979118',                                
        'payment_history_id IS NOT NULL',                                                         
        'ap_posted_flag_out_sync_sel.sql'); 
l_message    :=  '_______________________________________'||
                     '_______________________________________';
    AP_ACCTG_DATA_FIX_PKG.Print(l_message);		
    EXCEPTION                                                          
      WHEN OTHERS THEN
       NULL;
    END;
  END IF;
  
  

EXCEPTION 
    WHEN OTHERS THEN
      l_message :=  'Error  '|| SQLCODE||';'||SQLERRM ||'<p>';
      AP_Acctg_Data_Fix_PKG.Print(l_message);
  
END;
----ap_prepay_bus_code_s.sql
/*REM +=======================================================================+
REM |    Copyright (c) 2001 Oracle Corporation, Redwood Shores, CA, USA     |
REM |                         All rights reserved.                          |
REM +=======================================================================+
REM | FILENAME                                                              |
REM |                                                                       |
REM | DESCRIPTION                                                           |
REM |   GDF for Business Class Code missing on Prepayment Expense Acct      |
REM |   Lines								    |
REM | HISTORY                                                               |
REM |   Created By : GAGRAWAL                                               |
REM +=======================================================================+*/

BEGIN

l_bug_no:=8966888;

l_driver_tab := 'AP_TEMP_DATA_DRIVER_'||l_bug_no;
  BEGIN
     l_sql_stmt :=
          ' DROP TABLE '||l_driver_tab;
    EXECUTE IMMEDIATE l_sql_stmt;
  EXCEPTION
    WHEN OTHERS THEN
      null;
  END;

  l_debug_info := 'Before Creating the table '||l_driver_tab;
  l_sql_stmt :=
          ' CREATE TABLE '||l_driver_tab||
          '   AS '||
          ' SELECT DISTINCT ai.invoice_id, '||
          '        ai.invoice_num, '||
          '        xe.event_id, '||
          '        xah.ae_header_id, '||
          '        xal.ae_line_num, '||
          '        xal.accounting_class_code, '||
          '        xal.entered_dr, '||
          '        xal.entered_cr, '||
          '        xal.accounted_dr, '||
          '        xal.accounted_cr, '||
          '        ''Y'' process_flag '||
          '   FROM xla_ae_lines xal, '||
          '        xla_ae_headers xah, '||
          '        xla_transaction_entities_upg xte, '||
          '        ap_invoices_all ai, '||
          '        xla_events xe '||
          '  WHERE xe.event_id = xah.event_id '||
          '    AND xah.ae_header_id = xal.ae_header_id '||
          '    AND xah.application_id = 200 '||
          '    AND xe.application_id = 200 '||
          '    AND xal.application_id = 200 '||
          '    AND xe.entity_id = xte.entity_id '||
          '    AND xte.application_id = 200 '||
          '    AND xte.entity_code = ''AP_INVOICES'' '||
          '    AND xte.source_id_int_1 = ai.invoice_id '||
          '    AND ai.invoice_type_lookup_code = ''PREPAYMENT'' '||
          '    AND ai.historical_flag = ''Y'' '||
          '    AND xe.event_type_code = ''PREPAYMENT VALIDATED'' '||
          '    AND xe.event_status_code = ''P'' '||
          '    AND (xal.accounting_class_code LIKE ''%EXPENSE%'' '||
          '      OR xal.accounting_class_code LIKE ''%TAX%'' '||
          '      OR xal.accounting_class_code LIKE ''%ACCRUAL%'') '||
          '    AND xal.accounting_class_code NOT LIKE ''%LIAB%'' '||
          '    AND xe.upg_batch_id IS NOT NULL  '||
          '    AND xe.upg_batch_id <> -9999 '||
          '    AND xah.upg_batch_id IS NOT NULL '||
          '    AND xah.upg_batch_id <> -9999 '||
          '    AND xal.upg_batch_id IS NOT NULL '||
          '    AND xal.upg_batch_id <> -9999 '||
          '    AND xal.business_class_code IS NULL ';

  EXECUTE IMMEDIATE l_sql_stmt;
  
  l_message := ' Following are transactions which are having upgraded  Accounting Lines for Prepayment Invoices Missing  Business Class Code '||
               ' :: Follow the note 1109933.1';
  AP_ACCTG_DATA_FIX_PKG.Print(l_message);
  l_message :=  '_______________________________________'||
                '_______________________________________';
  AP_ACCTG_DATA_FIX_PKG.Print(l_message);

 l_select_list :=
          'INVOICE_ID,'||
          'INVOICE_NUM,'||
          'EVENT_ID,'||
          'AE_HEADER_ID,'||
          'AE_LINE_NUM,'||
          'ACCOUNTING_CLASS_CODE,'||
          'ENTERED_DR,'||
          'ENTERED_CR,'||
          'ACCOUNTED_DR,'||
          'ACCOUNTED_CR';          

  l_debug_info := 'Getting the table name ';
  l_table_name :=
         l_driver_tab;

  l_debug_info := 'Constructing the where clause ';
  l_where_clause := ' WHERE rownum < 5000 '||
                    ' ORDER BY INVOICE_ID, '||
                    '         EVENT_ID';

  l_debug_info := 'Before calling the Print HTML';
  AP_ACCTG_DATA_FIX_PKG.Print_html_table
    (p_select_list       => l_select_list,
     p_table_in          => l_table_name,
     p_where_in          => l_where_clause,
     P_calling_sequence  => l_calling_sequence);

EXCEPTION 
    WHEN OTHERS THEN
      l_message :=  'Error  '|| SQLCODE||';'||SQLERRM ||'<p>';
      AP_Acctg_Data_Fix_PKG.Print(l_message);
  
END;
----ap_prepay_bus_code_s.sql 

----ap_reissue_sel.sql 
/*REM +=======================================================================+
REM |    Copyright (c) 2001 Oracle Corporation, Redwood Shores, CA, USA     |
REM |                         All rights reserved.                          |
REM +=======================================================================+
REM | FILENAME                                                              |
REM | ap_reissue_sel.sql                                                    |
REM |                                                                       |
REM | DESCRIPTION                                                           |
REM |  This Script is to identify all the checks which got accounted with   | 
REM |  incorrect amounts due to issue in bug 8975671 and 9257606            |
REM |                                                                       | 
REM |  SELECTION SCRIPT                                                     |
REM |  ap_reissue_sel.sql                                                   |
REM |  sqlplus <login>/<password>@<database> @ap_reissue_sel.sql            |
REM |                                                                       |
REM | HISTORY Created by imandal                                            |
REM +=======================================================================+ */

BEGIN

BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE ap_temp_data_driver_9323907';

  Exception
    WHEN OTHERS THEN
     l_message := 'Driver table ap_temp_data_driver_9323907 is missing';
     FND_File.Put_Line(fnd_file.output,l_message);

  END;
 BEGIN
    Execute Immediate
     'CREATE TABLE ap_temp_data_driver_9323907
                  (CHECK_ID            NUMBER(15),
		   CHECK_NUMBER	       NUMBER(15),
		   CHECK_DATE          DATE,
		   EVENT_ID            NUMBER(15),
		   EVENT_TYPE_CODE     VARCHAR2(30),
		   ORG_ID	       NUMBER(15),
		   ACCTD_AMT           NUMBER,
		   CHECK_AMOUNT	       NUMBER,
		   PROCESS_FLAG              VARCHAR2(1) DEFAULT ''Y''
		   )';


  Exception
     WHEN OTHERS THEN
      l_message := 'EXCEPTION :: '||SQLERRM ||
                  ' in creating ap_temp_data_driver_9323907';
      FND_File.Put_Line(fnd_file.output,l_message);
	
  END;
  
  
   BEGIN
    Execute Immediate
      'INSERT INTO ap_temp_data_driver_9323907
       (CHECK_ID,
        CHECK_DATE,
	CHECK_NUMBER,
	EVENT_ID,
	EVENT_TYPE_CODE,
	ORG_ID,
	ACCTD_AMT,
	CHECK_AMOUNT,
	PROCESS_FLAG
       )
       (SELECT ac.check_id,
               ac.check_date,
	       ac.check_number,
               xe.event_id,
               xe.event_type_code,
               ac.org_id,
               SUM(nvl(entered_cr,   0)) - SUM(nvl(entered_dr,   0)) acctd_amt,
	       ac.amount,
	       ''Y''
	  FROM ap_system_parameters_all asp,
               xla_events xe,
               xla_ae_headers xh,
               xla_ae_lines xl,
               ap_payment_history_all aph,
               ap_checks_all ac,
               affected_unvoid_checks_9323907 ctrl
         WHERE xl.application_id = 200
           AND aph.check_id = ac.check_id
           AND ac.check_id = ctrl.check_id
           AND ac.void_date IS NULL
           AND EXISTS
                  (SELECT 1
                     FROM ap_invoice_payments_all aip
                    WHERE aip.check_id = ac.check_id
                 GROUP BY aip.check_id
                   HAVING sum(aip.amount) = ac.amount)
           AND aph.accounting_event_id = xe.event_id
           AND aph.historical_flag IS NULL
           AND aph.posted_flag = ''Y''
           AND xe.event_id = xh.event_id
           AND nvl(xe.upg_batch_id, -1) in (-1 , -9999)
           AND xe.event_type_code IN(''PAYMENT CREATED'',
	                             ''REFUND RECORDED'',
				     ''PAYMENT CLEARED'')
           AND xe.event_status_code = ''P''
           AND xe.application_id = 200
           AND xh.application_id = 200
           AND xh.ledger_id = asp.set_of_books_id
           AND xh.ae_header_id = xl.ae_header_id
           AND asp.org_id = ac.org_id
           AND xl.accounting_class_code IN(''CASH_CLEARING'',
	                                   ''CASH'',
					   ''FUTURE_DATED_PMT'')
           AND decode(xe.event_type_code,   
	              ''PAYMENT CLEARED'',xl.accounting_class_code,
                                ''YES'') != ''CASH''
      GROUP BY ac.org_id,
               ac.check_id,
	       ac.check_date,
	       ac.check_number,
               ac.amount,
               xe.event_id,
               xe.event_type_code
        HAVING ABS( ABS(SUM(nvl(entered_cr,0)) - SUM(nvl(entered_dr,0)) ) -
                                                                ABS(ac.amount)) > 1 
       )';

  Exception
     WHEN OTHERS THEN
     
      l_message := 'EXCEPTION :: '||SQLERRM ||
                  ' in inserting in ap_temp_data_driver_9323907';
      FND_File.Put_Line(fnd_file.output,l_message);
	
  END; 
l_message    := ' Below are REISSUED CHECKS ACCOUNTED WITH ZERO AMOUNT '||
                    ' Follow note 1118703.1 ';
    AP_ACCTG_DATA_FIX_PKG.Print(l_message);
    l_message    :=  '_______________________________________'||
                     '_______________________________________';
    AP_ACCTG_DATA_FIX_PKG.Print(l_message);

    
    l_table_name := 'AP_TEMP_DATA_DRIVER_9323907';

    l_where_clause :=
           'ORDER BY CHECK_DATE DESC';

    AP_ACCTG_DATA_FIX_PKG.Print_html_table
      (p_select_list       => 'CHECK_ID,CHECK_DATE,CHECK_NUMBER,ORG_ID,'||
                              'CHECK_AMOUNT,EVENT_TYPE_CODE,'||
		              'ACCTD_AMT,PROCESS_FLAG',
       p_table_in          => l_table_name,
       p_where_in          => l_where_clause,
       P_calling_sequence  => l_calling_sequence);

EXCEPTION 
    WHEN OTHERS THEN
      l_message :=  'Error  '|| SQLCODE||';'||SQLERRM ||'<p>';
      AP_Acctg_Data_Fix_PKG.Print(l_message);
  
END;
---ap_reissue_sel.sql 

---ap_del_pay_clr_sel.sql 

/*REM +=======================================================================+
REM |    Copyright (c) 2001 Oracle Corporation, Redwood Shores, CA, USA     |
REM |                         All rights reserved.                          |
REM +=======================================================================+
REM | FILENAME                                                              |
REM |    ap_ap_del_pay_clr_sel.sql                                          |
REM |                                                                       |
REM | DESCRIPTION                                                           |
REM |     This script will select Payment clearing events do not get        |
REM |     accounted if the customer changes the recon_accounting_flag       |
REM |     after payment has been accounted.          			          |
REM |                                                                       |
REM +=======================================================================+*/

BEGIN
    
  BEGIN
    Execute Immediate
      'DROP TABLE ap_temp_data_driver_9359243';

  EXCEPTION
    WHEN OTHERS THEN
    NULL;
	
  END;
 
  --------------------------------------------------------------------------
  -- Step 2: create backup tables and driver tables
  --------------------------------------------------------------------------
 
   
 Execute Immediate
      'CREATE TABLE ap_temp_data_driver_9359243 AS
	SELECT ac.check_number,
	       ac.check_date,
	       aph.check_id,
	       payment_history_id,
	       transaction_type,
	       accounting_event_id event_id,
	       aph.org_id,
	       ''Y'' process_flag
       FROM ap_payment_history_all aph,
	    ap_checks_all ac
       WHERE ac.check_id = aph.check_id
       AND 1=2';
   
   --------------------------------------------------------------------------
   -- Step 3:  Insert data into  temp driver tables
   --------------------------------------------------------------------------

      Execute Immediate
      'INSERT INTO ap_temp_data_driver_9359243      
       SELECT DISTINCT ac.check_number,
 	                 ac.check_date,
  	                 aph.check_id,
          	           aph.payment_history_id, 
                       aph.transaction_type,
                       aph.accounting_event_id,
		           aph.org_id ,
                       ''Y'' process_flag
			  FROM ap_payment_history_all aph,
                         ap_checks_all ac,
			       xla_events xe
			  WHERE ac.check_id=aph.check_id
                      AND xe.event_id = aph.accounting_event_id
			    AND aph.posted_flag <> ''Y''
			    AND aph.transaction_type like ''%CLEARING''
			    AND xe.event_status_code <> ''P''
			    AND xe.application_id = 200
			    AND EXISTS (SELECT 1 -- Cash posted in created
			                FROM ap_payment_history_all h2,
							             xla_ae_headers xh,
								           xla_ae_lines xl
        						   WHERE h2.check_id = aph.check_id
        						     AND h2.transaction_type = ''PAYMENT CREATED''
        							   AND h2.posted_flag = ''Y''
        							   AND xh.event_id = h2.accounting_event_id
        							   AND xl.ae_header_id = xh.ae_header_id
        							   AND xl.application_id = 200 
        							   AND xh.application_id = 200
        							   AND xl.accounting_class_code = ''CASH'')';
 
  
  
  
  
      BEGIN
	  
	  l_message    := ' Below are  Payment clearing event do not get accounted when'||
                    'recon_accounting_flag is changed after payment accounting Follow note 1146638.1 ';
    AP_ACCTG_DATA_FIX_PKG.Print(l_message);
    l_message    :=  '_______________________________________'||
                     '_______________________________________';
    AP_ACCTG_DATA_FIX_PKG.Print(l_message);
	
        AP_Acctg_Data_Fix_PKG.Print_html_table                           
        ('CHECK_NUMBER,CHECK_DATE,CHECK_ID,PAYMENT_HISTORY_ID,TRANSACTION_TYPE,EVENT_ID,ORG_ID',
        'ap_temp_data_driver_9359243',
	    NULL,
        'ap_del_pay_clr_sel.sql');                                              
      EXCEPTION                                                          
       WHEN OTHERS THEN
        l_message := 'EXCEPTION :: '||SQLERRM ||
                     'in call to AP_Acctg_Data_Fix_PKG.Print_html_table '||
		                 'during printing data from ap_temp_data_driver_9359243';
        AP_Acctg_Data_Fix_PKG.Print(l_message);
	
      END;
  

  
EXCEPTION

   WHEN OTHERS THEN
        
      l_message :=  'Error  '|| SQLCODE||';'||SQLERRM ||'<p>';
      AP_Acctg_Data_Fix_PKG.Print(l_message);

END;

---ap_del_pay_clr_sel.sql 

---ap_payDistsMissInPrior_sel.sql

/*REM +=======================================================================+
REM | FILENAME                                                              |
REM |     ap_payDistsMissInPrior_sel.sql                                    |
REM |                                                                       |
REM | DESCRIPTION                                                           |
REM | Script to identify the Payment Clearing Events having and payment     |
REM | Maturity events that are not getting accounted wih the error -        |
REM | "ERROR 0 THE APPLIED-TO SOURCES PROVIDED FOR THIS"                    |
REM | because it is picking up invoice distributions which does not exist in| 
REM | the proration for the prior event like Payment Created, payment       |
REM | Adjusted, Payment Maturity, payment Maturity Adjusted, Refund Recorded|
REM | , Refund Adjusted. As such accounting fails with BFLOW error          |
REM | RCA Bug 9728193                                                       |
REM | HISTORY zrehman                                                       |
REM +=======================================================================+*/



BEGIN
l_bug_no:='9732714';

  --------------------------------------------------------------------------
  -- STEP 1: DROP THE TEMPORARY TABLES IF ALREADY EXISTS
  --------------------------------------------------------------------------
  l_driver_tab := 'AP_TEMP_DATA_DRIVER_'||l_bug_no;
  

  BEGIN
     l_sql_stmt :=
          ' DROP TABLE '||l_driver_tab;
    EXECUTE IMMEDIATE l_sql_stmt;
  EXCEPTION
    WHEN OTHERS THEN
  NULL;
  END;

  l_affected_pay_tab := 'AP_AFFCTD_CHCKS_'||l_bug_no;
  l_debug_info       := 'Dropping driver table ->'||l_affected_pay_tab;

  BEGIN
     l_sql_stmt :=
          ' DROP TABLE '||l_affected_pay_tab;
    EXECUTE IMMEDIATE l_sql_stmt;
  EXCEPTION
    WHEN OTHERS THEN
      Null;
  END;
  --------------------------------------------------------------------------
  -- STEP 2: CREATE BACKUP TABLES AND DRIVER TABLES
  --------------------------------------------------------------------------
  
  l_sql_stmt :=
          ' CREATE TABLE '||l_affected_pay_tab||
          '   AS                                                                    '||
          'SELECT DISTINCT ac.org_id                                                '||
          '     , ac.check_number                                                   '||
          '     , ac.check_date                                                     '||
          '     , ac.amount                                                         '||
          '     , aph.check_id                                                      '||
          '     , ac.bank_account_name                                              '||
          '     , ac.currency_code                                                  '||
          '     , ac.void_date                                                      '||
          '     , aph.payment_history_id                                            '||
          '     , aph.transaction_type                                              '||
          '     , aph.historical_flag                                               '||
          '     , aph.accounting_event_id event_id                                  '||
          '  FROM ap_payment_hist_dists aphd                                        '||
          '     , ap_payment_history_all aph                                        '||
          '     , ap_invoice_distributions_all aid                                  '||
          '     , ap_checks_all ac                                                  '||
          ' WHERE aph.transaction_type LIKE ''PAYMENT CLEARING%''                   '||
          '   AND ac.check_id                  = aph.check_id                       '||
          '   AND ac.org_id                    = aph.org_id                         '||
          '   AND aph.posted_flag             IN( ''N'', ''S'' )                    '||
          '   AND aph.payment_history_id       = aphd.payment_history_id            '||
          '   AND aph.accounting_event_id      = aphd.accounting_event_id           '||
          '   AND aphd.invoice_distribution_id = aid.invoice_distribution_id        '||
          '   AND NOT EXISTS                                                        '||
          '       (SELECT 1                                                         '||
          '           FROM ap_payment_history_all aph3                              '||
          '              , xla_events xe                                            '||
          '          WHERE aph3.check_id             = aph.check_id                 '||
          '            AND xe.application_id         = 200                          '||
          '            AND xe.event_id               = aph3.accounting_event_id     '||
          '            AND xe.event_status_code     <> ''P''                        '||
          '            AND aph3.payment_history_id  <> aph.payment_history_id       '||
          '            AND( ( ac.future_pay_due_date IS NULL                        '||
          '                   AND aph3.transaction_type IN( ''PAYMENT CREATED'',    '||
	  '                        ''PAYMENT ADJUSTED'',''MANUAL PAYMENT ADJUSTED'','||
	  '                        ''REFUND ADJUSTED'', ''REFUND RECORDED'')        '||
	  '                 )                                                       '||
          '                 OR (ac.future_pay_due_date IS NOT NULL                  '||
          '                     AND aph3.transaction_type IN (''PAYMENT MATURITY'', '||
	  '                   ''PAYMENT MATURITY ADJUSTED'')                        '||
	  '                    )                                                    '||
	  '               )                                                         '||
          '       )                                                                 '||
          '   AND NOT EXISTS                                                        '||
          '       (SELECT 1                                                         '||
          '           FROM ap_payment_hist_dists aphd2                              '||
          '              , ap_payment_history_all aph2                              '||
          '          WHERE aphd2.payment_history_id      = aph2.payment_history_id  '||
          '            AND aph2.check_id                 = aph.check_id             '||
          '            AND(( ac.future_pay_due_date     IS NULL                     '||
          '                 AND aph2.transaction_type IN(''PAYMENT CREATED'',       '||
	  '                   ''PAYMENT ADJUSTED'',''MANUAL PAYMENT ADJUSTED'',     '||
	  '                       ''REFUND ADJUSTED'',''REFUND RECORDED'')          '||
	  '                )                                                        '||
          '             OR( ac.future_pay_due_date      IS NOT NULL                 '||
          '                AND aph2.transaction_type IN (''PAYMENT MATURITY'',      '||
	  '                    ''PAYMENT MATURITY ADJUSTED'')                       '||
	  '               ))                                                        '||
          '            AND aph2.posted_flag              = ''Y''                    '||
          '         AND aphd2.invoice_distribution_id = aphd.invoice_distribution_id'||
          '       )                                                                 '||
          'UNION                                                                    '||
          'SELECT DISTINCT ac.org_id,                                               '|| 
          '      ac.check_number,                                                   '||
          '      ac.check_date,                                                     '||
          '      ac.amount,                                                         '||
          '      aph.check_id,                                                      '||
          '      ac.bank_account_name,                                              '||
          '      ac.currency_code,                                                  '||
          '      ac.void_date,                                                      '||
          '      aph.payment_history_id,                                            '||
          '      aph.transaction_type,                                              '||
          '      aph.historical_flag,                                               '||
          '      aph.accounting_event_id event_id                                   '||
          '  FROM ap_payment_hist_dists aphd                                        '||
          '     , ap_payment_history_all aph                                        '||
          '     , ap_invoice_distributions_all aid                                  '||
          '     , ap_checks_all ac                                                  '||
          ' WHERE aph.transaction_type        LIKE  ''PAYMENT MATURITY%''           '||
          '   AND ac.check_id = aph.check_id                                        '||
          '   AND aph.posted_flag             <> ''Y''                              '||
          '   AND aph.payment_history_id       = aphd.payment_history_id            '||
          '   AND aphd.invoice_distribution_id = aid.invoice_distribution_id        '||
          '   AND NOT EXISTS                                                        '||
          '       (SELECT 1                                                         '||
          '           FROM ap_payment_history_all aph3                              '||
          '              , xla_events xe                                            '||
          '          WHERE aph3.check_id             = aph.check_id                 '||
          '            AND xe.application_id         = 200                          '||
          '            AND xe.event_id               = aph3.accounting_event_id     '||
          '            AND xe.event_status_code     <> ''P''                        '||
          '            AND aph3.payment_history_id  <> aph.payment_history_id       '||
          '            AND aph3.transaction_type    IN (''PAYMENT CREATED'',        '||
	  '            ''PAYMENT ADJUSTED'',''MANUAL PAYMENT ADJUSTED'',            '||
	  '            ''REFUND ADJUSTED'',''REFUND RECORDED'')                     '||
          '       )                                                                 '||
          '   AND NOT EXISTS                                                        '||
          '                (SELECT 1                                                '||
          '                    FROM ap_payment_hist_dists aphd2                     '||
          '                       , ap_payment_history_all aph2                     '||
          '                   WHERE aphd2.payment_history_id = aph2.payment_history_id  '||
          '                     AND aph2.check_id            = aph.check_id             '||
          '                     AND aph2.transaction_type        IN(''PAYMENT CREATED'' '||
          '                       ,''PAYMENT ADJUSTED'',''MANUAL PAYMENT ADJUSTED''     '||
          '                       ,''REFUND ADJUSTED'',''REFUND RECORDED'' )            '||
          '                     AND aph2.posted_flag         = ''Y''                    '||
          '           AND aphd2.invoice_distribution_id = aphd.invoice_distribution_id  '||
          '                )                                                            '||
          '   order by org_id, check_id';

  EXECUTE IMMEDIATE l_sql_stmt;

  
  l_sql_stmt :=
          'CREATE TABLE ' ||l_driver_tab||
          ' AS                                                      '||
          'SELECT DISTINCT ac.org_id,                               '||
          '      ac.check_number,                                   '||
          '      ac.check_date,                                     '||
          '      aph.check_id,                                      '||
          '      ac.amount,                                         '||
	  '      ac.bank_account_name,                              '||
          '      ac.currency_code,                                  '||
          '      ac.void_date,                                      '||
          '      aph.payment_history_id,                            '||
          '      aph.transaction_type,                              '||
          '      aph.accounting_event_id event_id,                  '||
	  '      aph.posted_flag,                                   '||
          '      xe.event_type_code,                                '||
          '      xe.event_status_code,                              '||
          '      xe.process_status_code,                            '||
          '      xe.event_date,                                     '||
          '      xe.upg_batch_id,                                   '||
          '      ''Y'' process_flag                                 '||
          ' FROM ap_checks_all ac,                                  '||
          '      ap_payment_history_all aph,                        '||
	  '      xla_events xe                                      '||
          ' WHERE ac.check_id = aph.check_id                        '||
	  '   AND xe.event_id = aph.accounting_event_id             '||
	  '   AND aph.posted_flag = ''Y''                           '||
	  '   AND xe.event_status_code = ''P''                      '||
          '   AND ac.check_id in ( SELECT distinct check_id         '||
          '                        FROM ' || l_affected_pay_tab      ||
          '                    )                                    '||
	  ' order by org_id,check_id,payment_history_id';
  EXECUTE IMMEDIATE l_sql_stmt;

  
  

  ------------------------------------------------------------------
  -- STEP 3: REPORT ALL THE AFFECTED TRANSACTIONS IN LOG FILE 
  ---------------------------------------------------------------------

      l_where_clause :=
           'ORDER BY ORG_ID,CHECK_ID';


l_message    := ' PAYMENT CLEARING EVENT - ERROR 0 THE APPLIED-TO SOURCES PROVIDED FOR THIS'||
                 ' Follow note 1177653.1 ';
				 AP_Acctg_Data_Fix_PKG.Print(l_message);
				 
l_message    :=  '_______________________________________'||
                     '_______________________________________';
    AP_ACCTG_DATA_FIX_PKG.Print(l_message);
					 
    
    AP_ACCTG_DATA_FIX_PKG.Print_html_table
      (p_select_list       => 'ORG_ID,CHECK_ID,CHECK_NUMBER,CHECK_DATE,VOID_DATE,'||
                              'BANK_ACCOUNT_NAME,AMOUNT,CURRENCY_CODE,PAYMENT_HISTORY_ID,'||
			      'TRANSACTION_TYPE,EVENT_ID',
       p_table_in          => l_affected_pay_tab,
       p_where_in          => l_where_clause,
       P_calling_sequence  => l_calling_sequence);
	   


EXCEPTION
  
   WHEN OTHERS THEN
        
      l_message :=  'Error  '|| SQLCODE||';'||SQLERRM ||'<p>';
      AP_Acctg_Data_Fix_PKG.Print(l_message);
END;
---ap_payDistsMissInPrior_sel.sql

--ap_prepay_final_rnd_s.sql
/*REM +=======================================================================+
REM | FILENAME                                                              |
REM |                                                                       |
REM | DESCRIPTION                                                           |
REM |   GDF to correct the Accounting of the Prepayment Application or      |
REM |   Unapplication events which have been Incorectly Accounted because   |
REM |   Final Rounding because of a Prior Unapplied Prepayment Application  |
REM |   or a prior voided Payment                                           |
REM +=======================================================================+*/

BEGIN

  BEGIN
    l_bug_no:='9774484';
     l_sql_stmt :=
          ' DROP TABLE ap_temp_data_driver_'||l_bug_no;
     
     --AP_ACCTG_DATA_FIX_PKG.Print(l_sql_stmt);

    EXECUTE IMMEDIATE l_sql_stmt;
  EXCEPTION
    WHEN OTHERS THEN
      NULL;
  END;

  l_sql_stmt :=
       ' CREATE TABLE ap_temp_data_driver_'||l_bug_no||' AS '||
       ' SELECT aidp.invoice_id, '||
       '        ai.invoice_num, '||
       '        ai.invoice_type_lookup_code, '||
       '        ai.invoice_amount, '||
       '        ai.invoice_currency_code, '||
       '        ai.invoice_date, '||
       '        asu.vendor_name, '||
       '        assi.vendor_site_code, '||
       '        aidp.line_type_lookup_code, '||
       '        aidp.invoice_line_number, '||
       '        aidp.distribution_line_number, '||
       '        aidp.invoice_distribution_id            prepay_app_distribution_id,'||
       '        aidp.accounting_date, '||
       '        aidp.amount                             prepay_app_amt, '||
       '        aidp.base_amount                        prepay_app_base_amt, '||
       '        0                                       sum_app_dists_amt, '||
       '        0                                       sum_app_dists_base_amt, '||
       '        aidp.accounting_event_id                event_id, '||
       '        apph.prepay_history_id, '||
       '        apph.transaction_type, '||
       '        aidp.posted_flag, '||
       '        aidp.match_status_flag, '||
       '        fsp.purch_encumbrance_flag, '||
       '        ai.org_id, '||
       '        asp.base_currency_code, '||
       '        ai.set_of_books_id, '||
       '        ''Y'' process_flag '||
       '   FROM ap_prepay_history_all apph, '||
       '        ap_invoice_distributions_all aidp, '||
       '        ap_invoices_all ai, '||
       '        ap_suppliers asu, '||
       '        ap_supplier_sites_all assi, '||
       '        ap_system_parameters_all asp, '||
       '        financials_system_params_all fsp '||
       '  WHERE apph.transaction_type <> ''PREPAYMENT APPLICATION ADJ'' '||
       '    AND aidp.invoice_id = apph.invoice_id '||
       '    AND apph.accounting_event_id = aidp.accounting_event_id '||
       '    AND aidp.line_type_lookup_code IN (''PREPAY'', ''REC_TAX'', ''NONREC_TAX'') '||
       '    AND aidp.prepay_distribution_id IS NOT NULL '||
       '    AND nvl(aidp.reversal_flag, ''N'') <> ''Y'' '||
       '    AND aidp.invoice_id = ai.invoice_id '||
       '    AND ai.vendor_id = asu.vendor_id(+) '||
       '    AND ai.vendor_site_id = assi.vendor_site_id(+) '||
       '    AND fsp.org_id = aidp.org_id '||
       '    AND asp.org_id = aidp.org_id '||
       '    AND (aidp.posted_flag = ''Y'' OR '||
       '         (aidp.match_status_flag IN (''A'',''T'') AND  '||
       '          nvl(fsp.purch_encumbrance_flag, ''N'') = ''N'') OR '||
       '         (aidp.match_status_flag = ''A'' AND '||
       '          nvl(fsp.purch_encumbrance_flag, ''N'') = ''Y'')) '||
       '    AND aidp.accounting_event_id IS NOT NULL '||
       '    AND EXISTS '||
       '       ((SELECT 1 '||
       '          FROM ap_invoice_distributions_all aidp2 '||
       '         WHERE aidp2.invoice_id = ai.invoice_id '||
       '           AND aidp2.prepay_distribution_id IS NOT NULL '||
       '           AND aidp2.line_type_lookup_code = ''PREPAY'' '||
       '           AND aidp2.reversal_flag = ''Y'' '||
       '           AND aidp2.parent_reversal_id IS NOT NULL) '||
       '        UNION '||
       '       (SELECT 1 '||
       '          FROM ap_invoice_payments_all aip, '||
       '               ap_checks_all ac '||
       '         WHERE aip.invoice_id = ai.invoice_id '||
       '           AND aip.check_id = ac.check_id '||
       '           AND ac.status_lookup_code = ''VOIDED'' '||
       '           AND ac.void_date IS NOT NULL)) ';

  --AP_ACCTG_DATA_FIX_PKG.Print(l_sql_stmt);
  EXECUTE IMMEDIATE l_sql_stmt;

  
  ------------------------------------------------------------------


 l_message := 'Following are the Prepayment Application/Unapplication '||
               'distributions, which have been incorrectly prorated in the '||
               'table AP_PREPAY_APP_DISTS. Follow note 1190473.1';

  AP_ACCTG_DATA_FIX_PKG.Print(l_message);
  
  l_message    :=  '_______________________________________'||
                     '_______________________________________';

  AP_ACCTG_DATA_FIX_PKG.Print(l_message);
  l_select_list :=
          'INVOICE_ID,'||
          'INVOICE_NUM,'||
          'INVOICE_TYPE_LOOKUP_CODE,'||
          'INVOICE_AMOUNT,'||
          'INVOICE_CURRENCY_CODE,'||
          'INVOICE_DATE,'||
          'VENDOR_NAME,'||
          'VENDOR_SITE_CODE,'||
          'LINE_TYPE_LOOKUP_CODE,'||
          'INVOICE_LINE_NUMBER,'||
          'DISTRIBUTION_LINE_NUMBER,'||
          'PREPAY_APP_DISTRIBUTION_ID,'||
          'ACCOUNTING_DATE,'||
          'PREPAY_APP_AMT,'||
          'PREPAY_APP_BASE_AMT,'||
	  'SUM_APP_DISTS_AMT,'||
	  'SUM_APP_DISTS_BASE_AMT,'||
          'EVENT_ID,'||
          'PREPAY_HISTORY_ID,'||
	  'TRANSACTION_TYPE,'||
          'POSTED_FLAG,'||
          'MATCH_STATUS_FLAG,'||
          'PURCH_ENCUMBRANCE_FLAG,'||
	  'BASE_CURRENCY_CODE,'||
          'ORG_ID,'||
	  'BASE_CURRENCY_CODE,'||
          'SET_OF_BOOKS_ID,'||
          'PROCESS_FLAG';

  
l_table_name := 'ap_temp_data_driver_'||l_bug_no;

  l_where_clause :=
          'ORDER BY INVOICE_ID';
  AP_ACCTG_DATA_FIX_PKG.Print_html_table
    (p_select_list       => l_select_list,
     p_table_in          => l_table_name,
     p_where_in          => l_where_clause,
     P_calling_sequence  => l_calling_sequence);



EXCEPTION
  WHEN OTHERS THEN
    l_message :=  'Error  '|| SQLCODE||';'||SQLERRM ||'<p>';
      AP_Acctg_Data_Fix_PKG.Print(l_message);

END;

--ap_prepay_final_rnd_s.sql

--- ap_payClrXbankCurAmt_sel.sql
/*REM +=======================================================================+
REM | FILENAME                                                              |
REM |     ap_payClrXbankCurAmt_sel.sql                                      |
REM |                                                                       |
REM | DESCRIPTION                                                           |
REM | Script to identify the Payment Clearing Events having incorrect       |
REM | bank_curr_amount. Though the bank currency is same as payment currency|
REM | but bank_curr_amt is not equal to the payment amount                  |
REM | This casues validation to fail during GL transfer - ec12 error in     |
REM | Journal Import. Fix is to undo and redo accounting of all the related |
REM | checks.                                                               |
REM +=======================================================================+*/

BEGIN

  BEGIN
    l_bug_no:='9727543';
     l_sql_stmt :=
          ' DROP TABLE ap_temp_data_driver_'||l_bug_no;
     
     --AP_ACCTG_DATA_FIX_PKG.Print(l_sql_stmt);

    EXECUTE IMMEDIATE l_sql_stmt;
  EXCEPTION
    WHEN OTHERS THEN
      NULL;
  END;

  
  l_sql_stmt :=' CREATE TABLE ap_temp_data_driver_9727543 AS 
       SELECT DISTINCT aph.check_id
, ac.org_id
, ac.check_number
, ac.bank_account_id
, ac.bank_account_name
, ac.amount
, aph.accounting_event_id event_id
FROM ap_payment_history_all aph
, ap_payment_hist_dists aphd
, ap_checks_all ac
WHERE aph.payment_history_id = aphd.payment_history_id
and AC.CHECK_ID = APH.CHECK_ID
and APH.TRANSACTION_TYPE like ''PAYMENT CLEARING%''
and APH.POSTED_FLAG = ''Y''
AND APHD.PAY_DIST_LOOKUP_CODE = ''CASH''
AND aph.bank_currency_code = aph.pmt_currency_code
AND aphd.amount != aphd.bank_curr_amount
AND EXISTS
(SELECT 1
FROM xla_ae_headers h
where H.EVENT_ID = APH.ACCOUNTING_EVENT_ID
AND h.gl_transfer_status_code != ''Y''
and H.APPLICATION_ID = 200
)';



  --AP_ACCTG_DATA_FIX_PKG.Print(l_sql_stmt);
  EXECUTE IMMEDIATE l_sql_stmt;

  
  ------------------------------------------------------------------


 l_message := 'Following are EC12 error in journal import - wrong payment clearing accounting. follow note 1193313.1';

  AP_ACCTG_DATA_FIX_PKG.Print(l_message);
  
  l_message    :=  '_______________________________________'||
                     '_______________________________________';

  AP_ACCTG_DATA_FIX_PKG.Print(l_message);
  

  l_select_list :=
          'CHECK_ID,'||
          'ORG_ID,'||
          'CHECK_NUMBER,'||
          'BANK_ACCOUNT_ID,'||
          'BANK_ACCOUNT_NAME,'||
		  'AMOUNT,'||
		  'EVENT_ID';

  
l_table_name := 'ap_temp_data_driver_'||l_bug_no;

  l_where_clause :='ORDER BY CHECK_ID';
  AP_ACCTG_DATA_FIX_PKG.Print_html_table
    (p_select_list       => l_select_list,
     p_table_in          => l_table_name,
     p_where_in          => l_where_clause,
     P_calling_sequence  => l_calling_sequence);



EXCEPTION
  WHEN OTHERS THEN
    l_message :=  'Error  9727543'|| SQLCODE||';'||SQLERRM ||'<p>';
      AP_Acctg_Data_Fix_PKG.Print(l_message);

END;

 ---ap_payClrXbankCurAmt_sel.sql

  AP_Acctg_Data_Fix_PKG.Print('For any issue/query/feedback contact '|| '<B>'|| 'virendra.bhandari@oracle.com' || '</B>'); 
  l_message    :=  '_______________________________________'||
                     '_______________________________________';
	AP_ACCTG_DATA_FIX_PKG.Print(l_message);	
		AP_ACCTG_DATA_FIX_PKG.Print(' End of File');	
	AP_ACCTG_DATA_FIX_PKG.Print(l_message);		
  AP_Acctg_Data_Fix_PKG.Print('</body></html>');
  AP_Acctg_Data_Fix_PKG.Close_Log_Out_Files;

  dbms_output.put_line('--------------------------------------------------'||
                       '-----------------------------');
  dbms_output.put_line(v_filedir||' is the log file created');
  dbms_output.put_line('--------------------------------------------------'||
                       '-----------------------------');
  COMMIT;

EXCEPTION
  WHEN OTHERS THEN
    l_message :=  'Error  '|| SQLCODE||';'||SQLERRM ||'<p>';
    AP_Acctg_Data_Fix_PKG.Print(l_message);
    AP_Acctg_Data_Fix_PKG.Print('</body></html>');
    AP_Acctg_Data_Fix_PKG.Close_Log_Out_Files;

    dbms_output.put_line('--------------------------------------------------'||
                         '-----------------------------');
    dbms_output.put_line(v_filedir||' is the log file created');
    dbms_output.put_line('--------------------------------------------------'||
                         '-----------------------------');

END;

End ;
/
COMMIT;


	
	
	
	
		  
  
     