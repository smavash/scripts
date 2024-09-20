SELECT  occupant_name "Item",  
     space_usage_kbytes/1048576 "Space Used (GB)",  
    schema_name "Schema",  
    move_procedure "Move Procedure"  
 FROM v$sysaux_occupants  
 ORDER BY 1  
;