ps -eo pid,pcpu,comm | sort -n -k2 | grep 'frmweb'|tail -10 | awk '{ print $1 " " $2}' > /tmp/output
while read line; 
do 
 a=$(echo $line | awk '{ print $1 }'); 
 b=$(echo $line | awk '{ print $2 }'); 
 echo "$(pwdx $a) (${b}&#37;)"; 
done < /tmp/output


ps -eo pid,pcpu,comm | sort -n -k2 | grep 'frmweb'|tail -10|awk '{ORS="% "; system("pwdx " $1); print $2}'
