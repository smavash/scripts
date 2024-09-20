REM $Header: APSCHECK.sql version 115.3  updated 24-Sep-2012 $
REM +=======================================================================+
REM |    Copyright (c) 2002 Oracle Corporation, Redwood Shores, CA, USA     |
REM |                         All rights reserved.                          |
REM +=======================================================================+
REM | FILENAME                                                              |
REM |     APSCHECK.sql                                                      |
REM |                                                                       |
REM | DESCRIPTION                                                           |
REM |     This script can be run to gather information about                |
REM |     an application for diagnostic purposes.                           |
REM |                                                                       |
REM | NOTE                                                                  |
REM |     Specialized script for the Advanced Planning and Scheduling       |
REM |     Suite. Maintained in Note 246150.1 by DAGODDAR                    |
REM |     Revisions made when Rollup patches are released and Note 223026.1 |
REM |     OR related notes are updated with new rollup patch information    |
REM |                                                                       |
REM | INSTRUCTIONS                                                          |
REM |     Normally run on the Database Server as applmgr user               |
REM |     Run in SQL*Plus as APPS User                                      |
REM |                                                                       |
REM | HISTORY                                                               |
REM |                                                                       |
REM |     04-MAY-2003              SKALE           CREATED                  | 
REM |     04-MAY-2007              NAKHOURI        Updated based on 5904640 |
REM |     Maintained by            DAGODDAR                                 |
REM +=======================================================================+
clear buffer;

set heading on
set verify off
set feed off
set linesize 250
set pagesize 5000
set underline '='
set serveroutput on size 1000000
set newpage 1

col app_name         format a50  heading 'Application Name' ;
col app_s_name       format a8   heading 'Short|Name' ;
col inst_status      format a10  heading 'Installed?' ;
col product_version  format a12  heading 'Prod Version' ;
col patchset         format a15  heading 'Patchset' ;
col app_id           format 9990 heading 'Appl Id' ;
col dtime            format a25  heading 'Script run at Date/Time' ;
col db               format a9   heading 'DB Name';
col created          format a9   heading 'Created';
col ver              format a64  heading 'Oracle RDBMS/Tools Version(s)';
col parameter        format a30  heading 'NLS Parameter Name';
col param_value      format a45  heading 'Currently Set Value';
col owner            format a5   heading 'Owner';
col table_owner      format a5   heading 'Table|Owner';
col table_name       format a30  heading 'Table Name';
col trigger_name     format a30  heading 'Trigger Name';
col trigger_type     format a16  heading 'Trigger Type';
col triggering_event format a26  heading 'Triggering Event';
col status           format a8   heading 'Status';
col index_name       format a30  heading 'Index Name';
col index_type       format a12  heading 'Index Type';
col pparameter       format a39  heading 'Parameter Name';
col pvalues          format a39  heading 'Parameter Value';
col M2A              format a30  heading 'M2A Dblink';
col A2M              format a30  heading 'A2M Dblink';
col plan_name        format a20  heading 'Plan Name';
col free_flag        format 999  heading 'Free Flag';
col instance_id      format 999999 heading 'Instance ID';
col patch_name format a15        heading 'Patch Number';
col patch_type format a15        heading 'Patch Type';
col application_short_name format a6 heading 'App';
col applied_patch_id format 99999999 heading 'Patch ID';
col creation_date                heading 'CR Date';
col object_name      format a35  heading 'Object';
col status           format a10  heading 'Status';
col object_type      format a20  heading 'Type';
col control_level    format a13;
col PRODUCTION_FLAG  format a10  heading 'Production';
col REQUIRED_FLAG    format a8   heading 'REQUIRED';
col LAUNCH_WORKFLOW_FLAG format a9 heading 'Launch WF';
col organization_code format A8 heading 'Org Code';
col organization_id format 99999999 heading 'Org ID';
col process_enabled_flag format a7 heading 'OPM Org';
col process_orgn_code format a12 heading 'OPM Org Code';
col master_organization_id format 99999999 heading 'Master Org ID';
col manager format a40 heading 'Manager Name'

variable        v_erp_or_plan         varchar2(1);
variable        v_share_plan          varchar2(10);
variable        v_scp_pf              varchar2(15);

ACCEPT   erp_or_plan prompt 'Is this the ERP(E), Planning(P) or Both(B) instance (Default B)? '
prompt

REM SET TERMOUT OFF
begin
    :v_erp_or_plan := upper(nvl(rtrim(ltrim('&erp_or_plan')),'B'));
end;
/

spool apscheck.txt;
prompt Revision Date: 24-SEP-2012 - DAGODDAR
prompt 
prompt 
select to_char(sysdate, 'DD-MON-YYYY HH:MI:SS') dtime from dual;
prompt
prompt
prompt 1. Database and Application Installation Details :
prompt ===================================================
prompt 
prompt
prompt Database Name and Created Date :
prompt ===================================
select name db, 
       created 
from   V$DATABASE;
prompt
prompt
prompt Application Installation Details :
prompt ===================================================
prompt
prompt Key products MSC, MSD, MSO, MSR
prompt   Customers running only Order management for ATP will see Installed for ONT Yes and MSC Shared
prompt
select 
  fav.application_name app_name
, fav.application_short_name app_s_name
, decode(fpi.status, 'I', 'Yes', 
                     'S', 'Shared', 
                     'N', 'No', fpi.status) inst_status
, fpi.product_version
, nvl(fpi.patch_level, 'Not Available') patchset
, fav.application_id app_id
from fnd_application_vl fav, fnd_product_installations fpi
where fav.application_id = fpi.application_id
order by 3;

prompt
prompt
prompt
prompt 2. Oracle Version(s) : 
prompt ======================
select banner ver 
from   V$VERSION;

prompt
prompt 3. NLS Parameter Settings :
prompt ===========================
select parameter, 
       value param_value 
from   nls_session_parameters;

prompt
prompt 4. Profile Option Values :
prompt ==========================
prompt
prompt  For Values that are number instead of Y or N, check Application Developer / Profile to see SQL validation
prompt    SQL validation will point to FND_LOOKUPS or MFG_LOOKUPS table where user application values are stored.
prompt   
prompt   Checking ATP setup - INV: Capable To Promise - 4 = ATP/CTP Based on planning data \\ 5 = ATP based on Collected Data
prompt   
declare

  l_user_id                         varchar2(255);
  l_user_name                       varchar2(255);
  l_resp_id                         varchar2(255);
  l_resp_name                       varchar2(255);
  l_appl_id                         number := -1;
  l_pov                             varchar2(60);
  l_lvl                             varchar2(10);
  
  cursor profile_options
  is
  select fpo.application_id,  
         fpo.profile_option_id poi, 
         substr(fpo.user_profile_option_name, 1, 60) upon
  from   fnd_profile_options_vl fpo
  where  fpo.application_id in (401,724, 704, 723, 722, 554)
  and    fpo.start_date_active <= sysdate
  and    (nvl(fpo.end_date_active,sysdate) >= sysdate)
  order  by fpo.application_id, fpo.user_profile_option_name;

  cursor profile_values(c_appl_id  number, c_po_id  number)
  is
  select substr(fpov.profile_option_value, 1, 52) pov, 
         decode(fpov.level_id, 10001, 'Site', 10002, 'Appl', 10003, 'Resp', 10004, 'User', 'None') lvl
  from   fnd_profile_option_values fpov
  where  fpov.application_id    in (401,724, 704, 723, 722, 554)
  and    fpov.profile_option_id = c_po_id
  and    ((fpov.level_id = 10001 and fpov.level_value = 0)
   or    (fpov.level_id = 10002 and fpov.level_value = c_appl_id)
   or    (fpov.level_id = 10003 and fpov.level_value_application_id = c_appl_id 
  and    fpov.level_value = to_number(l_resp_id)) 
   or    (fpov.level_id = 10004 and fpov.level_value = to_number(l_user_id)))
  order  by fpov.level_id desc ;

  cursor appl_name(c_appl_id  number)
  is
  select substr(application_name, 1, 60) application_name
  from   fnd_application_vl
  where  application_id = c_appl_id;

begin

/* NOT USED in SQL*PLus run
 -- Get the User Id/Name, Responsibility Id/Name.
  --
  fnd_profile.get('USER_ID', l_user_id);
  fnd_profile.get('USER_NAME', l_user_name);
  fnd_profile.get('RESP_ID', l_resp_id);
  fnd_profile.get('RESP_NAME', l_resp_name);

  dbms_output.put_line('Logged in as user '||l_user_name||'(Id : '||l_user_id||') with responsibility '||l_resp_name||'(Id : '||l_resp_id||')');
*/

  for rec1 in profile_options loop
    -- if application has changed then change the header.
    if rec1.application_id != l_appl_id then
      for rec2 in appl_name(rec1.application_id) loop
        dbms_output.put_line(chr(10)||'=====================================================================================================');
        dbms_output.put_line('Profile Option Values listing for Application : '||rec2.application_name);
        dbms_output.put_line('=====================================================================================================');
        dbms_output.put_line(chr(10)||'User Profile Option Name                                     Profile Option Value                                 Set At');
        dbms_output.put_line('============================================================ ==================================================== ======');
      end loop;
      l_appl_id := rec1.application_id;
    end if;

    open profile_values(rec1.application_id, rec1.poi);

    fetch profile_values into l_pov, l_lvl;

    if profile_values%notfound then
      l_pov := '** Not Set At Any Level **';
      l_lvl := '----';

    end if;
    
    close profile_values;

    dbms_output.put_line(rpad(rec1.upon, 60)||' '||rpad(l_pov, 52)||' '||rpad(l_lvl, 6));

  end loop;

end;
/



prompt  
prompt 5. Patchset and Family Pack level :
prompt ===================================
prompt  
prompt  List of Family Pack / Patch Set and Applications Release Levels
prompt  
prompt      | Patchset    | Family Pack Level |Applications Release
prompt      | 11i.MSC.G   | 11i.SCP_PF.H      |  11.5.8
prompt      | 11i.MSC.H   | 11i.SCP_PF.I      |  11.5.9
prompt      | 11i.MSC.I   | 11i.SCP_PF.J      |  11.5.10
prompt      | R12.MSC.A   | R12.SCP_PF.A      |  12.0.0
prompt      | R12.MSC.A.1 | R12.SCP_PF.A.1    |  12.0.1
prompt      | R12.MSC.A.2 | R12.SCP_PF.A.2    |  12.0.2
prompt      | R12.MSC.A.3 | R12.SCP_PF.A.3    |  12.0.3
prompt      | R12.MSC.A.4 | R12.SCP_PF.A.4    |  12.0.4
prompt      |             |                   |  12.0.5 Not Released for SCP_FP - 12.0.5 Customer is on 12.0.4 for APS Applications
prompt      | R12.MSC.A.6 | R12.SCP_PF.A.6    |  12.0.6
prompt      |             |                   |  12.0.7 Not Released for SCP_FP - 12.0.7 Customer is on 12.0.6 for APS Applications
prompt      | R12.MSC.B   | R12.SCP_PF.B.B    |  12.1.01 OR 12.1.02 - Controlled Availability release
prompt      | R12.MSC.B.1 | R12.SCP_PF.B.1    |  12.1.1
prompt      | R12.MSC.B.2 | R12.SCP_PF.B.2    |  12.1.2
prompt      | R12.MSC.B.3 | R12.SCP_PF.B.3    |  12.1.3
prompt      | R12.MSC.C   | R12.SCP_PF.C.C    |  12.2
prompt      | R12.MSC.C.1 | R12.SCP_PF.C.1    |  12.2.1
prompt 
prompt 
prompt Current Customer Family Pack / Patchset Levels - Compare this information to the list above


declare
  num_rows number;

      cursor familypatch is
        select fav.application_short_name app_s_name,
               decode(fpi.status, 'I', 'Installed','S', 'Shared','N', 'No', fpi.status) inst_status,
               fpi.product_version,
               nvl(fpi.patch_level, 'Not Available') patchset 
        from   fnd_application_vl fav, fnd_product_installations fpi 
        where fav.application_id = fpi.application_id and 
        fpi.APPLICATION_ID in (724, 704, 723, 722) order by 1 desc;

FUNCTION Get_Family_Pack_Level (p_app_s_name          VARCHAR2,
                                p_product_patch_level VARCHAR2
      ) RETURN VARCHAR2 IS
      v_prefix                 NUMBER;
    BEGIN
      IF (p_app_s_name = 'MSC' or p_app_s_name = 'MSO') THEN
         IF p_product_patch_level = 'Not Available' THEN
            RETURN 'Not Available';
         -- Patchset information for R12
         ELSIF p_product_patch_level LIKE 'R12.MS_.A%' THEN
            RETURN 'R12.SCP_PF.A.'||substr(p_product_patch_level, -1, 1);
         ELSIF p_product_patch_level LIKE 'R12.MS_.B%' THEN
            RETURN 'R12.SCP_PF.B.'||substr(p_product_patch_level, -1, 1);
         ELSIF p_product_patch_level LIKE 'R12.MS_.C%' THEN
            RETURN 'R12.SCP_PF.C.'||substr(p_product_patch_level, -1, 1);
         END IF;
         IF ASCII( SUBSTR(p_product_patch_level,-1,1) ) > 66 THEN
            v_prefix := ASCII( SUBSTR(p_product_patch_level,-1,1) );
            if (v_prefix = 68) THEN
              RETURN '11i.SCP_PF.'||CHR(v_prefix + 1)||'1';
            ELSE
              RETURN '11i.SCP_PF.'||CHR(v_prefix + 1);
            end if;
         ELSE
            RETURN '-';
         END IF;
      ELSIF (p_app_s_name = 'MSD') THEN
         IF p_product_patch_level = 'Not Available' THEN
            RETURN 'Not Available';
                  -- Patchset information for R12
         ELSIF p_product_patch_level LIKE 'R12.MSD.A%' THEN
            RETURN 'R12.SCP_PF.A.'||substr(p_product_patch_level, -1, 1);
         ELSIF p_product_patch_level LIKE 'R12.MSD.B%' THEN
            RETURN 'R12.SCP_PF.B.'||substr(p_product_patch_level, -1, 1);
         ELSIF p_product_patch_level LIKE 'R12.MSD.C%' THEN
            RETURN 'R12.SCP_PF.C.'||substr(p_product_patch_level, -1, 1);
         END IF;
         IF ASCII( SUBSTR(p_product_patch_level,-1,1) ) = 66 THEN
            v_prefix := ASCII( SUBSTR(p_product_patch_level,-1,1) );
            RETURN '11i.SCP_PF_'||CHR(v_prefix+2);
         END IF;
         IF ASCII( SUBSTR(p_product_patch_level,-1,1) ) > 67 THEN
            v_prefix := ASCII( SUBSTR(p_product_patch_level,-1,1) );
            if (v_prefix = 68) THEN
              RETURN '11i.SCP_PF.'||CHR(v_prefix + 1)||'1';
            ELSE
              RETURN '11i.SCP_PF.'||CHR(v_prefix + 1);
            end if;
         ELSE 
            RETURN '-';
         END IF;
      ELSIF  (p_app_s_name = 'MRP') THEN
         IF p_product_patch_level = 'Not Available' THEN
            RETURN 'Not Available';
         -- Patchset information for R12
         ELSIF p_product_patch_level LIKE 'R12.MRP.A%' THEN
            RETURN 'R12.DMF_PF.A.'||substr(p_product_patch_level, -1, 1);
         ELSIF p_product_patch_level LIKE 'R12.MRP.B%' THEN
            RETURN 'R12.DMF_PF.B.'||substr(p_product_patch_level, -1, 1);
         ELSIF p_product_patch_level LIKE 'R12.MRP.C%' THEN
            RETURN 'R12.DMF_PF.C.'||substr(p_product_patch_level, -1, 1);

         END IF;
         IF ASCII( SUBSTR(p_product_patch_level,-1,1) ) > 66 THEN
            v_prefix := ASCII( SUBSTR(p_product_patch_level,-1,1) );
            RETURN '11i.DMF_PF.'||CHR(v_prefix+1);
         ELSE
            RETURN '-';
         END IF;
      END IF;
    EXCEPTION
      WHEN OTHERS THEN
        RETURN 'Not Available';
   END Get_Family_Pack_Level;
   begin
   dbms_output.put_line(rpad('Apps Short Name ',16)||rpad('Patchset Level ',15)||rpad('Family Pack Level',17));
   dbms_output.put_line(rpad('--------------- ',16)||rpad('-------------- ',15)||rpad('-----------------',17));

   for familypatch_rec in familypatch loop
      dbms_output.put_line(rpad(familypatch_rec.app_s_name,16)||rpad(familypatch_rec.patchset,15)||rpad(Get_Family_Pack_Level(familypatch_rec.app_s_name,familypatch_rec.patchset), 17));
      -- Assigning MSC Patchset information to variable which will be used later to show patchset level information.
      if familypatch_rec.app_s_name = 'MSC' then
         :v_scp_pf := Get_Family_Pack_Level(familypatch_rec.app_s_name,familypatch_rec.patchset);
      end if;
   end loop;
