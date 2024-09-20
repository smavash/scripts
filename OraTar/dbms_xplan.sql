SELECT  sql_id, MAX(io_cost)
FROM dba_hist_sql_plan
group by sql_id;

set linesize 150
set pagesize 90

SELECT * FROM dba_hist_sqltext where sql_id = '4gasbt25x1k5y';

SELECT * FROM TABLE(dbms_xplan.display_awr('4gasbt25x1k5y'));

