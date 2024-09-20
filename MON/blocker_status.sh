#!/bin/bash  


. /tusers/oraprd/.bash_profile

blocker(){

  echo -e "\n\n------------- Begin Test if RDBMS for $ENVNAME is alive  `date +%Y%m%d-%H:%M:%S` --------------"
  # Get all environments from oratab and start them
  for ENVNAME in `grep ":Y$" /etc/oratab | cut -d":" -f1`; do
    echo -e " ------------------------------- \n *** Starting $ENVNAME:"

    ORAUSER='ora'`echo $ENVNAME | tr [:upper:] [:lower:]`
    APPUSER='appl'`echo $ENVNAME | tr [:upper:] [:lower:]`

   if [ $ENVNAME = "PROD" ]; then 
	ORAUSER="oraprd"
        APPUSER="applprd"
   fi




    # check if ora user exist  
    # ---------------------------------------------------
    if grep "^$ORAUSER" /etc/passwd > /dev/null 2>&1; then


      # Test if RDBMS is alive before START
      echo " *** Test if BLOCKER  for $ENVNAME exist ***"
export ISBLCKER=`sqlplus -s '/as sysdba' <<EOF
set timing off echo off feed off verify off head off pages 0 term on
select count(*) from dba_blockers;
exit ;	
EOF`
      if [ $ISBLCKER -ne 0 ]; then
 	### echo  "##### ALERT: BLOCKED session  in $ENVNAME.  ######## " |mailx -s "ALERT: BLOCKED session  in $ENVNAME." slava.mavashev@tnuva.co.il
       logger -t ORA_CKERP -p user.err -i "##### ALERT: BLOCKED session  in $ENVNAME. Please call DBA in the morning  ######## "
      fi

echo $ISBLCKER


export ISBLCKER=`sqlplus -s '/as sysdba' <<EOF
set timing off echo off feed off verify off head off pages 0 term on
select count(*) from dba_kgllock w, dba_kgllock h, v\\$session w1, v\\$session h1 where (((h.kgllkmod != 0) and (h.kgllkmod != 1) and ((h.kgllkreq = 0) or (h.kgllkreq = 1))) and (((w.kgllkmod = 0) or (w.kgllkmod= 1)) and ((w.kgllkreq != 0) and (w.kgllkreq != 1)))) and  w.kgllktype       =  h.kgllktype and  w.kgllkhdl        =  h.kgllkhdl and  w.kgllkuse     =   w1.saddr and  h.kgllkuse     =   h1.saddr;
exit ;
EOF`
echo $ISBLCKER

      if [ $ISBLCKER -ne 0 ]; then
### 	echo  "##### ALERT: BLOCKED session  in $ENVNAME.  ######## " |mailx -s "ALERT: BLOCKED session  in $ENVNAME." slava.mavashev@tnuva.co.il
       logger -t ORA_CKERP -p user.err -i "##### ALERT: BLOCKED session  in $ENVNAME. Please call DBA in the morning. ######## "
      fi


    else 
      echo "There is no such user: $ORAUSER !"
    fi


  done

  echo -e "------- Done Test if BLOCKER  for $ENVNAME exist  (`date +%H:%M:%S`) --------\n" 

}

notify(){
  echo ""
  echo " ********************************************************************************"
  echo " *** This script uses /ets/oratab to know which instances exist on the server ***"
  echo " ********************************************************************************"
}

case "$1" in
  blocker)
    notify
    blocker
    ;;
  *)
    echo $"Usage: $0 {blocker}"
    RETVAL=1    
esac
