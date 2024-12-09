create or replace table last_slow_logs as (
  select * from read_json_auto('slow.jsonl.gz')
);
