select 
p.profile_option_name SHORT_NAME,v.last_updated_by,
v.profile_option_id,
n.user_profile_option_name NAME,
v.last_update_date DATE_updated,n.last_updated_by,
p.hierarchy_type,
decode(v.level_id,
10001, 'Site',
10002, 'Application',
10003, 'Responsibility',
10004, 'User',
10005, 'Server',
'UnDef') LEVEL_SET,
decode(to_char(v.level_id),
'10001', '',
'10002', app.application_short_name,
'10003', --rspv.responsibility_key||'***'||
rspv.RESPONSIBILITY_NAME,
--'10003', rspv.RESPONSIBILITY_NAME,
'10005', svr.node_name,
'10006', org.name,
'10004', usr.user_name,
'UnDef') "CONTEXT",
v.profile_option_value VALUE
from fnd_profile_options p,
fnd_profile_option_values v,
fnd_profile_options_tl n,
fnd_user usr,
fnd_application app,
--fnd_responsibility rsp,
fnd_responsibility_vl rspv,
fnd_nodes svr,
hr_operating_units org
where 
p.profile_option_id = v.profile_option_id (+)
and p.profile_option_name = n.profile_option_name
--and p.profile_option_id = 5852;
--and p.profile_option_name like '%IL%'
--and v.profile_option_value like '%FND: View Object Max Fetch Size%'
--and  (v.profile_option_value) like '%u02_ora%'
--and v.last_update_date > TO_DATE('30-08-2010 00:00:00', 'DD-MM-YYYY HH24:MI:SS')
--and v.last_update_date > TO_DATE('04-04-2009 23:59:00', 'DD-MM-YYYY HH24:MI:SS')
--and v.profile_option_value like '%/u01_%'
--AND n.user_profile_option_name like '%ECI: Archive Directory Base Cust 791%'
AND n.user_profile_option_name  like 
'ICX: Language%'
--'Concurrent:Report Copies%'
--'FND Function Validation Level'
--'FND%'
--'Export MIME type'
--'MO: Operating Unit'
--'Conc%OPP%'
--'FND%Timeout%'
--'MSC: Calendar Reference for Bucketing'
--'ICX: Client IANA Encoding%' 
--'FND: NATIVE CLIENT ENCODING%'
and usr.user_id (+) = v.level_value
and rspv.application_id (+) = v.level_value_application_id
and rspv.responsibility_id (+) = v.level_value
and app.application_id (+) = v.level_value
and svr.node_id (+) = v.level_value
and org.organization_id (+) = v.level_value
--and n.language =  'US'
and v.level_id = 10001
--and v.profile_option_id = 3769 
--and  usr.user_name  like   'C%'
--and v.level_id != NULL 
--order by short_name,level_set
;
