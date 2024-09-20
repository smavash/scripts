#!/usr/bin/ksh

DATE=`date +"%d-%b-%Y-%H%M"`

file=$1

tkprof $file $file.$DATE.prsqry sys=no explain=apps/$2 sort='(prsqry,exeqry,fchqry,prscu,execu,fchcu)' 
tkprof $file $file.$DATE.prsela sys=no explain=apps/$2 sort='(prsela,exeela,fchela)'  
tkprof $file $file.$DATE.prscnt sys=no explain=apps/$2 sort='(prscnt,execnt,fchcnt)'  
