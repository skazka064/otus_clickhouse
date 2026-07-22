# ticks_kafka — Потоковые данные (Kafka)

```
CREATE TABLE forex_data.ticks_kafka
(
    symbol String,
    bid Float64,
    ask Float64,
    timestamp DateTime
)
ENGINE = MergeTree()
ORDER BY (symbol, timestamp);
```
