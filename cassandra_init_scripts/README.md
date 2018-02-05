HSL Demo Data copying
=====================

These instructions are relevant only if you want to re-generate HSL demo data
(used by functional tests)

# Find min and max offsets for desired date range (using cqlsh)

```
SELECT
  MIN(kafka_offset),
  MAX(kafka_offset)
FROM
  stream_timestamps
WHERE
  stream = 'YpTAPDbvSAmj-iCUYz-dxA'
  AND stream_partition = 0
  AND ts >= '2017-04-09 16:00:00'
  AND ts <= '2017-04-10 08:00:00'
ALLOW FILTERING;
```

# Copy event and timestamp data to CSV

On production Cassandra (replace `<NAME>`, `<MIN_OFFSET>`, `<MAX_OFFSET>`):

```
cqlsh -k <NAME> --request-timeout=3600 --connect-timeout=3600 -e "SELECT * FROM stream_timestamps WHERE stream = 'YpTAPDbvSAmj-iCUYz-dxA' AND stream_partition = 0 AND kafka_offset >= <MIN_OFFSET> AND kafka_offset <= <MAX_OFFSET> ALLOW FILTERING;" > hsl-demo-data-ts.original.csv
```


```
cqlsh -k <NAME> --request-timeout=3600 --connect-timeout=3600 -e "SELECT * FROM streamr_events WHERE stream = 'YpTAPDbvSAmj-iCUYz-dxA' AND stream_partition = 0 AND kafka_offset >= <MIN_OFFSET> AND kafka_offset <= <MAX_OFFSET> ALLOW FILTERING;" > hsl-demo-data.original.csv
```


# Remove extra whitespace from both event and timestamp data with `whitespace_stripper.js`

```
python whitespace_stripper.py hsl-demo-data-ts.original.csv > hsl-demo-data-ts.csv
python whitespace_stripper.py hsl-demo-data.original.csv > hsl-demo-data.csv
```