END;
/

prompt 
prompt 5.1 Patches :
prompt ===============
prompt Checks only for patches for applications AU, MSC, MSD, MSO patches in ad_applied_patches 
prompt 
prompt This list does not include patches that were loaded via a Merged patch (multiple patches merged into a single patch)
prompt This limitation is overcome by the following direct queries to AD_BUGS table below in 5.2 to 5.7
prompt 
prompt IF one-off patches are applied (and not as merged patch), THEN they should be listed here in 5.1 
prompt Check file version in ARU as mentioned in Sections 8 and 17 below for double-check if there are any concerns about one-off patch level
prompt 
prompt For 11.5.10 and below
select distinct aap.patch_name, 
       SUBSTR(aap.patch_type, 1, 8) patch_type, 
       aap.applied_patch_id, 
       aap.creation_date, 
       ab.application_short_name
FROM   ad_applied_patches aap,
       ad_patch_run_bugs ab
WHERE  ab.application_short_name IN('MSO','MSC','MSD','AU')
AND    ab.orig_bug_number = aap.patch_name
AND    aap.creation_date >= add_months(sysdate, -36)-- To list patches applied in last 3 years only.
ORDER BY ab.application_short_name, aap.creation_date DESC;

prompt 
prompt For R12.x
select distinct aap.patch_name, 
       SUBSTR(aap.patch_type, 1, 8) patch_type, 
       aap.applied_patch_id, 
       aap.creation_date, 
       ab.application_short_name
FROM   ad_applied_patches aap,
       ad_patch_run_bugs ab
WHERE  ab.application_short_name IN('mso','msc','msd','au')
AND    ab.orig_bug_number = aap.patch_name
AND    aap.creation_date >= add_months(sysdate, -24)  -- To list patches applied in last 2 years only.
ORDER BY ab.application_short_name, aap.creation_date DESC;

prompt
prompt 5.2  R12.x APS Patch Check - for APS (MSC / MSO / MSR) :
prompt ====================================================================
prompt   Checks for R12.1.x Patches from Note 746824.1
prompt   Checks for R12.0.4/12.0.6 CU patch(es) from Note 412702.1 and Note 421097.1
prompt 


select bug_number,
decode(bug_number, 
/*12.1.3 patches */
'14247039','VCP 12.1.3.8 Patch 14247039 - Patch for customers on EBS 12.1.3 OR EBS 12.1.2',
'13833266','VCP 12.1.3.7 Patch 13833266 - Patch for customers on EBS 12.1.3 OR EBS 12.1.2',
'12695646','VCP 12.1.3.6 Patch 12695646 - Patch for customers on EBS 12.1.3 OR EBS 12.1.2',
'12695590','VCP 12.1.3.5 Patch 12695590 - Patch for customers on EBS 12.1.3 OR EBS 12.1.2',
'11782731','VCP 12.1.3.4 Patch 11782731 - Patch for customers on EBS 12.1.3 OR EBS 12.1.2',
'10389190','VCP 12.1.3.3 Patch 10389190 - Patch for customers on EBS 12.1.3 OR EBS 12.1.2',
'10192383','VCP 12.1.3.2 Patch 10192383 - Patch for customers on EBS 12.1.3 OR EBS 12.1.2',
'9771731','VCP 12.1.3.1 Patch 9771731 - Patch for customers on EBS 12.1.3 OR EBS 12.1.2',
'9245525','VCP 12.1.3 Patch 9245525 - R12SCP_PF.B.3 - same level as EBS 12.1.3',
/*12.1.2 patches */
'9750293','R12.1.3 Patch 9750293 - 64 bit planning exe files - Patch for 12.1.2',
'9482453','R12.1.3 Patch 9482453 - Patch for 12.1.2',
'9240920','R12.1.2.1 Patch 9240920 - Patch for 12.1.2',
/*12.1.1 patches */
'9058835','R12.1.1 CU4 Patch 9058835 - Last CU patch for 12.1.1',
	'8602258','R12.1.1 CU3 Patch 8602258 - First CU patch for 12.1.1',
/*12.1.0x patches */
	'7664905','R12.1.0 CU2 Patch 7664905 - Only for Controlled Release customer using FND 12.0.4/06 with APS 12.1.0x',
	'7551467','R12.1.0 CU1 Patch 7551467 - Only for ARROW ',
	'7644248','R12.1.0 CU1 Patch 7644248 - Controlled Release only! - 12.1.01 - supercedes Patch 7422116 and initial release 12.1.0 patch 6659487',
	'7422116','R12.1.0 CU1 Patch 7422116 - Controlled Release only! - 12.1.01 - OBSOLETE was first to supercede initial release 12.1.0 patch 659487',
	'6659487','R12.1.0 APS Feature Pack - Controlled Release Only! 12.1.0 - Patch 6659487 - SCP_PF.B initial release ',
/* 12.0 ATP Patches */
'11872403','R12.0.4 or 12.0.6 ATP CU10 patch 11872403',
'9480682','R12.0.4 or 12.0.6 ATP CU9 patch 9480682',
'9264550','R12.0.4 or 12.0.6 ATP CU8 patch 9264550',
'8979281','R12.0.4 or 12.0.6 ATP CU7 patch 8979281',
'8559015','R12.0.4 or 12.0.6 ATP CU6 patch 8559015',
	'8253739','R12.0.4 or 12.0.6 ATP CU5 patch 8253739',
	'6731855','R12.0.4 or 12.0.6 ATP CU4 patch 6731855 - first released ATP CU patch for R12.0',
/* 12.0 ASCP Engine patches */
'12971244','R12.0.4 or 12.0.6 - ASCP Engine/UI CU14 patch 12971244',
'11787444','R12.0.4 or 12.0.6 - ASCP Engine/UI CU13 patch 11787444',
'10245915','R12.0.4 or 12.0.6 - ASCP Engine/UI CU12 patch 10245915',
'9772496','R12.0.4 or 12.0.6 - ASCP Engine/UI CU11 patch 9772496',
'9244122','R12.0.4 or 12.0.6 - ASCP Engine/UI CU10 patch 9244122',
'8923997','R12.0.4 or 12.0.6 - ASCP Engine/UI CU9 patch 8923997',
'8525707','R12.0.4 or 12.0.6 - ASCP Engine/UI CU8 patch 8525707',
'8253592','R12.0.4 or 12.0.6 - ASCP Engine/UI CU7 patch 8253592',
	'7518572','R12.0.4 or 12.0.6 - ASCP Engine/UI CU6 patch 7518572',
	'7270650','R12.0.4 or 12.0.6 - ASCP Engine/UI CU5 patch 7270650',
	'7457357','R12.0.4 **NEW** CU4 ASCP Engine/UI patch 7457357',
	'7421338','R12.0.4 **OLD** CU4 ASCP Engine/UI patch 7421338',
	'6731645','R12.0.4 ASCP Engine/UI CU3 patch 6731645',
/* 12.0 Collections patches */
'10295640','R12.0.4 or 12.0.6 - Collections CU12 patch 10295640',
'9480676','R12.0.4 or 12.0.6 - Collections CU11 patch 9480676',
'9264779','R12.0.4 or 12.0.6 - Collections CU10 patch 9264779',
'8979626','R12.0.4 or 12.0.6 - Collections CU9 patch 8979626',
'8551151','R12.0.4 or 12.0.6 - Collections CU8 patch 8551151',
	'8253181','R12.0.4 or 12.0.6 - Collections CU7 patch 8253181',
	'7522050','R12.0.4 or 12.0.6 - Collections CU6 patch 7522050',
	'7361861','R12.0.4 or 12.0.6 - Collections CU5 patch 7361861',
	'7414449','R12.0.4 CU4 Collections Patch 7414449',
	'6955565','R12.0.4 CU3 Collections Patch 6955565 (mandatory pre-req for all Engine/UI CU patches)', 
/* 12.0 Collaborative Planning patches  */
	'8975714','R12.0.4 or 12.0.6 Collaborative Planning CU6 patch 8975714', 
	'6737560','R12.0.4 or 12.0.6 Collaborative Planning CU6 patch 6737560 - first patch for 12.0.x for CP') "Patch Description",
       creation_date, 
       last_update_date 
from   ad_bugs 
where  bug_number in 
(/*12.1.x*/'14247039','13833266','12695646','12695590','11782731','10389190','10192383','9771731','9245525','9750293','9482453','9240920','9058835','8602258',
/*12.1.0x*/'7664905','7551467','7644248','7422116','6659487',
/* 12.0.4 and above atp*/ '11872403','9480682','9264550','8979281', '8559015','8253739','6731855',
/*12.0.4 and above ascp*/ '12971244','11787444','10245915', '9772496','9244122','8923997', '8525707','8253592','7518572','7270650','7457357','7421338','6731645',
/*12.0.4 and above dc*/ '10295640', '9480676','9264779','8979626','8551151','8253181','7522050','7361861','7414449','6955565',
/*12.0.4 and above cp*/ '8975714', '6737560') 
order by trunc(last_update_date) desc, bug_number desc;


prompt
prompt 5.2.1  R12.1 Rapid Planning Patch Check  :
prompt ====================================================================
prompt   Checks for R12.1 Rapid Planning Patches - Refer to list in Note 252108.1
prompt   Rapid Planning requires a separate license from standard ASCP (MSC) and Constrained Based Planning (MSO)
prompt   
prompt   List of required patches that should be returned by the SQL below
prompt   NOTE: All Rapid Planning Customers MUST move to EBS 12.1.3 - Plus latest patches to go-live on this product.
prompt   For VCP 12.1.3.3 - 11768105 RP One-Off - post install patch for VCP 12.1.3.3
prompt   For VCP 12.1.3.3 - 12433669 RP One-Off - post install patch for VCP 12.1.3.3 - supersedes 11768105 - 06-May-2011
prompt   
prompt   Old Base Install information for 12.1 - 
prompt   NOTE: These are all included in EBS 12.1.3 AND All Rapid Planning Customers MUST move to EBS 12.1.3
prompt   Requires minimum level of 12.1.1 CU4 patch 9058835 or higher is applied and listed in previous section 5.2 
prompt   9092322 R12.MSC.B - UI Base patch
prompt   9064861 R12.MSC.B - Admin UI Base patch
prompt   9082764 R12.MSC.B - Engine Base patch
prompt   9092463 R12.MSC.B - IHelp base patch
prompt   9291109 R12.MSC.B - CU1 - obsoleted - must apply CU1 replacement patch 9307025
prompt   9307025 R12.MSC.B - CU1 - Repalcement patch for RP CU1 - latest patch and required patch level
prompt   
prompt   

select bug_number,
decode(bug_number,
/* 12.1.3.3 one-off */
	'12433669','Rapid Planning Post-Req Patch 12433669 for VCP 12.1.3.3',
	'11768105','11768105 RP One-Off - post install patch for VCP 12.1.3.3',
/*12.1.1 patches */
	'9092322','9092322 R12.MSC.B - UI Base patch',
	'9064861','9064861 R12.MSC.B - Admin UI Base patch',
	'9082764','9082764 R12.MSC.B - Engine Base patch',
	'9092463','9092463 R12.MSC.B - IHelp base patch',
	'9291109','9291109 R12.MSC.B - CU1 - obsoleted - must apply CU1 replacement patch 9307025',
	'9307025','9307025 R12.MSC.B - CU1 - Repalcement patch for RP CU1',
	'No Rapid Planning Patches Installed') "Patch Description",
	       creation_date, 
	       trunc(last_update_date)
from   ad_bugs 
where  bug_number in 
(
/* RP 12.1.3.3 one-off */ '12433669','11768105',
/*RP 12.1.1 patches */'9092322','9064861','9082764','9092463','9291109','9307025')
order by trunc(last_update_date) desc, bug_number desc;

prompt   
prompt
prompt 5.3 - 11.5.x Planning Engine and User Interface - for APS (MSC / MSO / MSR) :
prompt ==============================================================================
prompt   Uses SQL from Note 252108.1 to query for Rollup patches applied
prompt   Note 223026.1 - List of High Priority Patches for APS 
prompt 
select bug_number,
       creation_date,
       last_update_date
from   ad_bugs
where  bug_number in
('12541438','10352696','9855548','9550751'
,'9254001','9000516','8639586','8434383','8309716','7661491','8285664','7460088'
,'7636043','7633375','7375418','7495367','7142428','7286961','7286551','7286366'
,'6954491','6843364','6642641','6444221','6332127','6150744','6012246','5907099'
,'5844110','5734078','5649484','5582989','5495337','5416079','5358998','5262682'
,'5202616','5143461','5207826','5083534','5157684','5028419'
,'4946860','4885323','4738006','4632300','4535461','4451485'
,'4359934','4218963','4182342','4185358')
and :v_scp_pf = '11i.SCP_PF.J'
order by trunc(last_update_date) desc, bug_number desc;


select bug_number,
       creation_date,
       last_update_date
from   ad_bugs
where  bug_number in
('6328883','6109716','5935751','5839013',
'5588729','5458271','5306392','5137005','5078801','5025736'
,'4931673','4735180','4667156','4576193','4478973','4383114'
,'4314181','4220875','4119067','4073498','3983786','4060556'
,'3755270','3708936','3632599','3600881','3562491','3511063'
,'3492333','3451484','3486014','3408594','3351454','3318643'
,'3224779','3302659','3224146','3218967','3056423','3218083'
,'3195942','3167009','3157271','3124805','3103581','3099336'
,'3101536','2991052','3091338','3072354','3069559','3010092')
and :v_scp_pf = '11i.SCP_PF.I'
order by trunc(last_update_date) desc, bug_number desc;


