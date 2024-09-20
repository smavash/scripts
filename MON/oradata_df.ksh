#!/bin/ksh
#set -x

#. ~oraday1/.bash_profile

FILE=/var/adm/monrep/oradata_df.txt

DATE=`date '+%d-%m-%Y %H:%M'`

DF=`df -k | grep oradata|awk '{print $2}'`

echo "$DF   $DATE" >> $FILE
