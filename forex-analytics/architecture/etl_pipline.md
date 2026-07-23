```flowchart TD
    A[Kafka (forex_ticks)] --> B[kafka_queue\nKafka Engine]
    B -->|MV: kafka_to_ticks_kafka| C[ticks_kafka\nсырые данные]
    C -->|MV: mv_predictions_eur_usd| D[predictions_eur_usd\nпрогнозы EUR/USD]
    D -->|VIEW: latest_signals| E[latest_signals\nпоследние сигналы]
    E --> F[Superset\nдашборды и графики]
