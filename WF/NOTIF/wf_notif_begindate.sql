select 
notification_id,
message_type,
wfn.message_name,
wfn.recipient_role,
context,
subject,
status,
mail_status,
to_user,
begin_date
from wf_notifications wfn
where 
    begin_date > TO_DATE( '03-03-2007 16:19:00', 'DD-MM-YYYY HH24:MI:SS')
order by begin_date
;
