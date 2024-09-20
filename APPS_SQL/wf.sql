select count (*) from wf_local_roles 
where user_flag ='Y' 
and notification_preference != 'MAILHTML' ;



 select *
  from fnd_user_preferences t
 where t.module_name = 'WF'
   and t.preference_name = 'MAILTYPE'
   and t.preference_value = 'MAILHTML';


select * from applsys.fnd_user_preferences_17mar11 ;

update fnd_user_preferences
set preference_value = 'MAILHTML'
where module_name = 'WF'
and preference_name = 'MAILTYPE'
and preference_value != 'MAILHTML'
;


select preference_value
from fnd_user_preferences
where user_name='-WF_DEFAULT-'
and preference_name='MAILTYPE';





select * from wf_mailer_tags
;


select t.display_name, w.the_count
  from wf_item_types_tl t,
       (select item_type i_type, count(*) the_count
          from wf_items i
         where
              i.begin_date >  TO_DATE('02-04-2011 15:30:00', 'DD-MM-YYYY HH24:MI:SS')
--              and i.begin_date < TO_DATE( '04-05-2008 00:00:00', 'DD-MM-YYYY HH24:MI:SS')
         group by item_type) w
  where t.name = w.i_type
  and t.language = 'US'
--  and t.display_name = 'Requisitions'
--and t.display_name = 'ECI: HR: CV Distribution'
 order by 2 desc;
 
 
select * from po_requisition_headers_all t
where t.segment1 = '2828' 
 
 
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
 begin_date > TO_DATE('16-03-2011 06:00:00', 'DD-MM-YYYY HH24:MI:SS')
--and begin_date < TO_DATE( '26-08-2008 16:00:00', 'DD-MM-YYYY HH24:MI:SS')
--and message_type = 'XXHRCVDI'
-- and mail_status = 'FAILED' -- null
--and  status = 'CANCELED'
-- and message_type = 'WFERROR'
--and    message_name = 'RETRY _ONLY'
--and subject like '%OEOL%'
--  to_user like 'Ang%Soon%Aun%'
--  notification_id= 2652322
-- and language !='US'  
-- and context like '%OEOL%'
--and from_user is not null
 order by begin_date;



select c.component_id, c.component_name, p.parameter_id, p.parameter_name, v.parameter_value value 
from fnd_svc_comp_param_vals_v v, fnd_svc_comp_params_b p, fnd_svc_components c 
where c.component_type = 'WF_MAILER' 
and v.component_id = c.component_id 
and v.parameter_id = p.parameter_id 
and p.parameter_name in ( 'INBOUND_SERVER','ACCOUNT', 'REPLYTO') 
order by c.component_id, c.component_name,p.parameter_name; 


select c.component_id, c.component_name, p.parameter_id, p.parameter_name, v.parameter_value value 
from   fnd_svc_comp_param_vals_v v, fnd_svc_comp_params_b p, fnd_svc_components c 
where  c.component_type = 'WF_MAILER' 
and    v.component_id = c.component_id 
and    v.parameter_id = p.parameter_id 
and  p.parameter_name = 'PROCESSOR_READ_TIMEOUT_CLOSE'  
 order by c.component_name,p.parameter_name; 

select name, '['||substr(email_address, 1, 25)||']', orig_system from wf_local_roles where email_address like '% %';





select * from wf_resources where name = 'WF_ADMIN_ROLE';

 

select * from 
wf_user_roles wur
where wur.ROLE_NAME like '%FNDWF_ADMIN_WEB%';

  
 



 

update 
wf_resources
 set text = 'FND_RESP|FND|FNDWF_ADMIN_WEB_NEW|STANDARD'
 where name = 'WF_ADMIN_ROLE'
   and type = 'WFTKN';

