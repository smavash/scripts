find /app/appl/PROD/inst/apps/PROD_uapapp1/appltmp -name "*.tmp" -mtime +1 -exec rm {} \;
find /app/appl/PROD/inst/apps/PROD_uapapp1/appltmp -name "*.DAT" -mtime +1 -exec rm {} \;
find /app/appl/PROD/inst/apps/PROD_uapapp1/appltmp -name "*.t" -mtime +1 -exec rm {} \;
find /app/appl/PROD/inst/apps/PROD_uapapp1/appltmp -name "*.fo" -mtime +1 -exec rm {} \;
find /app/appl/PROD/inst/apps/PROD_uapapp1/logs/appl/conc/log -mtime +20 -exec rm {} \;
##########
find /app/logout/PROD/log -mtime +16 -exec rm {} \;
find /app/logout/PROD/out -mtime +16 -exec rm {} \;
find /app/logout/PROD/appltmp -mtime +120 -exec rm {} \;
find /app/logout/PROD/appltmp -name "*.tmp" -mtime +1 -exec rm {} \;
find /app/logout/PROD/appltmp -name "*.heb" -mtime +1 -exec rm {} \;
find /app/logout/PROD/appltmp -name "*.DAT" -mtime +1 -exec rm {} \;
find /app/logout/PROD/appltmp -name "*.rep" -mtime +1 -exec rm {} \;
find /app/logout/PROD/appltmp -name "*.t" -mtime +1 -exec rm {} \;

find /ora/locale/out  -mtime +15  -exec rm {} \;
find /ora/locale/appltmp -name "*.tmp" -mtime +1 -exec rm {} \;
find /ora/locale/appltmp -name "*.t" -mtime +1 -exec rm {} \;
find /ora/locale/appltmp -name "*.DAT" -mtime +1 -exec rm {} \; 
##########
cd /app/appl/PROD/apps/tech_st/10.1.3/j2ee/home; rm core*
cd /app/appl/PROD/inst/apps/PROD_uapapp1/ora/10.1.2/forms ;rm core*
##########
##find /app/appl/PROD/inst/apps/PROD_uapapp1/logs/ora/10.1.3/Apache  -mtime +2  -exec rm {} \;
find /app/appl/PROD/inst/apps/PROD_uapapp1/logs/ora/10.1.3/Apache -type f -not -name "ssl*" -mtime +2 -exec rm {} \;
find /app/appl/PROD/inst/apps/PROD_uapapp1/logs/ora/10.1.2/reports/cache -mtime +1 -exec rm {} \;
find /app/stage/KPMG -mtime +7 -exec rm {} \;
##########
find /app/appl/PROD/apps/apps_st/appl/xdo/12.0.0/temp -mtime +1 -exec rm {} \;
############
### OLD MQ FILES DELETE 
find /app/appl/tusers/mq/q2f/prd/old  -name "to_oa*" -mtime +62 -delete
