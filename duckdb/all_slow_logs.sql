create or replace table all_slow_logs as (
  select * from read_json_auto('logs/mysql/*.jsonl.gz')
);
