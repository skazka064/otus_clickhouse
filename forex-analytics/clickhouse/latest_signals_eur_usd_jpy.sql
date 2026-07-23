CREATE OR REPLACE VIEW forex_data.latest_signals AS
SELECT
    symbol,
    timestamp,
    actual_price,
    predicted_price,
    CASE
        WHEN actual_price > predicted_price THEN 'BUY'
        WHEN actual_price < predicted_price THEN 'SELL'
        ELSE 'HOLD'
    END AS signal,
    created_at
FROM
(
    SELECT
        'EUR/USD' AS symbol,
        timestamp,
        actual_price,
        predicted_price,
        created_at,
        ROW_NUMBER() OVER (ORDER BY timestamp DESC) AS rn
    FROM forex_data.predictions_eur_usd

    UNION ALL

    SELECT
        'GBP/USD' AS symbol,
        timestamp,
        actual_price,
        predicted_price,
        created_at,
        ROW_NUMBER() OVER (ORDER BY timestamp DESC) AS rn
    FROM forex_data.predictions_gbp_usd

    UNION ALL

    SELECT
        'USD/JPY' AS symbol,
        timestamp,
        actual_price,
        predicted_price,
        created_at,
        ROW_NUMBER() OVER (ORDER BY timestamp DESC) AS rn
    FROM forex_data.predictions_usd_jpy
)
WHERE rn = 1
ORDER BY symbol ASC;

CREATE OR REPLACE VIEW forex_data.latest_signals
AS SELECT
    symbol,
    timestamp,
    actual_price,
    predicted_price,
    multiIf(actual_price > predicted_price, 'BUY', actual_price < predicted_price, 'SELL', 'HOLD') AS signal,
    created_at
FROM
(
    SELECT
        'EUR/USD' AS symbol,
        timestamp,
        actual_price,
        predicted_price,
        created_at,
        ROW_NUMBER() OVER (ORDER BY timestamp DESC) AS rn
    FROM forex_data.predictions_eur_usd
    UNION ALL
    SELECT
        'GBP/USD' AS symbol,
        timestamp,
        actual_price,
        predicted_price,
        created_at,
        ROW_NUMBER() OVER (ORDER BY timestamp DESC) AS rn
    FROM forex_data.predictions_gbp_usd
    UNION ALL
    SELECT
        'USD/JPY' AS symbol,
        timestamp,
        actual_price,
        predicted_price,
        created_at,
        ROW_NUMBER() OVER (ORDER BY timestamp DESC) AS rn
    FROM forex_data.predictions_usd_jpy
)
WHERE rn = 1
ORDER BY symbol ASC
