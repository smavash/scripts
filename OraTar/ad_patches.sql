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
