SELECT COUNT(*) Total,
       sum(decode(greatest(0, ceil(sysdate - actual_completion_date)),
                  least(7, ceil(sysdate - actual_completion_date)),
                  1,
                  0)) Week4,
       sum(decode(greatest(8, ceil(sysdate - actual_completion_date)),
                  least(14, ceil(sysdate - actual_completion_date)),
                  1,
                  0)) Week3,
       sum(decode(greatest(15, ceil(sysdate - actual_completion_date)),
                  least(21, ceil(sysdate - actual_completion_date)),
                  1,
                  0)) Week2,
       sum(decode(greatest(22, ceil(sysdate - actual_completion_date)),
                  least(28, ceil(sysdate - actual_completion_date)),
                  1,
                  0)) Week1
  FROM FND_CONCURRENT_REQUESTS
 WHERE ACTUAL_COMPLETION_DATE is not null;
