begin 
fnd_ctl.fnd_sess_ctl('','','TRUE','TRUE','LOG','ALTER SESSION SET tracefile_identifier=''Slava'' EVENTS='||''''||'10046 TRACE NAME CONTEXT FOREVER,LEVEL 12'||''''); 
end;