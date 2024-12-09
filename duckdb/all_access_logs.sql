create or replace table all_access_logs as (
  select *, req2path(req) as path
  from read_json_auto('logs/nginx/*.jsonl.gz')
);
