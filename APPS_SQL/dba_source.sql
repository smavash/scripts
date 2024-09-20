select * from dba_source d1
where d1.name  not like 'XX%'
and text like upper('%GL_JE_LINES%NOLOG%')