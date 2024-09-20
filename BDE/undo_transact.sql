insert into dbamon.dbamon_collect_rolling_trns
(
WHEN_CHECKED ,
START_TIME ,
sid , 
OSPROCESS ,
username , 
ACTION ,
LAST_SQL,
MODULE ,
MACHINE ,
ROLLBACK_SEG  ,
STATUS ,
PHY_IO ,
Undo_seg_number ,
undo_blocks_used ,
Consistent_gets 
)
select 
sysdate,
t.START_TIME,
s.sid, 
p.SPID,
s.username, 
s.ACTION,
a.SQL_TEXT,
s.MODULE,
s.MACHINE,
r.name "ROLLBACK SEG",
s.STATUS,
t.PHY_IO,
t.XIDUSN,
t.USED_UBLK,
t.CR_GET
from 
v$session s, 
v$process p,
v$transaction t, 
v$rollname r,
v$sql a
where s.taddr=t.addr
and s.PADDR = p.ADDR
and t.xidusn = r.usn
and s.STATUS != 'ACTIVE'
and a.hASH_VALUE = s.SQL_HASH_VALUE
and a.ADDRESS= s.SQL_ADDRESS 
/
