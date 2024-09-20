SELECT dra.incident_id,
       dra.repair_line_id, 
       dra.inventory_item_id,
       dra.attribute9, 
       dra.attribute10, 
       items.concatenated_segments, 
       items.description item_desc,
       decode(dra.customer_product_id, '',dra.serial_number,cp.serial_number) SERIAL_NUM,
       decode(dra.customer_product_id, '',dra.item_revision,cp.inventory_revision) ITEM_REV, 
       dra.repair_number,
       dra.rowid ROW_ID,
       trans.action_type,
       trans.prod_txn_status,
       job.status_type JOB_STATUS_TYPE
from cs_incidents_all_b   sr,
     mtl_system_items_vl  items, 
     csd_repairs          dra, 
     csi_item_instances   cp,
     fnd_lookups          fndl2,
     csd_repair_types_vl  drtvl,
     mtl_units_of_measure_vl  uom,
     csd_product_transactions trans,
     CSD_REPAIR_JOB_XREF      jref,
     WIP_DISCRETE_JOBS        job
WHERE dra.repair_type_id      = drtvl.repair_type_id
  and sr.incident_id          = dra.incident_id
  and dra.status              = fndl2.lookup_code 
  and fndl2.lookup_type       = 'CSD_REPAIR_STATUS' 
  and dra.unit_of_measure     = uom.uom_code 
  and dra.repair_line_id      = trans.repair_line_id(+)
  and dra.CUSTOMER_PRODUCT_ID = cp.INSTANCE_ID(+) 
  and dra.inventory_item_id(+)   = items.inventory_item_id
 
  and items.organization_id    = cs_std.get_item_valdn_orgzn_id
  and dra.repair_line_id         = jref.repair_line_id(+)
  and jref.wip_entity_id         = job.wip_entity_id(+)
and  (sr.incident_id = 13386) 
and (('CBU_TO_IL' = 'CBU_TO_IL' and
      ( trans.action_type='RMA' and prod_txn_status='RECEIVED' 
      ) and
      ( dra.attribute9 is null 
        or 
        '600047'||' /' = substr(dra.attribute9, instr(nvl(dra.attribute9,'X'), 'IR:')+4, length('600047')+2)
      )
     )
     or
     ('CBU_TO_IL' = 'IL_TO_CBU' and
      ( trans.action_type = 'SHIP' and job.status_type = 4 
      ) and
      ( dra.attribute10 is null 
        or 
        '600047'||' /' = substr(dra.attribute10, instr(nvl(dra.attribute10,'X'), 'IR:')+4, length('600047')+2)
      )
     )
    )

