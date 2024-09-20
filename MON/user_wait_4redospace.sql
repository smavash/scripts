SELECT name, value 
FROM v$sysstat 
WHERE name = 'redo log space requests'; 
