select
 *
--distinct recipient_role
--(to_user)
/*
notification_id,
TO_char(begin_date, 'DD-MM-YY HH24:MI:SS') start_date,
message_name,
message_type,
context,
subject,
priority,
status,
mail_status,
from_user,
to_user*/
  from wf_notifications wfn
 where
 begin_date > TO_DATE('01-09-2010 16:00:00', 'DD-MM-YYYY HH24:MI:SS')
--and begin_date < TO_DATE( '26-08-2008 16:00:00', 'DD-MM-YYYY HH24:MI:SS')
--and message_type = 'XXHRCVDI'
-- and mail_status is null --!=  'FAILED' 
--and  status = 'CANCELED'
-- and message_type = 'WFERROR'
--and    message_name = 'RETRY _ONLY'
--and subject like '%OEOL%'
--  to_user like 'Ang%Soon%Aun%'
--  and notification_id= 60402
-- and language !='US'  
-- and context like '%OEOL%'
--and from_user is not null
 order by begin_date;
