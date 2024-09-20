#!/bin/ksh
#set -x

. ~oraprd/.bash_profile

## DATA_DIR=/db/oradata/PROD/data
DATA_DIR=/db/oradata/PROD/data/
LOG_DIR=/u01_share/DBA/scripts/MON/DBV_Log
##ADDRESS_LIST=anatolyr@eds.co.il,amith@eds.co.il
ADDRESS_LIST=anatolyr@eds.co.il

rm -f $LOG_DIR/*.log

cd $DATA_DIR

for i in `ls -1|grep -v log0|grep -v cntrl0`
do
echo "Now checking $i file, please be patient ..."
dbv USERID="/as sysdba"  FILE=$i LOGFILE=$LOG_DIR/$i.log
grep "Total Pages Marked Corrupt" $LOG_DIR/$i.log > $LOG_DIR/TotalPagesMarkedCorrupt.log
done

x=0
for i in `cat TotalPagesMarkedCorrupt.log | awk '{print $6}'` 
do x=`expr $x + $i` 
## echo $x 
done

if [ $x -eq 0 ]; then 
 ##  echo "There are NO Pages Marked Corrupt in the Database Files of DAY1"
   echo "There are NO Pages Marked Corrupt in the Database Files of DAY1" | mailx -s "DBV check of DAY1" $ADDRESS_LIST
else
 ##  echo "There are $x Pages Marked Corrupt in the Database Files of DAY1"
   echo "There are $x Pages Marked Corrupt in the Database Files of DAY1" | mailx -s "DBV check of DAY1" $ADDRESS_LIST
fi
