find /db/orainst/PROD/db/tech_st/11.1.0/admin/PROD_uapdb1/diag/rdbms/prod/PROD/trace . -name "*.trm" -mtime +1 -exec rm {} \;
find /db/orainst/PROD/db/tech_st/11.1.0/admin/PROD_uapdb1/diag/rdbms/prod/PROD/trace . -name "*.trc" -mtime +1 -exec rm {} \;
find /db/orainst/PROD/db/tech_st/11.1.0/admin/PROD_uapdb1/diag/rdbms/prod/PROD/trace . -name "*.txt" -mtime +1 -exec rm {} \;
find /db/orainst/PROD/db/tech_st/11.1.0/admin/PROD_uapdb1/diag/rdbms/prod/PROD/trace . -name "*.zip" -mtime +1 -exec rm {} \;
find /db/orainst/PROD/db/tech_st/11.1.0/admin/PROD_uapdb1/diag/rdbms/prod/PROD/alert . -name "log*.xml" -mtime +30 -exec rm {} \;
find /db/orainst/PROD/db/tech_st/11.1.0/log/diag/tnslsnr/uaperp1/prod/alert . -name "log*.xml" -mtime +30 -exec rm {} \;
find /db/orainst/PROD/db/tech_st/11.1.0/rdbms/audit -mtime +1 -exec rm {} \;
find /app/appl/PROD/inst/apps/PROD_uapapp1/appltmp -mtime +1 -exec rm {} \;
find /usr/tmp -name "*.html" -mtime +1 -exec rm {} \;
