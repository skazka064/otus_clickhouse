# Прогноз на основе скользящего среднего (Moving Average)
# График Forecast with Moving Average (линия Predicted)

Алгоритм
    Беру последние 10 значений курса
    Считаю их среднее арифметическое
    Это число и есть прогноз на следующий момент

   ```
    Последние 5 курсов USD/EUR:
0.873, 0.874, 0.872, 0.875, 0.873

Среднее = (0.873 + 0.874 + 0.872 + 0.875 + 0.873) / 5 = 0.8734

Прогноз: 0.8734

```

# Прогноз на 24 часа (Predictions_24H)
# График Predictions_24H — показывает, как может меняться курс в ближайшие сутки

### Алгоритм
Беру средний курс за последний час
Использую его как базовый прогноз
Добавляю небольшое случайное отклонение для реалистичности

### Создаю таблицу с прогнозом

```
CREATE TABLE forex_data.forex_predictions_table
ENGINE = MergeTree()
ORDER BY timestamp AS
SELECT 
    timestamp,
    bid AS actual_price,
    AVG(bid) OVER (ORDER BY timestamp ROWS BETWEEN 10 PRECEDING AND CURRENT ROW) AS predicted_price
FROM forex_data.ticks;

AVG(bid) OVER  — считаю среднее значение bid за последние 10 записей
ROWS BETWEEN 10 PRECEDING AND CURRENT ROW — беру текущую запись и 10 предыдущих
Полученное среднее сохраняю как predicted_price
```

###  Создаю метрики точности

```
CREATE TABLE forex_data.forex_metrics
ENGINE = MergeTree()
ORDER BY calculation_time AS
SELECT 
    now() AS calculation_time,
    AVG(ABS(actual_price - predicted_price)) AS mae,
    SQRT(AVG(POWER(actual_price - predicted_price, 2))) AS rmse,
    (1 - AVG(ABS(actual_price - predicted_price) / actual_price)) * 100 AS accuracy_percent
FROM forex_data.forex_predictions_table;

MAE (Mean Absolute Error) — средняя абсолютная ошибка. Показывает, насколько прогноз отклоняется от факта в среднем.
RMSE (Root Mean Square Error) — корень из средней квадратичной ошибки. Даёт больше веса большим ошибкам.
Accuracy — точность прогноза в процентах.
```

### Все таблицы созданы как материализованные представления — они автоматически пересчитываются при добавлении новых данных через Airflow









