-- Display three reports at two second intervals for all devices
iostat -d 2 3 


iostat -x 300

iostat -x 2 | grep -v " 0.00  0.00  0.00"

iostat -x 2 | grep -v " 0.00  0.00  0.00" | grep -v "dm-"

iostat -xdk 5

-- Display three reports of extended statistics at two second intervals for devices hda and hdb
iostat -x hda 2 3 

-- Look for any devices with abnormal high blocks reads (Blk_read/s) and writes (Blk_wrtn/s) per second 
-- If %util is higher or near 100% utilization then it is a strong indicator for I/O bottleneck 
-- If one of these disks are used by Oracle then you can check the data dictionary tables 
-- v$sql to see which SQL statement has generated most read/write and v$segment_statistics to see which object has generated most read/write activity.


iostat -xN 
iostat -xN 1

-- See only specific Volume Group
iostat -xN 1 -d vg_erpdataBKR-lv_erpdata  
iostat -xN vg_erpdataBKR-lv_erpdata 5 5


iostat -xn 2 40|grep dm-39
iostat -x 1 |grep dm-39


--  The output of iostat -xN will show your logical volumes, but it is worth knowing that the device mapper maps can also be seen by running ls -lrt /dev/mapper. The sixth column of the output corresponds to the DM- number shown in iostat and other device commands.

ls -lrt /dev/mapper


-- Running the command fuser -vm /opt will show us a list of processes accessing the filesystem, and the process owner.
fuser -vm /opt

