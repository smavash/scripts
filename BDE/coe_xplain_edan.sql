========================================================================
coe_xplain.sql - Enhanced Explain Plan for given SQL statement (8.1-9.0)
========================================================================
  1  SELECT dra.incident_id,
  2         dra.repair_line_id,
  3         dra.inventory_item_id,
  4         dra.attribute9,
  5         dra.attribute10,
  6         items.concatenated_segments,
  7         items.description item_desc,
  8         decode(dra.customer_product_id, '',dra.serial_number,cp.serial_number) SERIAL_NUM,
  9         decode(dra.customer_product_id, '',dra.item_revision,cp.inventory_revision) ITEM_REV,
 10         dra.repair_number,
 11         dra.rowid ROW_ID,
 12         trans.action_type,
 13         trans.prod_txn_status,
 14         job.status_type JOB_STATUS_TYPE
 15  from cs_incidents_all_b   sr,
 16       mtl_system_items_vl  items,
 17       csd_repairs          dra,
 18       csi_item_instances   cp,
 19       fnd_lookups          fndl2,
 20       csd_repair_types_vl  drtvl,
 21       mtl_units_of_measure_vl  uom,
 22       csd_product_transactions trans,
 23       CSD_REPAIR_JOB_XREF      jref,
 24       WIP_DISCRETE_JOBS        job
 25  WHERE dra.repair_type_id      = drtvl.repair_type_id
 26    and sr.incident_id          = dra.incident_id
 27    and dra.status              = fndl2.lookup_code
 28    and fndl2.lookup_type       = 'CSD_REPAIR_STATUS'
 29    and dra.unit_of_measure     = uom.uom_code
 30    and dra.repair_line_id      = trans.repair_line_id(+)
 31    and dra.CUSTOMER_PRODUCT_ID = cp.INSTANCE_ID(+)
 32    and dra.inventory_item_id(+)   = items.inventory_item_id
 33    and items.organization_id    = cs_std.get_item_valdn_orgzn_id
 34    and dra.repair_line_id         = jref.repair_line_id(+)
 35    and jref.wip_entity_id         = job.wip_entity_id(+)
 36  and  (sr.incident_id = 13386)
 37  and (('CBU_TO_IL' = 'CBU_TO_IL' and
 38        ( trans.action_type='RMA' and prod_txn_status='RECEIVED'
 39        ) and
 40        ( dra.attribute9 is null
 41          or
 42          '600047'||' /' = substr(dra.attribute9, instr(nvl(dra.attribute9,'X'), 'IR:')+4, length('600047')+2)
 43        )
 44       )
 45       or
 46       ('CBU_TO_IL' = 'IL_TO_CBU' and
 47        ( trans.action_type = 'SHIP' and job.status_type = 4
 48        ) and
 49        ( dra.attribute10 is null
 50          or
 51          '600047'||' /' = substr(dra.attribute10, instr(nvl(dra.attribute10,'X'), 'IR:')+4, length('600047')+2)
 52        )
 53       )
 54*     )
0 explain plan set statement_id = 'DUMMY' into COE_PLAN_TABLE_XYZ for
*
ERROR at line 55:
ORA-00933: SQL command not properly ended



IRS - Index Range Scan.  IUS - Index Unique Scan.  IFS=Index Full Scan.

I. TABLES
=========

I.a TABLE Partitioning Key Columns
==================================

I.b TABLE Statistics
====================

Note(*): For accurate values run first coe_fix_stats.sql

I.c TABLE Partitions
====================

I.d TABLE Partition Statistics
==============================

Note(*): For accurate values run first coe_fix_stats.sql

I.e TABLE Storage Parameters
============================

I.f TABLE Partition Storage Parameters
======================================

I.g TABLE Segments
==================

I.h TABLE Partition Segments
============================

I.i TABLE Extents
=================

I.j TABLE Partition Extents
===========================

I.k TABLE Triggers
==================

I.l TABLE/VIEW Policies
=======================

II. INDEXES
===========

