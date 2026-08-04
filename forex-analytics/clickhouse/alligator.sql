-- 1. Сначала создаем целевую таблицу для хранения данных
CREATE TABLE forex_data.candles_data (
    symbol String,
    bar_time DateTime,
    price Float64
) ENGINE = MergeTree()
ORDER BY (symbol, bar_time);

-- 2. Теперь создаем материализованное представление
CREATE MATERIALIZED VIEW forex_data.mv_candles
TO forex_data.candles_data
AS
SELECT
    symbol,
    toStartOfMinute(timestamp) AS bar_time,
    AVG(bid) AS price
FROM forex_data.ticks_kafka
GROUP BY symbol, bar_time;

-- 3. Создаем обычное представление для Alligator
CREATE VIEW forex_data.v_alligator AS
WITH candles AS (
    SELECT * FROM forex_data.candles_data
)
SELECT
    symbol,
    bar_time,
    price,
    AVG(price) OVER (PARTITION BY symbol ORDER BY bar_time ROWS BETWEEN 12 PRECEDING AND CURRENT ROW) AS jaw,
    AVG(price) OVER (PARTITION BY symbol ORDER BY bar_time ROWS BETWEEN 7 PRECEDING AND CURRENT ROW) AS teeth,
    AVG(price) OVER (PARTITION BY symbol ORDER BY bar_time ROWS BETWEEN 4 PRECEDING AND CURRENT ROW) AS lips,
    CASE
        WHEN jaw > teeth AND teeth > lips THEN 'UP'
        WHEN jaw < teeth AND teeth < lips THEN 'DOWN'
        ELSE 'SIDEWAYS'
    END AS state
FROM candles;



