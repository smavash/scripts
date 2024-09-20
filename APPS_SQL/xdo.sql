select * from FND_CP_SERVICES
where SERVICE_ID = (select MANAGER_TYPE from FND_CONCURRENT_QUEUES
                    where CONCURRENT_QUEUE_NAME = 'FNDCPOPP');

update FND_CP_SERVICES 
      set DEVELOPER_PARAMETERS =
      'J:oracle.apps.fnd.cp.gsf.GSMServiceController:-mx3072m'
where SERVICE_ID = (select MANAGER_TYPE from FND_CONCURRENT_QUEUES
                    where CONCURRENT_QUEUE_NAME = 'FNDCPOPP');

                    


update FND_CP_SERVICES 
set DEVELOPER_PARAMETERS =      'J:oracle.apps.fnd.cp.gsf.GSMServiceController:-mx2048m'
where SERVICE_ID = (select MANAGER_TYPE from FND_CONCURRENT_QUEUES
                    where CONCURRENT_QUEUE_NAME = 'FNDCPOPP');
                    
                    

select * from  xdo_config_values
;
select * from xdo_config_properties_tl
;

SELECT   xcpt.property_name, xcp.xdo_cfg_name,
         DECODE (TO_CHAR (xcv.config_level), '10', 'Site','30', 'DataSource','50', 'Template',
                 '???') "LEVEL",
         DECODE (TO_CHAR (xcv.config_level), '10', '',
                 '30', xd.application_short_name || '|' || xd.data_source_code,
                 '50', xt.application_short_name || '|' || xt.template_code,
                 '???') "CONTEXT_SHORT",
         DECODE (TO_CHAR (xcv.config_level), '10', '',
                 '30', (SELECT fat1.application_name || '|' || xdt.data_source_name
                          FROM xdo_ds_definitions_tl xdt, fnd_application fa1, fnd_application_tl fat1
                         WHERE fa1.application_id = fat1.application_id AND fat1.LANGUAGE = 'US'
                           AND xd.application_short_name = fa1.application_short_name
                           AND xd.application_short_name = xdt.application_short_name
                           AND xd.data_source_code = xdt.data_source_code AND xdt.LANGUAGE = 'US'),
                 '50', (SELECT fat2.application_name || '|' || xtt.template_name
                          FROM xdo_templates_tl xtt, fnd_application fa2, fnd_application_tl fat2
                         WHERE fa2.application_id = fat2.application_id AND fat2.LANGUAGE = 'US'
                           AND xt.application_short_name = fa2.application_short_name
                           AND xt.application_short_name = xtt.application_short_name
                           AND xtt.template_code = xt.template_code AND xtt.LANGUAGE = 'US'),
                 '???' ) "CONTEXT_DETAIL", xcv.VALUE
    FROM xdo_config_properties_b xcp, xdo_config_properties_tl xcpt,
         xdo_config_values xcv, xdo_ds_definitions_b xd, xdo_templates_b xt
   WHERE xcp.property_code = xcpt.property_code AND xcpt.LANGUAGE = 'US'
     AND xcv.property_code = xcp.property_code
     AND xd.application_short_name(+) = xcv.application_short_name
     AND xd.data_source_code(+) = xcv.data_source_code
     AND xt.application_short_name(+) = xcv.application_short_name
     AND xt.template_code(+) = xcv.template_code
ORDER BY xcv.config_level, xcp.CATEGORY, xcp.sort_order
;


SELECT DECODE(bug_number,
              '3554613',
              '4.5.0',
              '3263588',
              'XDO.H',
              '3822219',
              '5.0.0',
              '4236958',
              '5.0.1',
              '4206181',
              '5.5.0',
              '4561451',
              '5.6.0',
              '4905678',
              '5.6.1',
              '5097966',
              '5.6.2',
              '5472959',
              '5.6.3') PATCH,
       bug_number
  FROM ad_bugs
 WHERE bug_number IN ('3554613',
                      '3263588',
                      '3822219',
                      '4236958',
                      '4206181',
                      '4561451',
                      '4905678',
                      '5097966',
                      '5472959');


