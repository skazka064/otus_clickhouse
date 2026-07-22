## Пакетные данные (Airflow)

```
CREATE TABLE forex_data.ticks
(
    symbol String,
    bid Float64,
    ask Float64,
    timestamp DateTime
)
ENGINE = MergeTree()
ORDER BY (symbol, timestamp);
```
