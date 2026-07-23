
CREATE MATERIALIZED VIEW forex_data.mv_predictions_eur_usd TO forex_data.predictions_eur_usd
AS SELECT
    timestamp,
    bid AS actual_price,
    AVG(bid) OVER (ORDER BY timestamp ASC ROWS BETWEEN 10 PRECEDING AND CURRENT ROW) AS predicted_price,
    bid - AVG(bid) OVER (ORDER BY timestamp ASC ROWS BETWEEN 10 PRECEDING AND CURRENT ROW) AS error,
    now() AS created_at
FROM forex_data.ticks_kafka
WHERE symbol = 'EUR/USD'

Query id: 1ba43f5d-8355-43f0-8575-d563da4918b2

Ok.

0 rows in set. Elapsed: 0.009 sec.


CREATE MATERIALIZED VIEW forex_data.mv_predictions_gbp_usd TO forex_data.predictions_gbp_usd
AS SELECT
    timestamp,
    bid AS actual_price,
    AVG(bid) OVER (ORDER BY timestamp ASC ROWS BETWEEN 10 PRECEDING AND CURRENT ROW) AS predicted_price,
    bid - AVG(bid) OVER (ORDER BY timestamp ASC ROWS BETWEEN 10 PRECEDING AND CURRENT ROW) AS error,
    now() AS created_at
FROM forex_data.ticks_kafka
WHERE symbol = 'GBP/USD'

Query id: 2cc804aa-8c47-4aa8-9ff6-58f423537e05

Ok.

0 rows in set. Elapsed: 0.016 sec.


CREATE MATERIALIZED VIEW forex_data.mv_predictions_usd_jpy TO forex_data.predictions_usd_jpy
AS SELECT
    timestamp,
    bid AS actual_price,
    AVG(bid) OVER (ORDER BY timestamp ASC ROWS BETWEEN 10 PRECEDING AND CURRENT ROW) AS predicted_price,
    bid - AVG(bid) OVER (ORDER BY timestamp ASC ROWS BETWEEN 10 PRECEDING AND CURRENT ROW) AS error,
    now() AS created_at
FROM forex_data.ticks_kafka
WHERE symbol = 'USD/JPY'

Query id: 4631915b-4f3a-443a-95db-2256527b1a7d

