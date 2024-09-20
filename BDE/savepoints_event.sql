alter session set events '10046 trace name context forever, level 12'

alter session set events  'immediate trace name savepoints level 1'




insert into xxqa_serial_cre_params (api_version
,commit_stat
,inventory_item_id
,organization_id
,serial_number
,initialization_date
,revision

)
values (1
,'T'
,58168
,168
,'0000221384'
,to_date('160605','ddmmyy')
,'B02'
)



select * from mtl_serial_numbers where serial_number = '0000221384'

select * from xxftj.xxqa_serial_cre_output 


alter session set events '10046 trace name context off'


  
  
  