II.a INDEX Partitioning Key Columns
===================================

II.b INDEX Partitions
=====================

II.c INDEX Statistics
=====================

II.d INDEX Partition Statistics
===============================

II.e INDEX Statistics (2nd part)
================================

Note(*): For accurate values run first coe_fix_stats.sql

II.f INDEX Partition Statistics (2nd part)
==========================================

Note(*): For accurate values run first coe_fix_stats.sql

II.g INDEX Storage Parameters
=============================

II.h INDEX Partition Storage Parameters
=======================================

II.i Index Segments
===================

II.j Index Partition Segments
=============================

II.k INDEX Extents
==================

II.l INDEX Partition Extents
============================

II.m INDEX Leaf Blocks Analysis
===============================

II.n INDEX Partition Leaf Blocks Analysis
=========================================

II.o INDEX Drop Candidates
==========================

III. COLUMNS
============

III.a INDEX COLUMN Statistics
=============================

III.b INDEX COLUMN Partition Statistics
=======================================

III.c TABLE COLUMN Statistics
=============================

III.d TABLE COLUMN Partition Statistics
=======================================

III.e TABLE COLUMN Statistics (2nd part)
========================================

III.f TABLE COLUMN Partition Statistics (2nd part)
==================================================

IV. TABLESPACES AND DATAFILES
=============================

Username                       Default Tablespace             Temporary Tablespace
------------------------------ ------------------------------ ------------------------------
APPS                           APPLSYSD                       TEMP

IV.a TABLESPACES
================

                                                                                     Percent
                                   Initial             Next                         increase
                                    Extent           Extent  Minimum                size for Permanent
                                      size             size  num. of   Maximum num.     Next or                  Extent     Allocation
Tablespace                         (bytes)          (bytes)  Extents     of Extents   Extent Temporary Logging?  Management Type
------------------------- ---------------- ---------------- -------- -------------- -------- --------- --------- ---------- ----------
APPLSYSD                           131,072          131,072        1  2,147,483,645          PERMANENT LOGGING   LOCAL      UNIFORM
TEMP                             1,048,576        1,048,576        1                         TEMPORARY NOLOGGING LOCAL      UNIFORM

IV.b DATAFILES
==============

V. HISTOGRAMS
=============

V.a COLUMN HISTOGRAM candidates
===============================

V.b COLUMN HISTOGRAMS
=====================

VI. INIT.ORA parameters
=======================

VI.a Apps 11i - Required and Recommended
========================================

VI.b Other non-default INIT.ORA parameters
==========================================

Parameter Name                    Parameter Value
--------------------------------- -------------------------------------------------------------------------------------------------------------------
O7_DICTIONARY_ACCESSIBILITY       TRUE
_complex_view_merging             TRUE
_fast_full_scan_enabled           FALSE
_like_with_bind_as_equality       TRUE
_new_initial_join_orders          TRUE
_optimizer_mode_force             TRUE
_optimizer_undo_changes           FALSE
_or_expand_nvl_predicate          TRUE
_ordered_nested_loop              TRUE
_push_join_predicate              TRUE
_push_join_union_view             TRUE
_shared_pool_reserved_min_alloc   4100
_sort_elimination_cost_ratio      5
_sqlexec_progression_cost         0
_system_trig_enabled              TRUE
_table_scan_cost_plus_one         TRUE
_trace_files_public               TRUE
_use_column_stats_for_function    TRUE
aq_tm_processes                   1
background_dump_dest              /u001/app/oracle/ECIT04ora1/9.2.0/admin/ECIT04_ecierp1/bdump
compatible                        9.2.0
control_files                     /u003/oradata/ECIT04data1/cntrl01.dbf, /u004/oradata/ECIT04data2/cntrl02.dbf, /u005/oradata/ECIT04data3/cntrl03.dbf
core_dump_dest                    /u001/app/oracle/ECIT04ora1/9.2.0/admin/ECIT04_ecierp1/cdump
cursor_sharing                    EXACT
db_block_buffers                  50000
db_block_checking                 FALSE
db_block_checksum                 TRUE
db_block_size                     8192
db_file_multiblock_read_count     8
db_files                          500
db_name                           ECIT04
dml_locks                         10000
enqueue_resources                 32000
ifile                             /u001/app/oracle/ECIT04ora1/9.2.0/dbs/ifilecbo.ora
java_pool_size                    100663296
job_queue_processes               2
log_buffer                        10485760
log_checkpoint_interval           1000000
log_checkpoint_timeout            72000
log_checkpoints_to_alert          TRUE
max_dump_file_size                20480
max_enabled_roles                 100
nls_comp                          binary
nls_date_format                   DD-MON-RR
nls_language                      american
nls_length_semantics              BYTE
nls_numeric_characters            .,
nls_sort                          binary
nls_territory                     america
open_cursors                      2048
optimizer_features_enable         8.1.7
optimizer_max_permutations        2000
optimizer_mode                    CHOOSE
parallel_max_servers              8
parallel_min_servers              0
pga_aggregate_target              524288000
processes                         1024
query_rewrite_enabled             true
rollback_segments                 RBS01, RBS02, RBS03, RBS04, RBS05, RBS06, RBS07, RBS08, RBS09, RBS10, RBS11, RBS12, RBS13, RBS14, RBS15, RBS16, RBS
                                  17, RBS18, RBS_BIG

