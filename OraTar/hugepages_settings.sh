#!/bin/bash -x
#
# hugepages_settings.sh
#
# Linux bash script to compute values for the
# recommended HugePages/HugeTLB configuration
#
# Note: This script does calculation for all shared memory
# segments available when the script is run, no matter it
# is an Oracle RDBMS shared memory segment or not.
#
# This script is provided by Doc ID 401749.1 from My Oracle Support 
# http://support.oracle.com

# Welcome text
echo "
This script is provided by Doc ID 401749.1 from My Oracle Support 
(http://support.oracle.com) where it is intended to compute values for 
the recommended HugePages/HugeTLB configuration for the current shared 
memory segments. Before proceeding with the execution please make sure 
that:
 * Oracle Database instance(s) are up and running
 * Oracle Database 11g Automatic Memory Management (AMM) is not setup 
   (See Doc ID 749851.1)
 * The shared memory segments can be listed by command:
     # ipcs -m

Press Enter to proceed..."

read

# Check for the kernel version
KERN=`uname -r | awk -F. '{ printf("%d.%d\n",$1,$2); }'`

# Find out the HugePage size
HPG_SZ=`grep Hugepagesize /proc/meminfo | awk '{print $2}'`

# Initialize the counter
NUM_PG=0

# Cumulative number of pages required to handle the running shared memory segments
for SEG_BYTES in `ipcs -m | awk '{print $5}' | grep "[0-9][0-9]*"`
do
   MIN_PG=`echo "$SEG_BYTES/($HPG_SZ*1024)" | bc -q`
   if [ $MIN_PG -gt 0 ]; then
      NUM_PG=`echo "$NUM_PG+$MIN_PG+1" | bc -q`
   fi
done

RES_BYTES=`echo "$NUM_PG * $HPG_SZ * 1024" | bc -q`

# An SGA less than 100MB does not make sense
# Bail out if that is the case
if [ $RES_BYTES -lt 100000000 ]; then
   echo "***********"
   echo "** ERROR **"
   echo "***********"
   echo "Sorry! There are not enough total of shared memory segments allocated for 
HugePages configuration. HugePages can only be used for shared memory segments 
that you can list by command:

   # ipcs -m

of a size that can match an Oracle Database SGA. Please make sure that:
 * Oracle Database instance is up and running 
 * Oracle Database 11g Automatic Memory Management (AMM) is not configured"
   exit 1
fi

# Finish with results
case $KERN in
   '2.4') HUGETLB_POOL=`echo "$NUM_PG*$HPG_SZ/1024" | bc -q`;
          echo "Recommended setting: vm.hugetlb_pool = $HUGETLB_POOL" ;;
   '2.6') echo "Recommended setting: vm.nr_hugepages = $NUM_PG" ;;
    *) echo "Unrecognized kernel version $KERN. Exiting." ;;
esac

# End

