#!/usr/bin/ksh

. ~/.profile
. /u002/app/applmgr/${ENVNAME}appl/APPS${ENVNAME}.env


DATE=`date +"%d-%b-%Y-%H%M"`
ALL_REPORTS="/tmp"
REPORT="${ALL_REPORTS}/ra_${DATE}.txt"

sqlplus -s apps/$APPLPWD << EOF
set timing off echo off feed off verify off head off pages 0 term on line 10000
drop table dbamon.ra_customer_trx_lines_all_temp;
create table dbamon.ra_customer_trx_lines_all_temp as
select count(*) total, rcta.customer_trx_id, rctla.interface_line_attribute6
from ra_customer_trx_all rcta,
ra_customer_trx_lines_all rctla
where rctla.customer_trx_id = rcta.customer_trx_id
and rctla.interface_line_context = 'ORDER ENTRY'
and rctla.line_type = 'LINE'
group by rcta.customer_trx_id, rctla.interface_line_attribute6
having count(rcta.customer_trx_id) > 1;
EOF




export TRX_NUM=`sqlplus -s apps/$APPLPWD << EOF
set timing off echo off feed off verify off head off pages 0 term on line 10000
select count(*)
from dbamon.ra_customer_trx_lines_all_temp;
EOF`

if [ ${TRX_NUM} -gt 1 ];
then
	java -classpath /opt/backup send_sms 0520000000 "Alert: Duplicate records in Invoice per Order were detected, Please Handle manualy in SCM team."
	
fi

