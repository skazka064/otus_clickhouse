## Назначение: Читает данные из Kafka топика forex_ticks.
## Роль в пайплайне: Kafka → kafka_queue → ticks_kafka

CREATE TABLE forex_data.kafka_queue
(
    symbol String,
    bid Float64,
    ask Float64,
    timestamp DateTime
)
ENGINE = Kafka()
SETTINGS 
    kafka_broker_list = '10.0.0.21:9092',
    kafka_topic_list = 'forex_ticks',
    kafka_group_name = 'clickhouse_group',
    kafka_format = 'CSV';
