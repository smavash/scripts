/*=============================================================================
bde_chk_imt.sql - Lists an interMedia Text index and it's dependent objects
USAGE-"@bde_chk_imt"
------------------------------------------------------------------------
REQUIREMENTS-
SELECT on dba_segments, dba_ind_columns, dba_tables,dba_lobs
------------------------------------------------------------------------
EXAMPLE-
Enter the Text index name: fnd_lobs_ctx
Enter the base table name: fnd_lobs
'-- Printing Object Information'
Object Object
Name Type Tablespace Owner
------------------------- ---------- ---------- ----------
DR$FND_LOBS_CTX$I TABLE USER_IDX APPLSYS
DR$FND_LOBS_CTX$R TABLE USER_IDX APPLSYS
DR$FND_LOBS_CTX$X INDEX USER_IDX APPLSYS
FND_LOBS TABLE USER_DATA APPLSYS
FND_LOBS_DOCUMENT TABLE USER_DATA APPLSYS
FND_LOBS_DOCUMENTPART TABLE USER_DATA APPLSYS
FND_LOBS_U1 INDEX USER_IDX APPLSYS
SYS_IOT_TOP_226550 INDEX USER_IDX APPLSYS
SYS_IOT_TOP_226555 INDEX USER_IDX APPLSYS
SYS_LOB0000028252C00004$$ LOBSEGMENT USER_DATA APPLSYS
SYS_LOB0000028256C00008$$ LOBSEGMENT USER_DATA APPLSYS
SYS_LOB0000226547C00006$$ LOBSEGMENT USER_IDX APPLSYS
SYS_LOB0000226552C00002$$ LOBSEGMENT USER_IDX APPLSYS
13 rows selected.
'-- Printing Index Information'
'-- $X index should be created with compress2 (i.e. Comp=ENAB)'
'-- alter index <I_INDEX> rebuild compress 2;'
'-- Example: alter index DR$FND_LOBS_CTX$X rebuild compress 2;'
Index Index Table
Name Type Comp Name
----------------------------------- ---------- ---- ------------------------------
DR$FND_LOBS_CTX$X NORMAL ENAB DR$FND_LOBS_CTX$I
FND_LOBS_CTX DOMAIN DISA FND_LOBS
FND_LOBS_U1 NORMAL DISA FND_LOBS
SYS_IL0000028252C00004$$ LOB DISA FND_LOBS
SYS_IL0000028256C00008$$ LOB DISA FND_LOBS_DOCUMENT
SYS_IL0000226547C00006$$ LOB DISA DR$FND_LOBS_CTX$I
SYS_IL0000226552C00002$$ LOB DISA DR$FND_LOBS_CTX$R
SYS_IOT_TOP_226550 IOT - TOP DISA DR$FND_LOBS_CTX$K
SYS_IOT_TOP_226555 IOT - TOP DISA DR$FND_LOBS_CTX$N
9 rows selected.

'--Printing LOB Information'
'--$R Table should be cached (i.e. Cached = YES)'
'--ALTER TABLE tabname MODIFY LOB (lobname) ( CACHE );'
'--tabname = R_TABLE name'
'--lobname = lob column of R_TABLE, which is the 'DATA' column'
'--(example: alter table DR$FND_LOBS_CTX$R modify lob (DATA) (CACHE);'
LOB Table Index
Name Name Name Cached
------------------------- -------------------- ------------------------- ------

SYS_LOB0000028252C00004$$ FND_LOBS SYS_IL0000028252C00004$$ NO
SYS_LOB0000028256C00008$$ FND_LOBS_DOCUMENT SYS_IL0000028256C00008$$ NO
SYS_LOB0000226547C00006$$ DR$FND_LOBS_CTX$I SYS_IL0000226547C00006$$ NO
SYS_LOB0000226552C00002$$ DR$FND_LOBS_CTX$R SYS_IL0000226552C00002$$ YES
Caution
-------
The sample program in this article is provided for educational purposes
only and is NOT supported by Oracle Support Services. It has been tested
internally, however, and works as documented. We do not guarantee that it
will work for you, so be sure to test it in your environment before
relying on it.

=============================================================================*/

set linesize 85;
set verify off;
spool bde_chk_imt.lst
accept idx_name prompt 'Enter the Text index name: '
accept tbl_name prompt 'Enter the base table name: '
prompt '-- Printing Object Information'
set pagesize 20
column segment_name format a25 heading 'Object|Name'
column tablespace_name format a10 heading 'Tablespace'
column segment_type format a10 heading 'Object|Type'
column owner format a10 heading 'Owner'
select /*+ FIRST_ROWS */ unique s.segment_name, s.segment_type,s.tablespace_name,s.owner
from dba_segments s
where
s.segment_name in (
(select /*+ FIRST_ROWS */ unique ic.index_name
from dba_ind_columns IC
where
ic.table_name like upper('%&&tbl_name%'))
union
(select /*+ FIRST_ROWS */ unique t.table_name
from dba_tables T
where
t.table_name like upper('%&&tbl_name%'))
union
(select /*+ FIRST_ROWS */ unique l.segment_name
from dba_lobs L
where
l.table_name like upper('%&&tbl_name%'))
union
(select /*+ FIRST_ROWS */ unique ic.table_name
from dba_ind_columns IC
where
ic.index_name like upper('%&&tbl_name%')));
prompt '-- Printing Index Information'
prompt '-- $X index should be created with compress2 (i.e. Comp=ENAB)'
prompt '-- alter index <I_INDEX> rebuild compress 2;'
prompt '-- Example: alter index DR$FND_LOBS_CTX$X rebuild compress 2;'
column index_name format a35 heading 'Index|Name'
column index_type format a10 heading 'Index|Type'
column compression format a4 heading 'Comp'
column table_name format a30 heading 'Table|Name'
select unique index_name,index_type,substr(compression,1,4) compression, table_name
from dba_indexes
where table_name like upper('%&&tbl_name%')
or index_name like upper('%&&idx_name%')
group by index_name,index_type, compression,table_name;
prompt'--Printing LOB Information'
prompt'--$R Table should be cached (i.e. Cached = YES)'
prompt'--ALTER TABLE tabname MODIFY LOB (lobname) ( CACHE );'
prompt'--tabname = R_TABLE name'
prompt'--lobname = lob column of R_TABLE, which is the 'DATA' column'
prompt'--(example: alter table DR$FND_LOBS_CTX$R modify lob (DATA) (CACHE);'
column index_name format a25 heading 'Index|Name'
column segment_name format a25 heading 'LOB|Name'
column table_name format a20 heading 'Table|Name'
column cache format a6 heading 'Cached'
select segment_name,table_name, index_name, cache
from dba_lobs
where table_name like upper('%&&tbl_name%')
order by segment_name,table_name, index_name, cache;
spool off;

