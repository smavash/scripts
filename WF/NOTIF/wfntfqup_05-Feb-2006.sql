REM dbdrv: none
REM $Header: wfntfqup.sql 115.4 2003/07/30 06:59:42 vshanmug ship $
REM *******************************************************************
REM NAME
REM   wfntfqup.sql - WorkFlow Message Queue Update
REM
REM DESCRIPTION
REM   Purges the wf_notification_out outbound message queue and 
REM   repopulates from the WF_NOTIFICATION table.
REM   Manual Script
REM
REM   **************************** WARNING ****************************
REM   DO NOT RUN THIS SCRIPT UNLESS DIRECTED BY ORACLE SUPPORT!!
REM   *****************************************************************
REM
REM USAGE
REM   sqlplus <usr>/<passwd>@db @wfntfqup <APPSusr> <APPSpw> <FNDusr>
REM
REM MODIFICATION LOG:
REM   12/6/2002 SMAYZE Created based on wfmqupd.sql
REM *******************************************************************

set serveroutput on
set pagesize 999
set linesize 80
set arraysize 1
set timing on;

SET VERIFY OFF
WHENEVER SQLERROR EXIT FAILURE ROLLBACK;
WHENEVER OSERROR EXIT FAILURE ROLLBACK;

CONNECT &1/&2

set serveroutput on
define appsuser = '&1'
define fnduser = '&3'

declare 
   dequeue_timeout exception;
   pragma EXCEPTION_INIT(dequeue_timeout, -25228);

   dequeue_disabled exception;
   pragma EXCEPTION_INIT(dequeue_disabled, -25226);

   dequeue_outofseq exception;
   pragma EXCEPTION_INIT(dequeue_outofseq, -25237);

   no_queue exception;
   pragma EXCEPTION_INIT(no_queue, -24010);

  queue_exists exception;
  pragma EXCEPTION_INIT(queue_exists, -24006);

  queue_table_exists exception;
  pragma EXCEPTION_INIT(queue_table_exists, -24001);

  subscriber_exist exception;
  pragma EXCEPTION_INIT(subscriber_exist, -24034);

  l_firstNotification NUMBER;
  l_lastNotification  NUMBER;

  l_wf_schema    varchar2(320);
  l_wf_account   varchar2(320);

  cursor c_ntf is
   select notification_id, group_id, recipient_role, message_type
   from wf_notifications
   where status in ('OPEN', 'CANCELED')
     and mail_status in ('MAIL', 'INVALID')
     and notification_id >= l_firstNotification
     and notification_id <= l_lastNotification
     and message_type != 'XXAUSEND'
   order by notification_id;

   r_ntf c_ntf%ROWTYPE;

   l_commit_level integer := 500;
   l_timeout      integer;
   l_agent_name   varchar2(200);
   l_table_name   varchar2(200);
   l_queue_name   varchar2(200);
   l_exception_queue_name   varchar2(200);
   i              integer;
   j              integer;

   l_deq integer;
   l_enq integer;
   l_xcount integer;
     
   l_dequeue_options dbms_aq.dequeue_options_t;
   l_message_properties dbms_aq.message_properties_t;
   l_message_handle RAW(16) := NULL;
   l_payload system.wf_message_payload_t;
   l_evt_payload wf_event_t;

   l_parameterlist wf_parameter_list_t;
   l_agent_hdl sys.aq$_agent;

   l_jms_payload sys.aq$_jms_text_message;
   rbs_too_old exception;
   pragma exception_init(rbs_too_old, -1555); 


