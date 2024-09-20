## Start of script
##
##  Check for HTTP statuses in 400 or 500 range for JServ 
##  or PLSQL requests only
##
awk ' $9>=400 && $9<=599 { print $0 }' access_log* | grep -e  "servlet" -e "\/pls\/" | grep -v .gif
##
##  Check for requests taking more than 30 seconds to be returned
##
awk ' $11>30 {print $0} ' access_log*
## 
##  This one is not an exception report, you need to manually check
##  Look for when the JVMs are restarting
##
grep "GET /oprocmgr-service?cmd=Register" access_log*
##
## End of script
