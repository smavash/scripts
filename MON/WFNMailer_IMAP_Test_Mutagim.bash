#!/bin/bash 
#==============================================================
#    Monitor Oracle IMAP Workflow Notification Services
#
#    Created By          Date               Refrence
# ------------------   ----------  ----------------------------
#
#    Updated By          Date               Refrence
# ------------------   ----------  ----------------------------
#
#==============================================================

USERS=amith@eds.co.il,anatolyr@eds.co.il,irinat@eds.co.il
#USERS=anatolyr@eds.co.il

{
sleep 5
echo a01 login mutapplprd Mutappl-01
sleep 3
echo a02 select "INBOX"
#echo a02 select "DISCARD"
sleep 3
echo a03 logout
} | telnet wmrch10.tnuva.co.il 143 1>/u01_share/DBA/scripts/MON/wfnm.log 

COUNT=`cat /u01_share/DBA/scripts/MON/wfnm.log|grep EXIST|awk '{print $2}'`

#echo $COUNT

if [ $COUNT -eq 0 ]; then
    echo "Notification Mailer(IMAP) of ERP Mutagim may be work properly. There are no new eMails in INBOX of mutapplprd account."
else
   echo "Notification Mailer(IMAP) of ERP Mutagim has a problem. There are $COUNT new eMails in INBOX of mutapplprd account." 
   echo "THE DATE IS : `date` . There are $COUNT new eMails in INBOX of mutapplprd account. Starting Restart_WF_Mailer.bash script ..." >> /u01_share/DBA/scripts/MON/WFNMailer_IMAP_Test_Mutagim.log
  ### echo "Notification Mailer(IMAP) of ERP Mutagim has a problem. There are $COUNT new eMails in INBOX of mutapplprd account."|mailx -s "Mutagim Notification Mailer(IMAP) doesn't work properly." $USERS
   /u01_share/DBA/scripts/MON/Restart_WF_Mailer.bash
 ###  logger -t ORA_CKERP -p user.err -i "Notification Mailer(IMAP) of ERP Mutagim has a problem. There are $COUNT new eMails in INBOX of mutapplprd account. Call DBA at the Morning"
   {
   sleep 25
   echo a01 login mutapplprd Mutappl-01
   sleep 3
   echo a02 select "INBOX"
   #echo a02 select "DISCARD"
   sleep 3
   echo a03 logout
   } | telnet wmrch10.tnuva.co.il 143 1>/u01_share/DBA/scripts/MON/wfnm.log

   COUNT=`cat /u01_share/DBA/scripts/MON/wfnm.log|grep EXIST|awk '{print $2}'`
   if [ $COUNT -ne 0 ]; then
      echo "Notification Mailer(IMAP) of ERP Mutagim has a problem. There are $COUNT new eMails in INBOX of mutapplprd account."|mailx -s "Mutagim Notification Mailer(IMAP) doesn't work properly." $USERS
   fi
fi

#echo "Test IMAP connection done "

