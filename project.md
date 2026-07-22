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

    API[alphavantage.com] --> AF[Airflow<br>Каждые 15 минут]
    API[ws.finnhub.io] --> P[Kafka Producer<br>Каждые 1-2 секунды]
    
    AF --> CH[(ClickHouse<br>Таблица: ticks)]
    P --> K[Kafka Topic<br>forex_ticks]
    K --> CH_Stream[(ClickHouse<br>Таблица: ticks_kafka)]
    
    CH --> S[Superset<br>Дашборд]
    CH_Stream --> S














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

# KAFKA

```
yc compute instance create \
  --name kafka-01 \
  --zone ru-central1-a \
  --network-interface subnet-name=otus-subnet,nat-ip-version=ipv4 \
  --create-boot-disk image-family=ubuntu-2204-lts,image-folder-id=standard-images,size=30 \
  --cores 2 \
  --core-fraction 100 \
  --memory 4 \
  --ssh-key .ssh/yc/id_rsa.pub
```
### Установка Docker и Docker Compose

```
sudo apt update
sudo apt install -y docker.io docker-compose
sudo systemctl start docker
sudo systemctl enable docker
sudo usermod -aG docker $USER
```
### docker-compose

```
cat > docker-compose.yml << 'EOF'
version: '3'
services:
  zookeeper-kafka:
    image: confluentinc/cp-zookeeper:latest
    container_name: zookeeper-kafka
    hostname: zookeeper-kafka
    environment:
      ZOOKEEPER_CLIENT_PORT: 2182
      ZOOKEEPER_TICK_TIME: 2000
    ports:
      - "2182:2182"
    restart: unless-stopped

  kafka:
    image: confluentinc/cp-kafka:7.4.0
    container_name: kafka
    hostname: kafka
    depends_on:
      - zookeeper-kafka
    environment:
      KAFKA_BROKER_ID: 1
      KAFKA_ZOOKEEPER_CONNECT: zookeeper-kafka:2182
      KAFKA_ADVERTISED_LISTENERS: PLAINTEXT://10.0.0.21:9092
      KAFKA_LISTENERS: PLAINTEXT://0.0.0.0:9092
      KAFKA_OFFSETS_TOPIC_REPLICATION_FACTOR: 1
      KAFKA_AUTO_CREATE_TOPICS_ENABLE: "true"
      KAFKA_LISTENER_SECURITY_PROTOCOL_MAP: PLAINTEXT:PLAINTEXT
    ports:
      - "9092:9092"
    restart: unless-stopped

  kafka-ui:
    image: provectuslabs/kafka-ui:latest
    container_name: kafka-ui
    hostname: kafka-ui
    depends_on:
      - kafka
    environment:
      KAFKA_CLUSTERS_0_NAME: local
      KAFKA_CLUSTERS_0_BOOTSTRAPSERVERS: kafka:9092
      KAFKA_CLUSTERS_0_ZOOKEEPER: zookeeper-kafka:2182
    ports:
      - "8089:8080"
    restart: unless-stopped
EOF

```

### Запуск KAFKA

```
sudo apt install -y python3-pip
pip3 install kafka-python requests
docker-compose up -d
docker-compose ps
```
### Создал Producer

```
cat > producer.py << 'EOF'
#!/usr/bin/env python3
import json
import time
import requests
from kafka import KafkaProducer
from datetime import datetime

producer = KafkaProducer(
    bootstrap_servers='10.0.0.21:9092',
    value_serializer=lambda v: v.encode('utf-8')
)

def fetch_forex():
    url = 'https://api.exchangerate-api.com/v4/latest/USD'
    try:
        r = requests.get(url, timeout=10)
        data = r.json()
        if 'rates' in data:
            ts = datetime.now().strftime('%Y-%m-%d %H:%M:%S')
            for s in ['EUR', 'GBP', 'JPY']:
                if s in data['rates']:
                    rate = data['rates'][s]
                    bid = round(rate * 0.999, 6)
                    ask = round(rate * 1.001, 6)
                    csv_line = f"USD/{s},{bid},{ask},{ts}\n"
                    producer.send('forex_ticks', csv_line)
                    print(f' Sent CSV: {csv_line.strip()}')
    except Exception as e:
        print(f' Error: {e}')

if __name__ == '__main__':
    print(' Kafka Producer started (CSV format, every 10 seconds)')
    while True:
        fetch_forex()
        time.sleep(10)
EOF
```
### Запустил продюсера

```
python3 producer.py
 Kafka Producer started (CSV format, every 10 seconds)
 Sent CSV: USD/EUR,0.873126,0.874874,2026-07-19 13:40:57
 Sent CSV: USD/GBP,0.743256,0.744744,2026-07-19 13:40:57
 Sent CSV: USD/JPY,162.22761,162.55239,2026-07-19 13:40:57
```

### Настройка clickhouse-kafka

```
-- 1. Создаём отдельную таблицу для данных из Kafka
CREATE TABLE IF NOT EXISTS forex_data.ticks_kafka
(
    symbol String,
    bid Float64,
    ask Float64,
    timestamp DateTime
) ENGINE = MergeTree()
ORDER BY (symbol, timestamp);

-- 2. Создаём Kafka-очередь (читает из топика forex_ticks)
CREATE TABLE forex_data.kafka_queue
(
    symbol String,
    bid Float64,
    ask Float64,
    timestamp DateTime
) ENGINE = Kafka()
SETTINGS 
    kafka_broker_list = '10.0.0.21:9092',
    kafka_topic_list = 'forex_ticks',
    kafka_group_name = 'clickhouse_group',
    kafka_format = 'CSV';  -- <- формат CSV

-- 3. Создаём материализованное представление (автоматический перенос)
CREATE MATERIALIZED VIEW forex_data.kafka_to_ticks_kafka
TO forex_data.ticks_kafka AS
SELECT symbol, bid, ask, timestamp
FROM forex_data.kafka_queue;
```








