create or replace table last_access_logs as (
  select *, req2path(req) as path
  from read_json_auto('access.jsonl.gz')
);
