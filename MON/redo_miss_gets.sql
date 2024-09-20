SELECT  substr(ln.name, 1, 20), gets, misses, immediate_gets, immediate_misses 
FROM v$latch l, v$latchname ln 
WHERE   ln.name in ('redo allocation', 'redo copy') 
                and ln.latch# = l.latch#; 
