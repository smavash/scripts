
  select 
total.tablespace_name , 
total.file_name                             fname, 
--'alter database datafile '''||total.file_name||''' resize '||trunc( total.bytes/1024/1024)||'m autoextend on;', 
--'alter database datafile '''||total.file_name||''' autoextend on;', 
trunc( total.bytes/1024/1024) tot_size,
 nvl(sum(free.bytes)/1024/1024,0)                 avasiz, 
(1-nvl(sum(free.bytes),0)/total.bytes)*100  pctusd 
from 
  dba_data_files  total, 
  dba_free_space  free                      
where 
      total.tablespace_name = free.tablespace_name(+) 
  and total.file_id=free.file_id(+)
--  and total.tablespace_name  in (
--  'INVD',
--'ZXX',
--'INTERIM',
--'APPS_TS_SEED',
--'APPS_TS_ARCHIVE',
--'APPS_TS_TX_IDX',
--'APPS_TS_MEDIA',
--'APPS_TS_TX_DATA',
--'APPS_TS_QUEUES',
--'APPS_TS_SUMMARY'
--'APPS_TS_NOLOGGING'
--'APPS_TS_TOOLS',
--'APPS_TS_INTERFACE'
  --)
  group by 
  total.tablespace_name, 
  total.file_name,
    total.bytes
order by 4 desc
;


select * from v$datafile;


SELECT
  substr(tablespace_name,1,38) TS_NAME,
  substr(file_name,1,60) FILE_NAME,
  bytes/1024/1024 TOTAL_MB,MAXBLOCKS,MAXBYTES,
  autoextensible,
  file_id
FROM
  dba_data_files df
;

--query to show all files with names:
select distinct a.current_file#, nvl(b.name, c.name) File_Name
  from dba_hist_active_sess_history a
  left outer join v$datafile b
    on a.current_file# = b.file#
   and a.current_file# <
       (select value from v$parameter where name = 'db_files')
  left outer join v$tempfile c
    on a.current_file# =
       c.file# + (select value from v$parameter where name = 'db_files')
   and a.current_file# >
       (select value from v$parameter where name = 'db_files')
 order by a.current_file#;


select fuzzy,
       status,
       error,
       recover,
       checkpoint_change#,
       checkpoint_time,
       count(*)
  from v$datafile_header
 group by fuzzy,
          status,
          error,
          recover,
          checkpoint_change#,
          checkpoint_time;

 select file#,
        substr(name, 1, 50),
        substr(tablespace_name, 1, 15),
        undo_opt_current_change#
   from v$datafile_header
  where fuzzy = 'YES';

select status, enabled, count(*) 
from v$datafile group by status, enabled;

