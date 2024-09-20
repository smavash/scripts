select 
message_type "MSG_UNSENT", 
count(*) "Total",
status, 
mail_status
--notification_id,
--begin_date
from wf_notifications
where 
mail_status =  'SENT'
and status = 'OPEN'
AND begin_date > TO_DATE( '28-12-2005 00:00:00', 'DD-MM-YYYY HH24:MI:SS')
--and begin_date between  sysdate -1 and sysdate
-- notification_id = 1893343
--and message_type like 'OKSWARWF'
group by message_type, status, mail_status
/
