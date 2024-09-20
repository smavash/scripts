#!/bin/ksh 



export DATE=`date +"%d-%b-%Y-%H%M"`

sqlplus '/as sysdba'<<EOF 

exec DBMS_WORKLOAD_REPOSITORY.CREATE_SNAPSHOT;

exit





EOF
