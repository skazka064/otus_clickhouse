## Назначение: Дублирует ticks_kafka для удобства работы с аналитикой.
## Структура: аналогична ticks_kafka
## Роль в пайплайне: Используется для визуализации и прогнозов.

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
