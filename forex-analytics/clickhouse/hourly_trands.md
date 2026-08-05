### Этот запрос анализирует последние 24 часа тиковых данных и для каждой валютной пары определяет 
    - Последний час last_hour
    - Цену в последнем часе last_price
    - Тренд UP|DOWN|SIDEWAYS сравнивая цену последнего часа с ценой предыдущего часа
###

```    SELECT
    symbol,
    toStartOfHour(timestamp) AS hour,
    argMax(bid, timestamp) AS price
FROM forex_data.ticks
WHERE timestamp > (now() - toIntervalHour(24))
GROUP BY symbol, hour
```

### Что делает 
    - Берет все тики за последние 24 часа 
    - Группирует по символу и часу (например EUR/USD, 2026-08-05 14:00:00)
