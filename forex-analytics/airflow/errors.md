# 1. Принудительно активировать DAG через PostgreSQL
docker exec yc-user-postgres-1 psql -U airflow -c "
    UPDATE dag SET is_paused = false WHERE dag_id = 'forex_alpha_hourly';
"

# 2. Проверить, что обновилось
docker exec yc-user-postgres-1 psql -U airflow -c "
    SELECT dag_id, is_paused FROM dag WHERE dag_id = 'forex_alpha_hourly';
"
# 1. Перезапустить scheduler
docker compose restart airflow-scheduler

# 2. Подождать 15 секунд
sleep 15

# 3. Проверить статус в Airflow
docker exec yc-user-airflow-scheduler-1 airflow dags list | grep forex_alpha_hourly

# 1. Запустить DAG
docker exec yc-user-airflow-scheduler-1 airflow dags trigger forex_alpha_hourly

# 2. Подождать 5 секунд
sleep 5

# 3. Проверить данные в ClickHouse
curl -s "http://10.0.0.32:8123/?user=airflow_user&password=airflow_pass_2026&database=forex_data&query=SELECT%20*%20FROM%20ticks%20ORDER%20BY%20timestamp%20DESC%20LIMIT%205"

### То же самое только короче
```
# 1. Проверить статус
docker exec yc-user-airflow-scheduler-1 airflow dags list | grep forex_alpha_hourly

# 2. Если False — обновить напрямую
docker exec yc-user-postgres-1 psql -U airflow -c "
    UPDATE dag SET is_paused = false WHERE dag_id = 'forex_alpha_hourly';
"

# 3. Перезапустить scheduler
docker compose restart airflow-scheduler
```
