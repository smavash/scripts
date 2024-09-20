
select n.user_profile_option_name NAME,
decode(v.level_id,
10001, 'Site',
10002, 'Application',
10003, 'Responsibility',
10004, 'User',
10005, 'Server',
10006, 'Organization',
10007, 'ServResp',
'UnDef') LEVEL_SET,
decode(to_char(v.level_id),
'10001', '',
'10002', app.application_short_name,
'10003', rsp.responsibility_key,
'10004', usr.user_name,
'10005', svr.node_name,
'10006', org.name,
'10007', 'depends=',
v.level_id) "CONTEXT",
v.profile_option_value VALUE,
(select n.node_name
from
fnd_nodes n
where
n.node_id=level_value2) Server,
decode(v.LEVEL_VALUE,
-1, 'Default',
rsp.responsibility_key) Resp,
decode(LEVEL_VALUE_APPLICATION_ID,
-1, 'Default',
app.application_short_name) Application
from fnd_profile_options p,
fnd_profile_option_values v,
fnd_profile_options_tl n,
fnd_user usr,
fnd_application app,
fnd_responsibility rsp,
fnd_nodes svr,
hr_operating_units org
where p.profile_option_id = v.profile_option_id (+)
and p.profile_option_name = n.profile_option_name
and p.profile_option_name in ('FND_LOOK_AND_FEEL', 'APPS_LOOK_AND_FEEL', 'FND_COLOR_SCHEME')
and usr.user_id (+) = v.level_value
and rsp.application_id (+) = v.level_value_application_id
and rsp.responsibility_id (+) = v.level_value
and app.application_id (+) = v.level_value
and svr.node_id (+) = v.level_value
and org.organization_id (+) = v.level_value
order by name, level_set;