row_locking                       always
session_cached_cursors            200
sessions                          2048
shared_pool_reserved_size         52428800
shared_pool_size                  536870912
sql_trace                         FALSE
timed_statistics                  TRUE
user_dump_dest                    /u001/app/oracle/ECIT04ora1/9.2.0/admin/ECIT04_ecierp1/udump
utl_file_dir                      /u002/app/applmgr/ECIT04comn/temp, /usr/tmp, /u001/app/oracle/ECIT04ora1/9.2.0/appsutil/outbound/ECIT04, /u002/app/
                                  applmgr/ECIT04comn/outbound, /u002/app/applmgr/ECIT04comn/attachments, /u002/app/applmgr/ECIT04comn/gateway

workarea_size_policy              AUTO

VII. Product Component Versions
===============================

Installed Products             Version      Status
------------------------------ ------------ ----------
NLSRTL                         9.2.0.4.0    Production
Oracle9i Enterprise Edition    9.2.0.4.0    64bit Prod
                                            uction

PL/SQL                         9.2.0.4.0    Production
TNS for IBM/AIX RISC System/60 9.2.0.4.0    Production
00:


VIII. Exporting Statistics
==========================
Exporting Stats into staging table COE_STATTAB_XYZ...


coe_statement_edan.sql and coe_xplain_edan.sql files are complete.

Recover the following files, compress them into a single file
coexplain.zip and send/upload the resulting coexplain.zip file for
further analysis:
1. coe_statement_edan.sql
2. coe_xplain_edan.sql
3. All spool files with VIEW names generated on dedicated directory.
On NT, files may get created under $ORACLE_HOME/bin.

If you wish to print output files nicely, open them in Wordpad or Word.
Use File -> Page Setup (menu option) to change Orientation to Landscape.
Using same menu option make all 4 Margins 0.2".  Exit this menu option.
Do a 'Select All' (Ctrl+A) and change Font to 'Courier New' Size 8.

Your Statistics have being exported into table COE_STATTAB_XYZ.
If instructed by Support, use the following command from your
Operating System prompt to export these Statistics into a file.
Use your O/S Oracle account while executing the command below.
Generated O/S file COE_STATTAB_XYZ.dmp is BINARY, always FTP as BINARY.

# exp apps/apps file=COE_STATTAB_XYZ tables=COE_STATTAB_XYZ

If instructed by Support, recover and send raw SQL trace file generated
under the udump directory.  Please, do not TKPROF this SQL trace file
generated by the coe_xplain.sql script.

Raw SQL Trace filename: /u001/app/oracle/ECIT04ora1/9.2.0/admin/ECIT04_ecierp1/udump/*3166412*.trc
