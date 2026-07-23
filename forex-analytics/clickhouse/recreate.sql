-- 1. Удалить все связанные объекты
DROP TABLE IF EXISTS forex_data.kafka_queue;
DROP TABLE IF EXISTS forex_data.kafka_to_ticks_kafka;

-- 2. Проверить, что ticks_kafka существует
SELECT name FROM system.tables 
WHERE database = 'forex_data' AND name = 'ticks_kafka';

-- 3. Если ticks_kafka не существует — создать
CREATE TABLE IF NOT EXISTS forex_data.ticks_kafka (
    symbol String,
    bid Float64,
    ask Float64,
    timestamp DateTime
) ENGINE = MergeTree()
ORDER BY (symbol, timestamp);

-- 4. Создать Kafka Engine
CREATE TABLE forex_data.kafka_queue (
    symbol String,
    bid Float64,
    ask Float64,
    timestamp DateTime
) ENGINE = Kafka()
SETTINGS 
    kafka_broker_list = '10.0.0.21:9092',
    kafka_topic_list = 'forex_ticks',
    kafka_group_name = 'clickhouse_group',
    kafka_format = 'CSV';

-- 5. Создать MV для переноса
CREATE MATERIALIZED VIEW forex_data.kafka_to_ticks_kafka
TO forex_data.ticks_kafka
AS
SELECT symbol, bid, ask, timestamp
FROM forex_data.kafka_queue;
