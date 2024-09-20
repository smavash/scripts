SELECT FILE_FORMAT_CODE,
       MIME_TYPE,
       CREATED_BY,
       CREATION_DATE,
       LAST_UPDATED_BY,
       LAST_UPDATE_DATE,
       LAST_UPDATE_LOGIN,
       DESCRIPTION,
       ALLOW_CLIENT_ENCODING
  FROM FND_MIME_TYPES_VL
 WHERE 
 (DESCRIPTION = 'Browser')
 order by file_format_code, mime_type;


SELECT ROWID,
       ROW_ID,
       FILE_FORMAT_CODE,
       MIME_TYPE,
       CREATED_BY,
       CREATION_DATE,
       LAST_UPDATED_BY,
       LAST_UPDATE_DATE,
       LAST_UPDATE_LOGIN,
       DESCRIPTION,
       ALLOW_CLIENT_ENCODING
  FROM FND_MIME_TYPES_VL
 WHERE (DESCRIPTION = 'Printer Control Language')
 order by file_format_code, mime_type