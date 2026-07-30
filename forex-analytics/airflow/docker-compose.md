
---

## Компоненты Airflow Cluster

### База данных и брокер

| Компонент | Назначение | Описание |
|-----------|------------|----------|
| **PostgreSQL** | База данных | Хранит метаданные DAG, задачи, запуски, переменные |
| **Redis** | Брокер сообщений | Очередь для распределения задач между workers |
| **Flower** | Мониторинг | Веб-интерфейс для отслеживания очередей и worker'ов |

### Сервисы Airflow

| Сервис | Назначение | Роль в кластере |
|--------|------------|-----------------|
| **apiserver (Web UI)** | Веб-интерфейс | Управление DAG, просмотр логов, ручной запуск |
| **scheduler** | Планировщик | Запускает задачи по расписанию, следит за зависимостями |
| **worker** | Исполнитель | Выполняет задачи (операторы) из очереди Redis |
| **dag-processor** | Обработчик | Сканирует папку dags, парсит DAG-файлы |
| **triggerer** | Триггеры | Обрабатывает асинхронные задачи (deferrable operators) |
| **init** | Инициализация | Первичная настройка: создание таблиц, миграции БД |

---

## Схема взаимодействия

```mermaid
graph TD
    subgraph INFRA[Инфраструктура]
        PG[(PostgreSQL)]
        REDIS[(Redis)]
        FLOWER[Flower]
    end
    
    subgraph SERVICES[Сервисы Airflow]
        WEB[apiserver<br/>Web UI]
        SCH[scheduler<br/>планировщик]
        PROC[dag-processor<br/>обработчик]
        WORKER[worker<br/>исполнитель]
        TRIG[triggerer<br/>триггеры]
        INIT[init<br/>инициализация]
    end
    
    PROC -->|чтение| DAGS[Файлы DAG]
    SCH -->|планирует| REDIS
    REDIS -->|отдаёт задачи| WORKER
    WORKER -->|результат| PG
    WEB -->|запросы| PG
    SCH -->|метаданные| PG
    TRIG -->|отложенные задачи| WORKER
```
```mermaid
graph TD
    DEV["Developer"] -->|upload DAG| DAGS["dags folder"]
    PROC["Dag-Processor"] -->|scan| DAGS
    PROC -->|parse| PG[("PostgreSQL")]
    SCH["Scheduler"] -->|read schedule| PG
    SCH -->|create tasks| REDIS["Redis"]
    SCH -->|update status| PG
    REDIS -->|take tasks| W1["Worker 1"]
    REDIS -->|take tasks| W2["Worker 2"]
    REDIS -->|take tasks| W3["Worker N"]
    W1 -->|execute| DAGS
    W1 -->|write logs| LOGS["Logs"]
    W1 -->|save result| PG
    WEB["Web Server"] -->|read| PG
    WEB -->|display| UI["Web UI"]
    UI -->|manage| DEV
    FLOWER["Flower"] -->|monitor| REDIS
    FLOWER -->|show| UI
```
