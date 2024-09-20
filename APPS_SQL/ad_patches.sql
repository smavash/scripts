select * from v$database;

select * from dba_source 
where upper(text) like upper ('%$Header:%xlajelns%') ;
select * from ad_bugs where bug_number like '%8319065%'
or bug_number like '%13717941%'; 



select bug_number, decode(bug_number,
'7237006', 'R12.ATG_PF.A.DELTA.6',
'6594849', 'R12.ATG_PF.A.DELTA.5',
'6272680', 'R12.ATG_PF.A.delta.4',
'6077669', 'R12.ATG_PF.A.delta.3',
'5917344', 'R12.ATG_PF.A.delta.2',
'8919491', 'R12.ATG_PF.B.3', 
'7651091', 'R12.ATG_PF.B.2', 
'7307198', 'R12.ATG_PF.B.1' 
) n_patch, last_update_date 
FROM ad_bugs 
WHERE bug_number 
IN ('7237006','6594849','6272680','6077669','5917344','8919491','7651091','7307198');


SELECT 
  --  DISTINCT RPAD(a.bug_number, 11) || RPAD(e.patch_name, 11) || RPAD(TRUNC(c.end_date), 12) || RPAD(b.applied_flag, 4)
--    DISTINCT RPAD(a.bug_number, 11)|| RPAD(e.patch_name, 11)
DISTINCT 
e.patch_name 
--,a.bug_number
,d.patch_abstract
,c.creation_date 
, c.patch_top    
--DISTINCT a.bug_number
--*
    FROM ad_bugs            a,
         ad_patch_run_bugs  b,
         ad_patch_runs      c,
         ad_patch_drivers   d,
         ad_applied_patches e   WHERE a.bug_id = b.bug_id
     AND b.patch_run_id = c.patch_run_id
     AND c.patch_driver_id = d.patch_driver_id
     AND d.applied_patch_id = e.applied_patch_id
--     and e.patch_name = 'merged'
AND a.bug_number like     '&p%';

/* AND a.bug_number   in    
  (
'9881400',
'10393119',
'10393119',13790398
'9414219',
'9414219',
'9379330',
'10426797',
'10432396',
'10300045'
     )

*/
and e.creation_date > TO_DATE('01-03-2014 00:30:00', 'DD-MM-YYYY HH24:MI:SS')
--and e.creation_date < TO_DATE('05-02-2013 14:00:00', 'DD-MM-YYYY HH24:MI:SS')
-- and e.creation_date > sysdate - 30
   ORDER BY 3 ;


SELECT 
distinct B.ORIG_PATCH_NAME AS "PATCH NAME",
A.NAME AS "NODE",
TO_CHAR(C.START_DATE, 'DD-MON-YYYY HH24:MI:SS') AS "START DATE", 
--Patch_abstract, 
--c.*
B.DRIVER_FILE_NAME AS "FILE NAME",
B.ORIG_PATCH_NAME AS "PATCH NAME",
B.PLATFORM AS "PLATFORM",
D.LANGUAGE AS "LANG",
C.SUCCESS_FLAG AS "SUCC",
TO_CHAR(C.END_DATE, 'DD-MON-YYYY HH24:MI:SS') AS "END DATE"
FROM APPS.AD_APPL_TOPS A,
APPS.AD_PATCH_DRIVERS B,
APPS.AD_PATCH_RUNS C,
APPS.AD_PATCH_DRIVER_LANGS D
WHERE B.PATCH_DRIVER_ID = C.PATCH_DRIVER_ID
AND C.APPL_TOP_ID = A.APPL_TOP_ID
AND D.PATCH_DRIVER_ID = C.PATCH_DRIVER_ID
 AND B.ORIG_PATCH_NAME LIKE '%&PATCH_NUMBER%'
--and C.START_DATE > TO_DATE('4-05-2010 00:00:00', 'DD-MM-YYYY HH24:MI:SS')
-- and C.START_DATE > sysdate - 17
-- ORDER BY 3, 7;







  --==============================================================================
-- ©Kruzik: kruzik@gmail.com
--      OEBS R12 Installed Patches List
--==============================================================================
WITH INSTALLED_PATCHES 
AS ( select aap.applied_patch_id
           ,aap.patch_name||decode(ab.baseline_name, null, '', '.')||ab.baseline_name         PATCH_NAME
           ,apd.patch_abstract          PATCH_DESCRIPTION
           ,apdl.language
           ,apd.merged_driver_flag      MERGED
           ,aap.patch_name              BUNDLED_IN
           ,min(apr.start_date)         START_DATE
           ,max(apr.end_date)           COMPLETION_DATE
           ,apr.patch_top
       from APPLSYS.ad_appl_tops          aat
           ,APPLSYS.ad_patch_driver_langs apdl
           ,APPLSYS.ad_patch_runs         apr
           ,APPLSYS.ad_patch_drivers      apd
           ,APPLSYS.ad_applied_patches    aap
           ,APPLSYS.ad_bugs               ab
      where apr.appl_top_id        = aat.appl_top_id
        and apr.patch_driver_id    = apd.patch_driver_id
        and apd.applied_patch_id   = aap.applied_patch_id
        and apd.patch_driver_id    = apdl.patch_driver_id
        and ab.bug_number(+)      = aap.patch_name
        and apd.merged_driver_flag = 'N'
   group by aap.applied_patch_id
           ,aap.patch_name||decode(ab.baseline_name,null,'','.')||ab.baseline_name
           ,apd.patch_abstract
           ,apdl.language
           ,apd.merged_driver_flag           
           ,aap.patch_name
           ,apr.patch_top
 UNION
     select aap.applied_patch_id
           ,ab.bug_number||decode(ab.baseline_name,null,'','.')||
            ab.baseline_name            PATCH_NAME
           ,acp.patch_abstract          PATCH_DESCRIPTION
           ,apdl.language
           ,apd.merged_driver_flag      MERGED      
           ,aap.patch_name              BUNDLED_IN
           ,min(apr.start_date)         START_DATE    
           ,max(apr.end_date)           COMPLETION_DATE
           ,apr.patch_top
       from applsys.ad_applied_patches    aap
           ,applsys.ad_patch_drivers      apd
           ,applsys.ad_patch_driver_langs apdl
           ,applsys.ad_comprising_patches acp
           ,applsys.ad_patch_runs         apr
           ,applsys.ad_bugs               ab
      where aap.applied_patch_id   = apd.applied_patch_id
        and apd.patch_driver_id    = acp.patch_driver_id
        and apr.patch_driver_id    = apd.patch_driver_id
        and apd.patch_driver_id    = apdl.patch_driver_id  
        and acp.bug_id             = ab.bug_id
        and apd.merged_driver_flag = 'Y'
   group by aap.applied_patch_id
           ,ab.bug_number||decode(ab.baseline_name,null,'','.')||ab.baseline_name
           ,acp.patch_abstract
           ,apdl.language
           ,apd.merged_driver_flag
           ,aap.patch_name
           ,apr.patch_top
           
           
   order by 5      
  )
-------------------------------------------------------------------------------
--       The Query Starts Here:
-------------------------------------------------------------------------------
SELECT * 
  FROM INSTALLED_PATCHES ip
 WHERE 
ip.BUNDLED_IN = '&p';
-- ip.start_date > TO_DATE('19-10-2010 10:00:00', 'DD-MM-YYYY HH24:MI:SS') ;
 
 /*
 and
 ip.COMPLETION_DATE < TO_DATE('31-08-2009 12:10:00', 'DD-MM-YYYY HH24:MI:SS')
 
--   AND merged='Y'

*/

