REM +===========================================================================+
REM | File Name          recon_120.sql 
REM |
REM |DESCRIPTION
REM |   This scripts checks the data integrity of transactions and identifies
REM |   the corrupt ones. This script does not fix any data
REM |
REM | EXTERNAL PUBLIC VARIABLES
REM |
REM | EXTERNAL DATATYPES
REM |
REM | KNOWN ISSUES
REM |  	The script might take long time as it has to analyse large volume of data
REM |   We advise the customers to run this script for a smaller data range if 
REM |   they have very high volume of  data.
REM |
REM | REFERENCES
REM |
REM | NOTES
REM |   This script computes the reconciliation difference for each day in the 
REM |    given gl_date range. If there is a mismatch in the figures, the different
REM |    possibilities of having this difference is analysed.
REM |   1.  Identify all the transactions with gl_date <= the input gl date max
REM |       and which have applications or adjustments with gl_date less  than the
REM |       invoice gl_date
REM |   2.  Identify all the invoices whose gl_date_closed is wrongly populated
REM |   3.  Identify all the adjustments in functional currency whose amount and
REM |       acctd_amount do not match
REM |   4.  Identify all the adjustments where the sign of amount and acctd_amount 
REM |       are different
REM |   5.  Identify those transactions whose amount_due_original does not match
REM |       with the sum of amount_due_remaining ,amount_applied and amount adjusted
REM |   6.  Identify those orphan credit memo applications which do not have the
REM |       corresponding records in ar_payment_schedules
REM |   7.  Identify those orphan records in ar_payment_schedules which do not have
REM |       the corresponding gl_dist records
REM |   8.  Identify those APP / UNAPP pair for which the gl_date of the APP record
REM |       is different from the gl_date of the UNAPP record.
REM |   9.  Identify those Applications in ar_receivable_applications whose 
REM |       unapplication gl_date is lesser than the original application gl_date
REM |  10.  Identify those receipts which have a record in ar_receivable_applications
REM |       in the given gl_date range and the original amount does not match with
REM |       the applied and remaining amounts
REM |  11.  Identify the receipts whose gl_date_closed is wrongly populated.
REM |  12.  Identify Applications having applied_payment_schedule_id wrongly popuated
REM |       in ar_receivable_applications. 
REM |  13.  Identify transactions or receipts for which the payment schedule is
REM |       marked as closed, but acctd_amount_due_remaining is not zero.
REM |       
REM |
REM |   The script will be enhanced to identify the corruptions which will be 
REM |   identified in the future
REM |
REM | USAGE
REM |      Supply the following when prompted:
REM |      1) org_id (REQUIRED) 
REM |      2) low and high gl_date (REQUIRED). Enter format DD-MON-YYYY
REM |      3) utl_file_dir (RECOMMENDED). Enter one of displayed options. 
REM |         Log file will be created in this directory, otherwise the first directory
REM |         in the utl_file_dir is used
REM |      4) the log file name (RECOMMENDED). If nothing is specified, the script 
REM |         generates the log messages in Recon.out file
REM |      5) Once the script completes, open the log file. If it lists any 
REM |         customer_trx_id or adjustment_id or cash_receipt_id, upload the 
REM |         corresponding ovc script outputs for development's analysis
REM |
REM | MODIFICATION HISTORY
REM | Date          Author            Description of Changes
REM | 09-Feb-04     rkader/sswayamp    Created
REM | 02-Mar-04     rkader             Modified to check the integrity of the
REM |                                  receipt data
REM | 15-Mar-04     rkader             Modified some queries to remove the constraint on GL_Date
REM | 19-Apr-04     rkader             Modified to check for the receipt's gl_date_closed
REM | 03-Jun-04     rvsharma           Modified to check integrity of RA.
REM | 28-Jul-04     rkader             Modified to check if acctd_amount_due_remaining is
REM |                                  zero if the payment schedule is closed.
REM | 24-Sep-05     rkader             Incorporate the code changes for the Data 
REM |                                  Reconciliation Project. The earlier versions will
REM |                                  error out in FP_G environments.
REM | 12-Mar-08	    samara             Modified setting org_id to work for R12
REM |
REM *============================================================================*/
set serveroutput on size 10000
PROMPT
define enter_org_id = '&org_id'
PROMPT
exec mo_global.set_policy_context('S','&enter_org_id');
PROMPT
define begin_gl_date = '&gl_date_low'
define end_gl_date = '&gl_date_high'
PROMPT
PROMPT Choose the directory from utl_file_dir where output should be written.
PROMPT 
SELECT value utl_file_dir FROM v$parameter WHERE UPPER(name)='UTL_FILE_DIR' ;
define out_dir_usr = '&Out_Dir_name'
PROMPT
PROMPT Enter the output file name
PROMPT
define  out_file = '&Out_File'
PROMPT
declare
 
   /* Identify all the transactions with gl_date <= the input gl date and which have
        applications gl_date less than the invoice gl_date
      Case 1 */
   cursor ps_apply_cur (l_start_gl_date date, l_end_gl_date date) is
   select ps.customer_trx_id , ps.payment_schedule_id 
   from ar_payment_Schedules ps
   Where ps.gl_date_Closed >= l_start_gl_date
   and ps.class <> 'PMT'
   and sign(ps.payment_schedule_id) <> -1
   and exists (select '1' from ar_receivable_applications ra
                  where ra.payment_schedule_id = ps.payment_schedule_id
                  and ra.gl_date < ps.gl_date
              union
              select '1' from ar_receivable_applications ra
                  where ra.applied_payment_schedule_id = ps.payment_schedule_id
                  and ra.gl_date < ps.gl_date
              union
              select '1' from ar_adjustments adj
                where adj.payment_schedule_id = ps.payment_schedule_id
                and adj.gl_date < ps.gl_date);

   /* Identify all the invoices whose gl_date_closed is wrongly populated
      Case 2 */
      cursor ps_gl_date_cur (l_start_gl_date date, l_end_gl_date date) is
      select ps.customer_trx_id , ps.payment_schedule_id 
      from ar_payment_Schedules ps 
      where gl_date_closed >= l_start_gl_date
      and trunc(ps.gl_date_Closed) <> to_date('31-DEC-4712','dd-MON-YYYY')
      and ps.class <> 'PMT' 
      and sign(ps.payment_schedule_id) <> -1 
      and exists (select '1' from ar_receivable_applications ra
                  where ra.payment_schedule_id = ps.payment_schedule_id
                  and ra.gl_date > ps.gl_date_closed
                  union
                  select '1' from ar_receivable_applications ra
                  where ra.applied_payment_schedule_id = ps.payment_schedule_id
                  and ra.gl_date > ps.gl_date_closed
                  union
                  select '1' from ar_adjustments adj
                  where adj.payment_schedule_id = ps.payment_schedule_id
                  and adj.gl_date > ps.gl_date_closed);

    /* Identify all the adjustments in functional currency whose amount does
       not match the accounted amount
       Case 3 */
   
     cursor adj_cur(l_start_gl_date date, l_end_gl_date date) is
     Select adj.adjustment_id,ps.customer_trx_id,adj.amount,adj.acctd_amount
     from ar_adjustments  adj, 
          ar_payment_schedules  ps,
          gl_sets_of_books books, ra_customer_trx  trx
     Where ps.gl_date_Closed >= l_start_gl_date
     and adj.customer_trx_id = ps.customer_trx_id
     and ps.customer_trx_id = trx.customer_trx_id
     and trx.set_of_books_id = books.set_of_books_id
     and books.currency_code = ps.invoice_currency_code
     and adj.amount <> adj.acctd_amount;
   
    /* Identify all the adjustments where sign(amount) <> sign(acctd_amount) 
       Case 4 */

     cursor adj_sign_cur(l_start_gl_date date, l_end_gl_date date) is
     Select adj.adjustment_id,ps.customer_trx_id,adj.amount,adj.acctd_amount
     from ar_adjustments  adj,
          ar_payment_schedules  ps
     where ps.gl_date_Closed >= l_start_gl_date
     and adj.customer_trx_id = ps.customer_trx_id
     and sign(adj.amount) <>  sign(adj.acctd_amount)
     and adj.acctd_amount <> 0;


  /* Indetify all the transactions created or applied or adjusted
     in the given gl_date range 
     Case 5 */
  cursor inv_cur(l_gl_date_low date, l_gl_date_high date) is 
    select pay.customer_trx_id
    from ar_payment_schedules pay
    where pay.gl_date between l_gl_date_low and l_gl_date_high
      and pay.class not in ('BR', 'PMT')
      and pay.payment_schedule_id >0
    union
    select pay.customer_trx_id
    from ar_receivable_applications ra , ar_payment_schedules pay  
    where ra.gl_date between l_gl_date_low and l_gl_date_high
     and nvl(ra.confirmed_flag,'Y') ='Y'
     and ra.status in ('APP','ACTIVITY')
     and ra.application_type ='CM'
     and pay.payment_schedule_id = ra.payment_schedule_id
    union
    select pay.customer_trx_id
    from ar_receivable_applications ra, ar_payment_schedules pay
    where ra.gl_date between l_gl_date_low and l_gl_date_high
     and nvl(ra.confirmed_flag,'Y') ='Y'
     and ra.status ='APP'
     and pay.payment_schedule_id = ra.applied_payment_schedule_id
    union
    select trx.customer_trx_id
    from   ra_customer_trx trx,
           ra_cust_trx_types type, ra_cust_trx_line_gl_dist gl_dist
    where  gl_dist.gl_date BETWEEN l_gl_date_low AND l_gl_date_high
    AND    gl_dist.gl_date IS NOT NULL
    AND    gl_dist.account_class   = 'REC'
    AND    gl_dist.latest_rec_flag = 'Y'
    AND    gl_dist.customer_trx_id = trx.customer_trx_id
    AND    type.cust_trx_type_id   = trx.cust_trx_type_id
    AND    trx.complete_flag       = 'Y'
    AND    type.type  in ('INV','DEP','GUAR', 'CM','DM', 'CB' )
    union
    select trx.customer_trx_id
     from  ra_customer_trx trx,
           ra_cust_trx_types type, ra_cust_trx_line_gl_dist gl_dist
    WHERE   trx.trx_date  BETWEEN l_gl_date_low AND l_gl_date_high
    AND     gl_dist.gl_date IS NULL
    AND     gl_dist.account_class   = 'REC'
    AND     gl_dist.latest_rec_flag = 'Y'
    AND     gl_dist.customer_trx_id = trx.customer_trx_id
    AND     type.cust_trx_type_id   = trx.cust_trx_type_id
    AND     trx.complete_flag       = 'Y'
    AND     type.type  in ('INV','DEP','GUAR', 'CM','DM', 'CB' )
    union
    select adj.customer_trx_id
    from ar_adjustments adj
    where adj.gl_date between l_gl_date_low and l_gl_date_high
    and nvl(adj.status,'A') = 'A'
    and adj.receivables_trx_id <> -15
    union
    select gl_dist.customer_trx_id
    from  ra_cust_trx_line_gl_dist gl_dist
    where gl_dist.amount = 0
     and gl_dist.acctd_amount <> 0
    and gl_dist.gl_date between l_gl_date_low and l_gl_date_high;
  
   /* Identify all the payment schedules of a given transaction */
  cursor ps_cur(l_cust_trx_id number) is
    select payment_schedule_id, acctd_amount_due_remaining, 
           gl_date_closed
    from ar_payment_schedules
    where customer_trx_id = l_cust_trx_id;

  /*Orphan Records In payment schedules 
    Case 6 */

  cursor orps_cur(l_gl_date_low date,l_gl_date_high date) is
   select pay.customer_trx_id
    from ar_payment_schedules pay
     where pay.class in ('INV','DEP','GUAR', 'CM','DM', 'CB')
     and pay.payment_schedule_id >0
     and not exists (select gl_dist.customer_trx_id
                      from   ra_customer_trx trx,
                             ra_cust_trx_types type, 
                             ra_cust_trx_line_gl_dist gl_dist
                     WHERE   gl_dist.gl_date = pay.gl_date
                       AND    gl_dist.customer_trx_id = pay.customer_trx_id
                       AND    gl_dist.gl_date IS NOT NULL
                       AND    gl_dist.account_class   = 'REC'
                       AND    gl_dist.latest_rec_flag = 'Y'
                       AND    gl_dist.customer_trx_id = trx.customer_trx_id
                       AND    type.cust_trx_type_id   = trx.cust_trx_type_id
                       AND    trx.complete_flag       = 'Y'
                       AND    type.type  in ('INV','DEP','GUAR', 'CM','DM','CB' ) /* Exclude BR and PMT */
                       AND    type.accounting_affect_flag = 'Y'
                      union
                       select gl_dist.customer_trx_id
                      from   ra_customer_trx trx,
                             ra_cust_trx_types type, 
                             ra_cust_trx_line_gl_dist gl_dist
                     WHERE   trx.trx_date = pay.gl_date
                       AND    gl_dist.customer_trx_id = pay.customer_trx_id
                       AND    gl_dist.gl_date IS NULL
                       AND    gl_dist.account_class   = 'REC'
                       AND    gl_dist.latest_rec_flag = 'Y'
                       AND    gl_dist.customer_trx_id = trx.customer_trx_id
                       AND    type.cust_trx_type_id   = trx.cust_trx_type_id
                       AND    trx.complete_flag       = 'Y'
                       AND    type.type  in ('INV','DEP','GUAR', 'CM','DM','CB' )
                       AND    type.accounting_affect_flag = 'Y');
  
 /* Orphan Record in RA 
    Case 7 */
  cursor orra_cur(l_gl_date_low date,l_gl_date_high date) is
  select ra.payment_schedule_id
  from ar_receivable_applications ra
   where ra.application_type =  'CM'
   and nvl(ra.postable,'Y') = 'Y'
   and not exists (select gl_dist.customer_trx_id
                    from  ra_cust_trx_line_gl_dist gl_dist,
                          ar_payment_schedules pay
                   WHERE    pay.payment_schedule_id = ra.payment_schedule_id
                   AND    gl_dist.gl_date IS NOT NULL
                   AND    gl_dist.account_class   = 'REC'
                   AND    gl_dist.latest_rec_flag = 'Y'
                   AND    pay.customer_trx_id = gl_dist.customer_trx_id);

   /* Find out if all the APP record in RA has a corresponding UNAPP
     record with same gl_date 
     Case 8 */
  cursor app_cur(l_gl_date_low date,l_gl_date_high date) is
  select ra.cash_receipt_id cr_id, ra.receivable_application_id rec_id
  from ar_receivable_applications ra
  where ra.status ='APP' 
   and ra.application_type =  'CASH'
   and nvl(ra.confirmed_flag,'Y') = 'Y'
   and ra.gl_date  BETWEEN l_gl_date_low AND l_gl_date_high
   and  not exists (select ra_unapp.receivable_application_id
                           from ar_receivable_applications ra_unapp, ar_distributions ard
                           where ard.source_id_secondary = ra.receivable_application_id
                           and ard.source_id_secondary is not null
                           and ra_unapp.receivable_application_id = ard.source_id
                           and ard.source_table ='RA'
                           and ard.source_type = 'UNAPP'
                           and ra_unapp.status = 'UNAPP'
			   and ra_unapp.gl_date = ra.gl_date
			   and ra_unapp.cash_receipt_id = ra.cash_receipt_id
			   and ra_unapp.cash_receipt_history_id = ra.cash_receipt_history_id)
   and not exists (select ra_unapp.receivable_application_id
                   from   ar_receivable_applications ra_unapp, ar_distributions ard
                   where ra_unapp.cash_receipt_id = ra.cash_receipt_id
                    and  ra_unapp.cash_receipt_history_id = ra.cash_receipt_history_id
                    and  ra_unapp.gl_date = ra.gl_date
                    and  ra_unapp.status = 'UNAPP'
                    and  ra_unapp.posting_control_id = ra.posting_control_id
                    and nvl(ra_unapp.gl_posted_date,sysdate) = nvl(ra.gl_posted_date, sysdate)
                    and  -ra_unapp.amount_applied = nvl(ra.amount_applied_from,ra.amount_applied)
                    and  ra_unapp.apply_date = ra.apply_date
                    and  ard.source_id = ra_unapp.receivable_application_id
                    and  ard.source_table = 'RA'
                    and ard.source_id_secondary is NULL);      
  /* Find out the corruption in reversal_gl_date for the APP records 
     Case 9 */
  cursor get_cr_ids(l_gl_date_low date, l_gl_date_high date) is
    select distinct cash_receipt_id
    from ar_receivable_applications
    where gl_date between l_gl_date_low and l_gl_date_high;
  cursor ra_rev_gl_cur(l_cr_id number) is
  select ra.cash_receipt_id cr_id,ra.receivable_application_id rec_id,
         ra_rev.receivable_application_id rev_rec_id, 
         ra.amount_applied+nvl(ra.earned_discount_taken,0)+nvl(ra.unearned_discount_taken,0)
         amount_applied
  from ar_receivable_applications ra, ar_distributions ard,
       ar_receivable_applications ra_rev  
   where ra.cash_receipt_id = l_cr_id
    and  ra.cash_receipt_id = ra_rev.cash_receipt_id
    and ard.source_id = ra_rev.receivable_application_id
    and ard.source_table ='RA'
    and ard.source_type ='REC'
    and ard.reversed_source_id = ra.receivable_application_id
    and ra.status ='APP'
    and ra_rev.status = 'APP'
    and nvl(ra.amount_applied_from, ra.amount_applied) = 
           -nvl(ra_rev.amount_applied_from,ra_rev.amount_applied)
   and ra.display ='N'
   and ra_rev.display = ra.display
   and ra.gl_date > ra_rev.gl_date;

   /* Identify all the receipts whose gl_date_closed is wrongly populated
      Case 11 */
      cursor rcpt_gl_date_cur (l_start_gl_date date, l_end_gl_date date) is
      select ps.cash_receipt_id , ps.payment_schedule_id
      from ar_payment_Schedules ps
      where gl_date_closed >= l_start_gl_date
      and trunc(ps.gl_date_Closed) <> to_date('31-DEC-4712','dd-MON-YYYY')
      and ps.class = 'PMT'
      and sign(ps.payment_schedule_id) <> -1
      and exists (select '1' from ar_receivable_applications ra
                  where ra.payment_schedule_id = ps.payment_schedule_id
                  and ra.gl_date > ps.gl_date_closed
		  and status in ('APP', 'ACTIVITY')
                  union
                  select '1' from ar_receivable_applications ra
                  where ra.applied_payment_schedule_id = ps.payment_schedule_id
                  and ra.gl_date > ps.gl_date_closed);

  /* Identify all the records having applied_customer_trx_id and
     applied_payment_schedule_id mismatch in RA table
   Case 12 */
   Cursor get_ra_id_curr is
   Select ps.customer_trx_id inv_id,ra.cash_receipt_id,ra.payment_schedule_id,
          ra.receivable_application_id,ra.customer_trx_id cm_id
      from ar_payment_schedules ps, ar_receivable_applications ra
        where ps.customer_trx_id = ra.applied_customer_trx_id
              and ra.applied_payment_schedule_id NOT IN ( select payment_schedule_id 
                                                        from ar_payment_schedules ps1
						        where ps1.customer_trx_id = ps.customer_trx_id) ;

   /* Check if the acctd_amount_due_remaining is zero if the payment schedule is
      marked as closed 
      Case 13 */
   Cursor get_incorrect_ps_status is
    select ps.payment_schedule_id, ps.class, ps.trx_number,
           decode(ps.class,'PMT',ps.cash_receipt_id,ps.customer_trx_id) trx_id,
           ps.gl_date, ps.acctd_amount_due_remaining AADR, ps.amount_due_remaining ADR
    from   ar_payment_schedules ps
    where  (status = 'CL' OR gl_date_closed <> to_Date('31-12-4712','DD-MM-YYYY'))
     and   acctd_amount_due_remaining <> 0;
   
  l_out_file                    varchar2(512):= ('&out_file'); 
  l_out_dir                     varchar2(512) ;
  l_out_dir_usr                 varchar2(512) := ('&out_dir_usr');
  l_begin_age_amt               number;
  l_begin_age_acctd_amt         number;
  l_end_age_amt                 number;
  l_end_age_acctd_amt           number;
  l_trx_reg_amt                 number;
  l_trx_reg_acctd_amt           number;
  l_unapp_reg_amt               number;
  l_unapp_reg_acctd_amt         number;
  l_app_reg_amt                 number;
  l_app_reg_acctd_amt           number;
  l_adj_reg_amt                 number;
  l_adj_reg_acctd_amt           number;
  l_cm_gain_loss                number;
  l_rounding_diff               number;
  l_inv_exp_amt                 number;
  l_inv_exp_acctd_amt           number;
  l_period_total_amt            number;
  l_period_total_acctd_amt      number;
  l_recon_diff_amt              number;
  l_recon_diff_acctd_amt        number;
  l_unapp_amt                   number;
  l_unapp_acctd_amt             number;
  l_acc_amt                     number;
  l_acc_acctd_amt               number;
  l_claim_amt                   number;
  l_claim_acctd_amt             number;
  l_prepay_amt                  number;
  l_prepay_acctd_amt            number;
  l_app_amt                     number;
  l_app_acctd_amt               number;
  l_edisc_amt                   number;
  l_edisc_acctd_amt             number;
  l_unedisc_amt                 number;
  l_unedisc_acctd_amt           number;
  l_fin_chrg_amt                number;
  l_fin_chrg_acctd_amt          number;
  l_adj_amt                     number;
  l_adj_acctd_amt               number;
  l_guar_amt                    number;
  l_guar_acctd_amt              number;
  l_dep_amt                     number;
  l_dep_acctd_amt               number;
  l_endorsmnt_amt               number;
  l_endorsmnt_acctd_amt         number;
  l_post_excp_amt               number;
  l_post_excp_acctd_amt         number;
  l_nonpost_excp_amt            number;
  l_nonpost_excp_acctd_amt      number;
  l_ps_id                       number;
  l_cust_trx_id                 number;
  l_rec_amount                  number;
  l_round_amount                number;
  l_amount_due_original_inv     number;
  l_amount_due_rem_inv          number;
  l_amount_due_remaining        number;
  l_amount_applied_from         number;
  l_amount_applied_to           number;
  l_amount_adjusted             number;
  l_gl_date_closed              date;
  l_max_gl_date                 date;
  l_amount_app_adj_inv          number;
  l_set_of_books_id             number;
  l_sob_name                    varchar2(300);
  l_functional_currency         varchar2(15);
  l_coa_id                      number;
  l_precision                   number;
  l_sysdate                     varchar2(20);
  l_organization                varchar2(300);
  l_bills_receivable_flag       varchar2(1);
  l_account_affect_flag         varchar2(1);
  l_non_post_amt                number;
  l_non_post_acctd_amt          number;
  l_post_amt                    number;
  l_post_acctd_amt              number;
  l_start_gl_date               date := ('&begin_gl_date');
  l_end_gl_date                 date := ('&end_gl_date');
  l_org_id                      number := ('&enter_org_id');
  l_ado_hist_amount             number;
  l_adr_ps_amount               number;
  l_rec_applied_from            number;
  l_rec_applied_to              number;
  l_rec_status                  varchar2(15);
  pg_fp                         utl_file.file_type;
  l_on_acc_cm_ref_amt           number; 
  l_on_acc_cm_ref_acctd_amt     number;
  l_cm_refund                   number;

  PROCEDURE debug(s varchar2) is
  BEGIN
      utl_file.put_line(pg_fp,s);
      utl_file.fflush(pg_fp);
  END debug;

  FUNCTION print_spaces(n IN number) RETURN Varchar2 IS
     l_return_string varchar2(100);
  Begin
     select substr('                                                   ',1,n)
     into l_return_String
     from dual;
        return(l_return_String);
  End print_spaces;

