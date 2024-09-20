SET VERIFY OFF
WHENEVER SQLERROR EXIT FAILURE ROLLBACK;
WHENEVER OSERROR EXIT FAILURE ROLLBACK;
declare
l_paramlist wf_parameter_list_t := wf_parameter_list_t();
l_item_type varchar2(10) := '&1';
l_begin_date date := '&2';
i_notification_id number := &3;
cursor c_ntfs is
SELECT notification_id, group_id, recipient_role
FROM wf_notifications
WHERE mail_status = 'MAIL'
AND status = 'OPEN'
AND begin_date >= l_begin_date
AND message_type = l_item_type
AND notification_id = i_notification_id;
l_notification_id number;
l_group_id number;
l_recipient_role varchar2(320);
l_message_type varchar2(8);
l_display_name varchar2(360);
l_email_address varchar2(320);
l_notification_pref varchar2(8);
l_language varchar2(30);
l_territory varchar2(30);
l_orig_system varchar2(30);
l_orig_system_id number;
l_installed varchar2(1);
begin
for l_ntf_rec in c_ntfs loop
-- Get recipient information using Dir Service API. Select from WF_ROLES
-- may not give the right information
Wf_Directory.GetRoleInfoMail(l_ntf_rec.recipient_role, l_display_name, l_email_address, l_notification_pref, l_language, l_territory,
l_orig_system, l_orig_system_id, l_installed);
-- Not checking the email address, since the Role may contain members. WF_XML.Generate takes
-- care of this condition.
if (l_notification_pref in ('MAILHTML','MAILTEXT','MAILATTH','MAILHTM2')) then
begin
UPDATE wf_notifications
SET mail_status = 'MAIL'
WHERE notification_id = l_ntf_rec.notification_id;
Wf_Event.AddParameterToList('NOTIFICATION_ID', l_ntf_rec.notification_id, l_paramlist);
Wf_Event.AddParameterToList('ROLE', l_ntf_rec.recipient_role, l_paramlist);
Wf_Event.AddParameterToList('GROUP_ID', l_ntf_rec.group_id, l_paramlist);
Wf_Event.AddParameterToList('Q_CORRELATION_ID', l_item_type, l_paramlist);
Wf_Event.Raise(p_event_name => 'oracle.apps.wf.notification.send',
p_event_key => to_char(l_ntf_rec.notification_id),
p_parameters => l_paramlist);
commit;
exception
when others then
null;
end;
end if;
end loop;
end;
/
commit;
exit;

