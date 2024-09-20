execute dbms_stats.gather_table_stats(ownname => 'XXTNV', tabname =>'XXAR_INTERFACE_LINES_ALL', estimate_percent =>DBMS_STATS.AUTO_SAMPLE_SIZE, method_opt => 'FOR ALL COLUMNS SIZE  AUTO', cascade => TRUE);

execute dbms_stats.gather_table_stats(ownname => 'XXTNV', tabname =>'XXAR_CASH_RECEIPT_F', estimate_percent =>DBMS_STATS.AUTO_SAMPLE_SIZE, method_opt => 'FOR ALL COLUMNS SIZE  AUTO', cascade => TRUE);