BEGIN
 

 If (l_start_gl_date > l_end_gl_date) then
        dbms_output.put_line(' REM                            ');
        dbms_output.put_line(' ERROR: Start GL-DATE should always be less than or equal to end GL-DATE');
        dbms_output.put_line(' REM                            ');
   return;
 end if;
   select value 
   into l_out_dir
   from v$parameter
   where upper(name) ='UTL_FILE_DIR';

   IF (instr(l_out_dir,l_out_dir_usr) = 0 AND l_out_dir_usr IS NOT NULL )
     OR l_out_dir_usr IS NULL THEN
     l_out_dir_usr := substr(l_out_dir,1,instr(l_out_dir,',')-1);
     dbms_output.put_line('The entered directory can not be used');
     dbms_output.put_line('The output will be written to '||l_out_dir_usr);
     dbms_output.put_line('                            ');
   END IF;
   IF l_out_file is null then
     l_out_file := 'Recon.out';
     dbms_output.put_line('The output is available in Recon.out file ');
     dbms_output.put_line('                            ');
   END IF;

   pg_fp := utl_file.fopen(l_out_dir_usr, l_out_file, 'w');

   debug('Org Id = '||l_org_id);
   debug('Start GL Date = '||l_start_gl_date);
   debug('End GL Date = '||l_end_gl_date);
   debug('Now Starting the analysis ..............');

   /* Case 1:
      Identify all the transactions with gl_date <= the input gl date and which have
        applications gl_date less than the invoice gl_date */

    debug('.................................');
    debug('Finding out transaction that have applications with gl_date less than its gl date');
    debug('CUSTOMER_TRX_ID     '||'PAYMENT_SCHEDULE_ID');
    debug('--------------      '||'-------------------');
    FOR ps_apply_rec in ps_apply_cur(l_start_gl_date,l_end_gl_date) LOOP
      debug(ps_apply_rec.customer_trx_id||
            print_spaces(20-length(ps_apply_rec.customer_trx_id))||
            ps_apply_rec.payment_schedule_id);
    END LOOP;
    debug('.................................');
      
   /* Case 2:
      Identify all the transactions whose gl_date_closed is wrongly populated */

    debug('Identifying invoices whose gl_date_closed is wrongly populated');
    debug('CUSTOMER_TRX_ID     '||'PAYMENT_SCHEDULE_ID');
    debug('--------------      '||'-------------------');
    FOR ps_gl_date_rec in ps_gl_date_cur(l_start_gl_date,l_end_gl_date) LOOP
      debug(ps_gl_date_rec.customer_trx_id||
            print_spaces(20-length(ps_gl_date_rec.customer_trx_id))||
            ps_gl_date_rec.payment_schedule_id);
    END LOOP;
    debug('.................................');

   /* Case 11:
      Identify all the receipts whose gl_date_closed is wrongly populated */

    debug('Identifying receipts whose gl_date_closed is wrongly populated');
    debug('CASH_RECEIPT_ID     '||'PAYMENT_SCHEDULE_ID');
    debug('--------------      '||'-------------------');
    FOR rcpt_gl_date_rec in rcpt_gl_date_cur(l_start_gl_date,l_end_gl_date) LOOP
      debug(rcpt_gl_date_rec.cash_receipt_id||
            print_spaces(20-length(rcpt_gl_date_rec.cash_receipt_id))||
            rcpt_gl_date_rec.payment_schedule_id);
    END LOOP;
    debug('.................................');

  /* Case 3:
     Identify the adjustments in functional currency where amount <> acctd_amount */

     debug('Identifying adjustments on functional currency invoices where amount and acctd amount do not match ');
     debug('CUSTOMER_TRX_ID     '||'ADJUSTMENT_ID       '|| 'ADJ AMOUNT     '||'ADJ ACCTD AMT');
     debug('---------------     '||'-------------       '|| '----------     '||'-------------');
     FOR adj_rec in adj_cur(l_start_gl_date,l_end_gl_date) LOOP
       debug(adj_rec.customer_trx_id|| print_spaces(20-length(adj_rec.customer_trx_id))||
             adj_rec.adjustment_id||print_spaces(20-length(adj_rec.adjustment_id))||
             adj_rec.amount||print_spaces(15-length(adj_rec.amount))||
             adj_rec.acctd_amount);
     END LOOP;
       debug('.................................');
      
  /* Case 4:
     Identify the adjustments where the sign of amount and acctd_amount are different */
     debug('Identifying adjustments for which the sign of amount and acctd_amount are different ');
     debug('CUSTOMER_TRX_ID     '||'ADJUSTMENT_ID       '|| 'ADJ AMOUNT     '||'ADJ ACCTD AMT');
     debug('---------------     '||'-------------       '|| '----------     '||'-------------');
     FOR adj_sign_rec in adj_sign_cur(l_start_gl_date,l_end_gl_date) LOOP
       debug(adj_sign_rec.customer_trx_id|| print_spaces(20-length(adj_sign_rec.customer_trx_id))||
             adj_sign_rec.adjustment_id||print_spaces(20-length(adj_sign_rec.adjustment_id))||
             adj_sign_rec.amount||print_spaces(15-length(adj_sign_rec.amount))||
             adj_sign_rec.acctd_amount);
     END LOOP;
       debug('.................................');
   /* Case 10
      Identify the corrupt Receipts */
   debug('Identifying corrupt receipts ');
   debug('CR_ID         '||'STATUS        '||'HIST AMOUNT     '||'ADR            '||'APPLIED_FROM    '||'APPLIED_TO');
   debug('------        '||'--------      '||'------------    '||'---------      '||'------------    '||'---------');
   for rec_cur in (select distinct cash_receipt_id,payment_schedule_id
                  from ar_receivable_applications
                  where gl_date between l_start_gl_date and l_end_gl_date
                    and cash_receipt_id is not null
                    and nvl(confirmed_flag,'Y') = 'Y')
   LOOP

    select acctd_amount+ nvl(acctd_factor_discount_amount,0), status
    into l_ado_hist_amount, l_rec_status
    from ar_cash_receipt_history
    where cash_receipt_id = rec_cur.cash_receipt_id
     and current_record_flag = 'Y';

    select ps.acctd_amount_due_remaining
    into l_adr_ps_amount
    from ar_payment_schedules ps
    where ps.cash_receipt_id = rec_cur.cash_receipt_id;

    select sum(nvl(ra.acctd_amount_applied_from,ra.amount_applied))
    into l_rec_applied_from
    from ar_receivable_applications ra
    where cash_Receipt_id = rec_cur.cash_receipt_id
     and status in ('APP','ACTIVITY')
     and application_type = 'CASH'
     and nvl(confirmed_flag,'Y')= 'Y';

    select sum(NVL(ra.acctd_amount_applied_to,ra.amount_applied))
    into l_rec_applied_to
    from ar_receivable_applications ra
    where ra.applied_payment_schedule_id = rec_cur.payment_schedule_id
    and ra.status = 'APP'
    and application_type = 'CASH'
    and nvl(ra.confirmed_flag,'Y')= 'Y';

    IF l_rec_status <> 'REVERSED' THEN
       if NVL(l_ado_hist_amount,0) <>  (NVL(-l_adr_ps_amount,0)-
                                    NVL(l_rec_applied_to,0)+nvl(l_rec_applied_from,0))
       then
           debug(rec_cur.cash_receipt_id||print_spaces(15-length(rec_cur.cash_receipt_id))||
                 l_rec_status||print_spaces(14-length(l_rec_status))||
                 NVL(l_ado_hist_amount,0)||print_spaces(16-length(NVL(l_ado_hist_amount,0)))||
                 NVL(-l_adr_ps_amount,0)||print_spaces(16-length(NVL(-l_adr_ps_amount,0)))||
                 nvl(l_rec_applied_from,0)||print_spaces(16-length(nvl(l_rec_applied_from,0)))||
                 NVL(l_rec_applied_to,0));
       end if;
    ELSE
       IF l_adr_ps_amount <> 0 OR NVL(l_rec_applied_to,0) <> 0 OR
             nvl(l_rec_applied_from,0) <>0 Then
           debug(rec_cur.cash_receipt_id||print_spaces(15-length(rec_cur.cash_receipt_id))||
                 l_rec_status||print_spaces(14-length(l_rec_status))||
                 NVL(l_ado_hist_amount,0)||print_spaces(16-length(NVL(l_ado_hist_amount,0)))||
                 NVL(-l_adr_ps_amount,0)||print_spaces(16-length(NVL(-l_adr_ps_amount,0)))||
                 nvl(l_rec_applied_from,0)||print_spaces(16-length(nvl(l_rec_applied_from,0)))||
                 NVL(l_rec_applied_to,0));
       END IF;
    END IF;
   end loop;
           debug('.................................');
   /* case 12 :
      Identify applications having wrong values of applied_payment_schedule_id */

    debug('Identifying applications whose applied_payment_schedules_id is wrongly populated in RA');
    debug('CR_ID          '||'CUSTOMER_TRX_ID (CM) '||'REC_APP_ID     '||'PS_ID          '||'CUSTOMER_TRX_ID');
    debug('----------     '||'-------------------  '||'----------     '||'--------       '||'---------------');
    FOR rcpt_ra_rec in get_ra_id_curr() LOOP
      debug(rcpt_ra_rec.cash_receipt_id||print_spaces(15-length(nvl(rcpt_ra_rec.cash_receipt_id,0)))||
            rcpt_ra_rec.cm_id||print_spaces(21-length(nvl(rcpt_ra_rec.cm_id,0)))||
            rcpt_ra_rec.receivable_application_id||
            print_spaces(15-length(rcpt_ra_rec.receivable_application_id))||
            rcpt_ra_rec.payment_schedule_id||
            print_spaces(15-length(rcpt_ra_rec.payment_schedule_id))||
            rcpt_ra_rec.inv_id);    
    END LOOP;

           debug('.................................');

    /* case 13 */
    /* Identify the transactions or receipts for which the payment schedule is closed but
       the acctd_amount_due_remaining is not zero */
    debug('Identifying trx or receipts for which the payment schedule is closed but AADR is NOT ZERO');
    debug(' ');
    debug('PS_ID      '||'CLASS '||'TRX_ID      '||'ADR             '||'AADR           '||'GL_DATE');
    debug('------     '||'----- '||'-------     '||'---------       '||'--------       '||'-------');
    FOR incorrect_ps_status in get_incorrect_ps_status LOOP
       debug(incorrect_ps_status.payment_schedule_id||
             print_spaces(12-length(incorrect_ps_status.payment_schedule_id))||
             incorrect_ps_status.class||
             print_spaces(6-length(incorrect_ps_status.class))||
             incorrect_ps_status.trx_id||
             print_spaces(13-length(incorrect_ps_status.trx_id))||
             incorrect_ps_status.adr||
             print_spaces(16-length(incorrect_ps_status.adr))||
             incorrect_ps_status.aadr||
             print_spaces(16-length(incorrect_ps_status.aadr))||
             incorrect_ps_status.gl_date);
    END LOOP;
           debug('---------------------------');
           debug('Searching for orphan/GL_DIST and PS mismatched records......');
           debug('CUSTOMER_TRX_ID');
           debug('---------------');
           for orps_rec in orps_cur(l_start_gl_date,l_start_gl_date) loop
              debug(orps_rec.customer_trx_id);
           end loop;
           debug('---------------------------');
           debug('Searching for orphan CM Applications in RA....');
           debug('PAYMENT_SCHEDULE_ID');
           debug('-------------------');
           for orra_rec in orra_cur(l_start_gl_date,l_start_gl_date) loop
              debug(orra_rec.payment_schedule_id);
           end loop;
           debug('---------------------------');
           debug('Searching for APP / UNAPP gl_date difference......');
           for app_rec in app_cur(l_start_gl_date,l_end_gl_date) loop
             debug('CASH_RECEIPT_ID     '||'RECEVIABLE_APP_ID');
             debug('---------------     '||'---------------');
              debug(app_rec.cr_id||print_spaces(20-length(app_rec.rec_id))||
               app_rec.rec_id);
           end loop;
           debug('---------------------------');
         select set_of_books_id into l_set_of_books_id from ar_system_parameters;

         ar_calc_aging.get_report_heading ( '3000',
                               l_org_id,
                               l_set_of_books_id ,
                               l_sob_name,
                               l_functional_currency,
                               l_coa_id,
                               l_precision,
                               l_sysdate,
                               l_organization ,
                               l_bills_receivable_flag);

   while l_start_gl_date <= l_end_gl_date loop

          ar_calc_aging.aging_as_of (l_start_gl_date-1 ,
                                     l_start_gl_date,
                                     '3000',
                                     l_org_id,
                                     NULL,
                                     NULL,
                                     NULL,
                                     l_begin_age_amt,
                                     l_end_age_amt,
                                     l_begin_age_acctd_amt,
                                     l_end_age_acctd_amt);

          ar_calc_aging.transaction_register(l_start_gl_date ,
                                   l_start_gl_date ,
                                   '3000',
                                   l_org_id,
                                   NULL,
                                   NULL,
                                   NULL,
                                   l_non_post_amt,
                                   l_non_post_acctd_amt,
                                   l_post_amt,
                                   l_post_acctd_amt);

          l_trx_reg_amt        := nvl(l_post_amt ,0)+
                                  nvl(l_non_post_amt,0);
          l_trx_reg_acctd_amt  := nvl(l_post_acctd_amt,0)+
                                  nvl(l_non_post_acctd_amt,0);

          ar_calc_aging.cash_receipts_register(l_start_gl_date,
                                       l_start_gl_date,
                                       '3000',
                                       l_org_id,
                                       NULL,
                                       NULL,
                                       NULL,
                                       l_unapp_amt,
                                       l_unapp_acctd_amt,
                                       l_acc_amt,
                                       l_acc_acctd_amt,
                                       l_claim_amt,
                                       l_claim_acctd_amt,
                                       l_prepay_amt,
                                       l_prepay_acctd_amt,
                                       l_app_amt,
                                       l_app_acctd_amt,
                                       l_edisc_amt,
                                       l_edisc_acctd_amt,
                                       l_unedisc_amt,
                                       l_unedisc_acctd_amt,
                                       l_cm_gain_loss,
                                       l_on_acc_cm_ref_amt,
                                       l_on_acc_cm_ref_acctd_amt );
         l_unapp_reg_amt  := nvl(l_unapp_amt,0) + nvl(l_acc_amt,0)+ 
                             nvl(l_claim_amt,0)+nvl(l_prepay_amt,0);
         l_unapp_reg_acctd_amt := nvl(l_unapp_acctd_amt,0)+nvl(l_acc_acctd_amt,0)+
                                  nvl(l_claim_acctd_amt,0)+nvl(l_prepay_acctd_amt,0);
         l_app_reg_amt  := nvl(l_app_amt,0)+nvl(l_edisc_amt,0)
                           +nvl(l_unedisc_amt,0)+nvl(l_on_acc_cm_ref_amt,0);
         l_app_reg_acctd_amt := nvl(l_app_acctd_amt,0)+nvl(l_edisc_acctd_amt,0)+
                                nvl(l_unedisc_acctd_amt,0)-nvl(l_on_acc_cm_ref_acctd_amt,0);

         ar_calc_aging.adjustment_register(l_start_gl_date,
                                     l_start_gl_date,
                                     '3000',
                                     l_org_id,
                                     NULL,
                                     NULL,
                                     NULL,
                                     l_fin_chrg_amt,
                                     l_fin_chrg_acctd_amt,
                                     l_adj_amt,
                                     l_adj_acctd_amt,
                                     l_guar_amt,
                                     l_guar_acctd_amt,
                                     l_dep_amt,
                                     l_dep_acctd_amt,
                                     l_endorsmnt_amt,
                                     l_endorsmnt_acctd_amt);

         l_adj_reg_amt       :=  nvl(l_fin_chrg_amt,0) +
                                 nvl(l_adj_amt,0) +
                                 nvl(l_guar_amt,0) +
                                 nvl(l_dep_amt,0) +
                                 nvl(l_endorsmnt_amt,0) ;
         l_adj_reg_acctd_amt :=   nvl(l_fin_chrg_acctd_amt,0) +
                                 nvl(l_adj_acctd_amt,0) +
                                 nvl(l_guar_acctd_amt,0) +
                                 nvl(l_dep_acctd_amt,0) +
                                 nvl(l_endorsmnt_acctd_amt,0);

         ar_calc_aging.invoice_exceptions(l_start_gl_date,
                                          l_start_gl_date,
                                          '3000',
                                          l_org_id,
                                          NULL,
                                          NULL,
                                          NULL,
                                          l_post_excp_amt,
                                          l_post_excp_acctd_amt, 
                                          l_nonpost_excp_amt,
                                          l_nonpost_excp_acctd_amt);

        l_inv_exp_amt              :=  nvl(l_post_excp_amt,0) +
                                       nvl(l_nonpost_excp_amt,0);
        l_inv_exp_acctd_amt        :=  nvl(l_post_excp_acctd_amt,0) +
                                       nvl(l_nonpost_excp_acctd_amt,0);

         l_period_total_acctd_amt  :=
             (l_begin_age_acctd_amt + l_trx_reg_acctd_amt 
             - l_unapp_reg_acctd_amt - l_app_reg_acctd_amt 
             + l_adj_reg_acctd_amt + l_cm_gain_loss
             - l_inv_exp_acctd_amt);
         IF l_period_total_acctd_amt =  l_end_age_acctd_amt
         THEN
           debug('Figures Match for '||to_char(l_start_gl_Date));
           debug('---------------------------');
         ELSE
           debug('Figures do not match for '||to_char(l_start_gl_Date));
           debug('l_begin_age_acctd_amt = '||to_char(l_begin_age_acctd_amt));
           debug('l_trx_reg_acctd_amt = '||to_char(l_trx_reg_acctd_amt));
           debug('l_unapp_reg_acctd_amt = '||to_char(l_unapp_reg_acctd_amt));
           debug('l_app_reg_acctd_amt = '||to_char(l_app_reg_acctd_amt));
           debug('l_adj_reg_acctd_amt = '||to_char(l_adj_reg_acctd_amt));
           debug('l_cm_gain_loss = '||to_char(l_cm_gain_loss));
           debug('l_inv_exp_acctd_amt = '||to_char(l_inv_exp_acctd_amt));
           debug('l_rounding_diff = '||to_char(l_rounding_diff));
           debug('l_end_age_acctd_amt = '||to_char(l_end_age_acctd_amt));
           debug('Difference = '||
               to_char(l_period_total_acctd_amt-l_end_age_acctd_amt));                                              

           debug('---------------------------');
           debug('Analysing Transactions......');
           for inv_rec in inv_cur(l_start_gl_date,l_start_gl_date) loop

               l_cust_trx_id := inv_rec.customer_trx_id;

               select accounting_affect_flag
               into l_account_affect_flag
               from ra_cust_trx_types type, ra_customer_trx trx
               where trx.customer_trx_id = l_cust_trx_id
               and   trx.cust_trx_type_id = type.cust_trx_type_id;
   
               IF l_account_affect_flag = 'Y' THEN
     
                  select sum(decode(account_class,'REC',
                                    decode(latest_rec_flag,'Y',acctd_amount,0),0)) ,
                         sum(decode(account_class,'ROUND',
                                    decode(amount,0,acctd_amount,0),0))
                    into l_rec_amount ,l_round_amount
                    from ra_cust_trx_line_gl_dist
                   where customer_trx_id = l_cust_trx_id;
          /* Don't consider the round difference for the time being. Bug 3430956 */ 
               /*   l_amount_due_original_inv  := l_rec_amount - l_round_amount; */
		  l_amount_due_original_inv  := l_rec_amount;
                  l_amount_due_rem_inv := 0;
                  l_amount_app_adj_inv := 0;

                  for ps_rec in ps_cur(l_cust_trx_id) loop
                     l_ps_id := ps_rec.payment_schedule_id;
                     l_amount_due_remaining := ps_rec.acctd_amount_due_remaining;
                     l_gl_date_closed := ps_rec.gl_date_closed;

                     l_amount_due_rem_inv := l_amount_due_rem_inv + 
                                             l_amount_due_remaining;

                     select sum(acctd_amount_applied_from+
                                nvl(acctd_earned_discount_taken,0)
                                +nvl(acctd_unearned_discount_taken,0))
                       into l_amount_applied_from
                       from ar_receivable_applications
                      where payment_schedule_id = l_ps_id
                        and nvl(confirmed_flag ,'Y') = 'Y'
                        and status ='APP';
                     
                     select sum(-(acctd_amount_applied_to+
                                  nvl(acctd_earned_discount_taken,0)
                                  +nvl(acctd_unearned_discount_taken,0))) 
                     into l_amount_applied_to
                     from ar_receivable_applications
                    where applied_payment_schedule_id = l_ps_id
                      and nvl(confirmed_flag ,'Y') = 'Y'
                      and status ='APP';

                    /* Bug 13811332 : CM Refunds are not added here */
                     select sum(acctd_amount_applied_to)
                     into l_cm_refund
                     from ar_receivable_applications
                    where payment_schedule_id = l_ps_id
                      and nvl(confirmed_flag ,'Y') = 'Y'
                      and status ='ACTIVITY'
                      and applied_payment_schedule_id = -8;

                   select sum(acctd_amount) 
                     into l_amount_adjusted 
                     from ar_adjustments
                    where payment_schedule_id = l_ps_id
                      and nvl(status,'A') = 'A'
                      and receivables_trx_id <> -15;

                   l_amount_app_adj_inv :=   nvl(l_amount_app_adj_inv,0)
                                           + nvl(l_amount_applied_from,0)
                                           + nvl(l_amount_applied_to,0)
                                           + nvl(l_amount_adjusted,0)
                                           + nvl(l_cm_refund,0);
            
                   end loop;
              if  nvl(l_amount_due_rem_inv,0) - nvl(l_amount_app_adj_inv,0)=
                            l_amount_due_original_inv then
                   null;
              else
                  debug('customer_trx_id  = '||to_char(l_cust_trx_id));
                  debug('---------------------------');                      
                  debug('Amount Due Original = '||to_char(l_amount_due_original_inv));
                  debug('Amount Applied or Adjusted ='||to_char(nvl(l_amount_app_adj_inv,0)));
                  debug('Amount Due Remaining = '||to_char(l_amount_due_rem_inv));
              end if;
             END IF;
           
           end loop;
           debug('---------------------------');
           debug('Searching for Applications with wrong rev_gl_date');
           for get_cr_rec in get_cr_ids(l_start_gl_date,l_start_gl_date) loop
              for ra_rev_gl_rec in ra_rev_gl_cur(get_cr_rec.cash_receipt_id) loop
                 IF ra_rev_gl_rec.amount_applied <> 0 THEN
                   debug('Cash_Receipt_id = '||(ra_rev_gl_rec.cr_id));
                   debug('Receivable Application Id = '||(ra_rev_gl_rec.rec_id));
                   debug('Reversal Application Id = '||(ra_rev_gl_rec.rev_rec_id));
                 END IF;
              end loop;
           end loop;
           debug('---------------------------');
         END IF;

         l_start_gl_date := l_start_gl_date +1;

    end loop; 

    utl_file.fclose(pg_fp);
end;
/

