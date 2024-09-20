select substr(name,1,30) name , substr(value,1,15) value 
          from v$parameter 
         where name like '%arallexl%';   
         
         select *  from  V$PX_PROCESS_SYSSTAT;

SELECT name, value
  FROM v$sysstat
  WHERE name like '%direct%'
;
