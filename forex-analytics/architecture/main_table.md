# Таблицы ETL пайплайна

| Таблица | Тип | Назначение | Кол-во записей |
|---------|-----|------------|----------------|
| `kafka_queue` | Kafka Engine | Читает из Kafka | — |
| `kafka_to_ticks_kafka` | MV | Переносит данные | — |
| `ticks_kafka` | MergeTree | Сырые данные | 288,000+ |
| `ticks` | MergeTree | Копия для аналитики | 200,000+ |
| `predictions_eur_usd` | MergeTree | Прогнозы EUR/USD | 71,000 |
| `predictions_gbp_usd` | MergeTree | Прогнозы GBP/USD | 114,000 |
| `predictions_usd_jpy` | MergeTree | Прогнозы USD/JPY | 99,000 |
| `mv_predictions_*` | MV | Автообновление прогнозов | — |
| `latest_signals` | VIEW | Последние сигналы | 3 записи |
