cd /u01_share/DBA/scripts/MON/
##################################################################################### 
#### Start of script for EBS 12.1.x 
##################################################################################### 
( 
# pick up files which have been modified in the last 1 day only 
HowManyDaysOld=1 
echo "Picking up files which have been modified in the last ${HowManyDaysOld} days" 
set -x 
find $LOG_HOME/ora/10.1.3 -type f -mtime -${HowManyDaysOld} > m.tmp 
find $LOG_HOME/appl/admin -type f -mtime -${HowManyDaysOld} >> m.tmp 
find $LOG_HOME/appl/rgf -type f -mtime -${HowManyDaysOld} >> m.tmp 
zip -r AppsLogFiles_`hostname`_`date '+%m%d%y'`.zip -@ < m.tmp 
rm m.tmp 
) 2>&1 | tee mzLogZip.out 
##################################################################################### 
#### End of script 
##################################################################################### 
