-- 1. Пересоздать тренд с новой логикой (сравнение часов)
CREATE OR REPLACE VIEW forex_data.hourly_trend AS
WITH hourly_data AS (
    SELECT 
        symbol,
        toStartOfHour(timestamp) AS hour,
        argMax(bid, timestamp) AS price
    FROM forex_data.ticks
    WHERE timestamp > now() - INTERVAL 24 HOUR
    GROUP BY symbol, hour
),
with_prev AS (
    SELECT 
        symbol,
        hour,
        price,
        LAG(price, 1) OVER (PARTITION BY symbol ORDER BY hour) AS prev_price
    FROM hourly_data
)
SELECT 
    symbol,
    MAX(hour) AS last_hour,
    argMax(price, hour) AS last_price,
    CASE 
        WHEN argMax(price, hour) > argMax(prev_price, hour) THEN 'UP'
        WHEN argMax(price, hour) < argMax(prev_price, hour) THEN 'DOWN'
        ELSE 'SIDEWAYS'
    END AS trend
FROM with_prev
GROUP BY symbol;
