#!/bin/bash

USERS=amith@eds.co.il,anatolyr@eds.co.il,irinat@eds.co.il

cd /app/appl/PROD/inst/apps/PROD_uapapp1/logs/appl/conc/log

LOG_FILE=`ls -rtl FNDOPP*|tail -1|awk '{print $9}'`

#echo LOG_FILE=$LOG_FILE

STR_CNT=`grep "Java heap space" $LOG_FILE|wc -l`

#echo STR_CNT=$STR_CNT

if [ $STR_CNT -eq 0  ];then
   echo "OPP Process is OK"
else
   echo "OPP Process FAILED"
  logger -t ORA_CKERP -p user.err -i "##### OPP Concurrent Manager(XML Reporting) FAILED. Call to Oracle DBA at the Morning.  ######## "
  echo "##### OPP Concurrent Manager(XML Reporting) FAILED . Please restart Output Post Processor Concurrent Manager #####"|mailx -s " OPP Process FAILED" $USERS
fi


