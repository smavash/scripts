select worker_id,
       rows_processed,
       status,
       to_char(start_date, 'MM-DD-YY HH24:MI:SS') as start_date,
       to_char(end_date, 'MM-DD-YY HH24:MI:SS') as end_date,
       table_name,
       script_name
  from ad_parallel_update_units u, ad_parallel_updates p
 where u.update_id = p.update_id
--   and table_name like 'CZ%'
   and start_date > to_date('17-07-2013', 'DD-MM-YYYY');
