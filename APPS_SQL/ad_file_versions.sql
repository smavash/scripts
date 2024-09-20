SELECT fi.file_id, filename, version
  FROM apps.ad_files fi, apps.ad_file_versions ve
 WHERE filename LIKE 'apgdfalb.pls'
   AND ve.file_id = fi.file_id
   AND version = (SELECT MAX(version)
                    FROM apps.ad_file_versions ven
                   WHERE ven.file_id = fi.file_id)
