## Назначение: Автоматически обновляют таблицы прогнозов при поступлении новых данных в ticks_kafka
## Роль в пайплайне: ticks_kafka → (MV) → predictions_*

CREATE MATERIALIZED VIEW forex_data.mv_predictions_eur_usd
TO forex_data.predictions_eur_usd
AS
SELECT 
    timestamp,
    bid AS actual_price,
    AVG(bid) OVER (ORDER BY timestamp ASC ROWS BETWEEN 10 PRECEDING AND CURRENT ROW) AS predicted_price,
    bid - AVG(bid) OVER (ORDER BY timestamp ASC ROWS BETWEEN 10 PRECEDING AND CURRENT ROW) AS error,
    now() AS created_at
FROM forex_data.ticks_kafka
WHERE symbol = 'EUR/USD';

CREATE MATERIALIZED VIEW forex_data.mv_predictions_gpb_usd
TO forex_data.predictions_gpb_usd
AS
SELECT 
    timestamp,
    bid AS actual_price,
    AVG(bid) OVER (ORDER BY timestamp ASC ROWS BETWEEN 10 PRECEDING AND CURRENT ROW) AS predicted_price,
    bid - AVG(bid) OVER (ORDER BY timestamp ASC ROWS BETWEEN 10 PRECEDING AND CURRENT ROW) AS error,
    now() AS created_at
FROM forex_data.ticks_kafka
WHERE symbol = 'GPB/USD';

CREATE MATERIALIZED VIEW forex_data.mv_predictions_usd_jpy
TO forex_data.predictions_usd_jpy
AS
SELECT 
    timestamp,
    bid AS actual_price,
    AVG(bid) OVER (ORDER BY timestamp ASC ROWS BETWEEN 10 PRECEDING AND CURRENT ROW) AS predicted_price,
    bid - AVG(bid) OVER (ORDER BY timestamp ASC ROWS BETWEEN 10 PRECEDING AND CURRENT ROW) AS error,
    now() AS created_at
FROM forex_data.ticks_kafka
WHERE symbol = 'USD/JPY';
