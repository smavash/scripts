/*update FND_CONCURRENT_REQUESTS f1
set 
    
    hold_flag = 'Y'
--    , phase_code = 'P'
--    , status_code = 'I'
    , COMPLETION_TEXT = 'Hold Done by DBA in PROD'
    , LAST_UPDATE_DATE       = sysdate
    , LAST_UPDATED_BY        = 1111  
where 
   phase_code = 'P' 
   --COMPLETION_TEXT = 'Hold Done by DBA in PRD1'
;
*/

select hold_flag,COMPLETION_TEXT,LAST_UPDATE_DATE,LAST_UPDATED_BY,LAST_UPDATED_BY
from  FND_CONCURRENT_REQUESTS
where 
    hold_flag = 'Y' 
    AND COMPLETION_TEXT = 'Hold Done by DBA in PROD'
    ;
    
    
update FND_CONCURRENT_REQUESTS f1
set 
      hold_flag = 'N'
--    , phase_code = 'P'
--    , status_code = 'I'
    , COMPLETION_TEXT = 'Release Done by DBA in PROD'
    , LAST_UPDATE_DATE       = sysdate
    , LAST_UPDATED_BY        = 1111  
where 
    hold_flag = 'Y' 
    AND COMPLETION_TEXT = 'Hold Done by DBA in PROD'
