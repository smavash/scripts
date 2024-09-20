#!/bin/ksh

#========================================================================================
#  Memory Utilization of Oracle Instance  
#----------------------------------------------------------------------------------------
#         Created By                    Date               Reference
#     ---------------------------   -----------   ---------------------------
#     S l a v a   M a v a s h e v    07/04/2013       Initial Creation
#
#         Updated By          Date               Reference
#     ------------------   ----------  ---------------------------
#
#
#----------------------------------------------------------------------------------------
#    Script Location : /u01_share/DBA/scripts/MON 
#       *     *     *   *    *        command to be executed
#       -     -     -   -    -     ------------------------------------------------------  
#       |     
#       +------------- oracle_mem_usage.sh
#
#========================================================================================


#Verify the parameter count
if [ $# -lt 2 ]; then
   echo "Usage: $0 ORACLE_SID [long|columnar]
   echo " e.g.: $0 PROD columnar
   exit 1
fi

##################################
# Environment setup
##################################

export ORACLE_SID=$1
output_type=$2


##################################
# running calculations...
##################################

export pids=`ps -elf|grep ora_pmon_$ORACLE_SID|grep -v grep|awk '{print $4}'`

export countcon=`print "$pids"|wc -l`

if [ "`uname -a|cut -f1 -d' '`" = "Linux" ]; then
   export tconprivsz=$(pmap -x `print "$pids"`|grep " rw"|grep -Ev "shmid|deleted"|awk '{total +=$2};END {print total}')
else
   export tconprivsz=$(pmap -x `print "$pids"`|grep " rw"|grep -v "shmid"|awk '{total +=$2};END {print total}')
fi

export avgcprivsz=`expr $tconprivsz / $countcon`

if [ "`uname -a|cut -f1 -d' '`" = "Linux" ]; then
   export instprivsz=$(pmap -x `ps -elf|grep ora_.*_$ORACLE_SID|grep -v grep|awk '{print $4}'`|grep " rw"|grep -Ev "shmid|deleted"|awk '{total +=$2};END {print total}')
else
   export instprivsz=$(pmap -x `ps -elf|grep ora_.*_$ORACLE_SID|grep -v grep|awk '{print $4}'`|grep " rw"|grep -v "shmid"|awk '{total +=$2};END {print total}')
fi

if [ "`uname -a|cut -f1 -d' '`" = "Linux" ]; then
   export instshmsz=$(pmap -x `ps -elf|grep ora_pmon_$ORACLE_SID|grep -v grep|awk '{print $4}'`|grep -E "shmid|deleted"|awk '{total +=$2};END {print total}')
else
   export instshmsz=$(pmap -x `ps -elf|grep ora_pmon_$ORACLE_SID|grep -v grep|awk '{print $4}'`|grep "shmid"|awk '{total +=$2};END {print total}')
fi

export binlibsz=$(pmap -x `ps -elf|grep ora_pmon_$ORACLE_SID|grep -v grep|awk '{print $4}'`|grep -v " rw"|  awk '{total +=$2};END {print total}')

export sumsz=`expr $tconprivsz + $instprivsz + $instshmsz + $binlibsz`

if [[ "$output_type" = "long" ]]; then
   echo memory used by Oracle instance $ORACLE_SID as of `date`
   echo
   echo "Total shared memory segments for the instance..................: "$instshmsz KB
   echo "Shared binary code of all oracle processes and shared libraries: "$binlibsz KB
   echo "Total private memory usage by dedicated connections............: "$tconprivsz KB
   echo "Total private memory usage by instance processes...............: "$instprivsz KB
   echo "Number of current dedicated connections........................: "$countcon
   echo "Average memory usage by database connection....................: "$avgcprivsz KB
   echo "Grand total memory used by this oracle instance................: "$sumsz KB
   echo
elif [ "$output_type" = "columnar" ]; then
   printf "%17s %10s %10s %10s %10s %10s %10s %10s %10s\n" "date" "ORACLE_SID" "instshmsz" "binlibsz" "tconprivsz" "instprivsz" "countcon" "avgcprivsz" "sumsz"
   echo "----------------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ----------"
   printf "%17s %10s %10s %10s %10s %10s %10s %10s %10s\n" "`date +%y/%m/%d_%H:%M:%S`" $ORACLE_SID $instshmsz $binlibsz $tconprivsz $instprivsz $countcon $avgcprivsz $sumsz
fi;
