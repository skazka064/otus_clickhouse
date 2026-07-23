## Назначение: Автоматически переносит данные из kafka_queue в ticks_kafka.
## Роль в пайплайне: kafka_queue → (MV) → ticks_kafka
  
CREATE MATERIALIZED VIEW forex_data.kafka_to_ticks_kafka
TO forex_data.ticks_kafka AS
SELECT symbol, bid, ask, timestamp
FROM forex_data.kafka_queue;
