#!/bin/bash 

. ~/.bash_profile

MAILLIST=anatolyr@eds.co.il,amith@eds.co.il,irinat@eds.co.il
#MAILLIST=anatolyr@eds.co.il

ISBLCKER=`sqlplus -s '/as sysdba' << EOF
set timing off echo off feed off verify off head off pages 0 term on
col tt for 99999
select NVL(Round(max(ctime)/60),0) tt from v\\$lock Where sid in (select * from dba_blockers) and block > 0;
exit ;	
EOF`

##echo "ISBLCKER = $ISBLCKER"

if [ $ISBLCKER -gt 5 ]; then

FLAG=`sqlplus -s '/as sysdba' << EOF
set echo off termout off feedback off heading off verify off linesize 100 pagesize 0 serveroutput on
Declare
  v_time number := 0;
  v_action v\\$session.action%TYPE := NULL ;
  v_alert varchar2(25) := 'NOT_LOGGER' ;
  v_work number := 0;
Begin
  for i in (select BLOCKING_SESSION, count(*) cnt
          from   v\\$session 
          Where  BLOCKING_SESSION is not null
          group by BLOCKING_SESSION
          order by cnt desc) Loop

    select ctime 
    into   v_time
    from   v\\$lock 
    Where  block > 0
    and    sid = i.blocking_session;
    
    Select action 
    into   v_action
    From   v\\$session
    Where  sid = i.blocking_session;
    
    Select to_char(sysdate,'hh24') 
    into v_work
    From dual;
    
    if v_work between 7 and 22 then
      if v_action = 'Concurrent Request' and i.cnt > 3 and v_time > 3600 then
          v_alert := 'LOGGER';
       elsif v_action = 'Concurrent Request' and v_time > 7200 then
          v_alert := 'LOGGER';
      elsif v_action != 'Concurrent Request' and i.cnt > 2 and v_time > 1800 then
          v_alert := 'LOGGER';
      elsif v_action != 'Concurrent Request' and i.cnt > 1 and v_time > 3600 then  
          v_alert := 'LOGGER';
      elsif v_action != 'Concurrent Request' and v_time > 7200 then
          v_alert := 'LOGGER';
      elsif v_time > 300 and i.cnt > 10 then
          v_alert := 'LOGGER';
      elsif v_time > 1200 then
          v_alert := 'MAIL';
      end if;  
    elsif i.cnt > 5 then
      v_alert := 'LOGGER';
    end if; 
    if v_alert = 'LOGGER' or v_alert = 'MAIL' then
      dbms_output.put_line(v_alert);
      EXIT;
    else
      dbms_output.put_line('NOTHING');
      EXIT;
    end if;
   end Loop;    

   EXCEPTION
    WHEN OTHERS THEN
    --  dbms_output.put_line('ERROR');
      NULL;
   
end ;
/
EOF`
echo FLAG=$FLAG
  if [ $FLAG == 'NOTHING' ]; then
     exit 0
  else   
    INSTANCE=`sqlplus -s '/as sysdba' << EOF
    set echo off termout off feedback off heading off verify off linesize 100 pagesize 0
    select 'instance '||upper(instance_name)||' running on '||upper(host_name)||' server !!!' as text
    from v\\$instance;
    exit;
    EOF`
    if [ $FLAG == 'MAIL' ]; then
      echo "### BLOCKED session  exist in $INSTANCE Max Blocking time is $ISBLCKER min. Please call to Oracle DBA ###" |mailx -s "BLOCKED session" $MAILLIST
    elif [ $FLAG == 'LOGGER' ]; then
      logger -t ORA_CKERP -p user.err -i "### BLOCKED session  exist in $INSTANCE Max Blocking time is $ISBLCKER min. Please call to Oracle DBA ###"
    fi
  fi
fi

