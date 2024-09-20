SELECT inst_id, address, hash_value, sql_id, plan_hash_value, child_address,
       child_number, timestamp, operation, options, object_node, object#,
       object_owner, object_name, object_alias, object_type, optimizer, id,
       parent_id, depth, position, search_columns, cost, cardinality, bytes,
       other_tag, partition_start, partition_stop, partition_id, other,
       distribution, cpu_cost, io_cost, temp_space, access_predicates,
       filter_predicates, projection, time, qblock_name, remarks
  FROM gv$sql_plan
 WHERE sql_id = '80s8a86qxxmv7'