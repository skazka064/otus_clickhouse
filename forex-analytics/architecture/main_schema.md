graph TD
    A["Kafka (forex_ticks)"] --> B["kafka_queue<br>Kafka Engine"]
    B -->|"MV: kafka_to_ticks_kafka"| C["ticks_kafka<br>сырые данные"]
    C -->|"Копирование"| D["ticks<br>данные для аналитики"]
    C -->|"MV: mv_predictions_*"| E["predictions_eur_usd<br>71,000 записей"]
    C -->|"MV: mv_predictions_*"| F["predictions_gbp_usd<br>114,000 записей"]
    C -->|"MV: mv_predictions_*"| G["predictions_usd_jpy<br>99,000 записей"]
    E -->|"VIEW: latest_signals"| H["latest_signals<br>3 последних сигнала"]
    F -->|"VIEW: latest_signals"| H
    G -->|"VIEW: latest_signals"| H
    H --> I["Superset<br>дашборды"]
