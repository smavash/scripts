#!/bin/ksh   



DATE=`date +"%d-%b-%Y-%H%M"`
DATE_M=`date +"%OM"`
DATE_H=`date +"%OH"`

ALL_REPORTS="/tmp"
REPORT="${ALL_REPORTS}/ARCH_${DATE}.txt"

sqlplus -s '/as sysdba' <<EOF 
set linesize 132 pagesize 9999 
set feed on

column ord noprint
column date_ heading 'Date' format A15
column no heading '#Arch files' format 999,999
column no_size heading 'Size Mb' format 999,999,999,999

compute avg of no on report

compute avg of no_size on report

break on report 

spool $REPORT
prompt ###########################################
prompt ###    Disk Space for Arcchive files ######
prompt ###########################################
@/u01_share/DBA/scripts/MON/archive_rep.sql
spool off
exit
EOF



