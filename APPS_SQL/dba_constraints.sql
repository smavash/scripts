prompt Show all constraints on a table
col type format a10
prompt Show all constraints on a table
col type format a10
col cons_name format a30
select  decode(constraint_type,
                'C', 'Check',
                'O', 'R/O View',
                'P', 'Primary',
                'R', 'Foreign',
                'U', 'Unique',
                'V', 'Check view') type
,       constraint_name cons_name
,       status
,       last_change
from    dba_constraints
where   owner like '&owner'
and     table_name like '&table_name'
order by 1
/

prompt List tables that are using the specified table as a foreign key
set lines 100 pages 999
select  a.owner
,       a.table_name
,       a.constraint_name
from    dba_constraints a
,       dba_constraints b
where   a.constraint_type = 'R'
and     a.r_constraint_name = b.constraint_name
and     a.r_owner  = b.owner
and     b.owner = '&table_owner'
and     b.table_name = '&table_name'
/
