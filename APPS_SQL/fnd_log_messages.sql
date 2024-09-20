SELECT substr(module, 1, 70), MESSAGE_TEXT, timestamp, log_sequence
  FROM fnd_log_messages msg, fnd_log_transaction_context tcon
 WHERE msg.TRANSACTION_CONTEXT_ID = tcon.TRANSACTION_CONTEXT_ID
--AND tcon.TRANSACTION_ID = <your child request ID> 
 ORDER BY LOG_SEQUENCE;






SELECT 
substr(module, 1, 70), MESSAGE_TEXT, timestamp, log_sequence
FROM fnd_log_messages msg, fnd_log_transaction_context tcon
WHERE msg.TRANSACTION_CONTEXT_ID = tcon.TRANSACTION_CONTEXT_ID
--AND tcon.TRANSACTION_ID = <your child request ID> 
ORDER BY LOG_SEQUENCE;


select max(log_sequence)
from
fnd_log_messages fnd, fnd_user fu
where fnd.user_id = fu.user_id
--and fu.user_name = '&USER_NAME'
order by log_sequence desc;


select max(log_sequence)
from
fnd_log_messages fnd
;

select count(*) 
from
fnd_log_messages fnd
where 
--fnd.user_id <> 0
--and fnd.timestamp > sysdate -3
log_sequence >= '209920597'
