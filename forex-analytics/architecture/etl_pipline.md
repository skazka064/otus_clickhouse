```mermaid
flowchart TD
    A[Kafka (forex_ticks)] --> B[kafka_queue<br>Kafka Engine]
    B -->|MV: kafka_to_ticks_kafka| C[ticks_kafka<br>сырые данные]
    C -->|MV: mv_predictions_eur_usd| D[predictions_eur_usd<br>прогнозы EUR/USD]
    D -->|VIEW: latest_signals| E[latest_signals<br>последние сигналы]
    E --> F[Superset<br>дашборды и графики]
```
