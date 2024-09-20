#!/bin/ksh 



DATE=`date +"%d-%b-%Y-%H%M"`

sqlplus '/as sysdba'<<EOF 

@bde_last_analyzed.sql

exit
EOF


mv bde_last_*.txt bde_last_$DATE
