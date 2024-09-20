#!/bin/ksh

echo "Starting ..."

while true
do
cd /app/appl/PROD/apps/apps_st/comn/webapps/oacore/html/cabo/styles/cache
COUNT=`ls -l *.css|wc -l`
if (( $COUNT > 0 ));then 
  rm  *.css
  #echo "File Exist"
fi
#echo "Sleeping ..."
sleep 10
done
