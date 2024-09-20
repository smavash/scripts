-- Create database link by Slava for Inbal
create database link APPS_TO_DAY1.TNUVA.CO.IL
  connect to apps identified by apps
  using '(DESCRIPTION=(ADDRESS_LIST=(ADDRESS=(PROTOCOL=TCP)(Host=uldev02.tnuva.co.il)(Port=1571)))(CONNECT_DATA=(SID=DAY1)))';
  
  
  
  
  -- Create database link 
create public database link TOPROD
  connect to APPS identified by apps
  using '(DESCRIPTION=(ADDRESS=(PROTOCOL=tcp)(HOST=uldev02.tnuva.co.il)(PORT= 1601))(CONNECT_DATA=(SID=BKR)))';


-- Create database link 
create database link TO_BIDWH11G.TNUVA.CO.IL
  connect to DWHUSER identified by DWHUSER
  using '(DESCRIPTION=(ADDRESS_LIST=(ADDRESS=(PROTOCOL=TCP)(Host=ubierp1.tnuva.co.il)(Port=1565)))(CONNECT_DATA=(SID = ORABIPOC)))';



create database link EBCC_AM_AGENT_LINK
  connect to AM_AGENT identified by am_Agent
  using '(DESCRIPTION=(ADDRESS_LIST=(ADDRESS=(PROTOCOL=TCP)(Host=uldev02.tnuva.co.il)(Port=1571)))(CONNECT_DATA=(SID = EBCC)))';

