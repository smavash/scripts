#!/usr/bin/ksh -x


#==============================================================
#    Monitor Oracle Workflow Services
#
#    Created By          Date               Refrence
# ------------------   ----------  ----------------------------
# Slava Mavashev       31/08/2010      Initial Creation  
#
#    Updated By          Date               Refrence
# ------------------   ----------  ----------------------------
#
#==============================================================

#-- 1 --  Initialize 
#--------------------------------------
. ~/.profile



DATE=`date +"%d-%b-%Y-%H%M"`
ALL_REPORTS="/tmp"
APPSPWD=`env|grep APPLPWD= |awk -F= '{print $2}'`

sqlplus -s <<!
APPS/$APPSPWD

spool mystats.log

begin
  -- Call the procedure
  fnd_stats.gather_index_stats(ownname => 'XLA',
                               indname => 'XLA_AE_HEADERS_N4',
                                       percent => 100,
                               degree => 64);
end;
/
 
!date
 
begin
  -- Call the procedure
  fnd_stats.gather_column_stats(ownname => 'XLA',
                                tabname => 'XLA_AE_HEADERS',
                                colname => 'APPLICATION_ID',
                                percent => 100,
                                degree => 64);
end;
/

!date

execute dbms_stats.gather_schema_stats('XXTNV',cascade=>TRUE,degree=>64);

!date
spool off

exit
!



echo ""
echo ""
echo "Status as of `date`"
echo ""

