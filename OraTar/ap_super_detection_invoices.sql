REM $Header: ap_super_detection_invoices.sql  V1
REM
REM dbdrv: none
REM
REM +=======================================================================+
REM |    Copyright (c) 2001 Oracle Corporation, Redwood Shores, CA, USA     |
REM |                         All rights reserved.                          |
REM +=======================================================================+
REM | FILENAME                                                              |
REM |     ap_super_detection_invoices.sql 			            |
REM | DESCRIPTION                                                           |
REM |      This file give what GDF's are applicable for given invoice       |
REM | PARAMETERS                                                            | 
REM |    invoice_id                                                                   |
REM | This parametrs except ledger_id is mandatory . These parametrs        |
REM       is used only for some upgraded invoice issues.					|
REM | HISTORY                                                               |
REM |   19-MAR-2010       VIRENDRA BHANDARI                                 |
REM |                     SRIRAM RAMANUJAM                                  |
REM | Below GDF's are coeverd												|
REM +=======================================================================+
				
REM Note 967242.1 Withholding Tax Calculation Causing Fractional Differences and Holds 
REM Note 967213.1 Tax Details Not Populated in XLA_DISTRIBUTION_LINKS for Upgraded Transactions 
REM Note 964952.1 Creating Reversal Manual AWT Distributions 
REM Note 972143.1 Total Tax Amount is not Populated to Invoice Header during the upgrade. 
REM Note 975184.1 Prepayment Application / Uapplication Events Fails to Account Due to Missing Records in AP_PREPAY_APP_DISTS  
REM Note 975162.1 Create Accounting Process Fails with 95353 Error For Self-Assessed Tax Lines 
REM Note 974149.1 Upgraded Validated Invoices in Needs Revalidation Status due to 'DIST VARIANCE' Hold 
REM Note 982075.1 Prepayment Applied/Unapplied Events Cannot be Accounted After The Invoice Is Cancelled 
REM Note 982802.1 REMIT_TO Columns Not Affected by Supplier Merge 
REM Note 982795.1 Cannot Account For Invoices Due to BC_EVENT_ID Stamped On Recoverable Tax Distributions 
REM Note 985228.1 Delete Unprocessed Budgetary Accounting Events Hindering Payables Period Closure 
REM Note 1061563.1 Cannot Account For Upgraded AWT Distribution Due to Missing AWT_RELATED_ID 
REM Note 1060644.1 Delete Orphan Invoice Distribution Lines Missing Invoice Lines 
REM Note 1060611.1 Correct Invoices On Which an Unsuccessful Cancellation was Attempted 
REM Note 1063226.1 Upgraded Invoices in 'Needs Revalidation' Status 
REM Note 1063272.1 Invoices with 100% Tax Variance are Placed in Distribution Variance Hold. 
REM Note 1063263.1 Accounted Amounts are Out of Sync With Invoice Distribution Amounts. 
REM Note 1060687.1 Distributions of 'Tax Only' Invoices Cannot be Validated Due to Invalid Account. 
REM Note 1072747.1 Invoices Accounting Fails Due to Missing Liability Account on Invoice Header 
REM Note 1072774.1 Invoices Locked by Invoice Validation Request That had Completed in Error 
REM Note 1072783.1 ORA-01422 Error on Clicking Distribution of Upgraded Invoice 
REM Note 1094274.1 Error APP-PO-14144: PO_ACTIONS-065 On Validating Payables Invoice
REM Note 1094283.1 On Cancellation Invoices Are Placed in 'DIST VARIANCE' Hold
REM Note 1094293.1 Withholding Tax Not Calculated on Variance Distributions Created During Upgrade
REM Note 1152559.1 Code Bug 8462050 - Reversed Automatic Withholding Tax (AWT) Distributions Do Not Have Descriptive Flexfield (DFF) Information.
REM Note 1152656.1 Populate Correct Taxable Amount and Base Amount for Upgraded Transctions
REM Note 1152683.1 Unable to Cancel / Reverse Invoice Corrected to Itself 
REM Note 1188825.1 R12 Generic Data Fix (GDF) Duplicate AWT Distributions Created During Payment 
REM NOte 1194913.1 R12 Generic Data Fix (GDF) patch Unaccounted prepay events for cancelled invoices having no item dists
REM Note 1264239.1 Payment acctg failing due to awt dists created by prepayment application (Doc ID 1264239.1)
REM Note 1188863.1 Zero base amount with non-zero dist amount for upgraded tax distributions

REM Note 1272433.1 Already validated invoices are picking up through validation program 
REM Note 1272440.1 Wrong balancing segments on invoice distributions
REM Note 1266869.1 Multiple corruptions on invoice (Check the read me)
REM Note 1272497.1 Base amounts are populated on base currency invoices
REM Note 1276069.1 Tax lines created with out having corresponding taxable lines
REM Note 1276055.1 11i dists have wrong parent reversal id and reversal flag and upgraded to R12
REM Note 1276043.1 Invoices with wrong base amounts, variances and rounding amount issues.
REM Note 982072.1  Mismatch between AP and PO for quantity/amount billed,finanaced and recouped
REM Note 874862.1  Invoice not released from PPR

REM GDF 9243855    Prepay details are missing on the upgrade tax distributions associated with prepay apply/unapply
REM GDF 10177871   Batch names are duplicated for upgraded batches
REM GDF 9575282    Amounts and quantity mismatch between PO distributions and PO shipments

REM ap_canc_inv_amt_paid_sel.sql                  Non zero amount paid for cancelled invoices
REM inv_incl_canc_sel.sql                         Non zero total tax amount on cancelled invoices
REM null_inv_line_num_sel.sql                     Invoice lines with null invoice_line_number
REM canc_tax_lines_sel.sql                        Invoices are picking up for validation due to tax lines with no distributions
REM canc_inv_wrong_enc_flag_bc_evnt_sel.sql       Cancelled invoice with distributions having MSF and enc flag discripency.
REM awt_rev_dist_sel.sql                          Cancelled or discarded AWT dists with out the reversals
REM ap_split_prepay_alloc_sel.sql                 In 11i, Tax related to Preapay and Item are allocated to same tax distribution
REM ap_ppay_non_po_match_encumbr_sel.sql          PO details are populated on prepay appl event dists even the prepay is not matched
REM Amt_Rem_Non_Zero_Can_Inv_Sel.sql              Non Zero amount remaining on cancelled invoices
REM MISC_LINE_NOT_RVRSD_WEN_CNCLD_SEL.sql         Misc lines are not reversed for cancelled invoices
REM NOT_NULL_QTY_INV_SEL.sql                      Non Zero quantity invoiced value on cancelled invoices
REM ap_wrg_11i_chrg_alloc_sel.sql                 In 11i, allocation happened wrongly on wrong line type lookups,like tax allocated to tax
REM tipv_terv_ccid_sel.sql                        TIPV and TERV ccid are wrongly populated after upgrade
REM unrev_upg_TIPV_sel.sql                        R12, while disarding or cancelling the invoices the TIPV is not reversed
REM upd_mtch_sts_flg_from_T2A_sel.sql             MSF is populated wrongly as A with out accounting event ids   
REM upd_inv_null_amt_sel.sql                      Null invoice amount on invoice header
REM upd_ret_inv_dist_id_for_rev_dists_sel.sql     retainage invoice id is not populated on reversed/cancelled retainage released dists
REM upd_upg_itm_TCC_sel.sql                       TCC is not populated on ITEM distributions after upgrade
REM update_individual_1099_sel.sql                individual_1099 is not populated
REM wrng_awrdid_upg_sel.sql                       awar_id on invoice lines went wrong after upgrade
REM syncup_inv_num_sel.sql                        Invoice Num is not in sync with other products like IBY, XLA and ZX
REM upd_pay_sta_flag_sel.sql                      wrong payment status flag on invoice header
REM taxable_amount_zero_sel.sql                   taxable amounts are zero.
REM rcv_shpmt_miss_sel.sql                        rev shipement details are not populated after upgrade
REM ppay_unapply_causing_neg_amt_paid_sel.sql     after prepay apply n unapply causing -ve amount paid on invoice header
REM posted_dists_match_status_flag_sel.sql        posted distributions showing wrong match status flag
REM paid_invoice_cancel_sel.sql                   some of the paid invoices are got canclled with out the payments got voided
REM orphan_self_assess_tax_inv_dists_sel.sql      orphan self assessed tax distributions
REM del_holds_on_can_inv_sel.sql                  hold remain unreleased on cancelled invoices
REM datafix_9235692_sel.sql                       AWT invoices with improper distributions             
REM 9178283_cancelled_tax_dist_sel.sql            Canclled invoices are picking up for invoice validation program
REM AP_PO_UOM_SYNC_SEL.sql                        UOM values are not in sync in AP and PO
REM ap_po_price_adj_flg_sel.sql                   PO price adjustment flag stuck in status S
REM discard_non_tax_line_wrong_rev_sel.sql        reversals went wrong for non tax lines discard     
REM ap_orphan_zx_lines_sel.sql                    orphan zx data





SET VERIFY OFF
SET SERVEROUTPUT ON

DECLARE
  l_count            NUMBER;
  l_count1           NUMBER;
  l_file_location    v$parameter.value%TYPE;
  l_message          VARCHAR2(1000);
  l_debug_info       VARCHAR2(1000);
  l_rows             NUMBER;
  l_row_limit        NUMBER:=101;
  l_dummy            NUMBER;
  l_bug_no           VARCHAR2(100) ;
  l_driver_tab       ALL_TABLES.TABLE_NAME%TYPE;
  l_driver_tab1      ALL_TABLES.TABLE_NAME%TYPE;  
  l_error_log        FND_LOG_MESSAGES.MESSAGE_TEXT%TYPE;
  l_select_list      LONG;
  l_table_name       ALL_TABLES.TABLE_NAME%TYPE;
  l_where_clause     LONG;
  l_sql_stmt         LONG;
  l_calling_sequence FND_LOG_MESSAGES.MESSAGE_TEXT%TYPE;
  l_invoice_id       NUMBER;
  l_rows1            NUMBER;
  l_count_inv        NUMBER;
  l_count_check      NUMBER;
  l_count_rec_pay    NUMBER;
  l_count_pay_sch    NUMBER;
  l_INVOICE_ID1      NUMBER; 
  l_org_id           NUMBER;
  table_name         VARCHAR2(25) := '';
  Script_Exception   EXCEPTION;
  l_current_date              VARCHAR2(500);
  l_database				  VARCHAR2(500); 	
   l_host_name				  VARCHAR2(500); 	
 
  
  
PROCEDURE PRINT_LINE
IS
l_message1          VARCHAR2(1000);
BEGIN
  l_message1 := '_______________________________________'||
                 '_______________________________________'||
				 '_______________________________________'||
				 '_______________________________________';
    AP_Acctg_Data_Fix_PKG.Print(l_message1); 
END;	

  
PROCEDURE CHECK_COUNT (p_bug_num IN NUMBER,p_invoice_id IN NUMBER, p_rows OUT NUMBER)
  IS
  BEGIN
  
  IF p_bug_num=9724485 THEN
  
  SELECT count(1)
  Into p_rows
FROM ap_invoice_distributions_all aid_awt,
ap_invoice_distributions_all aid_prepay,
XLA_EVENTS XE
WHERE aid_awt.posted_flag <> 'Y'
AND aid_prepay.invoice_id = aid_awt.invoice_id
and AID_PREPAY.INVOICE_DISTRIBUTION_ID = AID_AWT.AWT_RELATED_ID
AND aid_prepay.prepay_distribution_id IS NOT NULL
AND xe.event_id = aid_awt.accounting_event_id
and XE.EVENT_STATUS_CODE = 'U'
AND xe.application_id = 200
and aid_awt.invoice_id=p_invoice_id;
  
  
  ELSIF p_bug_num=9767397 THEN
  
  SELECT count(DISTINCT i.invoice_num)
  Into p_rows
        FROM ap_invoices_all i           ,
             ap_invoice_distributions_all aid,
             xla_events xe
       WHERE aid.invoice_id             = i.invoice_id
         AND aid.prepay_distribution_id IS NOT NULL
         AND aid.accounting_event_id     = xe.event_id (+)
         AND NVL(aid.posted_flag, 'N')  <> 'Y'
         AND NVL(aid.reversal_flag, 'N') = 'Y'
         AND NVL(xe.application_id, -99)           = 200
         AND NVL(xe.event_status_code, 'N')   <> 'P'
         AND i.cancelled_date           IS NOT NULL
         AND i.invoice_amount            = 0
		 and i.invoice_id=p_invoice_id
         AND EXISTS
            (SELECT 1
               FROM ap_invoice_distributions_all aid1
              WHERE aid1.invoice_id = aid.invoice_id
                AND aid1.prepay_distribution_id IS NOT NULL
                AND NVL(aid1.reversal_flag, 'N') = 'Y'
                AND (aid.parent_reversal_id
                     = aid1.invoice_distribution_id
                     OR aid.invoice_distribution_id
                     = aid1.parent_reversal_id)
                AND NVL(aid1.posted_flag, 'N') <> 'Y')
         AND NOT EXISTS
            (SELECT 1
               FROM ap_invoice_distributions_all aid2
              WHERE aid2.invoice_id           = i.invoice_id
                AND aid2.prepay_distribution_id IS NULL)	
       order by AID.INVOICE_ID, AID.INVOICE_LINE_NUMBER,
       aid.distribution_line_number, xe.event_type_code;
  

 
  ELSIF p_bug_num=9884253 THEN
  
  SELECT count(DISTINCT ai.invoice_id)
  Into p_rows   from ap_invoices_all ai,
                         ap_invoice_lines_all ail,
                         ap_invoice_distributions_all aid,
                         ap_system_parameters_all asp,
			 financials_system_params_all fsp
                    where ai.invoice_id = aid.invoice_id
		    and ai.invoice_id=p_invoice_id
		    and ai.invoice_type_lookup_code <> 'EXPENSE REPORT'
		    and ai.source <> 'ERS'
                    and asp.org_id = ai.org_id
		    and fsp.org_id = ai.org_id
		    and nvl(fsp.purch_encumbrance_flag, 'N') <> 'Y'
                    and ai.invoice_id = ail.invoice_id
                    and ail.line_number = aid.invoice_line_number
                    and ai.invoice_currency_code = asp.base_currency_code
                    and ail.line_source = 'IMPORTED'
		    and aid.line_type_lookup_code not in 
		    ('NONREC_TAX','REC_TAX','TRV','TIPV','TERV', 'IPV', 'ERV')
                    and (nvl(aid.base_amount, 0) <> 0
                         OR aid.amount <> aid.base_amount);  



  ELSIF p_bug_num=10177074 THEN
  
  SELECT count(DISTINCT ail.invoice_id)
  Into p_rows
	     FROM ap_invoice_lines_all ail 
	     WHERE ail.line_type_lookup_code ='TAX' 
	     and ail.invoice_id=p_invoice_id
	  	AND ail.summary_tax_line_id IS NOT NULL 
	  	AND ail.amount = 0 
	  	AND NVL(ail.cancelled_flag,'N') = 'N' 
	  	AND NVL(ail.discarded_flag,'N') = 'N'  
	  	AND EXISTS 
	  	  (SELECT 1 
	  	    FROM zx_lines zl1 
	  	   WHERE zl1.trx_id = ail.invoice_id 
	  	     AND zl1.application_id = 200 
	  	     AND zl1.entity_code = 'AP_INVOICES' 
	   	     AND zl1.event_class_code IN 
	  	      ('STANDARD INVOICES' , 'PREPAYMENT INVOICES', 'EXPENSE REPORTS') 
	  	     AND zl1.summary_tax_line_id = ail.summary_tax_line_id) 
	  	AND NOT EXISTS  
	  	  (SELECT 1 
	  	     FROM zx_lines zl 
	  	   WHERE zl.trx_id = ail.invoice_id 
	  	     AND zl.application_id = 200 
	  	     AND zl.entity_code = 'AP_INVOICES' 
	  	     AND zl.event_class_code IN  
	  	     ('STANDARD INVOICES' , 'PREPAYMENT INVOICES','EXPENSE REPORTS') 
	  	     AND zl.summary_tax_line_id = ail.summary_tax_line_id 
	  	     AND NVL(cancel_flag,'N') = 'N')
	   AND NOT EXISTS  
	  	  (SELECT 1 
	  	     FROM zx_lines_summary zls 
	  	   WHERE zls.trx_id = ail.invoice_id 
	  	     AND zls.application_id = 200 
	  	     AND zls.entity_code = 'AP_INVOICES' 
	  	     AND zls.event_class_code IN 
	  	     ('STANDARD INVOICES' , 'PREPAYMENT INVOICES', 'EXPENSE REPORTS') 
	  	     AND zls.summary_tax_line_id = ail.summary_tax_line_id 
	  	     AND NVL(zls.cancel_flag,'N') = 'Y');
  



  ELSIF p_bug_num=9978924 THEN
  
  SELECT count(DISTINCT a.invoice_id)
  Into p_rows  from (select /*+parallel(aid)*/ ai.org_id,
		       ai.invoice_num,
		       ai.invoice_id,
		       aid.invoice_line_number,
		       aid.invoice_distribution_id,
		       aid.line_type_lookup_code,
		       aid.posted_flag,
		       aid.accounting_date,
		       aid.period_name,
		       gsb.chart_of_accounts_id,
		       aid.set_of_books_id,
		       aid.dist_match_type,
		       aid.po_distribution_id,
		       aid.rcv_transaction_id,
		       aid.detail_tax_dist_id,
		       gcc.detail_posting_allowed_flag,
		       gcc.enabled_flag,
		       gcc.account_type,
		       gcc.summary_flag,
		       nvl((SELECT '1' /*+cardinality(glsv 1)*/
			     FROM gl_ledger_segment_values glsv
			    WHERE glsv.segment_value =
		       AP_INVOICE_DISTRIBUTIONS_PKG.get_balancing_segment_value(aid.dist_code_combination_id,
                                                           aid.set_of_books_id)
		       AND glsv.segment_type_code = 'B'
		       AND glsv.ledger_id = aid.set_of_books_id
		       AND aid.accounting_date BETWEEN
		              NVL(glsv.start_date, aid.accounting_date) AND
                              NVL(glsv.end_date, aid.accounting_date)
		       AND rownum = 1),
		       0) "BAL_SEG_VALID",
		       AP_INVOICE_DISTRIBUTIONS_PKG.get_balancing_segment_value(aid.dist_code_combination_id,
                                                aid.set_of_books_id) "OLD_BALANCING_SEG_VALUE",
		       decode(gcc.segment1,'DUMMY',gcc.segment1,'') "NEW_BALANCING_SEG_VALUE",
                       aid.dist_code_combination_id "OLD_CODE_COMBID",
                       decode(gcc.code_combination_id,000000,gcc.code_combination_id,null) "NEW_CODE_COMBID",
                       fnd_flex_ext.get_segs('SQLGL',
                                              'GL#',
                                              gsb.chart_of_accounts_id,
                                             aid.dist_code_combination_id) "OLD_CONCAT_ACCOUNT",
                       decode(aid.global_attribute_category,'DUMMY',aid.global_attribute_category,'') "NEW_CONCAT_ACCOUNT",
                       'Y' "PROCESS_FLAG",
                       'N' "VALIDATE_FLAG",
                       decode(aid.global_attribute1,'DUMMY',aid.global_attribute1,'') "ERROR_MESSAGE"
		  from ap_invoices_all              ai,
		       ap_invoice_distributions_all aid,
		       gl_ledgers                   gl,
		       gl_code_combinations         gcc,
		       ap_system_parameters_all     asp,
		       gl_sets_of_books             gsb
		 where ai.invoice_id = aid.invoice_id
		   and ai.invoice_id=p_invoice_id
		   and aid.dist_code_combination_id = gcc.code_combination_id
		   and aid.set_of_books_id = gl.ledger_id
		   and aid.historical_flag is null
		   and aid.posted_flag <> 'Y'
		   and nvl(gl.bal_seg_value_option_code, 'A') <> 'A' ) a
	          where a.BAL_SEG_VALID = 0;


  ELSIF p_bug_num=9738413 THEN
  
  SELECT count(DISTINCT a.invoice_id)
  Into p_rows FROM (SELECT  /*+ parallel(aid) */
			aid.invoice_id,
			aid.invoice_distribution_id,
			aid.accounting_event_id,
			aid.posted_flag,
			1 corruption_type,
			'Y' PROCESS_FLAG
		FROM ap_invoice_distributions_all aid
		WHERE aid.posted_flag      = 'Y'
		AND NVL(aid.match_status_flag,'N') <> 'A'
		AND EXISTS (SELECT 1
			  FROM xla_Events x
			  WHERE x.application_id = 200
			  AND x.event_id          = aid.accounting_event_id
			  AND x.event_Status_code   ='P'
			  AND x.process_status_code ='P'
			  )
		UNION
		SELECT  /*+ parallel(aid) */
			asa.invoice_id,
			asa.invoice_distribution_id,
			asa.accounting_event_id,
			asa.posted_flag,
			1 corruption_type,
			'Y' PROCESS_FLAG
		FROM ap_self_assessed_tax_dist_all asa
		WHERE asa.posted_flag      = 'Y'
		AND NVL(asa.match_status_flag,'N') <> 'A'
		AND EXISTS (SELECT 1
			  FROM xla_Events x
			  WHERE x.application_id = 200
			  AND x.event_id          = asa.accounting_event_id
			  AND x.event_Status_code   ='P'
			  AND x.process_status_code ='P'
			  )
		UNION
		SELECT /*+ parallel(ai) */
			ai.invoice_id,
			ail.line_number,
			NULL,
			NULL,
			2 corruption_type,
			'Y' process_flag
		FROM ap_invoices_all ai,
		  ap_invoice_lines_all ail,
		  ap_invoice_distributions_all aid
		WHERE ai.invoice_id    = ail.invoice_id
		AND ail.invoice_id     = aid.invoice_id
		AND ail.line_number    = aid.invoice_line_number
		AND ai.cancelled_date IS NULL
		AND ail.discarded_flag = 'Y'
		AND EXISTS (SELECT 1
			  FROM ap_invoice_distributions_all aid1
			  WHERE aid1.invoice_id                 = ai.invoice_id
			  AND NVL(aid1.posted_flag,'N')		<> 'Y'
			  AND (NVL(aid1.match_status_flag, 'N') = 'N'
			  OR (NVL(aid1.match_status_flag, 'N')  = 'T'
			  AND EXISTS
				(SELECT 1
				FROM ap_holds_all ah
				WHERE ah.invoice_id      = aid1.invoice_id
				AND release_lookup_code IS NULL
				))))
		GROUP BY ai.invoice_id,
		  ail.line_number,
		  DECODE(ail.historical_flag, 'Y', 0, ail.amount) 
		HAVING DECODE(ail.historical_flag, 'Y', 0, ail.amount) <> SUM (aid.amount)
	        UNION 
		SELECT /*+ parallel(ail) */
		      	 ail.invoice_id,
		         ail.line_number,
		         NULL,
		         NULL,
		         3 corruption_type,
		         'Y' process_flag
		FROM ap_invoice_lines_all ail
		WHERE ail.discarded_flag = 'Y'
		AND ail.amount <> 0
		AND NVL(ail.historical_flag,'N') <> 'Y'
		AND NOT EXISTS (select 1 from 
				ap_invoice_distributions_all aid
				where aid.invoice_id = ail.invoice_id
				and aid.invoice_line_number = ail.line_number)
		UNION
		SELECT /*+ parallel(aid) */
			aid.invoice_id,
			aid.invoice_distribution_id,
		        aid.accounting_event_id,
			aid.posted_flag,
			4 corruption_type,
			'Y' PROCESS_FLAG
		FROM ap_invoice_distributions_all aid
		WHERE line_type_lookup_code IN ('REC_TAX','NONREC_TAX','TRV','TERV','TIPV')
		AND detail_tax_dist_id      IS NULL
		AND summary_tax_line_id     IS NULL
		UNION
		SELECT /*+ parallel(asad) */
			  asad.invoice_id,
			  asad.invoice_distribution_id,
			  asad.accounting_event_id,
			  asad.posted_flag,
			  5 corruption_type,
			  'Y' PROCESS_FLAG
		FROM ap_self_assessed_tax_dist_all asad
		WHERE EXISTS
			(SELECT 1
			  FROM zx_rec_nrec_dist zd
			  WHERE zd.trx_id = asad.invoice_id  
			  AND zd.rec_nrec_tax_dist_id = asad.detail_tax_dist_id
			  AND zd.entity_code          = 'AP_INVOICES'
			  AND zd.event_class_code    IN ('STANDARD INVOICES', 'PREPAYMENT INVOICES', 'EXPENSE REPORTS')
			  AND zd.application_id       = 200
			  AND zd.self_assessed_flag   = 'N' )
		UNION
		SELECT /*+ parallel(aid) */
			  aid.invoice_id,
			  aid.invoice_distribution_id,
			  aid.accounting_event_id,
			  aid.posted_flag,
			  6 corruption_type,
			  'Y' PROCESS_FLAG
		FROM ap_invoice_distributions_all aid
		WHERE aid.detail_tax_dist_id IS NOT NULL
		AND EXISTS 
			(SELECT /*+ parallel(zd) */ 1
			  FROM zx_rec_nrec_dist zd
			  WHERE  zd.trx_id = aid.invoice_id 
			  AND zd.rec_nrec_tax_dist_id = aid.detail_tax_dist_id 
			  AND zd.entity_code          = 'AP_INVOICES'
			  AND zd.event_class_code    IN ('STANDARD INVOICES', 'PREPAYMENT INVOICES', 'EXPENSE REPORTS')
			  AND zd.application_id       = 200
			  AND zd.self_assessed_flag   = 'Y' )
		UNION
		SELECT  /*+ parallel(asad) */
			ai.invoice_id,
			asad.invoice_distribution_id,
			NULL,
			NULL,
			7 corruption_type,
			'Y' PROCESS_FLAG
		FROM ap_self_assessed_tax_dist_all asad,
		     ap_invoices_all ai
		WHERE ai.invoice_id= asad.invoice_id
		AND asad.accounting_event_id IS NULL
		AND ai.cancelled_date is null
		AND NVL(ai.force_revalidation_flag,'N') <> 'Y'
		AND AP_INVOICES_PKG.get_approval_status(ai.invoice_id, ai.invoice_amount, 
			ai.payment_status_flag, ai.invoice_type_lookup_code) 
			IN ('APPROVED','AVAILABLE','UNPAID','FULL')
		UNION
		SELECT  /*+ parallel(aha) */
			  aha.invoice_id,
			  aha.hold_id,
			  NULL,
			  NULL,
			  8 corruption_type,
			  'Y' PROCESS_FLAG
		FROM ap_holds_all aha
		WHERE hold_lookup_code   = 'CANNOT EXECUTE ALLOCATION'
		AND release_lookup_code IS NULL
		AND NOT EXISTS
		  (SELECT 1
		  FROM ap_invoice_lines_all ail
		  WHERE ail.invoice_id       = aha.invoice_id
		  AND line_type_lookup_code IN('FREIGHT','MISCELLANEOUS')
		  AND NVL(discarded_flag,'N')    = 'N'
		  AND NVL(generate_dists,'N')    = 'Y'
		  )
		UNION
		SELECT /*+ parallel(aha) */
			invoice_id,
			NULL,
			NULL,
			NULL,
			9 corruption_type,
			'Y'PROCESS_FLAG
		FROM ap_invoices_all
		WHERE cancelled_date   IS NOT NULL
		AND NVL(amount_paid,0) <> 0
		UNION
		SELECT /*+ parallel(aha) */
			ai.invoice_id,
			NULL,
			NULL,
			NULL,
			10 corruption_type,
			'Y' process_flag
		FROM ap_invoices_all ai 
		WHERE ai.cancelled_date IS NOT NULL 
		AND ai.invoice_amount = 0 
		AND EXISTS
			  (SELECT 1
			  FROM ap_payment_schedules_all aps
			  WHERE aps.invoice_id = ai.invoice_id
			  AND aps.hold_flag    = 'Y'
			  )
		UNION
		SELECT /*+ parallel(aha) */ 
			aid.invoice_id,
			aid.invoice_distribution_id,
			aid.accounting_event_id,
			aid.posted_flag,
			11 corruption_type,
			'Y' PROCESS_FLAG
		FROM ap_invoice_distributions_all aid
		WHERE aid.reversal_flag           = 'Y'
		AND EXISTS (SELECT 1 from ap_invoice_distributions_all aidrev
				WHERE aidrev.invoice_id            = aid.invoice_id
				AND aidrev.reversal_flag           = aid.reversal_flag
				AND aidrev.parent_reversal_id 	   = aid.invoice_distribution_id
				AND ABS(nvl(aidrev.amount,0)) <> ABS(nvl(aid.amount,0)))
		UNION
		SELECT  /*+ parallel(aid) */
			aid.invoice_id ,
			aid.invoice_distribution_id ,
			aid.accounting_event_id ,
			aid.posted_flag,
			12 corruption_type,
			'Y' PROCESS_FLAG
		FROM ap_invoice_distributions_all aid
		WHERE match_status_flag = 'S'
		AND EXISTS
			(SELECT 1
			FROM ap_invoices_all ai
			WHERE ai.invoice_id           = aid.invoice_id
			AND ai.validation_request_id IS NULL)
		UNION
		SELECT AID.invoice_id,
		   AID.invoice_distribution_id,
		   AID.bc_event_id,
		   AID.posted_flag,
		   13 corruption_type,
		   'Y' process_flag
		FROM ap_invoice_distributions_all AID,
			 ap_invoices_all  AI
		WHERE AI.invoice_id = AID.invoice_id
		AND ( AI.cancelled_date IS NOT NULL 
	         OR AI.temp_cancelled_amount IS NOT NULL )
		AND AI.invoice_amount = 0
		AND NVL( AI.historical_flag, 'N' ) <> 'Y'
		AND AI.validation_request_id IS NULL
		AND ( SELECT SUM( AID1.amount ) 
		      FROM ap_invoice_distributions_all AID1
	              WHERE AID1.invoice_id = AI.invoice_id ) = 0
		AND NOT EXISTS ( SELECT 1 
				 FROM ap_invoice_distributions_all AID2
				 WHERE AID2.invoice_id = AI.invoice_id
				 AND AID2.parent_reversal_id IS NULL
       		                 AND AID2.reversal_flag = 'Y'
				 AND ( SELECT COUNT( 1 )
                       		        FROM ap_invoice_distributions_all AID3
                    		        WHERE AID3.parent_reversal_id = AID2.invoice_distribution_id 
                           ) <> 1 )
		AND ( ( NVL( AID.match_status_flag, 'N' ) <> 'A'
			AND NVL( AID.encumbered_flag, 'N' ) = 'N'
			AND AID.bc_event_id IS NOT NULL ) 
	        OR 	( NVL( AID.match_status_flag, 'A' ) = 'A' 
			AND AID.encumbered_flag = 'R'
			AND AID.bc_event_id IS NOT NULL ) 
       		OR	( NVL( AID.match_status_flag, 'N' ) <> 'A' 
			AND AID.encumbered_flag = 'N'
			AND AID.bc_event_id IS NULL) )
		AND NOT EXISTS ( SELECT 1
				 FROM xla_events XE
				 WHERE XE.application_id = 200
				 AND XE.event_id = AID.bc_event_id
				 AND XE.event_status_code = 'P' )
		) a WHERE a.invoice_id=p_invoice_id;
 
  
  
  ELSIF p_bug_num=9709414     THEN
  
  select count(distinct invoice_id)
  INTO p_rows
from ap_invoice_distributions_all aid,
ap_system_parameters_all asp
where AID.LINE_TYPE_LOOKUP_CODE = 'AWT'
and aid.awt_flag = 'A'
and AID.AWT_INVOICE_PAYMENT_ID is null
and AID.HISTORICAL_FLAG is null
and AID.ORG_ID = ASP.ORG_ID
and ASP.CREATE_AWT_DISTS_TYPE = 'PAYMENT'
and aid.invoice_id=p_invoice_id
and rownum=1;
  
  ELSIF p_bug_num= 9930098   THEN
   
     select count(distinct aid.invoice_id)
	 into p_rows
         from ap_invoice_distributions_all aid , ap_invoices_all ai
         where aid.invoice_id = ai.invoice_id
		    and ai.exchange_rate is NULL
		    and AID.AMOUNT <> 0
            and AID.BASE_AMOUNT = 0
            and aid.historical_flag= 'Y'
			and ai.invoice_id=p_invoice_id;
  
  ELSIF p_bug_num=9253530   THEN
  
  SELECT count(distinct(ai.invoice_id))
  INTO p_rows
FROM xla_events xe,
xla_transaction_entities_upg xte,
ap_prepay_history_all apph,
ap_invoices_all ai,
ap_invoices_all ai_prepay,
ap_suppliers asu,
ap_supplier_sites_all assi,
(SELECT decode(SUM(aid.amount),
0, 1,
SUM(aid.amount)) amt,
aid.accounting_event_id
FROM ap_invoice_distributions_all aid
WHERE aid.line_type_lookup_code IN ('PREPAY',
'REC_TAX',
'NONREC_TAX')
AND aid.prepay_distribution_id IS NOT NULL
GROUP BY aid.accounting_event_id) dist_sum,
(SELECT SUM(nvl(xal.entered_cr, 0) -
nvl(xal.entered_dr, 0)) amt,
xe.event_id,
xah.ledger_id
FROM xla_ae_lines xal,
xla_ae_headers xah,
xla_events xe,
xla_transaction_entities_upg xte
WHERE xal.application_id = 200
AND xah.application_id = 200
AND xe.application_id = 200
AND xal.ae_header_id = xah.ae_header_id
AND xah.event_id = xe.event_id
AND xe.entity_id = xte.entity_id
AND xte.entity_code = 'AP_INVOICES'
AND xte.ledger_id = xah.ledger_id
AND xal.accounting_class_code = 'PREPAID_EXPENSE'
AND xe.event_type_code IN('PREPAYMENT APPLIED',
'PREPAYMENT UNAPPLIED')
GROUP BY xe.event_id,
xah.ledger_id) acct_sum
WHERE xe.application_id = 200
AND xe.event_type_code IN('PREPAYMENT APPLIED',
'PREPAYMENT UNAPPLIED')
AND xe.event_status_code = 'P'
AND xe.event_id = dist_sum.accounting_event_id
AND xe.event_id = acct_sum.event_id
AND ABS(ABS(acct_sum.amt) / ABS(dist_sum.amt)) > 2
AND xe.event_id = apph.accounting_event_id
AND apph.prepay_invoice_id = ai_prepay.invoice_id
AND xte.application_id = 200
AND xe.entity_id = xte.entity_id
AND xte.entity_code = 'AP_INVOICES'
AND nvl(xte.source_id_int_1, -99) = ai.invoice_id
AND ai.vendor_id = asu.vendor_id(+)
and AI.VENDOR_SITE_ID = ASSI.VENDOR_SITE_ID(+)
and ai.invoice_id=p_invoice_id
and rownum=1;
  
  ELSIF p_bug_num=9834746   THEN
  
  select count(distinct(ai.invoice_id))
  INTO p_rows
		FROM ap_invoice_lines_all ail,
			 AP_INVOICES_ALL AI
		WHERE ail.invoice_id = ail.corrected_inv_id
		and AI.INVOICE_ID = AIL.CORRECTED_INV_ID
		and NVL(MATCH_TYPE,'NOT_MATCHED') in ('PRICE_CORRECTION','AMOUNT_CORRECTION','NOT_MATCHED')
		and ai.invoice_id=p_invoice_id
		and rownum=1;

  
  ELSIF p_bug_num=9570464  THEN
     select count(distinct(ai.invoice_id))
	 INTO p_rows
     from ap_invoice_distributions_all aid,
          ap_invoice_distributions_all aid_item,
          ap_invoices_all ai
      where ai.historical_flag = 'Y'
        and ai.invoice_id = aid.invoice_id
        and aid.historical_flag = 'Y'
        and aid.charge_applicable_to_dist_id is not null
        and aid.line_type_lookup_code in ('TIPV','TERV','REC_TAX','NONREC_TAX')
        and aid.invoice_id = aid_item.invoice_id
        and AID.CHARGE_APPLICABLE_TO_DIST_ID = AID_ITEM.INVOICE_DISTRIBUTION_ID
        and aid_item.amount <> NVL(aid.taxable_amount,aid_item.amount-1)
		and ai.invoice_id=p_invoice_id
		and rownum=1;
  
   ELSIF p_bug_num=9342198    THEN
   
    SELECT COUNT (DISTINCT aid.invoice_id )
	INTO p_rows
               FROM ap_invoice_distributions_all AID
         WHERE AID.parent_reversal_id         IS NOT NULL
           AND AID.line_type_lookup_code      = 'AWT'
           AND AID.global_attribute_category IS NULL
		   AND AID.INVOICE_ID=p_invoice_id
		   AND rownum=1
           AND EXISTS
               (SELECT 1
                  FROM ap_invoice_distributions_all AID1
                 WHERE AID1.invoice_distribution_id   = AID.parent_reversal_id
                   AND AID1.invoice_id                = AID.invoice_id
                   AND AID1.global_attribute_category IS NOT NULL);
  
   ELSIF p_bug_num = 9011329 THEN
   
   
    SELECT count(count(aid.invoice_id)) 
	INTO p_rows
    FROM ap_invoice_distributions_all aid,
              ap_invoice_lines_all ail
        WHERE aid.invoice_id = ail.invoice_id
          AND ail.line_number = aid.invoice_line_number
          AND ail.line_type_lookup_code = 'AWT'
          AND aid.line_type_lookup_code = 'AWT'
          AND nvl(aid.historical_flag,'N') <> 'Y'
          AND ail.LINE_SOURCE ='AUTO WITHHOLDING'
          AND NVL(ail.discarded_flag,'N') <> 'Y'
		  AND AID.INVOICE_ID=p_invoice_id
		  AND rownum=1
        GROUP BY aid.invoice_id,
               aid.invoice_line_number,
               ail.amount,
               ail.base_amount
        HAVING ail.amount <> sum(aid.amount);
	
	ELSIF 	p_bug_num= 8966889   then 
	
	
	  SELECT COUNT (DISTINCT aid.invoice_id )
	  INTO p_rows
      FROM ap_invoice_distributions_all aid,
        ap_invoice_lines_all ail,
        ap_invoices_all ai,
        ap_holds_all aha
  WHERE aid.invoice_id = ail.invoice_id
    AND ail.invoice_id = ai.invoice_id
    AND aha.invoice_id = ai.invoice_id
    AND aha.hold_lookup_code ='DIST VARIANCE'
    AND aha.release_lookup_code IS NULL
    AND ai.invoice_amount = 0
    AND ap_invoices_utility_pkg.get_approval_status
          (ai.invoice_id, 
 	      ai.invoice_amount, 
 	      ai.payment_status_flag, 
 	      ai.invoice_type_lookup_code) ='NEEDS REAPPROVAL' 
   AND ai.cancelled_date IS NULL
   AND ai.temp_cancelled_amount IS NOT NULL
   AND ail.line_type_lookup_code ='AWT'
   AND ail.invoice_id = ai.invoice_id
   AND ail.line_source LIKE'%MANUAL%'
   AND aid.invoice_line_number = ail.line_number
   AND aid.line_type_lookup_code ='AWT'
   AND aid.awt_flag ='M'
   AND aid.parent_reversal_id IS NULL
   AND aid.invoice_id=p_invoice_id
   AND rownum=1
   AND NOT EXISTS
          (SELECT 1
   	        FROM ap_invoice_distributions_all aid1
 	       WHERE aid1.invoice_id = aid.invoice_id
 	         AND aid1.parent_reversal_id = aid.invoice_distribution_id) ; 
			 
			 
   ELSIF  p_bug_num= 8966332 THEN
  
    
      SELECT count(1)
	  INTO p_rows
   FROM ap_invoice_distributions_all aid,
        ap_invoices_all ai, 
        xla_events xe,
        financials_system_params_all fsp
  WHERE ai.invoice_id = aid.invoice_id
    AND aid.accounting_event_id IS NOT NULL
    AND aid.org_id = fsp.org_id
    AND ((aid.match_status_flag = 'A' AND
          fsp.purch_encumbrance_flag = 'Y') OR 
         (aid.match_status_flag IN ('A','T') AND
          nvl(fsp.purch_encumbrance_flag, 'N') = 'N'))
    AND nvl(aid.historical_flag, 'N') = 'N'
    AND aid.line_type_lookup_code IN ('PREPAY', 'REC_TAX', 'NONREC_TAX')
    AND aid.prepay_distribution_id IS NOT NULL
    AND aid.posted_flag IN ('N', 'S')
    AND aid.accounting_event_id = xe.event_id
    AND xe.event_status_code IN ('I','U')
    AND xe.application_id = 200
	AND ai.invoice_id=p_invoice_id
	AND rownum=1
    AND NOT EXISTS
       (SELECT 1
          FROM ap_prepay_app_dists apad
         WHERE apad.prepay_app_distribution_id = 
                           aid.invoice_distribution_id 
           AND apad.accounting_event_id = 
                        aid.accounting_event_id) ;
						
   ELSIF  p_bug_num= 8966893   THEN
   
  
       
       SELECT count(distinct(ai.invoice_id))
	   INTO p_rows
        FROM ap_invoices_all ai,              
             ap_self_assessed_tax_dist_all sd,
             zx_rec_nrec_dist zxd
       WHERE ai.invoice_id = sd.invoice_id
         AND ai.invoice_id = p_invoice_id	   
         AND zxd.rec_nrec_tax_dist_id = sd.detail_tax_dist_id
         AND sd.posted_flag IN ('N', 'S') 
         AND rownum=1		 
         AND sd.self_assessed_tax_liab_ccid IS NULL;
		 
   ELSIF p_bug_num =8966880   THEN
   
     
           SELECT count(distinct(ai.invoice_id))
		   INTO p_rows
           FROM ap_prepay_app_dists apad,
           ap_invoice_distributions_all aid,
           ap_invoice_distributions_all aid1,
           ap_invoices_all ai,
           xla.xla_events xe
           WHERE xe.event_id = apad.accounting_event_id
           AND xe.application_id = 200
           AND (xe.upg_batch_id IS NULL or xe.upg_batch_id = -9999)
           AND xe.event_type_code IN ('PREPAYMENT APPLIED','PREPAYMENT UNAPPLIED')
           AND apad.prepay_app_distribution_id = aid.invoice_distribution_id
           AND aid.posted_flag <> 'Y'
           AND nvl(aid.historical_flag, 'N') <> 'Y'
           AND aid.line_type_lookup_code IN ('PREPAY', 'REC_TAX', 'NONREC_TAX')
           AND aid.prepay_distribution_id IS NOT NULL
           AND aid.invoice_id = ai.invoice_id
           AND apad.invoice_distribution_id = aid1.invoice_distribution_id
           AND aid1.line_type_lookup_code NOT IN ('AWT','PREPAY')
           AND aid1.cancellation_flag = 'Y'
           AND rownum=1		   
		   AND ai.invoice_id=p_invoice_id;	

ELSIF  p_bug_num= 8966332 THEN
      
      SELECT count(1)
	  INTO p_rows
   FROM ap_invoice_distributions_all aid,
        ap_invoices_all ai, 
        xla_events xe,
        financials_system_params_all fsp
  WHERE ai.invoice_id = aid.invoice_id
    AND aid.accounting_event_id IS NOT NULL
    AND aid.org_id = fsp.org_id
    AND ((aid.match_status_flag = 'A' AND
          fsp.purch_encumbrance_flag = 'Y') OR 
         (aid.match_status_flag IN ('A','T') AND
          nvl(fsp.purch_encumbrance_flag, 'N') = 'N'))
    AND nvl(aid.historical_flag, 'N') = 'N'
    AND aid.line_type_lookup_code IN ('PREPAY', 'REC_TAX', 'NONREC_TAX')
    AND aid.prepay_distribution_id IS NOT NULL
    AND aid.posted_flag IN ('N', 'S')
    AND aid.accounting_event_id = xe.event_id
    AND xe.event_status_code IN ('I','U')
    AND xe.application_id = 200
	AND rownum=1
	AND ai.invoice_id=p_invoice_id
    AND NOT EXISTS
       (SELECT 1
          FROM ap_prepay_app_dists apad
         WHERE apad.prepay_app_distribution_id = 
                           aid.invoice_distribution_id 
           AND apad.accounting_event_id = 
                        aid.accounting_event_id) ;
						
   ELSIF  p_bug_num= 8966893   THEN
        
       SELECT count(distinct(ai.invoice_id))
	   INTO p_rows
        FROM ap_invoices_all ai,              
             ap_self_assessed_tax_dist_all sd,
             zx_rec_nrec_dist zxd
       WHERE ai.invoice_id = sd.invoice_id
         AND zxd.rec_nrec_tax_dist_id = sd.detail_tax_dist_id
         AND sd.posted_flag IN ('N', 'S')         
         AND sd.self_assessed_tax_liab_ccid IS NULL
		 AND rownum=1
		 AND ai.invoice_id=p_invoice_id; 
		 
    ELSIF p_bug_num =8966880   THEN
	
     
           SELECT count(distinct(ai.invoice_id))
		   INTO p_rows
           FROM ap_prepay_app_dists apad,
           ap_invoice_distributions_all aid,
           ap_invoice_distributions_all aid1,
           ap_invoices_all ai,
           xla.xla_events xe
           WHERE xe.event_id = apad.accounting_event_id
           AND xe.application_id = 200
           AND (xe.upg_batch_id IS NULL or xe.upg_batch_id = -9999)
           AND xe.event_type_code IN ('PREPAYMENT APPLIED','PREPAYMENT UNAPPLIED')
           AND apad.prepay_app_distribution_id = aid.invoice_distribution_id
           AND aid.posted_flag <> 'Y'
           AND nvl(aid.historical_flag, 'N') <> 'Y'
           AND aid.line_type_lookup_code IN ('PREPAY', 'REC_TAX', 'NONREC_TAX')
           AND aid.prepay_distribution_id IS NOT NULL
           AND aid.invoice_id = ai.invoice_id
           AND apad.invoice_distribution_id = aid1.invoice_distribution_id
           AND aid1.line_type_lookup_code NOT IN ('AWT','PREPAY')
           AND aid1.cancellation_flag = 'Y' 
		   AND rownum=1
		   AND ai.invoice_id=p_invoice_id;	 
		   
ELSIF p_bug_num=9071983 THEN
p_rows:=0;


SELECT count(distinct(invoice_id))
INTO l_rows1
        FROM ap_invoices_all ai
		WHERE ai.RELATIONSHIP_ID IS NOT NULL
	AND ai.REMIT_TO_SUPPLIER_ID IS NOT NULL
	AND ai.REMIT_TO_SUPPLIER_SITE_ID IS NOT NULL
	AND ai.RELATIONSHIP_ID = -1 
	AND ai.invoice_id=p_invoice_id
	AND rownum=1
	AND case 
		when nullif(ai.REMIT_TO_SUPPLIER_ID,
			ai.vendor_id) IS NOT NULL then 1
		when nullif(ai.REMIT_TO_SUPPLIER_SITE_ID,
			ai.vendor_site_id) is not null then 1 
		ELSE 0 end = 1;

		p_rows:=l_rows1;
    
    /*SELECT count(1)
	INTO l_rows1
        FROM ap_checks_all ac,ap_invoices_all ai,ap_invoice_payments_all aph
	WHERE ac.RELATIONSHIP_ID IS NOT NULL
	AND ac.REMIT_TO_SUPPLIER_ID IS NOT NULL
	AND ac.REMIT_TO_SUPPLIER_SITE_ID IS NOT NULL
	AND ac.RELATIONSHIP_ID = -1 
	AND ai.invoice_id= aph.invoice_id
	AND aph.check_id=ac.check_id
	AND ai.invoice_id=p_invoice_id
	AND case 
		when nullif(ac.REMIT_TO_SUPPLIER_ID,
			ac.vendor_id) IS NOT NULL then 1
		when nullif(ac.REMIT_TO_SUPPLIER_SITE_ID,
			ac.vendor_site_id) is not null then 1 
		ELSE 0 end = 1;
    
        p_rows:=p_rows+l_rows1;   */
     
    
     SELECT count(1)
	 INTO l_rows1
        FROM ap_payment_schedules_all aps
        WHERE APS.RELATIONSHIP_ID IS NOT NULL
	AND APS.REMIT_TO_SUPPLIER_ID IS NOT NULL
	AND APS.REMIT_TO_SUPPLIER_SITE_ID IS NOT NULL
	AND APS.RELATIONSHIP_ID = -1
	AND APS.INVOICE_ID=p_invoice_id
	AND rownum=1
   AND case 
		when nullif(APS.REMIT_TO_SUPPLIER_ID,
					nvl((select ai.vendor_id
				from ap_invoices_all ai
				where ai.invoice_id = aps.invoice_id),
					0)) IS NOT NULL then 1 
		when nullif(APS.REMIT_TO_SUPPLIER_SITE_ID, 
					nvl((select ai.vendor_site_id
				from ap_invoices_all ai
				where ai.invoice_id = aps.invoice_id),
					0)) is not null then 1 
		ELSE 0 end = 1;
    
  	   p_rows:=p_rows+l_rows1;
	   
    ELSIF p_bug_num=8966882  THEN
   
   
  
    SELECT count(1)
	INTO p_rows
         FROM ap_invoice_distributions_all aid,
              ap_invoices_all ai,
              ap_suppliers asu,
              ap_supplier_sites_all assi,
              xla_events xe
        WHERE ai.invoice_id = aid.invoice_id
          AND ai.vendor_id = asu.vendor_id(+)
          AND ai.vendor_site_id = assi.vendor_site_id(+)
          AND aid.line_type_lookup_code = 'REC_TAX'
          AND aid.prepay_distribution_id IS NULL
          AND xe.application_id = 200
          AND xe.event_id = aid.bc_event_id
          AND aid.bc_event_id IS NOT NULL
          AND nvl(aid.posted_flag, 'N') <> 'Y'
		  AND ai.invoice_id=p_invoice_id
		  AND rownum=1
          AND NOT EXISTS
              (SELECT 1
                 FROM xla_distribution_links xdl,
                      xla_ae_headers xah
                WHERE xdl.application_id = 200
                  AND xah.application_id = 200
                  AND xdl.ae_header_id = xah.ae_header_id
                  AND xah.event_id = aid.bc_event_id
       	   AND xah.balance_type_code = 'E'
       	   AND xdl.source_distribution_type = 'AP_INV_DIST'
       	   AND xdl.source_distribution_id_num_1 = aid.invoice_distribution_id);
		   
		
		   
    ELSIF p_bug_num= 8968844   THEN
	
	 
        p_rows:=0  ;
         SELECT count(distinct(aid.invoice_distribution_id))
		 INTO l_rows1
         FROM ap_invoice_distributions_all aid,
              ap_invoice_distributions_all aidr,
              financials_system_params_all fsp,
              xla_events xe,
              xla_events xer
        WHERE aid.bc_event_id = xe.event_id(+)
          AND aidr.bc_event_id = xer.event_id(+)
          AND xe.application_id(+) = 200
          AND xer.application_id(+) = 200
          AND xe.budgetary_control_flag(+) ='Y'
          AND xer.budgetary_control_flag(+) ='Y'
          AND aid.invoice_distribution_id = aidr.parent_reversal_id
          AND nvl(aid.historical_flag,'N') <>'Y'
          AND nvl(aidr.historical_flag,'N') <>'Y'
          AND nvl(aid.reversal_flag,  'N') ='Y'
          AND nvl(aidr.reversal_flag,  'N') ='Y'
          AND aid.invoice_id = aidr.invoice_id
          AND aid.org_id = fsp.org_id
          AND fsp.purch_encumbrance_flag ='Y'
          AND aid.invoice_line_number = aidr.invoice_line_number
		  AND aid.invoice_id=p_invoice_id
		  AND rownum=1
          AND (nvl(xe.event_id,  -99) =  -99 OR xe.event_status_code   <>'P')
          AND (nvl(xer.event_id, -99) =  -99 OR xer.event_status_code  <>'P')
          AND (nvl(xe.event_id,  -99) <> -99 OR nvl(xer.event_id, -99) <> -99);
		  
		  p_rows:=l_rows1;
          
           SELECT count(distinct(aid.invoice_distribution_id))
		   INTO l_rows1
         FROM ap_invoice_distributions_all aid,
              xla_events xe,
              financials_system_params_all fsp 
    WHERE nvl(aid.historical_flag,  'N') ='N'
          AND nvl(aid.posted_flag,'N') <>'Y'
          AND aid.po_distribution_id IS NULL
          AND aid.org_id = fsp.org_id
          AND nvl(fsp.purch_encumbrance_flag,  'N') ='Y'
          AND aid.encumbered_flag ='Y'
          AND aid.match_status_flag ='A'
          AND aid.bc_event_id = xe.event_id(+)
		  AND aid.invoice_id=p_invoice_id
		  AND rownum=1
          AND xe.application_id(+) = 200
          AND (nvl(xe.event_id, -99) = -99 OR 
               (nvl(xe.event_id, -99) <> -99 AND
                xe.event_status_code <>'P'))
          AND nvl(aid.reversal_flag,  'N') <>'Y';
	
		   
		  p_rows:= p_rows +l_rows1;
		  
       ELSIF p_bug_num=9358397  THEN
	   
	   

            select count(1) 
			INTO p_rows
          from ap_invoice_distributions_all aid,
               ap_system_parameters_all asp		  
         where aid.line_type_lookup_code = 'AWT' 
           and aid.posted_flag = 'N' 
           and aid.awt_related_id is NULL
		   and aid.historical_flag = 'Y'
		   and aid.org_id = asp.org_id
		   AND rownum=1
		   and nvl(asp.automatic_offsets_flag,'N') <> 'Y'
		   and aid.invoice_id=p_invoice_id;	
	 
	 ELSIF p_bug_num=8970059   THEN

           SELECT count(distinct(aid.invoice_distribution_id))
		   INTO p_rows
			FROM ap_invoice_distributions_all aid,
			ap_invoices_all ai,
			ap_suppliers asu,
			ap_supplier_sites_all assi
			WHERE nvl(aid.historical_flag, 'N') = 'N'
			AND aid.invoice_id = ai.invoice_id
			AND ai.vendor_id = asu.vendor_id(+)
			AND ai.vendor_site_id = assi.vendor_site_id(+)
			AND ai.invoice_id =p_invoice_id
			AND rownum=1
			AND ((NOT EXISTS			
			(SELECT 1
			FROM ap_invoice_lines_all l
			WHERE l.invoice_id = aid.invoice_id
			AND l.line_number = aid.invoice_line_number)
			) OR
			aid.parent_reversal_id IN
			(SELECT p.invoice_distribution_id
			FROM ap_invoice_distributions_all p
			WHERE NOT EXISTS
			(SELECT 1
			FROM ap_invoice_lines_all l
			WHERE l.invoice_id = p.invoice_id
			AND l.line_number = p.invoice_line_number)));

    ELSIF p_bug_num =9088967  THEN 

	
	  SELECT count(DISTINCT (ai.invoice_id))
	  INTO p_rows
      FROM ap_invoices_all ai, ap_holds_all ah
      WHERE invoice_amount = 0
      AND cancelled_date IS NULL
      AND temp_cancelled_amount IS NOT NULL
	  AND ai.invoice_id =p_invoice_id
	  AND rownum=1
      AND ((0 <> (SELECT SUM(amount)
        FROM ap_invoice_distributions_all
       WHERE invoice_id = ai.invoice_id) OR
       EXISTS (SELECT 1 FROM AP_INVOICE_LINES_ALL AIL
               WHERE INVOICE_ID = AI.INVOICE_ID
                 AND NOT EXISTS (SELECT 1 FROM AP_INVOICE_DISTRIBUTIONS_ALL
                     WHERE INVOICE_ID = AIL.INVOICE_ID
                       AND INVOICE_LINE_NUMBER = AIL.LINE_NUMBER)))
          OR (ah.hold_lookup_code = 'NO RATE' AND ah.release_lookup_code IS NULL));	

ELSIF p_bug_num=9231093   THEN

    
		SELECT Count(distinct(aid.invoice_distribution_id))
		INTO p_rows
		FROM ap_invoice_distributions_all aid       
		WHERE aid.line_type_lookup_code ='NONREC_TAX'              
		AND aid.detail_tax_dist_id IS NOT NULL                       
		AND aid.summary_tax_line_id IS NOT NULL                      
		AND aid.parent_reversal_id IS NULL  
		AND aid.invoice_id=p_invoice_id
		AND NVL(aid.historical_flag,'N') = 'N'                   
		AND aid.posted_flag = 'N'				  
		AND EXISTS (SELECT 1                
		FROM ap_invoice_distributions_all aidv            
 		WHERE aidv.invoice_id = aid.invoice_id             
 		AND aidv.charge_applicable_to_dist_id = aid.charge_applicable_to_dist_id   
 		AND aidv.detail_tax_dist_id = aid.detail_tax_dist_id                       
 		AND aidv.summary_tax_line_id = aid.summary_tax_line_id                     
 		AND aidv.line_type_lookup_code IN ('TRV','TERV','TIPV') 
        AND rownum=1		
 		AND aidv.parent_reversal_id IS NOT NULL) ;
		
		ELSIF p_bug_num=9231459 THEN
		
		
		SELECT count(DISTINCT aid.invoice_distribution_id)
		INTO p_rows
        FROM ap_invoices_all ai,
        ap_invoice_distributions_all aid,
        ap_system_parameters_all asp,
        xla_ae_headers xah,
        xla_ae_lines xal,
        xla_distribution_links xdl
  WHERE ai.invoice_id = aid.invoice_id
    AND ai.invoice_id = p_invoice_id
    AND aid.org_id = asp.org_id
    AND nvl(aid.historical_flag,'N')  = 'N'
    AND asp.set_of_books_id = xah.ledger_id
    AND aid.accounting_event_id = xah.event_id
    AND xah.application_id = 200
    AND xal.application_id = 200
    AND xdl.application_id = 200
    AND aid.posted_flag = 'Y'
    AND xah.ae_header_id = xal.ae_header_id
    AND xah.event_id = xdl.event_id
    AND xah.ae_header_id = xdl.ae_header_id
    AND xal.ae_line_num = xdl.ae_line_num
    AND aid.line_type_lookup_code IN ('ITEM',   'ACCRUAL')
    AND xal.accounting_class_code = 'LIABILITY'
    AND xdl.source_distribution_id_num_1 = aid.invoice_distribution_id
    AND xdl.source_distribution_type = 'AP_INV_DIST'
	AND rownum=1
    AND nvl(xdl.unrounded_entered_cr,   xdl.unrounded_entered_dr) <> ABS(aid.amount)
    AND EXISTS
       (SELECT 1
          FROM ap_invoice_distributions_all d2
         WHERE d2.invoice_id = aid.invoice_id
           AND d2.line_type_lookup_code IN ('NONREC_TAX',    'REC_TAX')
           AND d2.invoice_line_number = aid.invoice_line_number
           AND d2.charge_applicable_to_dist_id = aid.invoice_distribution_id);
		   
ELSIF p_bug_num =9296562    THEN

	
     	SELECT count(distinct(aid.invoice_distribution_id))
		INTO p_rows
		FROM ap_invoice_distributions_all      aid           
	        WHERE aid.line_type_lookup_code   = 'NONREC_TAX'   
		AND aid.DIST_CODE_COMBINATION_ID= -99                
		AND aid.detail_tax_dist_id IS NOT NULL
		AND rownum=1
		AND AID.INVOICE_ID=p_invoice_id;
		
ELSIF p_bug_num=9076040 THEN
       
       SELECT count(distinct(AI.INVOICE_ID))
	   INTO p_rows
         FROM ap_invoices_all ai
         WHERE ai.historical_flag = 'Y' AND 
               ai.total_tax_amount IS NULL AND
			   ai.invoice_id=p_invoice_id
               AND EXISTS (SELECT 'tax exists'
                           FROM ap_invoice_lines_all ail
                           WHERE ai.invoice_id = ail.invoice_id
                           AND ail.line_type_lookup_code = 'TAX');	   		

						   ELSIF p_bug_num=9080707 THEN
	    SELECT COUNT(DISTINCT(aid.invoice_distribution_id))
		INTO p_rows
			FROM ap_invoice_distributions_all aid    
			WHERE  aid.historical_flag = 'Y'       
				   AND aid.line_type_lookup_code = 'AWT'  
				   AND aid.awt_invoice_payment_id  IS NOT NULL                
                   AND aid.parent_reversal_id IS NOT NULL 
                   AND aid.invoice_id=p_invoice_id 	
				   AND rownum=1				   
                   AND aid.reversal_flag = 'N' ;  

ELSIF p_bug_num= 9227325 THEN

            SELECT  COUNT(1)
			INTO p_rows
				FROM ap_invoice_lines_all ail                                        
				WHERE ail.historical_flag = 'Y'                                    AND
					  ail.discarded_flag    = 'Y'                                   AND 
					  ail.line_type_lookup_code <> 'AWT'                             
                      AND ail.amount = 0 
					  AND rownum=1
                      AND ail.invoice_id=p_invoice_id					  
					  AND ail.amount <>   (SELECT SUM(amount)                              
                                           FROM ap_invoice_distributions_all aid                    
                                            WHERE ail.invoice_id    = aid.invoice_id                 
                                           AND ail.line_number     = aid.invoice_line_number        
                                            AND aid.historical_flag = 'Y'  
                             )  AND NOT EXISTS  (SELECT 1                                            
                                                  FROM ap_invoice_distributions_all aid1                             
                                                   WHERE aid1.invoice_id             = ail.invoice_id                 
                                                      AND aid1.invoice_line_number      = ail.line_number                
                                                      AND (NVL(aid1.historical_flag,'N') = 'N' OR        
                                                    NVL(aid1.reversal_flag,'N')  <> 'Y'))     ;
 
ELSIF p_bug_num=9214370 THEN
    
	 SELECT  count(1)
	 INTO p_rows
         FROM ap_invoices_all ai                                    
         WHERE nvl(ai.accts_pay_code_combination_id,-1) = -1        
          AND nvl(historical_flag,'N')='N'
		  AND rownum=1
          AND invoice_id=p_invoice_id		  ;   

ELSIF p_bug_num=9327208 THEN
       SELECT count(1) 
	               INTO p_rows
		           FROM ap_invoices_all ai                                         
					WHERE ai.validation_request_id IS NOT NULL              
					AND ai.validation_request_id > 0                        
					AND ai.invoice_id=p_invoice_id
					AND rownum=1
					AND ( EXISTS                                            
					( SELECT 1  FROM fnd_concurrent_requests fcr      
						WHERE fcr.request_id = ai.validation_request_id 
						AND fcr.phase_code = 'C' )                    
						OR NOT EXISTS					     
						( SELECT 1 FROM fnd_concurrent_requests fcr       
						WHERE fcr.request_id = ai.validation_request_id ) 
						);   
 ELSIF p_bug_num=9113457 THEN
       
       
 SELECT count(DISTINCT aid2.invoice_id) 
  INTO l_rows1 
 FROM ap_invoice_distributions_all aid,   
      ap_invoice_distributions_all aid2   
 WHERE aid.parent_reversal_id IN (        
    SELECT aid1.parent_reversal_id        
    FROM ap_invoice_distributions_all aid1                  
    WHERE aid1.invoice_id = aid.invoice_id                  
    AND   aid1.historical_flag = 'Y'    
    AND   aid1.parent_reversal_id IS NOT NULL               
    GROUP BY aid1.parent_reversal_id  HAVING COUNT(*) > 1 ) 
 AND aid.historical_flag = 'Y'          
 AND aid.line_type_lookup_code      IN ('IPV','ERV')                  
 AND aid.parent_reversal_id = aid2.parent_reversal_id       
 AND aid2.historical_flag = 'Y'  
AND rownum=1 
 AND aid2.invoice_id = aid.invoice_id    
 and aid2.invoice_id=p_invoice_id ;
 
 p_rows:=l_rows1;
  SELECT 
         count(DISTINCT aid2.invoice_id)  
  INTO l_rows1		 
 FROM ap_invoice_distributions_all aid,   
      ap_invoice_distributions_all aid2   
 WHERE aid.parent_reversal_id IN (        
    SELECT aid1.parent_reversal_id        
    FROM ap_invoice_distributions_all aid1                  
    WHERE aid1.invoice_id = aid.invoice_id                  
    AND   aid1.historical_flag = 'Y'    
    AND   aid1.parent_reversal_id IS NOT NULL               
    GROUP BY aid1.parent_reversal_id  HAVING COUNT(*) > 1 ) 
 AND aid.historical_flag = 'Y'          
 AND aid.line_type_lookup_code            
    IN ('TIPV','TERV','REC_TAX','NONREC_TAX','MISCELLANEOUS','FREIGHT' ) 
 AND aid.parent_reversal_id = aid2.parent_reversal_id       
 AND aid2.historical_flag = 'Y'
AND rownum=1 
 AND aid2.invoice_id = aid.invoice_id    
and aid.invoice_id=p_invoice_id ;
 
	p_rows:=p_rows+l_rows1; 

ELSIF p_bug_num=9231247 THEN

   SELECT count(1)  
   INTO p_rows   
    FROM ap_invoices_all       AI,                              
         ap_invoice_lines_all  AIL,                             
         po_line_locations_all PLL,                             
         po_headers_all        PH                               
   WHERE AIL.invoice_id             = AI.invoice_id             
     AND AIL.po_header_id           = PH.po_header_id           
     and ( ( PH.TYPE_LOOKUP_CODE    = 'BLANKET'               
             AND NVL( PH.global_agreement_flag, 'N' ) = 'N' 
           )							 
                                   OR PH.type_lookup_code = 'PLANNED'                 
         )                                                      
     AND pll.line_location_id       = ail.po_line_location_id   
     and PLL.PO_RELEASE_ID          is not null                 
     AND ail.po_release_id          IS NULL  
	 AND ai.invoice_id=p_invoice_id
	 AND rownum=1;

ELSIF p_bug_num=9341543   THEN

      SELECT count(1)
	  INTO p_rows
        	FROM ap_invoices_all AI,              
                     ap_invoice_distributions_all aid,              
                     ap_invoice_lines_all AIL        
		WHERE AI.invoice_id = AIL.invoice_id          
	        and AIL.invoice_id = aid.invoice_id          
		and ai.invoice_id = aid.invoice_id
                and nvl(ai.historical_flag, 'N') <> 'Y'		
		and ai.TEMP_CANCELLED_AMOUNT is not null          
		and ai.cancelled_date is null          
		and aid.reversal_flag = 'Y'          
		and aid.parent_reversal_id is not null 
        and ai.invoice_id=p_invoice_id	
        and rownum=1		
		and exists (select 1 from ap_holds_all                       
			where invoice_id = ai.invoice_id                          
			and hold_lookup_code = 'DIST VARIANCE'                         
		       	and nvl(status_flag,'S') <> 'R')          
			and exists (select 1 from ap_invoice_distributions_all aid1
				where aid1.invoice_id = ai.invoice_id                         
				and aid1.parent_reversal_id = aid.parent_reversal_id                         
				and aid1.invoice_distribution_id <> aid.invoice_distribution_id);
    ELSIF 	p_bug_num= 9375004   THEN

        select count(1)
		INTO p_rows
		from AP_INVOICE_DISTS_ARCH aid
			,ap_invoice_distributions_all aid1
		where aid.invoice_id = aid1.invoice_id
			and aid.invoice_distribution_id = aid1.old_distribution_id
			and aid.awt_group_id is not NULL
			and aid1.line_type_lookup_code not in
			('ITEM','REC_TAX','NONREC_TAX','AWT')
			and AID1.AWT_GROUP_ID is null
			and nvl(aid1.historical_flag,'N')='Y' 
			and aid.invoice_id=p_invoice_id
			and rownum=1;				
 	END IF;
	  
END;

--Decaler Part Over-------  





  
BEGIN  

  l_invoice_id:=&invoice_id;
  AP_Acctg_Data_Fix_PKG.Open_Log_Out_Files ('apinv'||'-diag',l_file_location);
  AP_Acctg_Data_Fix_PKG.Print('<html><body>');
  PRINT_LINE;

	AP_Acctg_Data_Fix_PKG.Print('***********************'||
	                            '  INVOICE GDF DIAGNOSTIC TEST REPORT FOR INVOICE ID '|| l_invoice_id ||
	                            '**********************'); 
  PRINT_LINE;
  select to_char (sysdate,'DD-MON-YYYY HH:MI:SS') 
  INTO l_current_date From DUAL;
  
       SELECT instance_name, 
           host_name
      INTO l_database, 
           l_host_name
      FROM v$instance;
  AP_Acctg_Data_Fix_PKG.Print('You are running the script version : V1');  
  AP_Acctg_Data_Fix_PKG.Print('Script Run Time Is     : '|| l_current_date); 
  AP_Acctg_Data_Fix_PKG.Print('Script Run Database/Host Name are : '|| l_database||' / '||l_host_name);
 
  PRINT_LINE;
 



 /*+=======================================================================+
 | FILENAME                                                              |
 |     AP_AWT_ROUNDING_DIFF_SEL.sql                                      |
 |                                                                       |
 | DESCRIPTION                                                           |
 |     This datafix will correct the AWT invoice                         |
 |     distributions that have a rounding difference because of          |
 |     which the invoice will either not get validated or will go        |
 |     into needs revalidation state.                                    |
 +=======================================================================*/

BEGIN 

FND_File.Put_Line(fnd_file.output,
                   '---------------------------------------------------------');
FND_File.Put_Line(fnd_file.output,
                  'START'||' '||'967242.1'||'     '||
                  to_char(sysdate, 'DD-MON-YYYY:HH24:MI:SS'));

 
CHECK_COUNT(9011329,l_invoice_id,l_rows);



IF l_rows < l_row_limit and l_rows > 0 THEN 

BEGIN
  EXECUTE Immediate 'DROP TABLE ap_temp_data_driver_9011329';
	
EXCEPTION
  WHEN OTHERS THEN 
    l_debug_info :='Could not drop ap_temp_data_driver_9011329' ||sqlerrm;
    FND_File.Put_Line(fnd_file.output,l_debug_info);
  END;
  
  BEGIN
    EXECUTE Immediate 'DROP TABLE ap_temp_data_driver_9011329_m';
  EXCEPTION
  WHEN OTHERS THEN 
    l_debug_info :='Could not drop ap_temp_data_driver_9011329_m' ||sqlerrm;
    FND_File.Put_Line(fnd_file.output,l_debug_info);
  END;  

  --------------------------------------------------------------------------
  -- Step 2: Create the data driver table 
  --------------------------------------------------------------------------  
  BEGIN
    EXECUTE Immediate 'CREATE TABLE ap_temp_data_driver_9011329_m
                       (
                        INVOICE_ID               NUMBER(15),
                        INVOICE_LINE_NUMBER      NUMBER,
                        DISTRIBUTION_LINE_NUMBER NUMBER,
                        LINE_AMT                 NUMBER,
                        LINE_BASE_AMT            NUMBER,
                        DIST_AMT_TOT             NUMBER,
                        DIST_BASE_AMT_TOT        NUMBER,
                        AMOUNT_ADJ               NUMBER,
                        BASE_AMT_ADJ             NUMBER
                       )';
  l_debug_info := 'CREATE TABLE ap_temp_data_driver_9011329_m';
  FND_File.Put_Line(fnd_file.output,l_debug_info);
					   
  EXCEPTION
  WHEN OTHERS THEN
    l_debug_info := 'Driver table ap_temp_data_driver_9011329_m could not be created.' ||sqlerrm;
    FND_File.Put_Line(fnd_file.output,l_debug_info);
  END;

  BEGIN
    EXECUTE Immediate 'CREATE TABLE ap_temp_data_driver_9011329
                       (
                        INVOICE_ID               NUMBER(15),
                        INVOICE_LINE_NUMBER      NUMBER,
                        DISTRIBUTION_LINE_NUMBER NUMBER,
                        LINE_AMT                 NUMBER,
                        LINE_BASE_AMT            NUMBER,
                        DIST_AMT_TOT             NUMBER,
                        DIST_BASE_AMT_TOT        NUMBER,
                        AMOUNT_ADJ               NUMBER,
                        BASE_AMT_ADJ             NUMBER,
                        POSTED_FLAG              VARCHAR2(1),
                        AWT_INVOICE_PAYMENT_ID   NUMBER,
                        PROCESS_FLAG             VARCHAR2(1) DEFAULT ''Y''
                       )';
  l_debug_info := 'CREATE TABLE ap_temp_data_driver_9011329';
  FND_File.Put_Line(fnd_file.output,l_debug_info);
					   
  EXCEPTION
  WHEN OTHERS THEN
    l_debug_info := 'Driver table ap_temp_data_driver_9011329 could not be created.' ||sqlerrm;
    FND_File.Put_Line(fnd_file.output,l_debug_info);
  END;
  
  --------------------------------------------------------------------------
  -- Step 3: Populate the data driver table with affected transactions
  --------------------------------------------------------------------------
 
  BEGIN
  --veer
  
    EXECUTE Immediate 
    'Insert into ap_temp_data_driver_9011329_m
      (        
        INVOICE_ID,
        INVOICE_LINE_NUMBER,
        DISTRIBUTION_LINE_NUMBER,
        LINE_AMT,
        LINE_BASE_AMT,
        DIST_AMT_TOT,
        DIST_BASE_AMT_TOT,
        AMOUNT_ADJ,
        BASE_AMT_ADJ
      )        
      (
        SELECT /*+ parallel(ail) */ aid.invoice_id,
               aid.invoice_line_number,
               max(aid.distribution_line_number) dist_line_number,
               ail.amount line_amt,
               nvl(ail.base_amount,0) line_base_amt,
               sum(aid.amount) dist_amt_tot,
               sum(nvl(aid.base_amount,0)) dist_base_amt_tot,
               (ail.amount- sum(aid.amount)) amount_adj,
               (nvl(ail.base_amount,0) - sum(nvl(aid.base_amount,0))) base_amt_adj
         FROM ap_invoice_distributions_all aid,
              ap_invoice_lines_all ail
        WHERE aid.invoice_id = ail.invoice_id
          AND ail.line_number = aid.invoice_line_number
          AND ail.line_type_lookup_code = ''AWT''
          AND aid.line_type_lookup_code = ''AWT''
          AND nvl(aid.historical_flag,''N'') <> ''Y''
          AND ail.LINE_SOURCE =''AUTO WITHHOLDING''
          AND NVL(ail.discarded_flag,''N'') <> ''Y''
		GROUP BY aid.invoice_id,
               aid.invoice_line_number,
               ail.amount,
               ail.base_amount
        HAVING ail.amount <> sum(aid.amount))' ;
  --after dbms_output.put_line ('Before Execute emmidiate');

  EXCEPTION
  WHEN OTHERS THEN
    l_debug_info := 'Exception in inserting records into '||
                    'ap_temp_data_driver_9011329_m'||SQLERRM;
    FND_File.Put_Line(fnd_file.output,l_debug_info);
    
  END;
 
  
  BEGIN
    EXECUTE Immediate
    'Insert into ap_temp_data_driver_9011329
      (        
        INVOICE_ID,
        INVOICE_LINE_NUMBER,
        DISTRIBUTION_LINE_NUMBER,
        LINE_AMT,
        LINE_BASE_AMT,
        DIST_AMT_TOT,
        DIST_BASE_AMT_TOT,
        AMOUNT_ADJ,
        BASE_AMT_ADJ,
        POSTED_FLAG,
        AWT_INVOICE_PAYMENT_ID,
        PROCESS_FLAG
      )        
      (
        SELECT main_driver.invoice_id,
               main_driver.invoice_line_number,
               main_driver.distribution_line_number,
               main_driver.line_amt,
               main_driver.line_base_amt,
               main_driver.dist_amt_tot,
               main_driver.dist_base_amt_tot,
               main_driver.amount_adj,
               main_driver.base_amt_adj,
               aid.posted_flag,
               aid.awt_invoice_payment_id,
               ''Y''
         FROM ap_invoice_distributions_all aid,
              ap_temp_data_driver_9011329_m main_driver
        WHERE aid.invoice_id = main_driver.invoice_id
        AND   aid.invoice_line_number = main_driver.invoice_line_number
        AND   aid.distribution_line_number = main_driver.distribution_line_number)';

  EXCEPTION
  WHEN OTHERS THEN
    l_debug_info := 'Exception in inserting records into '||
                    'ap_temp_data_driver_9011329'||SQLERRM;
    FND_File.Put_Line(fnd_file.output,l_debug_info);
    
  END;
  
  --------------------------------------------------------------------------
  -- Step 4: Report all the affected transactions in Log file
  --------------------------------------------------------------------------

  BEGIN
    EXECUTE Immediate  
     'SELECT count(*) FROM ap_temp_data_driver_9011329' INTO l_count;
  EXCEPTION
  WHEN OTHERS THEN
    l_debug_info := 'Exception in selecting count from '||
                    'ap_temp_data_driver_9011329 '||SQLERRM;
    FND_File.Put_Line(fnd_file.output,l_debug_info); 
  END;
  
  --Check if any affected transactions exist
  IF (l_count > 0) THEN
    AP_Acctg_Data_Fix_PKG.Print('******* Summary of invoices selected '||
	                            'Where Withholding Tax Calculation Causing Fractional Differences and Holds'||
                                ' *******');
	AP_Acctg_Data_Fix_PKG.Print('Solution: Please follow the note 967242.1 for more details.');
    							
    BEGIN
      AP_Acctg_Data_Fix_PKG.Print_html_table ('INVOICE_ID,INVOICE_LINE_NUMBER,DISTRIBUTION_LINE_NUMBER,'
                  ||'LINE_AMT,LINE_BASE_AMT,DIST_AMT_TOT,DIST_BASE_AMT_TOT,AMOUNT_ADJ,BASE_AMT_ADJ,'
                  ||'POSTED_FLAG,AWT_INVOICE_PAYMENT_ID,PROCESS_FLAG',
                  'ap_temp_data_driver_9011329',
                  'WHERE INVOICE_ID ='|| l_invoice_id || 'GROUP by INVOICE_ID,INVOICE_LINE_NUMBER,DISTRIBUTION_LINE_NUMBER,'
                  ||'LINE_AMT,LINE_BASE_AMT,DIST_AMT_TOT,DIST_BASE_AMT_TOT,AMOUNT_ADJ,BASE_AMT_ADJ,'
                  ||'POSTED_FLAG,AWT_INVOICE_PAYMENT_ID,PROCESS_FLAG',
                  'AP_AWT_ROUNDING_DIFF_SEL.sql ');
			
   PRINT_LINE;	


    
    EXCEPTION
    WHEN OTHERS THEN
      l_debug_info := 'Exception in Call to ' || 
                           'AP_Acctg_Data_Fix_PKG.Print_html_table '||SQLERRM;
      FND_File.Put_Line(fnd_file.output,l_debug_info); 
    END;
   

END IF;

ELSIF l_rows > l_row_limit THEN
  AP_Acctg_Data_Fix_PKG.Print( 'More then 100 invoices affected'||
                               'Please follow the note 967242.1 and run this GDF individually'); 
							   PRINT_LINE;
END IF;

FND_File.Put_Line(fnd_file.output,
                  '  END'||' '||'967242.1'||'     '||
                  to_char(sysdate, 'DD-MON-YYYY:HH24:MI:SS'));

 EXCEPTION 
WHEN OTHERS THEN
  l_message := 'After '||l_message||'';
  AP_Acctg_Data_Fix_PKG.Print(l_message);
  l_message := 'Exception :: '||SQLERRM||'';
  AP_Acctg_Data_Fix_PKG.Print(l_message);
  APP_EXCEPTION.RAISE_EXCEPTION;

END;

--AP_AWT_ROUNDING_DIFF_SEL.sql

/*+=======================================================================+
 | FILENAME                                                              |
 |     unrev_man_awt_sel.sql                                             |
 |                                                                       |
 | DESCRIPTION                                                           |
 |  This Script is used to select all the Manual Withholding Invoice     |
 |  Distributions which are not reversed but the withholding line is 0.  |
 |  These invoices will be on dist variance hold when the user tries to  |
 |  cancel.                                                              |
 |                                                                       |
 |  unrev_man_awt_fix.sql needs to be executed after running this        |
 |  script to fix all such withholding distributions                     |
+=======================================================================+*/

BEGIN 
 l_bug_no :=8966889;         


FND_File.Put_Line(fnd_file.output,
                   '---------------------------------------------------------');
FND_File.Put_Line(fnd_file.output,
                  'START'||' '||'964952.1'||'     '||
                  to_char(sysdate, 'DD-MON-YYYY:HH24:MI:SS'));

CHECK_COUNT(8966889,l_invoice_id,l_rows);

IF l_rows < l_row_limit and l_rows > 0 THEN 

 
  l_driver_tab := 'AP_TEMP_DATA_DRIVER_'||l_bug_no;
  BEGIN
     l_sql_stmt :=
          ' DROP TABLE '||l_driver_tab;
    EXECUTE IMMEDIATE l_sql_stmt;
  EXCEPTION
    WHEN OTHERS THEN
      null;
  END;

  BEGIN
 
    l_sql_stmt :=
          ' CREATE TABLE '||l_driver_tab||
          '   AS '||
          ' SELECT DISTINCT aid.invoice_id      INVOICE_ID, '||
          '        aid.invoice_distribution_id  UNREVERSED_DIST_ID, '||
          '        aid.line_type_lookup_code    UNREVERSED_DIST_LINE_TYPE, '||
          '        aid.invoice_line_number      UNREVERSED_DIST_LINE_NUM, '||
          '        aid.distribution_line_number UNREVERSED_DIST_NUM, '||
          '        aid.amount                   UNREVERSED_DIST_AMT, '||
	  '        aid.org_id                   ORG_ID, '||
	  '        ''Y''                        PROCESS_FLAG '||
          '   FROM ap_invoice_distributions_all aid, '||
          '        ap_invoice_lines_all ail, '||
          '        ap_invoices_all ai, '||
          '        ap_holds_all aha '||
          '  WHERE aid.invoice_id = ail.invoice_id '||
          '    AND ail.invoice_id = ai.invoice_id '||
          '    AND aha.invoice_id = ai.invoice_id '||
          '    AND aha.hold_lookup_code = ''DIST VARIANCE'' '||
          '    AND aha.release_lookup_code IS NULL '||
          '    AND ai.invoice_amount = 0 '||
          '    AND ap_invoices_utility_pkg.get_approval_status '||
          '          (ai.invoice_id,  '||
          ' 	      ai.invoice_amount,  '||
          ' 	      ai.payment_status_flag,  '||
          ' 	      ai.invoice_type_lookup_code) = ''NEEDS REAPPROVAL''  '||
          '   AND ai.cancelled_date IS NULL '||
          '   AND ai.temp_cancelled_amount IS NOT NULL '||
          '   AND ail.line_type_lookup_code = ''AWT'' '||
          '   AND ail.invoice_id = ai.invoice_id '||
          '   AND ail.line_source LIKE ''%MANUAL%'' '||
          '   AND aid.invoice_line_number = ail.line_number '||
          '   AND aid.line_type_lookup_code = ''AWT'' '||
          '   AND aid.awt_flag = ''M'' '||
          '   AND aid.parent_reversal_id IS NULL '||
		  '   AND NOT EXISTS '||
          '          (SELECT 1 '||
          '   	        FROM ap_invoice_distributions_all aid1 '||
          ' 	       WHERE aid1.invoice_id = aid.invoice_id '||
          ' 	         AND aid1.parent_reversal_id = aid.invoice_distribution_id) ';


    EXECUTE IMMEDIATE l_sql_stmt;
  EXCEPTION
    WHEN OTHERS THEN
      l_error_log := ' Encountered an Unhandled Exception, '||SQLCODE||'-'||SQLERRM||
                     ' in '||l_calling_sequence||' while performing '||l_debug_info;
      AP_ACCTG_DATA_FIX_PKG.Print(l_error_log);
      DBMS_OUTPUT.put_line(l_error_log);

      l_error_log := 'The DYNAMIC SQL formed for execution is: '||l_sql_stmt;
      DBMS_OUTPUT.put_line(l_error_log);
      AP_ACCTG_DATA_FIX_PKG.Print(l_error_log);

      RAISE_APPLICATION_ERROR(-20001, 'UNKNOWN_SQL_ERROR');
  END;

   l_message := ' For following transactions cancellation process was not completed '||
                'Reversal distribution for manual withholding was not created '||
				'and the invoice was placed on DIST VARIANCE hold';
   
  l_message :=	'Please follow the note 964952.1 for more details';		
				
  
  l_select_list :=
           'INVOICE_ID,'||
           'UNREVERSED_DIST_ID,'||
           'UNREVERSED_DIST_LINE_TYPE,'||
           'UNREVERSED_DIST_LINE_NUM,'||
           'UNREVERSED_DIST_NUM,'||
           'UNREVERSED_DIST_AMT';

  
  l_table_name :=
         l_driver_tab;

  
  l_where_clause := 'WHERE INVOICE_ID='||l_invoice_id||
                                      ' ORDER BY INVOICE_ID,UNREVERSED_DIST_ID,UNREVERSED_DIST_LINE_TYPE,UNREVERSED_DIST_LINE_NUM,'||
                                      'UNREVERSED_DIST_NUM,UNREVERSED_DIST_AMT'|| 
                                      'ORDER BY INVOICE_ID,'||'UNREVERSED_DIST_LINE_NUM,'||'UNREVERSED_DIST_NUM';
  
  
  AP_ACCTG_DATA_FIX_PKG.Print_html_table
    (p_select_list       => l_select_list,
     p_table_in          => l_table_name,
     p_where_in          => l_where_clause,
     P_calling_sequence  => l_calling_sequence);

  
  		
   PRINT_LINE;	
    
ELSIF l_rows > l_row_limit THEN
  AP_Acctg_Data_Fix_PKG.Print( 'More then 100 invoices affected'||
                               'Please follow the note 964952.1 and run this GDF individually');  
							   PRINT_LINE;

END IF;							   

FND_File.Put_Line(fnd_file.output,
                  '  END'||' '||'964952.1'||'     '||
                  to_char(sysdate, 'DD-MON-YYYY:HH24:MI:SS'));

EXCEPTION
  WHEN OTHERS THEN
    IF SQLCODE <> -20001 THEN
      l_error_log := ' Encountered an Unhandled Exception, '||SQLCODE||'-'||SQLERRM||
                     ' in '||l_calling_sequence||' while performing '||l_debug_info;
      DBMS_OUTPUT.put_line(l_error_log);
      AP_ACCTG_DATA_FIX_PKG.Print(l_error_log);
    END IF;
	
END;

--unrev_man_awt_sel.sql

 /*+=======================================================================+
 | FILENAME                                                              |
 |     ap_apad_missing_sel.sql                                                                   |
 | DESCRIPTION                                                           |
 |   GDF for Approved Prepay Dists missing Prepay Distributions          |
 | HISTORY                                                               |
 |   Created By : GAGRAWAL                                               |
 +=======================================================================+*/

BEGIN 
l_bug_no  := '8966332'; 


FND_File.Put_Line(fnd_file.output,
                   '---------------------------------------------------------');
FND_File.Put_Line(fnd_file.output,
                  'START'||' '||'975184.1'||'     '||
                  to_char(sysdate, 'DD-MON-YYYY:HH24:MI:SS'));

CHECK_COUNT(8966332,l_invoice_id,l_rows);

IF l_rows < l_row_limit and l_rows > 0 THEN 

l_driver_tab := 'AP_TEMP_DATA_DRIVER_'||l_bug_no;

  BEGIN
     l_sql_stmt :=
          ' DROP TABLE '||l_driver_tab;
    EXECUTE IMMEDIATE l_sql_stmt;
  EXCEPTION
    WHEN OTHERS THEN
      null;
  END;

  l_sql_stmt :=
       ' CREATE TABLE '||l_driver_tab||' AS '||
       ' SELECT aid.invoice_id, '||
       '        ai.invoice_num, '||
       '        aid.invoice_distribution_id, '||
       '        aid.line_type_lookup_code, '||
       '        aid.invoice_line_number, '||
       '        aid.distribution_line_number, '||
       '        aid.accounting_event_id, '||
       '        aid.bc_event_id, '||
       '        aid.posted_flag, '||
       '        aid.org_id, '||
       '        ''Y'' process_flag '||
       '   FROM ap_invoice_distributions_all aid, '||
       '        ap_invoices_all ai,  '||
       '        xla_events xe, '||
       '        financials_system_params_all fsp '||
       '  WHERE ai.invoice_id = aid.invoice_id '||
       '    AND aid.accounting_event_id IS NOT NULL '||
       '    AND aid.org_id = fsp.org_id '||
       '    AND ((aid.match_status_flag = ''A'' AND '||
       '          fsp.purch_encumbrance_flag = ''Y'') OR  '||
       '         (aid.match_status_flag IN (''A'',''T'') AND '||
       '          nvl(fsp.purch_encumbrance_flag, ''N'') = ''N'')) '||
       '    AND nvl(aid.historical_flag, ''N'') = ''N'' '||
       '    AND aid.line_type_lookup_code IN (''PREPAY'', ''REC_TAX'', ''NONREC_TAX'') '||
       '    AND aid.prepay_distribution_id IS NOT NULL '||
       '    AND aid.posted_flag IN (''N'', ''S'') '||
       '    AND aid.accounting_event_id = xe.event_id '||
       '    AND xe.event_status_code IN (''I'',''U'') '||
       '    AND xe.application_id = 200 '||
	   '    AND NOT EXISTS '|| 
       '       (SELECT 1 '||
       '          FROM ap_prepay_app_dists apad '||
       '         WHERE apad.prepay_app_distribution_id =  '||
       '                           aid.invoice_distribution_id  '||
       '           AND apad.accounting_event_id =  '||
       '                        aid.accounting_event_id) ';

  EXECUTE IMMEDIATE l_sql_stmt ;

  l_message := ' Following  are the Prepayment Application Lines'||
               ' which are missing records in the Prepay Distributions'||
               ' table';
  AP_ACCTG_DATA_FIX_PKG.Print(l_message);
  AP_ACCTG_DATA_FIX_PKG.Print('Solution : Please follow note 975184.1');
 l_select_list :=
        'INVOICE_ID,'||
        'INVOICE_NUM,'||
        'INVOICE_DISTRIBUTION_ID,'||
	'LINE_TYPE_LOOKUP_CODE,'||
        'INVOICE_LINE_NUMBER,'||
        'DISTRIBUTION_LINE_NUMBER,'||
        'ACCOUNTING_EVENT_ID,'||
	'BC_EVENT_ID,'||
        'POSTED_FLAG,'||
	'ORG_ID';

  l_debug_info := 'Getting the table name ';
  l_table_name :=
         l_driver_tab;

  l_debug_info := 'Constructing the where clause ';
  l_where_clause :='WHERE invoice_id='||l_invoice_id || ' ORDER BY INVOICE_ID,'||
        'INVOICE_NUM,'||
        'INVOICE_DISTRIBUTION_ID,'||
	    'LINE_TYPE_LOOKUP_CODE,'||
        'INVOICE_LINE_NUMBER,'||
        'DISTRIBUTION_LINE_NUMBER,'||
        'ACCOUNTING_EVENT_ID,'||
	    'BC_EVENT_ID,'||
        'POSTED_FLAG,'||
	    'ORG_ID '||
        'ORDER BY '||
        'INVOICE_ID,'||
	    'INVOICE_LINE_NUMBER,'||
	    'DISTRIBUTION_LINE_NUMBER';
        
AP_ACCTG_DATA_FIX_PKG.Print_html_table
    (p_select_list       => l_select_list,
     p_table_in          => l_table_name,
     p_where_in          => l_where_clause,
     P_calling_sequence  => l_calling_sequence);
	 		
   PRINT_LINE;	
    
	 
ELSIF l_rows > l_row_limit THEN
  AP_Acctg_Data_Fix_PKG.Print( 'More then 100 invoices affected'||
                               'Please follow the note 975184.1 and run this GDF individually'); 
							   PRINT_LINE;

END IF;							   

FND_File.Put_Line(fnd_file.output,
                  '  END'||' '||'975184.1'||'     '||
                  to_char(sysdate, 'DD-MON-YYYY:HH24:MI:SS'));


END;
 
  --ap_apad_missing_sel.sql     

/*+=======================================================================+
 | FILENAME                                                              |
 |     ap_asatd_no_liab_sel.sql                                     |
 |                                                                       |
 | DESCRIPTION                                                           |
 |     This datafix will update the Liability CCID for self              |
 |     assessed distributions which created with no liability account.   |
 |                                                                       |
 | USAGE                                                                 |
 |     This script runs automatically on patching and creates an         |
 |     output file for the user to review                                |
 |                                                                       |
 +=======================================================================+  |*/
 
 BEGIN
 
FND_File.Put_Line(fnd_file.output,
                   '---------------------------------------------------------');
FND_File.Put_Line(fnd_file.output,
                  'START'||' '||'975162.1'||'     '||
                  to_char(sysdate, 'DD-MON-YYYY:HH24:MI:SS'));

 CHECK_COUNT(8966893,l_invoice_id,l_rows);


IF l_rows < l_row_limit and l_rows > 0 THEN 

BEGIN
    EXECUTE Immediate 'DROP TABLE ap_temp_data_driver_8966893';
  
  l_debug_info := 'DROP TABLE ap_temp_data_driver_8966893';
  FND_File.Put_Line(fnd_file.output,l_debug_info);

  EXCEPTION
  WHEN OTHERS THEN 
    l_debug_info :='Could not drop ap_temp_data_driver_8966893' ||sqlerrm;
    FND_File.Put_Line(fnd_file.output,l_debug_info);
  END;    

  --------------------------------------------------------------------------
  -- Step 2: Create the data driver table 
  --------------------------------------------------------------------------  
  BEGIN
    EXECUTE Immediate 'CREATE TABLE ap_temp_data_driver_8966893
                       (
                        INVOICE_NUM                  VARCHAR2(50),
                        INVOICE_ID                   NUMBER,                        
                        INVOICE_DISTRIBUTION_ID      NUMBER,
                        GL_DATE                      DATE,
                        TAX_RATE_ID                  NUMBER,
                        RECOVERY_RATE_ID             NUMBER, 
                        SELF_ASSESSED_FLAG           VARCHAR2(1),
                        RECOVERABLE_FLAG             VARCHAR2(1),
                        TAX_JURISDICTION_ID          NUMBER,
                        TAX_REGIME_ID                NUMBER,
                        TAX_ID                       NUMBER,
                        ORG_ID                       NUMBER,
                        TAX_STATUS_ID                NUMBER, 
                        DIST_CODE_COMBINATION_ID     NUMBER,
                        ACCOUNT_SOURCE_TAX_RATE_ID   NUMBER,
                        DETAIL_TAX_DIST_ID           NUMBER,
                        SELF_ASSESSED_TAX_LIAB_CCID  NUMBER,
                        SELF_ASSESS_T_LIAB_CCID_NEW  NUMBER,
                        PROCESS_FLAG                 VARCHAR2(1) DEFAULT ''Y'' 
                       )';
                    
  
             
  EXCEPTION
  WHEN OTHERS THEN
    l_debug_info := 'Driver table ap_temp_data_driver_8966893 could not be created.' ||sqlerrm;
    FND_File.Put_Line(fnd_file.output,l_debug_info);
  END;

  --------------------------------------------------------------------------
  -- Step 3: Populate the data driver table with affected transactions
  --------------------------------------------------------------------------
 
  BEGIN
    EXECUTE Immediate
    'Insert into ap_temp_data_driver_8966893
      ( 
        INVOICE_NUM,
        INVOICE_ID,        
        INVOICE_DISTRIBUTION_ID,       
        GL_DATE,
        TAX_RATE_ID,
        RECOVERY_RATE_ID, 
        SELF_ASSESSED_FLAG,
        RECOVERABLE_FLAG,
        TAX_JURISDICTION_ID,
        TAX_REGIME_ID,
        TAX_ID,
        ORG_ID,
        TAX_STATUS_ID, 
        DIST_CODE_COMBINATION_ID,
        ACCOUNT_SOURCE_TAX_RATE_ID,
        DETAIL_TAX_DIST_ID,
        SELF_ASSESSED_TAX_LIAB_CCID,
        SELF_ASSESS_T_LIAB_CCID_NEW,
        PROCESS_FLAG
      )        
      ( SELECT ai.invoice_num,
               sd.invoice_id,               
               sd.invoice_distribution_id,  
               zxd.gl_date,
               zxd.tax_rate_id,
               zxd.recovery_rate_id,
               zxd.self_assessed_flag,
               zxd.recoverable_flag,
               zxd.tax_jurisdiction_id,
               zxd.tax_regime_id,
               zxd.tax_id,
               sd.org_id,
               zxd.tax_status_id,
               sd.dist_code_combination_id,
               zxd.account_source_tax_rate_id,
               sd.detail_tax_dist_id,
               sd.self_assessed_tax_liab_ccid,
               NULL, 
               ''Y''
        FROM ap_invoices_all ai,              
             ap_self_assessed_tax_dist_all sd,
             zx_rec_nrec_dist zxd
       WHERE ai.invoice_id = sd.invoice_id
         AND zxd.rec_nrec_tax_dist_id = sd.detail_tax_dist_id
         AND sd.posted_flag IN (''N'', ''S'')         
         AND sd.self_assessed_tax_liab_ccid IS NULL)';
    
 

  EXCEPTION
  WHEN OTHERS THEN
    l_debug_info := 'Exception in inserting records into '||
                    'ap_temp_data_driver_8966893'||SQLERRM;
    FND_File.Put_Line(fnd_file.output,l_debug_info);
    
  END;
  
  --------------------------------------------------------------------------
  -- Step 4: Report all the affected transactions in Log file
  --------------------------------------------------------------------------

  BEGIN
    EXECUTE Immediate  
     'SELECT count(invoice_distribution_id) FROM ap_temp_data_driver_8966893' INTO l_count;
  EXCEPTION
  WHEN OTHERS THEN
    l_debug_info := 'Exception in selecting count from '||
                    'ap_temp_data_driver_8966893 '||SQLERRM;
    FND_File.Put_Line(fnd_file.output,l_debug_info); 
  END;
  
  --Check if any affected transactions exist
  IF (l_count > 0) THEN
    AP_Acctg_Data_Fix_PKG.Print('******* Summary of invoices selected'||
	                            'where Accounting Process Fails with 95353 Error For Self-Assessed' ||
								' *******');
    BEGIN
      AP_Acctg_Data_Fix_PKG.Print_html_table ('INVOICE_NUM,INVOICE_ID,INVOICE_DISTRIBUTION_ID,GL_DATE,TAX_RATE_ID,'
        ||'RECOVERY_RATE_ID,SELF_ASSESSED_FLAG,RECOVERABLE_FLAG,TAX_JURISDICTION_ID,TAX_REGIME_ID,TAX_ID,'
        ||'ORG_ID,TAX_STATUS_ID,DIST_CODE_COMBINATION_ID,ACCOUNT_SOURCE_TAX_RATE_ID,DETAIL_TAX_DIST_ID,'
        ||'PROCESS_FLAG',
        'ap_temp_data_driver_8966893',
        'WHERE invoice_id='||l_invoice_id||' GROUP BY INVOICE_NUM,INVOICE_ID,INVOICE_DISTRIBUTION_ID,GL_DATE,TAX_RATE_ID,'
        ||'RECOVERY_RATE_ID,SELF_ASSESSED_FLAG,RECOVERABLE_FLAG,TAX_JURISDICTION_ID,TAX_REGIME_ID,TAX_ID,'
        ||'ORG_ID,TAX_STATUS_ID,DIST_CODE_COMBINATION_ID,ACCOUNT_SOURCE_TAX_RATE_ID,DETAIL_TAX_DIST_ID,'
        ||'PROCESS_FLAG',
		'ap_asatd_no_liab_sel.sql ');
		EXCEPTION
    WHEN OTHERS THEN
      l_debug_info := 'Exception in Call to ' || 
                           'AP_Acctg_Data_Fix_PKG.Print_html_table '||SQLERRM;
      FND_File.Put_Line(fnd_file.output,l_debug_info); 
    END;
   
  END IF;
  ELSIF l_rows > l_row_limit THEN
  AP_Acctg_Data_Fix_PKG.Print( 'More then 100 invoices affected'||
                               'Please follow the note 975162.1 and run this GDF individually'); 
							   PRINT_LINE;
END IF;

FND_File.Put_Line(fnd_file.output,
                  '  END'||' '||'975162.1'||'     '||
                  to_char(sysdate, 'DD-MON-YYYY:HH24:MI:SS'));


EXCEPTION
WHEN OTHERS THEN
  l_message := 'After '||l_message||'';
  AP_Acctg_Data_Fix_PKG.Print(l_message);
  l_message := 'Exception :: '||SQLERRM||'';
  AP_Acctg_Data_Fix_PKG.Print(l_message);
  APP_EXCEPTION.RAISE_EXCEPTION;						   

 
 
 END;
 
 --ap_asatd_no_liab_sel.sql     
 
 /*+=======================================================================+
 | FILENAME                                                              |
 |     ap_apad_cancelled_dist_sel.sql                                    |
 |                                                                       |
 | DESCRIPTION                                                           |
 |     This script will select the affected invoices which are cancelled |
 |     and has prepayment applied/unapplied and the proration for        |
 |     prepayment has been done against the cancelled distributions due  |
 |     to which accounting of prepayment applied/prepayment unapplied is |
 |     failing with error - "This line cannot be accounted until the     |
 |     accounting event for the application.."                           |
 | HISTORY                                                               |
 +=======================================================================+*/
 
 BEGIN
--------------------------------------------------------------------------
  -- Step 1: Drop the temporary tables if already exists
  --------------------------------------------------------------------------
  
FND_File.Put_Line(fnd_file.output,
                   '---------------------------------------------------------');
FND_File.Put_Line(fnd_file.output,
                  'START'||' '||'982075.1'||'     '||
                  to_char(sysdate, 'DD-MON-YYYY:HH24:MI:SS'));

  CHECK_COUNT(8966880,l_invoice_id,l_rows);

  IF l_rows < l_row_limit and l_rows > 0 THEN 
  
  l_bug_no   := '8966880';

  l_driver_tab := 'AP_TEMP_DATA_DRIVER_'||l_bug_no;
  BEGIN
     l_sql_stmt :=
          ' DROP TABLE '||l_driver_tab;
    EXECUTE IMMEDIATE l_sql_stmt;
  EXCEPTION
    WHEN OTHERS THEN
      AP_Acctg_Data_Fix_PKG.Print('Could not delete driver table '|| 
                                  l_driver_tab||' ->'||sqlerrm );
  END;

  --------------------------------------------------------------------------
  -- Step 2: create backup tables and driver tables
  --------------------------------------------------------------------------
  
  l_sql_stmt :=
          ' CREATE TABLE '||l_driver_tab||
          '   AS '||
          ' SELECT apad.prepay_app_dist_id, '||
          '        apad.accounting_event_id, '||
          '        aid.invoice_id, '||
	  '        ai.invoice_num, '||
	  '        ai.invoice_date, '||
          '        aid.invoice_distribution_id, '||
	  '        aid.line_type_lookup_code, '||
          '        aid.invoice_line_number, '||
          '        aid.distribution_line_number, '||
          '        aid.amount, '||
          '        xe.event_type_code, '||
	  '        ''Y'' process_flag '||
          '   FROM ap_prepay_app_dists apad, '||
          '        ap_invoice_distributions_all aid, '||
          '        ap_invoice_distributions_all aid1, '||
	  '        ap_invoices_all ai, '||
          '        xla_events xe '||
          '  WHERE xe.event_id = apad.accounting_event_id '||
          '    AND xe.application_id = 200 '||
          '    AND (xe.upg_batch_id IS NULL or xe.upg_batch_id = ''-9999'')'||
          '    AND xe.event_type_code IN (''PREPAYMENT APPLIED'',''PREPAYMENT UNAPPLIED'') '||
          '    AND apad.prepay_app_distribution_id = aid.invoice_distribution_id '||
          '    AND aid.posted_flag <> ''Y'' '||
          '    AND nvl(aid.historical_flag, ''N'') <> ''Y'' '||
          '    AND aid.line_type_lookup_code IN (''PREPAY'', ''REC_TAX'', ''NONREC_TAX'') '||
          '    AND aid.prepay_distribution_id IS NOT NULL '||
	  '    AND aid.invoice_id = ai.invoice_id '||
          '    AND apad.invoice_distribution_id = aid1.invoice_distribution_id '||
          /*'    AND aid1.posted_flag = ''Y'' '|| */
          '    AND aid1.line_type_lookup_code NOT IN (''AWT'',''PREPAY'') '||
          '    AND aid1.cancellation_flag = ''Y'' ';


  EXECUTE IMMEDIATE l_sql_stmt;

  ------------------------------------------------------------------
  -- Step 3: Report all the affected transactions in Log file 
  ---------------------------------------------------------------------
  Begin
    Execute Immediate  
        'SELECT COUNT(*) from AP_TEMP_DATA_DRIVER_8966880' into l_count;
  EXCEPTION
    WHEN OTHERS THEN
          l_message := 'Exception in selecting count from '|| 
		       l_driver_tab||' for selecting affected records'||
		       SQLERRM ;
          AP_ACCTG_DATA_FIX_PKG.Print(l_message);
  END; 

  IF (l_count > 0) THEN    

  
    l_select_list :=
           'INVOICE_ID,'||
  	   'INVOICE_NUM,'||
	   'INVOICE_DATE,'||
	   'INVOICE_DISTRIBUTION_ID,'||
	   'LINE_TYPE_LOOKUP_CODE,'||
           'INVOICE_LINE_NUMBER,'||
           'DISTRIBUTION_LINE_NUMBER,'||
           'AMOUNT,'||
	   'EVENT_TYPE_CODE,'||
	   'ACCOUNTING_EVENT_ID'
         ;

 
    l_table_name := l_driver_tab;

 
    l_where_clause :='WHERE invoice_id='||l_invoice_id||' ORDER BY INVOICE_ID,'||
  	   'INVOICE_NUM,'||
	   'INVOICE_DATE,'||
	   'INVOICE_DISTRIBUTION_ID,'||
	   'LINE_TYPE_LOOKUP_CODE,'||
           'INVOICE_LINE_NUMBER,'||
           'DISTRIBUTION_LINE_NUMBER,'||
           'AMOUNT,'||
	   'EVENT_TYPE_CODE,'||
	   'ACCOUNTING_EVENT_ID '||
           'ORDER BY INVOICE_ID,'||
           '         INVOICE_LINE_NUMBER,'||
           '         DISTRIBUTION_LINE_NUMBER';

   l_message := ' Following transactions with Prepayment Applied/Unapplied Events Cannot be Accounted'||
                    'After The Invoice Is Cancelled';
   AP_ACCTG_DATA_FIX_PKG.Print(l_message);
	
	l_message :=  'Solution : Follow note 982075.1	';
					
    AP_ACCTG_DATA_FIX_PKG.Print(l_message);
    AP_ACCTG_DATA_FIX_PKG.Print_html_table
      (p_select_list       => l_select_list,
       p_table_in          => l_table_name,
       p_where_in          => l_where_clause,
       P_calling_sequence  => l_calling_sequence);
	   
 
  END IF; 
   		
   PRINT_LINE;				
  ELSIF l_rows > l_row_limit THEN
  AP_Acctg_Data_Fix_PKG.Print( 'More then 100 invoices affected'||
                               'Please follow the note 982075.1 and run this GDF individually'); 
							   PRINT_LINE;
  
  END IF;


FND_File.Put_Line(fnd_file.output,
                  '  END'||' '||'982075.1'||'     '||
                  to_char(sysdate, 'DD-MON-YYYY:HH24:MI:SS'));
 
EXCEPTION
WHEN OTHERS THEN
  l_message := 'After '||l_message||'';
  AP_Acctg_Data_Fix_PKG.Print(l_message);
  l_message := 'Exception :: '||SQLERRM||'';
  AP_Acctg_Data_Fix_PKG.Print(l_message);
  APP_EXCEPTION.RAISE_EXCEPTION;
 
 END;

--ap_apad_cancelled_dist_sel.sql


/*+=======================================================================+
| FILENAME                                                              |
|     ap_sup_merge_remit_cols_sel.sql                                         |
|                                                                       |
| DESCRIPTION                                                           |
|     This script will select records present in the system       |
|     whose remit to columns are not affected after supplier merge.  	   
+=======================================================================+*/

BEGIN
--------------------------------------------------------------------------
  -- Step 1: Drop the temporary tables if already exists
  --------------------------------------------------------------------------
  
FND_File.Put_Line(fnd_file.output,
                   '---------------------------------------------------------');
FND_File.Put_Line(fnd_file.output,
                  'START'||' '||'9071983'||'     '||
                  to_char(sysdate, 'DD-MON-YYYY:HH24:MI:SS'));
  
  CHECK_COUNT(9071983,l_invoice_id,l_rows);

  IF l_rows < l_row_limit and l_rows > 0 THEN 
  
  BEGIN
    Execute Immediate
      'DROP TABLE ap_temp_invoices_9071983';

  EXCEPTION
    WHEN OTHERS THEN
     NUll;
  END;

  /*BEGIN
    Execute Immediate
      'DROP TABLE ap_temp_checks_9071983';

  EXCEPTION
    WHEN OTHERS THEN
     NULL;
  END;

  BEGIN
    Execute Immediate
      'DROP TABLE ap_temp_recur_inv_9071983';

  EXCEPTION
    WHEN OTHERS THEN
     NULL;
  END;*/

  BEGIN
    Execute Immediate
      'DROP TABLE ap_temp_pay_sch_9071983';

  EXCEPTION
    WHEN OTHERS THEN
     NULL;
  END;

  --------------------------------------------------------------------------
  -- Step 2: create backup tables and driver tables
  --------------------------------------------------------------------------
 
  BEGIN
    Execute Immediate
      'CREATE TABLE ap_temp_invoices_9071983 AS
       SELECT invoice_id,
		invoice_num,
		org_id,
		vendor_id,
		vendor_site_id,
		remit_to_supplier_id,
		remit_to_supplier_site_id,
		relationship_id,
		''Y'' process_flag
       FROM ap_invoices_all
       WHERE 1=2';
   EXCEPTION
     WHEN OTHERS THEN
      l_message := 'EXCEPTION :: '||SQLERRM ||
                  ' in creating ap_temp_invoices_9071983';
      FND_File.Put_Line(fnd_file.output,l_message);
	  dbms_output.put_line(l_message||sqlerrm);
   END;

 /* BEGIN
    Execute Immediate
      'CREATE TABLE ap_temp_checks_9071983 AS
       SELECT check_id,
		check_number,
		org_id,
		vendor_id,
		vendor_site_id,
		remit_to_supplier_id,
		remit_to_supplier_site_id,
		relationship_id,
		''Y'' process_flag
       FROM ap_checks_all
       WHERE 1=2';
   EXCEPTION
     WHEN OTHERS THEN
      l_message := 'EXCEPTION :: '||SQLERRM ||
                  ' in creating ap_temp_checks_9071983';
      FND_File.Put_Line(fnd_file.output,l_message);
	  dbms_output.put_line(l_message||sqlerrm);
   END;

  BEGIN
    Execute Immediate
      'CREATE TABLE ap_temp_recur_inv_9071983 AS
       SELECT recurring_payment_id,
		recurring_pay_num,
		org_id,
		vendor_id,
		vendor_site_id,
		remit_to_supplier_id,
		remit_to_supplier_site_id,
		relationship_id,
		''Y'' process_flag
       FROM ap_recurring_payments_all
       WHERE 1=2';
   EXCEPTION
     WHEN OTHERS THEN
      l_message := 'EXCEPTION :: '||SQLERRM ||
                  ' in creating ap_temp_recur_inv_9071983';
      FND_File.Put_Line(fnd_file.output,l_message);
	  dbms_output.put_line(l_message||sqlerrm);
   END;*/

  BEGIN
    Execute Immediate
      'CREATE TABLE ap_temp_pay_sch_9071983 AS
       SELECT invoice_id,
		org_id,
		remit_to_supplier_id,
		remit_to_supplier_site_id,
		relationship_id,
		''Y'' process_flag
       FROM ap_payment_schedules_all
       WHERE 1=2';
   EXCEPTION
     WHEN OTHERS THEN
      l_message := 'EXCEPTION :: '||SQLERRM ||
                  ' in creating ap_temp_pay_sch_9071983';
      FND_File.Put_Line(fnd_file.output,l_message);
	  dbms_output.put_line(l_message||sqlerrm);
   END;

   /*Select the records in ap_invoices_all, ap_checks_all, ap_recurring_payments_all
     and ap_payment_schedules_all, whose remit to columns are not affected after merge. */	

   BEGIN
  	   
    Execute Immediate
      'INSERT INTO ap_temp_invoices_9071983      
        SELECT invoice_id,
		invoice_num,
		org_id,
		vendor_id,
		vendor_site_id,
		remit_to_supplier_id,
		remit_to_supplier_site_id,
		relationship_id,
		''Y'' process_flag
        FROM ap_invoices_all ai
        WHERE ai.RELATIONSHIP_ID IS NOT NULL
	AND ai.REMIT_TO_SUPPLIER_ID IS NOT NULL
	AND ai.REMIT_TO_SUPPLIER_SITE_ID IS NOT NULL
	AND ai.RELATIONSHIP_ID = -1 
	AND case 
		when nullif(ai.REMIT_TO_SUPPLIER_ID,
			ai.vendor_id) IS NOT NULL then 1
		when nullif(ai.REMIT_TO_SUPPLIER_SITE_ID,
			ai.vendor_site_id) is not null then 1 
		ELSE 0 end = 1';

   EXCEPTION
     WHEN OTHERS THEN
      l_message := 'EXCEPTION :: '||SQLERRM ||' in inserting in ap_temp_invoices_9071983';
      FND_File.Put_Line(fnd_file.output,l_message);
	  dbms_output.put_line(l_message||sqlerrm);
   END;   

   /*BEGIN
  	   
    Execute Immediate
      'INSERT INTO ap_temp_checks_9071983      
        SELECT check_id,
		check_number,
		org_id,
		vendor_id,
		vendor_site_id,
		remit_to_supplier_id,
		remit_to_supplier_site_id,
		relationship_id,
		''Y'' process_flag
        FROM ap_checks_all ac
        WHERE ac.RELATIONSHIP_ID IS NOT NULL
	AND ac.REMIT_TO_SUPPLIER_ID IS NOT NULL
	AND ac.REMIT_TO_SUPPLIER_SITE_ID IS NOT NULL
	AND ac.RELATIONSHIP_ID = -1 
	AND case 
		when nullif(ac.REMIT_TO_SUPPLIER_ID,
			ac.vendor_id) IS NOT NULL then 1
		when nullif(ac.REMIT_TO_SUPPLIER_SITE_ID,
			ac.vendor_site_id) is not null then 1 
		ELSE 0 end = 1';

   EXCEPTION
     WHEN OTHERS THEN
      l_message := 'EXCEPTION :: '||SQLERRM ||' in inserting in ap_temp_checks_9071983';
      FND_File.Put_Line(fnd_file.output,l_message);
	  dbms_output.put_line(l_message||sqlerrm);
   END;   

   BEGIN
  	   
    Execute Immediate
      'INSERT INTO ap_temp_recur_inv_9071983      
        SELECT recurring_payment_id,
		recurring_pay_num,
		org_id,
		vendor_id,
		vendor_site_id,
		remit_to_supplier_id,
		remit_to_supplier_site_id,
		relationship_id,
		''Y'' process_flag
        FROM ap_recurring_payments_all arp
        WHERE arp.RELATIONSHIP_ID IS NOT NULL
	AND arp.REMIT_TO_SUPPLIER_ID IS NOT NULL
	AND arp.REMIT_TO_SUPPLIER_SITE_ID IS NOT NULL
	AND arp.RELATIONSHIP_ID = -1 
	AND case 
		when nullif(arp.REMIT_TO_SUPPLIER_ID,
			arp.vendor_id) IS NOT NULL then 1
		when nullif(arp.REMIT_TO_SUPPLIER_SITE_ID,
			arp.vendor_site_id) is not null then 1 
		ELSE 0 end = 1';

   EXCEPTION
     WHEN OTHERS THEN
      l_message := 'EXCEPTION :: '||SQLERRM ||' in inserting in ap_temp_recur_inv_9071983';
      FND_File.Put_Line(fnd_file.output,l_message);
	  dbms_output.put_line(l_message||sqlerrm);
   END;  */

   BEGIN
  	   
    Execute Immediate
      'INSERT INTO ap_temp_pay_sch_9071983      
        SELECT invoice_id,
		org_id,
		remit_to_supplier_id,
		remit_to_supplier_site_id,
		relationship_id,
		''Y'' process_flag
        FROM ap_payment_schedules_all aps
        WHERE APS.RELATIONSHIP_ID IS NOT NULL
	AND APS.REMIT_TO_SUPPLIER_ID IS NOT NULL
	AND APS.REMIT_TO_SUPPLIER_SITE_ID IS NOT NULL
	AND APS.RELATIONSHIP_ID = -1
   AND case 
		when nullif(APS.REMIT_TO_SUPPLIER_ID,
					nvl((select ai.vendor_id
				from ap_invoices_all ai
				where ai.invoice_id = aps.invoice_id),
					0)) IS NOT NULL then 1 
		when nullif(APS.REMIT_TO_SUPPLIER_SITE_ID, 
					nvl((select ai.vendor_site_id
				from ap_invoices_all ai
				where ai.invoice_id = aps.invoice_id),
					0)) is not null then 1 
		ELSE 0 end = 1';

   EXCEPTION
     WHEN OTHERS THEN
      l_message := 'EXCEPTION :: '||SQLERRM ||' in inserting in ap_temp_pay_sch_9071983';
      FND_File.Put_Line(fnd_file.output,l_message);
	  dbms_output.put_line(l_message||sqlerrm);
   END;   

  ------------------------------------------------------------------
  -- Step 3: Report all the affected transactions in Log file 
  ---------------------------------------------------------------------
  BEGIN
  Execute Immediate  
      'SELECT COUNT(*) FROM ap_temp_invoices_9071983' into l_count_inv;
  EXCEPTION
      WHEN OTHERS THEN
        l_message := 'EXCEPTION :: '||SQLERRM ||
                  ' in counting data from ap_temp_invoices_9071983';
        FND_File.Put_Line(fnd_file.output,l_message);
	    dbms_output.put_line(l_message||sqlerrm);
  END; 

    IF (l_count_inv > 0) THEN 
      AP_Acctg_Data_Fix_PKG.Print('++++Details of Invoices present in the system, whose remit to columns were not affected after supplier merge.');   
	   AP_Acctg_Data_Fix_PKG.Print('Solution : Follow note 982802.1');
    BEGIN
    	
      AP_Acctg_Data_Fix_PKG.Print_html_table                           
       ('INVOICE_ID,INVOICE_NUM,ORG_ID,VENDOR_ID,VENDOR_SITE_ID,REMIT_TO_SUPPLIER_ID,REMIT_TO_SUPPLIER_SITE_ID,RELATIONSHIP_ID'
        ,'AP_TEMP_INVOICES_9071983'
        ,'WHERE INVOICE_ID=' || l_invoice_id
        ,'ap_sup_merge_remit_cols_sel.sql');    
                                 
    EXCEPTION                                                          
       WHEN OTHERS THEN
        l_message := 'EXCEPTION :: '||SQLERRM ||
                     'in call to AP_Acctg_Data_Fix_PKG.Print_html_table '||
		     'during printing data from ap_temp_invoices_9071983';
        dbms_output.put_line(l_message||sqlerrm);
		FND_File.Put_Line(fnd_file.output,l_message);
	    
    END;
    END IF;

 /* BEGIN
  Execute Immediate  
      'SELECT COUNT(*) FROM ap_temp_checks_9071983' into l_count_check;
  EXCEPTION
      WHEN OTHERS THEN
        l_message := 'EXCEPTION :: '||SQLERRM ||
                  ' in counting data from ap_temp_checks_9071983';
        FND_File.Put_Line(fnd_file.output,l_message);
	    dbms_output.put_line(l_message||sqlerrm);
  END; 

    IF (l_count_check > 0) THEN 
      AP_Acctg_Data_Fix_PKG.Print('++++Details of Checks present in the system, whose remit to columns were not affected after supplier merge.');   
	   AP_Acctg_Data_Fix_PKG.Print('Solution : Follow note 982802.1');
    BEGIN
	
	  
    	
      AP_Acctg_Data_Fix_PKG.Print_html_table                           
       ('CHECK_ID,CHECK_NUMBER,ORG_ID,VENDOR_ID,VENDOR_SITE_ID,REMIT_TO_SUPPLIER_ID,REMIT_TO_SUPPLIER_SITE_ID,RELATIONSHIP_ID'
        ,'AP_TEMP_CHECKS_9071983'
        ,'WHERE 1=1 GROUP BY CHECK_ID,CHECK_NUMBER,ORG_ID,VENDOR_ID,VENDOR_SITE_ID,REMIT_TO_SUPPLIER_ID,REMIT_TO_SUPPLIER_SITE_ID,RELATIONSHIP_ID'
        ,'ap_sup_merge_remit_cols_sel.sql');    
                                 
    EXCEPTION                                                          
       WHEN OTHERS THEN
        l_message := 'EXCEPTION :: '||SQLERRM ||
                     'in call to AP_Acctg_Data_Fix_PKG.Print_html_table '||
		     'during printing data from ap_temp_checks_9071983';
        dbms_output.put_line(l_message||sqlerrm);
		FND_File.Put_Line(fnd_file.output,l_message);
	    
    END;
    END IF;

  BEGIN
  Execute Immediate  
      'SELECT COUNT(*) FROM ap_temp_recur_inv_9071983' into l_count_rec_pay;
  EXCEPTION
      WHEN OTHERS THEN
        l_message := 'EXCEPTION :: '||SQLERRM ||
                  ' in counting data from ap_temp_recur_inv_9071983';
        FND_File.Put_Line(fnd_file.output,l_message);
	    dbms_output.put_line(l_message||sqlerrm);
  END; 

    IF (l_count_rec_pay > 0) THEN 
      AP_Acctg_Data_Fix_PKG.Print('++++Details of Recurring Payments present in the system, whose remit to columns were not affected after supplier merge.');   
	  AP_Acctg_Data_Fix_PKG.Print('Solution : Follow note 982802.1');
    BEGIN
    	
      AP_Acctg_Data_Fix_PKG.Print_html_table                           
       ('RECURRING_PAYMENT_ID,RECURRING_PAY_NUM,ORG_ID,VENDOR_ID,VENDOR_SITE_ID,REMIT_TO_SUPPLIER_ID,REMIT_TO_SUPPLIER_SITE_ID,RELATIONSHIP_ID'
        ,'AP_TEMP_RECUR_INV_9071983'
        ,NULL
        ,'ap_sup_merge_remit_cols_sel.sql');    
                                 
    EXCEPTION                                                          
       WHEN OTHERS THEN
        l_message := 'EXCEPTION :: '||SQLERRM ||
                     'in call to AP_Acctg_Data_Fix_PKG.Print_html_table '||
		     'during printing data from ap_temp_recur_inv_9071983';
        dbms_output.put_line(l_message||sqlerrm);
		FND_File.Put_Line(fnd_file.output,l_message);
	    
    END;
    END IF;*/

  BEGIN
  Execute Immediate  
      'SELECT COUNT(*) FROM ap_temp_pay_sch_9071983' into l_count_pay_sch;
  EXCEPTION
      WHEN OTHERS THEN
        l_message := 'EXCEPTION :: '||SQLERRM ||
                  ' in counting data from ap_temp_pay_sch_9071983';
        FND_File.Put_Line(fnd_file.output,l_message);
	    dbms_output.put_line(l_message||sqlerrm);
  END; 

    IF (l_count_pay_sch > 0) THEN 
      AP_Acctg_Data_Fix_PKG.Print('++++Details of Payment Schedules present in the system, whose remit to columns were not affected after supplier merge.');   
	  AP_Acctg_Data_Fix_PKG.Print('Solution : Follow note 982802.1');
    BEGIN
    	
      AP_Acctg_Data_Fix_PKG.Print_html_table                           
       ('INVOICE_ID,ORG_ID,REMIT_TO_SUPPLIER_ID,REMIT_TO_SUPPLIER_SITE_ID,RELATIONSHIP_ID'
        ,'AP_TEMP_PAY_SCH_9071983'
        ,'WHERE INVOICE_ID=' || l_invoice_id
        ,'ap_sup_merge_remit_cols_sel.sql');    
                                 
    EXCEPTION                                                          
       WHEN OTHERS THEN
        l_message := 'EXCEPTION :: '||SQLERRM ||
                     'in call to AP_Acctg_Data_Fix_PKG.Print_html_table '||
		     'during printing data from ap_temp_pay_sch_9071983';
        dbms_output.put_line(l_message||sqlerrm);
		FND_File.Put_Line(fnd_file.output,l_message);
	    
    END;
    END IF;
			
    PRINT_LINE;				
 
 ELSIF l_rows > l_row_limit THEN
  AP_Acctg_Data_Fix_PKG.Print( 'More then 100 invoices affected'||
                               'Please follow the note 982075.1 and run this GDF individually'); 
PRINT_LINE;							   
							   
  END IF;
							   

FND_File.Put_Line(fnd_file.output,
                  '  END'||' '||'9071983'||'     '||
                  to_char(sysdate, 'DD-MON-YYYY:HH24:MI:SS'));

EXCEPTION
WHEN OTHERS THEN
  l_message := 'After '||l_message||'';
  AP_Acctg_Data_Fix_PKG.Print(l_message);
  l_message := 'Exception :: '||SQLERRM||'';
  AP_Acctg_Data_Fix_PKG.Print(l_message);
  APP_EXCEPTION.RAISE_EXCEPTION;
 

END;

-----------ap_sup_merge_remit_cols_sel.sql


/*+=======================================================================+
| FILENAME                                                              |
|     ap_bc_on_rectax_dist_sel.sql                                      |
|                                                                       |
| DESCRIPTION                                                           |
|     This script will select the affected recoverable tax distributions|
|     on invoice for which bc_event_id has been stamped while validation|
|     There are no JLTs for recoverable tax distribution and even if the|
|     distributions shows as encumbered, but actually there are no      |
|     journals created for the same. This will be ab issue for          |
|     downstream accounting                                             |
+=======================================================================*/
 
BEGIN

FND_File.Put_Line(fnd_file.output,
                   '---------------------------------------------------------');
FND_File.Put_Line(fnd_file.output,
                  'START'||' '||'8966882'||'     '||
                  to_char(sysdate, 'DD-MON-YYYY:HH24:MI:SS'));

CHECK_COUNT(8966882,l_invoice_id,l_rows);

IF l_rows < l_row_limit and l_rows > 0 THEN 

l_bug_no:= '8966882';

l_driver_tab := 'AP_TEMP_DATA_DRIVER_'||l_bug_no;
  BEGIN
     l_sql_stmt :=
          ' DROP TABLE '||l_driver_tab;
    EXECUTE IMMEDIATE l_sql_stmt;
  EXCEPTION
    WHEN OTHERS THEN
      NULL;
  END;

  --------------------------------------------------------------------------
  -- Step 3: create driver tables
  --------------------------------------------------------------------------

  l_debug_info := 'Before Creating the table '||l_driver_tab;
  l_sql_stmt :=
           ' CREATE TABLE '||l_driver_tab||
           '   AS '||
           'SELECT ai.invoice_id                  INVOICE_ID, '||
           '       ai.invoice_num                 INVOICE_NUM, '||
           '       asu.vendor_name                VENDOR_NAME, '||
           '       assi.vendor_site_code          VENDOR_SITE_CODE, '||
           '       aid.invoice_distribution_id    INVOICE_DISTRIBUTION_ID, '||
           '       aid.invoice_line_number        INVOICE_LINE_NUMBER, '||
           '       aid.distribution_line_number   DISTRIBUTION_LINE_NUMBER, '||
           '       aid.line_type_lookup_code      LINE_TYPE_LOOKUP_CODE, '||
           '       aid.accounting_date            ACCOUNTING_DATE, '||
           '       aid.amount                     AMOUNT, '||
           '       aid.base_amount                BASE_AMOUNT, '||
           '       aid.posted_flag                POSTED_FLAG,'||
           '       aid.bc_event_id                BC_EVENT_ID,'||
           '       aid.encumbered_flag            ENCUMBERED_FLAG,'||
           '       xe.event_status_code           EVENT_STATUS_CODE,'||
           '       xe.process_status_code         PROCESS_STATUS_CODE,'||
	   '       xe.budgetary_control_flag      BUDGETARY_CONTROL_FLAG,'||
	   '       xe.upg_batch_id		  UPG_BATCH_ID,'||
           '       ''Y''                          PROCESS_FLAG '||
           '  FROM ap_invoice_distributions_all aid, '||
           '       ap_invoices_all ai, '||
           '       ap_suppliers asu, '||
           '       ap_supplier_sites_all assi,'||
           '       xla_events xe'||
           ' WHERE ai.invoice_id = aid.invoice_id '||
           '   AND ai.vendor_id = asu.vendor_id(+) '||
           '   AND ai.vendor_site_id = assi.vendor_site_id(+) '||
           '   AND aid.line_type_lookup_code = ''REC_TAX''  '||
           '   AND aid.prepay_distribution_id IS NULL '||
           '   AND xe.application_id = 200'||
           '   AND xe.event_id = aid.bc_event_id'||
           '   AND aid.bc_event_id IS NOT NULL '||
           '   AND nvl(aid.posted_flag, ''N'') <> ''Y'' '||
           '   AND NOT EXISTS '||
           '  (SELECT 1 '||
           '     FROM xla_distribution_links xdl, '||
           '          xla_ae_headers xah '||
           '    WHERE xdl.application_id = 200 '||
           '      AND xah.application_id = 200 '||
           '      AND xdl.ae_header_id = xah.ae_header_id '||
           '      AND xah.event_id = aid.bc_event_id '||
           '	  AND xah.balance_type_code = ''E'''||
           '	  AND xdl.source_distribution_type = ''AP_INV_DIST'''||
           '	  AND xdl.source_distribution_id_num_1 = '||
	   '                   aid.invoice_distribution_id)';

  EXECUTE IMMEDIATE l_sql_stmt;

  BEGIN
  
    EXECUTE IMMEDIATE 
     'SELECT COUNT(*)
        FROM AP_TEMP_DATA_DRIVER_8966882'
        INTO l_count;
  EXCEPTION WHEN OTHERS THEN
    l_message := 'Error encountered in getting the count from '||
                 'AP_TEMP_DATA_DRIVER_8966882';
    AP_ACCTG_DATA_FIX_PKG.Print(l_message);    
  END;
  IF l_count <> 0 THEN

    l_message := ' Following transactions Cannot '||
                 ' Account For Invoices Due to BC_EVENT_ID Stamped On '||
                 ' Recoverable Tax Distributions the Data Fix ';
    AP_ACCTG_DATA_FIX_PKG.Print(l_message);
    l_message :=  'Solution: Follow the note 982795.1';
    AP_ACCTG_DATA_FIX_PKG.Print(l_message);

    l_debug_info := 'Constructing the select columns ';
    l_select_list :=
        'INVOICE_ID,'||
        'INVOICE_NUM,'||
        'VENDOR_NAME,'||
        'VENDOR_SITE_CODE,'||
        'INVOICE_DISTRIBUTION_ID,'||
        'INVOICE_LINE_NUMBER,'||
        'DISTRIBUTION_LINE_NUMBER,'||
        'LINE_TYPE_LOOKUP_CODE,'||
        'ACCOUNTING_DATE,'||
        'AMOUNT,'||
        'BASE_AMOUNT,'||
	'ENCUMBERED_FLAG,'||
        'BC_EVENT_ID,'||
        'POSTED_FLAG';

    l_debug_info := 'Getting the table name ';
    l_table_name := l_driver_tab;

    l_debug_info := 'Constructing the where clause ';
    l_where_clause := 'WHERE INVOICE_ID='||l_invoice_id||' ORDER BY INVOICE_ID,'||
                      'INVOICE_NUM,'||
                      'VENDOR_NAME,'||
                      'VENDOR_SITE_CODE,'||
                      'INVOICE_DISTRIBUTION_ID,'||
                      'INVOICE_LINE_NUMBER,'||
                      'DISTRIBUTION_LINE_NUMBER,'||
                      'LINE_TYPE_LOOKUP_CODE,'||
                      'ACCOUNTING_DATE,'||
                      'AMOUNT,'||
                      'BASE_AMOUNT,'||
	                  'ENCUMBERED_FLAG,'||
                      'BC_EVENT_ID,'||
                      'POSTED_FLAG '||
	                  'ORDER BY VENDOR_NAME,'||
                      '         VENDOR_SITE_CODE,'||
                      '         INVOICE_ID,'||
                      '         INVOICE_LINE_NUMBER,'||
                      '         DISTRIBUTION_LINE_NUMBER';

    l_debug_info := 'Before calling the Print HTML';
    AP_ACCTG_DATA_FIX_PKG.Print_html_table
      (p_select_list       => l_select_list,
       p_table_in          => l_table_name,
       p_where_in          => l_where_clause,
       P_calling_sequence  => l_calling_sequence);

   
  END IF;
  		
   PRINT_LINE;				
  ELSIF l_rows > l_row_limit THEN
  AP_Acctg_Data_Fix_PKG.Print( 'More then 100 invoices affected'||
                               'Please follow the note 982795.1 and run this GDF individually');
PRINT_LINE;
							   
  END IF;


FND_File.Put_Line(fnd_file.output,
                  '  END'||' '||'8966882'||'     '||
                  to_char(sysdate, 'DD-MON-YYYY:HH24:MI:SS'));


EXCEPTION
WHEN OTHERS THEN
  l_message := 'After '||l_message||'';
  AP_Acctg_Data_Fix_PKG.Print(l_message);
  l_message := 'Exception :: '||SQLERRM||'';
  AP_Acctg_Data_Fix_PKG.Print(l_message);
  APP_EXCEPTION.RAISE_EXCEPTION;
  

END;

---ap_bc_on_rectax_dist_sel.sql

/*+=======================================================================+
| FILENAME     ap_psa_cleanup_s.sql                                                         |
|                                                                       |
| DESCRIPTION                                                           |
|   GDF for BC event and encumbered flag cleanup                        |
+=======================================================================+*/

BEGIN


FND_File.Put_Line(fnd_file.output,
                   '---------------------------------------------------------');
FND_File.Put_Line(fnd_file.output,
                  'START'||' '||'8968844'||'     '||
                  to_char(sysdate, 'DD-MON-YYYY:HH24:MI:SS'));

CHECK_COUNT(8968844,l_invoice_id,l_rows);

IF l_rows < l_row_limit and l_rows > 0 THEN

l_bug_no :=8968844;
 BEGIN
     l_sql_stmt :=
          ' DROP TABLE UNENC_REV_PAIRS_'||l_bug_no;
    EXECUTE IMMEDIATE l_sql_stmt;
  EXCEPTION
    WHEN OTHERS THEN
      null;
  END;

  l_sql_stmt :=
       ' CREATE TABLE UNENC_REV_PAIRS_'||l_bug_no||' AS '||
       ' SELECT aid.invoice_id                  INVOICE_ID, '||
       '        aid.invoice_line_number         LINE_NUMBER,  '||
       '        aid.invoice_distribution_id     PARENT_INV_DIST_ID, '||
       '        aid.distribution_line_number    PARENT_DIST_LINE_NUM, '||
       '        aid.line_type_lookup_code       PARENT_LINE_TYPE, '||
       '        aid.amount                      PARENT_AMOUNT, '||
       '        aid.base_amount                 PARENT_BASE_AMOUNT, '||
       '        aid.bc_event_id                 PARENT_BC_EVENT_ID, '||
       '        xe.event_status_code            PARENT_EVENT_STATUS, '||
       '        aid.encumbered_flag             PARENT_ENCUMBERED_FLAG, '||
       '        aid.posted_flag                 PARENT_POSTED_FLAG, '||
       '        aidr.invoice_distribution_id    REVERSAL_INV_DIST_ID, '||
       '        aidr.distribution_line_number   REVERSAL_DIST_LINE_NUM, '||
       '        aidr.line_type_lookup_code      REVERSAL_LINE_TYPE, '||
       '        aidr.amount                     REVERSAL_AMOUNT, '||
       '        aidr.base_amount                REVERSAL_BASE_AMOUNT,  '||
       '        aidr.bc_event_id                REVERSAL_BC_EVENT_ID, '||
       '        xer.event_status_code           REVERSAL_EVENT_STATUS, '||
       '        aidr.encumbered_flag            REVERSAL_ENCUMBERED_FLAG, '||
       '        aidr.posted_flag                REVERSAL_POSTED_FLAG, '||
       '        ''Y''                           PROCESS_FLAG '||
       '   FROM ap_invoice_distributions_all aid, '||
       '        ap_invoice_distributions_all aidr, '||
       '        financials_system_params_all fsp, '||
       '        xla_events xe, '||
       '        xla_events xer '||
       '  WHERE aid.bc_event_id = xe.event_id(+) '||
       '    AND aidr.bc_event_id = xer.event_id(+) '||
       '    AND xe.application_id(+) = 200 '||
       '    AND xer.application_id(+) = 200 '||
       '    AND xe.budgetary_control_flag(+) = ''Y'' '||
       '    AND xer.budgetary_control_flag(+) = ''Y'' '||
       '    AND aid.invoice_distribution_id = aidr.parent_reversal_id '||
       '    AND nvl(aid.historical_flag, ''N'') <> ''Y'' '||
       '    AND nvl(aidr.historical_flag, ''N'') <> ''Y'' '||
       '    AND nvl(aid.reversal_flag,   ''N'') = ''Y'' '||
       '    AND nvl(aidr.reversal_flag,   ''N'') = ''Y'' '||
       '    AND aid.invoice_id = aidr.invoice_id '||
       '    AND aid.org_id = fsp.org_id '||
       '    AND fsp.purch_encumbrance_flag = ''Y'' '||
       '    AND aid.invoice_line_number = aidr.invoice_line_number '||
       '    AND (nvl(xe.event_id,  -99) =  -99 OR xe.event_status_code   <> ''P'') '||
       '    AND (nvl(xer.event_id, -99) =  -99 OR xer.event_status_code  <> ''P'') '||
       '    AND (nvl(xe.event_id,  -99) <> -99 OR nvl(xer.event_id, -99) <> -99) ';

  l_debug_info := 'Creating the Driver table containing the selected '||
                  'transactions - reversals';
  --AP_ACCTG_DATA_FIX_PKG.Print(l_sql_stmt);
  EXECUTE IMMEDIATE l_sql_stmt;


  -- Table to hold all the Invoice distributions which have an encumbered flag of
  -- Y but the BC event has not been processed
  --
  BEGIN
     l_sql_stmt :=
          ' DROP TABLE UNENC_APRVD_DISTS_'||l_bug_no;
    EXECUTE IMMEDIATE l_sql_stmt;
  EXCEPTION
    WHEN OTHERS THEN
      null;
  END;

  l_sql_stmt :=
       ' CREATE TABLE UNENC_APRVD_DISTS_'||l_bug_no||' AS '||
       ' SELECT aid.invoice_id, '||
       '        aid.invoice_distribution_id, '||
       '        aid.invoice_line_number, '||
       '        aid.distribution_line_number, '||
       '        aid.line_type_lookup_code, '||
       '        aid.amount, '||
       '        aid.base_amount, '||
       '        aid.match_status_flag, '||
       '        aid.bc_event_id, '||
       '        xe.event_status_code, '||
       '        xe.process_status_code, '||
       '        aid.encumbered_flag, '||
       '        aid.accounting_event_id, '||
       '        aid.posted_flag, '||
       '        aid.po_distribution_id, '||
       '        aid.org_id, '||
       '        ''Y'' PROCESS_FLAG '||
       '   FROM ap_invoice_distributions_all aid, '||
       '        xla_events xe, '||
       '        financials_system_params_all fsp  '||
       '  WHERE nvl(aid.historical_flag,   ''N'') = ''N'' '||
       '    AND nvl(aid.posted_flag, ''N'') <> ''Y'' '||
       '    AND aid.po_distribution_id IS NULL '||
       '    AND aid.org_id = fsp.org_id '||
       '    AND nvl(fsp.purch_encumbrance_flag,   ''N'') = ''Y'' '||
       '    AND aid.encumbered_flag = ''Y'' '||
       '    AND aid.match_status_flag = ''A'' '||
       '    AND aid.bc_event_id = xe.event_id(+) '||
       '    AND xe.application_id(+) = 200 '||
       '    AND (nvl(xe.event_id, -99) = -99 OR  '||
       '         (nvl(xe.event_id, -99) <> -99 AND '||
       '          xe.event_status_code <> ''P'')) '||
       '    AND nvl(aid.reversal_flag,   ''N'') <> ''Y'' ';


  
  --AP_ACCTG_DATA_FIX_PKG.Print(l_sql_stmt);
  EXECUTE IMMEDIATE l_sql_stmt;



  
  l_message := 'Following are the Reversal Pairs of the Invoice Distributions '||
               ' which can be marked as '||''''||'R'||''''||' ';
	      
  AP_ACCTG_DATA_FIX_PKG.Print(l_message);
  
  l_message := 'SOLUTION : Follow the Note 985228.1';
  AP_ACCTG_DATA_FIX_PKG.Print(l_message);

  l_select_list :=
       'INVOICE_ID,'||
       'LINE_NUMBER,'||
       'PARENT_INV_DIST_ID,'||
       'PARENT_DIST_LINE_NUM,'||
       'PARENT_LINE_TYPE,'||
       'PARENT_AMOUNT,'||
       'PARENT_BASE_AMOUNT,'||
       'PARENT_BC_EVENT_ID,'||
       'PARENT_EVENT_STATUS,'||
       'PARENT_ENCUMBERED_FLAG,'||
       'PARENT_POSTED_FLAG,'||
       'REVERSAL_INV_DIST_ID,'||
       'REVERSAL_DIST_LINE_NUM,'||
       'REVERSAL_LINE_TYPE,'||
       'REVERSAL_AMOUNT,'||
       'REVERSAL_BASE_AMOUNT,'||
       'REVERSAL_BC_EVENT_ID,'||
       'REVERSAL_EVENT_STATUS,'||
       'REVERSAL_ENCUMBERED_FLAG,'||
       'REVERSAL_POSTED_FLAG';


  l_table_name :=
         'UNENC_REV_PAIRS_'||l_bug_no;

  
  l_where_clause :='WHERE invoice_id='||l_invoice_id||' ORDER BY INVOICE_ID,'||
       'LINE_NUMBER,'||
       'PARENT_INV_DIST_ID,'||
       'PARENT_DIST_LINE_NUM,'||
       'PARENT_LINE_TYPE,'||
       'PARENT_AMOUNT,'||
       'PARENT_BASE_AMOUNT,'||
       'PARENT_BC_EVENT_ID,'||
       'PARENT_EVENT_STATUS,'||
       'PARENT_ENCUMBERED_FLAG,'||
       'PARENT_POSTED_FLAG,'||
       'REVERSAL_INV_DIST_ID,'||
       'REVERSAL_DIST_LINE_NUM,'||
       'REVERSAL_LINE_TYPE,'||
       'REVERSAL_AMOUNT,'||
       'REVERSAL_BASE_AMOUNT,'||
       'REVERSAL_BC_EVENT_ID,'||
       'REVERSAL_EVENT_STATUS,'||
       'REVERSAL_ENCUMBERED_FLAG,'||
       'REVERSAL_POSTED_FLAG '||
        'ORDER BY '||
              'INVOICE_ID,'||
              'LINE_NUMBER,'||
              'PARENT_DIST_LINE_NUM,'||
              'REVERSAL_DIST_LINE_NUM';


  
  AP_ACCTG_DATA_FIX_PKG.Print_html_table
    (p_select_list       => l_select_list,
     p_table_in          => l_table_name,
     p_where_in          => l_where_clause,
     P_calling_sequence  => l_calling_sequence);


  
  l_message := 'Following are the Unposted Invoice Distributions '||
               'because they are incorrectly marked as Encumbered ';
  AP_ACCTG_DATA_FIX_PKG.Print(l_message);
  
  l_message := 'SOLUTION :Follow the note 985228.1';
               AP_ACCTG_DATA_FIX_PKG.Print(l_message);

  
  l_select_list :=
         'INVOICE_ID,'||
         'INVOICE_DISTRIBUTION_ID,'||
         'INVOICE_LINE_NUMBER,'||
         'DISTRIBUTION_LINE_NUMBER,'||
         'LINE_TYPE_LOOKUP_CODE,'||
         'AMOUNT,'||
         'BASE_AMOUNT,'||
         'MATCH_STATUS_FLAG,'||
         'BC_EVENT_ID,'||
         'EVENT_STATUS_CODE,'||
         'PROCESS_STATUS_CODE,'||
         'ENCUMBERED_FLAG,'||
         'ACCOUNTING_EVENT_ID,'||
         'POSTED_FLAG,'||
         'PO_DISTRIBUTION_ID,'||
         'ORG_ID';

  
  l_table_name :=
         'UNENC_APRVD_DISTS_'||l_bug_no;

  
  l_where_clause :='WHERE invoice_id='||l_invoice_id ||' ORDER BY INVOICE_ID,'||
         'INVOICE_DISTRIBUTION_ID,'||
         'INVOICE_LINE_NUMBER,'||
         'DISTRIBUTION_LINE_NUMBER,'||
         'LINE_TYPE_LOOKUP_CODE,'||
         'AMOUNT,'||
         'BASE_AMOUNT,'||
         'MATCH_STATUS_FLAG,'||
         'BC_EVENT_ID,'||
         'EVENT_STATUS_CODE,'||
         'PROCESS_STATUS_CODE,'||
         'ENCUMBERED_FLAG,'||
         'ACCOUNTING_EVENT_ID,'||
         'POSTED_FLAG,'||
         'PO_DISTRIBUTION_ID,'||
         'ORG_ID ' ||
        'ORDER BY '||
              'INVOICE_ID,'||
              'INVOICE_LINE_NUMBER,'||
              'DISTRIBUTION_LINE_NUMBER';

  l_debug_info := 'Before calling the Print HTML';
  AP_ACCTG_DATA_FIX_PKG.Print_html_table
    (p_select_list       => l_select_list,
     p_table_in          => l_table_name,
     p_where_in          => l_where_clause,
     P_calling_sequence  => l_calling_sequence);
	 
		
   PRINT_LINE;				
  ELSIF l_rows > l_row_limit THEN
  AP_Acctg_Data_Fix_PKG.Print( 'More then 100 invoices affected'||
                               'Please follow the note 985228.1 and run this GDF individually');
PRINT_LINE;
							   
  END IF;	 

 
FND_File.Put_Line(fnd_file.output,
                  '  END'||' '||'8968844'||'     '||
                  to_char(sysdate, 'DD-MON-YYYY:HH24:MI:SS'));


EXCEPTION
WHEN OTHERS THEN
  l_message := 'After '||l_message||'';
  AP_Acctg_Data_Fix_PKG.Print(l_message);
  l_message := 'Exception :: '||SQLERRM||'';
  AP_Acctg_Data_Fix_PKG.Print(l_message);
  APP_EXCEPTION.RAISE_EXCEPTION;
  
END;



--ap_psa_cleanup_s.sql


/*+=======================================================================+
| FILENAME                                                              |
|     AP_AWT_RELATED_ID_SEL.sql                                         |
|                                                                       |
| DESCRIPTION                                                           |
|     This datafix will populate the awt related id                     |
|     for upgraded AWT distributions, only if the automatic offsets     |
|     flag is 'N'.                                                      |
+=======================================================================+*/

BEGIN


FND_File.Put_Line(fnd_file.output,
                   '---------------------------------------------------------');
FND_File.Put_Line(fnd_file.output,
                  'START'||' '||'9358397'||'     '||
                  to_char(sysdate, 'DD-MON-YYYY:HH24:MI:SS'));

CHECK_COUNT(9358397,l_invoice_id,l_rows);

IF l_rows < l_row_limit and l_rows > 0 THEN

BEGIN
    EXECUTE Immediate 'DROP TABLE ap_temp_data_driver_9079541';

  l_debug_info := 'DROP TABLE ap_temp_data_driver_9079541';
  FND_File.Put_Line(fnd_file.output,l_debug_info);
	
  EXCEPTION
  WHEN OTHERS THEN 
  NULL;
  END;  

  --------------------------------------------------------------------------
  -- Step 2: Create the data driver table 
  --------------------------------------------------------------------------  
  BEGIN
    EXECUTE Immediate 'CREATE TABLE ap_temp_data_driver_9079541
                       (
                        INVOICE_ID               NUMBER(15),
						INVOICE_DISTRIBUTION_ID  NUMBER,
                        INVOICE_LINE_NUMBER      NUMBER,
                        DISTRIBUTION_LINE_NUMBER NUMBER,
						ORG_ID                   NUMBER,
                        PROCESS_FLAG             VARCHAR2(1) DEFAULT ''Y''
                       )';
 					   
  EXCEPTION
  WHEN OTHERS THEN
    l_debug_info := 'Driver table ap_temp_data_driver_9079541 could not be created.' ||sqlerrm;
    FND_File.Put_Line(fnd_file.output,l_debug_info);
  END;
  
  --------------------------------------------------------------------------
  -- Step 3: Populate the data driver table with affected transactions
  --------------------------------------------------------------------------
 
  BEGIN
    EXECUTE Immediate
    'Insert into ap_temp_data_driver_9079541
      (        
        INVOICE_ID,
		INVOICE_DISTRIBUTION_ID,
        INVOICE_LINE_NUMBER,
        DISTRIBUTION_LINE_NUMBER,
        ORG_ID,
		PROCESS_FLAG
      )        
      (
        select aid.invoice_id,
               aid.invoice_distribution_id,
               aid.invoice_line_number,
               aid.distribution_line_number,
               aid.org_id,
               ''Y''			   
          from ap_invoice_distributions_all aid,
               ap_system_parameters_all asp		  
         where aid.line_type_lookup_code = ''AWT'' 
           and aid.posted_flag = ''N'' 
           and aid.awt_related_id is NULL
		   and aid.historical_flag = ''Y''
		   and aid.org_id = asp.org_id
		   and nvl(asp.automatic_offsets_flag,''N'') <> ''Y'')';
		   
 
  EXCEPTION
  WHEN OTHERS THEN
    l_debug_info := 'Exception in inserting records into '||
                    'ap_temp_data_driver_9079541'||SQLERRM;
    FND_File.Put_Line(fnd_file.output,l_debug_info);
    
  END;
 
  --------------------------------------------------------------------------
  -- Step 4: Report all the affected transactions in Log file
  --------------------------------------------------------------------------
  
  l_message := 'As per note 1061563.1';
  AP_Acctg_Data_Fix_PKG.Print(l_message);
  l_message := 'The following invoices cannot be fixed as AUTOMATIC_OFFSETS flag is enabled for that ORG: ';
  AP_Acctg_Data_Fix_PKG.Print(l_message);
  l_message := 'Invoice_id          Org_id ';
  AP_Acctg_Data_Fix_PKG.Print(l_message);
  l_message := '----------          ------ ';
  AP_Acctg_Data_Fix_PKG.Print(l_message);

  
  FOR i IN (SELECT distinct aid.org_id,aid.invoice_id  
              FROM ap_invoice_distributions_all aid,
                   ap_system_parameters_all asp		  
             WHERE aid.line_type_lookup_code = 'AWT' 
               AND aid.posted_flag = 'N' 
               AND aid.awt_related_id is NULL
		       AND aid.historical_flag = 'Y'
		       AND aid.org_id = asp.org_id
			   AND aid.invoice_id=l_invoice_id
		       AND nvl(asp.automatic_offsets_flag,'N') = 'Y')
    LOOP
	  l_invoice_id1:= i.invoice_id;
	  l_org_id := i.org_id;
      l_message := rpad(l_invoice_id1,30)||l_org_id;
      AP_Acctg_Data_Fix_PKG.Print(l_message);

	END LOOP;	
	

  BEGIN
    EXECUTE Immediate  
     'SELECT count(*) FROM ap_temp_data_driver_9079541' INTO l_count;
  EXCEPTION
  WHEN OTHERS THEN
    l_debug_info := 'Exception in selecting count from '||
                    'ap_temp_data_driver_9079541 '||SQLERRM;
    FND_File.Put_Line(fnd_file.output,l_debug_info); 
  END;
  
  --Check if any affected transactions exist
  IF (l_count > 0) THEN
    AP_Acctg_Data_Fix_PKG.Print('******* Summary of invoices selected for Correction'||
	                            'Cannot Account For Upgraded AWT Distribution Due to Missing '||
                                ' *******');
    BEGIN
      AP_Acctg_Data_Fix_PKG.Print_html_table ('INVOICE_ID,INVOICE_DISTRIBUTION_ID,INVOICE_LINE_NUMBER,DISTRIBUTION_LINE_NUMBER,'
                  ||'ORG_ID,PROCESS_FLAG',
                  'ap_temp_data_driver_9079541',
                  'WHERE invoice_id='||l_invoice_id ||
				  ' GROUP BY INVOICE_ID,INVOICE_DISTRIBUTION_ID,INVOICE_LINE_NUMBER,DISTRIBUTION_LINE_NUMBER,ORG_ID,PROCESS_FLAG',
                  'AP_AWT_RELATED_ID_SEL.sql ');
    EXCEPTION
    WHEN OTHERS THEN
      l_debug_info := 'Exception in Call to ' || 
                           'AP_Acctg_Data_Fix_PKG.Print_html_table '||SQLERRM;
      FND_File.Put_Line(fnd_file.output,l_debug_info); 
    END;
    ---------------------------------------------------------------------
    -- Step 4.1: User need to follow the next steps to fix the issue
    ---------------------------------------------------------------------
    l_message := 'SOLUTION: Follow note 1061563.1';
    AP_Acctg_Data_Fix_PKG.Print(l_message); 
    
  END IF;
  
  		
   PRINT_LINE;				
  ELSIF l_rows > l_row_limit THEN
  AP_Acctg_Data_Fix_PKG.Print( 'More then 100 invoices affected'||
                               'Please follow the note 1061563.1 and run this GDF individually');
PRINT_LINE;
							   
  END IF;	 
  
FND_File.Put_Line(fnd_file.output,
                  '  END'||' '||'9358397'||'     '||
                  to_char(sysdate, 'DD-MON-YYYY:HH24:MI:SS'));
  

EXCEPTION
WHEN OTHERS THEN
  l_message := 'After '||l_message||'';
  AP_Acctg_Data_Fix_PKG.Print(l_message);
  l_message := 'Exception :: '||SQLERRM||'';
  AP_Acctg_Data_Fix_PKG.Print(l_message);
  APP_EXCEPTION.RAISE_EXCEPTION;

END;

--AP_AWT_RELATED_ID_SEL.sql   


/*+=======================================================================+
| FILENAME                                                              |
|               ap_orphan_dists_s.sql                                                         |
| DESCRIPTION                                                           |
|   GDF for Orphan invoice distributions                                |
| HISTORY                                                               |
+=======================================================================+*/

BEGIN

CHECK_COUNT(8970059,l_invoice_id,l_rows);


FND_File.Put_Line(fnd_file.output,
                   '---------------------------------------------------------');
FND_File.Put_Line(fnd_file.output,
                  'START'||' '||'9358397'||'     '||
                  to_char(sysdate, 'DD-MON-YYYY:HH24:MI:SS'));

CHECK_COUNT(8970059,l_invoice_id,l_rows);

IF l_rows < l_row_limit and l_rows > 0 THEN

l_bug_no:=8970059;

l_debug_info := 'Creating the driver table for the Invoice distributions ';
  l_driver_tab := 'AP_TEMP_DATA_DRIVER_'||l_bug_no;
  BEGIN
     l_sql_stmt :=
          ' DROP TABLE '||l_driver_tab;
    EXECUTE IMMEDIATE l_sql_stmt;
  EXCEPTION
    WHEN OTHERS THEN
      null;
  END;

  l_sql_stmt :=
       ' CREATE TABLE '||l_driver_tab||' AS '||
       ' SELECT DISTINCT ai.invoice_id, '||
       '        ai.invoice_num, '||
       '        ai.invoice_type_lookup_code, '||
       '        ai.invoice_date, '||
       '        asu.vendor_name, '||
       '        assi.vendor_site_code, '||
       '        aid.invoice_line_number, '||
       '        aid.distribution_line_number, '||
       '        aid.line_type_lookup_code, '||
       '        aid.invoice_distribution_id, '||
       '        aid.amount, '||
       '        aid.base_amount, '||
       '        aid.accounting_event_id, '||
       '        aid.posted_flag, '||
       '        aid.detail_tax_dist_id, '||
       '        aid.org_id, '||
       '        aid.set_of_books_id, '||
       '        ''Y'' process_flag '||
       '   FROM ap_invoice_distributions_all aid, '||
       '        ap_invoices_all ai, '||
       '        ap_suppliers asu, '||
       '        ap_supplier_sites_all assi '||
       '  WHERE nvl(aid.historical_flag, ''N'') = ''N'' '||
       '    AND aid.invoice_id = ai.invoice_id '||
       '    AND ai.vendor_id = asu.vendor_id(+) '||
       '    AND ai.vendor_site_id = assi.vendor_site_id(+) '||
       '    AND ((NOT EXISTS '||
       '            (SELECT 1 '||
       '               FROM ap_invoice_lines_all l '||
       '              WHERE l.invoice_id = aid.invoice_id '||
       '                AND l.line_number = aid.invoice_line_number) '||
       '          ) OR  '||
       '         aid.parent_reversal_id IN '||
       '          (SELECT p.invoice_distribution_id '||
       '             FROM ap_invoice_distributions_all p '||
       '             WHERE NOT EXISTS '||
       '                  (SELECT 1 '||
       '                     FROM ap_invoice_lines_all l '||
       '                    WHERE l.invoice_id = p.invoice_id '||
       '                      AND l.line_number = p.invoice_line_number) '||
       '           ) '||
       '        ) ';

  l_debug_info := 'Creating the Driver table containing the selected '||
                  'transactions ';
  EXECUTE IMMEDIATE l_sql_stmt;
  
  l_sql_stmt:='DELETE FROM '||l_driver_tab||' WHERE INVOICE_ID <> '||l_invoice_id;
  EXECUTE IMMEDIATE l_sql_stmt;
  
  ------------------------------------------------------------------

  l_debug_info := 'Creating the driver table for the Invoice Distributions present '||
                  ' in XLA';
  BEGIN
     l_sql_stmt :=
          ' DROP TABLE AP_DISTS_TO_UNDO_'||l_bug_no;
    EXECUTE IMMEDIATE l_sql_stmt;
  EXCEPTION
    WHEN OTHERS THEN
      null;
  END;

  l_sql_stmt :=
       ' CREATE TABLE AP_DISTS_TO_UNDO_'||l_bug_no||' AS '||
       ' SELECT DISTINCT ai.invoice_id, '||
       '        ai.invoice_num, '||
       '        ai.invoice_type_lookup_code, '||
       '        ai.invoice_date, '||
       '        asu.vendor_name, '||
       '        assi.vendor_site_code, '||
       '        aid.invoice_line_number, '||
       '        aid.distribution_line_number, '||
       '        aid.line_type_lookup_code, '||
       '        aid.invoice_distribution_id, '||
       '        aid.amount, '||
       '        aid.base_amount, '||
       '        aid.accounting_event_id, '||
       '        aid.posted_flag, '||
       '        aid.detail_tax_dist_id, '||
       '        aid.org_id, '||
       '        aid.set_of_books_id, '||
       '        ''Y'' process_flag '||
       '   FROM ap_invoice_distributions_all aid, '||
       '        ap_invoices_all ai, '||
       '        ap_suppliers asu, '||
       '        ap_supplier_sites_all assi '||
       '  WHERE nvl(aid.historical_flag, ''N'') = ''N'' '||
       '    AND aid.invoice_id = ai.invoice_id '||
       '    AND ai.vendor_id = asu.vendor_id(+) '||
       '    AND ai.vendor_site_id = assi.vendor_site_id(+) '||
       '    AND aid.invoice_distribution_id IN '||
       '         (SELECT invoice_distribution_id '||
       '            FROM '||l_driver_tab||' ) '||
       '    AND EXISTS '||
       '        (SELECT 1 '||
       '           FROM xla_distribution_links xdl, '||
       '                xla_ae_headers xah '||
       '          WHERE xdl.application_id = 200 '||
       '           AND xah.application_id = 200 '||
       '           AND xdl.ae_header_id = xah.ae_header_id '||
       '           AND xah.event_id = aid.accounting_event_id '||
       '           AND xah.accounting_entry_status_code = ''F'' '||
       '           AND xdl.source_distribution_type = ''AP_INV_DIST'' '||
       '           AND xdl.source_distribution_id_num_1 = aid.invoice_distribution_id) ';

  l_debug_info := 'Creating the Driver table containing the selected '||
                  'transactions ';
  EXECUTE IMMEDIATE l_sql_stmt;
  ------------------------------------------------------------------

  l_debug_info := 'Creating the driver table for the Invoice events which '||
                  ' need to be Un-Accounted';
  BEGIN
     l_sql_stmt :=
          ' DROP TABLE inv_evnts_'||l_bug_no;
    EXECUTE IMMEDIATE l_sql_stmt;
  EXCEPTION
    WHEN OTHERS THEN
      null;
  END;

  l_sql_stmt :=
       ' CREATE TABLE inv_evnts_'||l_bug_no||' AS '||
       ' SELECT xe.event_id, '||
       '        xe.event_type_code, '||
       '        xe.event_status_code, '||
       '        xe.process_status_code, '||
       '        xah.ae_header_id, '||
       '        xah.gl_transfer_status_code, '||
       '        DECODE(xah.balance_type_code, '||
       '               ''A'', ''Actual'', '||
       '               ''E'', ''Encumbrance'') balance_type, '||
       '        xe.event_date, '||
       '        xte.source_id_int_1 invoice_id, '||
       '        xte.security_id_int_1 org_id, '||
       '        xte.ledger_id ledger_id, '||
       '        xte.transaction_number, '||
       '        decode(xte.entity_code,  '||
       '               ''AP_INVOICES'', ''Invoices'', '||
       '               ''Payments'')  transaction_type, '||
       '        ''Y'' process_flag '||
       '   FROM xla_events xe, '||
       '        xla_transaction_entities_upg xte, '||
       '        xla_ae_headers xah '||
       '  WHERE xe.application_id = 200 '||
       '    AND xte.application_id = 200 '||
       '    AND xah.application_id = 200 '||
       '    AND xe.entity_id = xte.entity_id '||
       '    AND xe.event_id = xah.event_id '||
       '    AND xte.entity_code = ''AP_INVOICES'' '||
       '    AND xe.event_status_code = ''P'' '||
       '    AND xe.event_id IN '||
       '        (SELECT dr.accounting_event_id '||
       '           FROM AP_DISTS_TO_UNDO_'||l_bug_no||' dr ) ';

  EXECUTE IMMEDIATE l_sql_stmt;
  ------------------------------------------------------------------

  
  BEGIN
     l_sql_stmt :=
          ' DROP TABLE inv_jrnls_'||l_bug_no;
    EXECUTE IMMEDIATE l_sql_stmt;
  EXCEPTION
    WHEN OTHERS THEN
      null;
  END;

  l_sql_stmt :=
       ' CREATE TABLE inv_jrnls_'||l_bug_no||' AS '||
       ' SELECT xe.event_id, '||
       '        xah.ae_header_id, '||
       '        xah.accounting_date,  '||
       '        xah.gl_transfer_status_code,  '||
       '        DECODE(xah.balance_type_code, '||
       '               ''A'', ''Actual'', '||
       '               ''E'', ''Encumbrance'') balance_type, '||
       '        xal.accounting_class_code,  '||
       '        gcc.padded_concatenated_segments account, '||
       '        xal.entered_dr,  '||
       '        xal.entered_cr,  '||
       '        xal.accounted_dr, '||
       '        xal.accounted_cr, '||
       '        xah.ledger_id, '||
       '        ''Y'' process_flag '||
       ' FROM xla_ae_lines xal, '||
       '      xla_ae_headers xah, '||
       '      xla_events xe, '||
       '      gl_code_combinations_kfv gcc '||
       ' WHERE xal.application_id = 200 '||
       ' AND xah.application_id = 200 '||
       ' AND xe.application_id = 200 '||
       ' AND xal.ae_header_id = xah.ae_header_id '||
       ' AND xal.code_combination_id = gcc.code_combination_id '||
       ' AND xah.event_id = xe.event_id '||
       ' AND xe.event_status_code = ''P'' '||
       ' AND xe.event_id IN '||
       '     (SELECT dr.accounting_event_id '||
       '        FROM AP_DISTS_TO_UNDO_'||l_bug_no||' dr ) ';


  EXECUTE IMMEDIATE l_sql_stmt;
  ------------------------------------------------------------------

  
  BEGIN
     l_sql_stmt :=
          ' DROP TABLE chks_temp_data_driver_'||l_bug_no;
    EXECUTE IMMEDIATE l_sql_stmt;
  EXCEPTION
    WHEN OTHERS THEN
      null;
  END;

  l_sql_stmt :=
       ' CREATE TABLE chks_temp_data_driver_'||l_bug_no||' AS '||
       ' SELECT ac.check_id,  '||
       '        ac.check_number, '||
       '        asu.vendor_name, '||
       '        assi.vendor_site_code, '||
       '        ac.check_date, '||
       '        ac.amount, '||
       '        ac.org_id, '||
       '        ''Y'' process_flag '||
       '   FROM ap_checks_all ac, '||
       '        ap_suppliers asu, '||
       '        ap_supplier_sites_all assi '||
       '  WHERE ac.vendor_id = asu.vendor_id(+) '||
       '    AND ac.vendor_site_id = assi.vendor_site_id(+) '||
       '    AND EXISTS '||
       '        (SELECT 1 '||
       '           FROM ap_invoice_payments_all aip, '||
       '                AP_DISTS_TO_UNDO_'||l_bug_no||' dr '||
       '          WHERE aip.invoice_id = dr.invoice_id '||
       '            AND aip.check_id = ac.check_id '||
       ' ) '; 
  
  EXECUTE IMMEDIATE l_sql_stmt;
  ------------------------------------------------------------------


  BEGIN
     l_sql_stmt :=
          ' DROP TABLE chk_evnts_'||l_bug_no;
    EXECUTE IMMEDIATE l_sql_stmt;
  EXCEPTION
    WHEN OTHERS THEN
      null;
  END;

  l_sql_stmt :=
       ' CREATE TABLE chk_evnts_'||l_bug_no||' AS '||
       ' SELECT xe.event_id, '||
       '        xe.event_type_code, '||
       '        xe.event_status_code, '||
       '        xe.process_status_code, '||
       '        xah.ae_header_id, '||
       '        xah.gl_transfer_status_code, '||
       '        DECODE(xah.balance_type_code, '||
       '               ''A'', ''Actual'', '||
       '               ''E'', ''Encumbrance'') balance_type, '||
       '        xe.event_date, '||
       '        xte.source_id_int_1 check_id, '||
       '        xte.security_id_int_1 org_id, '||
       '        xte.ledger_id ledger_id, '||
       '        xte.transaction_number, '||
       '        decode(xte.entity_code,  '||
       '               ''AP_INVOICES'', ''Invoices'', '||
       '               ''Payments'')  transaction_type, '||
       '        ''Y'' process_flag '||
       '   FROM xla_events xe, '||
       '        xla_transaction_entities_upg xte, '||
       '        xla_ae_headers xah '||
       '  WHERE xe.application_id = 200 '||
       '    AND xte.application_id = 200 '||
       '    AND xah.application_id = 200 '||
       '    AND xe.entity_id = xte.entity_id '||
       '    AND xe.event_id = xah.event_id '||
       '    AND xte.entity_code = ''AP_PAYMENTS'' '||
       '    AND xe.event_status_code = ''P'' '||
       '    AND xe.event_id IN '||
       '        (SELECT aph.accounting_event_id '||
       '           FROM ap_payment_history_all aph, '||
       '                chks_temp_data_driver_'||l_bug_no||' ac '||
       '          WHERE aph.check_id = ac.check_id ) ';

  EXECUTE IMMEDIATE l_sql_stmt;
  ------------------------------------------------------------------

  
  BEGIN
     l_sql_stmt :=
          ' DROP TABLE chk_jrnls_'||l_bug_no;
    EXECUTE IMMEDIATE l_sql_stmt;
  EXCEPTION
    WHEN OTHERS THEN
      null;
  END;

  l_sql_stmt :=
       ' CREATE TABLE chk_jrnls_'||l_bug_no||' AS '||
       ' SELECT xe.event_id, '||
       '        xah.ae_header_id, '||
       '        xah.accounting_date,  '||
       '        xah.gl_transfer_status_code,  '||
       '        DECODE(xah.balance_type_code, '||
       '               ''A'', ''Actual'', '||
       '               ''E'', ''Encumbrance'') balance_type, '||
       '        xal.accounting_class_code,  '||
       '        gcc.padded_concatenated_segments account, '||
       '        xal.entered_dr,  '||
       '        xal.entered_cr,  '||
       '        xal.accounted_dr, '||
       '        xal.accounted_cr, '||
       '        xah.ledger_id, '||
       '        ''Y'' process_flag '||
       ' FROM xla_ae_lines xal, '||
       '      xla_ae_headers xah, '||
       '      xla_events xe, '||
       '      gl_code_combinations_kfv gcc '||
       ' WHERE xal.application_id = 200 '||
       ' AND xah.application_id = 200 '||
       ' AND xe.application_id = 200 '||
       ' AND xal.ae_header_id = xah.ae_header_id '||
       ' AND xal.code_combination_id = gcc.code_combination_id '||
       ' AND xah.event_id = xe.event_id '||
       ' AND xe.event_status_code = ''P'' '||
       ' AND xe.event_id IN '||
       '        (SELECT aph.accounting_event_id '||
       '           FROM ap_payment_history_all aph, '||
       '                chks_temp_data_driver_'||l_bug_no||' ac '||
       '          WHERE aph.check_id = ac.check_id ) ';



  EXECUTE IMMEDIATE l_sql_stmt;
  ------------------------------------------------------------------


  AP_ACCTG_DATA_FIX_PKG.Print('Start of Issues with note 1060644.1');
  l_message := ' Following Orphan Invoice Distributions have '||
               ' been Identified in the system';
  AP_ACCTG_DATA_FIX_PKG.Print(l_message);
 

  l_debug_info := 'Constructing the select columns ';
  l_select_list :=
          'INVOICE_ID,'||
          'INVOICE_NUM,'||
          'INVOICE_TYPE_LOOKUP_CODE,'||
          'INVOICE_DATE,'||
          'VENDOR_NAME,'||
          'VENDOR_SITE_CODE,'||
          'INVOICE_LINE_NUMBER,'||
          'DISTRIBUTION_LINE_NUMBER,'||
          'LINE_TYPE_LOOKUP_CODE,'||
          'INVOICE_DISTRIBUTION_ID,'||
          'AMOUNT,'||
          'BASE_AMOUNT,'||
          'ACCOUNTING_EVENT_ID,'||
          'POSTED_FLAG,'||
          'DETAIL_TAX_DIST_ID,'||
	  'ORG_ID,'||
	  'SET_OF_BOOKS_ID';

  l_debug_info := 'Getting the table name ';
  l_table_name :=
         l_driver_tab;

  l_debug_info := 'Constructing the where clause ';
  l_where_clause :=
          ' ORDER BY INVOICE_ID,'||
          '         INVOICE_LINE_NUMBER,'||
          '         DISTRIBUTION_LINE_NUMBER';

  
  AP_ACCTG_DATA_FIX_PKG.Print_html_table
    (p_select_list       => l_select_list,
     p_table_in          => l_table_name,
     p_where_in          => l_where_clause,
     P_calling_sequence  => l_calling_sequence);
  ------------------------------------------------------------------


  l_debug_info := 'Prompting the transactions ';
  l_message := ' Following are the Orphan Invoice Distributions '||
               ' which are present in XLA, and need to be Un-Accounted';
  AP_ACCTG_DATA_FIX_PKG.Print(l_message);
  

  l_debug_info := 'Constructing the select columns ';
  l_select_list :=
          'INVOICE_ID,'||
          'INVOICE_NUM,'||
          'INVOICE_TYPE_LOOKUP_CODE,'||
          'INVOICE_DATE,'||
          'VENDOR_NAME,'||
          'VENDOR_SITE_CODE,'||
          'INVOICE_LINE_NUMBER,'||
          'DISTRIBUTION_LINE_NUMBER,'||
          'LINE_TYPE_LOOKUP_CODE,'||
          'INVOICE_DISTRIBUTION_ID,'||
          'AMOUNT,'||
          'BASE_AMOUNT,'||
          'ACCOUNTING_EVENT_ID,'||
          'POSTED_FLAG,'||
          'DETAIL_TAX_DIST_ID,'||
	  'ORG_ID,'||
	  'SET_OF_BOOKS_ID';

  l_debug_info := 'Getting the table name ';
  l_table_name :=
         'AP_DISTS_TO_UNDO_'||l_bug_no;

  l_debug_info := 'Constructing the where clause ';
  l_where_clause :=
          ' ORDER BY INVOICE_ID,'||
          '         INVOICE_LINE_NUMBER,'||
          '         DISTRIBUTION_LINE_NUMBER';

  l_debug_info := 'Before calling the Print HTML';
  AP_ACCTG_DATA_FIX_PKG.Print_html_table
    (p_select_list       => l_select_list,
     p_table_in          => l_table_name,
     p_where_in          => l_where_clause,
     P_calling_sequence  => l_calling_sequence);
  ------------------------------------------------------------------


  l_debug_info := 'Prompting the transactions ';
  l_message := ' Following are the Invoice events which need '||
               ' to be Un-Accounted';

  AP_ACCTG_DATA_FIX_PKG.Print(l_message);
  

  l_debug_info := 'Constructing the select columns ';
  l_select_list :=
          'EVENT_ID,'||
	  'EVENT_TYPE_CODE,'||
          'EVENT_STATUS_CODE,'||
          'PROCESS_STATUS_CODE,'||
	  'AE_HEADER_ID,'||
	  'GL_TRANSFER_STATUS_CODE,'||
	  'BALANCE_TYPE,'||
          'EVENT_DATE,'||
          'INVOICE_ID,'||
	  'ORG_ID,'||
	  'LEDGER_ID,'||
          'TRANSACTION_NUMBER,'||
          'TRANSACTION_TYPE';


  l_table_name := 'inv_evnts_'||l_bug_no;

  l_debug_info := 'Constructing the where clause ';
  l_where_clause :=
          ' ORDER BY EVENT_ID, AE_HEADER_ID, BALANCE_TYPE';

  l_debug_info := 'Before calling the Print HTML';
  AP_ACCTG_DATA_FIX_PKG.Print_html_table
    (p_select_list       => l_select_list,
     p_table_in          => l_table_name,
     p_where_in          => l_where_clause,
     P_calling_sequence  => l_calling_sequence);
  ------------------------------------------------------------------



  
  l_message := ' Following are the Journals for the events which '||
               ' need to be Un-Accounted';
  AP_ACCTG_DATA_FIX_PKG.Print(l_message);
  

  l_debug_info := 'Constructing the select columns ';
  l_select_list :=
          'EVENT_ID,'||
          'AE_HEADER_ID,'||
          'ACCOUNTING_DATE,'||
          'GL_TRANSFER_STATUS_CODE,'||
          'BALANCE_TYPE,'||
          'ACCOUNTING_CLASS_CODE,'||
          'ACCOUNT,'||
          'ENTERED_DR,'||
          'ENTERED_CR,'||
          'ACCOUNTED_DR,'||
          'ACCOUNTED_CR,'||
	  'LEDGER_ID';

  l_debug_info := 'Getting the table name ';
  l_table_name :=
         'inv_jrnls_'||l_bug_no;

  l_debug_info := 'Constructing the where clause ';
  l_where_clause :=
          'ORDER BY EVENT_ID, AE_HEADER_ID, BALANCE_TYPE';

  l_debug_info := 'Before calling the Print HTML';
  AP_ACCTG_DATA_FIX_PKG.Print_html_table
    (p_select_list       => l_select_list,
     p_table_in          => l_table_name,
     p_where_in          => l_where_clause,
     P_calling_sequence  => l_calling_sequence);
  ------------------------------------------------------------------


  l_message := ' Following are the checks paying the Invoice Distributions '||
               ' that need to be  Unaccounted';
  AP_ACCTG_DATA_FIX_PKG.Print(l_message);
  
  l_debug_info := 'Constructing the select columns ';
  l_select_list :=
          'CHECK_ID,'||
          'CHECK_NUMBER,'||
          'VENDOR_NAME,'||
          'VENDOR_SITE_CODE,'||
          'CHECK_DATE,'||
          'AMOUNT,'||
          'ORG_ID';

  l_debug_info := 'Getting the table name ';
  l_table_name := 'chks_temp_data_driver_'||l_bug_no;

  l_debug_info := 'Constructing the where clause ';
  l_where_clause :=
      'ORDER BY vendor_name, '||
      '         vendor_site_code, '||
      '         check_id';

  
  AP_ACCTG_DATA_FIX_PKG.Print_html_table
    (p_select_list       => l_select_list,
     p_table_in          => l_table_name,
     p_where_in          => l_where_clause,
     P_calling_sequence  => l_calling_sequence);
  ------------------------------------------------------------------



  
  l_message := ' Following are the events corresponding to the checks '||
               ' that need to be Unaccounted';
  AP_ACCTG_DATA_FIX_PKG.Print(l_message);
  

  
  l_select_list :=
          'EVENT_ID,'||
	  'EVENT_TYPE_CODE,'||
          'EVENT_STATUS_CODE,'||
          'PROCESS_STATUS_CODE,'||
	  'AE_HEADER_ID,'||
	  'GL_TRANSFER_STATUS_CODE,'||
	  'BALANCE_TYPE,'||
          'EVENT_DATE,'||
          'CHECK_ID,'||
	  'ORG_ID,'||
	  'LEDGER_ID,'||
          'TRANSACTION_NUMBER,'||
          'TRANSACTION_TYPE';

  
  l_table_name := 'chk_evnts_'||l_bug_no;

  
  l_where_clause :=
          'ORDER BY EVENT_ID, AE_HEADER_ID, BALANCE_TYPE';

  l_debug_info := 'Before calling the Print HTML';
  AP_ACCTG_DATA_FIX_PKG.Print_html_table
    (p_select_list       => l_select_list,
     p_table_in          => l_table_name,
     p_where_in          => l_where_clause,
     P_calling_sequence  => l_calling_sequence);
  ------------------------------------------------------------------



  l_debug_info := 'Prompting the transactions ';
  l_message := ' Following are the Journals corresponding to the check'||
               ' events that need to be Un-Accounted';
  AP_ACCTG_DATA_FIX_PKG.Print(l_message);
  
  
  l_select_list :=
          'EVENT_ID,'||
          'AE_HEADER_ID,'||
          'ACCOUNTING_DATE,'||
          'GL_TRANSFER_STATUS_CODE,'||
          'BALANCE_TYPE,'||
          'ACCOUNTING_CLASS_CODE,'||
          'ACCOUNT,'||
          'ENTERED_DR,'||
          'ENTERED_CR,'||
          'ACCOUNTED_DR,'||
          'ACCOUNTED_CR,'||
	  'LEDGER_ID';

  
  l_table_name :=
         'chk_jrnls_'||l_bug_no;

  
  l_where_clause :=
          ' ORDER BY EVENT_ID, AE_HEADER_ID, BALANCE_TYPE';

  
  AP_ACCTG_DATA_FIX_PKG.Print_html_table
    (p_select_list       => l_select_list,
     p_table_in          => l_table_name,
     p_where_in          => l_where_clause,
     P_calling_sequence  => l_calling_sequence);
  ------------------------------------------------------------------

  l_message := 'Following is the Information about the Invoice '||
               'events which will have issues while Unaccounting';
  AP_ACCTG_DATA_FIX_PKG.Print(l_message);

  
  AP_ACCTG_DATA_FIX_PKG.check_period
      (p_bug_no                      => l_bug_no,
       p_driver_table                => 'inv_evnts_'||l_bug_no,
       p_check_sysdate               => 'N',
       p_check_event_date            => 'Y',
       p_chk_proposed_undo_date      => 'N',
       p_update_process_flag         => 'N',
       p_calc_undo_date              => 'N',
       p_commit_flag                 => 'N',
       p_calling_sequence            => l_calling_sequence);

  l_debug_info := 'Following are the Invoice events for which the '||
                  'CCID on the Journal lines is Invalid';

  AP_ACCTG_DATA_FIX_PKG.check_ccid
      (p_bug_no                      => l_bug_no,
       p_driver_table                => 'inv_evnts_'||l_bug_no,
       p_update_process_flag         => 'N',
       p_commit_flag                 => 'N',
       p_calling_sequence            => l_calling_sequence);

  ------------------------------------------------------------------

  l_message := 'Following is the Information about the Check '||
               'events which will have issues while Unaccounting';

  AP_ACCTG_DATA_FIX_PKG.Print(l_message);

  l_debug_info := 'Following are the Check events for which the '||
                  'periods are closed: calling check_period';

  AP_ACCTG_DATA_FIX_PKG.check_period
      (p_bug_no                      => l_bug_no,
       p_driver_table                => 'chk_evnts_'||l_bug_no,
       p_check_sysdate               => 'N',
       p_check_event_date            => 'Y',
       p_chk_proposed_undo_date      => 'N',
       p_update_process_flag         => 'N',
       p_calc_undo_date              => 'N',
       p_commit_flag                 => 'N',
       p_calling_sequence            => l_calling_sequence);

  l_debug_info := 'Following are the Check events for which the '||
                  'CCID on the Journal lines is Invalid';

  AP_ACCTG_DATA_FIX_PKG.check_ccid
      (p_bug_no                      => l_bug_no,
       p_driver_table                => 'chk_evnts_'||l_bug_no,
       p_update_process_flag         => 'N',
       p_commit_flag                 => 'N',
       p_calling_sequence            => l_calling_sequence);

  ------------------------------------------------------------------

  		
  AP_ACCTG_DATA_FIX_PKG.Print('End of Issues with note 1060644.1');
  
   PRINT_LINE;				

   ELSIF l_rows > l_row_limit THEN
  AP_Acctg_Data_Fix_PKG.Print( 'More then 100 invoices affected'||
                               'Please follow the note 1060644.1 and run this GDF individually');
PRINT_LINE;
							   
  
END IF;	

FND_File.Put_Line(fnd_file.output,
                  '  END'||' '||'9358397'||'     '||
                  to_char(sysdate, 'DD-MON-YYYY:HH24:MI:SS'));


EXCEPTION
WHEN OTHERS THEN
  l_message := 'After '||l_message||'';
  AP_Acctg_Data_Fix_PKG.Print(l_message);
  l_message := 'Exception :: '||SQLERRM||'';
  AP_Acctg_Data_Fix_PKG.Print(l_message);
  APP_EXCEPTION.RAISE_EXCEPTION;
END;
--ap_orphan_dists_s.sql   




/*REM +=======================================================================+
REM | FILENAME                                                              |
REM |  ap_cancel_inv_sel.sql                                                |
REM |                                                                       |
REM | DESCRIPTION                                                           |
REM |  The following selection script will identify all the invoices on     |
REM |  which cancelation attempt was tried but the invoice did not get      |
REM |  cancelled.                                                           |
REM +=======================================================================+*/

BEGIN


FND_File.Put_Line(fnd_file.output,
                   '---------------------------------------------------------');
FND_File.Put_Line(fnd_file.output,
                  'START'||' '||'1060611.1'||'     '||
                  to_char(sysdate, 'DD-MON-YYYY:HH24:MI:SS'));

CHECK_COUNT(9088967,l_invoice_id,l_rows);

IF l_rows < l_row_limit and l_rows > 0 THEN

l_bug_no:=9088967;

l_driver_tab := 'AP_TEMP_DATA_DRIVER_'||l_bug_no;
  BEGIN
     l_sql_stmt :=
          ' DROP TABLE '||l_driver_tab;
    EXECUTE IMMEDIATE l_sql_stmt;
  EXCEPTION
    WHEN OTHERS THEN
      null;
  END;

  BEGIN
    l_debug_info := 'Before Creating the table '||l_driver_tab;

    l_sql_stmt :=
          ' CREATE TABLE '||l_driver_tab||
          '   AS '||
          ' SELECT DISTINCT ai.org_id,'||
		  '   ai.invoice_id,' ||
          '   ai.invoice_num,'||
          '   ai.invoice_type_lookup_code,'||
          '   ai.quick_credit,'||
          '   ''Y'' process_flag'||
          '   FROM ap_invoices_all ai, ap_holds_all ah' ||
          '  WHERE invoice_amount = 0' ||
          '    AND cancelled_date IS NULL' ||
          '    AND temp_cancelled_amount IS NOT NULL' ||
          '    AND ((0 <> (SELECT SUM(amount)'||
          '        FROM ap_invoice_distributions_all'||
          '       WHERE invoice_id = ai.invoice_id) OR'||
		  '      EXISTS (SELECT 1 FROM AP_INVOICE_LINES_ALL AIL'||
		  '               WHERE INVOICE_ID = AI.INVOICE_ID'||
		  '                 AND NOT EXISTS (SELECT 1 FROM AP_INVOICE_DISTRIBUTIONS_ALL'||
		  '                     WHERE INVOICE_ID = AIL.INVOICE_ID'||
		  '                       AND INVOICE_LINE_NUMBER = AIL.LINE_NUMBER)))'||
		  '          OR (ah.hold_lookup_code = ''NO RATE'' AND ah.release_lookup_code IS NULL))';

    EXECUTE IMMEDIATE l_sql_stmt;
  EXCEPTION
    WHEN OTHERS THEN
      l_error_log := ' Encountered an Unhandled Exception, '||SQLCODE||'-'||SQLERRM||
                     ' in '||l_calling_sequence||' while performing '||l_debug_info;
      AP_ACCTG_DATA_FIX_PKG.Print(l_error_log);

      l_error_log := 'The DYNAMIC SQL formed for execution is: '||l_sql_stmt;
      AP_ACCTG_DATA_FIX_PKG.Print(l_error_log);

      RAISE_APPLICATION_ERROR(-20001, 'UNKNOWN_SQL_ERROR');
  END;

   l_message := ' Following transactions WHERE INVOICE AMOUNT ZERO, BUT INVOICE TOTAL DIST AMOUNT IS <> ZERO ';
   AP_ACCTG_DATA_FIX_PKG.Print(l_message);
   l_message := ' SOLUTION : Follow Note 1060611.1 ';
   AP_ACCTG_DATA_FIX_PKG.Print(l_message);
  
  l_select_list :=
           'ORG_ID,'||
           'INVOICE_ID,'||
           'INVOICE_NUM,'||
           'INVOICE_TYPE_LOOKUP_CODE';

  
  l_table_name := l_driver_tab;

  l_where_clause := 'WHERE invoice_id='||l_invoice_id ||
                    ' ORDER BY ORG_ID,INVOICE_ID,INVOICE_NUM,INVOICE_TYPE_LOOKUP_CODE ORDER BY INVOICE_ID';
  
  
  AP_ACCTG_DATA_FIX_PKG.Print_html_table
    (p_select_list       => l_select_list,
     p_table_in          => l_table_name,
     p_where_in          => l_where_clause,
     P_calling_sequence  => l_calling_sequence);
	 

 		
 PRINT_LINE;				

 ELSIF l_rows > l_row_limit THEN
  AP_Acctg_Data_Fix_PKG.Print( 'More then 100 invoices affected'||
                               'Please follow the note 1060611.1 and run this GDF individually');
PRINT_LINE;	 

 END IF;


FND_File.Put_Line(fnd_file.output,
                  '  END'||' '||'1060611.1'||'     '||
                  to_char(sysdate, 'DD-MON-YYYY:HH24:MI:SS'));

EXCEPTION
WHEN OTHERS THEN
  l_message := 'After '||l_message||'';
  AP_Acctg_Data_Fix_PKG.Print(l_message);
  l_message := 'Exception :: '||SQLERRM||'';
  AP_Acctg_Data_Fix_PKG.Print(l_message);
  APP_EXCEPTION.RAISE_EXCEPTION;
END;

--ap_cancel_inv_sel.sql  

/*EM +=======================================================================+
REM | FILENAME                                                              |
REM |     ap_extra_nr_tax_dist_sel.sql				    |
REM |                                                                       |
REM | ISSUE                                                                 |
REM |  For R12 invoices,in case there is 100% tax rate variance (tax        |
REM |  on invoice and no tax on PO) then for a matched item line if TRV     |
REM |  is computed, on discarding such an item line and rematching it       |
REM |  causes an extra -ve non recoverable TAX to be generated.             |
REM |  This makes invoice impossible to validate by putting it on           |
REM |  distribution variance hold                                           |
=======================================================================+*/
BEGIN
FND_File.Put_Line(fnd_file.output,
                   '---------------------------------------------------------');
FND_File.Put_Line(fnd_file.output,
                  'START'||' '||'1063272.1'||'     '||
                  to_char(sysdate, 'DD-MON-YYYY:HH24:MI:SS'));

CHECK_COUNT(9231093,l_invoice_id,l_rows);

IF l_rows < l_row_limit and l_rows > 0 THEN

BEGIN
EXECUTE IMMEDIATE 'DROP TABLE AP_TEMP_DATA_DRIVER_9231093 ';
EXCEPTION
WHEN OTHERS THEN
    NUll;
END;
  
 EXECUTE IMMEDIATE ' CREATE TABLE AP_TEMP_DATA_DRIVER_9231093  AS                                 ' ||
                   ' SELECT INVOICE_ID,INVOICE_DISTRIBUTION_ID,LINE_TYPE_LOOKUP_CODE                         ' ||
		           ' FROM ap_invoice_distributions_all aid                                ' ||
				   ' WHERE aid.line_type_lookup_code =''NONREC_TAX''              ' ||
				   ' AND aid.detail_tax_dist_id IS NOT NULL                       ' ||
				   ' AND aid.summary_tax_line_id IS NOT NULL                      ' ||
				   ' AND aid.parent_reversal_id IS NULL                           ' ||
				   ' AND NVL(aid.historical_flag,''N'') = ''N''                   ' ||
				   ' AND aid.posted_flag = ''N''				  ' ||
				   ' AND EXISTS (SELECT 1                                         ' ||
				   	           ' FROM ap_invoice_distributions_all aidv                                     ' ||
					           ' WHERE aidv.invoice_id = aid.invoice_id                                     ' || 
					           ' AND aidv.charge_applicable_to_dist_id = aid.charge_applicable_to_dist_id   ' ||
					           ' AND aidv.detail_tax_dist_id = aid.detail_tax_dist_id                       ' ||
					           ' AND aidv.summary_tax_line_id = aid.summary_tax_line_id                     ' ||
					           ' AND aidv.line_type_lookup_code IN (''TRV'',''TERV'',''TIPV'')              ' ||
					           ' AND aidv.parent_reversal_id IS NOT NULL)                                   ' ;


l_select_list := 'INVOICE_ID,'||
           'INVOICE_DISTRIBUTION_ID,'||
           'LINE_TYPE_LOOKUP_CODE';

  
  l_table_name := 'AP_TEMP_DATA_DRIVER_9231093';

  l_where_clause := 'WHERE invoice_id='||l_invoice_id ||' ORDER BY INVOICE_ID,INVOICE_DISTRIBUTION_ID,LINE_TYPE_LOOKUP_CODE';
  
AP_Acctg_Data_Fix_PKG.Print( 'Invoices with 100% Tax Variance are Placed in Distribution Variance');  
AP_Acctg_Data_Fix_PKG.Print( 'SOLUTION : Follow note 1063272.1');  

 AP_ACCTG_DATA_FIX_PKG.Print_html_table
    (p_select_list       => l_select_list,
     p_table_in          => l_table_name,
     p_where_in          => l_where_clause,
     P_calling_sequence  => l_calling_sequence);
	
  		
 PRINT_LINE;				

 ELSIF l_rows > l_row_limit THEN
  AP_Acctg_Data_Fix_PKG.Print( 'More then 100 invoices affected'||
                               'Please follow the note 1063272.1 and run this GDF individually');
PRINT_LINE;	 

 END IF; 

FND_File.Put_Line(fnd_file.output,
                  '  END'||' '||'1063272.1'||'     '||
                  to_char(sysdate, 'DD-MON-YYYY:HH24:MI:SS'));

 EXCEPTION
WHEN OTHERS THEN
  l_message := 'After '||l_message||'';
  AP_Acctg_Data_Fix_PKG.Print(l_message);
  l_message := 'Exception :: '||SQLERRM||'';
  AP_Acctg_Data_Fix_PKG.Print(l_message);
  APP_EXCEPTION.RAISE_EXCEPTION;
END;

--ap_extra_nr_tax_dist_sel.sql     


/*EM +=======================================================================+
REM | FILENAME                                                              |
REM |     ap_incl_excl_tax_sel.sql                                          |
REM |                                                                       |
REM | DESCRIPTION                                                           |
REM |     The item distribution for which an inclusive tax is associated is |
REM |  reflecting wrong amount in XLA accounting tables. This is the case   |
REM |  if the inclusive tax lines are discarded atleast once. This selection|
REM |  script identifies all such transactions.                             |
REM +=======================================================================+*/
BEGIN

FND_File.Put_Line(fnd_file.output,
                   '---------------------------------------------------------');
FND_File.Put_Line(fnd_file.output,
                  'START'||' '||'9231459'||'     '||
                  to_char(sysdate, 'DD-MON-YYYY:HH24:MI:SS'));

CHECK_COUNT(9231459,l_invoice_id,l_rows);

IF l_rows < l_row_limit and l_rows > 0 THEN

l_bug_no:=9231459;

 --------------------------------------------------------------------------
  -- Step 1: Drop the temporary tables if already exists
  --------------------------------------------------------------------------
  l_driver_tab  := 'AP_TEMP_DATA_DRV_INV_'||l_bug_no;
  l_driver_tab1 := 'AP_TEMP_DATA_DRV_PAY_'||l_bug_no;
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
          ' DROP TABLE '||l_driver_tab1;
    EXECUTE IMMEDIATE l_sql_stmt;
  EXCEPTION
    WHEN OTHERS THEN
      NULL;
  END;
  
  --------------------------------------------------------------------------
  -- Step 2: create backup tables and driver tables
  --------------------------------------------------------------------------
  l_debug_info := 'Before Creating the table '||l_driver_tab;
 
  l_sql_stmt :=
          ' CREATE TABLE '||l_driver_tab||
          '   AS '||
          ' SELECT DISTINCT ai.invoice_id,'||
          '        ai.invoice_num,'||
          '        ai.invoice_amount,'||
          '        aid.invoice_line_number,'||
          '        aid.distribution_line_number,'||
          '        aid.accounting_event_id,'||
          '        aid.org_id,'||
          '        ''Y'' process_flag'||        
          '   FROM ap_invoices_all ai,'||
          '        ap_invoice_distributions_all aid,'||
          '        ap_system_parameters_all asp,'||
          '        xla_ae_headers xah,'||
          '        xla_ae_lines xal,'||
          '        xla_distribution_links xdl'||
          '  WHERE ai.invoice_id = aid.invoice_id'||
          '    AND aid.org_id = asp.org_id'||
          '    AND nvl(aid.historical_flag,''N'')  = ''N'''||
          '    AND asp.set_of_books_id = xah.ledger_id'||
          '    AND aid.accounting_event_id = xah.event_id'||
          '    AND xah.application_id = 200'||
          '    AND xal.application_id = 200'||
          '    AND xdl.application_id = 200'||
          '    AND aid.posted_flag = ''Y'''||
          '    AND xah.ae_header_id = xal.ae_header_id'||
          '    AND xah.event_id = xdl.event_id'||
          '    AND xah.ae_header_id = xdl.ae_header_id'||
          '    AND xal.ae_line_num = xdl.ae_line_num'||
          '    AND aid.line_type_lookup_code IN (''ITEM'',   ''ACCRUAL'')'||
          '    AND xal.accounting_class_code = ''LIABILITY'''||
          '    AND xdl.source_distribution_id_num_1 = aid.invoice_distribution_id'||
          '    AND xdl.source_distribution_type = ''AP_INV_DIST'''||
          '    AND nvl(xdl.unrounded_entered_cr,   xdl.unrounded_entered_dr) <> ABS(aid.amount)'||
          '    AND EXISTS'||
          '       (SELECT 1'||
          '          FROM ap_invoice_distributions_all d2'||
          '         WHERE d2.invoice_id = aid.invoice_id'||
          '           AND d2.line_type_lookup_code IN (''NONREC_TAX'',    ''REC_TAX'')'||
          '           AND d2.invoice_line_number = aid.invoice_line_number'||
          '           AND d2.charge_applicable_to_dist_id = aid.invoice_distribution_id)';
          
  EXECUTE IMMEDIATE l_sql_stmt;   

 l_sql_stmt:= 'DELETE FROM '||l_driver_tab||' WHERE INVOICE_ID <> '|| l_invoice_id;
  EXECUTE IMMEDIATE l_sql_stmt;  

  l_debug_info := 'Before Creating the table '||l_driver_tab1;
 
  l_sql_stmt :=
          ' CREATE TABLE '||l_driver_tab1||
          '   AS '||
          ' SELECT DISTINCT aph.check_id,'||
          '        ac.check_number,'||
          '        trunc(ac.check_date) check_date,'||
          '        aip.invoice_id,'||
          '        aph.transaction_type,'||
          '        aph.accounting_event_id,'||
          '        aph.org_id,'||
          '        ''Y'' process_flag'||
          '   FROM ap_temp_data_drv_inv_9231459 ai,'||
          '        ap_payment_history_all aph,'||
	  '        ap_checks_all ac,'||
          '        ap_invoice_payments_all aip'||
          '  WHERE ai.invoice_id = aip.invoice_id'||
          '    AND aip.check_id = aph.check_id'||
	  '    AND ac.check_id = aph.check_id'||
          '    AND aph.posted_flag = ''Y'''||
          '    AND aph.transaction_type LIKE ''%ADJUSTED'''; 

  EXECUTE IMMEDIATE l_sql_stmt;      

  ------------------------------------------------------------------
  -- Step 3: Report all the affected transactions in Log file 
  ---------------------------------------------------------------------
  Begin
    Execute Immediate  
        'SELECT COUNT(*) from AP_TEMP_DATA_DRV_INV_9231459' into l_count;
    Execute Immediate  
        'SELECT COUNT(*) from AP_TEMP_DATA_DRV_PAY_9231459' into l_count1;        
  EXCEPTION
    WHEN OTHERS THEN
          l_message := 'Exception in selecting count from '|| 
               l_driver_tab||' for selecting affected records'||
               SQLERRM ;
          AP_ACCTG_DATA_FIX_PKG.Print(l_message);
  END; 

  IF (l_count > 0) THEN    

  
    l_message := ' Following invoices Accounted '||
                   ' Amounts are Out of Sync With Invoice Distribution Amounts';
				   
    AP_ACCTG_DATA_FIX_PKG.Print(l_message);
    
	l_message := ' SOLUTION : Follow note 1063263.1 ';
	AP_ACCTG_DATA_FIX_PKG.Print(l_message);
    
    
   l_select_list :=
           'INVOICE_ID,'||
           'INVOICE_NUM,'||
           'INVOICE_LINE_NUMBER,'||
           'DISTRIBUTION_LINE_NUMBER,'||
           'INVOICE_AMOUNT,'||
           'ACCOUNTING_EVENT_ID,'||
           'ORG_ID';

    
    l_table_name := l_driver_tab;

    

    l_where_clause :='WHERE 1=1 ORDER BY INVOICE_ID,'||
           'INVOICE_NUM,'||
           'INVOICE_LINE_NUMBER,'||
           'DISTRIBUTION_LINE_NUMBER,'||
           'INVOICE_AMOUNT,'||
           'ACCOUNTING_EVENT_ID,'||
           'ORG_ID '||
           'ORDER BY INVOICE_ID,INVOICE_LINE_NUMBER,DISTRIBUTION_LINE_NUMBER';

    
    AP_ACCTG_DATA_FIX_PKG.Print_html_table
      (p_select_list       => l_select_list,
       p_table_in          => l_table_name,
       p_where_in          => l_where_clause,
       P_calling_sequence  => l_calling_sequence);
       
    IF (l_count1 > 0) THEN
    
       l_message := ' Following payments where Accounted '||
                   ' Amounts are Out of Sync With Invoice Distribution Amounts'; 
				   
    				   
      AP_ACCTG_DATA_FIX_PKG.Print(l_message);
	  
	     l_message := ' SOLUTION : Follow note 1063263.1 ';
	AP_ACCTG_DATA_FIX_PKG.Print(l_message);
    
      
    
      AP_Acctg_Data_Fix_PKG.Print(l_message);
      
      l_select_list :=
          'CHECK_ID,'||
          'CHECK_NUMBER,'||
          'CHECK_DATE,'||
          'INVOICE_ID,'||
          'TRANSACTION_TYPE,'||
          'ACCOUNTING_EVENT_ID,'||
          'ORG_ID'     ;
      
      
      l_where_clause :=
             'ORDER BY CHECK_ID';
      
      
      AP_ACCTG_DATA_FIX_PKG.Print_html_table
        (p_select_list       => l_select_list,
         p_table_in          => l_table_name,
         p_where_in          => l_where_clause,
         P_calling_sequence  => l_calling_sequence);
         
    
    END IF;
 
 END IF;

PRINT_LINE;				

 ELSIF l_rows > l_row_limit THEN
  AP_Acctg_Data_Fix_PKG.Print( 'More then 100 invoices affected'||
                               'Please follow the note 1063272.1 and run this GDF individually');
PRINT_LINE;	
  
END IF;

FND_File.Put_Line(fnd_file.output,
                  '  END'||' '||'9231459'||'     '||
                  to_char(sysdate, 'DD-MON-YYYY:HH24:MI:SS'));

EXCEPTION
WHEN OTHERS THEN
  l_message := 'After '||l_message||'';
  AP_Acctg_Data_Fix_PKG.Print(l_message);
  l_message := 'Exception :: '||SQLERRM||'';
  AP_Acctg_Data_Fix_PKG.Print(l_message);
  APP_EXCEPTION.RAISE_EXCEPTION;
END;

---ap_incl_excl_tax_sel.sql     

/*REM +=======================================================================+
REM | FILENAME                                                              |
REM |     ap_upd_ccid_nr_tax_dist_sel.sql			            |
REM |                                                                       |
REM | ISSUE                                                                 |
REM |   For "TAX" only lines, the non-rec tax distributions                 |
REM |   were getting stamped as  ccid -99                                   |
REM |                                                                       |
REM +=======================================================================+*/

BEGIN

FND_File.Put_Line(fnd_file.output,
                   '---------------------------------------------------------');
FND_File.Put_Line(fnd_file.output,
                  'START'||' '||'1060687.1'||'     '||
                  to_char(sysdate, 'DD-MON-YYYY:HH24:MI:SS'));


CHECK_COUNT(9296562,l_invoice_id,l_rows);

IF l_rows < l_row_limit and l_rows > 0 THEN



BEGIN
EXECUTE IMMEDIATE 'DROP TABLE AP_TEMP_DATA_DRIVER_9296562 ';
EXCEPTION
    WHEN OTHERS THEN
    NULL;
END;


 

   EXECUTE IMMEDIATE ' CREATE TABLE AP_TEMP_DATA_DRIVER_9296562  AS            ' ||
                   ' SELECT INVOICE_ID,INVOICE_DISTRIBUTION_ID   ' ||
		   ' FROM ap_invoice_distributions_all      aid              ' ||
	           ' WHERE aid.line_type_lookup_code   = ''NONREC_TAX''      ' ||
		   ' AND aid.DIST_CODE_COMBINATION_ID= -99                   ' ||
		   ' AND aid.detail_tax_dist_id IS NOT NULL                  ';



 l_message := ' Distributions of Tax Only Invoices Cannot be Validated ';
  AP_ACCTG_DATA_FIX_PKG.Print(l_message);
	  
l_message := ' SOLUTION : Follow note 1060687.1 ';
AP_ACCTG_DATA_FIX_PKG.Print(l_message);
    
      
    
    l_select_list :='INVOICE_ID,INVOICE_DISTRIBUTION_ID';
          
      
      l_where_clause :='INVOICE_ID='||l_invoice_id;
             
      l_table_name:='AP_TEMP_DATA_DRIVER_9296562';
      
      AP_ACCTG_DATA_FIX_PKG.Print_html_table
        (p_select_list       => l_select_list,
         p_table_in          => l_table_name,
         p_where_in          => l_where_clause,
         P_calling_sequence  => l_calling_sequence);
   
PRINT_LINE;				

 ELSIF l_rows > l_row_limit THEN
  AP_Acctg_Data_Fix_PKG.Print( 'More then 100 invoices affected'||
                               'Please follow the note 1060687.1 and run this GDF individually');
PRINT_LINE;	
  
END IF;


FND_File.Put_Line(fnd_file.output,
                  '  END'||' '||'1060687.1'||'     '||
                  to_char(sysdate, 'DD-MON-YYYY:HH24:MI:SS'));


EXCEPTION
WHEN OTHERS THEN
  l_message := 'After '||l_message||'';
  AP_Acctg_Data_Fix_PKG.Print(l_message);
  l_message := 'Exception :: '||SQLERRM||'';
  AP_Acctg_Data_Fix_PKG.Print(l_message);
  APP_EXCEPTION.RAISE_EXCEPTION;
END;


/* +=======================================================================+
REM | FILENAME                                                        	    |
REM |     upd_xdl_tax_details_sel.sql                                       |
REM |                                                                      s |
REM | DESCRIPTION                                                     	    |
REM |     This whole fix is to stamp tax details in XDL table               |
REM |     for upgraded transactions.                                        |
REM |     because  in the old versions of appdstln.sql and apidstln.sql     |
REM |     updating the tax details was missing.                             |
REM |     this script will update   the xdl for both invoice and check      |
REM |     related transactions.                                             |
REM +=======================================================================+*/


BEGIN

 
/* Building the dynamic conditions for invoice and payment according to the parameter values. */


FND_File.Put_Line(fnd_file.output,
                   '---------------------------------------------------------');
FND_File.Put_Line(fnd_file.output,
                  'START'||' '||'967213.1'||'     '||
                  to_char(sysdate, 'DD-MON-YYYY:HH24:MI:SS'));


BEGIN

    EXECUTE IMMEDIATE  'SELECT count(distinct(REC_NREC_TAX_DIST_ID)) ' ||
   ' FROM zx.zx_rec_nrec_dist zrd,'||
        'ap_invoice_distributions_all aid,'||
	'ap_invoices_all ai,'||
	'xla_ae_headers xah '||
     ' WHERE ai.invoice_id = aid.invoice_id '||
     ' AND upper(zrd.RECORD_TYPE_CODE) = ''MIGRATED'' '||
     ' AND zrd.application_id = 200'||
     ' AND zrd.REC_NREC_TAX_DIST_ID = aid.Detail_Tax_Dist_ID'||
     ' AND aid.accounting_event_id = xah.event_id'||
     ' AND xah.application_id = 200'||
     ' AND aid.posted_flag = ''Y'''||
     ' AND aid.historical_flag = ''Y'' '||
	 ' AND ai.invoice_id=:1 ' 
     INTO l_rows1
	  USING l_invoice_id;
	  
	  
	 
	  
	  l_rows:=l_rows1;
	  
	EXECUTE IMMEDIATE ' SELECT count( distinct (aid.invoice_distribution_id))' ||
                   ' FROM ap_invoice_distributions_all aid, ap_invoice_payments_all aip,zx_rec_nrec_dist zrd '||
                   ' WHERE  aip.invoice_id = aid.invoice_id '||
                   ' AND aid.detail_tax_dist_id = zrd.rec_nrec_tax_dist_id '||
                   ' AND aid.detail_tax_dist_id is not null '||
                   ' AND aid.historical_flag = ''Y'' '||
                   ' AND upper(zrd.RECORD_TYPE_CODE) = ''MIGRATED'' '||
                   ' AND zrd.application_id = 200 '||
                   ' AND zrd.entity_code = ''AP_INVOICES'' '||
				   ' AND aid.invoice_id=:1 '
	INTO l_rows1
		   USING l_invoice_id;    
	 
     l_rows:=l_rows1+l_rows;
EXCEPTION
when others then
     FND_LOG.STRING(10, 'upd_xdl_tax_details.sql','error occurred for invoices is '|| SQLERRM);
     AP_Acctg_Data_Fix_PKG.Print('Error occurred (INVOICE) is : ' || SQLERRM);
END;	 
	 
If l_rows < l_row_limit and l_rows > 0 then 	 


BEGIN
 EXECUTE IMMEDIATE 'DROP TABLE temp_table'||table_name;
EXCEPTION
  WHEN OTHERS THEN
    NUll;
END;

BEGIN
 EXECUTE IMMEDIATE 'DROP TABLE aid_backup'||table_name;
EXCEPTION
  WHEN OTHERS THEN
    NULL;
END;


   
--- DROPPED THE TABLES ---------

BEGIN

/* STEP 1 ,mentioned in the script description, for invoice */

 EXECUTE IMMEDIATE 'CREATE TABLE temp_table'||table_name||' AS '||
   'SELECT /*+ parallel(ai) */ zrd.tax_line_id   ,'||
         ' zrd.REC_NREC_TAX_DIST_ID,zrd.SUMMARY_TAX_LINE_ID, xah.ae_header_id, aid.accounting_event_id '||
	 ' ,aid.invoice_distribution_id '||
   'FROM zx.zx_rec_nrec_dist zrd,'||
        'ap_invoice_distributions_all aid,'||
	'ap_invoices_all ai,'||
	'xla_ae_headers xah '||
     ' WHERE 1=2';
	 
	 EXECUTE IMMEDIATE 'INSERT INTO temp_table'||table_name||
   ' SELECT /*+ parallel(ai) */ zrd.tax_line_id   ,'||
         ' zrd.REC_NREC_TAX_DIST_ID,zrd.SUMMARY_TAX_LINE_ID, xah.ae_header_id, aid.accounting_event_id '||
	 ' ,aid.invoice_distribution_id '||
   'FROM zx.zx_rec_nrec_dist zrd,'||
        'ap_invoice_distributions_all aid,'||
	'ap_invoices_all ai,'||
	'xla_ae_headers xah '||
     ' WHERE ai.invoice_id = aid.invoice_id '||
     ' AND upper(zrd.RECORD_TYPE_CODE) = ''MIGRATED'' '||
     ' AND zrd.application_id = 200'||
     ' AND zrd.REC_NREC_TAX_DIST_ID = aid.Detail_Tax_Dist_ID'||
     ' AND aid.accounting_event_id = xah.event_id'||
     ' AND xah.application_id = 200'||
     ' AND aid.posted_flag = ''Y'''||
     ' AND aid.historical_flag = ''Y'' '||
	 ' AND ai.invoice_id=:1 '
     USING l_invoice_id;
	 
  l_message := ' Following Invocie where'||
                   ' Tax Details Not Populated in XLA_DISTRIBUTION_LINKS for Upgraded Transaction'; 
				   
    				   
      AP_ACCTG_DATA_FIX_PKG.Print(l_message);
	  
	     l_message := ' SOLUTION : Follow note 967213.1 ';
	
	AP_ACCTG_DATA_FIX_PKG.Print(l_message);
    
        l_select_list :='TAX_LINE_ID,REC_NREC_TAX_DIST_ID,SUMMARY_TAX_LINE_ID,AE_HEADER_ID,ACCOUNTING_EVENT_ID';
      
      
      l_where_clause :=
             ' ORDER BY TAX_LINE_ID';
      
	  l_table_name:='temp_table'||table_name;
      
      AP_ACCTG_DATA_FIX_PKG.Print_html_table
        (p_select_list       => l_select_list,
         p_table_in          => l_table_name,
         p_where_in          => l_where_clause,
         P_calling_sequence  => l_calling_sequence);	 

  

EXCEPTION
   WHEN OTHERS THEN
     FND_LOG.STRING(10, 'upd_xdl_tax_details.sql','error occurred for invoices is '|| SQLERRM);
     AP_Acctg_Data_Fix_PKG.Print('Error occurred (INVOICE) is : ' || SQLERRM);
END;


BEGIN

/* STEP 1 ,mentioned in the script description, for check */

EXECUTE IMMEDIATE ' CREATE TABLE aid_backup'||table_name ||' AS '||
                   ' SELECT /*+ parallel(aid) */ DISTINCT aid.invoice_distribution_id,aip.check_id,'||
		   ' aid.detail_tax_dist_id,'||
                   ' aid.summary_tax_line_id,zrd.tax_line_id'||
                   ' FROM ap_invoice_distributions_all aid, ap_invoice_payments_all aip,zx_rec_nrec_dist zrd '||
                   ' WHERE  1=2';
 

 EXECUTE IMMEDIATE ' INSERT INTO aid_backup'||table_name ||
                   ' SELECT /*+ parallel(aid) */ DISTINCT aid.invoice_distribution_id,aip.check_id,'||
		   ' aid.detail_tax_dist_id,'||
                   ' aid.summary_tax_line_id,zrd.tax_line_id'||
                   ' FROM ap_invoice_distributions_all aid, ap_invoice_payments_all aip,zx_rec_nrec_dist zrd '||
                   ' WHERE  aip.invoice_id = aid.invoice_id '||
                   ' AND aid.detail_tax_dist_id = zrd.rec_nrec_tax_dist_id '||
                   ' AND aid.detail_tax_dist_id is not null '||
                   ' AND aid.historical_flag = ''Y'' '||
                   ' AND upper(zrd.RECORD_TYPE_CODE) = ''MIGRATED'' '||
                   ' AND zrd.application_id = 200 '||
                   ' AND zrd.entity_code = ''AP_INVOICES'' '||
				   ' AND aid.invoice_id = :1 ' 
            USING l_invoice_id;  
 l_message := ' Following CHECKS where'||
                   ' Tax Details Not Populated in XLA_DISTRIBUTION_LINKS for Upgraded Transaction'; 
				   
    				   
      AP_ACCTG_DATA_FIX_PKG.Print(l_message);
	  
	     l_message := ' SOLUTION : Follow note 967213.1 ';
	
	AP_ACCTG_DATA_FIX_PKG.Print(l_message);
    
        l_select_list :='INVOICE_DISTRIBUTION_ID,CHECK_ID,DETAIL_TAX_DIST_ID,SUMMARY_TAX_LINE_ID,TAX_LINE_ID';
      
      
      l_where_clause :=
             ' ORDER BY INVOICE_DISTRIBUTION_ID';
      
	  l_table_name:='aid_backup'||table_name;
      
      AP_ACCTG_DATA_FIX_PKG.Print_html_table
        (p_select_list       => l_select_list,
         p_table_in          => l_table_name,
         p_where_in          => l_where_clause,
         P_calling_sequence  => l_calling_sequence);	


     PRINT_LINE;

 EXCEPTION
   WHEN OTHERS THEN
     FND_LOG.STRING(10, 'upd_xdl_tax_details.sql','error while creating '
                         ||' xdl_pay_backup_8991569 table : '|| SQLERRM);
     AP_Acctg_Data_Fix_PKG.Print('error while creating xdl_pay_backup_8991569 table : ' || SQLERRM);
 END;
 
 elsif l_rows > l_row_limit then

AP_ACCTG_DATA_FIX_PKG.Print('More then 10000 rows returned. Please follow the note for more details' );

PRINT_LINE;

end if;


FND_File.Put_Line(fnd_file.output,
                  '  END'||' '||'967213.1'||'     '||
                  to_char(sysdate, 'DD-MON-YYYY:HH24:MI:SS'));

EXCEPTION
   WHEN Script_Exception THEN
        FND_LOG.STRING(10, 'upd_xdl_tax_details.sql','One or both the date(s) not entered');
	AP_Acctg_Data_Fix_PKG.Print('One or both the date(s) not entered. Please enter both the start and end date');
   WHEN OTHERS THEN
        FND_LOG.STRING(10, 'upd_xdl_tax_details.sql','error is '||sqlerrm);
	AP_Acctg_Data_Fix_PKG.Print('Error happend is : ' ||sqlerrm);
END;



--upd_xdl_tax_details_sel.sql


/*REM +=======================================================================+
REM | FILENAME                                                              |
REM |     update_inv_total_tax_amt_sel.sql				    |
REM |                                                                       |
REM | DESCRIPTION                                                           |
REM |                                                                       |
REM |     Selection script for invoices with total_tax_amount null	    |
REM |     and invoices has tax lines                                        |         
REM |                                                                       |
REM |    Once the script completes customer can check the data in the       |
REM |    table inv_total_tax_null and he can select the only rows which     |
REM |    they want to fix through fix script. this can be done by           |
REM |    stamping the process_flag to N in table inv_total_tax_null         |
REM |    for other rows what he wants to fix (because the processflag is Y  |
REM |    by default). if he wont modify any thing on this column the fix    |
REM |    will run for all the data.                                         |
REM +=======================================================================+*/


BEGIN  


FND_File.Put_Line(fnd_file.output,
                   '---------------------------------------------------------');
FND_File.Put_Line(fnd_file.output,
                  'START'||' '||'972143.1'||'     '||
                  to_char(sysdate, 'DD-MON-YYYY:HH24:MI:SS'));

CHECK_COUNT(9076040,l_invoice_id,l_rows);

IF l_rows < l_row_limit and l_rows > 0 THEN

BEGIN
 EXECUTE IMMEDIATE 'DROP TABLE inv_total_tax_null';
EXCEPTION
  WHEN OTHERS THEN
    NULL;
END;


BEGIN

  EXECUTE IMMEDIATE 'CREATE TABLE inv_total_tax_null AS                        ' ||
                   ' SELECT AI.INVOICE_ID,AI.INVOICE_NUM,AI.TAX_AMOUNT FROM ap_invoices_all ai    ' ||
		   ' WHERE 1=2                           ' ;

 EXECUTE IMMEDIATE 'INSERT INTO inv_total_tax_null                         ' ||
                   ' SELECT AI.INVOICE_ID,AI.INVOICE_NUM,AI.TAX_AMOUNT FROM ap_invoices_all ai    ' ||
		   ' WHERE ai.historical_flag = ''Y''                           ' ||
		   ' AND ai.total_tax_amount IS NULL                          ' ||
		   ' AND EXISTS (SELECT ''tax exists''                        ' ||
		   '             FROM ap_invoice_lines_all ail                ' ||
		   '             WHERE ai.invoice_id = ail.invoice_id         ' ||
		   '             AND   ail.line_type_lookup_code = ''TAX'')   ' ||
		   '             AND   ai.invoice_id= :1'
		   USING l_invoice_id;
		   
EXCEPTION
WHEN OTHERS THEN
DBMS_OUTPUT.PUT_LINE(SQLERRM);
		   END;		   

  l_select_list := 'INVOICE_ID,'||
           'INVOICE_NUM,'||
           'TAX_AMOUNT';

  
  l_table_name := 'inv_total_tax_null';

  l_where_clause := 'WHERE 1=1 ORDER BY INVOICE_ID,INVOICE_NUM,TAX_AMOUNT';
  
AP_Acctg_Data_Fix_PKG.Print( 'Invoice with wrong (NULL) total_tax_amount on invoice header, But having tax distributions and lines');  
AP_Acctg_Data_Fix_PKG.Print( 'SOLUTION : Follow note 972143.1');  

DBMS_OUTPUT.PUT_LINE('B4 Table');

 AP_ACCTG_DATA_FIX_PKG.Print_html_table
    (p_select_list       => l_select_list,
     p_table_in          => l_table_name,
     p_where_in          => l_where_clause,
     P_calling_sequence  => l_calling_sequence);
	 
	 DBMS_OUTPUT.PUT_LINE('AFTER Table');
	
  PRINT_LINE;				

 ELSIF l_rows > l_row_limit THEN
  AP_Acctg_Data_Fix_PKG.Print( 'More then 100 invoices affected'||
                               'Please follow the note 972143.1 and run this GDF individually');
PRINT_LINE;	 

 END IF; 

FND_File.Put_Line(fnd_file.output,
                  '  END'||' '||'972143.1'||'     '||
                  to_char(sysdate, 'DD-MON-YYYY:HH24:MI:SS'));

EXCEPTION 
      
   WHEN Script_Exception THEN
    FND_LOG.STRING(10, 'update_inv_total_tax_amt_sel.sql','Error in enabling fnd debug : ' || SQLERRM);
    AP_Acctg_Data_Fix_PKG.Print('Error in enabling fnd debug : ' || SQLERRM);

   WHEN OTHERS THEN
     FND_LOG.STRING(10, 'update_inv_total_tax_amt_sel.sql','Error is : ' || SQLERRM);
     AP_Acctg_Data_Fix_PKG.Print('Error is : ' || SQLERRM);

END ;

--  update_inv_total_tax_amt_sel.sql

/*REM +=======================================================================+
REM | FILENAME                                                              |
REM |     upd_wrng_pay_awt_rev_sel.sql				            |
REM |                                                                       |
REM | ISSUE                                                                 |
REM |    For 11i payment time awt reversal distributions at the time of     |
REM |    upgrade it populating invoice lines separately for original and    |
REM |    reversed distributions. This is happening due to 11i corruption.   |
REM |    already done the code fix in upgrade script for bug 9080712        |
REM |                                                                       |
REM | DESCRIPTION                                                           |
REM |                                                                       |
REM |     Selection script to select the invoice lines and distributions    |
REM |     belongs to upgraded reversal payment time AWT (11i) distributions |         
REM |                                                                       |
REM |    Once the script completes customer can check the data in the       |
REM |    table AP_TEMP_DATA_DRIVER_9080707 and he can select the only       |
REM |    rows which they want to fix through fix script. this can be done by|
REM |    stamping the process_flag to N in table AP_TEMP_DATA_DRIVER_9080707|
REM |    for other rows what he wants to fix (because the processflag is Y  |
REM |    by default). if he wont modify any thing on this column the fix    |
REM |    will run for all the data.                                         |
REM |                                                                       |
REM |    The fix script is upd_wrng_pay_awt_rev_fix.sql	                    |
REM |                                                                       |
REM |    Also the script will create AP_INV_LINES_9080707 with lines        |
REM |    data and AP_TMP_DATA_DRIVER_9080707_BKP and                        |
REM |    AP_INV_LINES_9080707_BKP for backup.                               |
REM |=======================================================================+*/

BEGIN  


FND_File.Put_Line(fnd_file.output,
                   '---------------------------------------------------------');
FND_File.Put_Line(fnd_file.output,
                  'START'||' '||'974149.1'||'     '||
                  to_char(sysdate, 'DD-MON-YYYY:HH24:MI:SS'));


CHECK_COUNT(9080707,l_invoice_id,l_rows);

IF l_rows < l_row_limit and l_rows > 0 THEN



BEGIN
 EXECUTE IMMEDIATE 'DROP TABLE AP_TEMP_DATA_DRIVER_9080707';
EXCEPTION
  WHEN OTHERS THEN
    NULL;
END;


BEGIN



EXECUTE IMMEDIATE 'CREATE TABLE AP_TEMP_DATA_DRIVER_9080707 AS            ' ||
                   ' SELECT AID.INVOICE_ID,AID.INVOICE_DISTRIBUTION_ID,AID.LINE_TYPE_LOOKUP_CODE         ' ||
		   ' FROM ap_invoice_distributions_all aid                      ' ||
		   ' WHERE 1=2';

  
 EXECUTE IMMEDIATE 'INSERT INTO AP_TEMP_DATA_DRIVER_9080707             ' ||
                   ' SELECT AID.INVOICE_ID,AID.INVOICE_DISTRIBUTION_ID,AID.LINE_TYPE_LOOKUP_CODE         ' ||
		   ' FROM ap_invoice_distributions_all aid                      ' ||
		   ' WHERE aid.historical_flag = ''Y''                          ' ||
		   ' AND aid.line_type_lookup_code = ''AWT''                    ' ||
		   ' AND aid.awt_invoice_payment_id  IS NOT NULL                ' ||
		   ' AND aid.parent_reversal_id IS NOT NULL                     ' ||
		   ' AND aid.reversal_flag = ''N''     '||
		   ' AND aid.invoice_id= :1'
		   USING l_invoice_id;


		   

EXCEPTION
WHEN OTHERS THEN

DBMS_OUTPUT.PUT_LINE(SQLERRM);
		   
END;		   

  l_select_list := 'INVOICE_ID,INVOICE_DISTRIBUTION_ID,LINE_TYPE_LOOKUP_CODE';
  l_table_name := 'AP_TEMP_DATA_DRIVER_9080707';
  l_where_clause := 'WHERE 1=1 ORDER BY INVOICE_ID,INVOICE_DISTRIBUTION_ID,LINE_TYPE_LOOKUP_CODE';
  
AP_Acctg_Data_Fix_PKG.Print( 'Below upgraded invoices CREATING TWO DIFF INVOICE LINES IN UPGRADE FOR PAYMENT TIME AWT REVERSALS');  
AP_Acctg_Data_Fix_PKG.Print( 'SOLUTION : Follow note 974149.1');  

DBMS_OUTPUT.PUT_LINE('B4 TABLE');		  

 AP_ACCTG_DATA_FIX_PKG.Print_html_table
    (p_select_list       => l_select_list,
     p_table_in          => l_table_name,
     p_where_in          => l_where_clause,
     P_calling_sequence  => l_calling_sequence);
	 
	 DBMS_OUTPUT.PUT_LINE('AFTER TABLE');		  
	
  PRINT_LINE;				

 ELSIF l_rows > l_row_limit THEN
  AP_Acctg_Data_Fix_PKG.Print( 'More then 100 invoices affected'||
                               'Please follow the note 974149.1 and run this GDF individually');
PRINT_LINE;	 

 END IF; 

FND_File.Put_Line(fnd_file.output,
                  '  END'||' '||'974149.1'||'     '||
                  to_char(sysdate, 'DD-MON-YYYY:HH24:MI:SS'));

EXCEPTION 
      
  WHEN OTHERS THEN
     FND_LOG.STRING(10, 'update_inv_total_tax_amt_sel.sql','Error is : ' || SQLERRM);
     AP_Acctg_Data_Fix_PKG.Print('Error is : ' || SQLERRM);

END ;

--upd_wrng_pay_awt_rev_sel.sql	

/*REM +=======================================================================+
REM | FILENAME                                                              |
REM |     upd_rev_flg_11i_corup_sel.sql				                              |
REM |                                                                       |
REM | ISSUE                                                                 |
REM |   Some of the upgraded invoices are in 'Needs Revalidation' status    | 
REM |   though they are accounted in 11i .The Reversal distributions        | 
REM |   are not having the same amount as the parent distribution , and     | 
REM |   PARENT_REVERSAL_ID and REVERSAL_FLAG are populated.This has lead    | 
REM |   to the corruption of line amounts for these lines with reversal     | 
REM |   in the distribution during the upgrade as the lines amount get      |
REM |   stamped as 0 when the distributions are reversed.                   |
REM +=======================================================================+*/

BEGIN  


FND_File.Put_Line(fnd_file.output,
                   '---------------------------------------------------------');
FND_File.Put_Line(fnd_file.output,
                  'START'||' '||'1063226.1'||'     '||
                  to_char(sysdate, 'DD-MON-YYYY:HH24:MI:SS'));


CHECK_COUNT(9227325,l_invoice_id,l_rows);

IF l_rows < l_row_limit and l_rows > 0 THEN



BEGIN
 EXECUTE IMMEDIATE 'DROP TABLE AP_TEMP_DATA_DRIVER_9227325';
EXCEPTION
  WHEN OTHERS THEN
    NULL;
END;


BEGIN

EXECUTE IMMEDIATE   '  CREATE TABLE AP_TEMP_DATA_DRIVER_9227325 AS        ' || 
  '  SELECT  AIL.INVOICE_ID,AIL.LINE_NUMBER,AIL.HISTORICAL_FLAG,AIL.LINE_TYPE_LOOKUP_CODE    ' || 
  '  FROM ap_invoice_lines_all ail                                         ' || 
  '  WHERE 1=2';
  
 EXECUTE IMMEDIATE   '  INSERT INTO AP_TEMP_DATA_DRIVER_9227325        ' || 
  '  SELECT  AIL.INVOICE_ID,AIL.LINE_NUMBER,AIL.HISTORICAL_FLAG,AIL.LINE_TYPE_LOOKUP_CODE    ' || 
  '  FROM ap_invoice_lines_all ail                                         ' || 
  '  WHERE ail.historical_flag = ''Y''                                     ' || 
  '  AND ail.discarded_flag    = ''Y''                                     ' || 
  '  AND ail.line_type_lookup_code <> ''AWT''                              ' || 
  '  AND ail.amount = 0                                                    ' || 
  '  AND ail.invoice_id=:1                                                 ' || 
  '  AND ail.amount <>   (SELECT SUM(amount)                               ' || 
  '              FROM ap_invoice_distributions_all aid                     ' || 
  '              WHERE ail.invoice_id    = aid.invoice_id                  ' || 
  '              AND ail.line_number     = aid.invoice_line_number         ' || 
  '              AND aid.historical_flag = ''Y''  )                        ' || 
  '  AND NOT EXISTS  (SELECT 1                                             ' || 
  '    FROM ap_invoice_distributions_all aid1                              ' || 
  '    WHERE aid1.invoice_id             = ail.invoice_id                  ' || 
  '    AND aid1.invoice_line_number      = ail.line_number                 ' || 
  '    AND (NVL(aid1.historical_flag,''N'') = ''N'' OR                     ' || 
  '         NVL(aid1.reversal_flag,''N'')  <> ''Y'' ) )                    '
  USING l_invoice_id;


		   

EXCEPTION
WHEN OTHERS THEN
DBMS_OUTPUT.PUT_LINE('IN EXP');
DBMS_OUTPUT.PUT_LINE(SQLERRM);
		   
END;		   

  l_select_list := 'INVOICE_ID,LINE_NUMBER,HISTORICAL_FLAG,LINE_TYPE_LOOKUP_CODE';
  l_table_name := 'AP_TEMP_DATA_DRIVER_9227325';
  l_where_clause := 'WHERE 1=1 ORDER BY INVOICE_ID,LINE_NUMBER,HISTORICAL_FLAG,LINE_TYPE_LOOKUP_CODE ';
  
AP_Acctg_Data_Fix_PKG.Print( 'Below upgraded invoices LINES UPGRADE ISSUE FOR REVERSED DIST WITH DIFF AMTS IN 11I');  
AP_Acctg_Data_Fix_PKG.Print( 'SOLUTION : Follow note 1063226.1 ');  



 AP_ACCTG_DATA_FIX_PKG.Print_html_table
    (p_select_list       => l_select_list,
     p_table_in          => l_table_name,
     p_where_in          => l_where_clause,
     P_calling_sequence  => l_calling_sequence);
	 

	
  PRINT_LINE;				

 ELSIF l_rows > l_row_limit THEN
  AP_Acctg_Data_Fix_PKG.Print( 'More then 100 invoices affected'||
                               'Please follow the note 1063226.1  and run this GDF individually');
PRINT_LINE;	 

 END IF; 

FND_File.Put_Line(fnd_file.output,
                  '  END'||' '||'1063226.1'||'     '||
                  to_char(sysdate, 'DD-MON-YYYY:HH24:MI:SS'));

EXCEPTION 
      
  WHEN OTHERS THEN
     FND_LOG.STRING(10, 'update_inv_total_tax_amt_sel.sql','Error is : ' || SQLERRM);
     AP_Acctg_Data_Fix_PKG.Print('Error is : ' || SQLERRM);

END ;

--upd_rev_flg_11i_corup_sel.sql

/*REM +=======================================================================+
REM | FILENAME                                                              |
REM |     ap_upd_ccid_nr_tax_dist_sel.sql			            |
REM |                                                                       |
REM | ISSUE                                                                 |
REM |   For "TAX" only lines, the non-rec tax distributions                 |
REM |   were getting stamped as  ccid -99                                   |
REM +=======================================================================+*/

BEGIN  

FND_File.Put_Line(fnd_file.output,
                   '---------------------------------------------------------');
FND_File.Put_Line(fnd_file.output,
                  'START'||' '||'1072747.1'||'     '||
                  to_char(sysdate, 'DD-MON-YYYY:HH24:MI:SS'));


CHECK_COUNT(9214370,l_invoice_id,l_rows);


IF l_rows < l_row_limit and l_rows > 0 THEN



BEGIN
 EXECUTE IMMEDIATE 'DROP TABLE AP_TEMP_DATA_DRIVER_9214370';
EXCEPTION
  WHEN OTHERS THEN
    NULL;
END;


BEGIN


  
 EXECUTE IMMEDIATE 'CREATE TABLE AP_TEMP_DATA_DRIVER_9214370 AS                 ' ||
                   ' SELECT ai.INVOICE_ID,ai.INVOICE_NUM         ' ||
		   ' FROM ap_invoices_all ai                                    ' ||
		   ' WHERE 1=2';

EXECUTE IMMEDIATE 'INSERT INTO AP_TEMP_DATA_DRIVER_9214370                ' ||
                   ' SELECT ai.INVOICE_ID,ai.INVOICE_NUM         ' ||
		   ' FROM ap_invoices_all ai                                    ' ||
		   ' WHERE nvl(ai.accts_pay_code_combination_id,-1) = -1        ' ||
		   ' AND nvl(historical_flag,''N'')=''N''                       ' ||
		   ' AND ai.invoice_id=:1'
		   USING l_invoice_id;		   


		   

EXCEPTION
WHEN OTHERS THEN
DBMS_OUTPUT.PUT_LINE('IN EXP');
DBMS_OUTPUT.PUT_LINE(SQLERRM);
		   
END;		   

  l_select_list := 'INVOICE_ID,INVOICE_NUM';
  l_table_name := 'AP_TEMP_DATA_DRIVER_9214370';
  l_where_clause := 'WHERE 1=1 ORDER BY INVOICE_ID,INVOICE_NUM ';
  
AP_Acctg_Data_Fix_PKG.Print( 'Below invoices where Invoices Accounting Fails Due to Missing Liability Account on Invoice Header');  
AP_Acctg_Data_Fix_PKG.Print( 'SOLUTION : Follow note 1072747.1 ');  



 AP_ACCTG_DATA_FIX_PKG.Print_html_table
    (p_select_list       => l_select_list,
     p_table_in          => l_table_name,
     p_where_in          => l_where_clause,
     P_calling_sequence  => l_calling_sequence);
	 

	
  PRINT_LINE;				

 ELSIF l_rows > l_row_limit THEN
  AP_Acctg_Data_Fix_PKG.Print( 'More then 100 invoices affected'||
                               'Please follow the note 1060687.1  and run this GDF individually');
PRINT_LINE;	 

 END IF; 


FND_File.Put_Line(fnd_file.output,
                  '  END'||' '||'1072747.1'||'     '||
                  to_char(sysdate, 'DD-MON-YYYY:HH24:MI:SS'));


EXCEPTION 
      
  WHEN OTHERS THEN
     FND_LOG.STRING(10, 'update_inv_total_tax_amt_sel.sql','Error is : ' || SQLERRM);
     AP_Acctg_Data_Fix_PKG.Print('Error is : ' || SQLERRM);

END ;
--ap_upd_ccid_nr_tax_dist_sel.sql

/*REM +=======================================================================+
REM | FILENAME                                                              |
REM |     ap_inv_val_prb_sel.sql            			            |
REM |                                                                       |
REM | ISSUE                                                                 |
REM |  Invoice validation program is not releasing the lock on the          |
REM |  invoices once the program is error out. Hence as a result            |
REM |  user is not able to do any operation on the locked invoices          |
REM |  Validation Request_id is not NULL though validation is completed     |
REM |  with error.                                                          |     
REM +=======================================================================+*/

BEGIN  

FND_File.Put_Line(fnd_file.output,
                   '---------------------------------------------------------');
FND_File.Put_Line(fnd_file.output,
                  'START'||' '||'1072774.1'||'     '||
                  to_char(sysdate, 'DD-MON-YYYY:HH24:MI:SS'));


CHECK_COUNT(9327208,l_invoice_id,l_rows);

IF l_rows < l_row_limit and l_rows > 0 THEN



BEGIN
 EXECUTE IMMEDIATE 'DROP TABLE AP_TEMP_DATA_DRIVER_9327208';
EXCEPTION
  WHEN OTHERS THEN
    NULL;
END;


BEGIN


EXECUTE IMMEDIATE ' CREATE TABLE AP_TEMP_DATA_DRIVER_9327208   AS                           ' ||
                   ' SELECT ai.INVOICE_ID,ai.INVOICE_NUM,ai.VALIDATION_REQUEST_ID                     ' ||
		           ' FROM ap_invoices_all ai                                         ' ||
				   ' WHERE 1=2';

  
 EXECUTE IMMEDIATE ' INSERT INTO AP_TEMP_DATA_DRIVER_9327208                             ' ||
                   ' SELECT ai.INVOICE_ID,ai.INVOICE_NUM,ai.VALIDATION_REQUEST_ID                     ' ||
		           ' FROM ap_invoices_all ai                                         ' ||
				   ' WHERE ai.validation_request_id IS NOT NULL              ' ||
				   ' AND ai.validation_request_id > 0                        ' ||
				   ' AND ai.invoice_id=:1                                    ' ||
				   ' AND ( EXISTS                                            ' ||
				   '       ( SELECT 1  FROM fnd_concurrent_requests fcr      ' ||
				   '         WHERE fcr.request_id = ai.validation_request_id ' ||
				   '         AND fcr.phase_code = ''C'' )                    ' ||
				   '	  OR NOT EXISTS					     ' ||
				   '       ( SELECT 1 FROM fnd_concurrent_requests fcr       ' ||
				   '       WHERE fcr.request_id = ai.validation_request_id ) ' ||
				   '     )'
				   USING l_invoice_id;                         


		   

EXCEPTION
WHEN OTHERS THEN
DBMS_OUTPUT.PUT_LINE('IN EXP');
DBMS_OUTPUT.PUT_LINE(SQLERRM);
		   
END;		   

  l_select_list := 'INVOICE_ID,INVOICE_NUM,VALIDATION_REQUEST_ID';
  l_table_name := 'AP_TEMP_DATA_DRIVER_9327208';
  l_where_clause := 'WHERE 1=1 ORDER BY INVOICE_ID,INVOICE_NUM,VALIDATION_REQUEST_ID';
  
AP_Acctg_Data_Fix_PKG.Print( 'Below invoices Locked by Invoice Validation Request That had Completed in Error');  
AP_Acctg_Data_Fix_PKG.Print( 'SOLUTION : Follow note 1072774.1 ');  



 AP_ACCTG_DATA_FIX_PKG.Print_html_table
    (p_select_list       => l_select_list,
     p_table_in          => l_table_name,
     p_where_in          => l_where_clause,
     P_calling_sequence  => l_calling_sequence);
	 

	
  PRINT_LINE;				

 ELSIF l_rows > l_row_limit THEN
  AP_Acctg_Data_Fix_PKG.Print( 'More then 100 invoices affected'||
                               'Please follow the note 1072774.1  and run this GDF individually');
PRINT_LINE;	 

 END IF; 

FND_File.Put_Line(fnd_file.output,
                  '  END'||' '||'1072774.1'||'     '||
                  to_char(sysdate, 'DD-MON-YYYY:HH24:MI:SS'));


EXCEPTION 
      
  WHEN OTHERS THEN
     FND_LOG.STRING(10, 'update_inv_total_tax_amt_sel.sql','Error is : ' || SQLERRM);
     AP_Acctg_Data_Fix_PKG.Print('Error is : ' || SQLERRM);

END ;

--ap_inv_val_prb_sel.sql 


/*REM +=======================================================================+
REM | FILENAME                                                              |
REM |     ap_upd_dup_parent_rev_sel.sql				            |
REM |                                                                       |
REM | ISSUE                                                                 |
REM |    For upgraded transactions the parent reversal ids duplicated for   |
REM |    TRV,ERV,TIPV and TERV distributions.                               |
REM +=======================================================================+*/

BEGIN  

FND_File.Put_Line(fnd_file.output,
                   '---------------------------------------------------------');
FND_File.Put_Line(fnd_file.output,
                  'START'||' '||'1072783.1'||'     '||
                  to_char(sysdate, 'DD-MON-YYYY:HH24:MI:SS'));


CHECK_COUNT(9113457,l_invoice_id,l_rows);

IF l_rows < l_row_limit and l_rows > 0 THEN



BEGIN
 EXECUTE IMMEDIATE 'DROP TABLE AP_ITEM_DATA_DRIVER_9113457';
 
 EXECUTE IMMEDIATE 'DROP TABLE AP_TAX_DATA_DRIVER_9113457';

 EXCEPTION
  WHEN OTHERS THEN
    NULL;
END;


BEGIN


  
 EXECUTE IMMEDIATE 'CREATE TABLE AP_ITEM_DATA_DRIVER_9113457 AS            ' ||
                   ' SELECT AID2.INVOICE_DISTRIBUTION_ID,AID2.INVOICE_ID ' ||
		   ' FROM ap_invoice_distributions_all aid,                     ' ||
		   '      ap_invoice_distributions_all aid2                     ' ||
		   ' WHERE aid.parent_reversal_id IN (                          ' ||
		   '    SELECT aid1.parent_reversal_id                          ' ||
		   '    FROM ap_invoice_distributions_all aid1                  ' ||
		   '    WHERE aid1.invoice_id = aid.invoice_id                  ' ||
		   '    AND   aid1.historical_flag = ''Y''                      ' ||
		   '    AND   aid1.parent_reversal_id IS NOT NULL               ' ||
		   '    GROUP BY aid1.parent_reversal_id  HAVING COUNT(*) > 1 ) ' ||
		   ' AND aid.historical_flag = ''Y''                            ' ||
		   ' AND aid.line_type_lookup_code                              ' ||
		   '    IN (''IPV'',''ERV'')                                    ' ||
		   ' AND aid.parent_reversal_id = aid2.parent_reversal_id       ' ||
		   ' AND aid2.historical_flag = ''Y''                           ' ||
		   ' AND aid2.invoice_id = aid.invoice_id                       ' ||
		   ' AND 1=2' ;
		   
 EXECUTE IMMEDIATE 'INSERT INTO  AP_ITEM_DATA_DRIVER_9113457          ' ||
                   ' SELECT AID2.INVOICE_DISTRIBUTION_ID,AID2.INVOICE_ID ' ||
		   ' FROM ap_invoice_distributions_all aid,                     ' ||
		   '      ap_invoice_distributions_all aid2                     ' ||
		   ' WHERE aid.parent_reversal_id IN (                          ' ||
		   '    SELECT aid1.parent_reversal_id                          ' ||
		   '    FROM ap_invoice_distributions_all aid1                  ' ||
		   '    WHERE aid1.invoice_id = aid.invoice_id                  ' ||
		   '    AND   aid1.historical_flag = ''Y''                      ' ||
		   '    AND   aid1.parent_reversal_id IS NOT NULL               ' ||
		   '    GROUP BY aid1.parent_reversal_id  HAVING COUNT(*) > 1 ) ' ||
		   ' AND aid.historical_flag = ''Y''                            ' ||
		   ' AND aid.line_type_lookup_code                              ' ||
		   '    IN (''IPV'',''ERV'')                                    ' ||
		   ' AND aid.parent_reversal_id = aid2.parent_reversal_id       ' ||
		   ' AND aid2.historical_flag = ''Y''                           ' ||
		   ' AND aid2.invoice_id = aid.invoice_id                       '||
		   'AND aid2.invoice_id=:1'
USING l_invoice_id		   ;		   


    

 EXECUTE IMMEDIATE 'CREATE TABLE AP_TAX_DATA_DRIVER_9113457 AS            ' ||
                   ' SELECT AID2.INVOICE_DISTRIBUTION_ID,AID2.INVOICE_ID' ||
		   ' FROM ap_invoice_distributions_all aid,                     ' ||
		   '      ap_invoice_distributions_all aid2                     ' ||
		   ' WHERE aid.parent_reversal_id IN (                          ' ||
		   '    SELECT aid1.parent_reversal_id                          ' ||
		   '    FROM ap_invoice_distributions_all aid1                  ' ||
		   '    WHERE aid1.invoice_id = aid.invoice_id                  ' ||
		   '    AND   aid1.historical_flag = ''Y''                      ' ||
		   '    AND   aid1.parent_reversal_id IS NOT NULL               ' ||
		   '    GROUP BY aid1.parent_reversal_id  HAVING COUNT(*) > 1 ) ' ||
		   ' AND aid.historical_flag = ''Y''                            ' ||
		   ' AND aid.line_type_lookup_code                              ' ||
		   '    IN (''TIPV'',''TERV'',''REC_TAX'',''NONREC_TAX'',''MISCELLANEOUS'',''FREIGHT'' ) ' ||
		   ' AND aid.parent_reversal_id = aid2.parent_reversal_id       ' ||
		   ' AND aid2.historical_flag = ''Y''                           ' ||
		   ' AND aid2.invoice_id = aid.invoice_id                        ' || 
		   ' AND 1=2'; 
		   
 EXECUTE IMMEDIATE 'INSERT INTO AP_TAX_DATA_DRIVER_9113457             ' ||
                   ' SELECT AID2.INVOICE_DISTRIBUTION_ID,AID2.INVOICE_ID' ||
		   ' FROM ap_invoice_distributions_all aid,                     ' ||
		   '      ap_invoice_distributions_all aid2                     ' ||
		   ' WHERE aid.parent_reversal_id IN (                          ' ||
		   '    SELECT aid1.parent_reversal_id                          ' ||
		   '    FROM ap_invoice_distributions_all aid1                  ' ||
		   '    WHERE aid1.invoice_id = aid.invoice_id                  ' ||
		   '    AND   aid1.historical_flag = ''Y''                      ' ||
		   '    AND   aid1.parent_reversal_id IS NOT NULL               ' ||
		   '    GROUP BY aid1.parent_reversal_id  HAVING COUNT(*) > 1 ) ' ||
		   ' AND aid.historical_flag = ''Y''                            ' ||
		   ' AND aid.line_type_lookup_code                              ' ||
		   '    IN (''TIPV'',''TERV'',''REC_TAX'',''NONREC_TAX'',''MISCELLANEOUS'',''FREIGHT'' ) ' ||
		   ' AND aid.parent_reversal_id = aid2.parent_reversal_id       ' ||
		   ' AND aid2.historical_flag = ''Y''                           ' ||
		   ' AND aid2.invoice_id = aid.invoice_id                       ' ||
		   ' AND aid2.invoice_id=:1'
		   USING l_invoice_id;		   

		   

EXCEPTION
WHEN OTHERS THEN
DBMS_OUTPUT.PUT_LINE('IN EXP');
DBMS_OUTPUT.PUT_LINE(SQLERRM);
		   
END;		   

  l_select_list := 'INVOICE_DISTRIBUTION_ID,INVOICE_ID';
  l_table_name := 'AP_ITEM_DATA_DRIVER_9113457';
  l_where_clause := 'WHERE 1=1 ORDER BY INVOICE_DISTRIBUTION_ID,INVOICE_ID';
  
AP_Acctg_Data_Fix_PKG.Print( 'Below invoices getting ORA-01422 Error on Clicking Distribution of Upgraded Invoice');  
AP_Acctg_Data_Fix_PKG.Print( 'SOLUTION : Follow note 1072783.1 ');  



 AP_ACCTG_DATA_FIX_PKG.Print_html_table
    (p_select_list       => l_select_list,
     p_table_in          => l_table_name,
     p_where_in          => l_where_clause,
     P_calling_sequence  => l_calling_sequence);


l_select_list := 'INVOICE_DISTRIBUTION_ID,INVOICE_ID';
  l_table_name := 'AP_TAX_DATA_DRIVER_9113457';
  l_where_clause := 'WHERE 1=1 ORDER BY INVOICE_DISTRIBUTION_ID,INVOICE_ID';
  
AP_Acctg_Data_Fix_PKG.Print( 'Below invoices(TAX LINES) getting ORA-01422 Error on Clicking Distribution of Upgraded Invoice');  
AP_Acctg_Data_Fix_PKG.Print( 'SOLUTION : Follow note 1072783.1 ');  



 AP_ACCTG_DATA_FIX_PKG.Print_html_table
    (p_select_list       => l_select_list,
     p_table_in          => l_table_name,
     p_where_in          => l_where_clause,
     P_calling_sequence  => l_calling_sequence);	 

	
  PRINT_LINE;				

 ELSIF l_rows > l_row_limit THEN
  AP_Acctg_Data_Fix_PKG.Print( 'More then 100 invoices affected'||
                               'Please follow the note 1072774.1  and run this GDF individually');
PRINT_LINE;	 

 END IF; 

FND_File.Put_Line(fnd_file.output,
                  '  END'||' '||'1072783.1'||'     '||
                  to_char(sysdate, 'DD-MON-YYYY:HH24:MI:SS'));


EXCEPTION 
      
  WHEN OTHERS THEN
     FND_LOG.STRING(10, 'update_inv_total_tax_amt_sel.sql','Error is : ' || SQLERRM);
     AP_Acctg_Data_Fix_PKG.Print('Error is : ' || SQLERRM);

END ;


--ap_upd_dup_parent_rev_sel.sql				            


/*REM +=======================================================================+
REM | FILENAME                                                              |
REM |   ap_sync_po_release_id_sel.sql                                       |
REM |                                                                       |
REM | ISSUE                                                                 |
REM |   Application allowed user to match an invoice to Blanket Purchase    |
REM |   Agreements and Planned Purchase Orders without providing the Po     |
REM |   Release Number by specifying other PO details on invoice lines.     |
REM |   Later, when user tries to validate or cancel the invoice,           |
REM |   APP-PO-14144 error message is displayed                             |
REM +=======================================================================+*/

BEGIN  

FND_File.Put_Line(fnd_file.output,
                   '---------------------------------------------------------');
FND_File.Put_Line(fnd_file.output,
                  'START'||' '||'1094274.1'||'     '||
                  to_char(sysdate, 'DD-MON-YYYY:HH24:MI:SS'));


CHECK_COUNT(9231247,l_invoice_id,l_rows);

IF l_rows < l_row_limit and l_rows > 0 THEN



BEGIN
 EXECUTE IMMEDIATE 'DROP TABLE AP_TEMP_DATA_DRIVER_9231247';
EXCEPTION
  WHEN OTHERS THEN
    NULL;
END;


BEGIN

  EXECUTE IMMEDIATE     '  CREATE TABLE AP_TEMP_DATA_DRIVER_9231247 AS                   ' ||
			'  SELECT AI.INVOICE_NUM,                                        ' ||
			'         AIL.INVOICE_ID,                                        ' ||
			'         AIL.LINE_NUMBER,                                       ' ||
			'         AIL.PO_HEADER_ID,                                      ' ||
			'         AIL.PO_LINE_LOCATION_ID,                               ' ||
			'         AIL.PO_RELEASE_ID  OLD_PO_RELEASE_ID,                  ' ||
			'         PLL.PO_RELEASE_ID  NEW_PO_RELEASE_ID                  '  ||
			'    FROM ap_invoices_all       AI,                              ' ||
			'         ap_invoice_lines_all  AIL,                             ' ||
			'         po_line_locations_all PLL,                             ' ||
			'         po_headers_all        PH                               ' ||
			'   WHERE 1=2';
	
  
  EXECUTE IMMEDIATE     '  INSERT INTO AP_TEMP_DATA_DRIVER_9231247           ' ||
			'  SELECT AI.INVOICE_NUM,                                        ' ||
			'         AIL.INVOICE_ID,                                        ' ||
			'         AIL.LINE_NUMBER,                                       ' ||
			'         AIL.PO_HEADER_ID,                                      ' ||
			'         AIL.PO_LINE_LOCATION_ID,                               ' ||
			'         AIL.PO_RELEASE_ID  OLD_PO_RELEASE_ID,                  ' ||
			'         PLL.PO_RELEASE_ID  NEW_PO_RELEASE_ID                  '  ||
			'    FROM ap_invoices_all       AI,                              ' ||
			'         ap_invoice_lines_all  AIL,                             ' ||
			'         po_line_locations_all PLL,                             ' ||
			'         po_headers_all        PH                               ' ||
			'   WHERE AIL.invoice_id             = AI.invoice_id             ' ||
			'     AND AIL.po_header_id           = PH.po_header_id           ' ||
			'     AND ( ( PH.type_lookup_code    = ''BLANKET''               ' ||
			'             AND NVL( PH.global_agreement_flag, ''N'' ) = ''N'' ' ||
			'           )							 ' ||
                        '           OR PH.type_lookup_code = ''PLANNED''     ' ||
			'         )                                                      ' ||
			'     AND pll.line_location_id       = ail.po_line_location_id   ' ||
			'     AND pll.po_release_id          IS NOT NULL                 ' ||
			'     AND ail.po_release_id          IS NULL                     ' ||
			'     AND ai.invoice_id=:1'
			USING l_invoice_id;                      


		   

EXCEPTION
WHEN OTHERS THEN
DBMS_OUTPUT.PUT_LINE('IN EXP');
DBMS_OUTPUT.PUT_LINE(SQLERRM);
		   
END;		   

  l_select_list := 'INVOICE_NUM,INVOICE_ID,LINE_NUMBER,PO_HEADER_ID,PO_LINE_LOCATION_ID,OLD_PO_RELEASE_ID,NEW_PO_RELEASE_ID';
  l_table_name := 'AP_TEMP_DATA_DRIVER_9231247';
  l_where_clause := ' WHERE 1=1 ORDER by INVOICE_NUM,INVOICE_ID,LINE_NUMBER,PO_HEADER_ID,PO_LINE_LOCATION_ID,OLD_PO_RELEASE_ID,NEW_PO_RELEASE_ID';
  
AP_Acctg_Data_Fix_PKG.Print( 'Below invoices are having MISSING PO_RELEASE_ID and GET APP-PO-14144: PO_ACTIONS-065 ERROR ON VALIDATE');  
AP_Acctg_Data_Fix_PKG.Print( 'SOLUTION : Follow Note 1094274.1');  



 AP_ACCTG_DATA_FIX_PKG.Print_html_table
    (p_select_list       => l_select_list,
     p_table_in          => l_table_name,
     p_where_in          => l_where_clause,
     P_calling_sequence  => l_calling_sequence);
	 

	
  PRINT_LINE;				

 ELSIF l_rows > l_row_limit THEN
  AP_Acctg_Data_Fix_PKG.Print( 'More then 100 invoices affected'||
                               'Please follow the note 1094274.1  and run this GDF individually');
PRINT_LINE;	 

 END IF; 

FND_File.Put_Line(fnd_file.output,
                  '  END'||' '||'1094274.1'||'     '||
                  to_char(sysdate, 'DD-MON-YYYY:HH24:MI:SS'));

EXCEPTION 
      
  WHEN OTHERS THEN
     FND_LOG.STRING(10, 'update_inv_total_tax_amt_sel.sql','Error is : ' || SQLERRM);
     AP_Acctg_Data_Fix_PKG.Print('Error is : ' || SQLERRM);

END ;
			            
--ap_sync_po_release_id_sel.sql

/*REM +=======================================================================+
REM * File: ap_duplicate_reversals_sel.sql                                  *
REM * Bug Number: 9341543                                                   *
REM * Issue: Duplicate reversal distributions created for parent reversal   *
REM *        distributions during invoice cancellation. This causes a       *
REM *        DIST VARIANCE hold on the invoice and invoice cannot be        *
REM *        processed.                                                     *
REM *                                                                       *
REM * Description: Script to identify all duplicate distributions for       *
REM *              parent reversal distributions.                           *
REM *                                                                       *
REM +=======================================================================+*/
BEGIN  

FND_File.Put_Line(fnd_file.output,
                   '---------------------------------------------------------');
FND_File.Put_Line(fnd_file.output,
                  'START'||' '||'1094283.1'||'     '||
                  to_char(sysdate, 'DD-MON-YYYY:HH24:MI:SS'));

CHECK_COUNT(9341543,l_invoice_id,l_rows);

IF l_rows < l_row_limit and l_rows > 0 THEN



BEGIN
 EXECUTE IMMEDIATE 'DROP TABLE AP_TEMP_DATA_DRIVER_9341543';
EXCEPTION
  WHEN OTHERS THEN
    NULL;
END;


BEGIN


  EXECUTE IMMEDIATE  'CREATE TABLE AP_TEMP_DATA_DRIVER_9341543 AS (       
            SELECT /* + parallel(AI)*/               
        	AI.INVOICE_ID,              
		AI.TEMP_CANCELLED_AMOUNT,              
		AID.INVOICE_DISTRIBUTION_ID,              
		AID.PARENT_REVERSAL_ID,              
		AID.AMOUNT,              
		AID.LINE_TYPE_LOOKUP_CODE,              
		AID.DETAIL_TAX_DIST_ID,              
		AID.SUMMARY_TAX_LINE_ID              
		  FROM ap_invoices_all AI,              
                     ap_invoice_distributions_all aid,              
                     ap_invoice_lines_all AIL        
		WHERE 1=2)';

  
  EXECUTE IMMEDIATE  'INSERT INTO AP_TEMP_DATA_DRIVER_9341543 ( 
            SELECT /* + parallel(AI)*/               
        	AI.INVOICE_ID,              
		AI.TEMP_CANCELLED_AMOUNT,              
		AID.INVOICE_DISTRIBUTION_ID,              
		AID.PARENT_REVERSAL_ID,              
		AID.AMOUNT,              
		AID.LINE_TYPE_LOOKUP_CODE,              
		AID.DETAIL_TAX_DIST_ID,              
		AID.SUMMARY_TAX_LINE_ID              
		  FROM ap_invoices_all AI,              
                     ap_invoice_distributions_all aid,              
                     ap_invoice_lines_all AIL        
		WHERE AI.invoice_id = AIL.invoice_id          
	        and AIL.invoice_id = aid.invoice_id          
		and ai.invoice_id = aid.invoice_id
                and nvl(ai.historical_flag, ''N'') <> ''Y''		
		and ai.TEMP_CANCELLED_AMOUNT is not null          
		and ai.cancelled_date is null          
		and aid.reversal_flag = ''Y''          
		and aid.parent_reversal_id is not null
        and ai.invoice_id= :1		
		and exists (select 1 from ap_holds_all                       
			where invoice_id = ai.invoice_id                          
			and hold_lookup_code = ''DIST VARIANCE''                         
		       	and nvl(status_flag,''S'') <> ''R'')          
			and exists (select 1 from ap_invoice_distributions_all aid1
				where aid1.invoice_id = ai.invoice_id                         
				and aid1.parent_reversal_id = aid.parent_reversal_id                         
				and aid1.invoice_distribution_id <> aid.invoice_distribution_id))'
				USING l_invoice_id;                    


		   

EXCEPTION
WHEN OTHERS THEN
DBMS_OUTPUT.PUT_LINE('IN EXP');
DBMS_OUTPUT.PUT_LINE(SQLERRM);
		   
END;		   

  l_select_list := 'INVOICE_ID,TEMP_CANCELLED_AMOUNT,INVOICE_DISTRIBUTION_ID,PARENT_REVERSAL_ID,AMOUNT,LINE_TYPE_LOOKUP_CODE,DETAIL_TAX_DIST_ID,SUMMARY_TAX_LINE_ID';  
  l_table_name := 'AP_TEMP_DATA_DRIVER_9341543';
  l_where_clause := ' WHERE 1=1 ORDER by INVOICE_ID,TEMP_CANCELLED_AMOUNT,INVOICE_DISTRIBUTION_ID,PARENT_REVERSAL_ID,AMOUNT,LINE_TYPE_LOOKUP_CODE,DETAIL_TAX_DIST_ID,SUMMARY_TAX_LINE_ID';
  
AP_Acctg_Data_Fix_PKG.Print( 'Below invoices are having  DUPLICATE REVERSAL DISTRIBUTIONS CREATED FOR SINGLE PARENT DIST');  
AP_Acctg_Data_Fix_PKG.Print( 'SOLUTION : Follow Note 1094283.1');  



 AP_ACCTG_DATA_FIX_PKG.Print_html_table
    (p_select_list       => l_select_list,
     p_table_in          => l_table_name,
     p_where_in          => l_where_clause,
     P_calling_sequence  => l_calling_sequence);
	 

	
  PRINT_LINE;				

 ELSIF l_rows > l_row_limit THEN
  AP_Acctg_Data_Fix_PKG.Print( 'More then 100 invoices affected'||
                               'Please follow the note 1094283.1  and run this GDF individually');
PRINT_LINE;	 

 END IF; 

FND_File.Put_Line(fnd_file.output,
                  '  END'||' '||'1094283.1'||'     '||
                  to_char(sysdate, 'DD-MON-YYYY:HH24:MI:SS'));

EXCEPTION 
      
  WHEN OTHERS THEN
     FND_LOG.STRING(10, 'update_inv_total_tax_amt_sel.sql','Error is : ' || SQLERRM);
     AP_Acctg_Data_Fix_PKG.Print('Error is : ' || SQLERRM);

END ;
			            
--ap_duplicate_reversals_sel.sql 

--ap_var_awt_group_id_sel.sql
/*REM +=======================================================================+
REM |    Copyright (c) 2001 Oracle Corporation, Redwood Shores, CA, USA     |
REM |                         All rights reserved.                          |
REM +=======================================================================+
REM | FILENAME                                                              |
REM |     ap_var_awt_group_id_sel.sql                                       |
REM |                                                                       |
REM | ISSUE                                                                 |
REM |   For upgraded variance distributions, awt_group_id is not            |
REM |   getting populated.                                                  |
REM +=======================================================================+*/

BEGIN  

FND_File.Put_Line(fnd_file.output,
                   '---------------------------------------------------------');
FND_File.Put_Line(fnd_file.output,
                  'START'||' '||'1094293.1'||'     '||
                  to_char(sysdate, 'DD-MON-YYYY:HH24:MI:SS'));

CHECK_COUNT(9375004,l_invoice_id,l_rows);

IF l_rows < l_row_limit and l_rows > 0 THEN
BEGIN
 EXECUTE IMMEDIATE 'DROP TABLE AP_TEMP_DATA_DRIVER_9375004';
EXCEPTION
  WHEN OTHERS THEN
    NULL;
END;
BEGIN
  EXECUTE IMMEDIATE  'CREATE TABLE AP_TEMP_DATA_DRIVER_9375004 AS (       
            select /*+ parallel(aid1) */ aid.invoice_id 
               ,aid.line_type_lookup_code 
               ,aid.invoice_distribution_id 
               ,aid.awt_group_id 
               ,aid1.line_type_lookup_code Dist_line_type_lookup_code
               ,aid1.invoice_distribution_id DIST_Invoice_distribution_id 
               ,aid1.awt_group_id DIST_awt_group_id
	       ,aid1.old_distribution_id Dist_old_distribution_id
	       from AP_INVOICE_DISTS_ARCH aid
               ,ap_invoice_distributions_all aid1
         where 1=2)';                    

  EXECUTE IMMEDIATE  'INSERT INTO AP_TEMP_DATA_DRIVER_9375004  
            select /*+ parallel(aid1) */ aid.invoice_id 
               ,aid.line_type_lookup_code 
               ,aid.invoice_distribution_id 
               ,aid.awt_group_id 
               ,aid1.line_type_lookup_code Dist_line_type_lookup_code
               ,aid1.invoice_distribution_id DIST_Invoice_distribution_id 
               ,aid1.awt_group_id DIST_awt_group_id
	       ,aid1.old_distribution_id Dist_old_distribution_id
	       from AP_INVOICE_DISTS_ARCH aid
               ,ap_invoice_distributions_all aid1
         where aid.invoice_id = aid1.invoice_id
           and aid.invoice_distribution_id = aid1.old_distribution_id
           and aid.awt_group_id is not NULL
           and aid1.line_type_lookup_code not in
                (''ITEM'',''REC_TAX'',''NONREC_TAX'',''AWT'')
           and aid1.awt_group_id is NULL
           and nvl(aid1.historical_flag,''N'')=''Y''
		   and aid1.invoice_id=:1'
		   Using l_invoice_id;                    

		   EXCEPTION
WHEN OTHERS THEN
DBMS_OUTPUT.PUT_LINE('IN EXP');
DBMS_OUTPUT.PUT_LINE(SQLERRM);
		   
END;		   

  l_select_list := 'INVOICE_ID,LINE_TYPE_LOOKUP_CODE,INVOICE_DISTRIBUTION_ID,AWT_GROUP_ID,DIST_LINE_TYPE_LOOKUP_CODE,DIST_INVOICE_DISTRIBUTION_ID,DIST_AWT_GROUP_ID,DIST_OLD_DISTRIBUTION_ID' ;  
  l_table_name := 'AP_TEMP_DATA_DRIVER_9375004';
  l_where_clause := ' WHERE 1=1 ORDER by INVOICE_ID,LINE_TYPE_LOOKUP_CODE,INVOICE_DISTRIBUTION_ID,AWT_GROUP_ID,DIST_LINE_TYPE_LOOKUP_CODE,DIST_INVOICE_DISTRIBUTION_ID,DIST_AWT_GROUP_ID,DIST_OLD_DISTRIBUTION_ID';
  
AP_Acctg_Data_Fix_PKG.Print( 'Below invoices are having  Withholding Tax Not Calculated on Variance Distributions Created During Upgrade');  
AP_Acctg_Data_Fix_PKG.Print( 'SOLUTION : Follow Note 1094293.1');  



 AP_ACCTG_DATA_FIX_PKG.Print_html_table
    (p_select_list       => l_select_list,
     p_table_in          => l_table_name,
     p_where_in          => l_where_clause,
     P_calling_sequence  => l_calling_sequence);
	 

	
  PRINT_LINE;				

 ELSIF l_rows > l_row_limit THEN
  AP_Acctg_Data_Fix_PKG.Print( 'More then 100 invoices affected'||
                               'Please follow the note 1094293.1  and run this GDF individually');
PRINT_LINE;	 

 END IF; 

FND_File.Put_Line(fnd_file.output,
                  '  END'||' '||'1094293.1'||'     '||
                  to_char(sysdate, 'DD-MON-YYYY:HH24:MI:SS'));

EXCEPTION 
      
  WHEN OTHERS THEN
     FND_LOG.STRING(10, 'update_inv_total_tax_amt_sel.sql','Error is : ' || SQLERRM);
     AP_Acctg_Data_Fix_PKG.Print('Error is : ' || SQLERRM);

END ;

----ap_var_awt_group_id_sel.sql

----ap_awt_dist_wo_dff_sel.sql
/*REM ***************************************************************************
REM * File: ap_awt_dist_wo_dff_sel.sql                                        *
REM * Bug Number: 9342198                                                     *
REM * Issue: Reversed awt distributions do not have DFF info                  *
REM *        stamped on them while the original onces have.                   *
REM *                                                                         *
REM * Description: Script to take backup of all the reversed                  *
REM *              awt distributions that do not have DFF info                *
REM *              stamped on them while the original onces have.             *
REM * RCA: 8462050                                                            *
REM *                                                                         *
REM * NOTES:                                                                  *
REM *  ap_awt_dist_wo_dff_fix.sql need to be run in order for the invoice to  *
*************************************************************************************/
BEGIN  


FND_File.Put_Line(fnd_file.output,
                   '---------------------------------------------------------');
FND_File.Put_Line(fnd_file.output,
                  'START'||' '||'1152559.1'||'     '||
                  to_char(sysdate, 'DD-MON-YYYY:HH24:MI:SS'));

CHECK_COUNT(9342198,l_invoice_id,l_rows);



IF l_rows < l_row_limit and l_rows > 0 THEN

BEGIN
 EXECUTE IMMEDIATE 'DROP TABLE AP_TEMP_DATA_DRIVER_9342198';
EXCEPTION
  WHEN OTHERS THEN
    NULL;
END;
BEGIN

  EXECUTE IMMEDIATE
      'CREATE TABLE  AP_TEMP_DATA_DRIVER_9342198 AS
       (SELECT AID.invoice_id, AID.invoice_distribution_id, ''Y'' PROCESS_FLAG                 
          FROM ap_invoice_distributions_all AID
         WHERE 1=2)';            

EXECUTE IMMEDIATE
      'INSERT INTO  AP_TEMP_DATA_DRIVER_9342198
       SELECT AID.invoice_id, AID.invoice_distribution_id, ''Y'' PROCESS_FLAG                 
          FROM ap_invoice_distributions_all AID
         WHERE AID.parent_reversal_id         IS NOT NULL
           AND AID.line_type_lookup_code      = ''AWT''
           AND AID.global_attribute_category IS NULL
		   and aid.invoice_id=:1
           AND EXISTS
               (SELECT 1
                  FROM ap_invoice_distributions_all AID1
                 WHERE AID1.invoice_distribution_id   = AID.parent_reversal_id
                   AND AID1.invoice_id                = AID.invoice_id
                   AND AID1.global_attribute_category IS NOT NULL)'
USING l_invoice_id;            
EXCEPTION
WHEN OTHERS THEN
DBMS_OUTPUT.PUT_LINE('IN EXP 9342198');
DBMS_OUTPUT.PUT_LINE(SQLERRM);
		   
END;		   

  l_select_list := 'INVOICE_ID,INVOICE_DISTRIBUTION_ID' ;  
  l_table_name := 'AP_TEMP_DATA_DRIVER_9342198';
  l_where_clause := ' WHERE 1=1 ORDER by INVOICE_ID,INVOICE_DISTRIBUTION_ID';
  
AP_Acctg_Data_Fix_PKG.Print( 'Below invoices are having  Reversed Automatic Withholding Tax (AWT) Distributions Do Not Have Descriptive Flexfield (DFF) Information');  
AP_Acctg_Data_Fix_PKG.Print( 'SOLUTION : Follow Note 1152559.1');  



 AP_ACCTG_DATA_FIX_PKG.Print_html_table
    (p_select_list       => l_select_list,
     p_table_in          => l_table_name,
     p_where_in          => l_where_clause,
     P_calling_sequence  => l_calling_sequence);
	 

	
  PRINT_LINE;				

 ELSIF l_rows > l_row_limit THEN
  AP_Acctg_Data_Fix_PKG.Print( 'More then 100 invoices affected'||
                               'Please follow the note 1152559.1  and run this GDF individually');
PRINT_LINE;	 

 END IF; 


FND_File.Put_Line(fnd_file.output,
                  '  END'||' '||'1152559.1'||'     '||
                  to_char(sysdate, 'DD-MON-YYYY:HH24:MI:SS'));


EXCEPTION 
      
  WHEN OTHERS THEN
     FND_LOG.STRING(10, 'update_inv_total_tax_amt_sel.sql','Error is : ' || SQLERRM);
     AP_Acctg_Data_Fix_PKG.Print('Error is : ' || SQLERRM);
 
END ;
----ap_awt_dist_wo_dff_sel.sql

----ap_upd_txble_amt_crt.sql
/*REM +=======================================================================+
REM | FILENAME                                                              |
REM |     ap_upd_txble_amt_crt.sql				                    |
REM |                                                                       |
REM | ISSUE                                                                 |
REM |   The taxable amount is incorrect for upgraded tax distributions      |
REM |                                                                       |
REM | DESCRIPTION                                                           |
REM |                                                                       |
REM |   Script is to update taxable amount and taxable base amount for      |
REM |   upgraded transactions                                               |
REM |                                                                       |
REM |   this script will create the driver table  AP_TMP_DATA_DRVR_9570464  |       
REM |   which will hold the distributions with incorrect taxable amount     |
==============================================================================*/

BEGIN  

FND_File.Put_Line(fnd_file.output,
                   '---------------------------------------------------------');
FND_File.Put_Line(fnd_file.output,
                  'START'||' '||'1152656.1'||'     '||
                  to_char(sysdate, 'DD-MON-YYYY:HH24:MI:SS'));

CHECK_COUNT(9570464 ,l_invoice_id,l_rows);

IF l_rows < l_row_limit and l_rows > 0 THEN

BEGIN
 EXECUTE IMMEDIATE 'DROP TABLE AP_TMP_DATA_DRVR_9570464';
EXCEPTION
  WHEN OTHERS THEN
    NULL;
END;
BEGIN

 EXECUTE IMMEDIATE   '  CREATE TABLE AP_TMP_DATA_DRVR_9570464 AS           ' || 
  '                     SELECT invoice_id,invoice_distribution_id,         ' || 
  '                           charge_applicable_to_dist_id,taxable_amount, ' || 
  '                           ''Y'' Process_flag  ' || 
  '                        FROM ap_invoice_distributions_all               ' || 
  '                        WHERE 1=2        ' ;


EXECUTE IMMEDIATE 'INSERT INTO AP_TMP_DATA_DRVR_9570464 ' ||
'select aid.invoice_id,aid.invoice_distribution_id,' ||
'       aid.charge_applicable_to_dist_id,aid.taxable_amount,' ||
' ''Y'' ' ||
' from ap_invoice_distributions_all aid,' ||
'     ap_invoice_distributions_all aid_item,' ||
'     ap_invoices_all ai' ||
' where ai.historical_flag = ''Y'' ' ||
' and ai.invoice_id = aid.invoice_id' ||
' and aid.historical_flag = ''Y'' ' ||
' and aid.charge_applicable_to_dist_id is not null' ||
' and aid.line_type_lookup_code in (''TIPV'',''TERV'',''REC_TAX'',''NONREC_TAX'') ' ||
' and aid.invoice_id = aid_item.invoice_id ' ||
' and aid.charge_applicable_to_dist_id = aid_item.invoice_distribution_id ' ||
' and aid_item.amount <> NVL(aid.taxable_amount,aid_item.amount-1)' ||
'and ai.invoice_id=:1' 
USING l_invoice_id;


EXCEPTION
WHEN OTHERS THEN
DBMS_OUTPUT.PUT_LINE('IN EXP 9570464');
DBMS_OUTPUT.PUT_LINE(SQLERRM);
		   
END;		   

  l_select_list := 'INVOICE_ID,INVOICE_DISTRIBUTION_ID,CHARGE_APPLICABLE_TO_DIST_ID,TAXABLE_AMOUNT' ;  
  l_table_name := 'AP_TMP_DATA_DRVR_9570464';
  l_where_clause := ' WHERE 1=1 ORDER by INVOICE_ID,INVOICE_DISTRIBUTION_ID,CHARGE_APPLICABLE_TO_DIST_ID,TAXABLE_AMOUNT';
  
AP_Acctg_Data_Fix_PKG.Print( 'Below invoices are not having Correct Taxable Amount and Base Amount for Upgraded Transctions');  
AP_Acctg_Data_Fix_PKG.Print( 'SOLUTION : Follow Note 1152656.1');  



 AP_ACCTG_DATA_FIX_PKG.Print_html_table
    (p_select_list       => l_select_list,
     p_table_in          => l_table_name,
     p_where_in          => l_where_clause,
     P_calling_sequence  => l_calling_sequence);
	 

	
  PRINT_LINE;				

 ELSIF l_rows > l_row_limit THEN
  AP_Acctg_Data_Fix_PKG.Print( 'More then 100 invoices affected'||
                               'Please follow the note 1152656.1  and run this GDF individually');
PRINT_LINE;	 

 END IF; 

FND_File.Put_Line(fnd_file.output,
                  '  END'||' '||'1152656.1'||'     '||
                  to_char(sysdate, 'DD-MON-YYYY:HH24:MI:SS'));

EXCEPTION 
      
  WHEN OTHERS THEN
     FND_LOG.STRING(10, 'update_inv_total_tax_amt_sel.sql','Error is : ' || SQLERRM);
     AP_Acctg_Data_Fix_PKG.Print('Error is : ' || SQLERRM);

END ;

-----ap_self_corrct_inv_sel.sql
/*REM +=======================================================================+
REM | FILENAME                                                              |
REM |  ap_self_corrct_inv_sel.sql                                          |
REM |                                                                       |
REM | DESCRIPTION                                                           |
REM |  The following selection script will identify all the invoices        |
REM |  which are self corrected.                                            |
REM |  Table AP_TEMP_DATA_DRIVER_9574934 will contain details of all such   |
REM |  invoices.       
=============================================================================*/

BEGIN  


FND_File.Put_Line(fnd_file.output,
                   '---------------------------------------------------------');
FND_File.Put_Line(fnd_file.output,
                  'START'||' '||'1152683.1'||'     '||
                  to_char(sysdate, 'DD-MON-YYYY:HH24:MI:SS'));

CHECK_COUNT(9834746,l_invoice_id,l_rows);



IF l_rows < l_row_limit and l_rows > 0 THEN

BEGIN
 EXECUTE IMMEDIATE 'DROP TABLE AP_TEMP_DATA_DRIVER_9834746';
EXCEPTION
  WHEN OTHERS THEN
    NULL;
END;
BEGIN

EXECUTE IMMEDIATE ' CREATE TABLE AP_TEMP_DATA_DRIVER_9834746'||
                  ' AS '||
                  ' SELECT ail.invoice_id,'||
		  '        ail.line_number,'||
  		  '        ai.invoice_num,'||
		  '       ''Y'' process_flag'||
                  ' FROM  ap_invoice_lines_all ail, ap_invoices_all ai' ||
		  ' WHERE 1=2';
		  
EXECUTE IMMEDIATE ' INSERT INTO AP_TEMP_DATA_DRIVER_9834746'||
                  ' SELECT ail.invoice_id,'||
		  '        ail.line_number,'||
  		  '        ai.invoice_num,'||
		  '       ''Y'' process_flag'||
                  ' FROM  ap_invoice_lines_all ail, ap_invoices_all ai' ||
		  ' WHERE ail.invoice_id = ail.corrected_inv_id'||
		  '   AND ai.invoice_id =  ail.corrected_inv_id'||
		  '   AND nvl(match_type,''NOT_MATCHED'') IN '||
		  '   (''PRICE_CORRECTION'', ''AMOUNT_CORRECTION'', ''NOT_MATCHED'' ) '||
		  ' AND ai.invoice_id=:1'
		  USING l_invoice_id;		  

  
      EXCEPTION
WHEN OTHERS THEN
DBMS_OUTPUT.PUT_LINE('IN EXP 9834746');
DBMS_OUTPUT.PUT_LINE(SQLERRM);
		   
END;		   

  l_select_list := 'INVOICE_ID,LINE_NUMBER,INVOICE_NUM' ;  
  l_table_name := 'AP_TEMP_DATA_DRIVER_9834746';
  l_where_clause := ' WHERE 1=1 ORDER by INVOICE_ID,LINE_NUMBER,INVOICE_NUM';
  
AP_Acctg_Data_Fix_PKG.Print( 'Below invoices are  Unable to Cancel / Reverse Invoice Corrected to Itself');  
AP_Acctg_Data_Fix_PKG.Print( 'SOLUTION : Follow Note 1152683.1');  



 AP_ACCTG_DATA_FIX_PKG.Print_html_table
    (p_select_list       => l_select_list,
     p_table_in          => l_table_name,
     p_where_in          => l_where_clause,
     P_calling_sequence  => l_calling_sequence);
	 

	
  PRINT_LINE;				

 ELSIF l_rows > l_row_limit THEN
  AP_Acctg_Data_Fix_PKG.Print( 'More then 100 invoices affected'||
                               'Please follow the note 1152683.1  and run this GDF individually');
PRINT_LINE;	 

 END IF; 


FND_File.Put_Line(fnd_file.output,
                  '  END'||' '||'1152683.1'||'     '||
                  to_char(sysdate, 'DD-MON-YYYY:HH24:MI:SS'));


EXCEPTION 
      
  WHEN OTHERS THEN
     FND_LOG.STRING(10, 'update_inv_total_tax_amt_sel.sql','Error is : ' || SQLERRM);
     AP_Acctg_Data_Fix_PKG.Print('Error is : ' || SQLERRM);

END ;

------ap_self_corrct_inv_sel.sql

-----ap_prepay_triplicate_s.sql 
/*REM +=======================================================================+
REM | FILENAME                                                              |
REM |                                                                       |
REM | DESCRIPTION                                                           |
REM |   GDF for prepayment triplicated accounting                           |
REM +=======================================================================+*/

BEGIN  


FND_File.Put_Line(fnd_file.output,
                   '---------------------------------------------------------');
FND_File.Put_Line(fnd_file.output,
                  'START'||' '||'9253530'||'     '||
                  to_char(sysdate, 'DD-MON-YYYY:HH24:MI:SS'));

CHECK_COUNT(9253530,l_invoice_id,l_rows);


IF l_rows < l_row_limit and l_rows > 0 THEN

BEGIN
 EXECUTE IMMEDIATE 'DROP TABLE AP_TEMP_DATA_DRIVER_9253530';
EXCEPTION
  WHEN OTHERS THEN
    NULL;
END;
BEGIN

EXECUTE IMMEDIATE ' CREATE TABLE AP_TEMP_DATA_DRIVER_9253530'||
                  ' AS '||
                   ' SELECT ai.invoice_id, '||
       '        ai.invoice_num, '||
       '        ai.invoice_type_lookup_code, '||
       '        ai.invoice_date, '||
       '        ai.invoice_amount, '||
       '        asu.vendor_name, '||
       '        assi.vendor_site_code, '||
       '        xe.event_id, '||
       '        xe.event_type_code, '||
       '        apph.prepay_history_id, '||
       '        apph.invoice_line_number, '||
       '        apph.prepay_invoice_id, '||
       '        ai_prepay.invoice_num prepay_invoice_num, '||
       '        apph.prepay_line_num, '||
       '        dist_sum.amt prepay_appl_amt, '||
       '        acct_sum.amt prepay_acct_amt, '||
       '        ai.org_id, '||
       '        ai.set_of_books_id, '||
       '        ''Y'' process_flag '||
       '   FROM xla_events xe, '||
       '        xla_transaction_entities_upg xte, '||
       '        ap_prepay_history_all apph, '||
       '        ap_invoices_all ai, '||
       '        ap_invoices_all ai_prepay, '||
       '        ap_suppliers asu, '||
       '        ap_supplier_sites_all assi, '||
       '        (SELECT DECODE(sum(aid.amount), 0, 1,sum(aid.amount))  amt, '||
       '                aid.accounting_event_id '||
       '           FROM ap_invoice_distributions_all aid '||
       '          WHERE aid.line_type_lookup_code IN (''PREPAY'',''REC_TAX'',''NONREC_TAX'') '||
       '            AND aid.prepay_distribution_id IS NOT NULL '||
       '          GROUP BY aid.accounting_event_id '||
       '        ) dist_sum, '||
       '        (SELECT sum(nvl(xal.entered_cr, 0) - nvl(xal.entered_dr, 0)) amt, '||
       '              xe.event_id, '||
       '              xah.ledger_id '||
       '         FROM xla_ae_lines xal, '||
       '              xla_ae_headers xah, '||
       '              xla_events xe, '||
       '              xla_transaction_entities_upg xte '||
       '        WHERE xal.application_id =200 '||
       '          AND xah.application_id = 200 '||
       '          AND xe.application_id = 200 '||
       '          AND xal.ae_header_id = xah.ae_header_id '||
       '          AND xah.event_id = xe.event_id '||
       '          AND xe.entity_id = xte.entity_id '||
       '          AND xte.entity_code = ''AP_INVOICES'' '||
       '          AND xte.ledger_id = xah.ledger_id '||
       '          AND xal.accounting_class_code = ''PREPAID_EXPENSE'' '||
       '          AND xe.event_type_code IN (''PREPAYMENT APPLIED'',''PREPAYMENT UNAPPLIED'') '||
       '        GROUP BY xe.event_id, '||
       '                  xah.ledger_id '||
       '        ) acct_sum '||
       '   WHERE 1=2 ';
	   
	   EXECUTE IMMEDIATE ' INSERT INTO AP_TEMP_DATA_DRIVER_9253530 '||
                  ' SELECT ai.invoice_id, '||
       '        ai.invoice_num, '||
       '        ai.invoice_type_lookup_code, '||
       '        ai.invoice_date, '||
       '        ai.invoice_amount, '||
       '        asu.vendor_name, '||
       '        assi.vendor_site_code, '||
       '        xe.event_id, '||
       '        xe.event_type_code, '||
       '        apph.prepay_history_id, '||
       '        apph.invoice_line_number, '||
       '        apph.prepay_invoice_id, '||
       '        ai_prepay.invoice_num prepay_invoice_num, '||
       '        apph.prepay_line_num, '||
       '        dist_sum.amt prepay_appl_amt, '||
       '        acct_sum.amt prepay_acct_amt, '||
       '        ai.org_id, '||
       '        ai.set_of_books_id, '||
       '        ''Y'' process_flag '||
       '   FROM xla_events xe, '||
       '        xla_transaction_entities_upg xte, '||
       '        ap_prepay_history_all apph, '||
       '        ap_invoices_all ai, '||
       '        ap_invoices_all ai_prepay, '||
       '        ap_suppliers asu, '||
       '        ap_supplier_sites_all assi, '||
       '        (SELECT DECODE(sum(aid.amount), 0, 1,sum(aid.amount))  amt, '||
       '                aid.accounting_event_id '||
       '           FROM ap_invoice_distributions_all aid '||
       '          WHERE aid.line_type_lookup_code IN (''PREPAY'',''REC_TAX'',''NONREC_TAX'') '||
       '            AND aid.prepay_distribution_id IS NOT NULL '||
       '          GROUP BY aid.accounting_event_id '||
       '        ) dist_sum, '||
       '        (SELECT sum(nvl(xal.entered_cr, 0) - nvl(xal.entered_dr, 0)) amt, '||
       '              xe.event_id, '||
       '              xah.ledger_id '||
       '         FROM xla_ae_lines xal, '||
       '              xla_ae_headers xah, '||
       '              xla_events xe, '||
       '              xla_transaction_entities_upg xte '||
       '        WHERE xal.application_id =200 '||
       '          AND xah.application_id = 200 '||
       '          AND xe.application_id = 200 '||
       '          AND xal.ae_header_id = xah.ae_header_id '||
       '          AND xah.event_id = xe.event_id '||
       '          AND xe.entity_id = xte.entity_id '||
       '          AND xte.entity_code = ''AP_INVOICES'' '||
       '          AND xte.ledger_id = xah.ledger_id '||
       '          AND xal.accounting_class_code = ''PREPAID_EXPENSE'' '||
       '          AND xe.event_type_code IN (''PREPAYMENT APPLIED'',''PREPAYMENT UNAPPLIED'') '||
       '        GROUP BY xe.event_id, '||
       '                  xah.ledger_id '||
       '        ) acct_sum '||
       '   WHERE xe.application_id = 200 '||
       '     AND xe.event_type_code IN (''PREPAYMENT APPLIED'',''PREPAYMENT UNAPPLIED'') '||
       '     AND xe.event_status_code = ''P'' '||
       '     AND xe.event_id = dist_sum.accounting_event_id '||
       '     AND xe.event_id = acct_sum.event_id '||
       '     AND abs(abs(acct_sum.amt)/abs(dist_sum.amt)) > 2 '||
       '     AND xe.event_id = apph.accounting_event_id '||
       '     AND apph.prepay_invoice_id = ai_prepay.invoice_id '||
       '     AND xte.application_id = 200 '||
       '     AND xe.entity_id = xte.entity_id '||
       '     AND xte.entity_code = ''AP_INVOICES'' '||
       '     AND nvl(xte.source_id_int_1, -99) = ai.invoice_id '||
       '     AND ai.vendor_id = asu.vendor_id(+) '||
       '     AND ai.vendor_site_id = assi.vendor_site_id(+) 
	   and ai.invoice_id=:1'
	   USING l_invoice_id;
	   
	   
  
      EXCEPTION
WHEN OTHERS THEN
DBMS_OUTPUT.PUT_LINE('IN EXP 9253530');
DBMS_OUTPUT.PUT_LINE(SQLERRM);
		   
END;		   

  l_select_list := 'INVOICE_ID,INVOICE_NUM,INVOICE_TYPE_LOOKUP_CODE,EVENT_ID' ;  
  l_table_name := 'AP_TEMP_DATA_DRIVER_9253530';
  l_where_clause := ' WHERE 1=1 ORDER by INVOICE_ID,INVOICE_NUM,INVOICE_TYPE_LOOKUP_CODE,EVENT_ID';
  
AP_Acctg_Data_Fix_PKG.Print( 'Below invoices where PREPAYMENT ACCOUNTED AMOUNT TRIPLICATED');  
AP_Acctg_Data_Fix_PKG.Print( 'SOLUTION : Follow Note 1179414.1');  



 AP_ACCTG_DATA_FIX_PKG.Print_html_table
    (p_select_list       => l_select_list,
     p_table_in          => l_table_name,
     p_where_in          => l_where_clause,
     P_calling_sequence  => l_calling_sequence);
	 

	
  PRINT_LINE;				

 ELSIF l_rows > l_row_limit THEN
  AP_Acctg_Data_Fix_PKG.Print( 'More then 100 invoices affected'||
                               'Please follow the note 1179414.1  and run this GDF individually');
PRINT_LINE;	 

 END IF; 

FND_File.Put_Line(fnd_file.output,
                  '  END'||' '||'9253530'||'     '||
                  to_char(sysdate, 'DD-MON-YYYY:HH24:MI:SS'));

EXCEPTION 
      
  WHEN OTHERS THEN
     FND_LOG.STRING(10, '9253530l','Error is : ' || SQLERRM);
     AP_Acctg_Data_Fix_PKG.Print('Error is : ' || SQLERRM);

END ;

------ap_prepay_triplicate_s.sql 
-----ap_base_amt_zero_sel.sql 
/*REM +=======================================================================+
REM | FILENAME                                                              |
REM |     ap_base_amt_zero_sel.sql                                       |
REM |                                                                       |
REM | DESCRIPTION                                                           |
REM |  This Script is used to select all the Invoice Distributions and      |
REM |  their evnets whose base amount is zero and amount is non zero for    |
REM |  upgraded invoices                                                    |  
REM +=======================================================================+*/

BEGIN  

FND_File.Put_Line(fnd_file.output,
                   '---------------------------------------------------------');
FND_File.Put_Line(fnd_file.output,
                  'START'||' '||'1188863.1'||'     '||
                  to_char(sysdate, 'DD-MON-YYYY:HH24:MI:SS'));

CHECK_COUNT(9930098,l_invoice_id,l_rows);



IF l_rows < l_row_limit and l_rows > 0 THEN

BEGIN
 EXECUTE IMMEDIATE 'DROP TABLE AP_TEMP_DATA_DRIVER_9930098';
EXCEPTION
  WHEN OTHERS THEN
    NULL;
END;
BEGIN

EXECUTE IMMEDIATE ' CREATE TABLE AP_TEMP_DATA_DRIVER_9930098 as
                   select distinct aid.invoice_id , aid.invoice_distribution_id , aid.accounting_event_id 
                   from ap_invoice_distributions_all aid , ap_invoices_all ai
                    where 1=2';
					 
EXECUTE IMMEDIATE ' INSERT INTO AP_TEMP_DATA_DRIVER_9930098
                   select distinct aid.invoice_id , aid.invoice_distribution_id , aid.accounting_event_id 
                   from ap_invoice_distributions_all aid , ap_invoices_all ai
                    where aid.invoice_id = ai.invoice_id
		            and ai.exchange_rate is NULL
		            and aid.amount <> 0
                     and aid.base_amount = 0
                     and aid.historical_flag= ''Y'' ';					 

  
      EXCEPTION
WHEN OTHERS THEN
DBMS_OUTPUT.PUT_LINE('IN EXP 9930098');
DBMS_OUTPUT.PUT_LINE(SQLERRM);
		   
END;		   

  l_select_list := 'INVOICE_ID,INVOICE_DISTRIBUTION_ID,ACCOUNTING_EVENT_ID' ;  
  l_table_name := 'AP_TEMP_DATA_DRIVER_9930098';
  l_where_clause := ' WHERE 1=1 ORDER by INVOICE_ID,INVOICE_DISTRIBUTION_ID,ACCOUNTING_EVENT_ID';
  
AP_Acctg_Data_Fix_PKG.Print( 'Below invoices are having amount is non zero and base amount 0 on tax dist after upgrade');  
AP_Acctg_Data_Fix_PKG.Print( 'SOLUTION : Follow Note 1188863.1');  



 AP_ACCTG_DATA_FIX_PKG.Print_html_table
    (p_select_list       => l_select_list,
     p_table_in          => l_table_name,
     p_where_in          => l_where_clause,
     P_calling_sequence  => l_calling_sequence);
	 

	
  PRINT_LINE;				

 ELSIF l_rows > l_row_limit THEN
  AP_Acctg_Data_Fix_PKG.Print( 'More then 100 invoices affected'||
                               'Please follow the note 1188863.1  and run this GDF individually');
PRINT_LINE;	 

 END IF; 

FND_File.Put_Line(fnd_file.output,
                  '  END'||' '||'1188863.1'||'     '||
                  to_char(sysdate, 'DD-MON-YYYY:HH24:MI:SS'));

EXCEPTION 
      
  WHEN OTHERS THEN
     FND_LOG.STRING(10, '9930098','Error is : ' || SQLERRM);
     AP_Acctg_Data_Fix_PKG.Print('Error is : ' || SQLERRM);
 
END ;

------ap_base_amt_zero_sel.sql 


-----AP_DUP_PMT_AWT_DISTS_SEL.sql  
/*REM +=======================================================================+
REM | FILENAME                                                              |
REM |     AP_DUP_PMT_AWT_DISTS_SEL.sql                                      |
REM |                                                                       |
REM | DESCRIPTION                                                           |
REM |     This GDF will identify all duplicate AWT distributions            |
REM |     created during payment time.                                      |
REM +=======================================================================+*/
BEGIN  


FND_File.Put_Line(fnd_file.output,
                   '---------------------------------------------------------');
FND_File.Put_Line(fnd_file.output,
                  'START'||' '||'1188825.1'||'     '||
                  to_char(sysdate, 'DD-MON-YYYY:HH24:MI:SS'));

CHECK_COUNT(9709414,l_invoice_id,l_rows);



IF l_rows < l_row_limit and l_rows > 0 THEN

BEGIN
 EXECUTE IMMEDIATE 'DROP TABLE AP_TEMP_DATA_DRIVER_9709414';
EXCEPTION
  WHEN OTHERS THEN
    NULL;
END;
BEGIN

EXECUTE IMMEDIATE ' CREATE TABLE AP_TEMP_DATA_DRIVER_9709414   as
                   select aid.invoice_id,
               aid.invoice_distribution_id,
               aid.invoice_line_number,
               aid.distribution_line_number,
			   aid.accounting_event_id,
			   aid.posted_flag,
               aid.org_id               
          from ap_invoice_distributions_all aid,
               ap_system_parameters_all asp		  
         where 1=2';
		   
EXECUTE IMMEDIATE ' INSERT INTO AP_TEMP_DATA_DRIVER_9709414   
                   select aid.invoice_id,
               aid.invoice_distribution_id,
               aid.invoice_line_number,
               aid.distribution_line_number,
			   aid.accounting_event_id,
			   aid.posted_flag,
               aid.org_id
              from ap_invoice_distributions_all aid,
               ap_system_parameters_all asp		  
         where aid.line_type_lookup_code = ''AWT''
		   and aid.awt_flag = ''A''
		   and aid.awt_invoice_payment_id is null
		   and aid.historical_flag is null
		   and aid.org_id = asp.org_id
		   and asp.create_awt_dists_type = ''PAYMENT''
		   and aid.invoice_id=:1'
		   using l_invoice_id;		   

  
      EXCEPTION
WHEN OTHERS THEN
DBMS_OUTPUT.PUT_LINE('IN EXP 9930098');
DBMS_OUTPUT.PUT_LINE(SQLERRM);
		   
END;		   

  l_select_list := 'INVOICE_ID,INVOICE_DISTRIBUTION_ID,INVOICE_LINE_NUMBER,DISTRIBUTION_LINE_NUMBER,ACCOUNTING_EVENT_ID' ;  
  l_table_name := 'AP_TEMP_DATA_DRIVER_9709414';
  l_where_clause := ' WHERE 1=1 ORDER by INVOICE_ID,INVOICE_DISTRIBUTION_ID,INVOICE_LINE_NUMBER,DISTRIBUTION_LINE_NUMBER,ACCOUNTING_EVENT_ID';
  
AP_Acctg_Data_Fix_PKG.Print( 'Below invoices are duplicate AWT Distributions Created During Payment');  
AP_Acctg_Data_Fix_PKG.Print( 'SOLUTION : Follow Note 1188825.1');  



 AP_ACCTG_DATA_FIX_PKG.Print_html_table
    (p_select_list       => l_select_list,
     p_table_in          => l_table_name,
     p_where_in          => l_where_clause,
     P_calling_sequence  => l_calling_sequence);
	 

	
  PRINT_LINE;				

 ELSIF l_rows > l_row_limit THEN
  AP_Acctg_Data_Fix_PKG.Print( 'More then 100 invoices affected'||
                               'Please follow the note 1188825.1  and run this GDF individually');
PRINT_LINE;	 

 END IF; 

FND_File.Put_Line(fnd_file.output,
                  '  END'||' '||'1188825.1'||'     '||
                  to_char(sysdate, 'DD-MON-YYYY:HH24:MI:SS'));

EXCEPTION 
      
  WHEN OTHERS THEN
     FND_LOG.STRING(10, '9709414','Error is : ' || SQLERRM);
     AP_Acctg_Data_Fix_PKG.Print('Error is : ' || SQLERRM);

END ;

---AP_DUP_PMT_AWT_DISTS_SEL.sql 

--ap_prep_apld_noitmdist_sel.sql  
/*REM +=======================================================================+
REM | FILENAME                                                              |
REM |     ap_prep_apld_noitmdist_sel.sql                                    |
REM |                                                                       |
REM | DESCRIPTION                                                           |
REM |     This script will select cancelled invoices                        |
REM |     having no item distributions and prepayment                       |
REM |     is applied on the invoice.                                        |                        
REM +=======================================================================+*/

BEGIN  


FND_File.Put_Line(fnd_file.output,
                   '---------------------------------------------------------');
FND_File.Put_Line(fnd_file.output,
                  'START'||' '||'9767397'||'     '||
                  to_char(sysdate, 'DD-MON-YYYY:HH24:MI:SS'));

CHECK_COUNT(9767397,l_invoice_id,l_rows);



IF l_rows < l_row_limit and l_rows > 0 THEN

BEGIN
 EXECUTE IMMEDIATE 'DROP TABLE AP_TEMP_DATA_DRIVER_9767397';
EXCEPTION
  WHEN OTHERS THEN
    NULL;
END;
BEGIN

EXECUTE IMMEDIATE
'CREATE TABLE AP_TEMP_DATA_DRIVER_9767397  AS  
        SELECT DISTINCT i.invoice_num ,
                       aid.invoice_id,
                       aid.invoice_line_number,
                       aid.invoice_distribution_id,
		               aid.parent_reversal_id,
                       aid.accounting_event_id
        FROM ap_invoices_all i ,
             ap_invoice_distributions_all aid,
             xla_events xe
        WHERE 1=2';
  
  
  EXECUTE IMMEDIATE
'INSERT INTO AP_TEMP_DATA_DRIVER_9767397 
        SELECT DISTINCT i.invoice_num ,
                       aid.invoice_id,
                       aid.invoice_line_number,
                       aid.invoice_distribution_id,
		               aid.parent_reversal_id,
                       aid.accounting_event_id
        FROM ap_invoices_all i ,
             ap_invoice_distributions_all aid,
             xla_events xe
        WHERE aid.invoice_id             = i.invoice_id
         AND aid.prepay_distribution_id IS NOT NULL
         AND aid.accounting_event_id     = xe.event_id (+)
         AND NVL(aid.posted_flag, ''N'')  <> ''Y''
         AND NVL(aid.reversal_flag, ''N'') = ''Y''
         AND NVL(xe.application_id, -99)           = 200
         AND NVL(xe.event_status_code, ''N'')   <> ''P''
         AND i.cancelled_date           IS NOT NULL
         AND i.invoice_amount            = 0
		 AND i.invoice_id=:1
         AND EXISTS
            (SELECT 1
               FROM ap_invoice_distributions_all aid1
              WHERE aid1.invoice_id = aid.invoice_id
                AND aid1.prepay_distribution_id IS NOT NULL
                AND NVL(aid1.reversal_flag, ''N'') = ''Y''
                AND (aid.parent_reversal_id 
                     = aid1.invoice_distribution_id
                     OR aid.invoice_distribution_id
                     = aid1.parent_reversal_id)
                AND NVL(aid1.posted_flag, ''N'') <> ''Y''                                                  
	    )
         AND NOT EXISTS
            (SELECT 1
               FROM ap_invoice_distributions_all aid2
              WHERE aid2.invoice_id           = i.invoice_id
                AND aid2.prepay_distribution_id IS NULL)	 
       ORDER BY aid.invoice_id'
	   USING l_invoice_id;

      EXCEPTION
WHEN OTHERS THEN
DBMS_OUTPUT.PUT_LINE('IN EXP 9767397');
DBMS_OUTPUT.PUT_LINE(SQLERRM);
		   
END;		   

 l_select_list := 'INVOICE_NUM,INVOICE_ID,INVOICE_LINE_NUMBER,INVOICE_DISTRIBUTION_ID,PARENT_REVERSAL_ID,ACCOUNTING_EVENT_ID' ;  
  l_table_name := 'AP_TEMP_DATA_DRIVER_9767397';
  l_where_clause := 'WHERE 1=1 ORDER BY INVOICE_NUM,INVOICE_ID,INVOICE_LINE_NUMBER,INVOICE_DISTRIBUTION_ID,PARENT_REVERSAL_ID,ACCOUNTING_EVENT_ID';
  
AP_Acctg_Data_Fix_PKG.Print( 'Below invoices are having unaccounted prepay events for cancelled invoices having no item dists');  
AP_Acctg_Data_Fix_PKG.Print( 'SOLUTION : Follow Note 1194913.1');  



 AP_ACCTG_DATA_FIX_PKG.Print_html_table
    (p_select_list       => l_select_list,
     p_table_in          => l_table_name,
     p_where_in          => l_where_clause,
     P_calling_sequence  => l_calling_sequence);
	 

	
  PRINT_LINE;				

 ELSIF l_rows > l_row_limit THEN
  AP_Acctg_Data_Fix_PKG.Print( 'More then 100 invoices affected'||
                               'Please follow the note 1194913.1  and run this GDF individually');
PRINT_LINE;	 

 END IF; 

FND_File.Put_Line(fnd_file.output,
                  '  END'||' '||'9767397'||'     '||
                  to_char(sysdate, 'DD-MON-YYYY:HH24:MI:SS'));

EXCEPTION 
      
  WHEN OTHERS THEN
     FND_LOG.STRING(10, '1194913.1','Error is : ' || SQLERRM);
     AP_Acctg_Data_Fix_PKG.Print('Error is : ' || SQLERRM);

END ;

---ap_prep_apld_noitmdist_sel.sql 



--ap_awt_on_prepay_sel.sql                                              
/*REM +===========================================================================+
REM | FILENAME                                                                  |
REM |     ap_awt_on_prepay_sel.sql                                              |
REM |                                                                           |
REM | DESCRIPTION                                                               |
REM |     This script will select transaction data                              |
REM |     which have AWT distributions created due to                           |
REM |     prepayment application. If the AWT distributions                      |
REM |     related to the item line are posted, then we will                     |
REM |     select all those events which needs undo accounting.                  |
REM +===========================================================================+
*/
BEGIN  
FND_File.Put_Line(fnd_file.output,
                   '---------------------------------------------------------');
FND_File.Put_Line(fnd_file.output,
                  'START'||' '||'1264239.1'||'     '||
                  to_char(sysdate, 'DD-MON-YYYY:HH24:MI:SS'));

CHECK_COUNT(9724485,l_invoice_id,l_rows);



IF l_rows < l_row_limit and l_rows > 0 THEN

BEGIN
 EXECUTE IMMEDIATE 'DROP TABLE AP_TEMP_DATA_DRIVER_9724485';
EXCEPTION
  WHEN OTHERS THEN
    NULL;
END;
BEGIN

l_sql_stmt :='CREATE TABLE ap_temp_data_driver_9724485  AS '||
                'SELECT DISTINCT ai.invoice_num,'||
                '       aid_awt.invoice_id,'||
                '       ai.invoice_currency_code,'||
                '       aid_awt.org_id '||
                '  FROM ap_invoice_distributions_all aid_awt, '||
                '       ap_invoice_distributions_all aid_prepay, '||
                '       xla_events xe, '||
                '       ap_invoices_all ai '||
                ' WHERE 1=2 '; 
Execute Immediate l_sql_stmt;							
  l_sql_stmt :=' INSERT INTO ap_temp_data_driver_9724485  '||
                'SELECT DISTINCT ai.invoice_num,'||
                '       aid_awt.invoice_id,'||
                '       ai.invoice_currency_code,'||
                '       aid_awt.org_id '||
                '  FROM ap_invoice_distributions_all aid_awt, '||
                '       ap_invoice_distributions_all aid_prepay, '||
                '       xla_events xe, '||
                '       ap_invoices_all ai '||
                ' WHERE aid_prepay.invoice_id = aid_awt.invoice_id '||
                '   AND ai.invoice_id = aid_awt.invoice_id '||
                '   AND aid_prepay.invoice_distribution_id '||
                '       = aid_awt.awt_related_id '||
				'   AND aid_awt.invoice_id=:1 '||
                '   AND aid_prepay.prepay_distribution_id IS NOT NULL '||
                '   AND xe.event_id = aid_awt.accounting_event_id '||
                '   AND xe.event_status_code IN (''U'',''I'') '||
                '   AND xe.application_id = 200 '||
                '   AND NVL(aid_awt.posted_flag,''N'')  <>''Y'' ';  
				
Execute Immediate l_sql_stmt USING l_invoice_id;				
      EXCEPTION
WHEN OTHERS THEN
DBMS_OUTPUT.PUT_LINE('IN EXP 1264239.1');
DBMS_OUTPUT.PUT_LINE(SQLERRM);
		   
END;		   

 l_select_list := 'INVOICE_NUM,INVOICE_ID,INVOICE_CURRENCY_CODE,ORG_ID' ;  
  l_table_name := 'AP_TEMP_DATA_DRIVER_9724485';
  l_where_clause := 'WHERE 1=1 ORDER BY INVOICE_NUM,INVOICE_ID,INVOICE_CURRENCY_CODE,ORG_ID';
  
AP_Acctg_Data_Fix_PKG.Print( 'Below invoices are Payment acctg failing due to awt dists created by prepayment application ');  
AP_Acctg_Data_Fix_PKG.Print( 'SOLUTION : Follow Note 1264239.1');  



 AP_ACCTG_DATA_FIX_PKG.Print_html_table
    (p_select_list       => l_select_list,
     p_table_in          => l_table_name,
     p_where_in          => l_where_clause,
     P_calling_sequence  => l_calling_sequence);
	 

	
  PRINT_LINE;				

 ELSIF l_rows > l_row_limit THEN
  AP_Acctg_Data_Fix_PKG.Print( 'More then 100 invoices affected'||
                               'Please follow the note 1264239.1  and run this GDF individually');
PRINT_LINE;	 

 END IF; 

FND_File.Put_Line(fnd_file.output,
                  '  END'||' '||'1264239.1'||'     '||
                  to_char(sysdate, 'DD-MON-YYYY:HH24:MI:SS'));

EXCEPTION 
      
  WHEN OTHERS THEN
     FND_LOG.STRING(10, '1264239.1','Error is : ' || SQLERRM);
     AP_Acctg_Data_Fix_PKG.Print('Error is : ' || SQLERRM);

END ;

--ap_awt_on_prepay_sel.sql




--ap_func_curr_inv_with_base_amt_sel.sql
/*REM +=======================================================================+
REM | FILENAME                                                              |
REM |     ap_func_curr_inv_with_base_amt_sel.sql                            |
REM |                                                                       |
REM | DESCRIPTION                                                           |
REM |        Base amount is populated for functional currency invoices      |
REM |        which are created through IMPORT/quick invoicing.              |
REM |        This causes wrong accounting entries to be created.            |
REM +=======================================================================+*/

BEGIN  

FND_File.Put_Line(fnd_file.output,
                   '---------------------------------------------------------');
FND_File.Put_Line(fnd_file.output,
                  'START'||' '||'1272497.1'||'     '||
                  to_char(sysdate, 'DD-MON-YYYY:HH24:MI:SS'));

CHECK_COUNT(9884253,l_invoice_id,l_rows);



IF l_rows < l_row_limit and l_rows > 0 THEN

BEGIN
 EXECUTE IMMEDIATE 'DROP TABLE AP_TEMP_DATA_DRIVER_9884253';
EXCEPTION
  WHEN OTHERS THEN
    NULL;
END;
BEGIN

         EXECUTE IMMEDIATE  'Create table AP_TEMP_DATA_DRIVER_9884253
                    as
                    Select ai.invoice_num,
                           ai.invoice_id,
                           aid.invoice_line_number,
                           ai.invoice_type_lookup_code "INVOICE_TYPE",
                           ai.source,
                           aid.posted_flag,
                           asp.base_currency_code "BASE_CURRENCY",
                           ai.invoice_currency_code "INVOICE_CURRENCY",
                           ai.exchange_rate,
                           ai.exchange_rate_type,
                           ai.exchange_date,
                           ai.invoice_amount,
                           ai.base_amount "INVOICE_BASE_AMT",
                           aid.accounting_event_id event_id,
                           aid.amount "DISTRIBUTION_AMT",
                           aid.base_amount "DIST_BASE_AMT",
			   decode(aid.posted_flag,''Y'',''Accounted'',''Not Accounted'') "ACCOUNTING_STATUS",
                           aid.invoice_distribution_id,
			   aid.line_type_lookup_code,
			   ''Y'' PROCESS_FLAG,
			   decode(ai.attribute15, ''DUMMY_9884253'', ai.attribute15, '''') error_message,
			   decode((select tax.invoice_distribution_id
                            from   ap_invoice_distributions_all tax
                            where  tax.line_type_lookup_code in (''NONREC_TAX'',''REC_TAX'',''TRV'',''TIPV'',''TERV'')
                            and    ai.invoice_id = tax.invoice_id(+)
                            and    rownum < 2), null, ''N'', ''Y'') tax_dists_exists,
			   decode((select tax.invoice_distribution_id
                            from   ap_self_assessed_tax_dist_all tax
                            where  ai.invoice_id = tax.invoice_id(+)
                            and    rownum < 2), null, ''N'', ''Y'') self_assess_tax_exists
                    from ap_invoices_all ai,
                         ap_invoice_lines_all ail,
                         ap_invoice_distributions_all aid,
                         ap_system_parameters_all asp,
			 financials_system_params_all fsp
                    where ai.invoice_id = aid.invoice_id
		    and  ai.invoice_id = :1
		    and ai.invoice_type_lookup_code <> ''EXPENSE REPORT''
		    and ai.source <> ''ERS''
                    and asp.org_id = ai.org_id
		    and fsp.org_id = ai.org_id
		    and nvl(fsp.purch_encumbrance_flag, ''N'') <> ''Y''
                    and ai.invoice_id = ail.invoice_id
                    and ail.line_number = aid.invoice_line_number
                    and ai.invoice_currency_code = asp.base_currency_code
                    and ail.line_source = ''IMPORTED''
		    and aid.line_type_lookup_code not in (''NONREC_TAX'',''REC_TAX'',''TRV'',''TIPV'',''TERV'', ''IPV'', ''ERV'')
                    and (nvl(aid.base_amount, 0) <> 0
                         OR aid.amount <> aid.base_amount)'    USING l_invoice_id;

      EXCEPTION
WHEN OTHERS THEN
DBMS_OUTPUT.PUT_LINE('IN EXP 1272497.1');
DBMS_OUTPUT.PUT_LINE(SQLERRM);
		   
END;		   

 l_select_list := 'INVOICE_NUM,INVOICE_ID,INVOICE_LINE_NUMBER,INVOICE_TYPE,SOURCE,POSTED_FLAG,BASE_CURRENCY,INVOICE_CURRENCY,EXCHANGE_RATE,' ||
	          'EXCHANGE_RATE_TYPE,EXCHANGE_DATE,INVOICE_AMOUNT,INVOICE_BASE_AMT,EVENT_ID,DISTRIBUTION_AMT,DIST_BASE_AMT,LINE_TYPE_LOOKUP_CODE' ;  
  l_table_name := 'AP_TEMP_DATA_DRIVER_9884253';
  l_where_clause := 'WHERE 1=1 ORDER BY INVOICE_ID,INVOICE_LINE_NUMBER';
  
AP_Acctg_Data_Fix_PKG.Print( 'Below base currency invoices populated with base currency');  
AP_Acctg_Data_Fix_PKG.Print( 'SOLUTION : Follow Note 1272497.1');  



 AP_ACCTG_DATA_FIX_PKG.Print_html_table
    (p_select_list       => l_select_list,
     p_table_in          => l_table_name,
     p_where_in          => l_where_clause,
     P_calling_sequence  => l_calling_sequence);
	 

	
  PRINT_LINE;				

 ELSIF l_rows > l_row_limit THEN
  AP_Acctg_Data_Fix_PKG.Print( 'More then 100 invoices affected'||
                               'Please follow the note 1272497.1 and run this GDF individually');
PRINT_LINE;	 

 END IF; 

FND_File.Put_Line(fnd_file.output,
                  '  END'||' '||'1272497.1'||'     '||
                  to_char(sysdate, 'DD-MON-YYYY:HH24:MI:SS'));

EXCEPTION 
      
  WHEN OTHERS THEN
     FND_LOG.STRING(10, '1272497.1','Error is : ' || SQLERRM);
     AP_Acctg_Data_Fix_PKG.Print('Error is : ' || SQLERRM);

END ;

--ap_func_curr_inv_with_base_amt_sel.sql 






--ap_canc_tax_lines_sel.sql
/*REM +=======================================================================+
REM | FILENAME                                                              |
REM |     ap_canc_tax_lines_sel.sql                                         |
REM |                                                                       |
REM | DESCRIPTION                                                           |
REM |  This script is used to indentify the tax lines which have no         |
REM |  tax distributions due to corresponding zx_lines are marked as        |
REM |  cancelled but zx_lines_summary is not cancelled.Such invoices        |
REM |  are picked for validation agian and again though validated already.  |
REM +=======================================================================+*/

BEGIN  

FND_File.Put_Line(fnd_file.output,
                   '---------------------------------------------------------');
FND_File.Put_Line(fnd_file.output,
                  'START'||' '||'1272433.1'||'     '||
                  to_char(sysdate, 'DD-MON-YYYY:HH24:MI:SS'));

CHECK_COUNT(10177074,l_invoice_id,l_rows);



IF l_rows < l_row_limit and l_rows > 0 THEN

BEGIN
 EXECUTE IMMEDIATE 'DROP TABLE AP_TEMP_DATA_DRIVER_10177074';
EXCEPTION
  WHEN OTHERS THEN
    NULL;
END;
BEGIN

EXECUTE IMMEDIATE
'CREATE TABLE AP_TEMP_DATA_DRIVER_10177074  AS  
        SELECT DISTINCT ail.invoice_num ,
                       ail.line_number, ail.summary_tax_line_id
        FROM ap_invoice_lines_all ail 
        WHERE 1=2';
  
  
  EXECUTE IMMEDIATE
'INSERT INTO AP_TEMP_DATA_DRIVER_10177074 
	   SELECT ail.invoice_id,
	          ail.line_number, ail.summary_tax_line_id,
	  	   ''Y'' Process_flag 
	     FROM ap_invoice_lines_all ail 
	     WHERE ail.line_type_lookup_code =''TAX'' 
	        AND ail.invoice_id = :1
	  	AND ail.summary_tax_line_id IS NOT NULL 
	  	AND ail.amount = 0 
	  	AND NVL(ail.cancelled_flag,''N'') = ''N'' 
	  	AND NVL(ail.discarded_flag,''N'') = ''N''  
	  	AND EXISTS 
	  	  (SELECT 1 
	  	    FROM zx_lines zl1 
	  	   WHERE zl1.trx_id = ail.invoice_id 
	  	     AND zl1.application_id = 200 
	  	     AND zl1.entity_code = ''AP_INVOICES'' 
	   	     AND zl1.event_class_code IN 
	  	      (''STANDARD INVOICES'' , ''PREPAYMENT INVOICES'', ''EXPENSE REPORTS'') 
	  	     AND zl1.summary_tax_line_id = ail.summary_tax_line_id) 
	  	AND NOT EXISTS  
	  	  (SELECT 1 
	  	     FROM zx_lines zl 
	  	   WHERE zl.trx_id = ail.invoice_id 
	  	     AND zl.application_id = 200 
	  	     AND zl.entity_code = ''AP_INVOICES'' 
	  	     AND zl.event_class_code IN  
	  	     (''STANDARD INVOICES'' , ''PREPAYMENT INVOICES'',''EXPENSE REPORTS'') 
	  	     AND zl.summary_tax_line_id = ail.summary_tax_line_id 
	  	     AND NVL(cancel_flag,''N'') = ''N'')
	   AND NOT EXISTS  
	  	  (SELECT 1 
	  	     FROM zx_lines_summary zls 
	  	   WHERE zls.trx_id = ail.invoice_id 
	  	     AND zls.application_id = 200 
	  	     AND zls.entity_code = ''AP_INVOICES'' 
	  	     AND zls.event_class_code IN 
	  	     (''STANDARD INVOICES'' , ''PREPAYMENT INVOICES'', ''EXPENSE REPORTS'') 
	  	     AND zls.summary_tax_line_id = ail.summary_tax_line_id 
	  	     AND NVL(zls.cancel_flag,''N'') = ''Y'')'
         USING l_invoice_id;

      EXCEPTION
WHEN OTHERS THEN
DBMS_OUTPUT.PUT_LINE('IN EXP 1272433.1');
DBMS_OUTPUT.PUT_LINE(SQLERRM);
		   
END;		   

 l_select_list := 'INVOICE_ID,LINE_NUMBER,SUMMARY_TAX_LINE_ID' ;  
  l_table_name := 'AP_TEMP_DATA_DRIVER_10177074';
  l_where_clause := 'WHERE 1=1 ORDER BY INVOICE_ID,LINE_NUMBER,SUMMARY_TAX_LINE_ID';
  
AP_Acctg_Data_Fix_PKG.Print( 'Below invoices are validated but picking up for validation');  
AP_Acctg_Data_Fix_PKG.Print( 'SOLUTION : Follow Note 1272433.1');  



 AP_ACCTG_DATA_FIX_PKG.Print_html_table
    (p_select_list       => l_select_list,
     p_table_in          => l_table_name,
     p_where_in          => l_where_clause,
     P_calling_sequence  => l_calling_sequence);
	 

	
  PRINT_LINE;				

 ELSIF l_rows > l_row_limit THEN
  AP_Acctg_Data_Fix_PKG.Print( 'More then 100 invoices affected'||
                               'Please follow the note 1272433.1 and run this GDF individually');
PRINT_LINE;	 

 END IF; 

FND_File.Put_Line(fnd_file.output,
                  '  END'||' '||'1272433.1'||'     '||
                  to_char(sysdate, 'DD-MON-YYYY:HH24:MI:SS'));

EXCEPTION 
      
  WHEN OTHERS THEN
     FND_LOG.STRING(10, '1272433.1','Error is : ' || SQLERRM);
     AP_Acctg_Data_Fix_PKG.Print('Error is : ' || SQLERRM);

END ;

--ap_canc_tax_lines_sel.sql 



--ap_wrong_bal_segment_sel.sql
/*REM +=======================================================================+
REM | FILENAME                                                                     |
REM |     ap_wrong_bal_segment_sel.sql                                             |
REM |                                                                              |
REM | DESCRIPTION                                                                  |
REM |        Invoices that are not part of the legal entity or ledger context      |
REM |        of the Balancing Segment Values(BSV) on its Account code combinations |
REM |        always errors out during accounting in SLA with error#95311           |
REM +=======================================================================+*/

BEGIN  

FND_File.Put_Line(fnd_file.output,
                   '---------------------------------------------------------');
FND_File.Put_Line(fnd_file.output,
                  'START'||' '||'1272440.1'||'     '||
                  to_char(sysdate, 'DD-MON-YYYY:HH24:MI:SS'));

CHECK_COUNT(9978924,l_invoice_id,l_rows);



IF l_rows < l_row_limit and l_rows > 0 THEN

BEGIN
 EXECUTE IMMEDIATE 'DROP TABLE AP_TEMP_DATA_DRIVER_9978924';
EXCEPTION
  WHEN OTHERS THEN
    NULL;
END;
BEGIN

     EXECUTE IMMEDIATE  'CREATE TABLE AP_TEMP_DATA_DRIVER_9978924 NOLOGGING
		              AS
			     Select a.org_id,
				    a.invoice_num,
				    a.invoice_id,
				    a.invoice_line_number,
			            a.invoice_distribution_id,
				    a.line_type_lookup_code,
				    a.posted_flag,
			            a.accounting_date,
				    a.period_name,
				    a.chart_of_accounts_id,
				    a.set_of_books_id,
				    a.dist_match_type,
				    a.po_distribution_id,
				    a.rcv_transaction_id,
			            a.detail_tax_dist_id,
				    a.detail_posting_allowed_flag,
				    a.enabled_flag,
				    a.account_type,
				    a.summary_flag,
				    a.old_code_combid,
				    a.new_code_combid,
				    a.old_balancing_seg_value,
				    a.new_balancing_seg_value,
				    a.old_concat_account,
				    a.new_concat_account,
				    a.process_flag,
				    a.validate_flag,
				    a.error_message,
				    a.bal_seg_valid
               from (select /*+parallel(aid)*/ ai.org_id,
					       ai.invoice_num,
					       ai.invoice_id,
					       aid.invoice_line_number,
					       aid.invoice_distribution_id,
					       aid.line_type_lookup_code,
					       aid.posted_flag,
					       aid.accounting_date,
					       aid.period_name,
					       gsb.chart_of_accounts_id,
					       aid.set_of_books_id,
					       aid.dist_match_type,
					       aid.po_distribution_id,
					       aid.rcv_transaction_id,
					       aid.detail_tax_dist_id,
					       gcc.detail_posting_allowed_flag,
					       gcc.enabled_flag,
					       gcc.account_type,
					       gcc.summary_flag,
					       nvl((SELECT ''1'' /*+cardinality(glsv 1)*/
						     FROM gl_ledger_segment_values glsv
						    WHERE glsv.segment_value =
					       AP_INVOICE_DISTRIBUTIONS_PKG.get_balancing_segment_value(aid.dist_code_combination_id,
                                                                                   aid.set_of_books_id)
					       AND glsv.segment_type_code = ''B''
					       AND glsv.ledger_id = aid.set_of_books_id
					       AND aid.accounting_date BETWEEN
					              NVL(glsv.start_date, aid.accounting_date) AND
                                                      NVL(glsv.end_date, aid.accounting_date)
					       AND rownum = 1),
					       0) "BAL_SEG_VALID",
					       AP_INVOICE_DISTRIBUTIONS_PKG.get_balancing_segment_value(aid.dist_code_combination_id,
                                                                        aid.set_of_books_id) "OLD_BALANCING_SEG_VALUE",
					       decode(gcc.segment1,''DUMMY'',gcc.segment1,'''') "NEW_BALANCING_SEG_VALUE",
                                               aid.dist_code_combination_id "OLD_CODE_COMBID",
                                               decode(gcc.code_combination_id,000000,gcc.code_combination_id,null) "NEW_CODE_COMBID",
                                               fnd_flex_ext.get_segs(''SQLGL'',
                                                                      ''GL#'',
                                                                      gsb.chart_of_accounts_id,
                                                                     aid.dist_code_combination_id) "OLD_CONCAT_ACCOUNT",
                                               decode(aid.global_attribute_category,''DUMMY'',aid.global_attribute_category,'''') "NEW_CONCAT_ACCOUNT",
                                               ''Y'' "PROCESS_FLAG",
                                               ''N'' "VALIDATE_FLAG",
                                               decode(aid.global_attribute1,''DUMMY'',aid.global_attribute1,'''') "ERROR_MESSAGE"
					  from ap_invoices_all              ai,
					       ap_invoice_distributions_all aid,
					       gl_ledgers                   gl,
					       gl_code_combinations         gcc,
					       ap_system_parameters_all     asp,
					       gl_sets_of_books             gsb
					 where ai.invoice_id = aid.invoice_id
					   and ai.invoice_id = :1
					   and aid.dist_code_combination_id = gcc.code_combination_id
					   and aid.set_of_books_id = gl.ledger_id
					   and aid.historical_flag is null
					   and aid.posted_flag <> ''Y''
					   and nvl(gl.bal_seg_value_option_code, ''A'') <> ''A'' ) a
				          where a.BAL_SEG_VALID = 0 '
					   USING l_invoice_id;

      EXCEPTION
WHEN OTHERS THEN
DBMS_OUTPUT.PUT_LINE('IN EXP 1272440.1');
DBMS_OUTPUT.PUT_LINE(SQLERRM);
		   
END;		   

 l_select_list := 'ORG_ID,INVOICE_NUM,INVOICE_ID,INVOICE_LINE_NUMBER,INVOICE_DISTRIBUTION_ID,LINE_TYPE_LOOKUP_CODE,POSTED_FLAG,'||
                  'OLD_BALANCING_SEG_VALUE,NEW_BALANCING_SEG_VALUE,OLD_CODE_COMBID,NEW_CODE_COMBID';  
  l_table_name := 'AP_TEMP_DATA_DRIVER_9978924';
  l_where_clause := 'WHERE 1=1 ORDER BY ORG_ID,INVOICE_NUM,INVOICE_ID,INVOICE_LINE_NUMBER';
  
AP_Acctg_Data_Fix_PKG.Print( 'Below invoices are populatec with wrong balancing segments');  
AP_Acctg_Data_Fix_PKG.Print( 'SOLUTION : Follow Note 1272440.1');  



 AP_ACCTG_DATA_FIX_PKG.Print_html_table
    (p_select_list       => l_select_list,
     p_table_in          => l_table_name,
     p_where_in          => l_where_clause,
     P_calling_sequence  => l_calling_sequence);
	 

	
  PRINT_LINE;				

 ELSIF l_rows > l_row_limit THEN
  AP_Acctg_Data_Fix_PKG.Print( 'More then 100 invoices affected'||
                               'Please follow the note 1272440.1 and run this GDF individually');
PRINT_LINE;	 

 END IF; 

FND_File.Put_Line(fnd_file.output,
                  '  END'||' '||'1272440.1'||'     '||
                  to_char(sysdate, 'DD-MON-YYYY:HH24:MI:SS'));

EXCEPTION 
      
  WHEN OTHERS THEN
     FND_LOG.STRING(10, '1272440.1','Error is : ' || SQLERRM);
     AP_Acctg_Data_Fix_PKG.Print('Error is : ' || SQLERRM);

END ;

--ap_wrong_bal_segment_sel.sql 



--AP_MISC_INVOICE_DIAG.sql.sql
/*REM +=======================================================================+
REM | FILENAME                                                              |
REM |     AP_MISC_INVOICE_DIAG.sql.sql                                      |
REM |                                                                       |
REM | DESCRIPTION                                                           |
REM |   1 Match status flag incorrect for posted distributions              |
REM |   2 Discarded Flag on line is Y but distributions sum is not 0        |
REM |   3 Discarded Flag on line is Y but amount is non-zero and no dists   |
REM |   4 Invoice tax distributions with no summary_tax_line_id             |
REM |   5 Orphan Self assessed tax distributions                            |
REM |   6 Orphan invoice tax distributions                                  |
REM |   7 Self assessed tax distributions with null event_id                |
REM |   8 Invoices stuck with CANNOT EXECUTE ALLOCATION Hold                |
REM |   9 Cancelled invoices with non-zero amount paid                      |
REM |  10 Cancelled invoices with Schedule payment hold                     |
REM |  11 Reversal and Origianl Dists are not in sync                       |
REM |  12 Match status flag in distribution incorrect since validation      |
REM |     concurrent program completed in Error                             |
REM |  13 Match status flag incorrect for cancelled distributions           |
REM +=======================================================================+*/

BEGIN  

FND_File.Put_Line(fnd_file.output,
                   '---------------------------------------------------------');
FND_File.Put_Line(fnd_file.output,
                  'START'||' '||'1266869.1'||'     '||
                  to_char(sysdate, 'DD-MON-YYYY:HH24:MI:SS'));

CHECK_COUNT(9738413,l_invoice_id,l_rows);

IF l_rows < l_row_limit and l_rows > 0 THEN

BEGIN
 EXECUTE IMMEDIATE 'DROP TABLE AP_TEMP_DATA_DRIVER_9738413';
EXCEPTION
  WHEN OTHERS THEN
    NULL;
END;
BEGIN

EXECUTE IMMEDIATE  'CREATE TABLE AP_TEMP_DATA_DRIVER_9738413(
				INVOICE_ID       NUMBER,
				CHILD_ID   		 NUMBER,
				ACCOUNTING_EVENT_ID NUMBER,
				POSTED_FLAG		 VARCHAR2(1),
				CORRUPTION_TYPE  NUMBER)';


	  EXECUTE Immediate
	  'INSERT INTO AP_TEMP_DATA_DRIVER_9738413
		(
		INVOICE_ID,
		CHILD_ID,
		ACCOUNTING_EVENT_ID,
		POSTED_FLAG,
		CORRUPTION_TYPE,
		PROCESS_FLAG
		)
		SELECT a.* FROM
		 (SELECT  /*+ parallel(aid) */
			aid.invoice_id,
			aid.invoice_distribution_id,
			aid.accounting_event_id,
			aid.posted_flag,
			1 corruption_type,
			''Y'' PROCESS_FLAG
		FROM ap_invoice_distributions_all aid
		WHERE aid.posted_flag      = ''Y''
		AND NVL(aid.match_status_flag,''N'') <> ''A''
		AND EXISTS (SELECT 1
			  FROM xla_Events x
			  WHERE x.application_id = 200
			  AND x.event_id          = aid.accounting_event_id
			  AND x.event_Status_code   =''P''
			  AND x.process_status_code =''P''
			  )
		UNION
		SELECT  /*+ parallel(aid) */
			asa.invoice_id,
			asa.invoice_distribution_id,
			asa.accounting_event_id,
			asa.posted_flag,
			1 corruption_type,
			''Y'' PROCESS_FLAG
		FROM ap_self_assessed_tax_dist_all asa
		WHERE asa.posted_flag      = ''Y''
		AND NVL(asa.match_status_flag,''N'') <> ''A''
		AND EXISTS (SELECT 1
			  FROM xla_Events x
			  WHERE x.application_id = 200
			  AND x.event_id          = asa.accounting_event_id
			  AND x.event_Status_code   =''P''
			  AND x.process_status_code =''P''
			  )
		UNION
		SELECT /*+ parallel(ai) */
			ai.invoice_id,
			ail.line_number,
			NULL,
			NULL,
			2 corruption_type,
			''Y'' process_flag
		FROM ap_invoices_all ai,
		  ap_invoice_lines_all ail,
		  ap_invoice_distributions_all aid
		WHERE ai.invoice_id    = ail.invoice_id
		AND ail.invoice_id     = aid.invoice_id
		AND ail.line_number    = aid.invoice_line_number
		AND ai.cancelled_date IS NULL
		AND ail.discarded_flag = ''Y''
		AND EXISTS (SELECT 1
			  FROM ap_invoice_distributions_all aid1
			  WHERE aid1.invoice_id                 = ai.invoice_id
			  AND NVL(aid1.posted_flag,''N'')		<> ''Y''
			  AND (NVL(aid1.match_status_flag, ''N'') = ''N''
			  OR (NVL(aid1.match_status_flag, ''N'')  = ''T''
			  AND EXISTS
				(SELECT 1
				FROM ap_holds_all ah
				WHERE ah.invoice_id      = aid1.invoice_id
				AND release_lookup_code IS NULL
				))))
		GROUP BY ai.invoice_id,
		  ail.line_number,
		  DECODE(ail.historical_flag, ''Y'', 0, ail.amount) 
		HAVING DECODE(ail.historical_flag, ''Y'', 0, ail.amount) <> SUM (aid.amount)
	        UNION 
		SELECT /*+ parallel(ail) */
		      	 ail.invoice_id,
		         ail.line_number,
		         NULL,
		         NULL,
		         3 corruption_type,
		         ''Y'' process_flag
		FROM ap_invoice_lines_all ail
		WHERE ail.discarded_flag = ''Y''
		AND ail.amount <> 0
		AND NVL(ail.historical_flag,''N'') <> ''Y''
		AND NOT EXISTS (select 1 from 
				ap_invoice_distributions_all aid
				where aid.invoice_id = ail.invoice_id
				and aid.invoice_line_number = ail.line_number)
		UNION
		SELECT /*+ parallel(aid) */
			aid.invoice_id,
			aid.invoice_distribution_id,
		        aid.accounting_event_id,
			aid.posted_flag,
			4 corruption_type,
			''Y'' PROCESS_FLAG
		FROM ap_invoice_distributions_all aid
		WHERE line_type_lookup_code IN (''REC_TAX'',''NONREC_TAX'',''TRV'',''TERV'',''TIPV'')
		AND detail_tax_dist_id      IS NULL
		AND summary_tax_line_id     IS NULL
		UNION
		SELECT /*+ parallel(asad) */
			  asad.invoice_id,
			  asad.invoice_distribution_id,
			  asad.accounting_event_id,
			  asad.posted_flag,
			  5 corruption_type,
			  ''Y'' PROCESS_FLAG
		FROM ap_self_assessed_tax_dist_all asad
		WHERE EXISTS
			(SELECT 1
			  FROM zx_rec_nrec_dist zd
			  WHERE zd.trx_id = asad.invoice_id  
			  AND zd.rec_nrec_tax_dist_id = asad.detail_tax_dist_id
			  AND zd.entity_code          = ''AP_INVOICES''
			  AND zd.event_class_code    IN (''STANDARD INVOICES'', ''PREPAYMENT INVOICES'', ''EXPENSE REPORTS'')
			  AND zd.application_id       = 200
			  AND zd.self_assessed_flag   = ''N'' )
		UNION
		SELECT /*+ parallel(aid) */
			  aid.invoice_id,
			  aid.invoice_distribution_id,
			  aid.accounting_event_id,
			  aid.posted_flag,
			  6 corruption_type,
			  ''Y'' PROCESS_FLAG
		FROM ap_invoice_distributions_all aid
		WHERE aid.detail_tax_dist_id IS NOT NULL
		AND EXISTS 
			(SELECT /*+ parallel(zd) */ 1
			  FROM zx_rec_nrec_dist zd
			  WHERE  zd.trx_id = aid.invoice_id 
			  AND zd.rec_nrec_tax_dist_id = aid.detail_tax_dist_id 
			  AND zd.entity_code          = ''AP_INVOICES''
			  AND zd.event_class_code    IN (''STANDARD INVOICES'', ''PREPAYMENT INVOICES'', ''EXPENSE REPORTS'')
			  AND zd.application_id       = 200
			  AND zd.self_assessed_flag   = ''Y'' )
		UNION
		SELECT  /*+ parallel(asad) */
			ai.invoice_id,
			asad.invoice_distribution_id,
			NULL,
			NULL,
			7 corruption_type,
			''Y'' PROCESS_FLAG
		FROM ap_self_assessed_tax_dist_all asad,
		     ap_invoices_all ai
		WHERE ai.invoice_id= asad.invoice_id
		AND asad.accounting_event_id IS NULL
		AND ai.cancelled_date is null
		AND NVL(ai.force_revalidation_flag,''N'') <> ''Y''
		AND AP_INVOICES_PKG.get_approval_status(ai.invoice_id, ai.invoice_amount, 
			ai.payment_status_flag, ai.invoice_type_lookup_code) 
			IN (''APPROVED'',''AVAILABLE'',''UNPAID'',''FULL'')
		UNION
		SELECT  /*+ parallel(aha) */
			  aha.invoice_id,
			  aha.hold_id,
			  NULL,
			  NULL,
			  8 corruption_type,
			  ''Y'' PROCESS_FLAG
		FROM ap_holds_all aha
		WHERE hold_lookup_code   = ''CANNOT EXECUTE ALLOCATION''
		AND release_lookup_code IS NULL
		AND NOT EXISTS
		  (SELECT 1
		  FROM ap_invoice_lines_all ail
		  WHERE ail.invoice_id       = aha.invoice_id
		  AND line_type_lookup_code IN(''FREIGHT'',''MISCELLANEOUS'')
		  AND NVL(discarded_flag,''N'')    = ''N''
		  AND NVL(generate_dists,''N'')    = ''Y''
		  )
		UNION
		SELECT /*+ parallel(aha) */
			invoice_id,
			NULL,
			NULL,
			NULL,
			9 corruption_type,
			''Y''PROCESS_FLAG
		FROM ap_invoices_all
		WHERE cancelled_date   IS NOT NULL
		AND NVL(amount_paid,0) <> 0
		UNION
		SELECT /*+ parallel(aha) */
			ai.invoice_id,
			NULL,
			NULL,
			NULL,
			10 corruption_type,
			''Y'' process_flag
		FROM ap_invoices_all ai 
		WHERE ai.cancelled_date IS NOT NULL 
		AND ai.invoice_amount = 0 
		AND EXISTS
			  (SELECT 1
			  FROM ap_payment_schedules_all aps
			  WHERE aps.invoice_id = ai.invoice_id
			  AND aps.hold_flag    = ''Y''
			  )
		UNION
		SELECT /*+ parallel(aha) */ 
			aid.invoice_id,
			aid.invoice_distribution_id,
			aid.accounting_event_id,
			aid.posted_flag,
			11 corruption_type,
			''Y'' PROCESS_FLAG
		FROM ap_invoice_distributions_all aid
		WHERE aid.reversal_flag           = ''Y''
		AND EXISTS (SELECT 1 from ap_invoice_distributions_all aidrev
				WHERE aidrev.invoice_id            = aid.invoice_id
				AND aidrev.reversal_flag           = aid.reversal_flag
				AND aidrev.parent_reversal_id 	   = aid.invoice_distribution_id
				AND ABS(nvl(aidrev.amount,0)) <> ABS(nvl(aid.amount,0)))
		UNION
		SELECT  /*+ parallel(aid) */
			aid.invoice_id ,
			aid.invoice_distribution_id ,
			aid.accounting_event_id ,
			aid.posted_flag,
			12 corruption_type,
			''Y'' PROCESS_FLAG
		FROM ap_invoice_distributions_all aid
		WHERE match_status_flag = ''S''
		AND EXISTS
			(SELECT 1
			FROM ap_invoices_all ai
			WHERE ai.invoice_id           = aid.invoice_id
			AND ai.validation_request_id IS NULL)
		UNION
		SELECT AID.invoice_id,
		   AID.invoice_distribution_id,
		   AID.bc_event_id,
		   AID.posted_flag,
		   13 corruption_type,
		   ''Y'' process_flag
		FROM ap_invoice_distributions_all AID,
			 ap_invoices_all  AI
		WHERE AI.invoice_id = AID.invoice_id
		AND ( AI.cancelled_date IS NOT NULL 
	         OR AI.temp_cancelled_amount IS NOT NULL )
		AND AI.invoice_amount = 0
		AND NVL( AI.historical_flag, ''N'' ) <> ''Y''
		AND AI.validation_request_id IS NULL
		AND ( SELECT SUM( AID1.amount ) 
		      FROM ap_invoice_distributions_all AID1
	              WHERE AID1.invoice_id = AI.invoice_id ) = 0
		AND NOT EXISTS ( SELECT 1 
				 FROM ap_invoice_distributions_all AID2
				 WHERE AID2.invoice_id = AI.invoice_id
				 AND AID2.parent_reversal_id IS NULL
       		                 AND AID2.reversal_flag = ''Y''
				 AND ( SELECT COUNT( 1 )
                       		        FROM ap_invoice_distributions_all AID3
                    		        WHERE AID3.parent_reversal_id = AID2.invoice_distribution_id 
                           ) <> 1 )
		AND ( ( NVL( AID.match_status_flag, ''N'' ) <> ''A''
			AND NVL( AID.encumbered_flag, ''N'' ) = ''N''
			AND AID.bc_event_id IS NOT NULL ) 
	        OR 	( NVL( AID.match_status_flag, ''A'' ) = ''A'' 
			AND AID.encumbered_flag = ''R''
			AND AID.bc_event_id IS NOT NULL ) 
       		OR	( NVL( AID.match_status_flag, ''N'' ) <> ''A'' 
			AND AID.encumbered_flag = ''N''
			AND AID.bc_event_id IS NULL) )
		AND NOT EXISTS ( SELECT 1
				 FROM xla_events XE
				 WHERE XE.application_id = 200
				 AND XE.event_id = AID.bc_event_id
				 AND XE.event_status_code = ''P'' )
		) a  WHERE a.invoice_id = :1 '   USING l_invoice_id;

      EXCEPTION
WHEN OTHERS THEN
DBMS_OUTPUT.PUT_LINE('IN EXP 1266869.1');
DBMS_OUTPUT.PUT_LINE(SQLERRM);
		   
END;		   

 l_select_list := 'INVOICE_ID,CHILD_ID,ACCOUNTING_EVENT_ID,POSTED_FLAG,CORRUPTION_TYPE';  
  l_table_name := 'AP_TEMP_DATA_DRIVER_9738413';
  l_where_clause := 'WHERE 1=1 ORDER BY INVOICE_ID,CORRUPTION_TYPE';
  
AP_Acctg_Data_Fix_PKG.Print( 'Below invoices are having common issues');  
AP_Acctg_Data_Fix_PKG.Print( 'SOLUTION : Follow Note 1266869.1');  



 AP_ACCTG_DATA_FIX_PKG.Print_html_table
    (p_select_list       => l_select_list,
     p_table_in          => l_table_name,
     p_where_in          => l_where_clause,
     P_calling_sequence  => l_calling_sequence);
	 

	
  PRINT_LINE;				

 ELSIF l_rows > l_row_limit THEN
  AP_Acctg_Data_Fix_PKG.Print( 'More then 100 invoices affected'||
                               'Please follow the note 1266869.1 and run this GDF individually');
PRINT_LINE;	 

 END IF; 

FND_File.Put_Line(fnd_file.output,
                  '  END'||' '||'1266869.1'||'     '||
                  to_char(sysdate, 'DD-MON-YYYY:HH24:MI:SS'));

EXCEPTION 
      
  WHEN OTHERS THEN
     FND_LOG.STRING(10, '1266869.1','Error is : ' || SQLERRM);
     AP_Acctg_Data_Fix_PKG.Print('Error is : ' || SQLERRM);
 
END ;

--AP_MISC_INVOICE_DIAG.sql 



--ap_prepay_dist_id_pop_sel.sql
/*REM +=======================================================================+
REM | FILENAME                                                                      |
REM |     ap_prepay_dist_id_pop_sel.sql                                             |
REM |                                                                               |
REM | DESCRIPTION                                                                   |
REM |        Prepay_distribution_id is not populated on AP_INVOICE_DISTRIBUTIONS_ALL|
REM |        for the tax distributions created as part of prepay application/       |
REM |        unapplication.                                                         |
REM |                                                                               |
REM +=======================================================================+*/

DECLARE

  row_cnt NUMBER := 0;

BEGIN  

FND_File.Put_Line(fnd_file.output,
                   '---------------------------------------------------------');
FND_File.Put_Line(fnd_file.output,
                  'START'||' '||'9243855'||'     '||
                  to_char(sysdate, 'DD-MON-YYYY:HH24:MI:SS'));

BEGIN
 EXECUTE IMMEDIATE 'DROP TABLE AP_TEMP_DATA_DRIVER_9243855';
EXCEPTION
  WHEN OTHERS THEN
    NULL;
END;
BEGIN

EXECUTE IMMEDIATE  'CREATE TABLE AP_TEMP_DATA_DRIVER_9243855
   AS 
   SELECT aida_std.prepay_distribution_id ROOT,
	aida_ppay.invoice_id PREPAY_INVOICE_ID,
	aida_ppay.invoice_line_number PREPAY_LINE_NUMBER,
	aida_std.invoice_id INVOICE_ID,
	aida_std.distribution_line_number,
	aida_std.dist_code_combination_id,
	aida_std.line_type_lookup_code,
	aida_std.set_of_books_id,
	aida_std.posted_flag,
	aida_std.amount,
	aida_std.org_id,
	aida_std.tax_code_id,
	aida_std.tax_recoverable_flag,
	aida_std.invoice_distribution_id,
	aida_std.prepay_tax_parent_id,
	aida_std.prepay_distribution_id,
	aida_std.invoice_includes_prepay_flag,
	aida_std.tax_calculated_flag
   from ap_invoice_dists_arch aida_std, 
	ap_invoice_dists_arch aida_ppay
 where 1=2';


EXECUTE IMMEDIATE  'INSERT INTO AP_TEMP_DATA_DRIVER_9243855
   SELECT CONNECT_BY_ROOT aida_std.prepay_distribution_id ROOT,
	aida_ppay.invoice_id PREPAY_INVOICE_ID,
	aida_ppay.invoice_line_number PREPAY_LINE_NUMBER,
	aida_std.invoice_id INVOICE_ID,
	aida_std.distribution_line_number,
	aida_std.dist_code_combination_id,
	aida_std.line_type_lookup_code,
	aida_std.set_of_books_id,
	aida_std.posted_flag,
	aida_std.amount,
	aida_std.org_id,
	aida_std.tax_code_id,
	aida_std.tax_recoverable_flag,
	aida_std.invoice_distribution_id,
	aida_std.prepay_tax_parent_id,
	aida_std.prepay_distribution_id,
	aida_std.invoice_includes_prepay_flag,
	aida_std.tax_calculated_flag
   from (select a.* from ap_invoice_dists_arch a where a.invoice_id = '|| l_invoice_id ||') aida_std, 
	ap_invoice_dists_arch aida_ppay
 where aida_std.prepay_distribution_id = aida_ppay.invoice_distribution_id(+)
       and aida_std.invoice_id = '|| l_invoice_id ||'
	and aida_std.invoice_id in
		 (select distinct aida_drv.invoice_id
			from ap_invoice_dists_arch aida_drv
		    where aida_drv.prepay_distribution_id is null
		        and aida_drv.invoice_id = '|| l_invoice_id ||'
			and aida_drv.prepay_tax_parent_id is not null)
		start with (aida_std.line_type_lookup_code = ''PREPAY'' and
			    aida_std.prepay_distribution_id is not null)
		connect by NOCYCLE prior aida_std.invoice_distribution_id = aida_std.prepay_tax_parent_id';

      row_cnt := SQL%ROWCOUNT;

      EXCEPTION
WHEN OTHERS THEN
DBMS_OUTPUT.PUT_LINE('IN EXP 9243855');
DBMS_OUTPUT.PUT_LINE(SQLERRM);
		   
END;		   

IF row_cnt > 0 THEN
   l_select_list := 'INVOICE_ID,ROOT,PREPAY_INVOICE_ID,PREPAY_LINE_NUMBER,distribution_line_number,'||
                    'dist_code_combination_id,line_type_lookup_code,set_of_books_id,posted_flag,amount,org_id,'||
		    'tax_code_id,tax_recoverable_flag,invoice_distribution_id,prepay_tax_parent_id';  
   l_table_name := 'AP_TEMP_DATA_DRIVER_9243855';
   l_where_clause := 'WHERE 1=1 ORDER BY INVOICE_ID,PREPAY_INVOICE_ID';
  
   AP_Acctg_Data_Fix_PKG.Print( 'Below invoice is not poupulated with proper prepay details while upgrading');  
   AP_Acctg_Data_Fix_PKG.Print( 'SOLUTION : Follow GDF 9243855');  



   AP_ACCTG_DATA_FIX_PKG.Print_html_table
      (p_select_list       => l_select_list,
       p_table_in          => l_table_name,
       p_where_in          => l_where_clause,
       P_calling_sequence  => l_calling_sequence);
	 

	
   PRINT_LINE;				

END IF;

FND_File.Put_Line(fnd_file.output,
                  '  END'||' '||'9243855'||'     '||
                  to_char(sysdate, 'DD-MON-YYYY:HH24:MI:SS'));
EXCEPTION 
      
  WHEN OTHERS THEN
     FND_LOG.STRING(10, 'GDF 9243855','Error is : ' || SQLERRM);
     AP_Acctg_Data_Fix_PKG.Print('Error is : ' || SQLERRM);
 
END ;

--ap_prepay_dist_id_pop_sel.sql 



--ap_duplicate_batch_names_sel.sql
/*REM +=======================================================================+
REM | FILENAME                                                              |
REM |     ap_duplicate_batch_names_sel.sql                                  |
REM |                                                                       |
REM | DESCRIPTION                                                           |
REM |   This script will identify all AP batches with duplicate batch names |
REM |   and create driver table AP_TEMP_DATA_DRIVER_10177871                |
REM |   The records identified by this script are corrected by running the  |
REM |   script ap_duplicate_batch_names_fix.sql                             |
REM |   Update the process_flag in driver table to 'N' for any records that |
REM |   should not be corrected.                                            |
REM | RCA                                                                   |
REM |   9850836                                                             |
REM +=======================================================================+*/

DECLARE

  row_cnt NUMBER := 0;

BEGIN  

FND_File.Put_Line(fnd_file.output,
                   '---------------------------------------------------------');
FND_File.Put_Line(fnd_file.output,
                  'START'||' '||'10177871'||'     '||
                  to_char(sysdate, 'DD-MON-YYYY:HH24:MI:SS'));


BEGIN
 EXECUTE IMMEDIATE 'DROP TABLE AP_TEMP_DATA_DRIVER_10177871';
EXCEPTION
  WHEN OTHERS THEN
    NULL;
END;
BEGIN

EXECUTE IMMEDIATE 'CREATE TABLE AP_TEMP_DATA_DRIVER_10177871(      
		   BATCH_ID       	NUMBER,      
		   BATCH_NAME    	VARCHAR2(50),
		   NEW_BATCH_NAME  VARCHAR2(50),
		   ORG_ID          NUMBER,      
		   PROCESS_FLAG    VARCHAR2(1) DEFAULT ''Y'')';


EXECUTE IMMEDIATE 'INSERT INTO AP_TEMP_DATA_DRIVER_10177871   
		(   BATCH_ID,   
			BATCH_NAME,
			NEW_BATCH_NAME,
			ORG_ID,   
			PROCESS_FLAG   
			)   
		(	SELECT /* + parallel(ab)*/     
			ab.batch_id,     
			ab.batch_name,
			ab.batch_name||''-''||to_char(org_id),
			ab.org_id,   
			''Y''   
			FROM ap_batches_all ab   
			WHERE EXISTS     
			(SELECT 1 
			FROM ap_batches_all ab1     
			WHERE ab1.batch_name = ab.batch_name     
			AND ab1.batch_id    <> ab.batch_id )
			AND ab.batch_id IN 
			(SELECT a.batch_id FROM ap_invoices_all a
			 WHERE a.invoice_id = :1) ) '
    USING l_invoice_id;

      row_cnt := SQL%ROWCOUNT;

      EXCEPTION
WHEN OTHERS THEN
DBMS_OUTPUT.PUT_LINE('IN EXP 10177871');
DBMS_OUTPUT.PUT_LINE(SQLERRM);
		   
END;		   

IF row_cnt > 0 THEN
   l_select_list := 'BATCH_ID,BATCH_NAME,NEW_BATCH_NAME,ORG_ID,PROCESS_FLAG';  
   l_table_name := 'AP_TEMP_DATA_DRIVER_10177871';
   l_where_clause := 'WHERE 1=1 ORDER BY BATCH_ID';
  
   AP_Acctg_Data_Fix_PKG.Print('Batch related to the invoice has got duplicated');  
   AP_Acctg_Data_Fix_PKG.Print( 'SOLUTION : Follow GDF 10177871');  



   AP_ACCTG_DATA_FIX_PKG.Print_html_table
      (p_select_list       => l_select_list,
       p_table_in          => l_table_name,
       p_where_in          => l_where_clause,
       P_calling_sequence  => l_calling_sequence);
	 

	
   PRINT_LINE;				

END IF;

FND_File.Put_Line(fnd_file.output,
                  '  END'||' '||'10177871'||'     '||
                  to_char(sysdate, 'DD-MON-YYYY:HH24:MI:SS'));

EXCEPTION 
      
  WHEN OTHERS THEN
     FND_LOG.STRING(10, 'GDF 10177871','Error is : ' || SQLERRM);
     AP_Acctg_Data_Fix_PKG.Print('Error is : ' || SQLERRM);

END ;

--ap_duplicate_batch_names_sel.sql 


--ap_po_line_sync_sel.sql
/*REM +=======================================================================+
REM | FILENAME                                                              |
REM |     ap_po_line_sync_sel.sql                                           |
REM |                                                                       |
REM | DESCRIPTION                                                           |
REM |   Script ap_po_line_sync_sel.sql needs to be run to identify          |
REM |   the PO shipments that have quantity/amounts mismatching with the    |
REM |   corresponding PO distributions and create driver table              |
REM |   AP_TEMP_DATA_DRIVER_9575282                                         |
REM |   The PO_line_location_all columns that are compared with values in   |
REM |   PO distributions.                                                   |
REM |   quantity_billed/amount_billed                                       |
REM |   quantity_recouped/amount_recouped                                   |
REM |   quantity_financed/amount_financed                                   |
REM |   Run Fix script ap_po_line_sync_fix.sql to correct the corrution     |
REM |   Process_Flag in driver table can be updated to N for any records    |
REM |   that need not be updated by the fix script.                         |
REM | RCA                                                                   |
REM |   9718642                                                             |
REM +=======================================================================+*/

DECLARE

  row_cnt NUMBER := 0;

BEGIN  

FND_File.Put_Line(fnd_file.output,
                   '---------------------------------------------------------');
FND_File.Put_Line(fnd_file.output,
                  'START'||' '||'9575282'||'     '||
                  to_char(sysdate, 'DD-MON-YYYY:HH24:MI:SS'));


BEGIN
 EXECUTE IMMEDIATE 'DROP TABLE AP_TEMP_DATA_DRIVER_9575282';
EXCEPTION
  WHEN OTHERS THEN
    NULL;
END;
BEGIN

EXECUTE IMMEDIATE 'CREATE TABLE AP_TEMP_DATA_DRIVER_9575282(      
		   PO_HEADER_ID       	NUMBER,      
		   LINE_LOCATION_ID    NUMBER,
		   PROCESS_FLAG    VARCHAR2(1) DEFAULT ''Y'')';



EXECUTE IMMEDIATE 'INSERT INTO AP_TEMP_DATA_DRIVER_9575282
       	           SELECT /*+ parallel(pll) */
			  pll.po_header_id,
			  pll.line_location_id,
			  ''Y'' process_flag
		   FROM po_line_locations_all pll
		   WHERE (NVL(pll.quantity_billed,0) <>
			  (SELECT NVL(SUM(pod.quantity_billed),0)
			  FROM po_distributions_all pod
			  WHERE pod.line_location_id=pll.line_location_id
			  )
		   OR NVL(pll.amount_billed,0) <>
			  (SELECT NVL(SUM(amount_billed),0)
			  FROM po_distributions_all pod
			  WHERE pod.line_location_id=pll.line_location_id
			  )
		   OR NVL(pll.quantity_financed,0) <>
			  (SELECT NVL(SUM(pod.quantity_financed),0)
			  FROM po_distributions_all pod
			  WHERE pod.line_location_id=pll.line_location_id
			  )
		   OR NVL(pll.amount_financed,0) <>
			  (SELECT NVL(SUM(amount_financed),0)
			  FROM po_distributions_all pod
			  WHERE pod.line_location_id=pll.line_location_id
			  )
		   OR NVL(pll.quantity_recouped,0) <>
			  (SELECT NVL(SUM(pod.quantity_recouped),0)
			  FROM po_distributions_all pod
			  WHERE pod.line_location_id=pll.line_location_id
			  )
		   OR NVL(pll.amount_recouped,0) <>
			  (SELECT NVL(SUM(amount_recouped),0)
			  FROM po_distributions_all pod
			  WHERE pod.line_location_id=pll.line_location_id
			  ))
	           AND pll.po_header_id IN (
		              SELECT ail.po_header_id FROM ap_invoice_lines_all ail
			      WHERE ail.invoice_id = :1)'
    USING l_invoice_id;

      row_cnt := SQL%ROWCOUNT;

      EXCEPTION
WHEN OTHERS THEN
DBMS_OUTPUT.PUT_LINE('IN EXP 9575282');
DBMS_OUTPUT.PUT_LINE(SQLERRM);
		   
END;		   

IF row_cnt > 0 THEN
   l_select_list := 'PO_HEADER_ID,LINE_LOCATION_ID';  
   l_table_name := 'AP_TEMP_DATA_DRIVER_9575282';
   l_where_clause := 'WHERE 1=1 ORDER BY PO_HEADER_ID';
  
   AP_Acctg_Data_Fix_PKG.Print('Invoice has mismatch in PO distributions and PO line locations');  
   AP_Acctg_Data_Fix_PKG.Print( 'SOLUTION : Follow GDF 9575282');  



   AP_ACCTG_DATA_FIX_PKG.Print_html_table
      (p_select_list       => l_select_list,
       p_table_in          => l_table_name,
       p_where_in          => l_where_clause,
       P_calling_sequence  => l_calling_sequence);
	 

	
   PRINT_LINE;				

END IF;

FND_File.Put_Line(fnd_file.output,
                  '  END'||' '||'9575282'||'     '||
                  to_char(sysdate, 'DD-MON-YYYY:HH24:MI:SS'));

EXCEPTION 
      
  WHEN OTHERS THEN
     FND_LOG.STRING(10, 'GDF 9575282','Error is : ' || SQLERRM);
     AP_Acctg_Data_Fix_PKG.Print('Error is : ' || SQLERRM);

END ;

--ap_po_line_sync_sel.sql 



--ap_del_itmlines_sel.sql
/*REM +=======================================================================+
REM | FILENAME                                                              |
REM |     ap_del_itmlines_sel.sql                                           |
REM |                                                                       |
REM | DESCRIPTION                                                           |
REM |      This script is used to indentify the tax lines which have no     |
REM |      corresponding taxable lines in ap_invoice_linesa_all             |
REM |      Such tax lines cause issue in validation and cancellation        |
REM |      Before Running this Data Fix make sure ZX patch                  |
REM |      9193069:R12.ZX.A / 9193069:R12.ZX.B is applied                   |
REM |      CAUSE: Code Fix Bug 8604959 AP bug and  8722511 ZX Bug           | 
REM +=======================================================================+*/

DECLARE

  row_cnt NUMBER := 0;

BEGIN  

FND_File.Put_Line(fnd_file.output,
                   '---------------------------------------------------------');
FND_File.Put_Line(fnd_file.output,
                  'START'||' '||'1276069.1 '||'     '||
                  to_char(sysdate, 'DD-MON-YYYY:HH24:MI:SS'));

BEGIN
 EXECUTE IMMEDIATE 'DROP TABLE AP_ORPH_TAX_LINES_9978865';
EXCEPTION
  WHEN OTHERS THEN
    NULL;
END;
BEGIN

EXECUTE IMMEDIATE 'CREATE TABLE AP_ORPH_TAX_LINES_9978865 AS      
		   SELECT * FROM zx_lines WHERE 1=2';


EXECUTE IMMEDIATE 'INSERT INTO AP_ORPH_TAX_LINES_9978865   
		 SELECT /*+ parallel(zl) */ zl.*
                 FROM zx_lines zl , ap_invoices_all ai
                 WHERE zl.application_id = 200
		    AND ai.invoice_id = :1
                    AND zl.entity_code = ''AP_INVOICES''
                    AND zl.event_class_code IN 
                   (''STANDARD INVOICES'', ''PREPAYMENT INVOICES'', ''EXPENSE REPORTS'')
                      AND zl.tax_only_line_flag = ''N''  
                      AND zl.trx_id = ai.invoice_id 
                      AND ( ai.cancelled_date IS NULL and ai.temp_cancelled_amount IS NULL)					  
                      AND NOT EXISTS (SELECT /*+ parallel(ail) */ 1
                                         FROM ap_invoice_lines_all ail
                                          WHERE ail.invoice_id = zl.trx_id
                                          AND ail.line_type_lookup_code NOT IN (''TAX'',''AWT'')
                                          AND ail.line_number = zl.trx_line_id)'
                    USING l_invoice_id;

      row_cnt := SQL%ROWCOUNT;

      EXCEPTION
WHEN OTHERS THEN
DBMS_OUTPUT.PUT_LINE('IN EXP 1276069.1 ');
DBMS_OUTPUT.PUT_LINE(SQLERRM);
		   
END;		   

IF row_cnt > 0 THEN
   l_select_list := 'TRX_ID,TRX_LINE_ID,TRX_LINE_NUMBER,TAX_LINE_ID,ENTITY_CODE,EVENT_CLASS_CODE,TAX_ONLY_LINE_FLAG,'||
                    'TAX_RATE_ID,TRX_RATE';  
   l_table_name := 'AP_ORPH_TAX_LINES_9978865';
   l_where_clause := 'WHERE 1=1 ORDER BY TRX_ID,TRX_LINE_ID';
  
   AP_Acctg_Data_Fix_PKG.Print('Invoice has tax lines with out any taxable lines');  
   AP_Acctg_Data_Fix_PKG.Print( 'SOLUTION : Follow Note 1276069.1 ');  



   AP_ACCTG_DATA_FIX_PKG.Print_html_table
      (p_select_list       => l_select_list,
       p_table_in          => l_table_name,
       p_where_in          => l_where_clause,
       P_calling_sequence  => l_calling_sequence);
	 

	
   PRINT_LINE;				

END IF;

FND_File.Put_Line(fnd_file.output,
                  '  END'||' '||'1276069.1 '||'     '||
                  to_char(sysdate, 'DD-MON-YYYY:HH24:MI:SS'));

EXCEPTION 
      
  WHEN OTHERS THEN
     FND_LOG.STRING(10, '1276069.1 ','Error is : ' || SQLERRM);
     AP_Acctg_Data_Fix_PKG.Print('Error is : ' || SQLERRM);

END ;

--ap_del_itmlines_sel.sql 





--ap_wrng_par_rev_1_sel.sql / ap_wrng_par_rev_2_sel.sql
/*REM +=======================================================================+
REM | FILENAME                                                              |
REM |     ap_wrng_par_rev_1_sel.sql / ap_wrng_par_rev_2_sel.sql             |
REM |                                                                       |
REM | DESCRIPTION                                                           |
REM * Description: Script to identify the following types of corruptions    *
REM *        in 11i reversed distributions.                                 *
REM *        1. Reversal distribution amount not reversing parent           *
REM *        distribution amount.                                           *
REM *        2. Reversal distribution line type not same as parent          *
REM *        distribution line type.                                        *
REM *        3. Multiple reversal distributions stamped with same parent    *
REM *        reversal id.                                                   *
REM *        4. Reversal distribution where parent distribution does not    *
REM *        exist.                                                         *
REM *        5. Parent distribution with reversal_flag stamped Y but no     *
REM *        reversing distribution.                                        *
REM *        6. Reversal distribution stamped with parent reversal id but   *
REM *        reversal flag is null                                          *
REM *        7. Reversal distribution exists but the reversal flag is not Y *
REM * RCA  : For Corruption Type 1 and 2 : 9214996                          *
REM +=======================================================================+*/

DECLARE

  row_cnt NUMBER := 0;

BEGIN  

FND_File.Put_Line(fnd_file.output,
                   '---------------------------------------------------------');
FND_File.Put_Line(fnd_file.output,
                  'START'||' '||'1276055.1'||'     '||
                  to_char(sysdate, 'DD-MON-YYYY:HH24:MI:SS'));

BEGIN
 EXECUTE IMMEDIATE 'DROP TABLE AP_TEMP_DATA_DRIVER_10168238';
EXCEPTION
  WHEN OTHERS THEN
    NULL;
END;
BEGIN

EXECUTE IMMEDIATE  'CREATE TABLE AP_TEMP_DATA_DRIVER_10168238(
 			INVOICE_ID       NUMBER,
			PARENT_DIST_ID   NUMBER,
			REVERSAL_DIST_ID NUMBER,
			CORRUPTION_TYPE  NUMBER,
			PROCESS_FLAG     VARCHAR2(1) DEFAULT ''Y'')';



EXECUTE IMMEDIATE 
           'INSERT INTO AP_TEMP_DATA_DRIVER_10168238
		(
		INVOICE_ID,
		PARENT_DIST_ID,
		REVERSAL_DIST_ID,
		CORRUPTION_TYPE,
		PROCESS_FLAG
		)
	       (SELECT a.* FROM 
		(SELECT /*+ parallel(d1) */ d1.invoice_id invoice_id,
		  d2.invoice_distribution_id parent_dist_id,
		  d1.invoice_distribution_id reversal_dist_id,
		  1 corruption_type,
		  ''Y'' process_flag
		FROM ap_invoice_dists_arch d1,
		  ap_invoice_dists_arch d2
		WHERE d1.invoice_id       = d2.invoice_id
		AND d1.parent_reversal_id = d2.invoice_distribution_id
		AND d1.amount            <> (-1)*d2.amount
		UNION
		SELECT /*+ parallel(d1) */ d1.invoice_id invoice_id,
		  d2.invoice_distribution_id parent_dist_id,
		  d1.invoice_distribution_id reversal_dist_id,
		  2 corruption_type,
		  ''Y'' process_flag
		FROM ap_invoice_dists_arch d1,
		  ap_invoice_dists_arch d2
		WHERE d1.invoice_id           = d2.invoice_id
		AND d1.parent_reversal_id     = d2.invoice_distribution_id
		AND d1.line_type_lookup_code <> d2.line_type_lookup_code
		UNION
		SELECT /*+ parallel(aid1) */ aid1.invoice_id invoice_id,
		  aid1.parent_reversal_id parent_dist_id,
		  NULL reversal_dist_id,
		  3 corruption_type,
		  ''Y'' process_flag
		FROM ap_invoice_dists_arch aid1
		WHERE aid1.parent_reversal_id IS NOT NULL
		GROUP BY aid1.invoice_id,
		  aid1.parent_reversal_id
		HAVING COUNT(aid1.parent_reversal_id) > 1
		UNION
                SELECT /*+ parallel(aid1) */ aid1.invoice_id parent_invoice_id,
		  aid1.invoice_distribution_id parent_dist_id,
		  aid1.parent_reversal_id reversal_dist_id,
		  4 corruption_type,
		  ''Y'' process_flag
		FROM ap_invoice_dists_arch aid1
		WHERE aid1.parent_reversal_id IS NOT NULL
		AND NOT EXISTS
		  (SELECT 1
		  FROM ap_invoice_dists_arch aid2
		  WHERE aid2.invoice_id            = aid1.invoice_id
		  AND aid2.invoice_distribution_id = aid1.parent_reversal_id
		  )
		UNION
		SELECT /*+ parallel(aid1) */ aid1.invoice_id parent_invoice_id,
		  aid1.invoice_distribution_id parent_dist_id,
		  aid1.parent_reversal_id reversal_dist_id,
		  5 corruption_type,
		  ''Y'' process_flag
		FROM ap_invoice_dists_arch aid1
		WHERE aid1.reversal_flag     = ''Y''
		AND aid1.parent_reversal_id IS NULL
		AND NOT EXISTS
		  (SELECT 1
		  FROM ap_invoice_dists_arch aid2
		  WHERE aid2.parent_reversal_id IS NOT NULL
		  AND   aid2.invoice_id          = aid1.invoice_id
		  AND aid2.parent_reversal_id    = aid1.invoice_distribution_id
		  )
		UNION
		SELECT /*+ parallel(aid1) */ aid1.invoice_id parent_invoice_id,
		  aid1.invoice_distribution_id parent_dist_id,
		  aid1.parent_reversal_id reversal_dist_id,
		  6 corruption_type,
		  ''Y'' process_flag
		FROM ap_invoice_dists_arch aid1
		WHERE aid1.parent_reversal_id IS NOT NULL
		AND NVL(aid1.reversal_flag,''N'') = ''N''
		UNION
		SELECT /*+ parallel(aid1) */ aid1.invoice_id parent_invoice_id,
		  aid2.invoice_distribution_id parent_dist_id,
		  aid1.invoice_distribution_id reversal_dist_id,
		  7 corruption_type,
		  ''Y'' process_flag
		FROM ap_invoice_dists_arch aid1,
		     ap_invoice_dists_arch aid2
		WHERE aid1.parent_reversal_id IS NOT NULL
		AND   aid1.invoice_id = aid2.invoice_id
		AND   aid1.line_type_lookup_code = aid2.line_type_lookup_code
		AND   aid1.parent_reversal_id = aid2.invoice_distribution_id
		AND   aid2.parent_reversal_id IS NULL
		AND NVL(aid2.reversal_flag,''N'') = ''N''
		) a WHERE a.invoice_id = :1)'
		USING l_invoice_id;

      row_cnt := SQL%ROWCOUNT;

      EXCEPTION
WHEN OTHERS THEN
DBMS_OUTPUT.PUT_LINE('IN EXP 1276055.1');
DBMS_OUTPUT.PUT_LINE(SQLERRM);
		   
END;		   

IF row_cnt > 0 THEN
   l_select_list := 'INVOICE_ID,PARENT_DIST_ID,REVERSAL_DIST_ID,CORRUPTION_TYPE,PROCESS_FLAG';
   l_table_name := 'AP_TEMP_DATA_DRIVER_10168238';
   l_where_clause := 'WHERE 1=1 ORDER BY INVOICE_ID,PARENT_DIST_ID';
  
   AP_Acctg_Data_Fix_PKG.Print('Invoice has wrong 11i parent reversal ids');  
   AP_Acctg_Data_Fix_PKG.Print( 'SOLUTION : Follow Note 1276055.1');  



   AP_ACCTG_DATA_FIX_PKG.Print_html_table
      (p_select_list       => l_select_list,
       p_table_in          => l_table_name,
       p_where_in          => l_where_clause,
       P_calling_sequence  => l_calling_sequence);
	 

	
   PRINT_LINE;				

END IF;

FND_File.Put_Line(fnd_file.output,
                  '  END'||' '||'1276055.1'||'     '||
                  to_char(sysdate, 'DD-MON-YYYY:HH24:MI:SS'));


EXCEPTION 
      
  WHEN OTHERS THEN
     FND_LOG.STRING(10, '1276055.1','Error is : ' || SQLERRM);
     AP_Acctg_Data_Fix_PKG.Print('Error is : ' || SQLERRM);

END ;

--ap_wrng_par_rev_1_sel.sql/ap_wrng_par_rev_2_sel.sql





--ap_wrong_base_amt_sel.sql
/*REM +=======================================================================+
REM | FILENAME                                                              |
REM |     ap_wrong_base_amt_sel.sql                                           |
REM |                                                                       |
REM | DESCRIPTION                                                           |
REM |  The following selection script will identify all the invoices        |
REM |  with following issues.                                               |
REM |                                                                       |
REM |   1. Invoice header base amount is not matching with                  |
REM |      invoice header amount and exchange rates.                        |
REM |   2. Invoice header base amount not matching with                     |
REM |	   sum of invoice lines base amounts, because of                    |
REM |	   improper rounding.                                               |  
REM |   3. Each invoice line base amount and corresponding line             | 
REM |	   sum of distributions base amounts are not matching,              | 
REM |	   because of improper rounding.                                    |
REM |   4. Invoice distributions amount and base amount have opposite       |
REM |	   signs.  Observed in most of ITEM,ACCRUAL,ERV,TRV dist types.     | 
REM |   5. Incorrect base amount calculated because of wrong ERV/TRV        |
REM |	   calculation. These base amounts causing to cr/dr amounts         |
REM |	   under different accounts improperly.                             |
REM |	                                                                    |
REM |   a. Table AP_TEMP_DATA_DRIVER_9574881 will contain details of all    |
REM |      such invoices.                                                   |
REM |   b. Next ap_undo_act_encumb_acctg.sql need to be run in order        |
REM |      for the invoices and payments undo accounting.                   |
REM |   c. Next ap_wrong_base_amt_fix.sql  need to be run in order          |
REM |      for the invoice to be corrected.                                 |
REM |                                                                       |
REM +=======================================================================+*/

DECLARE

  row_cnt NUMBER := 0;

BEGIN  

FND_File.Put_Line(fnd_file.output,
                   '---------------------------------------------------------');
FND_File.Put_Line(fnd_file.output,
                  'START'||' '||'1276043.1'||'     '||
                  to_char(sysdate, 'DD-MON-YYYY:HH24:MI:SS'));

BEGIN
 EXECUTE IMMEDIATE 'DROP TABLE AP_TEMP_DATA_DRIVER_9574881';
EXCEPTION
  WHEN OTHERS THEN
    NULL;
END;
BEGIN

EXECUTE IMMEDIATE 'CREATE TABLE AP_TEMP_DATA_DRIVER_9574881 AS      
		   SELECT invoice_id,ai.invoice_num,ai.org_id,ai.cancelled_date,
		   ''Y'' process_flag,'' '' REASON 
		   FROM ap_invoices_all ai WHERE 1=2';


EXECUTE IMMEDIATE 'INSERT INTO AP_TEMP_DATA_DRIVER_9574881  ' ||
          'SELECT a.* FROM ( ' ||
          ' SELECT ai.invoice_id, ai.invoice_num,ai.org_id,' ||
	  '        ai.cancelled_date, ''Y'' process_flag, ' ||
          '       ''header base amount issue'' REASON ' ||
          ' FROM  AP_INVOICES_ALL ai, ' ||
          '       AP_SYSTEM_PARAMETERS_ALL asp ' ||
          ' WHERE NVL(ai.historical_flag,''N'') <> ''Y'' ' ||
          '   AND ai.exchange_rate IS NOT NULL ' ||
          '   AND ai.org_id = asp.org_id  ' ||
          '   AND ap_utilities_pkg.ap_round_currency('||
 	  '       invoice_amount * exchange_rate, base_currency_code) '||
	  '          <> base_amount  ' ||
	  ' UNION ALL '||
	  ' SELECT ai.invoice_id, ai.invoice_num,ai.org_id,' ||
	  '        ai.cancelled_date, ''Y'' process_flag, ' ||
          '       ''lines base amount issue'' REASON ' ||
	  ' FROM  AP_INVOICES_ALL ai, '||
	  '       AP_SYSTEM_PARAMETERS_ALL asp '||
	  ' WHERE NVL(ai.historical_flag,''N'') <> ''Y'' ' ||
	  '   AND ai.exchange_rate IS NOT NULL ' ||
          '   AND ai.org_id = asp.org_id  ' ||
          '   AND ap_invoices_utility_pkg.get_approval_status( '||
          '       ai.invoice_id,ai.invoice_amount, ai.payment_status_flag, '||
	  '          ai.invoice_type_lookup_code) <> ''NEVER APPROVED'' '|| 
          '   AND ai.invoice_amount = ( SELECT SUM(ail.amount) + '||
          '                 DECODE(NVL(ai.net_of_retainage_flag,''N''), '||
	  '			   ''Y'',SUM(NVL(retained_amount,0)),0) '||
	  '                 FROM AP_INVOICE_LINES_ALL ail '||
	  '		    WHERE ail.invoice_id = ai.invoice_id '||
	  '		     AND ail.line_type_lookup_code <> ''AWT'' '||
          '                  AND ((ail.prepay_invoice_id IS NOT NULL '||
          '                         AND nvl(ail.invoice_includes_prepay_flag,'||
	  '                                  ''N'') = ''Y'')' ||
	  '			  OR ail.prepay_invoice_id IS NULL))' || 
          '   AND NVL(ai.base_amount,0) <> '||
	  '              (SELECT SUM(NVL(base_amount,0))  + '||
          '               DECODE(NVL(ai.net_of_retainage_flag,''N''), '||
          '		            ''Y'',ap_utilities_pkg.ap_round_currency( '||
 	  '		         SUM(NVL(retained_amount,0))*ai.exchange_rate,'||
	  '                          asp.base_currency_code), 0) '||
          '               FROM AP_INVOICE_LINES_ALL ail '||
          '      	  WHERE ail.invoice_id = ai.invoice_id '||
	  '		   AND ail.line_type_lookup_code <> ''AWT'' '||
          '	           AND (( ail.prepay_invoice_id IS NOT NULL '|| 
  	  '			 AND NVL(ail.invoice_includes_prepay_flag,'||
	  ' 			 ''N'') = ''Y'')' ||
          '		    OR ail.prepay_invoice_id IS NULL)) '||
          ' UNION ALL ' ||
          ' SELECT DISTINCT ai.invoice_id, ai.invoice_num,ai.org_id,' ||
	  '                 ai.cancelled_date, ''Y'' process_flag, ' ||
          '       ''dists base amount issue'' REASON ' ||
          ' FROM AP_INVOICES_ALL ai, AP_INVOICE_LINES_ALL ail '||
	  ' WHERE NVL(ai.historical_flag,''N'') <> ''Y'' ' ||
	  '   AND ai.exchange_rate is not null ' ||
          '   AND ai.invoice_id = ail.invoice_id '||
	  '   AND ail.base_amount IS NOT NULL '||
          '   AND NOT EXISTS (SELECT ''unvalidated dists exists'' '||
	  '                   FROM   AP_INVOICE_DISTRIBUTIONS_ALL aid1' ||
	  '                   WHERE  aid1.invoice_id = ai.invoice_id'||
	  '                     AND  nvl(aid1.match_status_flag,''N'') = ''N'' )' ||
	  '   AND ail.amount =  (SELECT SUM(aid2.amount) '||
          '                      FROM AP_INVOICE_DISTRIBUTIONS_ALL aid2 '||
	  '		         WHERE aid2.invoice_id = ail.invoice_id '||
	  '		          AND aid2.invoice_line_number = ail.line_number) '||
          '   AND ail.base_amount <> '||
	  '               (SELECT SUM(NVL(aid.base_amount,0)) '||
          '                           FROM AP_INVOICE_DISTRIBUTIONS_ALL aid '||
	  '		              WHERE aid.invoice_id = ail.invoice_id '||
	  '		               AND aid.invoice_line_number = ail.line_number) '||
          ' UNION ALL '||
	  ' SELECT ai.invoice_id, ai.invoice_num,ai.org_id,' ||
	  '        ai.cancelled_date, ''Y'' process_flag, ' ||
          '       ''wrong variance'' REASON ' ||
          ' FROM AP_INVOICES_ALL ai '||
          ' WHERE NVL(ai.historical_flag,''N'') <> ''Y'' '||
          '  AND ai.exchange_rate IS NOT NULL '||
          '  AND EXISTS(SELECT ''wrong variance'' '||
          '             FROM AP_INVOICE_DISTRIBUTIONS_ALL aid '||
	  '	        WHERE aid.invoice_id = ai.invoice_id  '||
	  '	         AND (aid.po_distribution_id IS NOT NULL '||
	  '	               OR aid.rcv_transaction_id IS NOT NULL)'||
          '              AND NVL(aid.dist_match_type,''NOT_MATCHED'')'||
	  '                 IN (''ITEM_TO_PO'',''ITEM_TO_RECEIPT'',''NOT_MATCHED'','||
	  '	                ''ITEM_TO_SERVICE_PO'',''ITEM_TO_SERVICE_SHIPMENT'','||
	  '                     ''OTHER_TO_RECEIPT'')'||
	  '	         AND ( (aid.amount > 0 and aid.base_amount <0) '||
	  '	              OR(aid.amount < 0 and aid.base_amount >0) '||
	  '	              OR(aid.line_type_lookup_code in (''ITEM'',''ACCRUAL'')'||
	  '	                 AND aid.base_amount <> '||
	  '	                     (SELECT ap_utilities_pkg.ap_round_currency '||
 	  '		                (aid1.amount * NVL(rt.currency_conversion_rate,pod.rate),'||
	  '			         asp.base_currency_code)'||
	  '		              FROM AP_INVOICE_DISTRIBUTIONS_ALL aid1,'||
	  '		                   PO_DISTRIBUTIONS_ALL pod,'||
	  '			           RCV_TRANSACTIONS rt,'||
	  '			           AP_SYSTEM_PARAMETERS_ALL asp'||
	  '		              WHERE aid1.invoice_distribution_id = aid.invoice_distribution_id '||
	  '		               AND aid1.po_distribution_id = pod.po_distribution_id '||
	  '			       AND aid1.rcv_transaction_id = rt.transaction_id (+) '||
	  '			       AND aid1.org_id = asp.org_id) ) ))' ||
	  '  ) a WHERE a.invoice_id = :1 '
                    USING l_invoice_id;

      row_cnt := SQL%ROWCOUNT;


      EXCEPTION
WHEN OTHERS THEN
DBMS_OUTPUT.PUT_LINE('IN EXP 1276043.1');
DBMS_OUTPUT.PUT_LINE(SQLERRM);
		   
END;		   

IF row_cnt > 0 THEN
   l_select_list := 'INVOICE_ID,INVOICE_NUM,ORG_ID,CANCELLED_DATE,PROCESS_FLAG,REASON';  
   l_table_name := 'AP_TEMP_DATA_DRIVER_9574881';
   l_where_clause := 'WHERE 1=1 ORDER BY INVOICE_ID';
  
   AP_Acctg_Data_Fix_PKG.Print('Invoice has issue with its base amounts (header/lines/dists)');  
   AP_Acctg_Data_Fix_PKG.Print( 'SOLUTION : Follow Note 1276043.1');  



   AP_ACCTG_DATA_FIX_PKG.Print_html_table
      (p_select_list       => l_select_list,
       p_table_in          => l_table_name,
       p_where_in          => l_where_clause,
       P_calling_sequence  => l_calling_sequence);
	 

	
   PRINT_LINE;				

END IF;

FND_File.Put_Line(fnd_file.output,
                  '  END'||' '||'1276043.1'||'     '||
                  to_char(sysdate, 'DD-MON-YYYY:HH24:MI:SS'));


EXCEPTION 
      
  WHEN OTHERS THEN
     FND_LOG.STRING(10, '1276043.1','Error is : ' || SQLERRM);
     AP_Acctg_Data_Fix_PKG.Print('Error is : ' || SQLERRM);

END ;

--ap_wrong_base_amt_sel.sql 



--ap_inc_pay_schedules_sel.sql
/*REM +=======================================================================+
REM | FILENAME                                                                  |
REM |     ap_inc_pay_schedules_sel.sql                                          |
REM |                                                                           |
REM | DESCRIPTION                                                               |
REM | This script will select all the invoices which have incorrect data in     |
REM | payment schedules, that is if amount_remaining/payment_status_flag is     |
REM | wrong or NULL.It also selects invoices which have incorrect amount_paid / |
REM | payment_status_flag in invoice headers.                                   |
REM | Overpaid invoices will also be considered and those invoices will be      |
REM | inserted into a temp table ap_overpaid_invs_9102659 which will lateron    |
REM | be correct by the user.                                                   |
REM +=======================================================================+*/

DECLARE

  row_cnt NUMBER := 0;

BEGIN  

FND_File.Put_Line(fnd_file.output,
                   '---------------------------------------------------------');
FND_File.Put_Line(fnd_file.output,
                  'START'||' '||'1174813.1'||'     '||
                  to_char(sysdate, 'DD-MON-YYYY:HH24:MI:SS'));

BEGIN
 EXECUTE IMMEDIATE 'DROP TABLE ap_temp_data_driver_9102659';
EXCEPTION
  WHEN OTHERS THEN
    NULL;
END;
BEGIN

EXECUTE IMMEDIATE
	 'CREATE TABLE ap_temp_data_driver_9102659 AS        
        SELECT invoice_id
		  ,invoice_num
		  ,org_id
		  ,description Reason
		  ,''Y'' process_flag
          FROM ap_invoices_all
	   WHERE 1=2';


    Execute Immediate
           'INSERT INTO ap_temp_data_driver_9102659 
 		SELECT distinct ap.invoice_id,ap.invoice_num,ap.org_id,ap.Reason,''Y'' process_flag
 		  FROM 
		     (SELECT ''Incorrect Amt Paid'' Reason
				  ,ai.invoice_id
		              ,ai.invoice_num
          		        ,ai.org_id
				  ,ai.invoice_amount
				  ,ai.amount_paid
		      	  ,(SELECT AP_UTILITIES_PKG.ap_round_currency(SUM(aid.amount) *
				 		NVL(ai.payment_cross_rate,1),ai.payment_currency_code)
                 			FROM ap_invoice_distributions aid,ap_invoice_lines ail
		                 WHERE ail.invoice_id=ai.invoice_id
					 AND aid.invoice_id=ai.invoice_id
					 AND ail.line_number = aid.invoice_line_number  
			             AND aid.prepay_distribution_id is not null
	 				 AND nvl(ail.invoice_includes_prepay_flag,''N'')<>''Y''
                		   )prepay_amt
		              ,(SELECT SUM(aip.amount)
            		      FROM ap_invoice_payments aip
		                 WHERE aip.invoice_id =ai.invoice_id
		               )pay_amt
		         FROM ap_invoices ai
		        WHERE ai.invoice_id = '||l_invoice_id|| '
		          AND ai.cancelled_date IS NULL
			    AND ai.validation_request_id is NULL
			           ) ap
		 WHERE (nvl(ap.pay_amt,0)-nvl(ap.prepay_amt,0))<>nvl(ap.amount_paid,0)
		 UNION 
		 SELECT ap.invoice_id,ap.invoice_num,ap.org_id,ap.Reason,''Y'' process_flag
		   FROM 
		      (SELECT ''Incorrect Amt Remaining'' Reason
		 		  ,ai.invoice_id
		              ,ai.invoice_num
		              ,ai.org_id
 		              ,ai.invoice_amount
				  ,ai.amount_paid
		      	  ,nvl(ai.discount_amount_taken,0) disc_amt
		              ,nvl(ai.payment_cross_rate,1) payment_cross_rate
		              ,(SELECT AP_UTILITIES_PKG.ap_round_currency(SUM(ail.amount) *
						 NVL(ai.payment_cross_rate,1),ai.payment_currency_code)
		                  FROM ap_invoice_lines ail
		                 WHERE ail.invoice_id=ai.invoice_id
             			 AND ail.line_type_lookup_code =''AWT''
             		   ) awt_amt
		              ,(SELECT AP_UTILITIES_PKG.ap_round_currency(SUM(ail.retained_amount) *
						 NVL(ai.payment_cross_rate,1),ai.payment_currency_code)
			            FROM ap_invoice_lines ail
			           WHERE ail.invoice_id=ai.invoice_id
                  	       AND nvl(ai.net_of_retainage_flag,''N'')<>''Y''
             		    ) retained_amt
		              ,(SELECT AP_UTILITIES_PKG.ap_round_currency(SUM(aid.amount) *
				 		 NVL(ai.payment_cross_rate,1),ai.payment_currency_code)
		                  FROM ap_invoice_distributions aid,ap_invoice_lines ail
   			           WHERE ail.invoice_id=ai.invoice_id
		      		 AND aid.invoice_id=ai.invoice_id
					 AND ail.line_number = aid.invoice_line_number  
		                   AND aid.prepay_distribution_id is not null
	 			       AND nvl(ail.invoice_includes_prepay_flag,''N'')<>''Y''
		               )prepay_amt
            		  ,(SELECT SUM(aip.amount)
			             FROM ap_invoice_payments aip
  			            WHERE aip.invoice_id =ai.invoice_id
		               )pay_amt
				 ,(SELECT SUM(amount_remaining)
            		     FROM ap_payment_schedules aps
		                WHERE aps.invoice_id=ai.invoice_id
            		  ) amount_remain
		       FROM ap_invoices ai
		      WHERE ai.invoice_id = '||l_invoice_id|| '
		        AND ai.cancelled_date IS NULL
		        AND ai.validation_request_id is NULL
			        ) ap
		  WHERE (((ap.invoice_amount*ap.payment_cross_rate)-disc_amt+nvl(ap.awt_amt,0)+nvl(ap.retained_amt,0))
				-(nvl(ap.pay_amt,0)-nvl(ap.prepay_amt,0)))<>nvl(ap.amount_remain,0)
		 UNION
		 SELECT distinct ap.invoice_id,ai.invoice_num,ap.org_id,''Null Amt Remaining'' Reason,''Y'' process_flag
		   FROM ap_payment_schedules ap,ap_invoices ai 
		  WHERE ap.amount_remaining IS NULL
		    AND ap.invoice_id=ai.invoice_id
		    AND ap.invoice_id= '||l_invoice_id|| '
		    AND ap.checkrun_id IS NULL
	        UNION
		 SELECT ap.invoice_id,ap.invoice_num,ap.org_id,ap.Reason,''Y'' process_flag
		   FROM 
		      (SELECT ''Fully paid but Payment_status_flag not Y'' Reason
				 ,ai.invoice_id
		             ,ai.invoice_num
		             ,ai.org_id
				 ,ai.invoice_amount
				 ,ai.amount_paid
            		 ,(SELECT AP_UTILITIES_PKG.ap_round_currency(SUM(aid.amount) *
				          NVL(ai.payment_cross_rate,1),ai.payment_currency_code)
            		     FROM ap_invoice_distributions aid,ap_invoice_lines ail
		                WHERE ail.invoice_id=ai.invoice_id
            		      AND aid.invoice_id=ai.invoice_id
					AND ail.line_number = aid.invoice_line_number  
		                  AND aid.prepay_distribution_id is not null
	 				AND nvl(ail.invoice_includes_prepay_flag,''N'')<>''Y''
		              )prepay_amt
            		 ,(SELECT SUM(aip.amount)
		                 FROM ap_invoice_payments aip
            		    WHERE aip.invoice_id =ai.invoice_id
		              )pay_amt
				 ,(SELECT SUM(aps.amount_remaining)
		                 FROM ap_payment_schedules aps
            		    WHERE aps.invoice_id=ai.invoice_id
		              )amount_remain
			   FROM ap_invoices ai,ap_payment_schedules aps1
		        WHERE ai.invoice_id= '||l_invoice_id|| '
		          AND aps1.invoice_id=ai.invoice_id
		          AND (ai.payment_status_flag <> ''Y'' OR aps1.payment_status_flag<>''Y'')
		          AND ai.cancelled_date IS NULL
		          AND ai.validation_request_id IS NULL
 		          AND aps1.checkrun_id IS NULL
			          ) ap
		  WHERE (nvl(ap.pay_amt,0)-nvl(ap.prepay_amt,0))=nvl(ap.amount_paid,0)
		    AND ap.amount_paid<>0
 		    AND ap.amount_remain=0
		 UNION
		 SELECT ap.invoice_id,ap.invoice_num,ap.org_id,ap.Reason,''Y'' process_flag
		   FROM 
		      (SELECT ''Inv unpaid but Payment_status_flag not N'' Reason
				 ,ai.invoice_id
            		 ,ai.invoice_num
		             ,ai.org_id
				 ,ai.invoice_amount
				 ,ai.amount_paid
		         FROM ap_invoices ai,ap_payment_schedules aps
			  WHERE ai.invoice_id= '||l_invoice_id|| '
		  	    AND ai.invoice_id=aps.invoice_id
        		    AND (nvl(ai.payment_status_flag,''N'')<>''N'' OR nvl(aps.payment_status_flag,''N'')<>''N'')
		          AND ai.cancelled_date IS NULL
			    AND ai.invoice_amount<>0
		          AND ai.validation_request_id IS NULL
		          AND aps.checkrun_id IS NULL
			         ) ap
		  WHERE nvl(ap.amount_paid,0)=0
		 UNION
		 SELECT distinct ap.invoice_id,ai.invoice_num,ap.org_id,''Null Payment status flag'' Reason,''Y'' process_flag
		   FROM ap_payment_schedules ap ,ap_invoices ai
		  WHERE (ap.payment_status_flag IS NULL OR ai.payment_status_flag is NULL)
		    AND ai.invoice_id= '||l_invoice_id|| '
		    AND ai.validation_request_id is NULL
 		    AND ap.invoice_id=ai.invoice_id
		    AND ap.checkrun_id IS NULL
		 UNION
		 SELECT ap.invoice_id,ap.invoice_num,ap.org_id,ap.Reason,''Y'' process_flag
		   FROM 
		      (SELECT ''Wrong pay status flag for partial paid invoices'' Reason
				 ,ai.invoice_id
            		 ,ai.invoice_num
		             ,ai.org_id
				 ,ai.invoice_amount
				 ,ai.amount_paid
				 ,nvl(ai.discount_amount_taken,0) disc_amt
    				 ,(SELECT AP_UTILITIES_PKG.ap_round_currency(SUM(aid.amount) *
    			      		NVL(ai.payment_cross_rate,1),ai.payment_currency_code)
		                 FROM ap_invoice_distributions aid,ap_invoice_lines ail
            		    WHERE ail.invoice_id=ai.invoice_id
		                  AND aid.invoice_id=ai.invoice_id
					AND ail.line_number = aid.invoice_line_number  
            		      AND aid.prepay_distribution_id is not null
			 		AND nvl(ail.invoice_includes_prepay_flag,''N'')<>''Y''
		              )prepay_amt
            		 ,(SELECT SUM(aip.amount)
		                 FROM ap_invoice_payments aip
            		    WHERE aip.invoice_id =ai.invoice_id
		              )pay_amt
				 ,(SELECT SUM(aps.amount_remaining)
		                 FROM ap_payment_schedules aps
            		    WHERE aps.invoice_id=ai.invoice_id
		              )amount_remain
		       FROM ap_invoices ai
	      	WHERE ai.invoice_id=  '||l_invoice_id|| '
	      	  AND ai.cancelled_date IS NULL
      		  AND ai.validation_request_id is NULL
		        AND ai.payment_status_flag in (''N'',''Y'')
			        ) ap
		  WHERE nvl(ap.amount_remain,0)<> 0
		    AND nvl(ap.amount_paid,0)<> 0
		    AND (nvl(ap.prepay_amt,0)<> 0 OR nvl(ap.pay_amt,0)<> 0)
		 UNION
		 SELECT ap.invoice_id,ap.invoice_num,ap.org_id,ap.Reason,''Y'' process_flag
		   FROM 
		      (SELECT ''Incorrect pay status flag for partial paid invoices'' Reason
				 ,aps.invoice_id
		             ,ai.invoice_num
				 ,aps.org_id
				 ,aps.payment_num
				 ,aps.amount_remaining
				 ,aps.gross_amount
				 ,aps.payment_status_flag
            		 ,(SELECT AP_UTILITIES_PKG.ap_round_currency(SUM(aid.amount) *
						 NVL(ai.payment_cross_rate,1),ai.payment_currency_code)
		                 FROM ap_invoice_distributions aid
            		    WHERE aid.invoice_id=ai.invoice_id
		                  AND aid.line_type_lookup_code =''AWT''
					AND aid.awt_invoice_payment_id IS NULL
            		  )inv_awt_amt
		     		 ,(SELECT SUM(aps.gross_amount)
            		     FROM ap_payment_schedules aps
		                WHERE aps.invoice_id=ai.invoice_id
            		  ) tot_gross_amt
		         FROM  ap_payment_schedules aps,
			         ap_invoices ai
		        WHERE  aps.invoice_id= '||l_invoice_id|| '
		          AND  ai.invoice_id=aps.invoice_id
		          AND  ai.invoice_amount<>0
			    AND  ai.cancelled_date IS NULL
			    AND  ai.validation_request_id is NULL
			    AND  aps.checkrun_id IS NULL
			    AND  nvl(ai.historical_flag,''N'')<>''Y''
			    		 ) ap
		  WHERE ap.gross_amount<>0
                    AND ap.tot_gross_amt<>0
		    AND ap.payment_status_flag <> decode(nvl(ap.amount_remaining,0), 0, ''Y'',
				(ap.gross_amount+(nvl(ap.inv_awt_amt,0)*nvl(ap.gross_amount,0)/nvl(ap.tot_gross_amt,1))), ''N'', ''P'')
		 UNION
		 SELECT ai.invoice_id,ai.invoice_num,ai.org_id,''Inc Amt Remn,paid for cancelled invs'' Reason,''Y'' process_flag
		   FROM ap_invoices ai
		  WHERE ai.cancelled_date IS NOT NULL
		    AND (nvl(ai.amount_paid,0)<>0 
                    OR exists (SELECT 1 
				      FROM ap_payment_schedules aps
		                 WHERE aps.invoice_id = ai.invoice_id
		   		       AND amount_remaining <> 0))
		    AND ai.invoice_id= '||l_invoice_id|| '
		    AND ai.validation_request_id is NULL ';

      row_cnt := SQL%ROWCOUNT;

      EXCEPTION
WHEN OTHERS THEN
DBMS_OUTPUT.PUT_LINE('IN EXP 10279090');
DBMS_OUTPUT.PUT_LINE(SQLERRM);
		   
END;		   

IF row_cnt > 0 THEN
   l_select_list := 'INVOICE_ID,INVOICE_NUM,ORG_ID,REASON';  
   l_table_name := 'AP_TEMP_DATA_DRIVER_9102659';
   l_where_clause := 'WHERE 1=1 ORDER BY REASON';
  
   AP_Acctg_Data_Fix_PKG.Print('Invoice has wrong payment status flag, amounts (or Mismatch with invoice) in payment schedules');  
   AP_Acctg_Data_Fix_PKG.Print( 'SOLUTION : Follow Note 1174813.1');  



   AP_ACCTG_DATA_FIX_PKG.Print_html_table
      (p_select_list       => l_select_list,
       p_table_in          => l_table_name,
       p_where_in          => l_where_clause,
       P_calling_sequence  => l_calling_sequence);
	 

	
   PRINT_LINE;				

END IF;

FND_File.Put_Line(fnd_file.output,
                  '  END'||' '||'1174813.1'||'     '||
                  to_char(sysdate, 'DD-MON-YYYY:HH24:MI:SS'));

EXCEPTION 
      
  WHEN OTHERS THEN
     FND_LOG.STRING(10, '1174813.1','Error is : ' || SQLERRM);
     AP_Acctg_Data_Fix_PKG.Print('Error is : ' || SQLERRM);
 
END ;

--ap_inc_pay_schedules_sel.sql 



--ap_sync_po_qty_amt_sel.sql
/*REM +=======================================================================+
REM | FILENAME                                                              |
REM |     ap_sync_po_qty_amt_sel.sql                                        |
REM |                                                                       |
REM | DESCRIPTION                                                           |
REM |   This script will identify all PO distributions that have a mis-     |
REM |   match with AP distributions for quantity/amount billed, quantity    |
REM |   /amount financed and quatity/amount recouped.                       |
REM +=======================================================================+*/

DECLARE

  row_cnt NUMBER := 0;

BEGIN  

FND_File.Put_Line(fnd_file.output,
                   '---------------------------------------------------------');
FND_File.Put_Line(fnd_file.output,
                  'START'||' '||'982072.1 '||'     '||
                  to_char(sysdate, 'DD-MON-YYYY:HH24:MI:SS'));

BEGIN
 EXECUTE IMMEDIATE 'DROP TABLE AP_PO_MISMATCH_9049862';
EXCEPTION
  WHEN OTHERS THEN
    NULL;
END;
BEGIN

EXECUTE IMMEDIATE 'CREATE TABLE AP_PO_MISMATCH_9049862(
	PO_HEADER_ID    NUMBER,
	PO_LINE_ID      NUMBER,
	LINE_LOCATION_ID   NUMBER,
	PO_RELEASE_ID     NUMBER,
	PO_DISTRIBUTION_ID    NUMBER,
	UPD_QUANTITY     NUMBER,
	UPD_AMOUNT      NUMBER,
	ORI_QUANTITY     NUMBER,
	ORI_AMOUNT      NUMBER,
	MATCH_TYPE       NUMBER,
	UOM_CODES	 VARCHAR2(200),
	PROCESS_FLAG VARCHAR2(1) default ''Y'')';


EXECUTE IMMEDIATE
		'Insert into AP_PO_MISMATCH_9049862(
		PO_HEADER_ID,
		PO_LINE_ID,
		LINE_LOCATION_ID,
		PO_RELEASE_ID,
		PO_DISTRIBUTION_ID,
		UPD_QUANTITY, 
		UPD_AMOUNT,
		ORI_QUANTITY,
		ORI_AMOUNT,
		MATCH_TYPE,
		UOM_CODES,
		PROCESS_FLAG  )
		(SELECT apd.po_header_id,
			apd.po_line_id,
			apd.line_location_id,
			apd.po_release_id,
			apd.po_distribution_id,
			SUM(NVL(apd.AID_QUAN,0)),
			SUM(NVL(apd.AID_AMT,0)),
			NVL(apd.PO_QUANTITY,0),
			NVL(apd.PO_AMOUNT,0),
			1 MATCH_TYPE,
			apd.UOM_CODES,
			apd.PROCESS_FLAG
		FROM (SELECT pod.po_header_id po_header_id,
			 pod.po_line_id  po_line_id,
			 pod.line_location_id line_location_id,
			 pod.po_release_id po_release_id,
			 pod.po_distribution_id po_distribution_id,
			 decode(nvl(aid.matched_uom_lookup_code,pll.unit_meas_lookup_code),
			 pll.unit_meas_lookup_code,aid.quantity_invoiced,
			 aid.quantity_invoiced * NVL(AP_Acctg_Data_Fix_PKG.UOM_CONVERT(
			 nvl(aid.matched_uom_lookup_code,pll.unit_meas_lookup_code),
			 pll.unit_meas_lookup_code, RSL.item_id),0)) AID_QUAN,
			 aid.amount     AID_AMT,
			 pod.quantity_financed  PO_QUANTITY,
			 pod.amount_financed    PO_AMOUNT,
			 /*Bug9756279*/
			 DECODE(NVL(AP_Acctg_Data_Fix_PKG.UOM_CONVERT(nvl(aid.matched_uom_lookup_code,
			 pll.unit_meas_lookup_code),pll.unit_meas_lookup_code, RSL.item_id),-999),-999,
			 aid.matched_uom_lookup_code||'' and ''||pll.unit_meas_lookup_code,''None'') UOM_CODES,
			 DECODE(NVL(AP_Acctg_Data_Fix_PKG.UOM_CONVERT(nvl(aid.matched_uom_lookup_code,
			 pll.unit_meas_lookup_code),pll.unit_meas_lookup_code, RSL.item_id),-999),-999,''E'',''Y'') process_flag
			 /*End of Bug9756279*/
			 FROM po_distributions_all pod,
				ap_invoice_distributions_all aid,
				po_lines_all pol,
				po_line_locations_all pll,
				ap_invoices_all ai,
				financials_system_params_all fsp,
				rcv_transactions rtxn,
				rcv_shipment_lines RSL
			WHERE pod.po_distribution_id = aid.po_distribution_id
			AND pod.line_location_id = pll.line_location_id
			AND ai.invoice_id = '||l_invoice_id||'
			AND pll.po_line_id = pol.po_line_id
			AND aid.invoice_id = ai.invoice_id
			AND ai.org_id = fsp.org_id
			AND NVL(fsp.purch_encumbrance_flag,''N'') = ''N''
			AND aid.line_type_lookup_code IN (''ITEM'', ''ACCRUAL'', ''IPV'')
			AND ai.invoice_type_lookup_code = ''PREPAYMENT''
			AND aid.rcv_transaction_id = RTXN.transaction_id (+)
			AND RTXN.shipment_line_id = RSL.shipment_line_id (+) ) apd
			GROUP BY apd.po_header_id,
				 apd.po_line_id,
				 apd.line_location_id,
				 apd.po_release_id,
				 apd.po_distribution_id,
				 apd.PO_QUANTITY,
				 apd.PO_AMOUNT,
				 apd.UOM_CODES,
				apd.PROCESS_FLAG
			HAVING  (Round(Nvl(apd.PO_QUANTITY,0),15) <> Round(Sum(nvl(apd.AID_QUAN,0)),15))
			OR (Round(Nvl(apd.PO_AMOUNT,0),15) <> Round(Sum(nvl(apd.AID_AMT,0)),15)))
		UNION
               (SELECT apd.po_header_id,
			apd.po_line_id,
			apd.line_location_id,
			apd.po_release_id,
			apd.po_distribution_id,
			SUM(NVL(apd.AID_QUAN,0)),
			SUM(NVL(apd.AID_AMT,0)),
			NVL(apd.PO_QUANTITY,0),
			NVL(apd.PO_AMOUNT,0),
			2 MATCH_TYPE,
			apd.UOM_CODES,
			apd.PROCESS_FLAG
		FROM (SELECT pod.po_header_id po_header_id,
			 pod.po_line_id  po_line_id,
		     	 pod.line_location_id line_location_id,
		    	 pod.po_release_id po_release_id,
		    	 pod.po_distribution_id po_distribution_id,
		    	 - decode(nvl(aid.matched_uom_lookup_code,pll.unit_meas_lookup_code),
			 pll.unit_meas_lookup_code,aid.quantity_invoiced,aid.quantity_invoiced 
			 * NVL(AP_Acctg_Data_Fix_PKG.UOM_CONVERT(nvl(aid.matched_uom_lookup_code,
			 pll.unit_meas_lookup_code),pll.unit_meas_lookup_code,RSL.item_id),0)) AID_QUAN,
		    	 -aid.amount            AID_AMT,
		   	 pod.quantity_recouped  PO_QUANTITY,
		   	 pod.amount_recouped   PO_AMOUNT,
		     	 /*End of Bug9756279*/
		    	 DECODE(NVL(AP_Acctg_Data_Fix_PKG.UOM_CONVERT(nvl(aid.matched_uom_lookup_code,
			 pll.unit_meas_lookup_code),pll.unit_meas_lookup_code, RSL.item_id),-999),-999,
			 aid.matched_uom_lookup_code||'' and ''||pll.unit_meas_lookup_code,''None'') UOM_CODES,
		     	 DECODE(NVL(AP_Acctg_Data_Fix_PKG.UOM_CONVERT(nvl(aid.matched_uom_lookup_code,
			 pll.unit_meas_lookup_code),pll.unit_meas_lookup_code, RSL.item_id),-999),-999,''E'',''Y'') process_flag
		    	 /*Bug9756279*/
			 FROM po_distributions_all pod,
				ap_invoice_distributions_all aid,
				po_lines_all pol,
				po_line_locations_all pll,
				ap_invoices_all ai,
				financials_system_params_all fsp,
				rcv_transactions rtxn,
				rcv_shipment_lines RSL
			WHERE pod.po_distribution_id = aid.po_distribution_id
			AND pod.line_location_id = pll.line_location_id
			AND ai.invoice_id = '||l_invoice_id||'
			AND pll.po_line_id = pol.po_line_id
			AND aid.invoice_id = ai.invoice_id
			AND ai.org_id = fsp.org_id
			AND NVL(fsp.purch_encumbrance_flag,''N'') = ''N''
			AND aid.line_type_lookup_code = ''PREPAY''
			AND ai.invoice_type_lookup_code <> ''PREPAYMENT''
			AND aid.rcv_transaction_id = RTXN.transaction_id (+)
			AND RTXN.shipment_line_id = RSL.shipment_line_id (+) ) apd
		GROUP BY apd.po_header_id,
		         apd.po_line_id,
			 apd.line_location_id,
			 apd.po_release_id,
			 apd.po_distribution_id,
			 apd.PO_QUANTITY,
			 apd.PO_AMOUNT,
			 apd.UOM_CODES,
			 apd.PROCESS_FLAG
		HAVING 	(Round(Nvl(apd.PO_QUANTITY,0),15) <> - Round(Sum(nvl(apd.AID_QUAN,0)),15))
		OR (Round(Nvl(apd.PO_AMOUNT,0),15) <>  -Round(Sum(nvl(apd.AID_AMT,0)),15)))
                UNION
	    	(SELECT apd.po_header_id,
			apd.po_line_id,
			apd.line_location_id,
			apd.po_release_id,
			apd.po_distribution_id,
			SUM(NVL(apd.AID_QUAN,0)),
			SUM(NVL(apd.AID_AMT,0)),
			NVL(apd.PO_QUANTITY,0),
			NVL(apd.PO_AMOUNT,0),
			3 MATCH_TYPE,
			apd.UOM_CODES,
			apd.PROCESS_FLAG
	   	FROM(SELECT pod.po_header_id po_header_id,
	        	 pod.po_line_id   po_line_id,
			 pod.line_location_id  line_location_id,
			 pod.po_release_id po_release_id,
			 pod.po_distribution_id po_distribution_id,
			 decode(nvl(aid.matched_uom_lookup_code,pll.unit_meas_lookup_code),
			 pll.unit_meas_lookup_code,aid.quantity_invoiced,
			 aid.quantity_invoiced * NVL(AP_Acctg_Data_Fix_PKG.UOM_CONVERT(nvl(aid.matched_uom_lookup_code,
			 pll.unit_meas_lookup_code),pll.unit_meas_lookup_code,RSL.item_id),0)) AID_QUAN,
			 aid.amount            AID_AMT,
			 pod.quantity_billed     PO_QUANTITY,
			 pod.amount_billed       PO_AMOUNT,
			 /*Bug9756279*/
			 DECODE(NVL(AP_Acctg_Data_Fix_PKG.UOM_CONVERT(nvl(aid.matched_uom_lookup_code,
			 pll.unit_meas_lookup_code),pll.unit_meas_lookup_code, RSL.item_id),-999),-999,
			 aid.matched_uom_lookup_code||'' and ''||pll.unit_meas_lookup_code,''None'') UOM_CODES,
			 DECODE(NVL(AP_Acctg_Data_Fix_PKG.UOM_CONVERT(nvl(aid.matched_uom_lookup_code,
			 pll.unit_meas_lookup_code),pll.unit_meas_lookup_code, RSL.item_id),-999),-999,''E'',''Y'') process_flag
			 /*End of Bug9756279*/
			 FROM po_distributions_all pod,
				ap_invoice_distributions_all aid,
				po_lines_all pol,
				po_line_locations_all pll,
				ap_invoices_all ai,
				financials_system_params_all fsp,
				rcv_transactions rtxn,
				rcv_shipment_lines RSL
			 WHERE pod.po_distribution_id = aid.po_distribution_id
			 AND pod.line_location_id = pll.line_location_id
			 AND pll.po_line_id = pol.po_line_id
			 AND aid.invoice_id = ai.invoice_id
		         AND ai.invoice_id = '||l_invoice_id||'
			 AND ai.org_id = fsp.org_id
			 AND NVL(fsp.purch_encumbrance_flag,''N'') = ''N''
			 AND aid.line_type_lookup_code IN (''ITEM'', ''ACCRUAL'', ''IPV'')
			 AND ai.invoice_type_lookup_code <> ''PREPAYMENT''
			 AND aid.rcv_transaction_id = RTXN.transaction_id (+)
			 AND RTXN.shipment_line_id = RSL.shipment_line_id (+) ) apd
		GROUP BY apd.po_header_id,
		 	 apd.po_line_id,
			 apd.line_location_id,
			 apd.po_release_id,
			 apd.po_distribution_id,
			 apd.PO_QUANTITY,
			 apd.PO_AMOUNT,
			 apd.UOM_CODES,
			 apd.PROCESS_FLAG
		HAVING  (Round(Nvl(apd.PO_QUANTITY,0),15) <> Round(Sum(nvl(apd.AID_QUAN,0)),15))
		OR (Round(Nvl(apd.PO_AMOUNT,0),15) <> Round(Sum(nvl(apd.AID_AMT,0)),15)))';


      row_cnt := SQL%ROWCOUNT;

      EXCEPTION
WHEN OTHERS THEN
DBMS_OUTPUT.PUT_LINE('IN EXP 982072.1 ');
DBMS_OUTPUT.PUT_LINE(SQLERRM);
		   
END;		   

IF row_cnt > 0 THEN
   l_select_list := 'PO_HEADER_ID,PO_LINE_ID,LINE_LOCATION_ID,PO_RELEASE_ID,PO_DISTRIBUTION_ID,UPD_QUANTITY,'||
                      'UPD_AMOUNT,ORI_QUANTITY,ORI_AMOUNT,MATCH_TYPE,UOM_CODES';  
   l_table_name := 'AP_PO_MISMATCH_9049862';
   l_where_clause := 'WHERE 1=1 ORDER BY PO_HEADER_ID,PO_LINE_ID';
  
   AP_Acctg_Data_Fix_PKG.Print('Mismatch in PO and AP for quantity/amount billed,finanaced and recouped');  
   AP_Acctg_Data_Fix_PKG.Print( 'SOLUTION : Follow Note 982072.1 ');  



   AP_ACCTG_DATA_FIX_PKG.Print_html_table
      (p_select_list       => l_select_list,
       p_table_in          => l_table_name,
       p_where_in          => l_where_clause,
       P_calling_sequence  => l_calling_sequence);
	 

	
   PRINT_LINE;				

END IF;

FND_File.Put_Line(fnd_file.output,
                  '  END'||' '||'982072.1 '||'     '||
                  to_char(sysdate, 'DD-MON-YYYY:HH24:MI:SS'));

EXCEPTION 
      
  WHEN OTHERS THEN
     FND_LOG.STRING(10, '982072.1 ','Error is : ' || SQLERRM);
     AP_Acctg_Data_Fix_PKG.Print('Error is : ' || SQLERRM);

END ;

--ap_sync_po_qty_amt_sel.sql 




--AP_Rel_Inv_frm_TermPPR_sel.sql
/*REM +=======================================================================+
REM | FILENAME                                                              |
REM |     AP_Rel_Inv_frm_TermPPR_sel.sql                                        |
REM |                                                                       |
REM | DESCRIPTION                                                           |
REM |     This data fix lists all the PPRs which are in                     |
REM |     Terminated/Confirmed/Review state but                                    |
REM |     whose associated invoices are still in selected state.            |
REM +=======================================================================+*/

DECLARE

  row_cnt NUMBER := 0;

BEGIN  

FND_File.Put_Line(fnd_file.output,
                   '---------------------------------------------------------');
FND_File.Put_Line(fnd_file.output,
                  'START'||' '||'874862.1 '||'     '||
                  to_char(sysdate, 'DD-MON-YYYY:HH24:MI:SS'));

BEGIN
 EXECUTE IMMEDIATE 'DROP TABLE ap_temp_data_driver_8525551';
EXCEPTION
  WHEN OTHERS THEN
    NULL;
END;
BEGIN

   EXECUTE Immediate 'CREATE TABLE ap_temp_data_driver_8525551
  (
    CHECKRUN_ID NUMBER(15),
    CHECK_DATE DATE,
    PPR_NAME       VARCHAR2(255),
    PPR_STATUS     VARCHAR2(30),
    INVOICES_HELD  NUMBER(15),
    SCHEDULES_HELD NUMBER(15)
  )';




EXECUTE IMMEDIATE
		'Insert into ap_temp_data_driver_8525551
SELECT /*+ index(APS, AP_PAYMENT_SCHEDULES_N4) */ aisc.checkrun_id,
				aisc.check_date,
				aisc.checkrun_name,
				/*This is AISC Status */
				aisc.status || '' (Case 1)'',
				COUNT(DISTINCT aps.invoice_id),
				COUNT(aps.invoice_id)
			FROM ap_inv_selection_criteria_all aisc,
				ap_payment_schedules_all aps
			WHERE NOT EXISTS
				(SELECT ''Corresponding PSR''
				FROM iby_pay_service_requests ipsr
				WHERE ipsr.calling_app_id              = 200
				AND ipsr.call_app_pay_service_req_code = aisc.checkrun_name)
				AND aps.checkrun_id = aisc.checkrun_id
				AND aps.invoice_id = '||l_invoice_id||'
			GROUP BY aisc.checkrun_id,
					aisc.check_date,
					aisc.checkrun_name,
					aisc.status
        
			UNION
			/* CASE 2 */
			SELECT aisc.checkrun_id,
					aisc.check_date,
					ipsr.call_app_pay_service_req_code,
					AP_PAYMENT_UTIL_PKG.get_psr_status(ipsr.payment_service_request_id,ipsr.payment_service_request_status) || '' (Case 2)'',
					COUNT(DISTINCT invoice_id),
					COUNT(invoice_id)
			FROM iby_pay_service_requests ipsr,
				ap_inv_selection_criteria_all aisc,
				ap_payment_schedules_all aps
			WHERE aisc.checkrun_name = ipsr.call_app_pay_service_req_code
			AND aps.checkrun_id      = aisc.checkrun_id
			AND ipsr.calling_app_id  = 200
			AND AP_PAYMENT_UTIL_PKG.get_psr_status(ipsr.payment_service_request_id,ipsr.payment_service_request_status) = ''TERMINATED''
			AND aps.invoice_id = '||l_invoice_id||'
			GROUP BY aisc.checkrun_id,
				aisc.check_date,
				ipsr.call_app_pay_service_req_code,
				AP_PAYMENT_UTIL_PKG.get_psr_status(ipsr.payment_service_request_id,ipsr.payment_service_request_status)

			UNION
			/* CASE 3 */
			SELECT aisc.checkrun_id,
				aisc.check_date,
				ipsr.call_app_pay_service_req_code,
				AP_PAYMENT_UTIL_PKG.get_psr_status(ipsr.payment_service_request_id,ipsr.payment_service_request_status) || '' (Case 3)'',
				COUNT(DISTINCT invoice_id),
				COUNT(invoice_id)
			FROM iby_pay_service_requests ipsr,
				ap_inv_selection_criteria_all aisc,
				ap_payment_schedules_all aps,
				iby_docs_payable_all idp 
			WHERE aps.checkrun_id                                                     = aisc.checkrun_id
			AND ipsr.call_app_pay_service_req_code                                    = aisc.checkrun_name
			AND ipsr.calling_app_id                                                   = 200
			AND idp.calling_app_doc_unique_ref1                                       = aps.checkrun_id
			AND idp.calling_app_doc_unique_ref2                                       = aps.invoice_id
			AND idp.calling_app_doc_unique_ref3                                       = aps.payment_num
			AND idp.payment_service_request_id                                        = ipsr.payment_service_request_id
			AND idp.document_status                                                   IN 
				(''REMOVED'',''REMOVED_INSTRUCTION_TERMINATED'', ''REMOVED_REQUEST_TERMINATED'',''REMOVED_PAYMENT_REMOVED'',''REMOVED_PAYMENT_SPOILED'',
				''FAILED_VALIDATION'', ''PAYMENT_FAILED_VALIDATION'', ''REJECTED'' , ''FAILED_BY_REJECTION_LEVEL'' , ''FAILED_BY_CALLING_APP'',
				''FAILED_BY_RELATED_DOCUMENT'',''REMOVED_PAYMENT_STOPPED'',''REMOVED_PAYMENT_VOIDED'')
			AND aps.invoice_id = '||l_invoice_id||'
			GROUP BY aisc.checkrun_id,
				aisc.check_date,
				ipsr.call_app_pay_service_req_code,
				AP_PAYMENT_UTIL_PKG.get_psr_status(ipsr.payment_service_request_id,ipsr.payment_service_request_status)

			UNION
			/* CASE 4 */
			SELECT aisc.checkrun_id,
				aisc.check_date,
				ipsr.call_app_pay_service_req_code,
				AP_PAYMENT_UTIL_PKG.get_psr_status(ipsr.payment_service_request_id,ipsr.payment_service_request_status) || '' (Case 4)'',
				COUNT(DISTINCT invoice_id),
				COUNT(invoice_id)
			FROM iby_pay_service_requests ipsr,
				ap_inv_selection_criteria_all aisc,
				ap_payment_schedules_all aps
			WHERE aps.checkrun_id                                                     = aisc.checkrun_id
			AND ipsr.call_app_pay_service_req_code                                    = aisc.checkrun_name
			AND ipsr.calling_app_id                                                   = 200
			AND AP_PAYMENT_UTIL_PKG.get_psr_status
            (ipsr.payment_service_request_id,ipsr.payment_service_request_status) = ''CONFIRMED''
			AND NOT EXISTS
				(SELECT ''Corresponding Docs Payable'' from iby_docs_payable_all idp
				WHERE idp.calling_app_doc_unique_ref1                                     = aps.checkrun_id
				AND idp.calling_app_doc_unique_ref2                                       = aps.invoice_id
				AND idp.calling_app_doc_unique_ref3                                       = aps.payment_num
				AND idp.payment_service_request_id                                        = ipsr.payment_service_request_id)
				AND aps.invoice_id = '||l_invoice_id||'
			GROUP BY aisc.checkrun_id,
				aisc.check_date,
				ipsr.call_app_pay_service_req_code,
				AP_PAYMENT_UTIL_PKG.get_psr_status(ipsr.payment_service_request_id,ipsr.payment_service_request_status)
		  
			UNION
			/* CASE 5 */
			SELECT aisc.checkrun_id,
				aisc.check_date,
				aisc.checkrun_name,
				aisc.status || '' (Case 5)'',
				COUNT(DISTINCT aps.invoice_id),
				COUNT(aps.invoice_id)
			FROM ap_inv_selection_criteria_all aisc,
				ap_payment_schedules_all aps
			WHERE aps.checkrun_id = aisc.checkrun_id
			AND NOT EXISTS
				(SELECT ''Data in AP_SELECTED_INVOICES_ALL''
				FROM ap_selected_invoices_all asi
				WHERE asi.checkrun_id = aisc.checkrun_id)
			AND aps.invoice_id = '||l_invoice_id||'
			GROUP BY aisc.checkrun_id,
					aisc.check_date,
					aisc.checkrun_name,
					aisc.status
			
			UNION
			/* CASE 6 */
            SELECT aisc.checkrun_id,
				aisc.check_date,
				aisc.checkrun_name,
				aisc.status || '' (Case 5)'',
				COUNT(DISTINCT aps.invoice_id),
				COUNT(aps.invoice_id)
			FROM ap_inv_selection_criteria_all aisc,
				ap_payment_schedules_all aps
			WHERE aps.checkrun_id = aisc.checkrun_id
			AND EXISTS
				(select 1
				from ap_selected_invoices_all si2
				, ap_payment_schedules_all ps
				where si2.checkrun_id = aisc.checkrun_id
				and si2.invoice_id = ps.invoice_id
				and si2.payment_num = ps.payment_num
				and si2.org_id is null
				and ps.org_id is not null)
			AND aps.invoice_id = '||l_invoice_id||'
			GROUP BY aisc.checkrun_id,
				aisc.check_date,
				aisc.checkrun_name,
				aisc.status
            
			UNION
			/* CASE 7 */
			SELECT aisc.checkrun_id,
				aisc.check_date,
				ipsr.call_app_pay_service_req_code,
				AP_PAYMENT_UTIL_PKG.get_psr_status(ipsr.payment_service_request_id,ipsr.payment_service_request_status) || '' (Case 7)'',
				COUNT(DISTINCT invoice_id),
				COUNT(invoice_id)
			FROM iby_pay_service_requests ipsr,
				ap_inv_selection_criteria_all aisc,
				ap_payment_schedules_all aps,
				iby_docs_payable_all idp 
			WHERE aps.checkrun_id                                                     = aisc.checkrun_id
			AND ipsr.call_app_pay_service_req_code                                    = aisc.checkrun_name
			AND ipsr.calling_app_id                                                   = 200
			AND AP_PAYMENT_UTIL_PKG.get_psr_status
				(ipsr.payment_service_request_id,ipsr.payment_service_request_status) = ''CONFIRMED''
			AND idp.calling_app_doc_unique_ref1                                       = aps.checkrun_id
			AND idp.calling_app_doc_unique_ref2                                       = aps.invoice_id
			AND idp.calling_app_doc_unique_ref3                                       = aps.payment_num
			AND idp.payment_service_request_id                                        = ipsr.payment_service_request_id
			AND idp.document_status                                                   IN      (''PAYMENT_CREATED'')
			AND exists
				(SELECT ''AP Pmt Data Exists''
				FROM iby_docs_payable_all idp,
					ap_checks_all ac,
					ap_invoice_payments_all aip,
					ap_payment_history_all aph
				WHERE idp.payment_id        = ac.payment_id
				AND ac.check_id             = aip.check_id
				AND aip.invoice_id          = aps.invoice_id
				AND aip.payment_num         = aps.payment_num
				AND aip.accounting_event_id = aph.accounting_event_id
				AND ac.check_id             = aph.check_id
				AND nvl(aip.reversal_flag,''N'') <> ''Y'')
			AND aps.invoice_id = '||l_invoice_id||'
			GROUP BY aisc.checkrun_id,
				aisc.check_date,
				ipsr.call_app_pay_service_req_code,
				AP_PAYMENT_UTIL_PKG.get_psr_status(ipsr.payment_service_request_id,ipsr.payment_service_request_status)';
		


      row_cnt := SQL%ROWCOUNT;

      EXCEPTION
WHEN OTHERS THEN
DBMS_OUTPUT.PUT_LINE('IN EXP 874862.1 ');
DBMS_OUTPUT.PUT_LINE(SQLERRM);
		   
END;		   

IF row_cnt > 0 THEN
   l_select_list := 'CHECKRUN_ID,CHECK_DATE,PPR_NAME,PPR_STATUS,INVOICES_HELD,SCHEDULES_HELD';  
   l_table_name := 'ap_temp_data_driver_8525551';
   l_where_clause := 'WHERE 1=1 ';
  
   AP_Acctg_Data_Fix_PKG.Print('Invoice not released from PPR');  
   AP_Acctg_Data_Fix_PKG.Print( 'SOLUTION : Follow Note 874862.1 ');  



   AP_ACCTG_DATA_FIX_PKG.Print_html_table
      (p_select_list       => l_select_list,
       p_table_in          => l_table_name,
       p_where_in          => l_where_clause,
       P_calling_sequence  => l_calling_sequence);
	 

	
   PRINT_LINE;				

END IF;

FND_File.Put_Line(fnd_file.output,
                  '  END'||' '||'874862.1 '||'     '||
                  to_char(sysdate, 'DD-MON-YYYY:HH24:MI:SS'));

EXCEPTION 
      
  WHEN OTHERS THEN
     FND_LOG.STRING(10, '874862.1 ','Error is : ' || SQLERRM);
     AP_Acctg_Data_Fix_PKG.Print('Error is : ' || SQLERRM);

END ;

--AP_Rel_Inv_frm_TermPPR_sel.sql 


-- non GDF Start

--  posted_dists_match_status_flag_sel.sql
/*REM +=======================================================================+
REM *  FILENAME                                                               *
REM *      posted_dists_match_status_flag_sel.sql                             *
REM *                                                                         *
REM *  DESCRIPTION                                                            *
REM *      This script is used to indentify the posted distributions          *
REM *      with Match_status_flag T. Such invoices are picked up for          *
REM *      validation in Invoice validation concurrent request                *
REM +=======================================================================+*/

DECLARE 

  row_cnt NUMBER := 0;

BEGIN  

FND_File.Put_Line(fnd_file.output,
                   '---------------------------------------------------------');
FND_File.Put_Line(fnd_file.output,
                  'START'||' '||'posted_dists_match_status_flag_sel.sql'||'     '||
                  to_char(sysdate, 'DD-MON-YYYY:HH24:MI:SS'));


BEGIN
 EXECUTE IMMEDIATE 'DROP TABLE POSTED_INVOICES';
EXCEPTION
  WHEN OTHERS THEN
    NULL;
END;


BEGIN


EXECUTE IMMEDIATE
'CREATE TABLE POSTED_INVOICES AS
SELECT * FROM ap_invoice_distributions_all
WHERE 1=2';

EXECUTE IMMEDIATE 'INSERT INTO POSTED_INVOICES
SELECT *
  FROM ap_invoice_distributions_all ai
 WHERE posted_flag = ''Y''
   AND match_status_flag <> ''A'' 
   AND invoice_id = '|| l_invoice_id;


row_cnt := SQL%ROWCOUNT;


EXCEPTION
WHEN OTHERS THEN
DBMS_OUTPUT.PUT_LINE('IN EXP posted_dists_match_status_flag_sel.sql');
DBMS_OUTPUT.PUT_LINE(SQLERRM);
		   
END;		   

IF row_cnt > 1 THEN
 l_select_list := 'INVOICE_ID,INVOICE_LINE_NUMBER,MATCH_STATUS_FLAG,POSTED_FLAG';  
  l_table_name := 'POSTED_INVOICES';
  l_where_clause := 'WHERE 1=1';
  
AP_Acctg_Data_Fix_PKG.Print( 'posted_dists_match_status_flag_sel.sql picked the invoice '||l_invoice_id||
                             ' due to wrong match status flag on posted distributions. '||
			     'Generate APLIST for this invoice and log a Service Request.');  



 AP_ACCTG_DATA_FIX_PKG.Print_html_table
    (p_select_list       => l_select_list,
     p_table_in          => l_table_name,
     p_where_in          => l_where_clause,
     P_calling_sequence  => l_calling_sequence);
	 

	
  PRINT_LINE;				
END IF;


FND_File.Put_Line(fnd_file.output,
                  '  END'||' '||'posted_dists_match_status_flag_sel.sql'||'     '||
                  to_char(sysdate, 'DD-MON-YYYY:HH24:MI:SS'));

EXCEPTION 
      
  WHEN OTHERS THEN
     FND_LOG.STRING(10, 'posted_dists_match_status_flag_sel.sql','Error is : ' || SQLERRM);
     AP_Acctg_Data_Fix_PKG.Print('Error is : ' || SQLERRM);

END ;

-- posted_dists_match_status_flag_sel.sql 




--  ap_orphan_zx_lines_sel.sql
/*REM +=======================================================================+
REM | FILENAME                                                              |
REM |      ap_orphan_zx_lines_sel.sql                                    |
REM |                                                                       |
REM | DESCRIPTION                                                           |
REM |   This script will identify orphan ZX lines due to deleted item line  |
REM |   and creates driver table ORPHAN_ZX_LINES_10092603                   |
REM |   Update the process_flag in driver table to 'N' for any records that |
REM |   should not be corrected.                                            |
REM | RCA				                                    |
REM |   9295867                                                             |
REM +=======================================================================+*/

DECLARE 

  row_cnt NUMBER := 0;

BEGIN  

FND_File.Put_Line(fnd_file.output,
                   '---------------------------------------------------------');
FND_File.Put_Line(fnd_file.output,
                  'START'||' '||'ap_orphan_zx_lines_sel.sql'||'     '||
                  to_char(sysdate, 'DD-MON-YYYY:HH24:MI:SS'));


BEGIN
 EXECUTE IMMEDIATE 'DROP TABLE ORPHAN_ZX_LINES_10092603';
EXCEPTION
  WHEN OTHERS THEN
    NULL;
END;


BEGIN


EXECUTE IMMEDIATE
'CREATE TABLE ORPHAN_ZX_LINES_10092603 AS
SELECT
  /* + parallel(tax)*/
  tax_line_id,
  trx_id,
  trx_number,
  trx_line_id,
  ''Y'' process_flag
FROM zx_lines
WHERE 1=2';

EXECUTE IMMEDIATE 'INSERT INTO ORPHAN_ZX_LINES_10092603
SELECT
  /* + parallel(tax)*/
  tax_line_id,
  trx_id,
  trx_number,
  trx_line_id,
  ''Y'' process_flag
FROM zx_lines tax, ap_invoices_all ai
WHERE tax.application_id = 200
AND   ai.invoice_id = tax.trx_id
AND   ai.invoice_id = '||l_invoice_id||'
AND NOT EXISTS
  (SELECT 1
  FROM ap_invoice_lines_all ail
  WHERE ail.invoice_id = tax.trx_id
  AND ail.line_number  = tax.trx_line_id
  )';


row_cnt := SQL%ROWCOUNT;


EXCEPTION
WHEN OTHERS THEN
DBMS_OUTPUT.PUT_LINE('IN EXP ap_orphan_zx_lines_sel.sql');
DBMS_OUTPUT.PUT_LINE(SQLERRM);
		   
END;		   

IF row_cnt > 1 THEN
 l_select_list := 'TAX_LINE_ID,TRX_ID,TRX_NUMBER,TRX_LINE_ID';  
  l_table_name := 'ORPHAN_ZX_LINES_10092603';
  l_where_clause := 'WHERE 1=1 ORDER BY TAX_LINE_ID,TRX_ID, TRX_NUMBER, TRX_LINE_ID';
  
AP_Acctg_Data_Fix_PKG.Print( 'ap_orphan_zx_lines_sel.sql picked the invoice '||l_invoice_id||
                             ' due to orphan zx lines '||
			     'Generate APLIST for this invoice and log a Service Request.');  



 AP_ACCTG_DATA_FIX_PKG.Print_html_table
    (p_select_list       => l_select_list,
     p_table_in          => l_table_name,
     p_where_in          => l_where_clause,
     P_calling_sequence  => l_calling_sequence);
	 

	
  PRINT_LINE;				
END IF;


FND_File.Put_Line(fnd_file.output,
                  '  END'||' '||'ap_orphan_zx_lines_sel.sql'||'     '||
                  to_char(sysdate, 'DD-MON-YYYY:HH24:MI:SS'));

EXCEPTION 
      
  WHEN OTHERS THEN
     FND_LOG.STRING(10, 'ap_orphan_zx_lines_sel.sql','Error is : ' || SQLERRM);
     AP_Acctg_Data_Fix_PKG.Print('Error is : ' || SQLERRM);

END ;

-- ap_orphan_zx_lines_sel.sql 



--  discard_non_tax_line_wrong_rev_sel.sql
/*REM +=======================================================================+
REM | FILENAME                                                              |
REM |      discard_non_tax_line_wrong_rev_sel.sql                                    |
REM |                                                                       |
REM | DESCRIPTION                                                           |
REM *      This script is used to identify all POs for which the status stuck *
REM *      in START mode                                                      *
REM *                                                                         *
REM +=======================================================================+*/

DECLARE 

  row_cnt NUMBER := 0;

BEGIN  

FND_File.Put_Line(fnd_file.output,
                   '---------------------------------------------------------');
FND_File.Put_Line(fnd_file.output,
                  'START'||' '||'discard_non_tax_line_wrong_rev_sel.sql'||'     '||
                  to_char(sysdate, 'DD-MON-YYYY:HH24:MI:SS'));


BEGIN
 EXECUTE IMMEDIATE 'DROP TABLE discard_line_inv';
EXCEPTION
  WHEN OTHERS THEN
    NULL;
END;


BEGIN


EXECUTE IMMEDIATE
'CREATE TABLE discard_line_inv AS
    SELECT invoice_id, line_number
 FROM ap_invoice_lines_all
WHERE 1=2';

EXECUTE IMMEDIATE
'INSERT INTO discard_line_inv 
   select distinct ail.invoice_id, ail.line_number
 from ap_invoice_lines_all ail
 where discarded_flag =''Y'' 
 and   exists (select 1 from ap_invoices_all ai where ai.invoice_id=ail.invoice_id and ai.cancelled_date is  NULL) 
 and ((nvl(amount,0) <> 0 or nvl(base_amount,0) <> 0) 
 OR   exists (select 1 from AP_invoice_distributions_all  aid where ail.invoice_id=aid.invoice_id 
       and  ail.line_number=aid.invoice_line_number and aid.parent_reversal_id is NULL 
       and  not exists(select 1 from AP_invoice_distributions_all  aid1 
       where aid1.invoice_id=aid.invoice_id and aid1.invoice_line_number=aid.invoice_line_number  
       and  aid1.parent_reversal_id=aid.invoice_distribution_id)))  
 and  not   exists (select 1 from AP_invoice_distributions_all  aid where ail.invoice_id=aid.invoice_id 
       and  ail.line_number=aid.invoice_line_number and aid.posted_flag = ''Y'') 
 and  not   exists (select 1 from AP_invoice_distributions_all  aid where ail.invoice_id=aid.invoice_id 
       and  ail.line_number=aid.invoice_line_number and aid.line_type_lookup_code like  ''%TAX%'')       
 and  not   exists (select 1 from AP_invoice_payments_all  aip where ail.invoice_id=aip.invoice_id )
 and   invoice_id = '|| l_invoice_id ;


row_cnt := SQL%ROWCOUNT;


EXCEPTION
WHEN OTHERS THEN
DBMS_OUTPUT.PUT_LINE('IN EXP discard_non_tax_line_wrong_rev_sel.sql');
DBMS_OUTPUT.PUT_LINE(SQLERRM);
		   
END;		   

IF row_cnt > 1 THEN
 l_select_list := 'INVOICE_ID, LINE_NUMBER';  
  l_table_name := 'discard_line_inv';
  l_where_clause := 'WHERE 1=1';
  
AP_Acctg_Data_Fix_PKG.Print( 'discard_non_tax_line_wrong_rev_sel.sql picked the invoice '||l_invoice_id||
                             ' due to wrong amounts after reversal or the reversals are not created '||
			     'Generate APLIST for this invoice and log a Service Request.');  



 AP_ACCTG_DATA_FIX_PKG.Print_html_table
    (p_select_list       => l_select_list,
     p_table_in          => l_table_name,
     p_where_in          => l_where_clause,
     P_calling_sequence  => l_calling_sequence);
	 

	
  PRINT_LINE;				
END IF;


FND_File.Put_Line(fnd_file.output,
                  '  END'||' '||'discard_non_tax_line_wrong_rev_sel.sql'||'     '||
                  to_char(sysdate, 'DD-MON-YYYY:HH24:MI:SS'));

EXCEPTION 
      
  WHEN OTHERS THEN
     FND_LOG.STRING(10, 'discard_non_tax_line_wrong_rev_sel.sql','Error is : ' || SQLERRM);
     AP_Acctg_Data_Fix_PKG.Print('Error is : ' || SQLERRM);
 
END ;

-- discard_non_tax_line_wrong_rev_sel.sql 



--  ap_po_price_adj_flg_sel.sql
/*REM +=======================================================================+
REM | FILENAME                                                              |
REM |      ap_po_price_adj_flg_sel.sql                                    |
REM |                                                                       |
REM | DESCRIPTION                                                           |
REM *      This script is used to identify all POs for which the status stuck *
REM *      in START mode                                                      *
REM *                                                                         *
REM +=======================================================================+*/

DECLARE 

  row_cnt NUMBER := 0;

BEGIN  

FND_File.Put_Line(fnd_file.output,
                   '---------------------------------------------------------');
FND_File.Put_Line(fnd_file.output,
                  'START'||' '||'ap_po_price_adj_flg_sel.sql'||'     '||
                  to_char(sysdate, 'DD-MON-YYYY:HH24:MI:SS'));


BEGIN
 EXECUTE IMMEDIATE 'DROP TABLE po_dist_bkp';
EXCEPTION
  WHEN OTHERS THEN
    NULL;
END;


BEGIN


EXECUTE IMMEDIATE
'CREATE TABLE po_dist_bkp AS
    SELECT * FROM po_distributions_all
WHERE 1=2';

EXECUTE IMMEDIATE
'INSERT INTO po_dist_bkp 
select po.* from po_distributions_all po,
                 ap_invoice_distributions_all aid
where invoice_adjustment_flag = ''S''
and po.po_distribution_id = aid.po_distribution_id
and aid.invoice_id = :1 ' USING l_invoice_id;


row_cnt := SQL%ROWCOUNT;


EXCEPTION
WHEN OTHERS THEN
DBMS_OUTPUT.PUT_LINE('IN EXP ap_po_price_adj_flg_sel.sql');
DBMS_OUTPUT.PUT_LINE(SQLERRM);
		   
END;		   

IF row_cnt > 1 THEN
 l_select_list := 'PO_HEADER_ID,PO_LINE_ID,LINE_LOCATION_ID,PO_DISTRIBUTION_ID';  
  l_table_name := 'po_dist_bkp';
  l_where_clause := 'WHERE 1=1 ORDER BY PO_HEADER_ID';
  
AP_Acctg_Data_Fix_PKG.Print( 'ap_po_price_adj_flg_sel.sql picked the invoice '||l_invoice_id||
                             ' due to related PO stuck in START status.. '||
			     'Generate APLIST for this invoice and log a Service Request.');  



 AP_ACCTG_DATA_FIX_PKG.Print_html_table
    (p_select_list       => l_select_list,
     p_table_in          => l_table_name,
     p_where_in          => l_where_clause,
     P_calling_sequence  => l_calling_sequence);
	 

	
  PRINT_LINE;				
END IF;


FND_File.Put_Line(fnd_file.output,
                  '  END'||' '||'ap_po_price_adj_flg_sel.sql'||'     '||
                  to_char(sysdate, 'DD-MON-YYYY:HH24:MI:SS'));

EXCEPTION 
      
  WHEN OTHERS THEN
     FND_LOG.STRING(10, 'ap_po_price_adj_flg_sel.sql','Error is : ' || SQLERRM);
     AP_Acctg_Data_Fix_PKG.Print('Error is : ' || SQLERRM);
  
END ;

-- ap_po_price_adj_flg_sel.sql 




--  AP_PO_UOM_SYNC_SEL.sql
/*REM +=======================================================================+
REM | FILENAME                                                              |
REM |      AP_PO_UOM_SYNC_SEL.sql                                    |
REM |                                                                       |
REM | DESCRIPTION                                                           |
REM *      This script is used to identify all PO matched invoices for which  *
REM *      UOM id not in sync with PO data.                                   *
REM *      CAUSE: 10061262                                                    *
REM +=======================================================================+*/

DECLARE 

  row_cnt NUMBER := 0;

BEGIN  

FND_File.Put_Line(fnd_file.output,
                   '---------------------------------------------------------');
FND_File.Put_Line(fnd_file.output,
                  'START'||' '||'AP_PO_UOM_SYNC_SEL.sql'||'     '||
                  to_char(sysdate, 'DD-MON-YYYY:HH24:MI:SS'));


BEGIN
 EXECUTE IMMEDIATE 'DROP TABLE Inv_line_drv_10041958';
EXCEPTION
  WHEN OTHERS THEN
    NULL;
END;


BEGIN


EXECUTE IMMEDIATE
'CREATE TABLE Inv_line_drv_10041958 AS
    SELECT * FROM ap_invoices_all
WHERE 1=2';

EXECUTE IMMEDIATE
'INSERT INTO Inv_line_drv_10041958 
SELECT ai.* FROM ap_invoices_all ai
WHERE invoice_id IN ( 
select distinct ail.invoice_id
from ap_invoice_lines_all ail,
     po_line_locations_all pll  
where match_type in (''ITEM_TO_PO'',''ITEM_TO_SERVICE_PO'')
 and ail.PO_LINE_LOCATION_ID is not null
 and ail.PO_LINE_LOCATION_ID = pll.LINE_LOCATION_ID
 and nvl(ail.UNIT_MEAS_LOOKUP_CODE,-1) <> nvl(pll.UNIT_MEAS_LOOKUP_CODE,-1)
 and ail.invoice_id = '||l_invoice_id||'
 UNION
select distinct aid.invoice_id
from ap_invoice_distributions_all aid,
     po_distributions_all pod,
     po_line_locations_all pll
where aid.dist_match_type in (''ITEM_TO_PO'',''ITEM_TO_SERVICE_PO'')
 and aid.PO_DISTRIBUTION_ID is not null
 and aid.po_distribution_id = pod.po_distribution_id
 and pod.line_location_id = pll.line_location_id
 and nvl(aid.MATCHED_UOM_LOOKUP_CODE,-1) <> nvl(pll.UNIT_MEAS_LOOKUP_CODE,-1)
 and aid.invoice_id = '||l_invoice_id||'
UNION
select distinct aid.invoice_id
from ap_invoice_lines_all ail,
     ap_invoice_distributions_all aid
where ail.match_type in (''ITEM_TO_PO'',''ITEM_TO_SERVICE_PO'')
 and ail.PO_LINE_LOCATION_ID is not null
 and ail.invoice_id = aid.invoice_id
 and ail.line_number = aid.invoice_line_number
 and nvl(ail.UNIT_MEAS_LOOKUP_CODE,-1) <> nvl(aid.MATCHED_UOM_LOOKUP_CODE,-1)
  and ail.invoice_id = '||l_invoice_id||'
)';


row_cnt := SQL%ROWCOUNT;


EXCEPTION
WHEN OTHERS THEN
DBMS_OUTPUT.PUT_LINE('IN EXP AP_PO_UOM_SYNC_SEL.sql');
DBMS_OUTPUT.PUT_LINE(SQLERRM);
		   
END;		   

IF row_cnt > 1 THEN
 l_select_list := 'INVOICE_ID,INVOICE_NUM,INVOICE_AMOUNT,PAYMENT_STATUS_FLAG,CANCELLED_DATE'||
                  ',VALIDATION_REQUEST_ID,APPROVAL_READY_FLAG,HISTORICAL_FLAG';  
  l_table_name := 'Inv_line_drv_10041958';
  l_where_clause := 'WHERE 1=1';
  
AP_Acctg_Data_Fix_PKG.Print( 'AP_PO_UOM_SYNC_SEL.sql picked the invoice '||l_invoice_id||
                             ' due to UOM id mismatch. '||
			     'Generate APLIST for this invoice and log a Service Request.');  



 AP_ACCTG_DATA_FIX_PKG.Print_html_table
    (p_select_list       => l_select_list,
     p_table_in          => l_table_name,
     p_where_in          => l_where_clause,
     P_calling_sequence  => l_calling_sequence);
	 

	
  PRINT_LINE;				
END IF;


FND_File.Put_Line(fnd_file.output,
                  '  END'||' '||'AP_PO_UOM_SYNC_SEL.sql'||'     '||
                  to_char(sysdate, 'DD-MON-YYYY:HH24:MI:SS'));

EXCEPTION 
      
  WHEN OTHERS THEN
     FND_LOG.STRING(10, 'AP_PO_UOM_SYNC_SEL.sql','Error is : ' || SQLERRM);
     AP_Acctg_Data_Fix_PKG.Print('Error is : ' || SQLERRM);

END ;

-- AP_PO_UOM_SYNC_SEL.sql 




--  9178283_cancelled_tax_dist_sel.sql
/*REM +=======================================================================+
REM | FILENAME                                                              |
REM |      9178283_cancelled_tax_dist_sel.sql                                    |
REM |                                                                       |
REM | DESCRIPTION                                                           |
REM |   This script will identify all the invoice distributions which are   |
REM |   cancelled but picking up for the invoice validation program.        |
REM +=======================================================================+*/

DECLARE 

  row_cnt NUMBER := 0;

BEGIN  

FND_File.Put_Line(fnd_file.output,
                   '---------------------------------------------------------');
FND_File.Put_Line(fnd_file.output,
                  'START'||' '||'9178283_cancelled_tax_dist_sel.sql'||'     '||
                  to_char(sysdate, 'DD-MON-YYYY:HH24:MI:SS'));


BEGIN
 EXECUTE IMMEDIATE 'DROP TABLE ap_inv_bkp_9178283';
EXCEPTION
  WHEN OTHERS THEN
    NULL;
END;

BEGIN
 EXECUTE IMMEDIATE 'DROP TABLE ap_inv_lines_9178283_bkp';
EXCEPTION
  WHEN OTHERS THEN
    NULL;
END;

BEGIN


EXECUTE IMMEDIATE
'CREATE TABLE ap_inv_bkp_9178283 AS
    SELECT * FROM ap_invoices_all
WHERE 1=2';

EXECUTE IMMEDIATE
'INSERT INTO ap_inv_bkp_9178283 
SELECT /*+ dynamic_sampling(2) */ AI.*
   FROM AP_INVOICES_ALL AI
  WHERE AI.VALIDATION_REQUEST_ID    IS NULL
    AND AI.Invoice_ID = :1
    AND AI.APPROVAL_READY_FLAG      <> ''S''
    AND NOT (NVL(AI.PAYMENT_STATUS_FLAG,''N'') = ''Y''
    AND NVL(AI.HISTORICAL_FLAG,''N'')          = ''Y'')
    AND EXISTS
        ( SELECT 1 FROM DUAL WHERE UPPER(NVL(AI.SOURCE, ''X'')) <> ''RECURRING INVOICE''
          UNION ALL
          SELECT 1
            FROM DUAL
           WHERE UPPER(NVL(AI.SOURCE, ''X'')) = ''RECURRING INVOICE''
             AND NOT EXISTS
                ( SELECT NULL
                    FROM GL_PERIOD_STATUSES GLPS
                   WHERE GLPS.APPLICATION_ID = ''200''
                     AND GLPS.SET_OF_BOOKS_ID    = AI.SET_OF_BOOKS_ID
                     AND TRUNC(AI.GL_DATE) BETWEEN GLPS.START_DATE AND GLPS.END_DATE
                     AND NVL(GLPS.ADJUSTMENT_PERIOD_FLAG, ''N'') = ''N''
                     AND GLPS.CLOSING_STATUS                   = ''N''
                )
        )
    AND EXISTS
       ( 
         SELECT 1
           FROM AP_INVOICE_LINES_ALL AIL, AP_INVOICES AI
          WHERE AIL.INVOICE_ID            = AI.INVOICE_ID
            AND AI.CANCELLED_DATE            IS NULL
            AND NVL(AIL.DISCARDED_FLAG, ''N'') <> ''Y''
            AND NVL(AIL.CANCELLED_FLAG, ''N'') <> ''Y''
            AND (AIL.AMOUNT <> 0  OR (AIL.AMOUNT = 0  AND AIL.GENERATE_DISTS = ''Y''))
            AND NOT EXISTS
                ( SELECT /*+NO_UNNEST */ ''distributed line''
                    FROM AP_INVOICE_DISTRIBUTIONS_ALL D5
                   WHERE D5.INVOICE_ID      = AIL.INVOICE_ID
                     AND D5.INVOICE_LINE_NUMBER = AIL.LINE_NUMBER
                )
       ) ' USING l_invoice_id;



EXECUTE IMMEDIATE
'CREATE TABLE ap_inv_lines_9178283_bkp AS
    SELECT * FROM ap_invoice_lines_all
WHERE 1=2';


EXECUTE IMMEDIATE
'INSERT INTO ap_inv_lines_9178283_bkp
select * from AP_INVOICE_LINES_ALL AIL
WHERE AIL.INVOICE_ID in (select invoice_id from ap_inv_bkp_9178283
                                    where CANCELLED_DATE  IS NULL)
            AND NVL(AIL.DISCARDED_FLAG, ''N'') <> ''Y''
            AND NVL(AIL.CANCELLED_FLAG, ''N'') <> ''Y''
                        AND  (AIL.LINE_TYPE_LOOKUP_CODE=''TAX'' AND AIL.AMOUNT=0 AND AIL.GENERATE_DISTS = ''Y'')
            AND NOT EXISTS
                ( SELECT /*+NO_UNNEST */ ''distributed line''
                    FROM AP_INVOICE_DISTRIBUTIONS_ALL D5
                   WHERE D5.INVOICE_ID      = AIL.INVOICE_ID
                     AND D5.INVOICE_LINE_NUMBER = AIL.LINE_NUMBER
                 )';


row_cnt := SQL%ROWCOUNT;


EXCEPTION
WHEN OTHERS THEN
DBMS_OUTPUT.PUT_LINE('IN EXP 9178283_cancelled_tax_dist_sel.sql');
DBMS_OUTPUT.PUT_LINE(SQLERRM);
		   
END;		   

IF row_cnt > 1 THEN
 l_select_list := 'INVOICE_ID,INVOICE_NUM,INVOICE_AMOUNT,PAYMENT_STATUS_FLAG,CANCELLED_DATE'||
                  ',VALIDATION_REQUEST_ID,APPROVAL_READY_FLAG,HISTORICAL_FLAG';  
  l_table_name := 'ap_inv_bkp_9178283';
  l_where_clause := 'WHERE 1=1';
  
AP_Acctg_Data_Fix_PKG.Print( '9178283_cancelled_tax_dist_sel.sql picked the invoice '||l_invoice_id||
                             ' due to worng cancellation flag and picking for validation. '||
			     'Generate APLIST for this invoice and log a Service Request.');  



 AP_ACCTG_DATA_FIX_PKG.Print_html_table
    (p_select_list       => l_select_list,
     p_table_in          => l_table_name,
     p_where_in          => l_where_clause,
     P_calling_sequence  => l_calling_sequence);
	 

	
  PRINT_LINE;				
END IF;


FND_File.Put_Line(fnd_file.output,
                  '  END'||' '||'9178283_cancelled_tax_dist_sel.sql'||'     '||
                  to_char(sysdate, 'DD-MON-YYYY:HH24:MI:SS'));

EXCEPTION 
      
  WHEN OTHERS THEN
     FND_LOG.STRING(10, '9178283_cancelled_tax_dist_sel.sql','Error is : ' || SQLERRM);
     AP_Acctg_Data_Fix_PKG.Print('Error is : ' || SQLERRM);
 
END ;

-- 9178283_cancelled_tax_dist_sel.sql 



--  datafix_9235692_sel.sql
/*REM +=======================================================================+
REM | FILENAME                                                              |
REM |      datafix_9235692_sel.sql                                    |
REM |                                                                       |
REM | DESCRIPTION                                                           |
REM |   This script will identify all the awt invoices that donot have      |
REM |   proper distributions created. For AWT invoices, distributions are   |
REM |   automatically created by system at the invoice creation time.       |
REM |                                                                       |
REM | RCA: 9067091                                                          |                              
REM +=======================================================================+*/

DECLARE 

  row_cnt NUMBER := 0;

BEGIN  

FND_File.Put_Line(fnd_file.output,
                   '---------------------------------------------------------');
FND_File.Put_Line(fnd_file.output,
                  'START'||' '||'datafix_9235692_sel.sql'||'     '||
                  to_char(sysdate, 'DD-MON-YYYY:HH24:MI:SS'));


BEGIN
 EXECUTE IMMEDIATE 'DROP TABLE prob_awt_invoices_bkp';
EXCEPTION
  WHEN OTHERS THEN
    NULL;
END;

BEGIN


EXECUTE IMMEDIATE
'CREATE TABLE prob_awt_invoices_bkp AS
    SELECT * FROM ap_invoices_all
WHERE 1=2';

EXECUTE IMMEDIATE
'INSERT INTO prob_awt_invoices_bkp 
select ai.* from ap_invoices_all ai
where ai.invoice_type_lookup_code = ''AWT''
and ai.invoice_amount <> (select nvl(sum(aid.amount),-1) from ap_invoice_distributions_all aid
where ai.invoice_id = aid.invoice_id)
and ai.invoice_id = '||l_invoice_id;

row_cnt := SQL%ROWCOUNT;


EXCEPTION
WHEN OTHERS THEN
DBMS_OUTPUT.PUT_LINE('IN EXP datafix_9235692_sel.sql');
DBMS_OUTPUT.PUT_LINE(SQLERRM);
		   
END;		   

IF row_cnt > 1 THEN
 l_select_list := 'INVOICE_ID,INVOICE_NUM,INVOICE_AMOUNT,PAYMENT_STATUS_FLAG,CANCELLED_DATE';  
  l_table_name := 'prob_awt_invoices_bkp';
  l_where_clause := 'WHERE 1=1';
  
AP_Acctg_Data_Fix_PKG.Print( 'datafix_9235692_sel.sql picked the invoice '||l_invoice_id||
                             ' due to holds on cancelled invoice. '||
			     'Generate APLIST for this invoice and log a Service Request.');  



 AP_ACCTG_DATA_FIX_PKG.Print_html_table
    (p_select_list       => l_select_list,
     p_table_in          => l_table_name,
     p_where_in          => l_where_clause,
     P_calling_sequence  => l_calling_sequence);
	 

	
  PRINT_LINE;				
END IF;


FND_File.Put_Line(fnd_file.output,
                  '  END'||' '||'datafix_9235692_sel.sql'||'     '||
                  to_char(sysdate, 'DD-MON-YYYY:HH24:MI:SS'));

EXCEPTION 
      
  WHEN OTHERS THEN
     FND_LOG.STRING(10, 'datafix_9235692_sel.sql','Error is : ' || SQLERRM);
     AP_Acctg_Data_Fix_PKG.Print('Error is : ' || SQLERRM);

END ;

-- datafix_9235692_sel.sql 




--  del_holds_on_can_inv_sel.sql
/*REM +=======================================================================+
REM | FILENAME                                                              |
REM |      del_holds_on_can_inv_sel.sql                                    |
REM |                                                                       |
REM | DESCRIPTION                                                           |
REM *      Script to select invoices which are successfully cancecelled and   *
REM *      Line/Dist holds.                                                   *
REM +=======================================================================+*/

DECLARE 

  row_cnt NUMBER := 0;
BEGIN  

FND_File.Put_Line(fnd_file.output,
                   '---------------------------------------------------------');
FND_File.Put_Line(fnd_file.output,
                  'START'||' '||'del_holds_on_can_inv_sel.sql'||'     '||
                  to_char(sysdate, 'DD-MON-YYYY:HH24:MI:SS'));


BEGIN
 EXECUTE IMMEDIATE 'DROP TABLE can_inv_with_holds';
EXCEPTION
  WHEN OTHERS THEN
    NULL;
END;


BEGIN


EXECUTE IMMEDIATE
'CREATE TABLE can_inv_with_holds AS
    SELECT * FROM ap_invoices_all
WHERE 1=2';

EXECUTE IMMEDIATE
'INSERT INTO can_inv_with_holds 
select * 
from ap_invoices_all ai
where  ai.cancelled_date is not null
   and ai.temp_cancelled_amount is not null
   and not exists (select ''non zero amt line''
                   from ap_invoice_lines_all ail
		   where ail.invoice_id = ai.invoice_id
		   and ail.amount <> 0)
   and 0 = (select sum(amount)
            from ap_invoice_distributions_all aid
	    where aid.invoice_id = ai.invoice_id)
   and exists(select ''line dist var hold''
              from ap_holds_all ah
	      where ai.invoice_id = ah.invoice_id
	        and ah.hold_lookup_code in (''LINE VARIANCE'',''DIST VARIANCE'') 
		and ah.release_lookup_code is null)
   and ai.invoice_id = :1' USING l_invoice_id;

row_cnt := SQL%ROWCOUNT;


EXCEPTION
WHEN OTHERS THEN
DBMS_OUTPUT.PUT_LINE('IN EXP del_holds_on_can_inv_sel.sql');
DBMS_OUTPUT.PUT_LINE(SQLERRM);
		   
END;		   

IF row_cnt > 1 THEN
 l_select_list := 'INVOICE_ID,INVOICE_NUM,INVOICE_AMOUNT,PAYMENT_STATUS_FLAG,CANCELLED_DATE';  
  l_table_name := 'can_inv_with_holds';
  l_where_clause := 'WHERE 1=1';
  
AP_Acctg_Data_Fix_PKG.Print( 'del_holds_on_can_inv_sel.sql picked the invoice '||l_invoice_id||
                             ' due to holds on cancelled invoice. '||
			     'Generate APLIST for this invoice and log a Service Request.');  



 AP_ACCTG_DATA_FIX_PKG.Print_html_table
    (p_select_list       => l_select_list,
     p_table_in          => l_table_name,
     p_where_in          => l_where_clause,
     P_calling_sequence  => l_calling_sequence);
	 

	
  PRINT_LINE;				
END IF;


FND_File.Put_Line(fnd_file.output,
                  '  END'||' '||'del_holds_on_can_inv_sel.sql'||'     '||
                  to_char(sysdate, 'DD-MON-YYYY:HH24:MI:SS'));

EXCEPTION 
      
  WHEN OTHERS THEN
     FND_LOG.STRING(10, 'del_holds_on_can_inv_sel.sql','Error is : ' || SQLERRM);
     AP_Acctg_Data_Fix_PKG.Print('Error is : ' || SQLERRM);

END ;

-- del_holds_on_can_inv_sel.sql 




--  orphan_self_assess_tax_inv_dists_sel.sql
/*REM +=======================================================================+
REM | FILENAME                                                              |
REM |      orphan_self_assess_tax_inv_dists_sel.sql                                    |
REM |                                                                       |
REM | DESCRIPTION                                                           |
REM *    Script to select the orphan NONREC_TAX distributions created in      *
REM *    AP_INVOICE_DISTRIBUTIONS due to bug 7422547 where a normal tax is    *
REM *    modified to self assessed tax.                                       *
REM *                                                                         *
REM *    CAUSE: 7422547                                                       *
REM +=======================================================================+*/

DECLARE 

  row_cnt NUMBER := 0;
BEGIN  

FND_File.Put_Line(fnd_file.output,
                   '---------------------------------------------------------');
FND_File.Put_Line(fnd_file.output,
                  'START'||' '||'orphan_self_assess_tax_inv_dists_sel.sql'||'     '||
                  to_char(sysdate, 'DD-MON-YYYY:HH24:MI:SS'));


BEGIN
 EXECUTE IMMEDIATE 'DROP TABLE B7422547_AID_BKP';
EXCEPTION
  WHEN OTHERS THEN
    NULL;
END;


BEGIN


EXECUTE IMMEDIATE
'CREATE TABLE B7422547_AID_BKP AS
    Select aid.invoice_distribution_id, 
       invoice_id, 
       aid.line_type_lookup_code, 
       aid.accrual_posted_flag, 
       aid.amount 
  from ap_invoice_distributions_all aid 
WHERE 1=2';

EXECUTE IMMEDIATE
'INSERT INTO B7422547_AID_BKP 
    Select aid.invoice_distribution_id, 
       invoice_id, 
       aid.line_type_lookup_code, 
       aid.accrual_posted_flag, 
       aid.amount 
  from ap_invoice_distributions_all aid 
 where aid.invoice_line_number is NULL 
   and aid.line_type_lookup_code in 
       (''REC_TAX'', ''NONREC_TAX'', ''TRV'', ''TIPV'', ''TERV'') 
   and exists (SELECT ''Tax Distributions'' 
          FROM zx_rec_nrec_dist zd 
         WHERE zd.rec_nrec_tax_dist_id = aid.detail_tax_dist_id 
           AND NVL(SELF_ASSESSED_FLAG, ''N'') = ''Y'') 
   and exists 
 (Select ''self assessed tax'' 
          from AP_SELF_ASSESSED_TAX_DIST_ALL asat 
         where asat.invoice_id = aid.invoice_id 
 and asat.detail_tax_dist_id = aid.detail_tax_dist_id )
 AND aid.invoice_id = :1 ' USING l_invoice_id;

row_cnt := SQL%ROWCOUNT;


EXCEPTION
WHEN OTHERS THEN
DBMS_OUTPUT.PUT_LINE('IN EXP orphan_self_assess_tax_inv_dists_sel.sql');
DBMS_OUTPUT.PUT_LINE(SQLERRM);
		   
END;		   

IF row_cnt > 1 THEN
 l_select_list := 'invoice_distribution_id,invoice_id,line_type_lookup_code,accrual_posted_flag,amount';  
  l_table_name := 'B7422547_AID_BKP';
  l_where_clause := 'WHERE 1=1';
  
AP_Acctg_Data_Fix_PKG.Print( 'orphan_self_assess_tax_inv_dists_sel.sql picked the invoice '||l_invoice_id||
                             ' due to orphan NONREC_TAX distributions and normal tax is modified to self assessed. '||
			     'Generate APLIST for this invoice and log a Service Request.');  



 AP_ACCTG_DATA_FIX_PKG.Print_html_table
    (p_select_list       => l_select_list,
     p_table_in          => l_table_name,
     p_where_in          => l_where_clause,
     P_calling_sequence  => l_calling_sequence);
	 

	
  PRINT_LINE;				
END IF;


FND_File.Put_Line(fnd_file.output,
                  '  END'||' '||'orphan_self_assess_tax_inv_dists_sel.sql'||'     '||
                  to_char(sysdate, 'DD-MON-YYYY:HH24:MI:SS'));

EXCEPTION 
      
  WHEN OTHERS THEN
     FND_LOG.STRING(10, 'orphan_self_assess_tax_inv_dists_sel.sql','Error is : ' || SQLERRM);
     AP_Acctg_Data_Fix_PKG.Print('Error is : ' || SQLERRM);
 
END ;

-- orphan_self_assess_tax_inv_dists_sel.sql 




--  orphan_self_assess_tax_inv_dists_sel.sql
/*REM +=======================================================================+
REM | FILENAME                                                              |
REM |      orphan_self_assess_tax_inv_dists_sel.sql                                    |
REM |                                                                       |
REM | DESCRIPTION                                                           |
REM *    Script to select the orphan NONREC_TAX distributions created in      *
REM *    AP_INVOICE_DISTRIBUTIONS due to bug 7422547 where a normal tax is    *
REM *    modified to self assessed tax.                                       *
REM *                                                                         *
REM *    CAUSE: 7422547                                                       *
REM +=======================================================================+*/

DECLARE 

  row_cnt NUMBER := 0;
BEGIN  

FND_File.Put_Line(fnd_file.output,
                   '---------------------------------------------------------');
FND_File.Put_Line(fnd_file.output,
                  'START'||' '||'orphan_self_assess_tax_inv_dists_sel.sql'||'     '||
                  to_char(sysdate, 'DD-MON-YYYY:HH24:MI:SS'));


BEGIN
 EXECUTE IMMEDIATE 'DROP TABLE B7422547_AID_BKP';
EXCEPTION
  WHEN OTHERS THEN
    NULL;
END;


BEGIN


EXECUTE IMMEDIATE
'CREATE TABLE B7422547_AID_BKP AS
    Select aid.invoice_distribution_id, 
       invoice_id, 
       aid.line_type_lookup_code, 
       aid.accrual_posted_flag, 
       aid.amount 
  from ap_invoice_distributions_all aid 
WHERE 1=2';

EXECUTE IMMEDIATE
'INSERT INTO B7422547_AID_BKP 
    Select aid.invoice_distribution_id, 
       invoice_id, 
       aid.line_type_lookup_code, 
       aid.accrual_posted_flag, 
       aid.amount 
  from ap_invoice_distributions_all aid 
 where aid.invoice_line_number is NULL 
   and aid.line_type_lookup_code in 
       (''REC_TAX'', ''NONREC_TAX'', ''TRV'', ''TIPV'', ''TERV'') 
   and exists (SELECT ''Tax Distributions'' 
          FROM zx_rec_nrec_dist zd 
         WHERE zd.rec_nrec_tax_dist_id = aid.detail_tax_dist_id 
           AND NVL(SELF_ASSESSED_FLAG, ''N'') = ''Y'') 
   and exists 
 (Select ''self assessed tax'' 
          from AP_SELF_ASSESSED_TAX_DIST_ALL asat 
         where asat.invoice_id = aid.invoice_id 
 and asat.detail_tax_dist_id = aid.detail_tax_dist_id )
 AND aid.invoice_id = :1 ' USING l_invoice_id;

row_cnt := SQL%ROWCOUNT;


EXCEPTION
WHEN OTHERS THEN
DBMS_OUTPUT.PUT_LINE('IN EXP orphan_self_assess_tax_inv_dists_sel.sql');
DBMS_OUTPUT.PUT_LINE(SQLERRM);
		   
END;		   

IF row_cnt > 1 THEN
 l_select_list := 'invoice_distribution_id,invoice_id,line_type_lookup_code,accrual_posted_flag,amount';  
  l_table_name := 'B7422547_AID_BKP';
  l_where_clause := 'WHERE 1=1';
  
AP_Acctg_Data_Fix_PKG.Print( 'orphan_self_assess_tax_inv_dists_sel.sql picked the invoice '||l_invoice_id||
                             ' due to orphan NONREC_TAX distributions and normal tax is modified to self assessed. '||
			     'Generate APLIST for this invoice and log a Service Request.');  



 AP_ACCTG_DATA_FIX_PKG.Print_html_table
    (p_select_list       => l_select_list,
     p_table_in          => l_table_name,
     p_where_in          => l_where_clause,
     P_calling_sequence  => l_calling_sequence);
	 

	
  PRINT_LINE;				
END IF;


FND_File.Put_Line(fnd_file.output,
                  '  END'||' '||'orphan_self_assess_tax_inv_dists_sel.sql'||'     '||
                  to_char(sysdate, 'DD-MON-YYYY:HH24:MI:SS'));

EXCEPTION 
      
  WHEN OTHERS THEN
     FND_LOG.STRING(10, 'orphan_self_assess_tax_inv_dists_sel.sql','Error is : ' || SQLERRM);
     AP_Acctg_Data_Fix_PKG.Print('Error is : ' || SQLERRM);

END ;

-- orphan_self_assess_tax_inv_dists_sel.sql 




--  paid_invoice_cancel_sel.sql
/*REM +=======================================================================+
REM | FILENAME                                                              |
REM |      paid_invoice_cancel_sel.sql                                    |
REM |                                                                       |
REM | DESCRIPTION                                                           |
REM *      This script is identify the invoices for the case where a paid invoice    *
REM *      is cancelled. System allowed a paid invoice to cancel because             *
REM *      payment status flag in ap_payment_schedues was somehow set to N.          *
REM *      This fix is for those customers who do   not want to invoice              *
REM *      to be cancelled.                                                          *
REM +=======================================================================+*/

DECLARE 

  row_cnt NUMBER := 0;
BEGIN  

FND_File.Put_Line(fnd_file.output,
                   '---------------------------------------------------------');
FND_File.Put_Line(fnd_file.output,
                  'START'||' '||'paid_invoice_cancel_sel.sql'||'     '||
                  to_char(sysdate, 'DD-MON-YYYY:HH24:MI:SS'));


BEGIN
 EXECUTE IMMEDIATE 'DROP TABLE AFFECTED_INVOICES_9891256';
EXCEPTION
  WHEN OTHERS THEN
    NULL;
END;


BEGIN


EXECUTE IMMEDIATE
'CREATE TABLE AFFECTED_INVOICES_9891256 AS
    SELECT  distinct ai.invoice_id, ai.invoice_num, ai.amount_paid,
ai.invoice_currency_code, ai.payment_currency_code, ai.org_id
 FROM   ap_invoices_all ai 
WHERE 1=2';

EXECUTE IMMEDIATE
'INSERT INTO AFFECTED_INVOICES_9891256 
SELECT  distinct ai.invoice_id, ai.invoice_num, ai.amount_paid,
ai.invoice_currency_code, ai.payment_currency_code, ai.org_id
 FROM   ap_invoices_all ai,
        ap_invoice_payments_all P
WHERE   P.invoice_id = ai.invoice_id
  AND   nvl(P.reversal_flag,''N'') <> ''Y''
  AND   P.amount is not NULL
  AND   exists ( select ''non void check''
                      from ap_checks_all A
                      where A.check_id = P.check_id
                        and void_date is null)
  AND   ai.cancelled_date is not null
  AND   ai.cancelled_by is not null
   AND ai.invoice_id = :1 ' USING l_invoice_id;

row_cnt := SQL%ROWCOUNT;


EXCEPTION
WHEN OTHERS THEN
DBMS_OUTPUT.PUT_LINE('IN EXP paid_invoice_cancel_sel.sql');
DBMS_OUTPUT.PUT_LINE(SQLERRM);
		   
END;		   

IF row_cnt > 1 THEN
 l_select_list := 'invoice_id,invoice_num,amount_paid,invoice_currency_code,payment_currency_code,org_id';  
  l_table_name := 'AFFECTED_INVOICES_9891256';
  l_where_clause := 'WHERE 1=1';
  
AP_Acctg_Data_Fix_PKG.Print( 'paid_invoice_cancel_sel.sql picked the invoice '||l_invoice_id||
                             ' due to paid invoice got cancelled. '||
			     'Generate APLIST for this invoice and log a Service Request.');  



 AP_ACCTG_DATA_FIX_PKG.Print_html_table
    (p_select_list       => l_select_list,
     p_table_in          => l_table_name,
     p_where_in          => l_where_clause,
     P_calling_sequence  => l_calling_sequence);
	 

	
  PRINT_LINE;				
END IF;


FND_File.Put_Line(fnd_file.output,
                  '  END'||' '||'paid_invoice_cancel_sel.sql'||'     '||
                  to_char(sysdate, 'DD-MON-YYYY:HH24:MI:SS'));

EXCEPTION 
      
  WHEN OTHERS THEN
     FND_LOG.STRING(10, 'paid_invoice_cancel_sel.sql','Error is : ' || SQLERRM);
     AP_Acctg_Data_Fix_PKG.Print('Error is : ' || SQLERRM);

END ;

-- paid_invoice_cancel_sel.sql 




--  ppay_unapply_causing_neg_amt_paid_sel.sql
/*REM +=======================================================================+
REM | FILENAME                                                              |
REM |      ppay_unapply_causing_neg_amt_paid_sel.sql                                    |
REM |                                                                       |
REM | DESCRIPTION                                                           |
REM *    Script to select the invoices that have amount paid updated as       *
REM *    as negative after prepay unapply and has no payments issued from     *
REM *    system.                                                              *
REM +=======================================================================+*/

DECLARE 

  row_cnt NUMBER := 0;
BEGIN  

FND_File.Put_Line(fnd_file.output,
                   '---------------------------------------------------------');
FND_File.Put_Line(fnd_file.output,
                  'START'||' '||'ppay_unapply_causing_neg_amt_paid_sel.sql'||'     '||
                  to_char(sysdate, 'DD-MON-YYYY:HH24:MI:SS'));


BEGIN
 EXECUTE IMMEDIATE 'DROP TABLE B9277026_AI_BKP';
EXCEPTION
  WHEN OTHERS THEN
    NULL;
END;


BEGIN


EXECUTE IMMEDIATE
'CREATE TABLE B9277026_AI_BKP AS
    Select ai.invoice_id, 
       ai.invoice_num, 
       ai.amount_paid, 
       ai.invoice_amount, 
       ai.invoice_type_lookup_code, 
       ai.vendor_id 
  from ap_invoices_all ai 
WHERE 1=2';

EXECUTE IMMEDIATE
'INSERT INTO B9277026_AI_BKP 
    Select ai.invoice_id, 
       ai.invoice_num, 
       ai.amount_paid, 
       ai.invoice_amount, 
       ai.invoice_type_lookup_code, 
       ai.vendor_id 
  from ap_invoices_all ai 
 where ai.invoice_type_lookup_code = ''STANDARD'' 
   and ai.invoice_id = :1
   and ai.historical_flag is null 
   and sign(ai.amount_paid) = -1 
   and nvl(ai.payment_status_flag,''N'') = ''N'' 
   and ai.invoice_currency_code = ai.payment_currency_code 
   and exists (select 1 
          from ap_payment_schedules_all aps 
         where aps.invoice_id = ai.invoice_id 
         and nvl(aps.payment_status_flag,''N'') = ''N'' 
         having aps.amount_remaining = ai.invoice_amount) 
   and exists (select 1 
          from ap_invoice_lines_all ail 
         where ail.invoice_id = ai.invoice_id 
           and ail.line_type_lookup_code = ''PREPAY'' 
         having sum(ail.amount) = 0)' USING l_invoice_id;

row_cnt := SQL%ROWCOUNT;


EXCEPTION
WHEN OTHERS THEN
DBMS_OUTPUT.PUT_LINE('IN EXP ppay_unapply_causing_neg_amt_paid_sel.sql');
DBMS_OUTPUT.PUT_LINE(SQLERRM);
		   
END;		   

IF row_cnt > 1 THEN
 l_select_list := 'INVOICE_ID,INVOICE_NUM,AMOUNT_PAID,INVOICE_AMOUNT,INVOICE_TYPE_LOOKUP_CODE,VENDOR_ID';  
  l_table_name := 'B9277026_AI_BKP';
  l_where_clause := 'WHERE 1=1';
  
AP_Acctg_Data_Fix_PKG.Print( 'ppay_unapply_causing_neg_amt_paid_sel.sql picked the invoice '||l_invoice_id||
                             ' due to negative amount paid after apply and unapply the prepayment. '||
			     'Generate APLIST for this invoice and log a Service Request.');  



 AP_ACCTG_DATA_FIX_PKG.Print_html_table
    (p_select_list       => l_select_list,
     p_table_in          => l_table_name,
     p_where_in          => l_where_clause,
     P_calling_sequence  => l_calling_sequence);
	 

	
  PRINT_LINE;				
END IF;


FND_File.Put_Line(fnd_file.output,
                  '  END'||' '||'ppay_unapply_causing_neg_amt_paid_sel.sql'||'     '||
                  to_char(sysdate, 'DD-MON-YYYY:HH24:MI:SS'));

EXCEPTION 
      
  WHEN OTHERS THEN
     FND_LOG.STRING(10, 'ppay_unapply_causing_neg_amt_paid_sel.sql','Error is : ' || SQLERRM);
     AP_Acctg_Data_Fix_PKG.Print('Error is : ' || SQLERRM);
 
END ;

-- ppay_unapply_causing_neg_amt_paid_sel.sql 




--  rcv_shpmt_miss_sel.sql
/*REM +=======================================================================+
REM | FILENAME                                                              |
REM |      rcv_shpmt_miss_sel.sql                                    |
REM |                                                                       |
REM | DESCRIPTION                                                           |
REM *      Script to select all upgraded tranx missing with                *
REM *      rcv_shipment_line_id for invoice lines table.                   *
REM *      fix script will populates the misssing data                     *
REM *                                                                      *
REM *      CAUSE: 6896361                                                  *
REM +=======================================================================+*/

DECLARE 

  row_cnt NUMBER := 0;
BEGIN  

FND_File.Put_Line(fnd_file.output,
                   '---------------------------------------------------------');
FND_File.Put_Line(fnd_file.output,
                  'START'||' '||'rcv_shpmt_miss_sel.sql'||'     '||
                  to_char(sysdate, 'DD-MON-YYYY:HH24:MI:SS'));


BEGIN
 EXECUTE IMMEDIATE 'DROP TABLE upg_null_rcv_shpmt_bkp';
EXCEPTION
  WHEN OTHERS THEN
    NULL;
END;


BEGIN


EXECUTE IMMEDIATE
'CREATE TABLE upg_null_rcv_shpmt_bkp AS
SELECT  DISTINCT
       ada.invoice_id  ada_inv_id,ada.invoice_distribution_id,
       ada.RCV_TRANSACTION_ID,
       ail.line_number,ail.RCV_SHIPMENT_LINE_ID,ail.invoice_id,
       aid.old_distribution_id,ail.historical_flag
FROM ap_invoice_dists_arch ada,
     ap_invoice_distributions_all aid,
     ap_invoice_lines_all ail
WHERE 1=2';

EXECUTE IMMEDIATE
'INSERT INTO upg_null_rcv_shpmt_bkp 
SELECT /*+ PARALLEL(ada) */ DISTINCT
       ada.invoice_id  ada_inv_id,ada.invoice_distribution_id,
       ada.RCV_TRANSACTION_ID,
       ail.line_number,ail.RCV_SHIPMENT_LINE_ID,ail.invoice_id,
       aid.old_distribution_id,ail.historical_flag
FROM ap_invoice_dists_arch ada,
     ap_invoice_distributions_all aid,
     ap_invoice_lines_all ail
WHERE ada.invoice_id = aid.invoice_id
AND   ada.invoice_id = :1
AND   ada.invoice_distribution_id = aid.old_distribution_id
AND   aid.invoice_line_number = ail.line_number
AND   aid.invoice_id = ail.invoice_id
AND   ada.RCV_TRANSACTION_ID IS NOT NULL
AND   ail.RCV_TRANSACTION_ID IS NOT NULL
AND   ail.RCV_SHIPMENT_LINE_ID IS NULL
AND   ail.historical_flag = ''Y''
' USING l_invoice_id;

row_cnt := SQL%ROWCOUNT;


EXCEPTION
WHEN OTHERS THEN
DBMS_OUTPUT.PUT_LINE('IN EXP rcv_shpmt_miss_sel.sql');
DBMS_OUTPUT.PUT_LINE(SQLERRM);
		   
END;		   

IF row_cnt > 1 THEN
 l_select_list := 'ADA_INV_ID,INVOICE_DISTRIBUTION_ID,RCV_TRANSACTION_ID,LINE_NUMBER,CV_SHIPMENT_LINE_ID,INVOICE_ID,'||
                  'OLD_DISTRIBUTION_ID,HISTORICAL_FLAG';  
  l_table_name := 'UPG_NULL_RCV_SHPMT_BKP';
  l_where_clause := 'WHERE 1=1 ORDER BY ADA_INV_ID,RCV_TRANSACTION_ID';
  
AP_Acctg_Data_Fix_PKG.Print( 'rcv_shpmt_miss_sel.sql picked the invoice '||l_invoice_id||
                             ' due to mssing rcv shipment details on invoice lines after upgrade. '||
			     'Generate APLIST for this invoice and log a Service Request.');  



 AP_ACCTG_DATA_FIX_PKG.Print_html_table
    (p_select_list       => l_select_list,
     p_table_in          => l_table_name,
     p_where_in          => l_where_clause,
     P_calling_sequence  => l_calling_sequence);
	 

	
  PRINT_LINE;				
END IF;


FND_File.Put_Line(fnd_file.output,
                  '  END'||' '||'rcv_shpmt_miss_sel.sql'||'     '||
                  to_char(sysdate, 'DD-MON-YYYY:HH24:MI:SS'));

EXCEPTION 
      
  WHEN OTHERS THEN
     FND_LOG.STRING(10, 'rcv_shpmt_miss_sel.sql','Error is : ' || SQLERRM);
     AP_Acctg_Data_Fix_PKG.Print('Error is : ' || SQLERRM);

END ;

-- rcv_shpmt_miss_sel.sql 




--  taxable_amount_zero_sel.sql
/*REM +=======================================================================+
REM | FILENAME                                                              |
REM |      taxable_amount_zero_sel.sql                                    |
REM |                                                                       |
REM | DESCRIPTION                                                           |
REM *      Script to correct the taxable amount column for all the upgraded   *
REM *      transactions for which the taxable amount is populated as zero     *
REM *      even the related charge applicable dist amount is non zero value   *
REM *                                                                         *
REM *      the fix script is   taxable_amount_zero_fix.sql                    *
REM *      once the selection scritps executes, check the data in the table   *
REM *      ap_inv_dists_bkp_9145026                                           *
REM *                                                                         *
REM *    CODE FIX : 7250675                                                   *
REM +=======================================================================+*/

DECLARE 

  row_cnt NUMBER := 0;
BEGIN  

FND_File.Put_Line(fnd_file.output,
                   '---------------------------------------------------------');
FND_File.Put_Line(fnd_file.output,
                  'START'||' '||'taxable_amount_zero_sel.sql'||'     '||
                  to_char(sysdate, 'DD-MON-YYYY:HH24:MI:SS'));


BEGIN
 EXECUTE IMMEDIATE 'DROP TABLE ap_inv_dists_bkp_9145026';
EXCEPTION
  WHEN OTHERS THEN
    NULL;
END;


BEGIN


EXECUTE IMMEDIATE
'CREATE TABLE ap_inv_dists_bkp_9145026 AS
SELECT /*+ parallel(aidtax) */ aidtax.invoice_id,
  aidtax.invoice_line_number,
  aidtax.line_type_lookup_code,
  aidtax.invoice_distribution_id,
  aidtax.amount,
  aidtax.base_amount,
  aidtax.taxable_amount,
  aidtax.accounting_event_id,
  aidtax.posted_flag,
  aidtax.match_status_flag,
  aidtax.historical_flag,
  aidtax.reversal_flag,
  aidtax.parent_reversal_id,
  aidtax.old_distribution_id,
  aidtax.tax_recoverable_flag,
  aidtax.detail_tax_dist_id,
  aidtax.summary_tax_line_id,
  aidtax.tax_code_id,
  aidtax.tax_calculated_flag
FROM ap_invoice_distributions_all aidtax
WHERE 1=2';

EXECUTE IMMEDIATE
'INSERT INTO ap_inv_dists_bkp_9145026 
SELECT /*+ parallel(aidtax) */ aidtax.invoice_id,
  aidtax.invoice_line_number,
  aidtax.line_type_lookup_code,
  aidtax.invoice_distribution_id,
  aidtax.amount,
  aidtax.base_amount,
  aidtax.taxable_amount,
  aidtax.accounting_event_id,
  aidtax.posted_flag,
  aidtax.match_status_flag,
  aidtax.historical_flag,
  aidtax.reversal_flag,
  aidtax.parent_reversal_id,
  aidtax.old_distribution_id,
  aidtax.tax_recoverable_flag,
  aidtax.detail_tax_dist_id,
  aidtax.summary_tax_line_id,
  aidtax.tax_code_id,
  aidtax.tax_calculated_flag
FROM ap_invoice_distributions_all aidtax
WHERE taxable_amount       =0
AND   aidtax.invoice_id = :1
AND historical_flag        =''Y''
AND line_type_lookup_code IN (''REC_TAX'',''NONREC_TAX'')
AND EXISTS
  (SELECT 1
  FROM ap_invoice_distributions_all aidtaxable
  WHERE aidtax.invoice_id                   = aidtaxable.invoice_id
  AND aidtaxable.invoice_distribution_id    = aidtax.charge_applicable_to_dist_id
  AND aidtaxable.amount                    <> 0
  AND aidtaxable.line_type_lookup_code NOT IN (''REC_TAX'',''NONREC_TAX'',''TRV'',''TERV'',''TIPV'',''AWT'')
  )' USING l_invoice_id;

row_cnt := SQL%ROWCOUNT;


EXCEPTION
WHEN OTHERS THEN
DBMS_OUTPUT.PUT_LINE('IN EXP taxable_amount_zero_sel.sql');
DBMS_OUTPUT.PUT_LINE(SQLERRM);
		   
END;		   

IF row_cnt > 1 THEN
 l_select_list := 'INVOICE_ID,INVOICE_LINE_NUMBER,LINE_TYPE_LOOKUP_CODE,INVOICE_DISTRIBUTION_ID,'||
                  'AMOUNT,BASE_AMOUNT,TAXABLE_AMOUNT';  
  l_table_name := 'AP_INV_DISTS_BKP_9145026';
  l_where_clause := 'WHERE 1=1';
  
AP_Acctg_Data_Fix_PKG.Print( 'taxable_amount_zero_sel.sql picked the invoice '||l_invoice_id||
                             ' due to wrong taxable amount. '||
			     'Generate APLIST for this invoice and log a Service Request.');  



 AP_ACCTG_DATA_FIX_PKG.Print_html_table
    (p_select_list       => l_select_list,
     p_table_in          => l_table_name,
     p_where_in          => l_where_clause,
     P_calling_sequence  => l_calling_sequence);
	 

	
  PRINT_LINE;				
END IF;


FND_File.Put_Line(fnd_file.output,
                  '  END'||' '||'taxable_amount_zero_sel.sql'||'     '||
                  to_char(sysdate, 'DD-MON-YYYY:HH24:MI:SS'));

EXCEPTION 
      
  WHEN OTHERS THEN
     FND_LOG.STRING(10, 'taxable_amount_zero_sel.sql','Error is : ' || SQLERRM);
     AP_Acctg_Data_Fix_PKG.Print('Error is : ' || SQLERRM);

END ;

-- taxable_amount_zero_sel.sql 




--  upd_pay_sta_flag_sel.sql
/*REM +=======================================================================+
REM | FILENAME                                                              |
REM |      upd_pay_sta_flag_sel.sql                                    |
REM |                                                                       |
REM | DESCRIPTION                                                           |
REM *      Script to select all invoices for which the payment status flag  *
REM *      is wrong.                                                       *
REM +=======================================================================+*/

DECLARE 

  row_cnt NUMBER := 0;
BEGIN  

FND_File.Put_Line(fnd_file.output,
                   '---------------------------------------------------------');
FND_File.Put_Line(fnd_file.output,
                  'START'||' '||'upd_pay_sta_flag_sel.sql'||'     '||
                  to_char(sysdate, 'DD-MON-YYYY:HH24:MI:SS'));


BEGIN
 EXECUTE IMMEDIATE 'DROP TABLE wrong_pay_flag_bkp';
EXCEPTION
  WHEN OTHERS THEN
    NULL;
END;


BEGIN


EXECUTE IMMEDIATE
'CREATE TABLE wrong_pay_flag_bkp AS
SELECT * FROM ap_invoices_all
  Where 1 = 2';

EXECUTE IMMEDIATE
'INSERT INTO wrong_pay_flag_bkp
SELECT ai.*
FROM ap_invoices_all ai
WHERE ai.amount_paid        = ai.invoice_amount
AND  ai.invoice_id = :1
AND ai.payment_status_flag <> ''Y''
AND ai.cancelled_date      IS NULL
AND ai.invoice_amount      <> 0
AND ai.invoice_amount       =
  (SELECT NVL(SUM(amount),0)
  FROM ap_invoice_payments_all aip
  WHERE aip.invoice_id = ai.invoice_id
  )' USING l_invoice_id;

row_cnt := SQL%ROWCOUNT;


EXCEPTION
WHEN OTHERS THEN
DBMS_OUTPUT.PUT_LINE('IN EXP upd_pay_sta_flag_sel.sql');
DBMS_OUTPUT.PUT_LINE(SQLERRM);
		   
END;		   

IF row_cnt > 1 THEN
 l_select_list := 'INVOICE_ID,INVOICE_NUM,INVOICE_AMOUNT,AMOUNT_PAID,PAYMENT_STATUS_FLAG';  
  l_table_name := 'wrong_pay_flag_bkp';
  l_where_clause := 'WHERE 1=1';
  
AP_Acctg_Data_Fix_PKG.Print( 'upd_pay_sta_flag_sel.sql picked the invoice '||l_invoice_id||
                             ' due to wrong payment status flag on invoice header. '||
			     'Generate APLIST for this invoice and log a Service Request.');  



 AP_ACCTG_DATA_FIX_PKG.Print_html_table
    (p_select_list       => l_select_list,
     p_table_in          => l_table_name,
     p_where_in          => l_where_clause,
     P_calling_sequence  => l_calling_sequence);
	 

	
  PRINT_LINE;				
END IF;


FND_File.Put_Line(fnd_file.output,
                  '  END'||' '||'upd_pay_sta_flag_sel.sql'||'     '||
                  to_char(sysdate, 'DD-MON-YYYY:HH24:MI:SS'));

EXCEPTION 
      
  WHEN OTHERS THEN
     FND_LOG.STRING(10, 'upd_pay_sta_flag_sel.sql','Error is : ' || SQLERRM);
     AP_Acctg_Data_Fix_PKG.Print('Error is : ' || SQLERRM);

END ;

-- upd_pay_sta_flag_sel.sql 



--  syncup_inv_num_sel.sql
/*REM +=======================================================================+
REM | FILENAME                                                              |
REM |      syncup_inv_num_sel.sql                                    |
REM |                                                                       |
REM | DESCRIPTION                                                           |
REM *      Script to select all invoices for which the invoice_num is not  *
REM *      in sync with different products like tax,IBY and xla            *
REM *      Fix script will sync up the invoice_num in all the products     *
REM *                                                                      *
REM *      RCA  :10103631                                                  *
REM +=======================================================================+*/

DECLARE 

  row_cnt NUMBER := 0;
BEGIN  

FND_File.Put_Line(fnd_file.output,
                   '---------------------------------------------------------');
FND_File.Put_Line(fnd_file.output,
                  'START'||' '||'syncup_inv_num_sel.sql'||'     '||
                  to_char(sysdate, 'DD-MON-YYYY:HH24:MI:SS'));


BEGIN
 EXECUTE IMMEDIATE 'DROP TABLE syncup_inv_num_bkp';
EXCEPTION
  WHEN OTHERS THEN
    NULL;
END;


BEGIN


EXECUTE IMMEDIATE
'CREATE TABLE syncup_inv_num_bkp AS
SELECT * FROM ap_invoices_all
  Where 1 = 2';

EXECUTE IMMEDIATE
'INSERT INTO syncup_inv_num_bkp
    SELECT  ai.*
    FROM ap_invoices_all ai, xla_transaction_entities xle
    WHERE xle.source_id_int_1 = ai.invoice_id
    AND   ai.invoice_id = '||l_invoice_id||'
    AND   xle.application_id = 200
    AND   xle.entity_code = ''AP_INVOICES''
    AND   xle.transaction_number <> ai.invoice_num  
    UNION
    SELECT  ai.*
    FROM ap_invoices_all ai, IBY_DOCS_PAYABLE_ALL idp
    WHERE idp.CALLING_APP_DOC_UNIQUE_REF2 = ai.invoice_id
    AND   ai.invoice_id = '||l_invoice_id||'
    AND   idp.CALLING_APP_ID = 200
    AND   idp.PAY_PROC_TRXN_TYPE_CODE = ''PAYABLES_DOC''
    AND   idp.CALLING_APP_DOC_REF_NUMBER <> ai.invoice_num 
    AND   idp.ORG_ID = ai.org_id
    UNION
    SELECT  ai.*
    FROM ap_invoices_all ai, zx_lines zl
    WHERE zl.trx_id = ai.invoice_id
    AND   ai.invoice_id = '||l_invoice_id||'
    AND   zl.application_id = 200
    AND   zl.entity_code = ''AP_INVOICES''
    AND   zl.TRX_NUMBER <> ai.invoice_num ';

row_cnt := SQL%ROWCOUNT;


EXCEPTION
WHEN OTHERS THEN
DBMS_OUTPUT.PUT_LINE('IN EXP syncup_inv_num_sel.sql');
DBMS_OUTPUT.PUT_LINE(SQLERRM);
		   
END;		   

IF row_cnt > 1 THEN
 l_select_list := 'INVOICE_ID,INVOICE_NUM';  
  l_table_name := 'syncup_inv_num_bkp';
  l_where_clause := 'WHERE 1=1';
  
AP_Acctg_Data_Fix_PKG.Print( 'syncup_inv_num_sel.sql picked the invoice '||l_invoice_id||
                             ' due to invoice num is not in sync with different product tables. '||
			     'Generate APLIST for this invoice and log a Service Request.');  



 AP_ACCTG_DATA_FIX_PKG.Print_html_table
    (p_select_list       => l_select_list,
     p_table_in          => l_table_name,
     p_where_in          => l_where_clause,
     P_calling_sequence  => l_calling_sequence);
	 

	
  PRINT_LINE;				
END IF;


FND_File.Put_Line(fnd_file.output,
                  '  END'||' '||'syncup_inv_num_sel.sql'||'     '||
                  to_char(sysdate, 'DD-MON-YYYY:HH24:MI:SS'));

EXCEPTION 
      
  WHEN OTHERS THEN
     FND_LOG.STRING(10, 'syncup_inv_num_sel.sql','Error is : ' || SQLERRM);
     AP_Acctg_Data_Fix_PKG.Print('Error is : ' || SQLERRM);

END ;

-- syncup_inv_num_sel.sql 

--  cancelled_inv_nonzero_amt_sel.sql
/*REM +=======================================================================+
REM | FILENAME                                                              |
REM |      cancelled_inv_nonzero_amt_sel.sql                                    |
REM |                                                                       |
REM | DESCRIPTION                                                           |
REM *      This script is used to identify the invoices which are canclled     *
REM *      but the amount paid is still showing the value                  *
REM +=======================================================================+*/

DECLARE 

  row_cnt NUMBER := 0;
BEGIN  

FND_File.Put_Line(fnd_file.output,
                   '---------------------------------------------------------');
FND_File.Put_Line(fnd_file.output,
                  'START'||' '||' cancelled_inv_nonzero_amt_sel.sql'||'     '||
                  to_char(sysdate, 'DD-MON-YYYY:HH24:MI:SS'));


BEGIN
 EXECUTE IMMEDIATE 'DROP TABLE amount_paid_cancelled_invoice';
EXCEPTION
  WHEN OTHERS THEN
    NULL;
END;


BEGIN


EXECUTE IMMEDIATE
'CREATE TABLE amount_paid_cancelled_invoice AS
SELECT * FROM ap_invoices_all
  Where 1 = 2';

EXECUTE IMMEDIATE
'INSERT INTO amount_paid_cancelled_invoice
select ail.* FROM ap_invoices_all ail
 WHERE cancelled_date is not NULL 
 and  amount_paid <> 0 
 and exists (select 1 from ap_invoice_payments_all aip
             where aip.invoice_id=ail.invoice_id
             group by aip.invoice_id
             having sum(aip.amount) =0 )
AND  ail.invoice_id = :1 '
USING l_invoice_id;

row_cnt := SQL%ROWCOUNT;


EXCEPTION
WHEN OTHERS THEN
DBMS_OUTPUT.PUT_LINE('IN EXP  cancelled_inv_nonzero_amt_sel.sql');
DBMS_OUTPUT.PUT_LINE(SQLERRM);
		   
END;		   

IF row_cnt > 1 THEN
 l_select_list := 'INVOICE_ID,CANCELLED_DATE,INVOICE_AMOUNT,AMOUNT_PAID';  
  l_table_name := 'amount_paid_cancelled_invoice';
  l_where_clause := 'WHERE 1=1';
  
AP_Acctg_Data_Fix_PKG.Print( 'cancelled_inv_nonzero_amt_sel.sql picked the invoice '||l_invoice_id||
                             ' due to wrong amount paid on invoice header. '||
			     'Generate APLIST for this invoice and log a Service Request.');  



 AP_ACCTG_DATA_FIX_PKG.Print_html_table
    (p_select_list       => l_select_list,
     p_table_in          => l_table_name,
     p_where_in          => l_where_clause,
     P_calling_sequence  => l_calling_sequence);
	 

	
  PRINT_LINE;				
END IF;


FND_File.Put_Line(fnd_file.output,
                  '  END'||' '||'cancelled_inv_nonzero_amt_sel.sql'||'     '||
                  to_char(sysdate, 'DD-MON-YYYY:HH24:MI:SS'));

EXCEPTION 
      
  WHEN OTHERS THEN
     FND_LOG.STRING(10, 'cancelled_inv_nonzero_amt_sel.sql','Error is : ' || SQLERRM);
     AP_Acctg_Data_Fix_PKG.Print('Error is : ' || SQLERRM);

END ;

-- cancelled_inv_nonzero_amt_sel.sql 


--  wrng_awrdid_upg_sel.sql
/*REM +=======================================================================+
REM | FILENAME                                                              |
REM |      wrng_awrdid_upg_sel.sql                                    |
REM |                                                                       |
REM | DESCRIPTION                                                           |
REM *      This script is used to identify individual/foreign individual     *
REM *      suppliers for which individual_1099 is not populated.            * 
REM +=======================================================================+*/

DECLARE 

  row_cnt NUMBER := 0;
BEGIN  

FND_File.Put_Line(fnd_file.output,
                   '---------------------------------------------------------');
FND_File.Put_Line(fnd_file.output,
                  'START'||' '||' wrng_awrdid_upg_sel.sql'||'     '||
                  to_char(sysdate, 'DD-MON-YYYY:HH24:MI:SS'));


BEGIN
 EXECUTE IMMEDIATE 'DROP TABLE inv_lns_bkp_9721227';
EXCEPTION
  WHEN OTHERS THEN
    NULL;
END;


BEGIN


EXECUTE IMMEDIATE
'CREATE TABLE inv_lns_bkp_9721227 AS
SELECT * FROM ap_invoice_lines_all
  Where 1 = 2';

EXECUTE IMMEDIATE
'INSERT INTO inv_lns_bkp_9721227
select  ail.*
from ap_invoice_lines_all ail 
where historical_flag = ''Y''
and award_id is not null
and exists (select 1 from ap_invoice_distributions_all aid
            where aid.invoice_id = ail.invoice_id
	    and   aid.invoice_line_number = ail.line_number
	    and   aid.award_id = ail.award_id)
AND  ail.invoice_id = :1 '
USING l_invoice_id;

row_cnt := SQL%ROWCOUNT;


EXCEPTION
WHEN OTHERS THEN
DBMS_OUTPUT.PUT_LINE('IN EXP  wrng_awrdid_upg_sel.sql');
DBMS_OUTPUT.PUT_LINE(SQLERRM);
		   
END;		   

IF row_cnt > 1 THEN
 l_select_list := 'INVOICE_ID,LINE_NUMBER,AWARD_ID,HISTORICAL_FLAG';  
  l_table_name := 'INV_LNS_BKP_9721227';
  l_where_clause := 'WHERE 1=1';
  
AP_Acctg_Data_Fix_PKG.Print( 'wrng_awrdid_upg_sel.sql picked the invoice '||l_invoice_id||
                             ' due to wrong award_id populated in upgrade. '||
			     'Generate APLIST for this invoice and log a Service Request.');  



 AP_ACCTG_DATA_FIX_PKG.Print_html_table
    (p_select_list       => l_select_list,
     p_table_in          => l_table_name,
     p_where_in          => l_where_clause,
     P_calling_sequence  => l_calling_sequence);
	 

	
  PRINT_LINE;				
END IF;


FND_File.Put_Line(fnd_file.output,
                  '  END'||' '||'wrng_awrdid_upg_sel.sql'||'     '||
                  to_char(sysdate, 'DD-MON-YYYY:HH24:MI:SS'));

EXCEPTION 
      
  WHEN OTHERS THEN
     FND_LOG.STRING(10, 'wrng_awrdid_upg_sel.sql','Error is : ' || SQLERRM);
     AP_Acctg_Data_Fix_PKG.Print('Error is : ' || SQLERRM);

END ;

-- wrng_awrdid_upg_sel.sql 



-- update_individual_1099_sel.sql
/*REM +=======================================================================+
REM | FILENAME                                                              |
REM |     update_individual_1099_sel.sql                                    |
REM |                                                                       |
REM | DESCRIPTION                                                           |
REM *      This script is used to identify individual/foreign individual     *
REM *      suppliers for which individual_1099 is not populated.            * 
REM +=======================================================================+*/

DECLARE 

  row_cnt NUMBER := 0;
BEGIN  

FND_File.Put_Line(fnd_file.output,
                   '---------------------------------------------------------');
FND_File.Put_Line(fnd_file.output,
                  'START'||' '||'update_individual_1099_sel.sql'||'     '||
                  to_char(sysdate, 'DD-MON-YYYY:HH24:MI:SS'));


BEGIN
 EXECUTE IMMEDIATE 'DROP TABLE ap_suppliers_8922053';
EXCEPTION
  WHEN OTHERS THEN
    NULL;
END;


BEGIN


EXECUTE IMMEDIATE
'CREATE TABLE ap_suppliers_8922053 AS
SELECT * FROM AP_SUPPLIERS
  Where 1 = 2';

EXECUTE IMMEDIATE
'INSERT INTO ap_suppliers_8922053
SELECT * FROM AP_SUPPLIERS
WHERE  num_1099 IS NULL AND individual_1099 IS NULL
AND    organization_type_lookup_code IN (''INDIVIDUAL'',''FOREIGN INDIVIDUAL'')
And  vendor_id IN (SELECT ai.vendor_id FROM ap_invoices_all ai WHERE ai.invoice_id = :1) '
USING l_invoice_id;

row_cnt := SQL%ROWCOUNT;


EXCEPTION
WHEN OTHERS THEN
DBMS_OUTPUT.PUT_LINE('IN EXP update_individual_1099_sel.sql');
DBMS_OUTPUT.PUT_LINE(SQLERRM);
		   
END;		   

IF row_cnt > 1 THEN
 l_select_list := 'VENDOR_ID,VENDOR_NAME,INDIVIDUAL_1099,ORGANIZATION_TYPE_LOOKUP_CODE';  
  l_table_name := 'AP_SUPPLIERS_8922053';
  l_where_clause := 'WHERE 1=1';
  
AP_Acctg_Data_Fix_PKG.Print( 'update_individual_1099_sel.sql picked the invoice '||l_invoice_id||
                             ' due to the related supplier has no individual_1099 . '||
			     'Generate APLIST for this invoice and log a Service Request.');  



 AP_ACCTG_DATA_FIX_PKG.Print_html_table
    (p_select_list       => l_select_list,
     p_table_in          => l_table_name,
     p_where_in          => l_where_clause,
     P_calling_sequence  => l_calling_sequence);
	 

	
  PRINT_LINE;				
END IF;


FND_File.Put_Line(fnd_file.output,
                  '  END'||' '||'update_individual_1099_sel.sql'||'     '||
                  to_char(sysdate, 'DD-MON-YYYY:HH24:MI:SS'));

EXCEPTION 
      
  WHEN OTHERS THEN
     FND_LOG.STRING(10, 'update_individual_1099_sel.sql','Error is : ' || SQLERRM);
     AP_Acctg_Data_Fix_PKG.Print('Error is : ' || SQLERRM);

END ;

-- update_individual_1099_sel.sql 





-- upd_upg_itm_TCC_sel.sql
/*REM +=======================================================================+
REM | FILENAME                                                              |
REM |     upd_upg_itm_TCC_sel.sql                                           |
REM |                                                                       |
REM | DESCRIPTION                                                           |
REM *      This script is used to identify the cancelled/reversed invoices    *
REM *      retainage release distributions without retainage_invoice_id stamped* 
REM *      CAUSE:   8824235                                                   *
REM +=======================================================================+*/

DECLARE 

  row_cnt NUMBER := 0;
BEGIN  

FND_File.Put_Line(fnd_file.output,
                   '---------------------------------------------------------');
FND_File.Put_Line(fnd_file.output,
                  'START'||' '||'upd_upg_itm_TCC_sel.sql'||'     '||
                  to_char(sysdate, 'DD-MON-YYYY:HH24:MI:SS'));

BEGIN
 EXECUTE IMMEDIATE 'DROP TABLE dists_11i_tcc_bkp';
EXCEPTION
  WHEN OTHERS THEN
    NULL;
END;


BEGIN


EXECUTE IMMEDIATE
'CREATE TABLE dists_11i_tcc_bkp AS
SELECT ada.invoice_id,ada.invoice_distribution_id,
       ada.tax_code_id,ada.line_type_lookup_code
FROM ap_invoice_dists_arch ada
  Where 1 = 2';

EXECUTE IMMEDIATE
'INSERT INTO dists_11i_tcc_bkp
SELECT /*+ parallel(aid) */
       ada.invoice_id,ada.invoice_distribution_id,
       ada.tax_code_id,ada.line_type_lookup_code
FROM ap_invoice_dists_arch ada
WHERE ada.line_type_lookup_code <> ''TAX''
AND   ada.tax_code_id IS NOT NULL
AND NOT EXISTS (SELECT ''with TCC''
                FROM ap_invoice_distributions_all aid,
     ap_invoice_lines_all ail
WHERE aid.invoice_id = ada.invoice_id
AND  ada.invoice_distribution_id = aid.old_distribution_id
AND  ail.invoice_id = aid.invoice_id
AND  ail.line_number = aid.invoice_line_number
AND  ail.Tax_Classification_Code IS NOT NULL)
AND EXISTS (SELECT ''with TCC''
                FROM ap_invoice_distributions_all aid
WHERE aid.invoice_id = ada.invoice_id
AND  ada.invoice_distribution_id = aid.old_distribution_id)
And ada.invoice_id = :1 ' USING l_invoice_id;

row_cnt := SQL%ROWCOUNT;


EXCEPTION
WHEN OTHERS THEN
DBMS_OUTPUT.PUT_LINE('IN EXP upd_upg_itm_TCC_sel.sql');
DBMS_OUTPUT.PUT_LINE(SQLERRM);
		   
END;		   

IF row_cnt > 1 THEN
 l_select_list := 'INVOICE_ID,INVOICE_DISTRIBUTION_ID,TAX_CODE_ID,LINE_TYPE_LOOKUP_CODE';  
  l_table_name := 'DISTS_11I_TCC_BKP';
  l_where_clause := 'WHERE 1=1 ORDER BY LINE_TYPE_LOOKUP_CODE';
  
AP_Acctg_Data_Fix_PKG.Print( 'upd_upg_itm_TCC_sel.sql picked the invoice '||l_invoice_id||
                             ' due to missing Tax details on item dists after upgrade. '||
			     'Generate APLIST for this invoice and log a Service Request.');  



 AP_ACCTG_DATA_FIX_PKG.Print_html_table
    (p_select_list       => l_select_list,
     p_table_in          => l_table_name,
     p_where_in          => l_where_clause,
     P_calling_sequence  => l_calling_sequence);
	 

	
  PRINT_LINE;				
END IF;

FND_File.Put_Line(fnd_file.output,
                  '  END'||' '||'upd_upg_itm_TCC_sel.sql'||'     '||
                  to_char(sysdate, 'DD-MON-YYYY:HH24:MI:SS'));


EXCEPTION 
      
  WHEN OTHERS THEN
     FND_LOG.STRING(10, 'upd_upg_itm_TCC_sel.sql','Error is : ' || SQLERRM);
     AP_Acctg_Data_Fix_PKG.Print('Error is : ' || SQLERRM);

END ;

-- upd_upg_itm_TCC_sel.sql 





-- upd_ret_inv_dist_id_for_rev_dists_sel.sql
/*REM +=======================================================================+
REM | FILENAME                                                              |
REM |     upd_ret_inv_dist_id_for_rev_dists_sel.sql                         |
REM |                                                                       |
REM | DESCRIPTION                                                           |
REM *      This script is used to identify the cancelled/reversed invoices    *
REM *      retainage release distributions without retainage_invoice_id stamped* 
REM *      CAUSE:   8824235                                                   *
REM +=======================================================================+*/

DECLARE 

  row_cnt NUMBER := 0;
BEGIN  

FND_File.Put_Line(fnd_file.output,
                   '---------------------------------------------------------');
FND_File.Put_Line(fnd_file.output,
                  'START'||' '||'upd_ret_inv_dist_id_for_rev_dists_sel.sql'||'     '||
                  to_char(sysdate, 'DD-MON-YYYY:HH24:MI:SS'));

BEGIN
 EXECUTE IMMEDIATE 'DROP TABLE ap_inv_ret_inv_dist_bkp';
EXCEPTION
  WHEN OTHERS THEN
    NULL;
END;


BEGIN


EXECUTE IMMEDIATE
'CREATE TABLE ap_inv_ret_inv_dist_bkp AS
SELECT aid.*
FROM ap_invoice_distributions_all aid
  Where 1 = 2';

EXECUTE IMMEDIATE
'INSERT INTO ap_inv_ret_inv_dist_bkp
select aid.* from ap_invoice_distributions_all aid,
              ap_invoices_all ai,
	      ap_invoice_distributions_all aid2
where  ai.invoice_type_lookup_code = ''RETAINAGE RELEASE''
  and nvl(ai.historical_flag,''N'') <> ''Y''
  and ai.invoice_id = aid.invoice_id
  and aid.line_type_lookup_code = ''RETAINAGE''
  and aid.parent_reversal_id is not null
  and aid.RETAINED_INVOICE_DIST_ID is null  
  and aid2.invoice_id = aid.invoice_id
  and aid.parent_reversal_id = aid2.invoice_distribution_id
  and aid2.RETAINED_INVOICE_DIST_ID is not null
And ai.invoice_id = :1 ' USING l_invoice_id;

row_cnt := SQL%ROWCOUNT;


EXCEPTION
WHEN OTHERS THEN
DBMS_OUTPUT.PUT_LINE('IN EXP upd_ret_inv_dist_id_for_rev_dists_sel.sql');
DBMS_OUTPUT.PUT_LINE(SQLERRM);
		   
END;		   

IF row_cnt > 1 THEN
 l_select_list := 'INVOICE_ID,INVOICE_LINE_NUMBER,LINE_TYPE_LOOKUP_CODE,RETAINED_INVOICE_DIST_ID';  
  l_table_name := 'AP_INV_RET_INV_DIST_BKP';
  l_where_clause := 'WHERE 1=1 ORDER BY INVOICE_LINE_NUMBER,LINE_TYPE_LOOKUP_CODE';
  
AP_Acctg_Data_Fix_PKG.Print( 'upd_ret_inv_dist_id_for_rev_dists_sel.sql picked the invoice '||l_invoice_id||
                             ' due to missing retainage details on the distributions. '||
			     'Generate APLIST for this invoice and log a Service Request.');  



 AP_ACCTG_DATA_FIX_PKG.Print_html_table
    (p_select_list       => l_select_list,
     p_table_in          => l_table_name,
     p_where_in          => l_where_clause,
     P_calling_sequence  => l_calling_sequence);
	 

	
  PRINT_LINE;				
END IF;


FND_File.Put_Line(fnd_file.output,
                  '  END'||' '||'upd_ret_inv_dist_id_for_rev_dists_sel.sql'||'     '||
                  to_char(sysdate, 'DD-MON-YYYY:HH24:MI:SS'));

EXCEPTION 
      
  WHEN OTHERS THEN
     FND_LOG.STRING(10, 'upd_ret_inv_dist_id_for_rev_dists_sel.sql','Error is : ' || SQLERRM);
     AP_Acctg_Data_Fix_PKG.Print('Error is : ' || SQLERRM);

END ;

-- upd_ret_inv_dist_id_for_rev_dists_sel.sql 





-- upd_inv_null_amt_sel.sql
/*REM +=======================================================================+
REM | FILENAME                                                              |
REM |     upd_inv_null_amt_sel.sql                                              |
REM |                                                                       |
REM | DESCRIPTION                                                           |
REM *      Script to update null invoice header amounts to sum of             *
REM *      distritbuion amounts. because of the null amounts the appdstln.sql *
REM *      or apxlapay.sql failing at the time of upgrade or xla hot patch    *
REM *      The Script should run before upgrade.                              *
REM *      the fix script is  upd_inv_null_amt_fix.sql                        *
REM *      once the selection scritps executes, check the data in the tables  *
REM *      null_inv_bkp                                                       *
REM +=======================================================================+*/

DECLARE 

  row_cnt NUMBER := 0;
BEGIN  

FND_File.Put_Line(fnd_file.output,
                   '---------------------------------------------------------');
FND_File.Put_Line(fnd_file.output,
                  'START'||' '||'upd_inv_null_amt_sel.sql'||'     '||
                  to_char(sysdate, 'DD-MON-YYYY:HH24:MI:SS'));


BEGIN
 EXECUTE IMMEDIATE 'DROP TABLE null_inv_bkp';
EXCEPTION
  WHEN OTHERS THEN
    NULL;
END;


BEGIN


EXECUTE IMMEDIATE
'CREATE TABLE null_inv_bkp AS
SELECT ai.*
FROM ap_invoices_all ai
  Where 1 = 2';

EXECUTE IMMEDIATE
'INSERT INTO null_inv_bkp
SELECT * FROM ap_invoices_all WHERE invoice_amount IS NULL
And invoice_id = :1 ' USING l_invoice_id;

row_cnt := SQL%ROWCOUNT;


EXCEPTION
WHEN OTHERS THEN
DBMS_OUTPUT.PUT_LINE('IN EXP upd_inv_null_amt_sel.sql');
DBMS_OUTPUT.PUT_LINE(SQLERRM);
		   
END;		   

IF row_cnt > 1 THEN
 l_select_list := 'INVOICE_ID,INVOICE_AMOUNT,PAYMENT_STATUS_FLAG,AMOUNT_PAID';  
  l_table_name := 'NULL_INV_BKP';
  l_where_clause := 'WHERE 1=1';
  
AP_Acctg_Data_Fix_PKG.Print( 'upd_inv_null_amt_sel.sql picked the invoice '||l_invoice_id||
                             ' due to Null amount in invoice header. '||
			     'Generate APLIST for this invoice and log a Service Request.');  



 AP_ACCTG_DATA_FIX_PKG.Print_html_table
    (p_select_list       => l_select_list,
     p_table_in          => l_table_name,
     p_where_in          => l_where_clause,
     P_calling_sequence  => l_calling_sequence);
	 

	
  PRINT_LINE;				
END IF;


FND_File.Put_Line(fnd_file.output,
                  '  END'||' '||'upd_inv_null_amt_sel.sql'||'     '||
                  to_char(sysdate, 'DD-MON-YYYY:HH24:MI:SS'));

EXCEPTION 
      
  WHEN OTHERS THEN
     FND_LOG.STRING(10, 'upd_inv_null_amt_sel.sql','Error is : ' || SQLERRM);
     AP_Acctg_Data_Fix_PKG.Print('Error is : ' || SQLERRM);

END ;

-- upd_inv_null_amt_sel.sql 





-- upd_mtch_sts_flg_from_T2A_sel.sql
/*REM +=======================================================================+
REM | FILENAME                                                              |
REM |     upd_mtch_sts_flg_from_T2A_sel.sql                                              |
REM |                                                                       |
REM | DESCRIPTION                                                           |
REM *      Update match_status_flag to 'A' from 'T', if accounting_event_id   *
REM *      is null and purch_encumb_flag is 'Y'                               *
REM *      Fix script is  upd_mtch_sts_flg_from_T2A_fix.sql                   *
REM *      once the selection scritps executes, check the data in the table   *
REM *      inv_dist_bkup_9555610                                              *
REM +=======================================================================+*/

DECLARE 

  row_cnt NUMBER := 0;
BEGIN  

FND_File.Put_Line(fnd_file.output,
                   '---------------------------------------------------------');
FND_File.Put_Line(fnd_file.output,
                  'START'||' '||'upd_mtch_sts_flg_from_T2A_sel.sql'||'     '||
                  to_char(sysdate, 'DD-MON-YYYY:HH24:MI:SS'));

BEGIN
 EXECUTE IMMEDIATE 'DROP TABLE inv_dist_bkup_9555610';
EXCEPTION
  WHEN OTHERS THEN
    NULL;
END;


BEGIN


EXECUTE IMMEDIATE
'CREATE TABLE inv_dist_bkup_9555610 AS
SELECT aid.*
FROM ap_invoice_distributions_all aid
  Where 1 = 2';

EXECUTE IMMEDIATE
'INSERT INTO inv_dist_bkup_9555610
SELECT AID.*
FROM   ap_invoice_distributions_all AID,
       ap_invoices_all              AI,
       FINANCIALS_SYSTEM_PARAMS_ALL FSP,
       ap_invoice_distributions_all REV_DIST
WHERE  AI.invoice_id = AID.invoice_id
   AND AI.org_id = FSP.org_id
   AND NVL( AI.historical_flag, ''N'' ) <> ''Y''
   AND FSP.purch_encumbrance_flag = ''Y''
   AND AID.match_status_flag = ''T''
   AND AID.accounting_event_id is null
   AND NOT EXISTS ( SELECT ''NO HOLDS''
                    FROM ap_holds_all APH
                    WHERE APH.invoice_id = AI.invoice_id
		        AND APH.RELEASE_LOOKUP_CODE IS NULL)
   AND AID.PARENT_REVERSAL_ID = REV_DIST.INVOICE_DISTRIBUTION_ID(+)
   AND (   NVL(AID.REVERSAL_FLAG,''N'') = ''N''
        OR( NVL(AID.REVERSAL_FLAG,''N'') = ''Y'' 
	    AND(    (AID.BC_EVENT_ID IS NULL AND REV_DIST.BC_EVENT_ID IS NULL)
                 OR (AID.BC_EVENT_ID IS NOT NULL AND REV_DIST.BC_EVENT_ID IS NOT NULL))
	   ))
And aid.invoice_id = :1 ' USING l_invoice_id;

row_cnt := SQL%ROWCOUNT;


EXCEPTION
WHEN OTHERS THEN
DBMS_OUTPUT.PUT_LINE('IN EXP upd_mtch_sts_flg_from_T2A_sel.sql');
DBMS_OUTPUT.PUT_LINE(SQLERRM);
		   
END;		   

IF row_cnt > 1 THEN
 l_select_list := 'INVOICE_ID,INVOICE_DISTRIBUTION_ID,INVOICE_LINE_NUMBER,'||
                  'LINE_TYPE_LOOKUP_CODE, AMOUNT, ACCOUNTING_EVENT_ID, MATCH_STATUS_FLAG';  
  l_table_name := 'INV_DIST_BKUP_9555610';
  l_where_clause := 'WHERE 1=1 ORDER BY MATCH_STATUS_FLAG';
  
AP_Acctg_Data_Fix_PKG.Print( 'upd_mtch_sts_flg_from_T2A_sel.sql picked the invoice '||l_invoice_id||
                             ' due to wrong match status flag as A with out accounting event id. '||
			     'Generate APLIST for this invoice and log a Service Request.');  



 AP_ACCTG_DATA_FIX_PKG.Print_html_table
    (p_select_list       => l_select_list,
     p_table_in          => l_table_name,
     p_where_in          => l_where_clause,
     P_calling_sequence  => l_calling_sequence);
	 

	
  PRINT_LINE;				
END IF;


FND_File.Put_Line(fnd_file.output,
                  '  END'||' '||'upd_mtch_sts_flg_from_T2A_sel.sql'||'     '||
                  to_char(sysdate, 'DD-MON-YYYY:HH24:MI:SS'));

EXCEPTION 
      
  WHEN OTHERS THEN
     FND_LOG.STRING(10, 'upd_mtch_sts_flg_from_T2A_sel.sql','Error is : ' || SQLERRM);
     AP_Acctg_Data_Fix_PKG.Print('Error is : ' || SQLERRM);

END ;

-- upd_mtch_sts_flg_from_T2A_sel.sql 




-- unrev_upg_TIPV_sel.sql
/*REM +=======================================================================+
REM | FILENAME                                                              |
REM |     unrev_upg_TIPV_sel.sql                                              |
REM |                                                                       |
REM | DESCRIPTION                                                           |
REM *      Script to select all TIPV dists whichare reversed but the       *
REM *      reversal distributions are not created in R12. The reveseral    *
REM *      happenend in R12. Fix script will do undo of all such tranx     *
REM *      and delete those distributions                                  *
REM +=======================================================================+*/

DECLARE 

  row_cnt NUMBER := 0;
BEGIN  

FND_File.Put_Line(fnd_file.output,
                   '---------------------------------------------------------');
FND_File.Put_Line(fnd_file.output,
                  'START'||' '||'unrev_upg_TIPV_sel.sql'||'     '||
                  to_char(sysdate, 'DD-MON-YYYY:HH24:MI:SS'));

BEGIN
 EXECUTE IMMEDIATE 'DROP TABLE unrev_tipv_dists';
EXCEPTION
  WHEN OTHERS THEN
    NULL;
END;


BEGIN


EXECUTE IMMEDIATE ' CREATE TABLE unrev_tipv_dists AS
SELECT invoice_id,invoice_distribution_id,invoice_line_number,
       line_type_lookup_code, amount, reversal_flag, CANCELLATION_FLAG
FROM ap_invoice_distributions_all aid
  Where 1 = 2';

EXECUTE IMMEDIATE
'INSERT INTO unrev_tipv_dists
SELECT invoice_id,invoice_distribution_id,invoice_line_number,
       line_type_lookup_code, amount, reversal_flag, CANCELLATION_FLAG
FROM ap_invoice_distributions_all aid
WHERE aid.line_type_lookup_code = ''TIPV''
AND aid.historical_flag         = ''Y''
AND aid.parent_reversal_id     IS NULL
AND aid.reversal_flag           = ''Y''
AND NOT EXISTS
  (SELECT ''no reversal''
  FROM ap_invoice_distributions_all aid1
  WHERE aid.invoice_id              = aid1.invoice_id
  AND aid.invoice_line_number       = aid1.invoice_line_number
  AND ((aid.invoice_distribution_id = aid1.parent_reversal_id)
  OR aid.old_distribution_id        = aid1.parent_reversal_id)
  AND aid1.line_type_lookup_code    = ''TIPV''
  )
AND EXISTS
  (SELECT ''reversed in R12''
  FROM ap_invoice_distributions_all aid2,
    ap_invoice_distributions_all aid3
  WHERE aid.related_id = aid2.invoice_distribution_id
  AND aid2.line_type_lookup_code LIKE ''%TAX''
  AND aid2.parent_reversal_id       IS NULL
  AND ((aid2.invoice_distribution_id = aid3.parent_reversal_id)
  OR aid2.old_distribution_id        = aid3.parent_reversal_id)
  AND NVL(aid3.historical_flag,''N'')  = ''N''
  )
And aid.invoice_id = :1 ' USING l_invoice_id;

row_cnt := SQL%ROWCOUNT;


EXCEPTION
WHEN OTHERS THEN
DBMS_OUTPUT.PUT_LINE('IN EXP unrev_upg_TIPV_sel.sql');
DBMS_OUTPUT.PUT_LINE(SQLERRM);
		   
END;		   

IF row_cnt > 1 THEN
 l_select_list := 'INVOICE_ID,INVOICE_DISTRIBUTION_ID,INVOICE_LINE_NUMBER,'||
                  'LINE_TYPE_LOOKUP_CODE, AMOUNT, REVERSAL_FLAG, CANCELLATION_FLAG';  
  l_table_name := 'unrev_tipv_dists';
  l_where_clause := 'WHERE 1=1 ORDER BY LINE_TYPE_LOOKUP_CODE';
  
AP_Acctg_Data_Fix_PKG.Print( 'unrev_upg_TIPV_sel.sql picked the invoice '||l_invoice_id||
                             ' due to no reversal dist created for original reversed TIPV distributions '||
			     'Generate APLIST for this invoice and log a Service Request.');  



 AP_ACCTG_DATA_FIX_PKG.Print_html_table
    (p_select_list       => l_select_list,
     p_table_in          => l_table_name,
     p_where_in          => l_where_clause,
     P_calling_sequence  => l_calling_sequence);
	 

	
  PRINT_LINE;				
END IF;


FND_File.Put_Line(fnd_file.output,
                  '  END'||' '||'unrev_upg_TIPV_sel.sql'||'     '||
                  to_char(sysdate, 'DD-MON-YYYY:HH24:MI:SS'));

EXCEPTION 
      
  WHEN OTHERS THEN
     FND_LOG.STRING(10, 'unrev_upg_TIPV_sel.sql','Error is : ' || SQLERRM);
     AP_Acctg_Data_Fix_PKG.Print('Error is : ' || SQLERRM);

END ;

-- unrev_upg_TIPV_sel.sql 



-- ap_canc_inv_amt_paid_sel.sql
/*REM +=======================================================================+
REM | FILENAME                                                              |
REM |     ap_canc_inv_amt_paid_sel.sql                                              |
REM |                                                                       |
REM | DESCRIPTION                                                           |
REM *      Script to select the invoices which are cancelled but the       *
REM *      amount_paid column is showing amount other than zero.           *
REM *      Ref: bug 9365984                                                *
REM *      CAUSE: Code Fix 8411165                                         *
REM +=======================================================================+*/

DECLARE 

  row_cnt NUMBER := 0;
BEGIN  

FND_File.Put_Line(fnd_file.output,
                   '---------------------------------------------------------');
FND_File.Put_Line(fnd_file.output,
                  'START'||' '||'ap_canc_inv_amt_paid_sel.sql'||'     '||
                  to_char(sysdate, 'DD-MON-YYYY:HH24:MI:SS'));

BEGIN
 EXECUTE IMMEDIATE 'DROP TABLE ap_canc_inv_amt_paid_9365984';
EXCEPTION
  WHEN OTHERS THEN
    NULL;
END;


BEGIN


EXECUTE IMMEDIATE
'CREATE TABLE ap_canc_inv_amt_paid_9365984 AS
 Select * from ap_invoices_all
  Where 1 = 2';

EXECUTE IMMEDIATE
'INSERT INTO ap_canc_inv_amt_paid_9365984
SELECT *
  FROM ap_invoices_all ai
 WHERE cancelled_date IS NOT NULL
   AND amount_paid <> 0
   AND EXISTS (SELECT 1
                 FROM ap_invoice_lines_all ail
                WHERE ail.invoice_id = ail.invoice_id
                  AND ail.line_type_lookup_code = ''PREPAY'')
   And invoice_id = '|| l_invoice_id;

row_cnt := SQL%ROWCOUNT;


EXCEPTION
WHEN OTHERS THEN
DBMS_OUTPUT.PUT_LINE('IN EXP ap_canc_inv_amt_paid_sel.sql');
DBMS_OUTPUT.PUT_LINE(SQLERRM);
		   
END;		   

IF row_cnt > 1 THEN
 l_select_list := 'INVOICE_ID,INVOICE_NUM,INVOICE_AMOUNT,AMOUNT_PAID,CANCELLED_DATE,ORG_ID';  
  l_table_name := 'ap_canc_inv_amt_paid_9365984';
  l_where_clause := 'WHERE 1=1 ';
  
AP_Acctg_Data_Fix_PKG.Print( 'ap_canc_inv_amt_paid_sel.sql picked the invoice '||l_invoice_id||
                             ' due to amount paid on cancelled invoice '||
			     'Generate APLIST for this invoice and log a Service Request.');  



 AP_ACCTG_DATA_FIX_PKG.Print_html_table
    (p_select_list       => l_select_list,
     p_table_in          => l_table_name,
     p_where_in          => l_where_clause,
     P_calling_sequence  => l_calling_sequence);
	 

	
  PRINT_LINE;				
END IF;

FND_File.Put_Line(fnd_file.output,
                  '  END'||' '||'ap_canc_inv_amt_paid_sel.sql'||'     '||
                  to_char(sysdate, 'DD-MON-YYYY:HH24:MI:SS'));

EXCEPTION 
      
  WHEN OTHERS THEN
     FND_LOG.STRING(10, 'ap_canc_inv_amt_paid_sel.sql','Error is : ' || SQLERRM);
     AP_Acctg_Data_Fix_PKG.Print('Error is : ' || SQLERRM);

END ;

-- ap_canc_inv_amt_paid_sel.sql 





-- inv_incl_canc_sel.sql
/*REM +=======================================================================+
REM | FILENAME                                                              |
REM |     inv_incl_canc_sel.sql                                              |
REM |                                                                       |
REM | DESCRIPTION                                                           |
REM *      This script is used to indentify the cancelled invoices            *
REM *      where total tax is not zero but invoice is cancelled completely    *
REM *                                                                         *
REM *      CAUSE: 9244765                                                     *
REM +=======================================================================+*/

DECLARE 

  row_cnt NUMBER := 0;
BEGIN  

FND_File.Put_Line(fnd_file.output,
                   '---------------------------------------------------------');
FND_File.Put_Line(fnd_file.output,
                  'START'||' '||'inv_incl_canc_sel.sql'||'     '||
                  to_char(sysdate, 'DD-MON-YYYY:HH24:MI:SS'));

BEGIN
 EXECUTE IMMEDIATE 'DROP TABLE CANC_INVS_9244765';
EXCEPTION
  WHEN OTHERS THEN
    NULL;
END;


BEGIN


EXECUTE IMMEDIATE
'CREATE TABLE CANC_INVS_9244765 AS
 Select * from ap_invoices_all
  Where 1 = 2';

EXECUTE IMMEDIATE
'INSERT INTO CANC_INVS_9244765
SELECT * 
  FROM ap_invoices_all
 WHERE cancelled_date IS NOT NULL
   AND total_tax_amount <> 0
   And invoice_id = '|| l_invoice_id;

row_cnt := SQL%ROWCOUNT;


EXCEPTION
WHEN OTHERS THEN
DBMS_OUTPUT.PUT_LINE('IN EXP inv_incl_canc_sel.sql');
DBMS_OUTPUT.PUT_LINE(SQLERRM);
		   
END;		   

IF row_cnt > 1 THEN
 l_select_list := 'INVOICE_ID,INVOICE_NUM,ORG_ID,CANCELLED_DATE,TOTAL_TAX_AMOUNT';  
  l_table_name := 'CANC_INVS_9244765';
  l_where_clause := 'WHERE 1=1 ';
  
AP_Acctg_Data_Fix_PKG.Print( 'inv_incl_canc_sel.sql picked the invoice '||l_invoice_id||
                             ' due to total tax is non zero on cancelled invoice '||
			     'Generate APLIST for this invoice and log a Service Request.');  



 AP_ACCTG_DATA_FIX_PKG.Print_html_table
    (p_select_list       => l_select_list,
     p_table_in          => l_table_name,
     p_where_in          => l_where_clause,
     P_calling_sequence  => l_calling_sequence);
	 

	
  PRINT_LINE;				
END IF;


FND_File.Put_Line(fnd_file.output,
                  '  END'||' '||'inv_incl_canc_sel.sql'||'     '||
                  to_char(sysdate, 'DD-MON-YYYY:HH24:MI:SS'));

EXCEPTION 
      
  WHEN OTHERS THEN
     FND_LOG.STRING(10, 'inv_incl_canc_sel.sql','Error is : ' || SQLERRM);
     AP_Acctg_Data_Fix_PKG.Print('Error is : ' || SQLERRM);

END ;

-- inv_incl_canc_sel.sql 





-- null_inv_line_num_sel.sql
/*REM +=======================================================================+
REM | FILENAME                                                              |
REM |     null_inv_line_num_sel.sql                                              |
REM |                                                                       |
REM | DESCRIPTION                                                           |
REM *      This script is used to indentify the tax lines which have no       *
REM *      tax distributions due to corresponding zx_lines are marked as      *
REM *      cancelled but zx_lines_summary is not cancelled.Such invoices      *
REM *      are picked for validation agian and again though validated already *
REM *                                                                         *
REM *      CAUSE Code Fix  9193069                                           *
REM +=======================================================================+*/

DECLARE 

  row_cnt NUMBER := 0;
BEGIN  

FND_File.Put_Line(fnd_file.output,
                   '---------------------------------------------------------');
FND_File.Put_Line(fnd_file.output,
                  'START'||' '||'null_inv_line_num_sel.sql'||'     '||
                  to_char(sysdate, 'DD-MON-YYYY:HH24:MI:SS'));

BEGIN
 EXECUTE IMMEDIATE 'DROP TABLE orphan_tax_dists';
EXCEPTION
  WHEN OTHERS THEN
    NULL;
END;


BEGIN


EXECUTE IMMEDIATE
'CREATE TABLE orphan_tax_dists AS
 Select invoice_id,invoice_line_number,distribution_line_number,
       line_type_lookup_code,detail_tax_dist_id,invoice_distribution_id,
       amount,posted_flag,accounting_event_id from ap_invoice_distributions_all
  Where 1 = 2';

EXECUTE IMMEDIATE
'INSERT INTO orphan_tax_dists
 Select invoice_id,invoice_line_number,distribution_line_number,
       line_type_lookup_code,detail_tax_dist_id,invoice_distribution_id,
       amount,posted_flag,accounting_event_id
  From ap_invoice_distributions_all
 Where line_type_lookup_code in (''REC_TAX'',''NONREC_TAX'',''TRV'',''TERV'',''TIPV'')
   And invoice_line_number IS NULL
   And invoice_id = '|| l_invoice_id;

row_cnt := SQL%ROWCOUNT;


EXCEPTION
WHEN OTHERS THEN
DBMS_OUTPUT.PUT_LINE('IN EXP null_inv_line_num_sel.sql');
DBMS_OUTPUT.PUT_LINE(SQLERRM);
		   
END;		   

IF row_cnt > 1 THEN
 l_select_list := 'INVOICE_ID,INVOICE_LINE_NUMBER,DISTRIBUTION_LINE_NUMBER,LINE_TYPE_LOOKUP_CODE,DETAIL_TAX_DIST_ID'||
                  ',INVOICE_DISTRIBUTION_ID,AMOUNT,POSTED_FLAG,ACCOUNTING_EVENT_ID' ;  
  l_table_name := 'ORPHAN_TAX_DISTS';
  l_where_clause := 'WHERE 1=1 ORDER BY INVOICE_LINE_NUMBER,LINE_TYPE_LOOKUP_CODE';
  
AP_Acctg_Data_Fix_PKG.Print( 'null_inv_line_num_sel.sql picked the invoice '||l_invoice_id||
                             ' due to Null line number on invoice lines'||
			     'Generate APLIST for this invoice and log a Service Request.');  



 AP_ACCTG_DATA_FIX_PKG.Print_html_table
    (p_select_list       => l_select_list,
     p_table_in          => l_table_name,
     p_where_in          => l_where_clause,
     P_calling_sequence  => l_calling_sequence);
	 

	
  PRINT_LINE;				
END IF;

FND_File.Put_Line(fnd_file.output,
                  '  END'||' '||'null_inv_line_num_sel.sql'||'     '||
                  to_char(sysdate, 'DD-MON-YYYY:HH24:MI:SS'));


EXCEPTION 
      
  WHEN OTHERS THEN
     FND_LOG.STRING(10, 'null_inv_line_num_sel.sql','Error is : ' || SQLERRM);
     AP_Acctg_Data_Fix_PKG.Print('Error is : ' || SQLERRM);

END ;

-- null_inv_line_num_sel.sql 






-- canc_tax_lines_sel.sql
/*REM +=======================================================================+
REM | FILENAME                                                              |
REM |     canc_tax_lines_sel.sql                                              |
REM |                                                                       |
REM | DESCRIPTION                                                           |
REM *      This script is used to indentify the tax lines which have no       *
REM *      tax distributions due to corresponding zx_lines are marked as      *
REM *      cancelled but zx_lines_summary is not cancelled.Such invoices      *
REM *      are picked for validation agian and again though validated already *
REM *                                                                         *
REM *      CAUSE: Code Fix  9193069                                           *
REM +=======================================================================+*/

DECLARE 

  row_cnt NUMBER := 0;
BEGIN  

FND_File.Put_Line(fnd_file.output,
                   '---------------------------------------------------------');
FND_File.Put_Line(fnd_file.output,
                  'START'||' '||'canc_tax_lines_sel.sql'||'     '||
                  to_char(sysdate, 'DD-MON-YYYY:HH24:MI:SS'));

BEGIN
 EXECUTE IMMEDIATE 'DROP TABLE Bug9193069_CANC_TAX_LINES';
EXCEPTION
  WHEN OTHERS THEN
    NULL;
END;
BEGIN

EXECUTE IMMEDIATE
'CREATE TABLE Bug9193069_CANC_TAX_LINES AS
 Select *  from ap_invoice_lines_all
  Where 1 = 2';

EXECUTE IMMEDIATE
'INSERT INTO Bug9193069_CANC_TAX_LINES
SELECT ail.*
  FROM ap_invoice_lines_all ail
 WHERE ail.line_type_lookup_code =''TAX''
   AND ail.invoice_id = :1
   AND ail.summary_tax_line_id IS NOT NULL
   AND ail.amount = 0
   AND NVL(ail.cancelled_flag,''N'') = ''N''
   AND NVL(ail.discarded_flag,''N'') = ''N''
   AND EXISTS
      (SELECT 1
         FROM zx_lines zl1
        WHERE zl1.trx_id = ail.invoice_id
          AND zl1.application_id = 200
          AND zl1.entity_code = ''AP_INVOICES''
          AND zl1.event_class_code IN 
             (''STANDARD INVOICES'', ''PREPAYMENT INVOICES'', ''EXPENSE REPORTS'')
          AND zl1.summary_tax_line_id = ail.summary_tax_line_id)
   AND NOT EXISTS 
      (SELECT 1
         FROM zx_lines zl
        WHERE zl.trx_id = ail.invoice_id
          AND zl.application_id = 200
          AND zl.entity_code = ''AP_INVOICES''
          AND zl.event_class_code IN 
             (''STANDARD INVOICES'', ''PREPAYMENT INVOICES'', ''EXPENSE REPORTS'')
          AND zl.summary_tax_line_id = ail.summary_tax_line_id
          AND NVL(cancel_flag,''N'') = ''N'') '
         USING l_invoice_id;

row_cnt := SQL%ROWCOUNT;

EXCEPTION
WHEN OTHERS THEN
DBMS_OUTPUT.PUT_LINE('IN EXP canc_tax_lines_sel.sql');
DBMS_OUTPUT.PUT_LINE(SQLERRM);
		   
END;		   

IF row_cnt > 1 THEN
 l_select_list := 'INVOICE_ID,LINE_NUMBER,DISTRIBUTION_LINE_NUMBER,LINE_TYPE_LOOKUP_CODE,INVOICE_DISTRIBUTION_ID,'||
                  'SUMMARY_TAX_LINE_ID,AMOUNT,CANCELLED_FLAG,DISCARDED_FLAG' ;  
  l_table_name := 'Bug9193069_CANC_TAX_LINES';
  l_where_clause := 'WHERE 1=1 ORDER BY INVOICE_LINE_NUMBER';
  
AP_Acctg_Data_Fix_PKG.Print( 'canc_tax_lines_sel.sql picked the invoice '||l_invoice_id||
                             ' due to invoices picking up for validation due to no distribution for tax lines'||
			     'Generate APLIST for this invoice and log a Service Request.');  



 AP_ACCTG_DATA_FIX_PKG.Print_html_table
    (p_select_list       => l_select_list,
     p_table_in          => l_table_name,
     p_where_in          => l_where_clause,
     P_calling_sequence  => l_calling_sequence);
	 

	
  PRINT_LINE;				
END IF;

FND_File.Put_Line(fnd_file.output,
                  '  END'||' '||'canc_tax_lines_sel.sql'||'     '||
                  to_char(sysdate, 'DD-MON-YYYY:HH24:MI:SS'));

EXCEPTION 
      
  WHEN OTHERS THEN
     FND_LOG.STRING(10, 'canc_tax_lines_sel.sql','Error is : ' || SQLERRM);
     AP_Acctg_Data_Fix_PKG.Print('Error is : ' || SQLERRM);

END ;

-- canc_tax_lines_sel.sql 







-- canc_inv_wrong_enc_flag_bc_evnt_sel.sql
/*REM +=======================================================================+
REM | FILENAME                                                              |
REM |     canc_inv_wrong_enc_flag_bc_evnt_sel.sql                                              |
REM |                                                                       |
REM | DESCRIPTION                                                           |
REM *      Script to select invoice distributions on cancelled invoice that   *
REM *      have : MSF <> 'A', ENC FLAG = NULL / N, bc_event_id NOT NULL  OR   *
REM *             MSF =  'A', ENC FLAG = R       , bc_event_id NOT NULL  OR   *
REM *             MSF <> 'A', ENC FLAG = N       , bc_event_id NULL           *
REM *             and in both case, bc_event_id is not processed              *
REM *                                                                         *
REM *    CODE FIX : 8733916                                                   *
REM +=======================================================================+*/

DECLARE 

  row_cnt NUMBER := 0;
BEGIN  

FND_File.Put_Line(fnd_file.output,
                   '---------------------------------------------------------');
FND_File.Put_Line(fnd_file.output,
                  'START'||' '||'canc_inv_wrong_enc_flag_bc_evnt_sel.sql'||'     '||
                  to_char(sysdate, 'DD-MON-YYYY:HH24:MI:SS'));

BEGIN
 EXECUTE IMMEDIATE 'DROP TABLE aid_bkup_9407332';
EXCEPTION
  WHEN OTHERS THEN
    NULL;
END;
BEGIN

EXECUTE IMMEDIATE
'CREATE TABLE aid_bkup_9407332 AS
 Select *  from ap_invoice_distributions_all
  Where 1 = 2';

EXECUTE IMMEDIATE
'INSERT INTO aid_bkup_9407332
SELECT AID.*
  FROM ap_invoice_distributions_all AID,
       ap_invoices_all              AI
 WHERE AI.invoice_id = AID.invoice_id
    and ai.invoice_id = :1  
    AND ( AI.cancelled_date IS NOT NULL 
         OR AI.temp_cancelled_amount IS NOT NULL )
   AND AI.invoice_amount = 0
   AND NVL( AI.historical_flag, ''N'' ) <> ''Y''
   AND AI.validation_request_id IS NULL
   AND ( SELECT SUM( AID1.amount ) 
           FROM ap_invoice_distributions_all AID1
          WHERE AID1.invoice_id = AI.invoice_id 
       ) = 0
   AND NOT EXISTS ( SELECT 1 
                      FROM ap_invoice_distributions_all AID2
                     WHERE AID2.invoice_id = AI.invoice_id
        	       AND AID2.parent_reversal_id IS NULL
                       AND AID2.reversal_flag = ''Y''
                       AND ( SELECT COUNT( 1 )
                               FROM ap_invoice_distributions_all AID3
                              WHERE AID3.parent_reversal_id = AID2.invoice_distribution_id 
                           ) <> 1 
                  )
   AND ( ( NVL( AID.match_status_flag, ''N'' ) <> ''A'' 
           AND NVL( AID.encumbered_flag, ''N'' ) = ''N''
           AND AID.bc_event_id IS NOT NULL
         ) 
         OR
         ( NVL( AID.match_status_flag, ''A'' ) = ''A'' 
           AND NVL(AID.encumbered_flag,''N'') = ''R''
           AND AID.bc_event_id IS NOT NULL 
         ) 
         OR
         ( NVL( AID.match_status_flag, ''N'' ) <> ''A'' 
           AND NVL(AID.encumbered_flag,''N'') = ''N''
           AND AID.bc_event_id IS NULL
         ) 
       )
   AND NOT EXISTS ( SELECT 1
                      FROM xla_events XE
                     WHERE XE.application_id = 200
                       AND XE.event_id = AID.bc_event_id
                       AND XE.event_status_code = ''P'' 
                  ) '
         USING l_invoice_id;

row_cnt := SQL%ROWCOUNT;

EXCEPTION
WHEN OTHERS THEN
DBMS_OUTPUT.PUT_LINE('IN EXP canc_inv_wrong_enc_flag_bc_evnt_sel.sql');
DBMS_OUTPUT.PUT_LINE(SQLERRM);
		   
END;		   

IF row_cnt > 1 THEN
 l_select_list := 'INVOICE_ID,INVOICE_LINE_NUMBER,DISTRIBUTION_LINE_NUMBER,LINE_TYPE_LOOKUP_CODE,INVOICE_DISTRIBUTION_ID,'||
                  'CANCELLED_DATE,MATCH_STATUS_FLAG' ;  
  l_table_name := 'no_rev_awt_dists';
  l_where_clause := 'WHERE 1=1 ORDER BY INVOICE_LINE_NUMBER';
  
AP_Acctg_Data_Fix_PKG.Print( 'canc_inv_wrong_enc_flag_bc_evnt_sel.sql picked the invoice '||l_invoice_id||
                             ' due to Cancelled invoice with distributions having MSF and enc flag discripency.'||
			     'Generate APLIST for this invoice and log a Service Request.');  



 AP_ACCTG_DATA_FIX_PKG.Print_html_table
    (p_select_list       => l_select_list,
     p_table_in          => l_table_name,
     p_where_in          => l_where_clause,
     P_calling_sequence  => l_calling_sequence);
	 

	
  PRINT_LINE;				
END IF;

FND_File.Put_Line(fnd_file.output,
                  '  END'||' '||'canc_inv_wrong_enc_flag_bc_evnt_sel.sql'||'     '||
                  to_char(sysdate, 'DD-MON-YYYY:HH24:MI:SS'));

EXCEPTION 
      
  WHEN OTHERS THEN
     FND_LOG.STRING(10, 'canc_inv_wrong_enc_flag_bc_evnt_sel.sql','Error is : ' || SQLERRM);
     AP_Acctg_Data_Fix_PKG.Print('Error is : ' || SQLERRM);

END ;

-- canc_inv_wrong_enc_flag_bc_evnt_sel.sql 






-- awt_rev_dist_sel.sql
/*REM +=======================================================================+
REM | FILENAME                                                              |
REM |     awt_rev_dist_sel.sql                                              |
REM |                                                                       |
REM | DESCRIPTION                                                           |
REM *      Script to select cancelled or discarded AWT distributions          *
REM *      which dont have reversal distribution populated.                   *
REM +=======================================================================+*/

DECLARE 

  row_cnt NUMBER := 0;
BEGIN  

FND_File.Put_Line(fnd_file.output,
                   '---------------------------------------------------------');
FND_File.Put_Line(fnd_file.output,
                  'START'||' '||'awt_rev_dist_sel.sql'||'     '||
                  to_char(sysdate, 'DD-MON-YYYY:HH24:MI:SS'));
BEGIN
 EXECUTE IMMEDIATE 'DROP TABLE NO_REV_AWT_DISTS';
EXCEPTION
  WHEN OTHERS THEN
    NULL;
END;
BEGIN

EXECUTE IMMEDIATE
'CREATE TABLE NO_REV_AWT_DISTS AS
 Select *  from ap_invoice_distributions_all
  Where 1 = 2';

EXECUTE IMMEDIATE
'INSERT INTO NO_REV_AWT_DISTS
 select * 
  from ap_invoice_distributions_all aid
 where aid.line_type_lookup_code = ''AWT''
   and aid.reversal_flag = ''Y''
   and aid.parent_reversal_id is null   
   and not exists (select ''no reversal'' 
                     from ap_invoice_distributions_all aid1
					where aid.invoice_id = aid1.invoice_id
					  and aid.invoice_distribution_id = aid1.parent_reversal_id
					  and aid1.line_type_lookup_code = ''AWT'')
    and aid.invoice_id = :1'
         USING l_invoice_id;

row_cnt := SQL%ROWCOUNT;

EXCEPTION
WHEN OTHERS THEN
DBMS_OUTPUT.PUT_LINE('IN EXP awt_rev_dist_sel.sql');
DBMS_OUTPUT.PUT_LINE(SQLERRM);
		   
END;		   

IF row_cnt > 1 THEN
 l_select_list := 'INVOICE_ID,INVOICE_LINE_NUMBER,DISTRIBUTION_LINE_NUMBER,LINE_TYPE_LOOKUP_CODE,INVOICE_DISTRIBUTION_ID,'||
                  'PARENT_REVERSAL_ID,CHARGE_APPLICABLE_TO_DIST_ID,REVERSAL_FLAG,ACCOUNTING_EVENT_ID,ORG_ID' ;  
  l_table_name := 'no_rev_awt_dists';
  l_where_clause := 'WHERE 1=1 ORDER BY INVOICE_LINE_NUMBER';
  
AP_Acctg_Data_Fix_PKG.Print( 'awt_rev_dist_sel.sql picked the invoice '||l_invoice_id||
                             ' due to No reversal distributions for reversed AWT distributions'||
			     'Generate APLIST for this invoice and log a Service Request.');  



 AP_ACCTG_DATA_FIX_PKG.Print_html_table
    (p_select_list       => l_select_list,
     p_table_in          => l_table_name,
     p_where_in          => l_where_clause,
     P_calling_sequence  => l_calling_sequence);
	 

	
  PRINT_LINE;				
END IF;


FND_File.Put_Line(fnd_file.output,
                  '  END'||' '||'awt_rev_dist_sel.sql'||'     '||
                  to_char(sysdate, 'DD-MON-YYYY:HH24:MI:SS'));

EXCEPTION 
      
  WHEN OTHERS THEN
     FND_LOG.STRING(10, 'awt_rev_dist_sel.sql','Error is : ' || SQLERRM);
     AP_Acctg_Data_Fix_PKG.Print('Error is : ' || SQLERRM);

END ;

-- awt_rev_dist_sel.sql 




-- ap_split_prepay_alloc_sel.sql
/*REM +=======================================================================+
REM | FILENAME                                                              |
REM |     ap_split_prepay_alloc_sel.sql                              |
REM |                                                                       |
REM | DESCRIPTION                                                           |
REM *      In 11i, we can allocate the tax distribution to both ITEM and      *
REM *      PREPAY. for this case upgrade creating same invoice line in R12    *
REM *      for both the prepay and item tax distributions, due to this TAX    *
REM *      SUMMARY ID going wrong and on any action on that invoice going     *
REM *      wrong.                                                             *
REM +=======================================================================+*/

DECLARE 

  row_cnt NUMBER := 0;
BEGIN  

FND_File.Put_Line(fnd_file.output,
                   '---------------------------------------------------------');
FND_File.Put_Line(fnd_file.output,
                  'START'||' '||'ap_split_prepay_alloc_sel.sql'||'     '||
                  to_char(sysdate, 'DD-MON-YYYY:HH24:MI:SS'));

BEGIN
 EXECUTE IMMEDIATE 'DROP TABLE B9054372_DRIVER_TBL';
EXCEPTION
  WHEN OTHERS THEN
    NULL;
END;
BEGIN

EXECUTE IMMEDIATE
'Create table B9054372_DRIVER_TBL as
 Select aid_tax.invoice_id,
        aid_tax.invoice_line_number,
        aid_tax.distribution_line_number,
        aid_tax.line_type_lookup_code,
        aid_tax.invoice_distribution_id,
        aid_tax.parent_reversal_id,
        aid_tax.charge_applicable_to_dist_id,
        aid_tax.reversal_flag,
        aid_tax.summary_tax_line_id,
        aid_tax.detail_tax_dist_id,
        aid_tax.old_distribution_id,
        aid_tax.old_dist_line_number,
        aid_tax.accounting_event_id,
        aid_tax.org_id
   from ap_invoice_distributions_all aid_tax
  Where 1 = 2';

EXECUTE IMMEDIATE
'INSERT INTO B9054372_DRIVER_TBL
 Select aid_tax.invoice_id,
        aid_tax.invoice_line_number,
        aid_tax.distribution_line_number,
        aid_tax.line_type_lookup_code,
        aid_tax.invoice_distribution_id,
        aid_tax.parent_reversal_id,
        aid_tax.charge_applicable_to_dist_id,
        aid_tax.reversal_flag,
        aid_tax.summary_tax_line_id,
        aid_tax.detail_tax_dist_id,
        aid_tax.old_distribution_id,
        aid_tax.old_dist_line_number,
        aid_tax.accounting_event_id,
        aid_tax.org_id
   from ap_invoice_distributions_all aid_tax
  Where aid_tax.line_type_lookup_code in (''REC_TAX'', ''NONREC_TAX'')
    and exists (select 1
           From ap_invoice_distributions_all aid_prepay
          where aid_prepay.line_type_lookup_code = ''PREPAY''
            and aid_prepay.invoice_distribution_id =
                aid_tax.charge_applicable_to_dist_id
            and aid_prepay.invoice_id = aid_tax.invoice_id)
    and exists (select 1
                from ap_invoice_lines_all ail,
		     ap_invoice_distributions_all aid,
		     ap_invoice_distributions_all aid_item
		where ail.invoice_id = aid_tax.invoice_id
		and   ail.line_number = aid_tax.invoice_line_number
		and   ail.line_type_lookup_code = ''TAX''
		and   ail.invoice_id = aid.invoice_id
		and   ail.line_number = aid.invoice_line_number
		and   aid.invoice_distribution_id <> aid_tax.invoice_distribution_id
		and   aid.charge_applicable_to_dist_id = aid_item.invoice_distribution_id
		and   aid.invoice_id = aid_item.invoice_id
		and   aid_item.line_type_lookup_code <> ''PREPAY'')
    and aid_tax.historical_flag = ''Y''
    and aid_tax.invoice_id = :1'
         USING l_invoice_id;

row_cnt := SQL%ROWCOUNT;

EXCEPTION
WHEN OTHERS THEN
DBMS_OUTPUT.PUT_LINE('IN EXP ap_split_prepay_alloc_sel.sql');
DBMS_OUTPUT.PUT_LINE(SQLERRM);
		   
END;		   

IF row_cnt > 1 THEN
 l_select_list := 'INVOICE_ID,INVOICE_LINE_NUMBER,DISTRIBUTION_LINE_NUMBER,LINE_TYPE_LOOKUP_CODE,INVOICE_DISTRIBUTION_ID,'||
                  'PARENT_REVERSAL_ID,CHARGE_APPLICABLE_TO_DIST_ID,REVERSAL_FLAG,SUMMARY_TAX_LINE_ID,DETAIL_TAX_DIST_ID,'||
                  'OLD_DISTRIBUTION_ID,OLD_DIST_LINE_NUMBER,ACCOUNTING_EVENT_ID,ORG_ID' ;  
  l_table_name := 'B9054372_DRIVER_TBL';
  l_where_clause := 'WHERE 1=1 ORDER BY INVOICE_LINE_NUMBER';
  
AP_Acctg_Data_Fix_PKG.Print( 'ap_split_prepay_alloc_sel.sql picked the invoice '||l_invoice_id||
                             ' due to tax allocated to both prepay and ITEM dists in 11i'||
			     'Generate APLIST for this invoice and log a Service Request.');  



 AP_ACCTG_DATA_FIX_PKG.Print_html_table
    (p_select_list       => l_select_list,
     p_table_in          => l_table_name,
     p_where_in          => l_where_clause,
     P_calling_sequence  => l_calling_sequence);
	 

	
  PRINT_LINE;				
END IF;

FND_File.Put_Line(fnd_file.output,
                  '  END'||' '||'ap_split_prepay_alloc_sel.sql'||'     '||
                  to_char(sysdate, 'DD-MON-YYYY:HH24:MI:SS'));

EXCEPTION 
      
  WHEN OTHERS THEN
     FND_LOG.STRING(10, 'ap_split_prepay_alloc_sel.sql','Error is : ' || SQLERRM);
     AP_Acctg_Data_Fix_PKG.Print('Error is : ' || SQLERRM);

END ;

-- ap_split_prepay_alloc_sel.sql 



--ap_ppay_non_po_match_encumbr_sel.sql
/*REM +=======================================================================+
REM | FILENAME                                                              |
REM |     ap_ppay_non_po_match_encumbr_sel.sql                              |
REM |                                                                       |
REM | DESCRIPTION                                                           |
REM *    Script to select those prepayment application lines on standard      *
REM *    invoices that refer to non po matched prepayments but po_header_id   *
REM *    is populated on the prepay appl lines(also prepay inv) and the       *
REM *    standard invoice is on CAN'T FUNDS CHECK hold.                       *
REM *                                                                         *
REM *    Ref bugs - 9205881, 9107249,9478118                                  *
REM *    Ct should apply the latest patch on APXINLIN.pld >>9021265         *
REM +=======================================================================+*/

DECLARE 

  row_cnt NUMBER := 0;
BEGIN  

FND_File.Put_Line(fnd_file.output,
                   '---------------------------------------------------------');
FND_File.Put_Line(fnd_file.output,
                  'START'||' '||'ap_ppay_non_po_match_encumbr_sel.sql'||'     '||
                  to_char(sysdate, 'DD-MON-YYYY:HH24:MI:SS'));

BEGIN
 EXECUTE IMMEDIATE 'DROP TABLE B9478118_AIL_BKP2';
EXCEPTION
  WHEN OTHERS THEN
    NULL;
END;
BEGIN

EXECUTE IMMEDIATE
'create table B9478118_AIL_BKP2 as
select * from ap_invoice_lines_all where 1 = 2';

EXECUTE IMMEDIATE
'INSERT INTO B9478118_AIL_BKP2
Select ail.* 
  from ap_invoice_lines_all ail 
   where ail.prepay_invoice_id is not null 
     and ail.invoice_id = '||l_invoice_id||'
     and ail.prepay_line_number is not null 
     and ail.PO_HEADER_ID is not null 
     and ail.PO_LINE_ID is null 
     and ail.PO_LINE_LOCATION_ID is null 
     and ail.PO_DISTRIBUTION_ID is null 
     and exists (SELECT invoice_id 
            FROM ap_holds_all 
           WHERE hold_lookup_code = ''CANT FUNDS CHECK'' 
             AND status_flag != ''R'' 
             AND release_lookup_code is NULL)';

row_cnt := SQL%ROWCOUNT;

EXCEPTION
WHEN OTHERS THEN
DBMS_OUTPUT.PUT_LINE('IN EXP ap_ppay_non_po_match_encumbr_sel.sql');
DBMS_OUTPUT.PUT_LINE(SQLERRM);
		   
END;		   

IF row_cnt > 1 THEN
 l_select_list := 'INVOICE_ID,LINE_NUMBER,PREPAY_INVOICE_ID,PREPAY_LINE_NUMBER,PO_HEADER_ID,PO_LINE_ID' ;  
  l_table_name := 'B9478118_AIL_BKP2';
  l_where_clause := 'WHERE 1=1 ORDER BY LINE_NUMBER';
  
AP_Acctg_Data_Fix_PKG.Print( 'ap_ppay_non_po_match_encumbr_sel.sql picked the invoice '||l_invoice_id||
                             ' due to wrong PO details on prepay apply event distribution which are not matched at all'||
			     'Generate APLIST for this invoice and log a Service Request.');  



 AP_ACCTG_DATA_FIX_PKG.Print_html_table
    (p_select_list       => l_select_list,
     p_table_in          => l_table_name,
     p_where_in          => l_where_clause,
     P_calling_sequence  => l_calling_sequence);
	 

	
  PRINT_LINE;				
END IF;

FND_File.Put_Line(fnd_file.output,
                  '  END'||' '||'ap_ppay_non_po_match_encumbr_sel.sql'||'     '||
                  to_char(sysdate, 'DD-MON-YYYY:HH24:MI:SS'));

EXCEPTION 
      
  WHEN OTHERS THEN
     FND_LOG.STRING(10, 'ap_ppay_non_po_match_encumbr_sel','Error is : ' || SQLERRM);
     AP_Acctg_Data_Fix_PKG.Print('Error is : ' || SQLERRM);

END ;

--ap_ppay_non_po_match_encumbr_sel.sql 





--Amt_Rem_Non_Zero_Can_Inv_Sel.sql
/*REM +=======================================================================+
REM | FILENAME                                                              |
REM |     Amt_Rem_Non_Zero_Can_Inv_Sel.sql                                      |
REM |                                                                       |
REM | DESCRIPTION                                                           |
REM *      This script is used to resolve the issue of amount_remaining       *
REM *      not being 0 for canceled invoices in ap_payment_Schedules_all      *
REM *      Code bug fixed via RCA  Still investigating                        *
REM *      Ref: bug 9176980                                                   *
REM +=======================================================================+*/

DECLARE 

  row_cnt NUMBER := 0;
BEGIN  

FND_File.Put_Line(fnd_file.output,
                   '---------------------------------------------------------');
FND_File.Put_Line(fnd_file.output,
                  'START'||' '||'Amt_Rem_Non_Zero_Can_Inv_Sel.sql'||'     '||
                  to_char(sysdate, 'DD-MON-YYYY:HH24:MI:SS'));

BEGIN
 EXECUTE IMMEDIATE 'DROP TABLE tmp_pmt_schedules_9176980';
EXCEPTION
  WHEN OTHERS THEN
    NULL;
END;
BEGIN

EXECUTE IMMEDIATE
'create table tmp_pmt_schedules_9176980 as
select * from ap_payment_schedules_all where 1 = 2';

EXECUTE IMMEDIATE
'INSERT INTO tmp_pmt_schedules_9176980
SELECT * FROM ap_payment_schedules_all
where invoice_id in (select invoice_id from ap_invoices_all ai
where cancelled_date is not null
and  ai.invoice_id = :1
and exists (select 1 from ap_payment_schedules_all aps
where aps.invoice_id = ai.invoice_id
and amount_remaining <> 0)
and exists ( select 1 from ap_invoice_payments_all aip
where aip.invoice_id = ai.invoice_id
group by aip.invoice_id
having sum(amount) = 0))'
         USING l_invoice_id;

row_cnt := SQL%ROWCOUNT;

EXCEPTION
WHEN OTHERS THEN
DBMS_OUTPUT.PUT_LINE('IN EXP Amt_Rem_Non_Zero_Can_Inv_Sel.sql');
DBMS_OUTPUT.PUT_LINE(SQLERRM);
		   
END;		   

IF row_cnt > 1 THEN
 l_select_list := 'INVOICE_ID,AMOUNT_REMAINING,PAYMENT_STATUS_FLAG,GROSS_AMOUNT' ;  
  l_table_name := 'TMP_PMT_SCHEDULES_9176980';
  l_where_clause := 'WHERE 1=1 ORDER BY INVOICE_ID';
  
AP_Acctg_Data_Fix_PKG.Print( 'Amt_Rem_Non_Zero_Can_Inv_Sel.sql picked the invoice '||l_invoice_id||
                             ' due to wrong amount remaining on cancelled invoice'||
			     'Generate APLIST for this invoice and log a Service Request.');  



 AP_ACCTG_DATA_FIX_PKG.Print_html_table
    (p_select_list       => l_select_list,
     p_table_in          => l_table_name,
     p_where_in          => l_where_clause,
     P_calling_sequence  => l_calling_sequence);
	 

	
  PRINT_LINE;				
END IF;

FND_File.Put_Line(fnd_file.output,
                  '  END'||' '||'Amt_Rem_Non_Zero_Can_Inv_Sel.sql'||'     '||
                  to_char(sysdate, 'DD-MON-YYYY:HH24:MI:SS'));

EXCEPTION 
      
  WHEN OTHERS THEN
     FND_LOG.STRING(10, 'Amt_Rem_Non_Zero_Can_Inv_Sel','Error is : ' || SQLERRM);
     AP_Acctg_Data_Fix_PKG.Print('Error is : ' || SQLERRM);

END ;

--Amt_Rem_Non_Zero_Can_Inv_Sel.sql 

--MISC_LINE_NOT_RVRSD_WEN_CNCLD_SEL.sql
/*REM +=======================================================================+
REM | FILENAME                                                              |
REM |     MISC_LINE_NOT_RVRSD_WEN_CNCLD_SEL.sql                             |
REM |                                                                       |
REM | DESCRIPTION                                                           |
REM *      This script is used to indentify the cancelled invoices            *
REM *      where quantity invoiced is not updated to 0 when invoice is        * 
REM *      cancelled, even PO values get updated.                             *
REM *      Ref: bug  9713262                                                  *
REM +=======================================================================+*/

DECLARE 

  row_cnt NUMBER := 0;
BEGIN  

FND_File.Put_Line(fnd_file.output,
                   '---------------------------------------------------------');
FND_File.Put_Line(fnd_file.output,
                  'START'||' '||'MISC_LINE_NOT_RVRSD_WEN_CNCLD_SEL.sql'||'     '||
                  to_char(sysdate, 'DD-MON-YYYY:HH24:MI:SS'));

BEGIN
 EXECUTE IMMEDIATE 'DROP TABLE ap_misc_line_bkp_9713262';
EXCEPTION
  WHEN OTHERS THEN
    NULL;
END;
BEGIN

EXECUTE IMMEDIATE
'create table ap_misc_line_bkp_9713262 as
select * from ap_invoice_lines_all where 1 = 2';

EXECUTE IMMEDIATE
'INSERT INTO ap_misc_line_bkp_9713262
 select ail.* from ap_invoice_lines_all ail,
              ap_invoices_all ai,
	      ap_invoice_distributions_all aid
 where  ai.temp_cancelled_amount is not null 
   and  ai.invoice_id =  :1
   and ail.invoice_id = ai.invoice_id
   and ail.line_type_lookup_code = ''MISCELLANEOUS''
   and ail.amount <> 0'
         USING l_invoice_id;

row_cnt := SQL%ROWCOUNT;

EXCEPTION
WHEN OTHERS THEN
DBMS_OUTPUT.PUT_LINE('IN EXP MISC_LINE_NOT_RVRSD_WEN_CNCLD_SEL.sql');
DBMS_OUTPUT.PUT_LINE(SQLERRM);
		   
END;		   

IF row_cnt > 1 THEN
 l_select_list := 'INVOICE_ID,LINE_NUMBER,AMOUNT,LINE_TYPE_LOOKUP_CODE' ;  
  l_table_name := 'AP_MISC_LINE_BKP_9713262';
  l_where_clause := 'WHERE 1=1 ORDER BY INVOICE_ID';
  
AP_Acctg_Data_Fix_PKG.Print( 'MISC_LINE_NOT_RVRSD_WEN_CNCLD_SEL.sql picked the invoice '||l_invoice_id||
                             ' due to no reversals for MISC dists for cancelled invoice'||
			     'Generate APLIST for this invoice and log a Service Request.');  



 AP_ACCTG_DATA_FIX_PKG.Print_html_table
    (p_select_list       => l_select_list,
     p_table_in          => l_table_name,
     p_where_in          => l_where_clause,
     P_calling_sequence  => l_calling_sequence);
	 

	
  PRINT_LINE;				
END IF;

FND_File.Put_Line(fnd_file.output,
                  '  END'||' '||'MISC_LINE_NOT_RVRSD_WEN_CNCLD_SEL.sql'||'     '||
                  to_char(sysdate, 'DD-MON-YYYY:HH24:MI:SS'));

EXCEPTION 
      
  WHEN OTHERS THEN
     FND_LOG.STRING(10, 'MISC_LINE_NOT_RVRSD_WEN_CNCLD_SEL.sql','Error is : ' || SQLERRM);
     AP_Acctg_Data_Fix_PKG.Print('Error is : ' || SQLERRM);

END ;

--MISC_LINE_NOT_RVRSD_WEN_CNCLD_SEL.sql



--tipv_terv_ccid_sel.sql
/*REM +=======================================================================+
REM | FILENAME                                                              |
REM |     tipv_terv_ccid_sel.sql                                            |
REM |                                                                       |
REM | DESCRIPTION                                                           |
REM *      Script to select all upgraded variance distributions for which  *
REM *      the ccids are populated wrongly.and from the fix script      _  *
REM *      we will populate the correct ccids.                             *
REM *                                                                      *
REM *      RCA : 9154829                                                   *
REM +=======================================================================+*/

DECLARE 

  row_cnt NUMBER := 0;
BEGIN  

FND_File.Put_Line(fnd_file.output,
                   '---------------------------------------------------------');
FND_File.Put_Line(fnd_file.output,
                  'START'||' '||'tipv_terv_ccid_sel.sql'||'     '||
                  to_char(sysdate, 'DD-MON-YYYY:HH24:MI:SS'));

BEGIN
 EXECUTE IMMEDIATE 'DROP TABLE r12_tipv_terv_dists';
EXCEPTION
  WHEN OTHERS THEN
    NULL;
END;
BEGIN

EXECUTE IMMEDIATE
'create table r12_tipv_terv_dists as
select * from ap_invoice_distributions_all where 1 = 2';

EXECUTE IMMEDIATE
'INSERT INTO  r12_tipv_terv_dists
 select aid.* from ap_invoice_distributions_all aid
 where aid.historical_flag = ''Y''
 and   aid.line_type_lookup_code in (''TIPV'',''TERV'')
 and   aid.dist_code_combination_id <>
       (SELECT DECODE(aid.line_type_lookup_code, 
	               ''TIPV'', NVL(ada.Price_Var_Code_Combination_ID, ada.Dist_Code_Combination_ID),
		       ''TERV'', NVL(ada.Rate_Var_Code_Combination_ID, ada.Dist_Code_Combination_ID))
        FROM ap_invoice_dists_arch ada
	WHERE ada.invoice_id = aid.invoice_id
	AND   ada.invoice_distribution_id = aid.old_distribution_id
	)
 and   aid.invoice_id = :1 '
         USING l_invoice_id;

row_cnt := SQL%ROWCOUNT;

EXCEPTION
WHEN OTHERS THEN
DBMS_OUTPUT.PUT_LINE('IN EXP tipv_terv_ccid_sel.sql');
DBMS_OUTPUT.PUT_LINE(SQLERRM);
		   
END;		   

IF row_cnt > 1 THEN
 l_select_list := 'INVOICE_ID,HISTORICAL_FLAG,POSTED_FLAG,AMOUNT,LINE_TYPE_LOOKUP_CODE,'
                 ||'INVOICE_LINE_NUMBER,DIST_CODE_COMBINATION_ID';  
  l_table_name := 'R12_TIPV_TERV_DISTS';
  l_where_clause := 'WHERE 1=1 ORDER BY INVOICE_LINE_NUMBER,LINE_TYPE_LOOKUP_CODE';
  
AP_Acctg_Data_Fix_PKG.Print( 'tipv_terv_ccid_sel.sql picked the invoice '||l_invoice_id||
                             ' due to mismatch in CCID after upgrade for TIPV and TERV dists. '||
			     'Generate APLIST for this invoice and log a Service Request.');  



 AP_ACCTG_DATA_FIX_PKG.Print_html_table
    (p_select_list       => l_select_list,
     p_table_in          => l_table_name,
     p_where_in          => l_where_clause,
     P_calling_sequence  => l_calling_sequence);
     
  PRINT_LINE;	
  
END IF;


FND_File.Put_Line(fnd_file.output,
                  '  END'||' '||'tipv_terv_ccid_sel.sql'||'     '||
                  to_char(sysdate, 'DD-MON-YYYY:HH24:MI:SS'));

EXCEPTION 
      
  WHEN OTHERS THEN
     FND_LOG.STRING(10, 'tipv_terv_ccid_sel.sql','Error is : ' || SQLERRM);
     AP_Acctg_Data_Fix_PKG.Print('Error is : ' || SQLERRM);

END ;

--tipv_terv_ccid_sel.sql


--ap_wrg_11i_chrg_alloc_sel.sql
/*REM +=======================================================================+
REM | FILENAME                                                              |
REM |     ap_wrg_11i_chrg_alloc_sel.sql                                     |
REM |                                                                       |
REM | DESCRIPTION                                                           |
REM *      This script is used to indentify all the upgraded invoices         *
REM *      for which the allocations went wrong.                              * 
REM *                                                                         *
REM *      GDF: bug  9741731                                                  *
REM +=======================================================================+*/

DECLARE 

  row_cnt NUMBER := 0;
BEGIN  

FND_File.Put_Line(fnd_file.output,
                   '---------------------------------------------------------');
FND_File.Put_Line(fnd_file.output,
                  'START'||' '||'ap_wrg_11i_chrg_alloc_sel.sql'||'     '||
                  to_char(sysdate, 'DD-MON-YYYY:HH24:MI:SS'));

BEGIN
 EXECUTE IMMEDIATE 'DROP TABLE AP_TEMP_DATA_DRIVER_9741731';
EXCEPTION
  WHEN OTHERS THEN
    NULL;
END;
BEGIN

EXECUTE IMMEDIATE
'create table AP_TEMP_DATA_DRIVER_9741731 as
select invoice_id,invoice_distribution_id,invoice_distribution_id aid2_dist_id,
line_type_lookup_code,line_type_lookup_code aid2_line_type,org_id aid_org_id 
from ap_invoice_distributions_all where 1 = 2';

EXECUTE IMMEDIATE
'INSERT INTO  AP_TEMP_DATA_DRIVER_9741731
SELECT DISTINCT atd.* FROM (
SELECT
  /*+ parallel(aca) */
  aid1.invoice_id,
  aid1.invoice_distribution_id,
  aid2.invoice_distribution_id aid2_dist_id,
  aid1.line_type_lookup_code ,
  aid2.line_type_lookup_code aid2_line_type,
  aid1.org_id aid_org_id
FROM ap_chrg_allocations_all aca,
  ap_invoice_dists_arch aid1,
  ap_invoice_dists_arch aid2
WHERE aid1.invoice_id            = aid2.invoice_id
AND aid1.invoice_distribution_id = aca.item_dist_id
AND aid2.invoice_distribution_id = aca.charge_dist_id
AND (aid1.line_type_lookup_code  = aid2.line_type_lookup_code)
UNION
SELECT
  /*+ parallel(aca) */
  aid1.invoice_id,
  aid1.invoice_distribution_id,
  aid2.invoice_distribution_id aid2_dist_id,
  aid1.line_type_lookup_code ,
  aid2.line_type_lookup_code aid2_line_type,
  aid1.org_id aid_org_id
FROM ap_chrg_allocations_all aca,
  ap_invoice_dists_arch aid1,
  ap_invoice_dists_arch aid2
WHERE aid1.invoice_id            = aid2.invoice_id
AND aid1.invoice_distribution_id = aca.item_dist_id
AND aid2.invoice_distribution_id = aca.charge_dist_id
AND (aid2.line_type_lookup_code  = ''ITEM'')
UNION
SELECT
  /*+ parallel(aca) */
  aid1.invoice_id,
  aid1.invoice_distribution_id,
  aid2.invoice_distribution_id aid2_dist_id,
  aid1.line_type_lookup_code ,
  aid2.line_type_lookup_code aid2_line_type,
  aid1.org_id aid_org_id
FROM ap_chrg_allocations_all aca,
  ap_invoice_dists_arch aid1,
  ap_invoice_dists_arch aid2
WHERE aid1.invoice_id            = aid2.invoice_id
AND aid1.invoice_distribution_id = aca.item_dist_id
AND aid2.invoice_distribution_id = aca.charge_dist_id
AND (aid2.line_type_lookup_code  IN (''FREIGHT'',''MISCELLANEOUS'') )
AND aid1.line_type_lookup_code = ''TAX'') atd
WHERE atd.invoice_id = :1
AND atd.invoice_id NOT IN 
       (SELECT DISTINCT aid.invoice_id 
        FROM ap_invoice_distributions_all aid,
	     xla_events xe
	WHERE aid.invoice_id = atd.invoice_id
	AND   xe.event_id = aid.accounting_event_id
	AND   xe.application_id = 200
	AND   NVL(xe.upg_batch_id,-9999) = -9999)
AND atd.invoice_id NOT IN 
   (SELECT DISTINCT aip.invoice_id
    FROM ap_invoice_payments_all aip,
         ap_payment_history_all aph,
	 xla_events xe
    WHERE aip.invoice_id = atd.invoice_id			        
    AND aip.check_id = aph.check_id			             
    AND aph.accounting_event_id = xe.event_id
    AND xe.application_id = 200			                 
    AND nvl(xe.upg_batch_id,-9999) = -9999)'
         USING l_invoice_id;

row_cnt := SQL%ROWCOUNT;

EXCEPTION
WHEN OTHERS THEN
DBMS_OUTPUT.PUT_LINE('IN EXP ap_wrg_11i_chrg_alloc_sel.sql');
DBMS_OUTPUT.PUT_LINE(SQLERRM);
		   
END;		   

IF row_cnt > 1 THEN
 l_select_list := 'INVOICE_ID,INVOICE_DISTRIBUTION_ID,AID2_DIST_ID,LINE_TYPE_LOOKUP_CODE,'||
                  'AID2_LINE_TYPE,AID_ORG_ID' ;  
  l_table_name := 'AP_TEMP_DATA_DRIVER_9741731';
  l_where_clause := 'WHERE 1=1 ORDER BY INVOICE_ID,INVOICE_DISTRIBUTION_ID';
  
AP_Acctg_Data_Fix_PKG.Print( 'ap_wrg_11i_chrg_alloc_sel.sql picked the invoice '||l_invoice_id||
                             ' due to wrong allocations in 11i'||
			     'Generate APLIST for this invoice and log a Service Request.');  



 AP_ACCTG_DATA_FIX_PKG.Print_html_table
    (p_select_list       => l_select_list,
     p_table_in          => l_table_name,
     p_where_in          => l_where_clause,
     P_calling_sequence  => l_calling_sequence);
	 

	
  PRINT_LINE;				
END IF;

FND_File.Put_Line(fnd_file.output,
                  '  END'||' '||'ap_wrg_11i_chrg_alloc_sel.sql'||'     '||
                  to_char(sysdate, 'DD-MON-YYYY:HH24:MI:SS'));

EXCEPTION 
      
  WHEN OTHERS THEN
     FND_LOG.STRING(10, 'ap_wrg_11i_chrg_alloc_sel.sql','Error is : ' || SQLERRM);
     AP_Acctg_Data_Fix_PKG.Print('Error is : ' || SQLERRM);

END ;

--ap_wrg_11i_chrg_alloc_sel.sql




--NOT_NULL_QTY_INV_SEL.sql
/*REM +=======================================================================+
REM | FILENAME                                                              |
REM |     NOT_NULL_QTY_INV_SEL.sql                                          |
REM |                                                                       |
REM | DESCRIPTION                                                           |
REM *      This script is used to indentify the cancelled invoices            *
REM *      where quantity invoiced is not updated to 0 when invoice is        * 
REM *      cancelled, even PO values get updated.                             *
REM *      CAUSE: 9570774                                                     *
REM +=======================================================================+*/

DECLARE 

  row_cnt NUMBER := 0;
BEGIN  

FND_File.Put_Line(fnd_file.output,
                   '---------------------------------------------------------');
FND_File.Put_Line(fnd_file.output,
                  'START'||' '||'NOT_NULL_QTY_INV_SEL.sql'||'     '||
                  to_char(sysdate, 'DD-MON-YYYY:HH24:MI:SS'));

BEGIN
 EXECUTE IMMEDIATE 'DROP TABLE CANC_INVS_WITH_QI_9570774';
EXCEPTION
  WHEN OTHERS THEN
    NULL;
END;
BEGIN

EXECUTE IMMEDIATE
'create table CANC_INVS_WITH_QI_9570774 as
select * from ap_invoice_lines_all where 1 = 2';

EXECUTE IMMEDIATE
'INSERT INTO  CANC_INVS_WITH_QI_9570774
SELECT ail.*  FROM ap_invoice_lines_all ail
 WHERE (nvl(discarded_flag,''N'') = ''Y''
         or nvl(cancelled_flag,''N'') = ''Y'')
    and  po_line_location_id is not null
    and  nvl(quantity_invoiced,0) <> 0
    and  ail.invoice_id = :1 '
         USING l_invoice_id;

row_cnt := SQL%ROWCOUNT;

EXCEPTION
WHEN OTHERS THEN
DBMS_OUTPUT.PUT_LINE('IN EXP NOT_NULL_QTY_INV_SEL.sql');
DBMS_OUTPUT.PUT_LINE(SQLERRM);
		   
END;		   

IF row_cnt > 1 THEN
 l_select_list := 'INVOICE_ID,LINE_NUMBER,AMOUNT,DISCARDED_FLAG,CANCELLED_FLAG,PO_LINE_LOCATION_ID,QUANTITY_INVOICED' ;  
  l_table_name := 'CANC_INVS_WITH_QI_9570774';
  l_where_clause := 'WHERE 1=1 ORDER BY INVOICE_ID';
  
AP_Acctg_Data_Fix_PKG.Print( 'NOT_NULL_QTY_INV_SEL.sql picked the invoice '||l_invoice_id||
                             ' due to quantity invoices is not reset for cancelled invoice'||
			     'Generate APLIST for this invoice and log a Service Request.');  



 AP_ACCTG_DATA_FIX_PKG.Print_html_table
    (p_select_list       => l_select_list,
     p_table_in          => l_table_name,
     p_where_in          => l_where_clause,
     P_calling_sequence  => l_calling_sequence);
	 

	
  PRINT_LINE;				
END IF;

FND_File.Put_Line(fnd_file.output,
                  '  END'||' '||'NOT_NULL_QTY_INV_SEL.sql'||'     '||
                  to_char(sysdate, 'DD-MON-YYYY:HH24:MI:SS'));

EXCEPTION 
      
  WHEN OTHERS THEN
     FND_LOG.STRING(10, 'NOT_NULL_QTY_INV_SEL.sql','Error is : ' || SQLERRM);
     AP_Acctg_Data_Fix_PKG.Print('Error is : ' || SQLERRM);

END ;

--NOT_NULL_QTY_INV_SEL.sql

-- non GDF End

--End Part of file--------------
AP_Acctg_Data_Fix_PKG.Print('For any issue/query/feedback contact Oracle Support'); 
 AP_Acctg_Data_Fix_PKG.Print('END OF FILE');

  AP_Acctg_Data_Fix_PKG.Print('</body></html>');
  AP_Acctg_Data_Fix_PKG.Close_Log_Out_Files;
  dbms_output.put_line('--------------------------------------------------'||
                       '-----------------------------');
  dbms_output.put_line(l_file_location||' is the output file created');
  dbms_output.put_line('--------------------------------------------------'||
                '-----------------------------');

END;
/
COMMIT;
