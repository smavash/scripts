tar cvf LogFiles_${TWO_TASK}_`hostname`.tar  \
$LOG_HOME/ora/10.1.3/opmn/* \
$LOG_HOME/ora/10.1.3/j2ee/oacore/* \
$LOG_HOME/ora/10.1.3/j2ee/oafm/* \
$LOG_HOME/ora/10.1.3/Apache/* \
$LOG_HOME/appl/admin/log/ad*

gzip LogFiles_${TWO_TASK}_`hostname`.tar
