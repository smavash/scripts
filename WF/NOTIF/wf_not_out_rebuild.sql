sqlplus applsys/PWD
exec dbms_aqadm.stop_queue(queue_name => 'APPLSYS.WF_NOTIFICATION_OUT');
exec dbms_aqadm.drop_queue(queue_name => 'APPLSYS.WF_NOTIFICATION_OUT');
exec dbms_aqadm.drop_queue_table( queue_table=> 'APPLSYS.WF_NOTIFICATION_OUT',force=>true);

begin
dbms_aqadm.create_queue_table
(
queue_table => 'WF_NOTIFICATION_OUT',
queue_payload_type => 'SYS.AQ$_JMS_TEXT_MESSAGE',
sort_list => 'PRIORITY,ENQ_TIME',
multiple_consumers => TRUE,
comment => 'Workflow JMS Topic',
compatible => '8.1'
);
exception
when others then
raise_application_error(-20000, 'Oracle Error Mkr2= '
||to_char(sqlcode)||' - '||sqlerrm);
end;
/

begin
dbms_aqadm.create_queue
(
queue_name => 'WF_NOTIFICATION_OUT',
queue_table => 'WF_NOTIFICATION_OUT',
max_retries => 5,
retry_delay => 3600,
retention_time => 86400,
comment => 'Workflow JMS Topics'
);
exception
when others then
raise_application_error(-20000, 'Oracle Error Mkr4= '
||to_char(sqlcode)||' - '||sqlerrm);
end;
/

begin
dbms_aqadm.start_queue(queue_name => 'WF_NOTIFICATION_OUT');
exception
when others then
raise_application_error(-20000, 'Oracle Error Mkr5= '
||to_char(sqlcode)||' - '||sqlerrm);
end;
/


begin
dbms_aqadm.start_queue(queue_name => 'WF_NOTIFICATION_OUT');
exception
when others then
raise_application_error(-20000, 'Oracle Error Mkr5= '
||to_char(sqlcode)||' - '||sqlerrm);
end;
/