select bug_number,
       creation_date,
       last_update_date
from   ad_bugs
where  bug_number in
('5662208',
'5581433','5372035','5112763','4921589','4606245','4500699'
,'4430718','4349290','4269677','4215518','4142234','4093058'
,'3983341','3899421','3838733','3677847','3609298','3565348'
,'3506801','3408603','3318631','3302656','3290918','3267590'
,'3224138','3218999','3166519','3143959','3153615','3125201'
,'3128156','3135119','3120131','3112673','3085650','3099322'
,'3073565','3076350','3081350','3081093','3053127','3042778'
,'3010551','3056953','3042668','3020565','3032666','2960918'
,'2974649','3028711','2995707','3022301','3018411','3015692'
,'2856831','2981411','2973454','2980511','2867717','2901648'
,'2947964','2965235','2944336','2941815','2951737','2945450'
,'2942580','2887324','2880203','2925191','2912882','2872061'
,'2890404','2893763','2900322','2893349','2872706','2868930'
,'2878391','2875277','2823253','2840183','2834835','2822985'
,'2811682','2811053','2809000','2811757','2805403','2800428'
,'2758101','2774694','2800435','2797357','2766461','2723045'
,'2715233','2743361','2728432','2743816','2729737','2668771'
,'2721695','2647449','2675455','2671242','2628949','2634206'
,'2666524','2458940','2625758','2630630','2619973','2527477'
,'2594048','2572441','2543824','2558831','2513744','2546079'
,'2542602','2542749','2518382')
and :v_scp_pf = '11i.SCP_PF.H'
order by trunc(last_update_date) desc, bug_number desc;


select bug_number,
       creation_date,
       last_update_date
from   ad_bugs
where  bug_number in
('5067712','4859546','4650974','4545701','4448891','4328138'
,'3921867','4141287','3680668','3622048','3507065','3475504'
,'3454501','3392928','3318626','3235106','3219006','3177382'
,'3194824','3177382','3131824','3100758','3089411','3051906'
,'3065906','3059327','3028776','2892208','3026502','3013977'
,'3019519','3016587','2889597','2955652','3005973','2985049'
,'2902277','2937523','2894484','2916806','2908617','2832929'
,'2786257','2853913','2880664','2868054','2850627','2850501'
,'2824615','2834720','2631761','2824014','2762132','2770656'
,'2758242','2737575','2747950','2740422','2737721','2725091'
,'2713314','2723640','2693816','2676335','2701713','2697369'
,'2671571','2672234','2670073','2642231','2659533','2652978'
,'2640468','2637650','2636257','2596656','2623178','2623470'
,'2539126','2573587','2599969','2606776','2599483','2541993'
,'2559365','2438587','2560100','2551818','2540951','2533004'
,'2533400','2517340','2526969','2520742','2515360','2507437'
,'2500350','2473040','2466063','2449931','2426346','2387325'
,'2443104','2426399','2435721','2318415','2407338','2367115'
,'2386916','2380559','2373273','2327041','2367098','2290560'
,'2358951','2350392','2337508','2273092','2298777','2295433'
,'2288511','2252077','2284314','2266814','2206181','2242435')
and :v_scp_pf = '11i.SCP_PF.G'
order by trunc(last_update_date) desc, bug_number desc;


prompt
prompt 5.4 - 11.5.x Global Order Promising - GOP / ATP for OM (MSC) :
prompt ===============================================================
prompt   Uses SQL from Note 252108.1 to query for Rollup patches applied
prompt   Note 223026.1 - List of High Priority Patches for APS 
prompt 

select bug_number,
       creation_date,
       last_update_date
from   ad_bugs
where  bug_number in
('10422027','9860682','9341725','8686151',
'7456716','6988176','6675340','6521021','6374582','6242111','6118590','5956038',
'5891754','5731112','5679905','5578948','5385948','5290001','5137290','5056480'
,'5008939','4906422','4759950','4639052','4570432','4461873'
,'4392144','4278114','4240365','4085497')
and :v_scp_pf = '11i.SCP_PF.J'
order by trunc(last_update_date) desc, bug_number desc;


select bug_number,
       creation_date,
       last_update_date
from   ad_bugs
where  bug_number in
('5297497','5156907','5088559','5023069','4938126','4726232','4654293'
,'4548458','4424340','4362314','4245005','4177116','4044136'
,'3851687')
and :v_scp_pf = '11i.SCP_PF.I'
order by trunc(last_update_date) desc, bug_number desc;


prompt
prompt 5.5 - 11.5.x Collections Cumulative Patch List :
prompt ================================================
prompt   Uses SQL from Note 252108.1 to query for Rollup patches applied
prompt   Note 223026.1 - List of High Priority Patches for APS 
prompt 

select bug_number,
       creation_date,
       last_update_date
from   ad_bugs
where  bug_number in
('12731023','10077340','9586992','9054537','8671960','8430849','8298229','7661713'
,'7521941','7392616','7389654','6751704','6625126','6447137'
,'6350793','6199843','6058288','5931065','5743081','5659754'
,'5527919','5462165','5378494','5199309','5292592','5141262'
,'5070152','5009076','4916099','4754034','4713672','4754544'
,'4606782','4485377','4366346','4281509','4174551','4074569')
and :v_scp_pf = '11i.SCP_PF.J'
order by trunc(last_update_date) desc, bug_number desc;


select bug_number,
       creation_date,
       last_update_date
from   ad_bugs
where  bug_number in
('6064959','5660233'
,'5477900','5305818','5083476','4937536','4776712','4747018'
,'4604244','4421637','4260170','4215553','4119039','4070704'
,'4017804','3957519','3885820','3781107','3699354','3637510'
,'3553500','3522492','3451488','3409391','3363549','3371317'
,'3311794','3249735','3216136','3169858','3184839','2821681'
,'3068982','3013660','2857382')
and :v_scp_pf in ('11i.SCP_PF.I','11i.SCP_PF.H','11i.SCP_PF.G')
order by trunc(last_update_date) desc, bug_number desc;


select bug_number,
       creation_date,
       last_update_date
from   ad_bugs
where  bug_number in
('4018554','3880044','3755431','3693087','3603785','3433402'
,'3363559','3154505','3157138','3230022','3188371','3207062'
,'3108891','3145437','3076045','3138929','3130786','3113941'
,'3036943','3005631','3038843','3016411','2998956','3009028'
,'2941228','2953355','2969734','2939427','2940204','2938672'
,'2823309','2853044','2853235','2870470','2837651','2840900'
,'2791310','2800110','2727286','2740202','2701888','2721364'
,'2723520','2701552','2700239','2651750','2490553','2584598'
,'2643184','2631949','2615455','2587412','2559388','2560361'
,'2555001','2521038','2488597')
and :v_scp_pf = '11i.SCP_PF.H'
order by trunc(last_update_date) desc, bug_number desc;



prompt
prompt 5.6 - 11.5.x Collaborative Planning Cumulative Patch List :
prompt ==========================================================
prompt   Uses SQL from Note 252108.1 to query for Rollup patches applied
prompt   Note 223026.1 - List of High Priority Patches for APS 
prompt 

select bug_number,
       creation_date,
       last_update_date
from   ad_bugs
where  bug_number in
('9079623','7531850','6773395','6500840','6129468','5741841',
'5346309','5174962','5083539','4946788','4680160','4579267'
,'4485208','4392231','4231972','4210584','4091536')
and :v_scp_pf = '11i.SCP_PF.J'
order by trunc(last_update_date) desc, bug_number desc;


select bug_number,
       creation_date,
       last_update_date
from   ad_bugs
where  bug_number in
('4726329','4386997','4729091','4386997','4729091','4065696'
,'3930890','3757193','3561908','3623878','3618233','3364594'
,'3313437','3295177','3279231','3258910','3230958','3139543'
,'3118436','3128555','3107345','3066271')
and :v_scp_pf = '11i.SCP_PF.I'
order by trunc(last_update_date) desc, bug_number desc;


select bug_number,
       creation_date,
       last_update_date
from   ad_bugs
where  bug_number in
('4103529','3741726','3298753','3171397','3093547','3042262'
,'2965416','2963308','2947017','2838377','2796127','2741374'
,'2725901','2713030')
and :v_scp_pf = '11i.SCP_PF.H'
order by trunc(last_update_date) desc, bug_number desc;


prompt
prompt 5.7 - 11.5.10 only - Checking ODP Rollup patch level:
prompt ==========================================================
prompt  NOTE: This output prints for ANY release, only need to review if 11.5.10 is the customer release.
prompt   Uses SQL from Note 412308.1 to check for Rollup patches applied
prompt   Note 223026.1 - List of High Priority Patches for APS 
prompt 

select a.bug PatchNo,
decode (a.bug,
'3930903','DPE CONSOLIDATED 11.5.10 PATCH',
'4104832', 'CUMULATIVE 1 PATCH',
'4398235','CUMULATIVE 2 PATCH ',
'5120460','DPE Rollup#1 PATCH',
'5367230','DP Rollup#2 PATCH Obsolete',
'5578973','DP Rollup#2 PATCH',
'5395666','DP Rollup#3 PATCH',
'5578993','DP Rollup#4 PATCH',
'5659805','DP Rollup#5 PATCH',
'5934903','DP Rollup#6 PATCH',
'5869450','DP Rollup#7 PATCH',
'6036268','DP Rollup#8 PATCH Obsolete',
'6321532','DP Rollup#8 PATCH',
'6200268','DP Rollup#9 PATCH',
'6416414','Patch on Top Rollup#9',
'6353791','DP Rollup#10 PATCH',
'6625130','DP Rollup#11 PATCH',
'6751750','DP Rollup#12 PATCH',
'7115768','DP Rollup#13 PATCH',
'7433887','DP Rollup#14 PATCH',
'8278480','DP Rollup#15 PATCH')
 Description,
nvl(to_char(b.creation_date),'Not Installed') Installed
from applsys.ad_bugs b,
(select 3930903 bug from dual union
select 4104832 bug from dual union
select 4398235 bug from dual union
select 5120460 bug from dual union
select 5367230 bug from dual union
select 5578973 bug from dual union
select 5395666 bug from dual union
select 5578993 bug from dual union
select 5659805 bug from dual union
select 5934903 bug from dual union
select 5869450 bug from dual union
select 6036268 bug from dual union
select 6321532 bug from dual union
select 6200268 bug from dual union
select 6416414 bug from dual union
select 6353791 bug from dual union
select 6625130 bug from dual union
select 6751750 bug from dual union
select 7115768 bug from dual union 
select 7433887 bug from dual union
select 8278480 bug from dual
) a
where to_char(substr(a.bug,1,7)) = to_char(b.bug_number(+))
and :v_scp_pf = '11i.SCP_PF.J'
order by a.bug desc;



prompt
prompt 6. Database Triggers :
prompt ======================
prompt Check for DISABLED status
prompt

select atrg.table_owner, 
       atrg.table_name, 
       atrg.trigger_name, 
       atrg.trigger_type, 
       atrg.triggering_event, 
       atrg.status
from   all_triggers    atrg, 
       fnd_application fa
where  fa.application_id in (724, 704, 723, 722)
and    atrg.table_owner  = fa.application_short_name
order  by atrg.status, atrg.table_owner, atrg.table_name, atrg.trigger_type;


prompt
prompt 7. Table Indexes :
prompt ==================
prompt Check for STATUS = INVALID / Ignore STATUS = N/A
prompt  for Performance issues, check last_analyzed date, num_rows, sample size( sample_size should be 10% or higher or num_rows) 
prompt

select aind.table_owner, 
       aind.table_name, 
       aind.index_name, 
       aind.index_type, 
       aind.status,
       aind.num_rows,
       aind.sample_size, 	
       aind.last_analyzed
from  all_indexes     aind, 
      fnd_application fa
where fa.application_id in (724, 704, 723, 722)
and   aind.table_owner = fa.application_short_name 
order by aind.status, aind.table_owner, aind.table_name, aind.index_name;

prompt
prompt 8. Package Versions :
prompt =====================
prompt  Check for status = INVALID in this output, INVALID will also be listed in last section of the apscheck
prompt
prompt   Key versions: Use the files below to crosscheck or confirm patch levels reported in Sections 5.2 - 5.5 
prompt     via internal ARU system if there is any question about the rollup patch versions reported above.
prompt   Data Collections, use MSCCLBAB.pls / also use MSCVIEWS.sql in section 10
prompt   ATP/GOP, use check MSCGATPB.pls
prompt   APS with OPM data collections:
prompt     Check GMPPLDSB.pls and GMPBMRTB.pls to check for OPM latest version for OPM Collections patches.
prompt     Check GMPRELAB.pls to check for OPM latest UI Source side patch (ERP Source apscheck output required)
prompt     


declare
  type PkgCurType IS REF CURSOR;
  l_pkg_cursor    PkgCurType;
  l_query         varchar2(10000);
  l_where         varchar2(32767);
  l_name          varchar2(30);
  l_type          varchar2(4);
  l_file_name     varchar2(20);
  l_version       varchar2(40);
  l_status        varchar2(7);

  cursor pkg_prefix
  is
  select distinct substr(o.name, 1, decode(instr(o.name, '_'),0,5,instr(o.name, '_')))||'%' prefix
  from   sys.obj$ o, sys.tab$ t, sys.user$ u 
  where  u.name in
        (select fa.application_short_name
         from   fnd_application fa
         where  fa.application_id in (724, 704, 723, 722, 554))
  and    o.owner# = u.user#
  and    t.obj#   = o.obj#;

