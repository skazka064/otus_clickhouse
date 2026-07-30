
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

graph TD
    subgraph User["User"]
        Dev["Developer"]
        Ui["Web UI"]
    end

    subgraph Core["Airflow Core"]
        Sch["Scheduler"]
        Proc["Dag Processor"]
        Web["Web Server"]
    end

    subgraph Exec["Execution"]
        Redis["Redis Queue"]
        W1["Worker 1"]
        W2["Worker 2"]
        W3["Worker N"]
    end

    subgraph Storage["Storage"]
        Pg[("PostgreSQL")]
        Dags["DAGs Folder"]
        Logs["Logs"]
    end

    subgraph Monitor["Monitoring"]
        Flower["Flower"]
    end

    Dev -->|upload| Dags
    Proc -->|scan| Dags
    Proc -->|parse| Pg

    Sch -->|read schedule| Pg
    Sch -->|create tasks| Redis
    Sch -->|update status| Pg

    Redis -->|take| W1
    Redis -->|take| W2
    Redis -->|take| W3

    W1 -->|execute| Dags
    W1 -->|write| Logs
    W1 -->|save| Pg

    Web -->|read| Pg
    Web -->|display| Ui
    Ui -->|manage| Dev

    Flower -->|monitor| Redis
    Flower -->|show| Ui
    
