### Назначение: Хранят прогнозы (скользящее среднее) для каждой валюты отдельно.?
```
CREATE TABLE forex_data.predictions_eur_usd (
    timestamp DateTime,
    actual_price Float64,
    predicted_price Float64,
    error Float64,
    created_at DateTime DEFAULT now()
) ENGINE = MergeTree()
ORDER BY timestamp;

CREATE TABLE forex_data.predictions_gpb_usd (
    timestamp DateTime,
    actual_price Float64,
    predicted_price Float64,
    error Float64,
    created_at DateTime DEFAULT now()
) ENGINE = MergeTree()
ORDER BY timestamp;

CREATE TABLE forex_data.predictions_usd_jpy (
    timestamp DateTime,
    actual_price Float64,
    predicted_price Float64,
    error Float64,
    created_at DateTime DEFAULT now()
) ENGINE = MergeTree()
ORDER BY timestamp;
```
