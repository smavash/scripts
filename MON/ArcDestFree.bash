#!/bin/bash -x
#==============================================================================
# Watch Dog on Production DB archive log destination directory
#------------------------------------------------------------------------------
#
#         Created By          Date               Reference
#     -------------------   ----------     ---------------------------
#      kruzik@gmail.com    28/07/2010    
#
#         Updated By          Date               Reference
#     ------------------   ----------  ---------------------------
#==============================================================================
#/u01_share/DBA/scripts/MON/

#-- 1 -- Initialize environment
#--------------------------------------------
SCRIPT_HOME="$(dirname "$(readlink -f "$0")")"
SCRIPT_NAME=`basename $0`
LOGFILE="$SCRIPT_HOME/${SCRIPT_NAME/.bash/}.log"
LOCKFILE="$SCRIPT_HOME/${SCRIPT_NAME/.bash/}.lck"
ARC_DEST=/db/oraarch/PROD
ARC_DEST_GZIP=/db/oraarch/PROD/bk_gzip

ARC_KEEP_DAYS=1  #-- Keep Archive log files for the last three days
FS_TRASHOLD=55   #-- Compress files when FS utilization over 55%

echo "================================================================" >> $LOGFILE
echo "                 `date`">> $LOGFILE
echo "----------------------------------------------------------------" >> $LOGFILE
if [ -e $LOCKFILE ]; then
  echo "Script is already running, or failed, but lock exists! Exiting..." | tee -a $LOGFILE
  exit 1
else
  touch $LOCKFILE
fi

#-- 2 -- Compress archive logs if needed
#--------------------------------------------
echo "Checking the archive log destination utilization ..." | tee -a $LOGFILE
FS_USAGE=`df -klP $ARC_DEST | grep -iv filesystem | awk '{print $1" "$5" "$6" "$4}' | awk '{print $2}'`
echo "$FS_USAGE used for $ARC_DEST" | tee -a $LOGFILE 
if [ ${FS_USAGE/%"%"/} -gt $FS_TRASHOLD ] ; then
  echo "Compressing files ...."        | tee -a $LOGFILE
  FILES=$((`ls -1 $ARC_DEST/*.arc | wc -l0`-1))
  for file in `ls -1tr $ARC_DEST/*.arc| head -$FILES`
  do  
    echo "Compressing file $file ..."  | tee -a $LOGFILE
    #####  mv $ARC_DEST/*.arc.gz $ARC_DEST_GZIP/.
	ls -ltr

  done
fi


echo "================================================================" >> $LOGFILE
echo >> $LOGFILE
rm $LOCKFILE
exit 0  