begin

  l_query := 'select 
                o.name
              , ltrim(rtrim(substr(substrb(s.source, instr(s.source,''Header: '')), instr(substr(s.source, instr(s.source,''Header: '')), '' '', 1, 1), instr(substr(s.source, instr(s.source,''Header: '')), '' '', 1, 2) - instr(substr(s.source, instr(s.source,''Header: '')), '' '', 1, 1) ))) file_name
              , ltrim(rtrim(substr(substrb(s.source, instr(s.source,''Header: '')), instr(substr(s.source, instr(s.source,''Header: '')), '' '', 1, 2), instr(substr(s.source, instr(s.source,''Header: '')), '' '', 1, 3) - instr(substr(s.source, instr(s.source,''Header: '')), '' '', 1, 2) ))) file_version
              , decode(o.type#, 9, ''SPEC'', 11, ''BODY'', o.type#) type
              , decode(o.status, 0, ''N/A'', 1, ''VALID'', ''INVALID'') status
              from  sys.source$ s, sys.obj$ o, sys.user$ u
              where u.name   = ''APPS''
              and   o.owner# = u.user#
              and   s.obj#   = o.obj#
              and   s.line between 2 and 5
              and   s.source like ''%Header: %''';

  for pkg_prefix_rec in pkg_prefix loop
    if l_where is null then
      l_where := 'and ( o.name like '''||pkg_prefix_rec.prefix||'''';
    else
      l_where := l_where||' or  o.name like '''||pkg_prefix_rec.prefix||'''';
    end if;
  end loop;

  if l_where is not null then
    l_where := l_where||')';
    l_query := l_query||l_where;
  end if;

  l_query := l_query||' order by 1, 4';

  dbms_output.put_line('Name                           File Name            Version                                  Type Status ');
  dbms_output.put_line('============================== ==================== ======================================== ==== =======');
  open l_pkg_cursor for l_query;
  loop
    fetch l_pkg_cursor into l_name, l_file_name, l_version, l_type, l_status;
    exit when l_pkg_cursor%notfound;
    dbms_output.put_line(rpad(l_name, 30)||' '||rpad(l_file_name, 20)||' '||rpad(l_version, 40)||' '||rpad(l_type, 4)||' '||rpad(l_status, 7));
  end loop;
end;
/

prompt
prompt 9. Database INIT.ORA values from v$parameter :
prompt ===================================================
prompt

SELECT
  ltrim(rtrim(value)) "9.1 ATP session file Directory"
FROM
  (select value from v$parameter2
   where name='utl_file_dir' order by rownum desc)    
WHERE rownum <2;
prompt See Note 122372.1 for details on ATP Debug steps

prompt
prompt 9.2 Complete listing of RDBMS settings from v$parameter:
prompt =========================================================
prompt
prompt RDBMS Settings for Oracle Apps can be checked for each RDBMS release:
prompt   For 11i see Note 216205.1 Database Initialization Parameters for Oracle Applications 11i
prompt   For R12 see Note 396009.1 Database Initialization Parameters for Oracle Applications Release 12
prompt
prompt Checking for RAC install - The parameters using ‘cluster’ will show if the customer is using RAC (e.g. cluster_database = TRUE is RAC install)
prompt    and cluster_database_instances =2 would mean that there are 2 nodes on the RDBMS
prompt RAC install can cause ATP failures (ATP Processing Error) and require setup by DBA (Ref Note 266125.1) and see Section 24.3 for setup info
prompt RAC install can cause failures in Planning and Data Collections (Ref Note 279156.1)
prompt

select  name  pparameter, 
        value pvalues 
from    v$parameter
order by name;

spool off

set head off


prompt Getting O/S version, Please wait ...
host echo '' >> apscheck.txt
host echo '' >> apscheck.txt
host echo ' 9.3 O/S Info - Operating System Name and Version information using uname :' >> apscheck.txt
host echo '===========================================================================' >> apscheck.txt
host echo ' Full listing using uname -a is returned here ' >> apscheck.txt
host echo '    More info on parameters by running uname -h on the same O/S  ' >> apscheck.txt
host echo '' >> apscheck.txt

spool comm.lst
  select 'uname -a'
  from   dual;
spool off

host chmod 777 comm.lst
host comm.lst >> apscheck.txt

prompt ulimit values, Please wait ...
host echo '' >> apscheck.txt
host echo '' >> apscheck.txt
host echo ' 9.4 O/S Setup Info - ulimit -aS and -aH values :' >> apscheck.txt
host echo '===========================================================================' >> apscheck.txt
host echo ' -aS values are Soft limits' >> apscheck.txt
host echo ' -aH values are Hard limits' >> apscheck.txt
host echo ' Best Practice is for these values to match - see Note 1085614.1 OS Evironment and Compile Settings for Value Chain Planning ' >> apscheck.txt
host echo '' >> apscheck.txt

spool comm.lst
  Prompt 
  select 'echo  =============== ulimit -aS - Soft limits ===============' 
  from   dual;
  select 'ulimit -aS' 
  from   dual;
  select 'echo  - ' 
    from   dual;
  select 'echo  - ' 
    from   dual;
  select 'echo  =============== ulimit -aH - Hard limits ===============' 
  from   dual;
  select 'ulimit -aH' 
  from   dual;
spool off

host chmod 777 comm.lst
host comm.lst >> apscheck.txt

prompt Memory on the system, Please wait ...
host echo '' >> apscheck.txt
host echo '' >> apscheck.txt
host echo ' 9.5 Checking Memory on the system using free command:' >> apscheck.txt
host echo '===========================================================================' >> apscheck.txt
host echo ' This may not work on all systems.' >> apscheck.txt
host echo '' >> apscheck.txt

spool comm.lst
  Prompt 
  select 'echo  =============== free -g - GB setting to report in Gigabytes ===============' 
  from   dual;
  select 'free -g' 
  from   dual;
spool off

host chmod 777 comm.lst
host comm.lst >> apscheck.txt


prompt Getting $APPLCSF and $APPLCSF/$APPLOUT values, Please wait ...
host echo '' >> apscheck.txt
host echo '' >> apscheck.txt
host echo ' 9.6 Apps Setup Info - $APPLCSF and $APPLCSF/$APPLOUT values :' >> apscheck.txt
host echo '===========================================================================' >> apscheck.txt
host echo 'APPLCSF is useful for Production Scheduling (PS) issues' >> apscheck.txt
host echo 'APPLCSF/APPLOUT - DAT files under this in /data[plan_id] directory Per note 245974.1 - #4 ' >> apscheck.txt
host echo '' >> apscheck.txt
host echo '' >> apscheck.txt

spool comm.lst
  select 'echo  =============== APPLCSF Directory ===============' 
  from   dual;
  select 'echo $APPLCSF' 
  from   dual;
  select 'echo  =============== APPLOUT Directory for DAT Files ===============' 
  from   dual;
  select 'echo $APPLCSF/$APPLOUT' 
  from   dual;
spool off

host chmod 777 comm.lst
host comm.lst >> apscheck.txt

prompt Searching APS Data Collections Snapshot objects, Please wait ...

host echo '' >> apscheck.txt
host echo '' >> apscheck.txt
host echo '10. APS Data Collections Objects / SQL Scripts :' >> apscheck.txt
host echo '================================================' >> apscheck.txt
host echo '' >> apscheck.txt
host echo 'Data Collection Setup Object Files under $MSC_TOP/sql           ' >> apscheck.txt
Host echo ' These file files used when profile MSC:Source Setup Required = Y (Yes for R12.x) Refer to Note 207644.1 ' >> apscheck.txt
host echo '-------------------------------------------------------------------------------------------------------' >> apscheck.txt

spool comm.lst
  select 'grep -i ''$Header''  $'||basepath||'/sql/*.sql'
  from   fnd_application
  where  application_id  in (724);
spool off;
host chmod 777 comm.lst
host comm.lst >> apscheck.txt

host echo '' >> apscheck.txt
host echo 'General Purpose SQL Files under $MSC_TOP/patch/115/sql' >> apscheck.txt
-- host echo ' Includes files for $MSC_TOP and $MSD_TOP             ' >> apscheck.txt
host echo '------------------------------------------------------' >> apscheck.txt
spool comm.lst
  select 'grep -i ''$Header''  $'||basepath||'/patch/115/sql/*.sql'
  from   fnd_application
  where  application_id  in (724);

spool off;
host chmod 777 comm.lst
host comm.lst >> apscheck.txt

/* -- not working now - returns argument list too long error, too many files
spool comm.lst
  select 'grep -i ''$Header''  $'||basepath||'/patch/115/sql/*.sql'
  from   fnd_application
  where  application_id  in (722);

spool off;
host chmod 777 comm.lst
host comm.lst >> apscheck.txt
*/

prompt Searching Product Tops, Please wait ...

host echo '' >> apscheck.txt
host echo '11. Product Tops :' >> apscheck.txt
host echo '==================' >> apscheck.txt
host echo '' >> apscheck.txt

spool comm.lst
  select 'echo $'||basepath prod_top
  from   fnd_application
  where  application_id  in (724, 704, 723, 722, 726);
spool off;

host chmod 777 comm.lst
host comm.lst >> apscheck.txt

prompt Searching Product Forms, Please wait ...

host echo '' >> apscheck.txt
host echo '12. Form Versions :' >> apscheck.txt
host echo '===================' >> apscheck.txt
host echo '' >> apscheck.txt
host echo '  From $MSx_TOP/forms/<LANGUAGE> , example $MSC_TOP/forms/US ' >> apscheck.txt
host echo '  FMB files are the uncompiled forms / Compiled forms listed on customer file system have FMX extension ' >> apscheck.txt
host echo '  Internally search ARU using <name>.FMB ' >> apscheck.txt
host echo '' >> apscheck.txt

REM DAN CHANGE START
spool comm.lst
select 'strings -a $MSC_TOP/forms/'||userenv('LANG')||'/*.fmx | grep ''$Header: ''' 
 from   dual;
select 'strings -a $MSD_TOP/forms/'||userenv('LANG')||'/*.fmx | grep ''$Header: ''' 
 from   dual;
select 'strings -a $MRP_TOP/forms/'||userenv('LANG')||'/*.fmx | grep ''$Header: ''' 
 from  dual;
spool off

host chmod 777 comm.lst
host comm.lst >> apscheck.txt

prompt Searching Product Libraries, Please wait ...

host echo '' >> apscheck.txt
host echo '13. Library Versions :' >> apscheck.txt
host echo '======================' >> apscheck.txt
host echo '' >> apscheck.txt
host echo '  Form Libraries used for forms are in $AU_TOP/resource directory ' >> apscheck.txt
host echo '  PLD are uncompiled forms libraries / Compiled form libraries listed in customer file system have BOTH PLL and PLX extensions ' >> apscheck.txt
host echo '  Internally search ARU using <name>.PLD ' >> apscheck.txt
host echo '  ' >> apscheck.txt

host echo '  ' >> apscheck.txt
host echo ' Here is the list of PLL - library files used to build PLX library executable files on the system  ' >> apscheck.txt
spool comm.lst
   select distinct 'strings -a $AU_TOP/resource/'||substr(ff.form_name, 1, 3)||'*.pll | grep ''$Header: M'''
   from fnd_form ff
   where application_id  in (724, 704, 723, 722);
spool off

host chmod 777 comm.lst
host comm.lst >> apscheck.txt

host echo '  ' >> apscheck.txt
host echo '  ' >> apscheck.txt
host echo ' Here is the list of PLX - library executable files  ' >> apscheck.txt
host echo '  This list should have the same number of files and as the PLL list above.' >> apscheck.txt
host echo '  ' >> apscheck.txt

spool comm.lst
   select distinct 'strings -a $AU_TOP/resource/'||substr(ff.form_name, 1, 3)||'*.plx | grep ''$Header: M'''
   from fnd_form ff
   where application_id  in (724, 704, 723, 722);
spool off

host chmod 777 comm.lst
host comm.lst >> apscheck.txt

prompt Searching Product Reports, Please wait ...

host echo '' >> apscheck.txt
host echo '14. Reports Versions :' >> apscheck.txt
host echo '======================' >> apscheck.txt
host echo ' 14.1 and 14.2 should be checked if Discoverer Planning Detail Report is installed/used, then EEX file versions are reported ' >> apscheck.txt
host echo ' 14.3 reports versions for the RTF files of the XML Planning Detail Report ' >> apscheck.txt
host echo ' For information on the R12.x GMP Planning Detail Report see Note 738008.1' >> apscheck.txt
host echo ' For information on Discoverer Planning Detail Report see Note 762621.1' >> apscheck.txt
host echo '' >> apscheck.txt
host echo ' 14.4 checks Reports RDF files in $MRP_TOP/reports – currently only Standard MRP has RDF type Reports ' >> apscheck.txt
host echo '' >> apscheck.txt


host echo '14.1 - Checking $MSC_TOP/patch/115/discover/US directory' >> apscheck.txt
host echo '========================================================' >> apscheck.txt
host echo '  The msc*o.eex files for this release should be here if Discoverer Report patch is installed' >> apscheck.txt
spool comm.lst
  select 'strings -a $MSC_TOP/patch/115/discover/US/*.eex | grep ''$Header: '''
  from   dual;
spool off

host chmod 777 comm.lst
host comm.lst >> apscheck.txt

host echo '' >> apscheck.txt
host echo '14.2 - Checking $AU_TOP/discover/US directory' >> apscheck.txt
host echo '=================================================' >> apscheck.txt
host echo '  The msc*o.eex files must also be in this directory before Post install setup steps will complete successfully' >> apscheck.txt
host echo '    Files and Versions must match with versions in 14.1 output' >> apscheck.txt
spool comm.lst
  select 'strings -a $MSC_TOP/discover/US/msc*.eex | grep ''$Header: '''
  from   dual;
spool off

host chmod 777 comm.lst
host comm.lst >> apscheck.txt


host echo '' >> apscheck.txt
host echo '14.3 - Checking $GMP_TOP/patch/115/publisher/templates/US directory' >> apscheck.txt
host echo '===================================================================' >> apscheck.txt
host echo '  in R12.x, the RTF files that produce the XML Planning Detail Report are in this location' >> apscheck.txt
host echo '  ' >> apscheck.txt
spool comm.lst
  select 'strings -a $GMP_TOP/patch/115/publisher/templates/US/*.rtf | grep ''$Header: '''
  from   dual;
spool off

host chmod 777 comm.lst
host comm.lst >> apscheck.txt


host echo '' >> apscheck.txt
host echo '14.4 - Checking for MRP reports version info' >> apscheck.txt
host echo '=================================================' >> apscheck.txt
spool comm.lst
  select 'strings -a $MRP_TOP/reports/'||userenv('LANG')||'/*.rdf | grep ''$Header: '''
  from   dual;
spool off

host chmod 777 comm.lst
host comm.lst >> apscheck.txt


host echo '' >> apscheck.txt
host echo '14.4 - Checking for GMP XML Planning Detail Report RTF versions info' >> apscheck.txt
host echo '======================================================================' >> apscheck.txt
spool comm.lst
  select 'strings -a GMP$_TOP/patch/115/publisher/templates/'||userenv('LANG')||'/*.rtf | grep ''$Header: '''
  from   dual;
spool off

host chmod 777 comm.lst
host comm.lst >> apscheck.txt


prompt Searching ODF File versions, Please wait ...

host echo '' >> apscheck.txt
host echo '15. ODF, LDT and Workflow File Versions :' >> apscheck.txt
host echo '==========================================' >> apscheck.txt
host echo '' >> apscheck.txt
host echo '' >> apscheck.txt
host echo '' >> apscheck.txt
host echo '15.1 ODF and LDT File Versions :' >> apscheck.txt
host echo '==========================================' >> apscheck.txt

host echo '  ODF files are in $PROD_TOP/patch/115/odf ($PROD_TOP reporting for MSC, MSD, MRP, MSO) ' >> apscheck.txt
host echo '  LDT files are in $PROD_TOP/patch/115/import/<LANGUAGE> - example $MSC_TOP/patch/115/import/US ' >> apscheck.txt
host echo '' >> apscheck.txt

spool comm.lst
   select 'strings -a $MSC_TOP/patch/115/odf/*.odf | grep ''$Header: ''' 
   from   dual;
   select 'strings -a $MSD_TOP/patch/115/odf/*.odf | grep ''$Header: ''' 
   from   dual;
   select 'strings -a $MSO_TOP/patch/115/odf/*.odf | grep ''$Header: ''' 
   from   dual;
   select 'strings -a $MRP_TOP/patch/115/odf/*.odf | grep ''$Header: ''' 
   from   dual;
   select 'strings -a $MSC_TOP/patch/115/import/'||userenv('LANG')||'/*.ldt | grep ''$Header: ''' 
   from   dual;
   select 'strings -a $MSD_TOP/patch/115/import/'||userenv('LANG')||'/*.ldt | grep ''$Header: ''' 
   from   dual;
   select 'strings -a $MSO_TOP/patch/115/import/'||userenv('LANG')||'/*.ldt | grep ''$Header: ''' 
   from   dual;
   select 'strings -a $MRP_TOP/patch/115/import/'||userenv('LANG')||'/*.ldt | grep ''$Header: ''' 
   from   dual;
spool off

host chmod 777 comm.lst
host comm.lst >> apscheck.txt

prompt Searching WorkFlow File versions, Please wait ...

host echo '' >> apscheck.txt
host echo '15.2 WorkFlow File Versions :' >> apscheck.txt
host echo '============================' >> apscheck.txt
host echo '  WFT Workflow files are in $PROD_TOP/patch/115/import ($PROD_TOP reporting for MSC, MSD, MRP, MSO) ' >> apscheck.txt
host echo '' >> apscheck.txt

spool comm.lst
   select 'strings -a $MSC_TOP/patch/115/import/'||userenv('LANG')||'/*.wft | grep ''$Header: ''' 
   from   dual;
   select 'strings -a $MSD_TOP/patch/115/import/'||userenv('LANG')||'/*.wft | grep ''$Header: ''' 
   from   dual;
   select 'strings -a $MSO_TOP/patch/115/import/'||userenv('LANG')||'/*.wft | grep ''$Header: ''' 
   from   dual;
   select 'strings -a $MRP_TOP/patch/115/import/'||userenv('LANG')||'/*.wft | grep ''$Header: ''' 
   from   dual;
spool off

host chmod 777 comm.lst
host comm.lst >> apscheck.txt

host echo '' >> apscheck.txt
host echo '' >> apscheck.txt
host echo '16. Rapid Planning and APCC Information :' >> apscheck.txt
host echo '=========================================' >> apscheck.txt
host echo ' '  >> apscheck.txt
host echo ' In 12.1 - Rapid Planning delivers 3 ZIP files to $MSC_TOP/dist/orp '  >> apscheck.txt
host echo ' '  >> apscheck.txt
host echo ' In 12.1 - Advanced Planning Command Center (APCC) delivers files to $MSC_TOP/patch/115/obiee ' >> apscheck.txt
host echo ' APCC also uses $MSC_TOP/patch/115/sql/MSCHB*.pls - these file versions are in Section 8 of this output ' >> apscheck.txt
host echo '' >> apscheck.txt

host echo '' >> apscheck.txt
host echo '16.1 RP ZIP file versions from $MSC_TOP/dist/orp ' >> apscheck.txt
host echo ' ------------------------------------------------' >> apscheck.txt
spool comm.lst
   select 'strings -a $MSC_TOP/dist/orp/*zip | grep ''$Header: ''' 
   from   dual;
spool off

host chmod 777 comm.lst
host comm.lst >> apscheck.txt

host echo '' >> apscheck.txt
host echo '16.2 APCC File versions from $MSC_TOP/patch/115/obiee  ' >> apscheck.txt
host echo ' ------------------------------------------------' >> apscheck.txt
spool comm.lst
   select 'strings -a $MSC_TOP/patch/115/obiee/* | grep ''$Header: ''' 
   from   dual;
spool off

host chmod 777 comm.lst
host comm.lst >> apscheck.txt

host echo '' >> apscheck.txt
host echo '16.3 - Check Base URL profile FND: Oracle Business Intelligence Suite EE base URL ' >> apscheck.txt
host echo '    If NO ROWS Returned, then this profile is not setup ' >> apscheck.txt
host echo '    Check Section 4 for info on MSC profiles ' >> apscheck.txt
host echo ' ---------------------------------------------------------------------------------' >> apscheck.txt

spool comm.lst
 SELECT 
fu2.user_name, 
SUBSTR(DECODE(fpov.level_id,10001,'Site',10002,'Application',10003,'Responsibility',10004,'User'),1,15) profile_level, 
SUBSTR(fpot.USER_PROFILE_OPTION_NAME,1,40) NAME,
fpo.PROFILE_OPTION_NAME CODE,
SUBSTR(fpov.PROFILE_OPTION_VALUE,1,50) VALUE
FROM FND_PROFILE_OPTION_VALUES fpov,
FND_PROFILE_OPTIONS_TL fpot, 
FND_PROFILE_OPTIONS fpo, 
FND_APPLICATION fapp,
FND_USER fu2
WHERE fpo.PROFILE_OPTION_ID = fpov.PROFILE_OPTION_ID 
AND fpov.APPLICATION_ID = fapp.APPLICATION_ID 
AND fpo.PROFILE_OPTION_NAME LIKE 'FND_OBIEE_URL%'
AND fpot.PROFILE_OPTION_NAME = fpo.PROFILE_OPTION_NAME
AND fpov.level_value = fu2.user_id
ORDER BY CODE,NAME;
spool off

host chmod 777 comm.lst
host comm.lst >> apscheck.txt


prompt performing Pro*C file version, Please wait ...
host echo '' >> apscheck.txt
host echo '17. Product Pro*C Files :' >> apscheck.txt
host echo '=========================' >> apscheck.txt
host echo '' >> apscheck.txt
host echo ' NOTE: The 64 bit executables (like $MSC_TOP/bin/MSCNWS64.exe) are delivered already built in the patch' >> apscheck.txt
host echo '       NEVER use a manual adrelink on these files ' >> apscheck.txt
host echo '' >> apscheck.txt
host echo ' All 64 bit exe files for every supported platform (MS?_TOP/bin/MS*64.exe) are delivered with each patch' >> apscheck.txt
host echo '' >> apscheck.txt
host echo '' >> apscheck.txt

host echo '' >> apscheck.txt
host echo '17.1 Product Pro*C Files Spot Check Version Comparison :' >> apscheck.txt
host echo '--------------------------------------------------------' >> apscheck.txt
host echo 'This Checks version of Key files in the Executable files in $MS?_TOP/bin directory ' >> apscheck.txt
host echo 'Then also gets versions from library files ($MS?_TOP/lib) that are used to build exe files ' >> apscheck.txt
host echo '' >> apscheck.txt
host echo '   For plan failures, check this section to make sure that versions match ' >> apscheck.txt
host echo '   On a new instance where planning hangs in the Memory Based Snapshot, then check that enough processes are available to run the plan – Section 26 ' >> apscheck.txt
host echo '' >> apscheck.txt
host echo 'IF these versions are different,  ' >> apscheck.txt
host echo 'THEN the planning requests will fail  ' >> apscheck.txt
host echo 'RELINK INSTRUCTIONS ' >> apscheck.txt
host echo '  1. Use adadmin  / Maintain Applications Files menu / Relink Applications programs ' >> apscheck.txt
host echo '  2. Relink the executables for MSC, MSO, MSR ' >> apscheck.txt
host echo '  3. Run this SQL again and check results' >> apscheck.txt
host echo '  4. IF adadmin fails to resolve version mismatch, THEN manual adrelink of all the standard executables may be required ' >> apscheck.txt

host echo '' >> apscheck.txt


host echo '17.1.1 Comparing file mslnw3.ppc in MSC_TOP/bin/MSCNEW, MSCNSP and $MSC_TOP/lib/libmsc.a ... ' >> apscheck.txt
host echo '--------------------------------------------------------------------------------------------' >> apscheck.txt
spool comm.lst
  select 'strings -a $MSC_TOP/bin/MSCNEW | grep -i ''$Header: mslnw3.ppc'''
  from   dual;
  select 'strings -a $MSC_TOP/bin/MSCNSP | grep -i ''$Header: mslnw3.ppc'''
  from   dual;
  select 'strings -a $MSC_TOP/lib/libmsc.a | grep -i ''$Header: mslnw3.ppc'''
  from   dual;
spool off
host chmod 777 comm.lst
host comm.lst >> apscheck.txt

host echo ' Compare the above and all three file versions should match, ' >> apscheck.txt
host echo '  IF not, THEN relink of MSC application is required, use RELINK INSTRUCTIONS above  ' >> apscheck.txt

host echo '' >> apscheck.txt
host echo '' >> apscheck.txt

host echo '17.1.2 Comparing file msocnew.ppc in MSO_TOP/bin/MSONEW and $MSO_TOP/lib/libmso.a ... ' >> apscheck.txt
host echo '-------------------------------------------------------------------------------------' >> apscheck.txt
host echo '' >> apscheck.txt
spool comm.lst
  select 'strings -a $MSO_TOP/bin/MSONEW | grep -i ''$Header: msocnew.ppc'''
  from   dual;
  select 'strings -a $MSO_TOP/lib/libmso.a | grep -i ''$Header: msocnew.ppc'''
  from   dual;
spool off
host chmod 777 comm.lst
host comm.lst >> apscheck.txt

host echo ' Compare the above and both file versions should match, ' >> apscheck.txt
host echo '  IF not, THEN relink of MSO application is required, use RELINK INSTRUCTIONS above  ' >> apscheck.txt
host echo '' >> apscheck.txt
host echo '' >> apscheck.txt

host echo '17.1.3 Comparing file mslnw3.ppc in MSR_TOP/bin/MSRNEW and $MSR_TOP/lib/libmsr.a ... ' >> apscheck.txt
host echo '------------------------------------------------------------------------------------' >> apscheck.txt
host echo '  This may return no rows or only 1 row of the MSR application is not installed, check first section for install status ' >> apscheck.txt
host echo '' >> apscheck.txt

spool comm.lst
  select 'strings -a $MSR_TOP/bin/MSRNEW | grep -i ''$Header: mslnw3.ppc'''
  from   dual;
  select 'strings -a $MSR_TOP/lib/libmsr.a | grep -i ''$Header: mslnw3.ppc'''
  from   dual;
spool off
host chmod 777 comm.lst
host comm.lst >> apscheck.txt

host echo '  If installed, then Compare the above and both file versions should match, ' >> apscheck.txt
host echo '  IF required, THEN relink of MSR application is required, use RELINK INSTRUCTIONS above  ' >> apscheck.txt
host echo '' >> apscheck.txt
host echo '' >> apscheck.txt


host echo '' >> apscheck.txt
host echo '' >> apscheck.txt
host echo '17.2 Product Pro*C Files from the libraries used to build the Executable files :' >> apscheck.txt
host echo '-------------------------------------------------------------------------------- ' >> apscheck.txt
host echo ' Gets versions from $MSC_TOP/lib/libmsc.a, $MSO_TOP/lib/libmo.a, $MSR_TOP/lib/libmsr.a ' >> apscheck.txt
host echo '' >> apscheck.txt
host echo ' Check file version of MSCNWH64.ppc against file manifest of Engine RUP Patch if any question on the patch level. ' >> apscheck.txt
host echo ' Internally, review file versions in ARU system, This can help determine if a one-off engine patch is applied after the rollup patch. ' >> apscheck.txt
host echo ' These can have extensions like ppc, lcc, opp ' >> apscheck.txt
host echo '' >> apscheck.txt
spool comm.lst
  select 'strings -a $MSC_TOP/lib/libmsc.a | grep -i ''$Header:'''
  from   dual;
  select 'strings -a $MSO_TOP/lib/libmso.a | grep -i ''$Header:'''
  from   dual;
  select 'strings -a $MSR_TOP/lib/libmsr.a | grep -i ''$Header:'''
  from   dual;
spool off

host chmod 777 comm.lst
host comm.lst >> apscheck.txt


set head on
prompt Show Item Attribute Controls ...

host echo '' >> apscheck.txt
host echo '18. Item Attribute Controls :' >> apscheck.txt
host echo '=============================' >> apscheck.txt
host echo '' >> apscheck.txt

spool comm.lst
  select attribute_name,
         decode(control_level, 1, 'Master',
                               2, 'Org',
                               3, 'Viewable',
                               to_char(control_level)) control_level,
         status_control_code
  from   mtl_item_attributes
  order  by attribute_name ;
spool off;

host chmod 777 comm.lst
host cat comm.lst >> apscheck.txt



prompt ENABLED SYSTEM ITEMS SEGMENTS ...

host echo '' >> apscheck.txt
host echo '19. System Items Segment list :' >> apscheck.txt
host echo '===============================' >> apscheck.txt
host echo '' >> apscheck.txt

spool comm.lst
  select segment_num             SEGMENT_NUMBER,
         SEGMENT_NAME ,
         application_column_name COLUMN_NAME, 
         REQUIRED_FLAG
  from   fnd_id_flex_segments_vl
  where  application_id = 401
  and    id_flex_code = 'MSTK'
  and    id_flex_num = 101
  and    enabled_flag = 'Y'
  order  by segment_num ;
spool off;

host chmod 777 comm.lst
host cat comm.lst >> apscheck.txt

prompt ENABLED STOCK LOCATORS SEGMENTS... 

host echo '' >> apscheck.txt
host echo '20. Stock Locators Segment list :' >> apscheck.txt
host echo '=================================' >> apscheck.txt
host echo '' >> apscheck.txt

spool comm.lst
  select segment_num SEGMENT_NUMBER,SEGMENT_NAME ,application_column_name COLUMN_NAME, REQUIRED_FLAG
  from   fnd_id_flex_segments_vl
  where application_id = 401
  and id_flex_code = 'MTLL'
  and id_flex_num = 101
  and enabled_flag = 'Y'
  order by segment_num ;
spool off;

host chmod 777 comm.lst
host cat comm.lst >> apscheck.txt

prompt Show Languages list ...

host echo '' >> apscheck.txt
host echo '21. Language list :' >> apscheck.txt
host echo '===================' >> apscheck.txt
host echo '' >> apscheck.txt

spool comm.lst
  select LANGUAGE_CODE,INSTALLED_FLAG
  from   fnd_languages
  order by INSTALLED_FLAG;
spool off;

host chmod 777 comm.lst
host cat comm.lst >> apscheck.txt

prompt Show organization and calendar list ...

host echo '' >> apscheck.txt
host echo '22. Organization, Calendar and Assignment Set list :' >> apscheck.txt
host echo '====================================================' >> apscheck.txt
host echo '   Checks INV table MTL_PARAMETERS in ERP Source applications and then APS orgs in MSC_TRADING_PARTNERS ' >> apscheck.txt
host echo '   Also shows APS enabled for collections - and for 11.5.10, R12 – shows ODP/Demantra enabled and Collection Group ' >> apscheck.txt
host echo '' >> apscheck.txt
host echo '   Data shown below depends on option chosen when running script ' >> apscheck.txt
host echo '        B = BOTH shows ERP and APS info, Centralized install - both outputs should be present ' >> apscheck.txt
host echo '        P = PLANNING, shows only APS info, if ERP info exists, check Section 23 for Source setup ' >> apscheck.txt
host echo '        E = ERP, shows only MTL table info ' >> apscheck.txt
host echo '' >> apscheck.txt
spool comm.lst
begin
   if :v_erp_or_plan in ('E', 'B', 'P') then
     dbms_output.put_line('MTL_PARAMETERS ORG LIST FROM ERP SOURCE');
     dbms_output.put_line('---------------------------------------');
   end if;
end;
/

  select organization_code,
         organization_id,
         process_enabled_flag,
         process_orgn_Code,
         master_organization_id,
         calendar_code "CALENDAR"
  from   mtl_parameters
  where  :v_erp_or_plan in('E', 'B','P')
  order  by master_organization_id,organization_id ;

declare
  type t_crs is REF CURSOR;
  v_crs         t_crs;
  v_sql         varchar2(2000);

  type r_org_list is record
     (sr_instance_id      msc_instance_orgs.sr_instance_id%type, 
      organization_code   msc_trading_partners.organization_code%type, 
      organization_id     msc_instance_orgs.organization_id%type, 
      calendar_code       msc_trading_partners.calendar_code%type,
      master_organization msc_trading_partners.master_organization%type, 
      aps_enabled         varchar2(4), 
      odp_enabled         varchar2(4),
      Org_Group           varchar2(30),
      organization_type   varchar2(1));

  rec_org_list r_org_list;

begin
  -- show only in case of planning/both instance.
  if :v_erp_or_plan <> 'E' then
    dbms_output.put_line('.');
    dbms_output.put_line(' ');
    dbms_output.put_line('APS ORGANIZATIONS');
    dbms_output.put_line('------------------');
    dbms_output.put_line(' ');
    v_sql := 'select mio.sr_instance_id, mtp.organization_code, mio.organization_id, mtp.calendar_code, '||
                    'mtp.master_organization, decode(mio.enabled_flag,1,''Yes'',2,''No'', ''Null'') APS_Enabled, '||
                    'decode (mtp.organization_type, 1,'' '', 2, ''Y'') organization_type ';

    -- To show columns based on patchset level.
      if :v_scp_pf in('11i.SCP_PF.J', 'R12.SCP_PF.A' ,'R12.SCP_PF.1','R12.SCP_PF.2','R12.SCP_PF.3','R12.SCP_PF.4','R12.SCP_PF.6','R12.SCP_PF.B','R12.SCP_PF.B.1','R12.SCP_PF.B.2','R12.SCP_PF.B.3','R12.SCP_PF.C','R12.SCP_PF.C.1') then
      v_sql := v_sql || ', decode(mio.dp_enabled_flag, 1,''Yes'', 2,''No'', ''Null'') ODP_Enabled, Org_Group ';
--  dagoddar 04-sep-07     elsif :v_scp_pf = '11i.SCP_PF.J' then
--      v_sql := v_sql || ', Org_Group ';
    end if;

    v_sql := v_sql || ' from   msc_instance_orgs mio, msc_trading_partners mtp '||
                      ' where  mio.sr_instance_id = mtp.sr_instance_id and '||
                             ' mio.organization_id = mtp.sr_tp_id and '||
                             ' mtp.partner_type = 3 '||
                      ' order by 1,2 ';

    -- Printing Header based on patchset level.
      if :v_scp_pf in('11i.SCP_PF.J', 'R12.SCP_PF.A' ,'R12.SCP_PF.1','R12.SCP_PF.2','R12.SCP_PF.3','R12.SCP_PF.4','R12.SCP_PF.6','R12.SCP_PF.B','R12.SCP_PF.B.1','R12.SCP_PF.B.2','R12.SCP_PF.B.3','R12.SCP_PF.C','R12.SCP_PF.C.1') then
      dbms_output.put_line('SR Instance ID Org Code Org ID Calendar       Master Org OPM Org  APS Enabled ODP Enabled Org Group ');
      dbms_output.put_line('============== ======== ====== ============== ========== ======== =========== =========== ========= ');
--  dagoddar 04-sep-07    elsif :v_scp_pf = '11i.SCP_PF.J' then
--      dbms_output.put_line('SR Instance ID Org Code Org ID Calendar       Master Org OPM Org  APS Enabled Org Group ');
--      dbms_output.put_line('============== ======== ====== ============== ========== ======== =========== ========= ');
    else
      dbms_output.put_line('SR Instance ID Org Code Org ID Calendar       Master Org OPM Org  APS Enabled ');
      dbms_output.put_line('============== ======== ====== ============== ========== ======== =========== ');
    end if;

    -- Opening cursor and printing data based on patchset level.
    open v_crs for v_sql;
    loop
      if :v_scp_pf in('11i.SCP_PF.J', 'R12.SCP_PF.A' ,'R12.SCP_PF.1','R12.SCP_PF.2','R12.SCP_PF.3','R12.SCP_PF.4','R12.SCP_PF.6','R12.SCP_PF.B','R12.SCP_PF.B.1','R12.SCP_PF.B.2','R12.SCP_PF.B.3','R12.SCP_PF.C','R12.SCP_PF.C.1') then
        fetch v_crs into rec_org_list.sr_instance_id,  rec_org_list.organization_code,
                         rec_org_list.organization_id, rec_org_list.calendar_code, rec_org_list.master_organization,
                         rec_org_list.APS_enabled,     rec_org_list.organization_type, rec_org_list.odp_enabled,
                         rec_org_list.org_group;
--  dagoddar 04-sep-07    elsif :v_scp_pf = '11i.SCP_PF.J' then
--        fetch v_crs into rec_org_list.sr_instance_id,  rec_org_list.organization_code,
--                         rec_org_list.organization_id, rec_org_list.calendar_code, rec_org_list.master_organization,
--                         rec_org_list.APS_enabled,     rec_org_list.organization_type, rec_org_list.org_group;
      else
        fetch v_crs into rec_org_list.sr_instance_id,  rec_org_list.organization_code,
                         rec_org_list.organization_id, rec_org_list.calendar_code, rec_org_list.master_organization,
                         rec_org_list.APS_enabled ,    rec_org_list.organization_type;
      end if;
      exit when v_crs%notfound;
      if :v_scp_pf in('11i.SCP_PF.J', 'R12.SCP_PF.A' ,'R12.SCP_PF.1','R12.SCP_PF.2','R12.SCP_PF.3','R12.SCP_PF.4','R12.SCP_PF.6','R12.SCP_PF.B','R12.SCP_PF.B.1','R12.SCP_PF.B.2','R12.SCP_PF.B.3','R12.SCP_PF.C','R12.SCP_PF.C.1') then
        dbms_output.put_line(rpad(rec_org_list.sr_instance_id, 14)||' '||rpad(rec_org_list.organization_code, 8)||' '||
                             lpad(rec_org_list.organization_id, 6)||' '||lpad(rec_org_list.calendar_code, 14)||' '||
                             lpad(rec_org_list.master_organization, 10)||' '||lpad(rec_org_list.organization_type, 8)||' '||
                             rpad(rec_org_list.aps_enabled, 11)||' '||rpad(rec_org_list.odp_enabled, 11)||' '||
                             rec_org_list.org_group);
--  dagoddar 04-sep-07     elsif :v_scp_pf = '11i.SCP_PF.J' then
--        dbms_output.put_line(rpad(rec_org_list.sr_instance_id, 14)||' '||rpad(rec_org_list.organization_code, 8)||' '||
--                             lpad(rec_org_list.organization_id, 6)||' '||lpad(rec_org_list.calendar_code, 14)||' '||
--                             lpad(rec_org_list.master_organization, 10)||' '||lpad(rec_org_list.organization_type, 8)||' '||
--                             rpad(rec_org_list.aps_enabled, 11)||' '||rpad(rec_org_list.odp_enabled, 11)||' '||
--			     rec_org_list.org_group);
      else
        dbms_output.put_line(rpad(rec_org_list.sr_instance_id, 14)||' '||rpad(rec_org_list.organization_code, 8)||' '||
                             lpad(rec_org_list.organization_id, 6)||' '||lpad(rec_org_list.calendar_code, 14)||' '||
                             lpad(rec_org_list.master_organization, 10)||' '||lpad(rec_org_list.organization_type, 8)||' '||
                             rpad(rec_org_list.aps_enabled, 11));
      end if;
    end loop;
  end if;
end;
/

spool off;

host chmod 777 comm.lst
host cat comm.lst >> apscheck.txt

host echo '' >> apscheck.txt
host echo '22.1 APS Calendar list :' >> apscheck.txt
host echo '========================' >> apscheck.txt
host echo '  Check start and end dates of the calendars ' >> apscheck.txt
host echo '   Very general rule is that plans can require calendars to extend up to 2 years in Past and 5 or more years into the future  ' >> apscheck.txt
host echo '   No data shown if instance is ERP Source ' >> apscheck.txt
host echo '   Also review Section 24.3 - Instance Partition Data Integrity Check' >> apscheck.txt
host echo '' >> apscheck.txt

spool comm.lst

  select min(calendar_date) "Start Date"
, max(calendar_date) "End Date"
, calendar_code "Calendar Code"
, sr_instance_id "Instance ID"
from msc_calendar_dates
group by calendar_code, sr_instance_id
order by calendar_code;


spool off;

host chmod 777 comm.lst
host cat comm.lst >> apscheck.txt

host echo '' >> apscheck.txt
host echo '22.2 APS Assignment Set List :' >> apscheck.txt
host echo '==============================' >> apscheck.txt
host echo '  Use this list to validate the profiles seen in Section 4 output ' >> apscheck.txt
host echo '  For MRP: ATP Assignment Set use Source Asg ID ' >> apscheck.txt
host echo '  For MSC: ATP Assignment Set use MSC Asg ID ' >> apscheck.txt
host echo '   IF the Source Asg ID is a negative number, then Assignment Set was defined in ASCP application ' >> apscheck.txt
host echo '' >> apscheck.txt

spool comm.lst

SELECT sr_instance_id "Instance ID",
assignment_set_name "Asg Set Name",
ASSIGNMENT_SET_ID "MSC Asg ID",
sr_assignment_set_id "Source Asg ID"
FROM msc_assignment_sets
order by sr_instance_id, assignment_set_name;

spool off;

host chmod 777 comm.lst
host cat comm.lst >> apscheck.txt






host echo '' >> apscheck.txt
host echo '23. APS Instances' >> apscheck.txt
host echo '=================' >> apscheck.txt
host echo ' ERP Source side applications table MRP_AP_APPS_INSTANCES_ALL (11.5.9 and below table is MRP_AP_APPS_INSTANCES)' >> apscheck.txt
host echo ' APS destination applications table MSC_APPS_INSTANCES ' >> apscheck.txt
host echo ' (NULL) for DB links means Centralized, single instance install with ERP and APS on the same instance ' >> apscheck.txt
host echo ' Note 137293.1 explains setup and details for these tables ' >> apscheck.txt
host echo ' ' >> apscheck.txt
host echo ' Warning: Neither table should have same Instance Code and/or Instance ID listed more than once ' >> apscheck.txt
host echo ' ' >> apscheck.txt
host echo 'Info on DB Links Testing: ' >> apscheck.txt
host echo 'IF [M2A Dblink - APS to ERP] and [A2M Dblink - ERP To APS] is NULL ignore this information ' >> apscheck.txt
host echo 'IF this is the ERP Source Instance: then expect (Success) on Dblink Test is expected in column [A2M Dblink - ERP To APS]' >> apscheck.txt
host echo 'IF this is the ERP Source Instance: then expect (Failure) on Dblink Test is expected in column [M2A Dblink - APS to ERP]' >> apscheck.txt
host echo 'IF this is the APS Destination Instance: then expect (Failure) on Dblink Test is expected in column [A2M Dblink - ERP To APS]' >> apscheck.txt
host echo 'IF this is the APS Destination Instance: then expect (Success) on Dblink Test is expected in column [M2A Dblink - APS to ERP]' >> apscheck.txt
host echo '------------------------------------------------' >> apscheck.txt
host echo ' ' >> apscheck.txt
spool comm.lst
set lines 150
declare
  type t_crs is REF CURSOR;
  v_crs         t_crs;
  v_cnt         number := 0;

  type r_mrp_ap_apps_instances is record
     (instance_id        mrp_ap_apps_instances.instance_id%type,
      instance_code      mrp_ap_apps_instances.instance_code%type,
      m2a_dblink         mrp_ap_apps_instances.m2a_dblink%type,
      a2m_dblink         mrp_ap_apps_instances.a2m_dblink%type,
      allow_release_flag varchar2(4),
      allow_atp_flag     varchar2(4),
      sn_status          mrp_ap_apps_instances.sn_status%type,
      validation_org_id  number);

  type r_msc_apps_instances is record
     (instance_id        msc_apps_instances.instance_id%type,
      instance_code      msc_apps_instances.instance_code%type,
      m2a_dblink         msc_apps_instances.m2a_dblink%type,
      a2m_dblink         msc_apps_instances.a2m_dblink%type,
      st_status          msc_apps_instances.st_status%type,
      allow_release_flag varchar2(4),
      allow_atp_flag     varchar2(4),
      instance_type      msc_apps_instances.instance_type%type,
      so_tbl_status      msc_apps_instances.so_tbl_status%type,
      validation_org_id  number,
      apps_ver           msc_apps_instances.apps_ver%type);

  type r_msc_ai_nodes is record
     (instance_id        number,
      node_id            number,
      m2a_dblink         msc_apps_instances.m2a_dblink%type);

  v_sql         varchar2(2000);
  rec_mrp_aia   r_mrp_ap_apps_instances;
  rec_msc_ai    r_msc_apps_instances;
  rec_msc_ain   r_msc_ai_nodes;

  function validate_dblink(p_dblink varchar2) return varchar2 is
    v_cnt   number;
    v_sql   varchar2(200);
  begin
    if p_dblink is null then
      return 'Null';
    else
      v_sql := 'select count(1) from dual@'||p_dblink;
      execute immediate v_sql into v_cnt;
      return 'Success';
    end if;
  exception
    when others then
       return 'Failure';
  end validate_dblink;
begin

             -- =====================****  MRP_AP_APPS_INSTANCES_ALL ****========================

  -- Defining SELECT/CURSOR statement based on patchset level for MRP_AP_APPS_INSTANCES_ALL.
      if :v_scp_pf in('11i.SCP_PF.J', 'R12.SCP_PF.A' ,'R12.SCP_PF.1','R12.SCP_PF.2','R12.SCP_PF.3','R12.SCP_PF.4','R12.SCP_PF.6','R12.SCP_PF.B','R12.SCP_PF.B.1','R12.SCP_PF.B.2','R12.SCP_PF.B.3','R12.SCP_PF.C','R12.SCP_PF.C.1') then
    v_sql := 'select instance_id, instance_code, M2A_dblink, A2M_dblink, '||
                    'decode(allow_release_flag, 1, ''Yes'', 2, ''No'', ''NULL'') allow_release_flag, '||
                    'decode(allow_atp_flag,     1, ''Yes'', 2, ''No'', ''NULL'') allow_atp_flag, '||
                    'sn_status, validation_org_id '||
             ' from MRP_AP_APPS_INSTANCES_ALL';
  else
    v_sql := 'select instance_id, instance_code, M2A_dblink, A2M_dblink, sn_status '||
             ' from MRP_AP_APPS_INSTANCES';
  end if;

  -- Printing Header based on patchset level for MRP_AP_APPS_INSTANCES_ALL.
      if :v_scp_pf in('11i.SCP_PF.J', 'R12.SCP_PF.A' ,'R12.SCP_PF.1','R12.SCP_PF.2','R12.SCP_PF.3','R12.SCP_PF.4','R12.SCP_PF.6','R12.SCP_PF.B','R12.SCP_PF.B.1','R12.SCP_PF.B.2','R12.SCP_PF.B.3','R12.SCP_PF.C','R12.SCP_PF.C.1') then
    dbms_output.put_line('23.1 - MRP_AP_APPS_INSTANCES_ALL - ERP Applications table ');
    dbms_output.put_line('=============================================================');
    dbms_output.put_line('Warning: The table should NOT have same Instance Code and/or Instance ID listed more than once ');
    dbms_output.put_line('  NULL for DB links means Centralized, single instance install with ERP and APS on the same instance ');  
    dbms_output.put_line('    Also for NULL DB links, there should be corresponding row in MSC_APPS_INSTANCES');
    dbms_output.put_line('.');
    dbms_output.put_line('Instance ID INS M2A Dblink - APS to ERP             A2M Dblink - ERP To APS             Rel  ATP  Snapshot Sts Validation Org');
    dbms_output.put_line('=========== === =================================== =================================== ==== ==== ============ ==============');
  else
    dbms_output.put_line('23.1 - MRP_AP_APPS_INSTANCES - ERP Applications Table ');
    dbms_output.put_line('==========================================================');
    dbms_output.put_line('Warning: The table should NOT have same Instance Code and/or Instance ID listed more than once ');
    dbms_output.put_line('  NULL for DB links means Centralized, single instance install with ERP and APS on the same instance ');
    dbms_output.put_line('    Also for NULL DB links, there should be corresponding row in MSC_APPS_INSTANCES');
    dbms_output.put_line('.');
    dbms_output.put_line('Instance ID INS M2A Dblink - APS to ERP             A2M Dblink - ERP To APS             Snapshot Sts');
    dbms_output.put_line('=========== === =================================== =================================== ============');
  end if;

  -- Opening cursor and printing data based on patchset level for MRP_AP_APPS_INSTANCES_ALL.
  open v_crs for v_sql;
  loop
      if :v_scp_pf in('11i.SCP_PF.J', 'R12.SCP_PF.A' ,'R12.SCP_PF.1','R12.SCP_PF.2','R12.SCP_PF.3','R12.SCP_PF.4','R12.SCP_PF.6','R12.SCP_PF.B','R12.SCP_PF.B.1','R12.SCP_PF.B.2','R12.SCP_PF.B.3','R12.SCP_PF.C','R12.SCP_PF.C.1') then
      fetch v_crs into rec_mrp_aia.instance_id, rec_mrp_aia.instance_code,
                       rec_mrp_aia.m2a_dblink,  rec_mrp_aia.a2m_dblink,
                       rec_mrp_aia.allow_release_flag, rec_mrp_aia.allow_atp_flag,
                       rec_mrp_aia.sn_status, rec_mrp_aia.validation_org_id;
    else
      fetch v_crs into rec_mrp_aia.instance_id, rec_mrp_aia.instance_code,
                       rec_mrp_aia.m2a_dblink,  rec_mrp_aia.a2m_dblink,
                       rec_mrp_aia.sn_status;
    end if;
    exit when v_crs%notfound;
      if :v_scp_pf in('11i.SCP_PF.J', 'R12.SCP_PF.A' ,'R12.SCP_PF.1','R12.SCP_PF.2','R12.SCP_PF.3','R12.SCP_PF.4','R12.SCP_PF.6','R12.SCP_PF.B','R12.SCP_PF.B.1','R12.SCP_PF.B.2','R12.SCP_PF.B.3','R12.SCP_PF.C','R12.SCP_PF.C.1') then
      dbms_output.put_line(rpad(rec_mrp_aia.instance_id, 11)||' '||rpad(rec_mrp_aia.instance_code, 3)||' '||
                           rpad('x'||rec_mrp_aia.M2A_dblink||'x'||' ('||validate_dblink(ltrim(rtrim(rec_mrp_aia.M2A_dblink)))||')', 35)||' '||
                           rpad('x'||rec_mrp_aia.A2M_dblink||'x'||' ('||validate_dblink(ltrim(rtrim(rec_mrp_aia.A2M_dblink)))||')', 35)||' '||
                           rpad(rec_mrp_aia.allow_release_flag, 4)||' '||rpad(rec_mrp_aia.allow_atp_flag, 4)||' '||
                           lpad(rec_mrp_aia.sn_status, 12)||' '||lpad(rec_mrp_aia.validation_org_id, 14));
    else
      dbms_output.put_line(rpad(rec_mrp_aia.instance_id, 11)||' '||rpad(rec_mrp_aia.instance_code, 3)||' '||
                           rpad('x'||rec_mrp_aia.M2A_dblink||'x'||' ('||validate_dblink(ltrim(rtrim(rec_mrp_aia.M2A_dblink)))||')', 35)||' '||
                           rpad('x'||rec_mrp_aia.A2M_dblink||'x'||' ('||validate_dblink(ltrim(rtrim(rec_mrp_aia.A2M_dblink)))||')', 35)||' '||
                           lpad(rec_mrp_aia.sn_status, 12));
    end if;
  end loop;

               -- =====================**** MSC_APPS_INSTANCES ****========================

  -- Defining SELECT/CURSOR statement based on patchset level for MSC_APPS_INSTANCES.
      if :v_scp_pf in('11i.SCP_PF.J', 'R12.SCP_PF.A' ,'R12.SCP_PF.1','R12.SCP_PF.2','R12.SCP_PF.3','R12.SCP_PF.4','R12.SCP_PF.6','R12.SCP_PF.B','R12.SCP_PF.B.1','R12.SCP_PF.B.2','R12.SCP_PF.B.3','R12.SCP_PF.C','R12.SCP_PF.C.1') then
    v_sql := 'select instance_id, instance_code, m2a_dblink, a2m_dblink, st_status, '||
                   ' decode(allow_release_flag, 1, ''Yes'', 2, ''No'', ''NULL'') allow_release_flag, '||
                   ' decode(allow_atp_flag,     1, ''Yes'', 2, ''No'', ''NULL'') allow_atp_flag, '||
                   'instance_type, so_tbl_status, validation_org_id, apps_ver '||
             ' from   msc_apps_instances';
  else
    v_sql := 'select instance_id, instance_code, m2a_dblink, a2m_dblink, st_status, '||
                    'instance_type, so_tbl_status, apps_ver '||
             ' from  msc_apps_instances';
  end if;

  -- Printing Header based on patchset level for MSC_APPS_INSTANCES.
  dbms_output.put_line('.');
  dbms_output.put_line('23.2 MSC_APPS_INSTANCES - APS Applications table ');
  dbms_output.put_line('=====================================================');
  dbms_output.put_line('Warning: The table should NOT have same Instance Code and/or Instance ID listed more than once ');
  dbms_output.put_line('  NULL for DB links means Centralized, single instance install with ERP and APS on the same instance ');
  dbms_output.put_line('    Also for NULL DB links, there should be corresponding row in MRP_AP_APPS_INSTANCES_ALL');
  dbms_output.put_line('.');
      if :v_scp_pf in('11i.SCP_PF.J', 'R12.SCP_PF.A' ,'R12.SCP_PF.1','R12.SCP_PF.2','R12.SCP_PF.3','R12.SCP_PF.4','R12.SCP_PF.6','R12.SCP_PF.B','R12.SCP_PF.B.1','R12.SCP_PF.B.2','R12.SCP_PF.B.3','R12.SCP_PF.C','R12.SCP_PF.C.1') then
    dbms_output.put_line('Instance ID INS M2A Dblink - APS to ERP             A2M Dblink - ERP To APS             ST Sts Rel  ATP  Ins Type SO Tbl Sts Validation Org   Apps Ver');
    dbms_output.put_line('=========== === =================================== =================================== ====== ==== ==== ======== ========== ============== ==========');
  else
    dbms_output.put_line('Instance ID INS M2A Dblink - APS to ERP             A2M Dblink - ERP To APS             ST Sts Ins Type SO Tbl Sts   Apps Ver');
    dbms_output.put_line('=========== === =================================== =================================== ====== ======== ========== ==========');
  end if;

  -- Opening cursor and printing data based on patchset level for MSC_APPS_INSTANCES.
  open v_crs for v_sql;
  loop
      if :v_scp_pf in('11i.SCP_PF.J', 'R12.SCP_PF.A' ,'R12.SCP_PF.1','R12.SCP_PF.2','R12.SCP_PF.3','R12.SCP_PF.4','R12.SCP_PF.6','R12.SCP_PF.B','R12.SCP_PF.B.1','R12.SCP_PF.B.2','R12.SCP_PF.B.3','R12.SCP_PF.C','R12.SCP_PF.C.1') then
      fetch v_crs into rec_msc_ai.instance_id, rec_msc_ai.instance_code,
                       rec_msc_ai.m2a_dblink,  rec_msc_ai.a2m_dblink,
                       rec_msc_ai.st_status, rec_msc_ai.allow_release_flag, 
                       rec_msc_ai.allow_atp_flag, rec_msc_ai.instance_type, 
                       rec_msc_ai.so_tbl_status, rec_msc_ai.validation_org_id,
                       rec_msc_ai.apps_ver;
    else
      fetch v_crs into rec_msc_ai.instance_id, rec_msc_ai.instance_code,
                       rec_msc_ai.m2a_dblink,  rec_msc_ai.a2m_dblink,
                       rec_msc_ai.st_status, rec_msc_ai.instance_type, 
                       rec_msc_ai.so_tbl_status, rec_msc_ai.apps_ver;
    end if;
    exit when v_crs%notfound;
      if :v_scp_pf in('11i.SCP_PF.J', 'R12.SCP_PF.A' ,'R12.SCP_PF.1','R12.SCP_PF.2','R12.SCP_PF.3','R12.SCP_PF.4','R12.SCP_PF.6','R12.SCP_PF.B','R12.SCP_PF.B.1','R12.SCP_PF.B.2','R12.SCP_PF.B.3','R12.SCP_PF.C','R12.SCP_PF.C.1') then
      dbms_output.put_line(rpad(rec_msc_ai.instance_id, 11)||' '||rpad(rec_msc_ai.instance_code, 3)||' '||
                           rpad('x'||rec_msc_ai.M2A_dblink||'x'||' ('||validate_dblink(ltrim(rtrim(rec_msc_ai.M2A_dblink)))||')', 35)||' '||
                           rpad('x'||rec_msc_ai.A2M_dblink||'x'||' ('||validate_dblink(ltrim(rtrim(rec_msc_ai.A2M_dblink)))||')', 35)||' '||
                           lpad(rec_msc_ai.st_status, 6)||' '||rpad(rec_msc_ai.allow_release_flag, 4)||' '||
                           rpad(rec_msc_ai.allow_atp_flag, 4)||' '||lpad(rec_msc_ai.instance_type, 8)||' '||
                           lpad(nvl(to_char(rec_msc_ai.so_tbl_status), ' '), 10)||' '||lpad(nvl(to_char(rec_msc_ai.validation_org_id), ' '), 14)||' '||
                           lpad(rec_msc_ai.apps_ver, 10));
    else
      dbms_output.put_line(rpad(rec_msc_ai.instance_id, 11)||' '||rpad(rec_msc_ai.instance_code, 3)||' '||
                           rpad('x'||rec_msc_ai.M2A_dblink||'x'||' ('||validate_dblink(ltrim(rtrim(rec_msc_ai.M2A_dblink)))||')', 35)||' '||
                           rpad('x'||rec_msc_ai.A2M_dblink||'x'||' ('||validate_dblink(ltrim(rtrim(rec_msc_ai.A2M_dblink)))||')', 35)||' '||
                           lpad(rec_msc_ai.st_status, 6)||' '||lpad(rec_msc_ai.instance_type, 8)||' '||
                           lpad(nvl(to_char(rec_msc_ai.so_tbl_status), ' '), 10)||' '||lpad(rec_msc_ai.apps_ver, 10));
    end if;
  end loop;

              -- =====================**** MSC_APPS_INSTANCE_NODES ****========================

-- nakhouri 06-Sep START
  -- Printing data only when table exists
  select count(1)
  into   v_cnt
  from   all_tables
  where  table_name = 'MSC_APPS_INSTANCE_NODES';

  if v_cnt >= 1 then
--   if :v_scp_pf in('11i.SCP_PF.J', 'R12.SCP_PF.A' ,'R12.SCP_PF.1','R12.SCP_PF.2','R12.SCP_PF.3','R12.SCP_PF.4') then
-- nakhouri 06-Sep END

    select 'select instance_id, node_id, m2a_dblink from MSC_APPS_INSTANCE_NODES'
    into v_sql
    from dual;

    dbms_output.put_line('.');
    dbms_output.put_line('23.3 - MSC_APPS_INSTANCES_NODES - ATP Table for RAC installed ERP Source');
    dbms_output.put_line('=========================================================================');
    dbms_output.put_line(' This table is required to be populated for GOP/ATP when the ERP Source is a RAC RDBMS ');
    dbms_output.put_line(' ATP Processing Error for GOP/ATP is flag to check ERP Source for RAC install Ref: Note 266125.1 ');
    dbms_output.put_line('   see Notes on Section 9 of this output to check if this is a RAC install  ');
    dbms_output.put_line('.');
    dbms_output.put_line('Instance ID     Node ID M2A Dblink                         ');
    dbms_output.put_line('=========== =========== ===================================');
    open v_crs for v_sql;
    loop
      fetch v_crs into rec_msc_ain;
      exit when v_crs%notfound;

      dbms_output.put_line(rpad(rec_msc_ain.instance_id, 11)||' '||lpad(rec_msc_ain.node_id, 11)||' '||
                           rpad('x'||rec_msc_ain.M2A_dblink||'x'||' ('||validate_dblink(ltrim(rtrim(rec_msc_ain.M2A_dblink)))||')', 35));
    end loop;
  end if;
end;
/

spool off;
set lines 135

host chmod 777 comm.lst
host cat comm.lst >> apscheck.txt


host echo '' >> apscheck.txt
host echo '24. Partitions list' >> apscheck.txt
host echo '===================' >> apscheck.txt
host echo '' >> apscheck.txt
host echo ' Check Note 137293.1 for comprehensive information about using Partitions in APS Applications ' >> apscheck.txt
host echo '' >> apscheck.txt
host echo ' Checking value of profile MSC: Share Plan Partition' >> apscheck.txt
begin
  select substr(fpov.profile_option_value, 1, 52)
  into   :v_share_plan
  from   fnd_profile_option_values fpov,
         fnd_profile_options_vl    fpo
  where  fpo.application_id = fpov.application_id and
         fpo.profile_option_id = fpov.profile_option_id and
         fpo.profile_option_name = 'MSC_SHARE_PARTITIONS';
exception
  when others then
    null;
end;
/

set head off
spool comm.lst
select decode(:v_share_plan, 'Y', ' WARNING: MSC: Share Plan Partitions = Yes, Shared Plan Partitions being used',
                             'MSC: Share Plan Partitions = No, Plan Partitions are being used')
from   dual;
spool off;
set head on
host chmod 777 comm.lst
host cat comm.lst >> apscheck.txt
host echo ' Using Shared Plan partitions in not recommended/allowed and can cause performance problems ' >> apscheck.txt

host echo '' >> apscheck.txt
host echo '' >> apscheck.txt
host echo '24.1 - Plan Partitions' >> apscheck.txt
host echo '=======================' >> apscheck.txt
host echo ' Extra unused partitions with free_flag = 1 – Check Note 137293.1 for guidelines ' >> apscheck.txt
host echo '   A few free plan partitions are OK, but many extra free partitions are known to cause performance issues ' >> apscheck.txt
host echo '' >> apscheck.txt
host echo '   Partitions with Plan Name - *UNUSABLE* should be dropped using Drop Partition ' >> apscheck.txt
host echo '      - The *USUABLE* status usually occurs when ATP 24x7 process cannot use all the tables in the partition, no root cause is known' >> apscheck.txt
host echo '      - Simply drop the *USUABLE* partition, and then Create APS Partitions to create a new Plan partition as required ' >> apscheck.txt

spool comm.lst
  select plan_id "Plan ID", plan_name, free_flag, partition_number "Plan Prtn Num", last_update_date
  from msc_plan_partitions
  order by plan_name;
spool off;

host chmod 777 comm.lst
host cat comm.lst >> apscheck.txt

host echo '' >> apscheck.txt
host echo '24.2 - Instance Partitions' >> apscheck.txt
host echo '===========================' >> apscheck.txt
host echo '  Used to Collect Data From ERP/EBS Source/Legacy instances ' >> apscheck.txt
host echo '  There should NOT be ANY extra partitions here with Free Flag = 1' >> apscheck.txt
host echo '' >> apscheck.txt
spool comm.lst
  select instance_id, free_flag, last_update_date
  from msc_inst_partitions;
spool off;

host chmod 777 comm.lst
host cat comm.lst >> apscheck.txt

host echo '' >> apscheck.txt
host echo '' >> apscheck.txt
host echo '24.3 - Instance Partition Data Integrity Check' >> apscheck.txt
host echo '===============================================' >> apscheck.txt
host echo 'Checking for Calendar Data which usually reveals if bad data is on the system' >> apscheck.txt
host echo '  For any instance name (like PRD) there should only be 1 INSTANCE_ID ' >> apscheck.txt
host echo '    example of Bad Data - we see here that we have instance_id 1 and 2021 ' >> apscheck.txt
host echo '                          and BOTH have Calendars with instance_code prefix of PRD' >> apscheck.txt
host echo '                          This shows that Steps in Section X of Note 137293.1 were not followed when creating a new instance code' >> apscheck.txt
host echo '             BAD DATA     CALENDAR_CODE  SR_INSTANCE_ID ' >> apscheck.txt
host echo '                           PRD:CAL_1                 1' >> apscheck.txt
host echo '                           PRD:CAL_1              2021' >> apscheck.txt
host echo '                           PRD:CAL_2                 1' >> apscheck.txt
host echo '                           PRD:CAL_2              2021' >> apscheck.txt
host echo '' >> apscheck.txt
host echo '               OK DATA     IF Both instances exist in MSC_APPS_INSTANCES above, then Two Different Instance Codes PRD and TST are OK' >> apscheck.txt
host echo '                             Otherwise, if only 1 row exists in MSC_APPS_INSTANCES, then the instance_id that is not there needs to be removed.' >> apscheck.txt
host echo '                             and customer should use Note 137293.1 to remove the old, obsolete data' >> apscheck.txt
host echo '                           CALENDAR_CODE  SR_INSTANCE_ID ' >> apscheck.txt
host echo '                           PRD:CAL_1                 1' >> apscheck.txt
host echo '                           TST:CAL_1              2021' >> apscheck.txt
host echo '                           PRD:CAL_2                 1' >> apscheck.txt
host echo '                           TST:CAL_2              2021' >> apscheck.txt
host echo '           Check the output below - every Instance_id should have a unique Instance_code and be listed above in Instance Partitions and MSC_APPS_INSTANCES output' >> apscheck.txt
host echo '             If there is not an instance_code prefix, then the instance should be inst_type = 3 - a Legacy instance' >> apscheck.txt
host echo '' >> apscheck.txt

spool comm.lst
select distinct calendar_code, sr_instance_id
from msc_calendar_Dates
order by calendar_code, sr_instance_id;
spool off;

host chmod 777 comm.lst
host cat comm.lst >> apscheck.txt


host echo '' >> apscheck.txt
host echo '25. Plans' >> apscheck.txt
host echo '=========' >> apscheck.txt

spool comm.lst
set lines 200
select
mp.COMPILE_DESIGNATOR "Plan Name",
mp.PLAN_ID "Plan ID",
mp.SR_INSTANCE_ID "Instance ID",
mtp.ORGANIZATION_CODE "Owning Org",
mp.PLAN_COMPLETION_DATE "Last Run Date",
decode (mp.PLAN_TYPE, 1, 'Manufacturing MRP', 2, 'Production MPS', 
                      3, 'Master MPP',4,'IO Plan', 5, 'Distribution DRP' ,
		      7, 'PS Production Schedule', 6, 'SNO Schedule',
                      8, 'Service Parts SPP', 9,'Service IO Plan',
                      101,'Rapid Plan MRP',102,'Rapid Plan MPS',103,'Rapid Plan MPP',plan_type)"Plan Type",
decode (md.PRODUCTION,1, 'Yes', 2, 'No', NULL, 'No') "Production Flag",
decode (md.LAUNCH_WORKFLOW_FLAG,1, 'Yes', 2, 'No', NULL, 'No') "Launch Workflow",
decode (md.INVENTORY_ATP_FLAG,1, 'Yes', 2, 'No', NULL, 'No') "ATP Plan",
mp.CURR_START_DATE "Start Date",
mp.CUTOFF_DATE "End Date"
from
msc_designators md,
msc_plans mp,
msc_trading_partners mtp
where
md.designator=mp.compile_designator and
md.sr_instance_id=mp.sr_instance_id and
mtp.sr_instance_id=mp.sr_instance_id and
md.sr_instance_id=mtp.sr_instance_id and
mtp.sr_tp_id=md.organization_id and
mtp.sr_tp_id=mp.organization_id and
mp.organization_id=md.organization_id
and mtp.partner_type = 3
ORDER BY "Plan Name";
spool off;
host chmod 777 comm.lst
host cat comm.lst >> apscheck.txt

prompt Checking Concurrent Managers, Please wait ...
host echo '' >> apscheck.txt
host echo '26. Concurrent Manager Check :' >> apscheck.txt
host echo '===============================' >> apscheck.txt
host echo '' >> apscheck.txt
host echo 'New instances where Snapshot fails or hangs typically do not have enough processes assigned' >> apscheck.txt
host echo '   On a new instance where planning hangs in the Memory Based Snapshot, then check that enough processes are available to run the plan ' >> apscheck.txt
host echo '   On a new instance where planning fails in the Memory Based Snapshot or Memory Based Planner, then check Section 17.1.1, 17.1.2 for correct compile of the 32 bit Planning executables ' >> apscheck.txt
host echo '' >> apscheck.txt
host echo 'Standard Manager is default manager for APS processes' >> apscheck.txt
host echo 'Manager for APS processes should have minimum of 16 processes with Default profiles ' >> apscheck.txt
host echo 'Check MRP: Snapshot Workers profile (If 5, then minimum target and actual should be 5 x2+6 = 16) ' >> apscheck.txt
host echo '' >> apscheck.txt
host echo 'APS Destination instances can usually have at least 20 Target/Actual workers without burdening system since ERP processes are not running -- MORE IS BETTER!' >> apscheck.txt
host echo '' >> apscheck.txt
host echo 'Primary and Secondary columns included for issues with RAC enabled instances, see Secion 9 to check RAC settings and Note 279156.1 for RAC setups' >> apscheck.txt

spool comm.lst
SELECT 
  substr(USER_CONCURRENT_QUEUE_NAME,1,40) Manager,
  MAX_PROCESSES "Target #",
  Running_processes "Actual #",
  NVL(NODE_NAME,'NULL') "Primary Node",
  NVL(Node_name2,'NULL') "Secondary Node"
FROM 
  FND_CONCURRENT_QUEUES_VL
WHERE 
  enabled_flag='Y'  
  order by max_processes desc;
spool off

host chmod 777 comm.lst
host cat comm.lst >> apscheck.txt


prompt searching XDF file version, Please wait ...
host echo '' >> apscheck.txt
host echo '27. XDF file versions :' >> apscheck.txt
host echo '=========================' >> apscheck.txt
host echo ' XDF files are java file replacement for ODF/LDT files for Table/view definitions ' >> apscheck.txt
host echo '' >> apscheck.txt

spool comm.lst
  select 'strings -a $MSC_TOP/patch/115/xdf/* | grep -i ''$Header:'''
  from   dual;
spool off

host chmod 777 comm.lst
host comm.lst >> apscheck.txt

prompt Get Java and XML versions for MSC, MRP and MSD ...

host echo ''                                 >> apscheck.txt
host echo '28. Java Class and Xml Versions ' >> apscheck.txt
host echo '=============================== ' >> apscheck.txt
host echo ''                                 >> apscheck.txt

host echo '     MSC                      ' >> apscheck.txt
host echo '     ======================== ' >> apscheck.txt
host echo ''                               >> apscheck.txt

host find $JAVA_TOP/oracle/apps/msc -name '*.class' -print > /tmp/mscjar.lst
host find $JAVA_TOP/oracle/apps/msc -name '*.xml' -print >> /tmp/mscjar.lst
host find $MSC_TOP/mds -name '*.xml' -print >> /tmp/mscjar.lst
host sed 's{^{strings -a {' /tmp/mscjar.lst > /tmp/msc1jar.lst
host sed 's{${ | grep -i '\''$Header'\''{' /tmp/msc1jar.lst > /tmp/mscversion.sh
host chmod +x /tmp/mscversion.sh
host /tmp/mscversion.sh >> apscheck.txt

host echo ''                               >> apscheck.txt
host echo '     MRP                      ' >> apscheck.txt
host echo '     ======================== ' >> apscheck.txt
host echo ''                               >> apscheck.txt

host find $JAVA_TOP/oracle/apps/mrp -name '*.class' -print > /tmp/mscjar.lst
host find $JAVA_TOP/oracle/apps/mrp -name '*.xml' -print >> /tmp/mscjar.lst
host sed 's{^{strings -a {' /tmp/mscjar.lst > /tmp/msc1jar.lst
host sed 's{${ | grep -i '\''$Header'\''{' /tmp/msc1jar.lst > /tmp/mscversion.sh
host chmod +x /tmp/mscversion.sh
host /tmp/mscversion.sh >> apscheck.txt

host echo ''                               >> apscheck.txt
host echo '     MSD                      ' >> apscheck.txt
host echo '     ======================== ' >> apscheck.txt
host echo ''                               >> apscheck.txt

host find $JAVA_TOP/oracle/apps/msd -name '*.class' -print > /tmp/mscjar.lst
host find $JAVA_TOP/oracle/apps/msd -name '*.xml' -print >> /tmp/mscjar.lst
host sed 's{^{strings -a {' /tmp/mscjar.lst > /tmp/msc1jar.lst
host sed 's{${ | grep -i '\''$Header'\''{' /tmp/msc1jar.lst > /tmp/mscversion.sh
host chmod +x /tmp/mscversion.sh
host /tmp/mscversion.sh >> apscheck.txt

host rm /tmp/mscjar.lst /tmp/msc1jar.lst /tmp/mscversion.sh

col owner            format a10   heading 'Owner';

host echo ''                                 >> apscheck.txt
host echo '29. Invalid Objects             ' >> apscheck.txt
host echo '=============================== ' >> apscheck.txt
host echo ''                                 >> apscheck.txt
host echo ' IGNORE any %SN and %MV objects showing invalid. These are Snapshot/Materialized Views and will compile and be valid when queried by the application' >> apscheck.txt
host echo ''                                 >> apscheck.txt

spool comm.lst
  select object_name, object_type, status, owner
  from dba_objects
where status != 'VALID'
order by owner, object_type;
spool off;

host chmod 777 comm.lst
host cat comm.lst >> apscheck.txt

host echo ''               >> apscheck.txt
host echo '30. References' >> apscheck.txt
host echo '==============' >> apscheck.txt
host echo '223026.1 - List of High Priority Patches for the APS Suite' >> apscheck.txt
host echo '207644.1 - Data Collections Fails - First Diagnostic Steps ' >> apscheck.txt
host echo '245974.1 - How to Use Debug Tools and Scripts for the APS Suite' >> apscheck.txt
host echo '118086.1 - APS Documentation Note' >> apscheck.txt
host echo '137293.1 - How to Manage APS Partitions in the MSC Schema' >> apscheck.txt
host echo '396009.1 - Database Initialization Parameters for Oracle Applications Release 12' >> apscheck.txt
host echo '216205.1 - Database Initialization Parameters for Oracle Applications 11i' >> apscheck.txt
host echo '279156.1 - RAC Configuration Setup For Running MRP Planning, APS Planning, and Data Collection Processes' >> apscheck.txt
host echo '266125.1 - RAC for GOP - Setups for Global Order Promising (GOP) When Using a Real Application Clusters (RAC) Environment ' >> apscheck.txt
host echo '246150.1 - APSCHECK.sql Provides Information Needed in Diagnosing GOP and APS Suite Issues' >> apscheck.txt
host echo '738008.1 - For information on the R12.x GMP Planning Detail Report' >> apscheck.txt
host echo '762621.1 - For information on Discoverer Planning Detail Report' >> apscheck.txt
host echo '421097.1 - R12 - Known Issues with APS - Advanced Planning and Scheduling ' >> apscheck.txt
host echo '412702.1 - FAQ -  Advanced Planning and Scheduling (APS) - Getting Started With R12' >> apscheck.txt
host echo '741964.1 - R12.1 FAQ - Advanced Planning and Scheduling (APS) - Getting Started With R12.1 - R12.SCP_PF.B' >> apscheck.txt
host echo '746824.1 - ALERT! - Value Chain Planning (aka Advanced Planning - APS) Installation Requirements and Critical Patches for 12.1.1' >> apscheck.txt



host echo ''                              >> apscheck.txt
host echo 'Report completed at Date/Time' >> apscheck.txt
host date '+%d/%m/%y %H:%M:%S'            >> apscheck.txt
host echo ''                              >> apscheck.txt
host echo 'End of Diagnostic Report'      >> apscheck.txt
host echo ''                              >> apscheck.txt
host echo '   Most sections of the output include comments on critical setups and what to check in each area ' >> apscheck.txt
host echo ''                              >> apscheck.txt
host echo ' Check the size of the output: If complete and run correctly it should exceed 1.2 MB ' >> apscheck.txt
host echo '   If smaller than 1.2 MB, then review the instructions for executing this script in Note 246150.1 ' >> apscheck.txt
host echo '   AND review each section of the output to make sure it contains data. '  >> apscheck.txt
host echo ''                              >> apscheck.txt

host echo 'Report completed at Date/Time'  
host date '+%d/%m/%y %H:%M:%S'             
host echo ''                               
host echo 'End of Diagnostic Report'       
host echo ''                               
host echo '   Most sections of the output include comments on critical setups and what to check in each area '  
host echo ''                               
host echo ' Check the size of the output: If complete and run correctly it should exceed 1.4 MB '  
host echo '   If smaller than 1.4 MB, then review the instructions for executing this script in Note 246150.1 '  
host echo '   AND review each section of the output to make sure it contains data. '  
host echo '   AND compare to the example output files included in the ZIP file with the script.  '


host rm comm.lst

-- exit;

