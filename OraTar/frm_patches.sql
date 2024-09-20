set serveroutput on size 1000000
spool frm_patches
declare
  l_instance       v$instance.instance_name%type;
  l_host           v$instance.host_name%type;
  l_release        fnd_product_groups.release_name%type;
  l_patch_level    fnd_product_installations.patch_level%type;
  l_patch_num      ad_applied_patches.patch_name%type;
  l_patch_name     varchar2(100);
  l_patch_date     date;

  cursor get_patch is
  select distinct(patch_name) PatchNum,
         decode(patch_name,
            '3140000', 'Maintenance Pack 11.5.10',
            '3761838', '11i.FRM.G',
            '4206794', '11i.FRM.H',
            '5484000', 'Release Update Pack 12.0.2',
            '5917316', 'R12.FRM.A.delta.2',
            '6141000', 'Release Update Pack 12.0.3',
            '6077597', 'R12.FRM.A.delta.3',
            '6435000', 'Release Update Pack 12.0.4',
            '6354138', 'R12.FRM.A.delta.4',
'7282993', 'Release Update Pack 12.0.5',
'6594779', 'R12.FRM.A.delta.5',
            '6728000', 'Release update Pack 12.0.6',
            '7237233', 'R12.FRM.A.delta.6' ) 
PatchName,
         creation_date
  from (select patch_name, creation_date from ad_applied_patches union
        select bug_number, creation_date  from ad_bugs)
  where patch_name in (
   '3140000', '3761838', '4206794',  -- end 11i
   '5484000', '5917316', '6141000', '6077597', '6435000', '6354138',
   '7282993', '6594779', '6728000', '7237233'  -- end R12
  )
  order by creation_date desc,  decode(patch_name,
   '3140000',1,'3761838',2,'4206794',3, -- end 11i
   '5484000',4,'5917316',5,'6141000',6,'6077597',7,'6435000',8,
   '6354138',9,'7282993',10,'6594779',11,'6728000',12,'7237233',12, -- end R12
   100) desc;

  cursor get_all(pdate date) is
  select ap.patch_name, max(pr.start_date) applied_date
  from ad_applied_patches ap,
       ad_patch_drivers pd,
       ad_patch_runs pr
  where pr.start_date > pdate
  and   ap.patch_name != 'merged'
  and   pd.applied_patch_id = ap.applied_patch_id
  and   pr.patch_driver_id = pd.patch_driver_id
  and   exists (
     select 1 from ad_patch_run_bugs prb
     where    prb.patch_run_id = pr.patch_run_id
     and      prb.application_short_name = 'FRM')
  group by ap.patch_name
  order by ap.patch_name, max(pr.start_date);

  patch_error exception;
begin
  select instance_name, host_name
  into   l_instance, l_host
  from   v$instance
  where  rownum=1;

  select release_name into l_release
  from   fnd_product_groups
  where  rownum = 1;

  select patch_level into l_patch_level
  from fnd_product_installations
  where  application_id = 265
  and rownum=1;

  open get_patch;
  fetch get_patch into l_patch_num, l_patch_name, l_patch_date;
  if get_patch%notfound then
    close get_patch;
    raise patch_error;
  end if;
  close get_patch;

  dbms_output.put_line('Instance:  '||l_instance);
  dbms_output.put_line('Host:      '||l_host);
  dbms_output.put_line('Release:   '||l_release);
  dbms_output.put_line('Patch Set: '||l_patch_level||chr(10));
  dbms_output.put_line('Latest Patchset/RUP: '||l_patch_num||' '||l_patch_name);
  dbms_output.put_line('Applied:             '||
    to_char(l_patch_date,'DD-MON-YYYY HH24:MI:SS')||chr(10));
  dbms_output.put_line('Report manager related patches applied since:');
  for rec in get_all(l_patch_date) loop
    dbms_output.put_line(chr(9)||rec.patch_name||'  ('||
      to_char(rec.applied_date,'DD-MON-YYYY HH24:MI:SS')||')');
  end loop;
  dbms_output.put_line('This does not list Web ADI or GL patches applied.');
exception
  when patch_error then
    dbms_output.put_line('Unable to determine latest patchset/rup level');
  when others then
    dbms_output.put_line('Exception in script: '||sqlerrm);
end;
/
spool off

