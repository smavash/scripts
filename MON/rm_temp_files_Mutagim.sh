echo "Shalom" >> /u01_share/DBA/scripts/MON/rm_temp_files_Mutagim.log
find /App/prodcomn/temp -name "*.t*" -mtime +1 -exec rm {} \;
