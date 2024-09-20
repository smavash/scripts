SELECT 
distinct 
'alter table XXTNV.'||substr(segment_name,1,40)||' MOVE  tablespace XXTNVD1  STORAGE ( next 16k );'
FROM dba_extents de
WHERE 
--((block_id+1)*(SELECT value FROM v$parameter  WHERE UPPER(name)='DB_BLOCK_SIZE')+BYTES) > (10*1024*1024)
       tablespace_name like  'XXTNVD' 
       and segment_type != 'TABLE'
  ; 
  

  
  SELECT 
   distinct de.segment_name,  de.segment_type, de.file_id , de.bytes, de.partition_name
FROM dba_extents de
WHERE ((block_id+1)*(SELECT value FROM v$parameter
                     WHERE UPPER(name)='DB_BLOCK_SIZE')+BYTES) > (6000*1024*1024)
       AND tablespace_name like  'XXTNVD' 
       and de.segment_type = 'TABLE'
       and file_id = 19;
       ;
       
       
       
       
       select
      'alter index '||l.owner||'.'||l.index_name ||' rebuild   tablespace XXTNVD1  storage ( initial 16k next 16k  minextents 1 maxextents 2147483645 pctincrease 0 );'
from dba_indexes l
where
l.owner = 'XXTNV';


       
       select 
	'lock TABLE  XXTNV.'|| segment_name || decode( segment_type, 'TABLE', ' in exclusive mode nowait;','XXX'),
	'alter ' || segment_type || ' XXTNV.' || segment_name || decode( segment_type, 'TABLE', ' move ', ' rebuild ' )|| 'tablespace XXTNVD1  storage ( initial 16k next 16k  minextents '|| min_extents ||' maxextents '|| max_extents ||' pctincrease '|| pct_increase ||' freelists '|| freelists ||');'
from 
	user_segments,
	(select table_name, index_name from user_indexes )
where
	segment_type in ( 'INDEX' )
	and segment_name = index_name (+)
	and segment_name not in (
                           select i.index_name
                           from user_indexes i 
                           where i.index_type like '%IOT%' 
                           )
	order by 1;



select * from dba_tables where degree  not like '%1%';