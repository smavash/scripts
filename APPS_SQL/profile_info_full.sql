select * from fnd_user where user_id=1358;


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
--AND n.user_profile_option_namE like '%791%'
--AND n.user_profile_option_namE = 'Applications Portal Logout'
--AND n.user_profile_option_namE LIKE 'ECI: INV: Load Forecast CUST682%'
--AND n.user_profile_option_namE LIKE 'FND: View Object Max Fetch Size'
--AND n.user_profile_option_namE LIKE '%ICX:Session Timeout%'
--AND n.user_profile_option_namE LIKE '%Person%'
--AND n.user_profile_option_namE LIKE  'OKS: Enable Install Base integration messages' 
--AND n.user_profile_option_namE LIKE 'OKS: User name to send Install base integration messages' 
--and n.user_profile_option_namE LIKE 'MSC:Source Setup Required'
and v.last_update_date > TO_DATE('25-06-2010 17:00:00', 'DD-MM-YYYY HH24:MI:SS')
--and v.last_update_date > TO_DATE('04-04-2009 23:59:00', 'DD-MM-YYYY HH24:MI:SS')
--and v.profile_option_value like '%/u01_%'
--AND n.user_profile_option_name like '%ECI: Archive Directory Base Cust 791%'
--AND n.user_profile_option_name  like 
--'Signon%'
--'FND: Oracle Business Intelligence Suite%'
--'Concurrent: Force Local Output File Mode'
--'SLA: Additional Data Access%'
--'Disable%'
--'FSG%'
--'ICX: Language%'
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
--'ECI%Arch%'
--'Applications SSO Type'
--'Node%'
--'Sign-On%'
--'OM%'
--'Concurrent%'
--'Conc%'
--'MSC%Platform%'
--'%GSM%'
--'%Password%Case%'
--'MO:%' 
--'Init%'
--'MO: Operating Unit'
--'Initialization SQL Statement - Custom'
--'Oracle Applications Look and Feel'
--'%Discoverer%'
--'%Guest%'
--'Default Country'
--'Utilities:Diagnostics'
--'Hide Diagnostics menu entry'
--'ICX: Language'
--'ICX: Forms Launcher'
--'ECI: AU: Archive 791 Windows Directory'
--'HZ: Generate Party Number'
--AND n.user_profile_option_name  like 'Self Service Persona%' 
--'OM: Debug Log Directory'
--'HR:Business Group'
--'HR%Security%'
and usr.user_id (+) = v.level_value
and rspv.application_id (+) = v.level_value_application_id
and rspv.responsibility_id (+) = v.level_value
and app.application_id (+) = v.level_value
and svr.node_id (+) = v.level_value
and org.organization_id (+) = v.level_value
and n.language =  'US'
and v.level_id = 10001
--and v.profile_option_id = 3769 
--and  usr.user_name  like   'TL0H%'
--'%A321059%' 
--and v.level_id != NULL 
--order by short_name,level_set
;


select * from fnd_user fu
where fu.user_name = 'AMIRY'
;




select * from V$Instance;

 
 
 
 
update fnd_profile_option_values
   set profile_option_value = 'BLAF'
 where PROFILE_OPTION_ID ='5785';
update fnd_profile_option_values
   set profile_option_value = '300'
 where PROFILE_OPTION_ID ='5852';
update FND_PROFILE_OPTION_VALUES
   set PROFILE_OPTION_VALUE = replace(replace (replace( PROFILE_OPTION_VALUE,'prod',
                                 (select lower(instance_name) from V$Instance)),
                                 'PROD',(select upper(instance_name) from V$Instance)),
                                 'lxerp01',(select host_name from V$Instance)) where profile_option_value like '%/appprod/%'; 

update fnd_profile_option_values
   set PROFILE_OPTION_VALUE =''||(select instance_name from V$Instance)||' , '||to_char(sysdate,'dd-mon-yyyy')||' , '||(select host_name from V$Instance)
 where PROFILE_OPTION_ID ='125'
