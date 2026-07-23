-- Обучение модели с нормализованным временем
CREATE OR REPLACE TABLE forex_model_norm ENGINE = Memory AS
SELECT stochasticLinearRegressionState(0.1, 0.0, 5, 'SGD')(
    bid, 
    (toUnixTimestamp(timestamp) - toUnixTimestamp(now())) / 86400 AS days_from_now
) AS state
FROM forex_data.ticks_kafka  where symbol='EUR/USD';

-- Прогноз с нормализованным временем
WITH (SELECT state FROM forex_model_norm) AS model
SELECT 
    timestamp,
    bid AS actual_price,
    evalMLMethod(model, (toUnixTimestamp(timestamp) - toUnixTimestamp(now())) / 86400) AS predicted_price
FROM forex_data.ticks_kafka where symbol='EUR/USD'
LIMIT 10;
