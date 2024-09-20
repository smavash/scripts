tar cvf configFiles_${TWO_TASK}_`hostname`.tar $ORA_CONFIG_HOME/10.1.2/* \
$CONTEXT_FILE \
$ADMIN_SCRIPTS_HOME \
$APPL_TOP/*.env \
$ORA_CONFIG_HOME/10.1.3/Apache \
$ORA_CONFIG_HOME/10.1.3/config \
$ORA_CONFIG_HOME/10.1.3/j2ee/oacore \
$ORA_CONFIG_HOME/10.1.3/j2ee/forms \
$ORA_CONFIG_HOME/10.1.3/j2ee/oafm \
$ORA_CONFIG_HOME/10.1.3/network \
$ORA_CONFIG_HOME/10.1.3/opmn \
$INST_TOP/ora/10.1.3/*.env
