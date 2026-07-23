```mermaid
    subgraph "ИСТОЧНИКИ ДАННЫХ"
        A[Kafka forex_ticks]
        DAG[Airflow DAG<br/>(раз в час)]
    end

    subgraph "ПРИЁМ ДАННЫХ"
        B[kafka_queue]
        T[ticks]
    end

    subgraph "ХРАНИЛИЩЕ"
        C[ticks_kafka]
    end

    subgraph "ПРОГНОЗЫ"
        E[predictions_eur_usd]
        F[predictions_gbp_usd]
        G[predictions_usd_jpy]
    end

    subgraph "ВИЗУАЛИЗАЦИЯ"
        H[latest_signals]
        I[Superset]
    end

    A -->|автоматически| B
    B -->|MV: kafka_to_ticks_kafka| C
    
    DAG -->|INSERT раз в час| T
    
    C -->|MV: mv_predictions_eur_usd| E
    C -->|MV: mv_predictions_gbp_usd| F
    C -->|MV: mv_predictions_usd_jpy| G
    
    E -->|VIEW: latest_signals| H
    F -->|VIEW: latest_signals| H
    G -->|VIEW: latest_signals| H
    
    H -->|данные для графиков| I
    
    T -.->|не используется для прогнозов| I
    T -.->|резервный источник| I

    style A fill:#f9f,stroke:#333,stroke-width:2px
    style DAG fill:#ff9,stroke:#333,stroke-width:2px
    style C fill:#9f9,stroke:#333,stroke-width:2px
    style T fill:#9cf,stroke:#333,stroke-width:2px
    style H fill:#fc9,stroke:#333,stroke-width:2px
```
