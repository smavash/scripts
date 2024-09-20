SELECT  
  a.ksppinm  "Parameter", 
  decode(p.isses_modifiable,'FALSE',NULL,NULL,NULL,b.ksppstvl) "Session", 
  c.ksppstvl "Instance",
  decode(p.isses_modifiable,'FALSE','F','TRUE','T') "S",
  decode(p.issys_modifiable,'FALSE','F','TRUE','T','IMMEDIATE','I','DEFERRED','D') "I",
  decode(p.isdefault,'FALSE','F','TRUE','T') "D",
  a.ksppdesc "Description"
FROM x$ksppi a, x$ksppcv b, x$ksppsv c, v$parameter p
WHERE a.indx = b.indx AND a.indx = c.indx
  AND p.name(+) = a.ksppinm
AND UPPER(a.ksppinm) LIKE UPPER('%&1%')
ORDER BY a.ksppinm;


Select name, value
  From v$parameter day1
 Where name in ('olap_page_pool_size',
                'plsql_optimize_level',
                'plsql_native_library_subdir_count',
                '_b_tree_bitmap_plans',
                '_like_with_bind_as_equality',
                '_sort_elimination_cost_ratio',
                '_fast_full_scan_enabled',
                'optimizer_secure_view_merging');

