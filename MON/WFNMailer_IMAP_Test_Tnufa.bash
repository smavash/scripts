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
echo a01 login wfprodusr wfprod01
sleep 3
echo a02 select "INBOX"
#echo a02 select "DISCARD"
sleep 3
echo a03 logout
} | telnet wmrch10.tnuva.co.il 143 1>/u01_share/DBA/scripts/MON/wfnm_Tnufa.log 

COUNT=`cat /u01_share/DBA/scripts/MON/wfnm_Tnufa.log|grep EXIST|awk '{print $2}'`

#echo COUNT1=$COUNT

if [ X$COUNT == 'X' ]; then
   COUNT=0
fi

#echo COUNT2=$COUNT

if [ $COUNT -lt 4 ]; then
    echo "Notification Mailer(IMAP) of ERP Tnufa may be work properly. There are only $COUNT new eMails in INBOX of wfprodusr account."
else
   echo "Notification Mailer(IMAP) of ERP Tnufa has a problem. There are $COUNT new eMails in INBOX of wfprodusr account."
   echo "Notification Mailer(IMAP) of ERP Tnufa has a problem. There are $COUNT new eMails in INBOX of wfprodusr account."|mailx -s "Tnufa Notification Mailer(IMAP) doesn't work properly." $USERS
  # logger -t ORA_CKERP -p user.err -i "Notification Mailer(IMAP) of ERP Tnufa has a problem. There are $COUNT new eMails in INBOX of wfprodusr account. Call DBA at the Morning"
fi

#echo "Test IMAP connection done "

