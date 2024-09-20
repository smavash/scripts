DATE=`date +"%d-%b-%Y-%H%M"`


cd $COMMON_TOP/webapps/oacore/html/cabo/styles/cache
mkdir -p cache_$DATE

mv *.css cache_$DATE/.
