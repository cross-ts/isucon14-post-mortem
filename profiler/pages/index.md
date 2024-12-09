---
title: Dashboard
---

# Last Benchmark
## Access Log Profile

```sql alp
select *, '<b>' || path || '</b>' as b_path from local.alp
```

<DataTable data={alp} rows=all rowShading=true>
  <Column id="b_path" title="Path" contentType=html/>
  <Column id="method" title="Method" />
  <Column id="count" title="Count" contentType=bar/>
  <Column id="sum_time" title="Sum Time" contentType=colorscale scaleColor={['#6db678','#ebbb38','#ce5050']}/>
  <Column id="avg_time" title="Avg Time" contentType=colorscale scaleColor={['#6db678','#ebbb38','#ce5050']}/>
  <Column id="sum_body_size" title="Sum Body Size" contentType=colorscale scaleColor={['#6db678','#ebbb38','#ce5050']} fmt='bytes'/>
  <Column id="avg_body_size" title="Avg Body Size" contentType=colorscale scaleColor={['#6db678','#ebbb38','#ce5050']} fmt='bytes'/>
  <Column id="200" title="2xx" contentType=colorscale scaleColor=blue/>
  <Column id="300" title="3xx" contentType=colorscale scaleColor=blue/>
  <Column id="400" title="4xx" contentType=colorscale scaleColor=blue/>
  <Column id="500" title="5xx" contentType=colorscale scaleColor=red/>
</DataTable>

## Slow Log Profile

```sql slowlogs
select
  '<b>' || distillate || '</b>' as b_distillate,
  fingerprint,
  query_count::int as query_count,
  sum::float as sum,
  avg::float as avg,
  min::float as min,
  max::float as max,
  median::float as median,
  pct_95::float as pct_95,
  stddev::float as stddev,
  label
from local.last_slow_logs
order by sum desc
```

{#each ['query_time', 'rows_examined', 'rows_sent', 'lock_time', 'query_length'] as label}
## {label}
<DataTable data={slowlogs.where(`label='${label}'`)} rows=all>
  <Column id="b_distillate" title="Distillate" contentType=html/>
  <Column id="query_count" title="Count" contentType=bar/>
  <Column id="sum" title="Sum" contentType=colorscale scaleColor={['#6db678','#ebbb38','#ce5050']}/>
  <Column id="avg" title="Avg" contentType=colorscale scaleColor={['#6db678','#ebbb38','#ce5050']}/>
  <Column id="min" title="Min" contentType=colorscale scaleColor={['#6db678','#ebbb38','#ce5050']}/>
  <Column id="max" title="Max" contentType=colorscale scaleColor={['#6db678','#ebbb38','#ce5050']}/>
  <Column id="median" title="Median" contentType=colorscale scaleColor={['#6db678','#ebbb38','#ce5050']}/>
  <Column id="pct_95" title="P95" contentType=colorscale scaleColor={['#6db678','#ebbb38','#ce5050']}/>
  <Column id="stddev" title="Stddev" />
  <Column id="fingerprint" title="Fingerprint" />
</DataTable>
{/each}
