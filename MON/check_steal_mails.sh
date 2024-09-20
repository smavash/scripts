#!/bin/bash

#USERS=amith@eds.co.il,anatolyr@eds.co.il,irinat@eds.co.il
USERS=anatolyr@eds.co.il

cd /u01_share/DBA/scripts/Clone/run/inventory/XML/appl

#echo $PWD

for i in `ls -l | grep "^d"|awk '{print $9}'`  
do 
#echo $i  
cd $i   
grep wfprodusr *.xml  
if [ $? -eq 0 ]; 
  then  echo "The XML file of $i ENV contain wfprodusr account name !!!"|mailx -s "I find an XML with wfprodusr account name !!!" $USERS
fi
cd .. 
done
