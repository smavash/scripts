select sid,program from v$session where program like '%CKPT%' or program like '%DBW%';

select sid,event,state,p1,p2,p3,seconds_in_wait 
from v$session_wait 
where sid in (select sid from v$session where program like '%CKPT%' or program like '%DBW%');