SELECT fu.user_name ||' - '|| fu.description "Last Run By",
       to_char(max(rts.last_update_date),'DD-Mon-YY HH24:MI') "Last Run",
       trunc(sysdate - max(rts.last_update_date)) "Age (Days)"
  FROM rg.rg_table_sizes rts,
       applsys.fnd_user fu
 WHERE rts.last_updated_by = fu.user_id
 GROUP by fu.user_name, fu.description;
