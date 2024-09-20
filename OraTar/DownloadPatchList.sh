#!/bin/ksh -x

function getOraPatch
{
        mosUser=""
        mosPass=""
        fname=`echo $1 | awk -F"=" '{print $NF;}'`
        wget --secure-protocol=TLSv1 --no-check-certificate --http-user $mosUser --http-passwd $mosPass $1 -O $fname
}

#=========================================================

for patch in `cat PatchListURL.txt`
do
  getOraPatch $patch
done

