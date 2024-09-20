!#/bin/ksh

SNAP=$1
echo SNAP=$SNAP
 
if [[ $SNAP != DEV_3 && $SNAP != DEV_7 ]]; then
   echo "Parameter must be DEV_3 Or DEV_7 !!!"
   exit 99
fi

echo "Run stop DEV script ..."
/usr/tnu/stopDEV
sleep 5

echo "Run resync script of $SNAP ..."
/usr/tnu/3PAR_new/3PAR_resync_vreplica -g $SNAP  -v 
sleep 5

echo "Run Start DEV script ..." 
/usr/tnu/startDEV