begin
   wf_log_pkg.string(WF_LOG_PKG.LEVEL_STATEMENT, 'WFNTFQUP',
                        'BEGIN');

   l_wf_schema := upper('&&fnduser');
   l_wf_account := upper('&&appsuser');

   -- Purge the WF_DEFERRED queue
   l_agent_name := 'WF_DEFERRED';
   l_queue_name := l_wf_schema||'.'||l_agent_name;
   l_xcount := 0;
   l_timeout := 0;
   l_dequeue_options.navigation   := dbms_aq.FIRST_MESSAGE;
   l_dequeue_options.wait         := dbms_aq.NO_WAIT;
   l_dequeue_options.consumer_name := l_agent_name;
   l_dequeue_options.correlation := l_wf_account||
                                    ':oracle.apps.wf.notification.send';
   wf_log_pkg.string(WF_LOG_PKG.LEVEL_STATEMENT, 'WFNTFQUP',
                        'Purging WF_DEFERRED queue for '||l_dequeue_options.correlation);
   while (l_timeout = 0) loop
      begin
        begin
          dbms_aq.Dequeue(queue_name => l_queue_name,
                          dequeue_options => l_dequeue_options,
                          message_properties => l_message_properties,
                          payload => l_evt_payload,
                          msgid => l_message_handle);
        exception
          when rbs_too_old then
            if (l_dequeue_options.navigation = dbms_aq.FIRST_MESSAGE) then
              raise;
            else 
              l_dequeue_options.navigation := dbms_aq.FIRST_MESSAGE;
              dbms_aq.dequeue
              (
               queue_name => l_queue_name,
               dequeue_options => l_dequeue_options,
               message_properties => l_message_properties,
               payload => l_evt_payload,
               msgid => l_message_handle
               );
            end if;
        end;
        l_deq := l_deq + 1;
        l_xcount := l_xcount + 1;
        l_timeout := 0;
      exception
         when dequeue_timeout then
            l_timeout := 1;
         when others then
            raise;
      end;
      l_dequeue_options.navigation   := dbms_aq.NEXT_MESSAGE;
      if l_xcount >= l_commit_level then
         commit;
         l_xcount := 0;
      end if;
   end loop;
   commit;
   -- Same stategy as above. After the inital purge, go 
   -- through once more with FIRST_MESSAGE only
   l_xcount := 0;
   l_timeout := 0;
   l_dequeue_options.navigation   := dbms_aq.FIRST_MESSAGE;
   wf_log_pkg.string(WF_LOG_PKG.LEVEL_STATEMENT, 'WFNTFQUP',
                        'Purging wf_notification_out queue again');
   while (l_timeout = 0) loop
      begin
        begin
          dbms_aq.Dequeue(queue_name => l_queue_name,
                          dequeue_options => l_dequeue_options,
                          message_properties => l_message_properties,
                          payload => l_evt_payload,
                          msgid => l_message_handle);
        exception
          when rbs_too_old then
            if (l_dequeue_options.navigation = dbms_aq.FIRST_MESSAGE) then
              raise;
            else 
              l_dequeue_options.navigation := dbms_aq.FIRST_MESSAGE;
              dbms_aq.dequeue
              (
               queue_name => l_queue_name,
               dequeue_options => l_dequeue_options,
               message_properties => l_message_properties,
               payload => l_evt_payload,
               msgid => l_message_handle
               );
            end if;
        end;
        l_deq := l_deq + 1;
        l_xcount := l_xcount + 1;
        l_timeout := 0;
      exception
         when dequeue_timeout then
            l_timeout := 1;
         when others then
            raise;
      end;
      if l_xcount >= l_commit_level then
         commit;
         l_xcount := 0;
      end if;
   end loop;
   commit;

   -- Purge the WF_NOTIFICATION_OUT queue
   l_agent_name := 'WF_NOTIFICATION_OUT';
   l_queue_name :=  l_wf_schema||'.'||l_agent_name;
   l_exception_queue_name :=  l_wf_schema||'.'||'AQ$_'||l_agent_name||'_E';
   l_table_name :=  l_wf_schema||'.'||l_agent_name;

   -- Stop the queue
   wf_log_pkg.string(WF_LOG_PKG.LEVEL_STATEMENT, 'WFNTFQUP',
                        'Stopping the WF_NOTIFICATION_OUT queue');
   dbms_aqadm.stop_queue(queue_name => l_queue_name);

   begin -- Trap exception. Exception queue may no yet exist
      dbms_aqadm.stop_queue(queue_name => l_exception_queue_name);
   exception
      when no_queue then
         null; -- Ignore
      when others then
         raise_application_error(-20000, 'Oracle Error Mkr1= '
                                 ||to_char(sqlcode)||' - '||sqlerrm);
   end;

   -- Remove the queue
   wf_log_pkg.string(WF_LOG_PKG.LEVEL_STATEMENT, 'WFNTFQUP',
                        'Dropping the WF_NOTIFICATION_OUT queue');
   dbms_aqadm.drop_queue(queue_name => l_queue_name);

   begin -- Trap exception. Exception queue may no yet exist
      dbms_aqadm.drop_queue(queue_name => l_exception_queue_name);
   exception
      when no_queue then
         null; -- Ignore
      when others then
         raise_application_error(-20000, 'Oracle Error Mkr2= '
                                 ||to_char(sqlcode)||' - '||sqlerrm);
   end;


   -- Drop the table
   wf_log_pkg.string(WF_LOG_PKG.LEVEL_STATEMENT, 'WFNTFQUP',
                        'Dropping the WF_NOTIFICATION_OUT table');
   dbms_aqadm.drop_queue_table(l_table_name);

   -- Recreate the queue table
   wf_log_pkg.string(WF_LOG_PKG.LEVEL_STATEMENT, 'WFNTFQUP',
                        'Recreating the WF_NOTIFICATION_OUT table');
   begin
    dbms_aqadm.create_queue_table
      (
         queue_table          => l_table_name,
         queue_payload_type   => 'SYS.AQ$_JMS_TEXT_MESSAGE',
         sort_list            => 'PRIORITY,ENQ_TIME',
         multiple_consumers   => TRUE,
         comment              => 'Workflow JMS Topic',
         compatible           => '8.1'
      );
 
 
   exception
     when queue_table_exists then
       null;
     when others then
         raise_application_error(-20000, 'Oracle Error Mkr3= '
                                 ||to_char(sqlcode)||' - '||sqlerrm);
  end;

  -- Recreate the queue 
   wf_log_pkg.string(WF_LOG_PKG.LEVEL_STATEMENT, 'WFNTFQUP',
                        'Recreating the WF_NOTIFICATION_OUT queue');
 begin
    dbms_aqadm.create_queue
        (
          queue_name            => l_queue_name,
          queue_table           => l_table_name,
          max_retries           => 5,
          retry_delay           => 3600,
          retention_time        => 86400,
          comment               => 'Workflow JMS Topics'
        );

  exception
    when queue_exists then
      null;
    when others then
        raise_application_error(-20000, 'Oracle Error Mkr4= '
                                ||to_char(sqlcode)||' - '||sqlerrm);
 end;

   -- Start the topic

  begin
    dbms_aqadm.start_queue(queue_name => l_queue_name);

    exception
      when others then
          raise_application_error(-20000, 'Oracle Error Mkr5= '
                                  ||to_char(sqlcode)||' - '||sqlerrm);
  end;


   -- Add a subscriber
   begin
     l_agent_hdl := sys.aq$_agent('WF_NOTIFICATION_OUT',null,0);
     dbms_aqadm.add_subscriber(queue_name =>l_queue_name,
                               subscriber=>l_agent_hdl, rule=>'1=1');
   exception
     when subscriber_exist then
       -- ignore if we already added this subscriber.
       dbms_aqadm.alter_subscriber(queue_name => l_queue_name,
                                   subscriber=>l_agent_hdl,
                                   rule=>'1=1');
   end;


   -- Now enqueue all of the valid notifications
   -- We can not make any assumptions on the number of 
   -- transactions to process or the length of time that this will take
   -- and whether or not there are still notifications being enqueued.

   select max(notification_id) into l_lastNotification
   from wf_notifications;

   l_enq := 0;
   l_firstNotification := 	     2065512;

    dbms_output.put_line('firstNotification: '||l_firstNotification);
    dbms_output.put_line('lastNotification: '||l_lastNotification);
   wf_log_pkg.string(WF_LOG_PKG.LEVEL_STATEMENT, 'WFNTFQUP',
                        'Enqueuing messages from wf_notifications');
   loop
      l_xcount := 0;
      open c_ntf;
      loop
         fetch c_ntf into r_ntf;
         exit when c_ntf%NOTFOUND or l_xcount >= l_commit_level;



         -- wf_xml.enqueueNotification(r_ntf.notification_id);
         l_parameterList := wf_parameter_list_t();
         wf_event.AddParameterToList('NOTIFICATION_ID',r_ntf.notification_id,
                                     l_parameterlist);
         wf_event.AddParameterToList('ROLE', r_ntf.recipient_role, 
                                     l_parameterlist);
         wf_event.AddParameterToList('GROUP_ID', nvl(r_ntf.group_id,
                                     r_ntf.notification_id),
                                     l_parameterlist);
         wf_event.addParameterToList('Q_CORRELATION_ID', r_ntf.message_type,
       			             l_parameterlist);

         --Raise the event
         wf_log_pkg.string(WF_LOG_PKG.LEVEL_STATEMENT, 'WFNTFQUP',
                        'Enqueuing message '||to_char(r_ntf.notification_id));
         wf_event.Raise(p_event_name => 'oracle.apps.wf.notification.send',
                        p_event_key  => to_char(r_ntf.notification_id),
                        p_parameters => l_parameterlist);




         l_enq := l_enq + 1;
         l_xcount := l_xcount + 1;
      end loop;
      exit when c_ntf%NOTFOUND;
      l_firstNotification := r_ntf.notification_id;
      close c_ntf;
      commit;
   end loop;
    dbms_output.put_line('Enqueued: '||l_enq);

   commit;

   wf_log_pkg.string(WF_LOG_PKG.LEVEL_STATEMENT, 'WFNTFQUP',
                        'END');
end;
/

set verify on
commit;
exit;
