#!/bin/bash
#===============================================================================
# Monitor 11i EBS WF Deferred Agent, and restart it when ORA-01555 trapped
#-------------------------------------------------------------------------------
#
#         Created By          Date               Reference
#     -------------------   ----------     ---------------------------
#     ©Anatoly Spectorov    02/12/2014
#
#         Updated By          Date               Reference
#     -------------------   ----------     ---------------------------
#      Anatoly Spectorov    18/12/2014    Abandon agent log file monitoring
#                                        Monitor PPLSYS.WF_DEFERRED in the DB
#      Anatoly Spectorov    15/03/2015   Exit if system is in Maintenance mode
#===============================================================================
# Standard Configuration
#     Scripts Base Directory: /opt/oracle
#     Scripts Log Directory:  /var/opt/log/oracle
#.............................................................................
#=============================================================================#

PSWD=snf_apps

. /App/prodappl/APPSPROD_ulmutap.env

sqlplus -s apps/$PSWD << END_SQL > /u01_share/DBA/scripts/MON/Restart_WF_Mailer.log
set feedback off;
set serveroutput on;
prompt Restarting WorkFlow Deferred Agents . . .
declare
   p_retcode number;
   p_errbuf varchar2(100);
  begin
       if fnd_svc_component.Get_Component_Status('Workflow Notification Mailer') = 'RUNNING' then
          fnd_svc_component.stop_component(10006, p_retcode, p_errbuf);
          if p_retcode <> 0 then
            dbms_output.put_line(p_errbuf);
            rollback;
          else
            commit;
            while fnd_svc_component.Get_Component_Status('Workflow Notification Mailer') <> 'DEACTIVATED_USER'
            loop
              null;
            end loop;
            fnd_svc_component.Start_Component(10006, p_retcode, p_errbuf);
            if p_retcode <> 0 then
              dbms_output.put_line(p_errbuf);
              rollback;
            else
              commit;
              while fnd_svc_component.Get_Component_Status('Workflow Notification Mailer') <> 'RUNNING'
               loop
                 null;
               end loop;
            end if;
          end if;
        else 
          fnd_svc_component.Start_Component(10006, p_retcode, p_errbuf);
          if p_retcode <> 0 then
            dbms_output.put_line(p_errbuf);
            rollback;
          else
            commit;
            while fnd_svc_component.Get_Component_Status('Workflow Notification Mailer') <> 'RUNNING'
            loop
               null;
            end loop;
          end if;
        end if;
end;
/
prompt WorkFlow Deferred Agents restart completed.
prompt Please check errors (if any) above.
END_SQL



