/*$Header: coe_locks.sql 7.3-9.2 156965.1 2003/11/19            csierra coe $*/
SET term off;
/*=============================================================================

coe_locks.sql - Session and serial# for locked Rows (7.3-9.0)

    *************************************************************
    This article is being delivered in Draft form and may contain
    errors.  Please use the MetaLink "Feedback" button to advise
    Oracle of any issues related to this article.
    *************************************************************


 Overview
 --------

    coe_locks.sql displays all sessions holding a lock on a table or row.
    Knowing the session/serial#, the analyst can turn specific events like
    10046 for a particular session, using coe_event_10046.sql or similar.

    To study in detail one session, use bde_session.sql (Note:169630.1)
    with parameter session_id (sid).


 Instructions
 ------------

 1. Copy this whole Note into a text file and name it coe_locks.sql

 2. Make a fake row lock in session you want to identify.  I.e. query one
    existing row and make a dummy change (same value on any given column).

 3. Without issuing a commit (save), open a SQL*Plus session and run this
    script coe_locks.sql.

    #sqlplus apps/apps@vis11i
    SQL> START coe_locks.sql;

 4. Identify from output your session by looking at the table name.

 5. Use session/serial# on any other script (i.e. coe_event_10046.sql)


 Program Notes
 -------------

 1. Always download latest version from Metalink (Note:156965.1)

 2. This script has been tested up to Oracle Apps 11.5.4 with Oracle 8.1.7 but
    it can be used on earlier Releases.

 3. For other SQL Tuning scripts, search on Metalink using keyword coescripts.

 4. A practical guide in Troubleshooting Oracle ERP Applications Performance
    Issues can be found on Metalink under Note:169935.1


 Parameters
 ----------

    None.


 Caution
 -------

    The sample program in this article is provided for educational purposes
    only and is NOT supported by Oracle Support Services.  It has been tested
    internally, however, and works as documented.  We do not guarantee that it
    will work for you, so be sure to test it in your environment before
    relying on it.


=============================================================================*/
set term on;
set lines 130;
column sid_ser format a12 heading 'session,|serial#';
column username format a12 heading 'os user/|db user';
column process format a9 heading 'os|process';
column spid format a7 heading 'trace|number';
column owner_object format a35 heading 'owner.object';
column locked_mode format a13 heading 'locked|mode';
column status format a8 heading 'status';
spool coe_locks.lst;

select
    substr(to_char(l.session_id)||','||to_char(s.serial#),1,12) sid_ser,
    substr(l.os_user_name||'/'||l.oracle_username,1,12) username,
    l.process,
    p.spid,
    substr(o.owner||'.'||o.object_name,1,35) owner_object,
    decode(l.locked_mode,
             1,'No Lock',
             2,'Row Share',
             3,'Row Exclusive',
             4,'Share',
             5,'Share Row Excl',
             6,'Exclusive',null) locked_mode,
    substr(s.status,1,8) status
from
    v$locked_object l,
    all_objects     o,
    v$session       s,
    v$process       p
where
    l.object_id = o.object_id
and l.session_id = s.sid
and s.paddr      = p.addr
and s.status != 'KILLED';

spool off;






