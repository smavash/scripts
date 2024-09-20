select a.TABLE_NAME,a.index_name, a.column_name, a.TABLE_OWNER
  from dba_ind_columns a, dba_indexes b
 where 
a.table_name in 
'AR_PAYMENT_SCHEDULES_ALL' --'RA_CUSTOMER_TRX_LINES_ALL'
 --('XXAR_CREDIT_DAYS', 'XXAR_CASH_RECEIPT_F','XXAR_CASH_CHECK_RECEIPT_F')
-- 'XX_PO_D'
-- a.INDEX_name = 'SYS_C0049094'
    and a.index_name = b.index_name and a.table_name = b.table_name
 order by 2
 ;
 


select distinct 'exec dbms_stats.gather_index_stats(ownname => ''' ||
                a.TABLE_OWNER || ''', indname => ''' || a.index_name ||
                ''', estimate_percent => DBMS_STATS.AUTO_SAMPLE_SIZE);'
  from dba_ind_columns a, dba_indexes b
 where a.table_name in 
 (     'XXBI_DIM_GL_AR_INVOICE',
       'XXBI_FACT_GL_TRX_AGG1',
       'XXBI_FACT_GL_TRX_AGG',
       'XXBI_FACT_GL_TRX2',
       'XXBI_AR_CART_CUST_FACT',
       'W_GL_BALANCE_F',
       '',
       ''
       )
   and a.index_name = b.index_name
   and a.table_name = b.table_name
;


 
 drop index XXTNV.XXAR_PAYMENT_SCHEDULES_ALL_N19;
 
 
 
 

 
