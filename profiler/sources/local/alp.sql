select
  count(1) as count,
  path,
  method,
  count(1) filter (left(status::varchar, 1) == '1') as '100',
  count(1) filter (left(status::varchar, 1) == '2') as '200',
  count(1) filter (left(status::varchar, 1) == '3') as '300',
  count(1) filter (left(status::varchar, 1) == '4') as '400',
  count(1) filter (left(status::varchar, 1) == '5') as '500',
  round(sum(request_time), 5) as sum_time,
  round(avg(request_time), 5) as avg_time,
  sum(body_bytes)::bigint as sum_body_size,
  avg(body_bytes)::bigint as avg_body_size
from last_access_logs
group by path, method
order by sum_time desc;
