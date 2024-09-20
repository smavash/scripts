select program_name,count(*)
from FND_LOBS
where expiration_date is not NULL
group by program_name;

select *
from FND_LOBS
where expiration_date is NULL
and program_name is null
and upload_date  > sysdate -30
group by program_name;



select round(sum(bytes)/1024/1024/1024) SIZE_GB, s.segment_name, s.segment_type
  from dba_lobs l, dba_segments s
 where s.segment_type = 'LOBSEGMENT'
   and l.table_name = 'FND_LOBS'
   and s.segment_name = l.segment_name
 group by s.segment_name, s.segment_type;




select program_name,
       round(sum(dbms_lob.getlength(FILE_DATA)) / 1024 / 1024, 0) "Size(M)"
  from APPS.fnd_LOBS
 where expiration_date is NULL
 and upload_date > sysdate -720
 --and program_name is null
 group by program_name
 order by 2 desc;



select sum(dbms_lob.getlength(FILE_DATA))/1024/1024/1024 from FND_LOBS;




select
  min(round(dbms_lob.getlength (FILE_DATA)/1024,0)) "Min Size(K)",
  round(avg(round(dbms_lob.getlength (FILE_DATA)/1024,0)),0) "Avg Size(K)",
  max(round(dbms_lob.getlength (FILE_DATA)/1024,0)) "Max Size(K)"
from APPS.fnd_LOBS;