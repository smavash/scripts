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
         ad_applied_patches e
   WHERE a.bug_id = b.bug_id
     AND b.patch_run_id = c.patch_run_id
     AND c.patch_driver_id = d.patch_driver_id
     AND d.applied_patch_id = e.applied_patch_id
--     and e.patch_name = 'merged'
-- AND a.bug_number like '&p%';

/* AND a.bug_number    in    
     (
'8730143',
'8730143',
'9377631',
'8854962',
'8854962',
'9366077',
'9366077',
'8815071',
'8815071',
'9370071'
     )
*/

and e.creation_date > TO_DATE('26-05-2010 09:00:00', 'DD-MM-YYYY HH24:MI:SS')
--and e.creation_date < TO_DATE('26-04-2009 14:00:00', 'DD-MM-YYYY HH24:MI:SS')
-- and e.creation_date > sysdate - 30
   ORDER BY 3 ;
