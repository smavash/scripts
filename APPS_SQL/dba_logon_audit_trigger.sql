-- Create table
create table STATS$USER_LOG
(
  USER_NAME       VARCHAR2(30),
  SESSION_ID      NUMBER(8),
  SID             NUMBER(8),
  HOST            VARCHAR2(64),
  TERMINAL        VARCHAR2(30),
  OS_USER         VARCHAR2(30),
  LAST_PROGRAM    VARCHAR2(48),
  LAST_ACTION     VARCHAR2(32),
  LAST_MODULE     VARCHAR2(32),
  LOGON_DAY       DATE,
  LOGON_TIME      VARCHAR2(10),
  LOGOFF_DAY      DATE,
  LOGOFF_TIME     VARCHAR2(10),
  ELAPSED_MINUTES NUMBER(8)
)
tablespace APPS_TS_TX_DATA
  pctfree 10
  initrans 10
  maxtrans 255
  storage
  (
    initial 1M
    next 1M
    minextents 1
    maxextents unlimited
    pctincrease 0
  );


CREATE OR REPLACE TRIGGER logon_audit_trigger
AFTER LOGON ON DATABASE
when (USER like 'APPS_VIEW%')
BEGIN
insert into stats$user_log values(
   user,
   sys_context('USERENV','SESSIONID'),
   sys_context('USERENV','SID'),
   sys_context('USERENV','HOST'),
   sys_context('USERENV','TERMINAL'),
   sys_context('USERENV','OS_USER'),
   null,
   null,
   null,
   sysdate,
   to_char(sysdate, 'hh24:mi:ss'),
   null,
   null,
   null
);
END;

