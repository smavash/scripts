Initialization SQL Statement - Custom
BEGIN 
FND_CTL.FND_SESS_CTL('','', '', 'TRUE','','ALTER SESSION SET TRACEFILE_IDENTIFIER='||''''||'SLAVA' ||''''||' EVENTS ='||''''||' 10046 TRACE NAME CONTEXT FOREVER, LEVEL 12'||''''); 
END;


FND: Debug Log Filename for Middle-Tier
FND: Debug Log Level
FND: Debug Log Module
FND: Debug Log Enabled