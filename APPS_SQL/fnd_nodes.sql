select count(*) from Fnd_Concurrent_Processes p1
where p1.node_name !=  'UAPAPP1';

create table fnd_nodes_backup_ap as select * from fnd_nodes;

update Fnd_Concurrent_Processes p1
set p1.node_name = 'UAPAPP1'
where p1.node_name = 'UAPERP2';