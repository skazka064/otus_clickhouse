### Замена табуляции на точку с запятой
sed 's/ \t/;/g' /home/yc-user/sales_log.csv > /home/yc-user/sales_log_clean.csv
### Работа с функциями
```sql
SELECT
    toYear(toDateTime('2025-07-27 15:45:21')) AS _year,
    toMonth(toDateTime('2025-07-27 15:45:21')) AS _month,
    toDayOfYear(toDateTime('2025-07-27 15:45:21')) AS day_of_year,
    toDayOfMonth(toDateTime('2025-07-27 15:45:21')) AS day_of_month,
    toDayOfWeek(toDateTime('2025-07-27 15:45:21')) AS day_of_week,
    toHour(toDateTime('2025-07-27 15:45:21')) AS _hour;

SELECT
    toStartOfYear(toDateTime('2025-07-27 15:45:21')) AS start_of_year,
    toStartOfMonth(toDateTime('2025-07-27 15:45:21')) AS start_of_month,
    toStartOfDay(toDateTime('2025-07-27 15:45:21')) AS start_of_day,
    toStartOfHour(toDateTime('2025-07-27 15:45:21')) AS start_of_hour;
```
