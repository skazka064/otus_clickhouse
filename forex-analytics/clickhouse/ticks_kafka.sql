## ticks_kafka — хранилище сырых данных
## Назначение: Хранит все данные, приходящие из Kafka.
## Роль в пайплайне: Основное хранилище всех сырых тиков.

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
