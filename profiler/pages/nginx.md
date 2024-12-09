---
title: Nginx
---

# Nginx
## All Access Logs

<Slider
    name=interval
    title='Interval'
    size=large
    min=1
    max=600
    defaultValue=10
/>

<Slider
    name=limit
    title='Limit'
    size=large
    min=100
    max=1000
    step=10
/>

```sql time_series
select
  time_bucket(interval '${inputs.interval} seconds', time::timestamp) as time_bucket,
  path,
  method,
  round(sum(request_time), 5) as sum_time
from local.all_access_logs
group by time_bucket, path, method
order by time_bucket desc
limit ${inputs.limit}
```

<AreaChart
  chartAreaHeight=300
  data={time_series}
  x="time_bucket"
  y="sum_time"
  series="path"
/>
