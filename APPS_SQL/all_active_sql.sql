set feedback off
set serveroutput on size 9999
column username format a20
column sql_text format a55 word_wrapped
begin
  for x in
   (select username||'('||sid||','||serial#||') ospid = '|| process ||
    ' program = ' || program username,
    to_char(LOGON_TIME,' Day HH24:MI') logon_time,
    to_char(sysdate,' Day HH24:MI') current_time,
    sql_address,
    sql_hash_value
   from v$session
   where status = 'ACTIVE'
   and rawtohex(sql_address) <> '00'
   and username is not null ) loop
   for y in (select sql_text
   from v$sqlarea
   where address = x.sql_address ) loop
   if ( y.sql_text not like '%listener.get_cmd%' and
    y.sql_text not like '%RAWTOHEX(SQL_ADDRESS)%' ) then
    dbms_output.put_line( '--------------------' );
    dbms_output.put_line( x.username );
    dbms_output.put_line( x.logon_time || ' ' || x.current_time || ' SQL#=' || x.sql_hash_value);
    dbms_output.put_line( substr( y.sql_text, 1, 250 ) );
   end if;
  end loop;
 end loop;
end;
/

