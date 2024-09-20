#!/bin/bash 


. /db/orainst/PROD/db/tech_st/11.1.0/PROD_uapdb1.env

test_conn(){

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
      echo " *** Test if RDBMS for $ENVNAME is alive before START ***"
#20131127 08:31  sqlplus -s apps/makel2011 <<EOF
sqlplus -s apps/$APPLPWD <<EOF
set timing off echo off feed off verify off head off pages 0 term on
WHENEVER SQLERROR EXIT 1
WHENEVER OSERROR EXIT 1
select * from dual;
exit ;	
EOF

      export EXITCODE=$?
      if [ "$EXITCODE" -eq 0 ]; then
        echo "------- RDBMS for $ENVNAME is alive  -------"
      else
       logger -t ORA-CKERP -p user.err -i "##### Critical ALERT: PROD DB sqlplus connection not responding . ######## "
      fi

    else 
      echo "There is no such user: $ORAUSER !"
    fi


  done

  echo -e "------- Done Test if RDBMS for $ENVNAME is alive (`date +%H:%M:%S`) --------\n" 

}

notify(){
  echo ""
  echo " ********************************************************************************"
  echo " *** This script uses /ets/oratab to know which instances exist on the server ***"
  echo " ********************************************************************************"
}

case "$1" in
  test_conn)
    notify
    test_conn
    ;;
  *)
    echo $"Usage: $0 {test_conn}"
    RETVAL=1    
esac
