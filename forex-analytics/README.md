
#  Forex Analytics — Система аналитики в реальном времени

##  Описание проекта

Проект представляет собой полноценную платформу для сбора, хранения, обработки и визуализации данных о курсах валют в реальном времени.

**Ключевые компоненты:**

- **ClickHouse** — основное хранилище данных и движок для прогнозирования
- **Apache Airflow** — оркестрация ETL-пайплайнов (пакетная загрузка)
- **Apache Kafka** — потоковая загрузка данных в реальном времени
- **Apache Superset** — визуализация и дашборды

---

##  Архитектура

```mermaid
flowchart LR
    API[Forex API] --> AF[Airflow<br>Каждые 15 минут]
    API --> P[Kafka Producer<br>Каждые 1-2 секунды]
    
    AF --> CH[(ClickHouse<br>Таблица: ticks)]
    P --> K[Kafka Topic<br>forex_ticks]
    K --> CH_Stream[(ClickHouse<br>Таблица: ticks_kafka)]
    
    CH --> S[Superset<br>Дашборд]
    CH_Stream --> S
