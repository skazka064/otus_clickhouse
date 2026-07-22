## kafka_to_ticks_kafka — Материализованное представление
  
CREATE MATERIALIZED VIEW forex_data.kafka_to_ticks_kafka
TO forex_data.ticks_kafka AS
SELECT symbol, bid, ask, timestamp
FROM forex_data.kafka_queue;
