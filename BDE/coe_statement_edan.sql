========================================================================
Generating Enhanced Explain Plan for SQL statement on file edan.sql
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
0 explain plan set statement_id = 'COE_XPLAIN' into COE_PLAN_TABLE_XYZ for
*
ERROR at line 55:
ORA-00933: SQL command not properly ended


