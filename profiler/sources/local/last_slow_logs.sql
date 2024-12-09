with parsed as (
  select fingerprint, query_count, distillate, metrics.*
  from last_slow_logs
)
select fingerprint, query_count, distillate, query_length.*, 'query_length' as label from parsed
union all
select fingerprint, query_count, distillate, lock_time.*, 'lock_time' as label from parsed
union all
select fingerprint, query_count, distillate, query_time.*, 'query_time' as label from parsed
union all
select fingerprint, query_count, distillate, rows_examined.*, 'rows_examined' as label from parsed
union all
select fingerprint, query_count, distillate, rows_sent.*, 'rows_sent' as label from parsed
