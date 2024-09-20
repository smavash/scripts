CREATE OR REPLACE TRIGGER logoff_audit_trigger
BEFORE LOGOFF ON DATABASE
BEGIN
-- ***************************************************
-- Update the last action accessed
-- ***************************************************
update
stats$user_log
set
last_action = (select action from v$session where
sys_context('USERENV','SESSIONID') = audsid)
where
sys_context('USERENV','SESSIONID') = session_id;
--***************************************************
-- Update the last program accessed
-- ***************************************************
update
stats$user_log
set
last_program = (select program from v$session where
sys_context('USERENV','SESSIONID') = audsid)
where
sys_context('USERENV','SESSIONID') = session_id;
-- ***************************************************
-- Update the last module accessed
-- ***************************************************
update
stats$user_log
set
last_module = (select module from v$session where
sys_context('USERENV','SESSIONID') = audsid)
where
sys_context('USERENV','SESSIONID') = session_id;
-- ***************************************************
-- Update the logoff day
-- ***************************************************
update
   stats$user_log
set
   logoff_day = sysdate
where
   sys_context('USERENV','SESSIONID') = session_id;
-- ***************************************************
-- Update the logoff time
-- ***************************************************
update
   stats$user_log
set
   logoff_time = to_char(sysdate, 'hh24:mi:ss')
where
   sys_context('USERENV','SESSIONID') = session_id;
-- ***************************************************
-- Compute the elapsed minutes
-- ***************************************************
update
stats$user_log
set
elapsed_minutes =
round((logoff_day - logon_day)*1440)
where
sys_context('USERENV','SESSIONID') = session_id;
END;

