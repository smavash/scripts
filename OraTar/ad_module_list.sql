select a.application_id,
       a.application_short_name,
       t.application_name,
       p.status,
       p.patch_level
  from FND_APPLICATION A, FND_PRODUCT_INSTALLATIONS P, FND_APPLICATION_TL T
 WHERE A.APPLICATION_ID = P.APPLICATION_ID
   AND A.APPLICATION_ID = T.APPLICATION_ID
   AND T.LANGUAGE = 'US'
/
