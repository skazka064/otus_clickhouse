## Проверка количества данных

SELECT 
    'ticks (Airflow)' AS table_name,
    COUNT(*) AS rows,
    MIN(timestamp) AS first,
    MAX(timestamp) AS last
FROM forex_data.ticks

UNION ALL

SELECT 
    'ticks_kafka (Kafka)' AS table_name,
    COUNT(*) AS rows,
    MIN(timestamp) AS first,
    MAX(timestamp) AS last
FROM forex_data.ticks_kafka;
