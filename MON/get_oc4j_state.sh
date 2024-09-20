#!/bin/sh

header_string="$Header: adoacorectl_sh_1013.tmp 120.13 2008/01/30 07:30:48 mmanku ship $"
prog_version=`echo "$header_string" | awk '{print $3}'`
program=`basename $0`
usage="\t$program {start|stop|status}"

printf "\nYou are running $program version $prog_version\n\n"

#
# Check the number of parameters passed
#

if [ $# -lt 1 ]; then
   printf "\n$program: too few arguments specified.\n\n"
   printf "$usage\n\n"
   exit 1;
fi

#
# Set ORAENV_FILE to 10.1.3 Oracle Home Environment File
#

ORAENV_FILE="/app/appl/PROD/inst/apps/PROD_uapapp1/ora/10.1.3/PROD_uapapp1.env"


#
#  Check the existence of ORAENV_FILE
#

if [ ! -f "$ORAENV_FILE" ];
then
   printf "Oracle environment file for 1013 ORACLE_HOME not found.\n"
     if [ -f "$LOGAP" ]; then
       printf "\n`date +%D-%T` :: Oracle environment file for 1013 ORACLE_HOME not found.\n" >> $LOGAP
     fi
   exit 1;
else
   . $ORAENV_FILE
fi



control_code="$1"

#
# Check the parameter passed
#

if [ $control_code = "status" ]; then
               		$LINUX32 /app/appl/PROD/inst/apps/PROD_uapapp1/ora/10.1.3/opmn/bin/opmnctl $control_code -l -noheaders 2>&1 | tee -a $LOGAP  

	PROCSTATE=`$LINUX32 /app/appl/PROD/inst/apps/PROD_uapapp1/ora/10.1.3/opmn/bin/opmnctl $control_code -l -noheaders 2>&1 | tee -a $LOGAP|grep Alive|wc -l`
         exit_code=$?;

else

      printf "\n`date +%D-%T` ::  you have specified option other than"  >> $LOGAP
      printf "\n                   start,stop and status.Running"  >> $LOGAP
      printf "\n                  $program with specified option."  >> $LOGAP
      exit_code=$?;


fi


echo $PROCSTATE
if [ $PROCSTATE -le 3 ];
then

echo " Some OC4J procs are down"
logger -t ORA-CKERP -p user.err -i "##### Critical ALERT:  Some OC4J proc is stoped in $TWO_TASK. Please Call DBA Team . ########"
fi

