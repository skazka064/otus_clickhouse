### Установите ClickHouse
```bash
# Установить необходимые пакеты
apt-get install -y apt-transport-https ca-certificates curl gnupg
# Скачайте GPG-ключ ClickHouse и сохраните его в хранилище ключей
curl -fsSL 'https://packages.clickhouse.com/rpm/lts/repodata/repomd.xml.key' | sudo gpg --dearmor -o /usr/share/keyrings/clickhouse-keyring.gpg
# Получите архитектуру системы
ARCH=$(dpkg --print-architecture)
# Добавьте репозиторий ClickHouse в источники apt
echo "deb [signed-by=/usr/share/keyrings/clickhouse-keyring.gpg arch=${ARCH}] https://packages.clickhouse.com/deb stable main" | sudo tee /etc/apt/sources.list.d/clickhouse.list
# Обновите списки пакетов apt
sudo apt-get update
apt-get install -y clickhouse-server clickhouse-client
service clickhouse-server start
```

### Загрузите тестовый датасет и выполните выборку из таблицы

```
clickhouse-node.ru-central1.internal :) CREATE DATABASE nyc_taxi;

CREATE DATABASE nyc_taxi

Query id: 3071dd67-c12b-47cc-b7ad-cd00772930b1

Ok.

0 rows in set. Elapsed: 0.006 sec.

clickhouse-node.ru-central1.internal :) CREATE TABLE nyc_taxi.trips_small (
    trip_id             UInt32,
    pickup_datetime     DateTime,
    dropoff_datetime    DateTime,
    pickup_longitude    Nullable(Float64),
    pickup_latitude     Nullable(Float64),
    dropoff_longitude   Nullable(Float64),
    dropoff_latitude    Nullable(Float64),
    passenger_count     UInt8,
    trip_distance       Float32,
    fare_amount         Float32,
    extra               Float32,
    tip_amount          Float32,
    tolls_amount        Float32,
    total_amount        Float32,
    payment_type        Enum('CSH' = 1, 'CRE' = 2, 'NOC' = 3, 'DIS' = 4, 'UNK' = 5),
    pickup_ntaname      LowCardinality(String),
    dropoff_ntaname     LowCardinality(String)
)
ENGINE = MergeTree
PRIMARY KEY (pickup_datetime, dropoff_datetime);

CREATE TABLE nyc_taxi.trips_small
(
    `trip_id` UInt32,
    `pickup_datetime` DateTime,
    `dropoff_datetime` DateTime,
    `pickup_longitude` Nullable(Float64),
    `pickup_latitude` Nullable(Float64),
    `dropoff_longitude` Nullable(Float64),
    `dropoff_latitude` Nullable(Float64),
    `passenger_count` UInt8,
    `trip_distance` Float32,
    `fare_amount` Float32,
    `extra` Float32,
    `tip_amount` Float32,
    `tolls_amount` Float32,
    `total_amount` Float32,
    `payment_type` Enum('CSH' = 1, 'CRE' = 2, 'NOC' = 3, 'DIS' = 4, 'UNK' = 5),
    `pickup_ntaname` LowCardinality(String),
    `dropoff_ntaname` LowCardinality(String)
)
ENGINE = MergeTree
PRIMARY KEY (pickup_datetime, dropoff_datetime)

Query id: 14c6a757-e87e-4d9e-b79a-abfc6a5d7e3d

Ok.

0 rows in set. Elapsed: 0.010 sec.

clickhouse-node.ru-central1.internal :) INSERT INTO nyc_taxi.trips_small
SELECT
    trip_id,
    pickup_datetime,
    dropoff_datetime,
    pickup_longitude,
    pickup_latitude,
    dropoff_longitude,
    dropoff_latitude,
    passenger_count,
    trip_distance,
    fare_amount,
    extra,
    tip_amount,
    tolls_amount,
    total_amount,
    payment_type,
    pickup_ntaname,
    dropoff_ntaname
FROM gcs(
    'https://storage.googleapis.com/clickhouse-public-datasets/nyc-taxi/trips_{0..2}.gz',
    'TabSeparatedWithNames'
);

INSERT INTO nyc_taxi.trips_small SELECT
    trip_id,
    pickup_datetime,
    dropoff_datetime,
    pickup_longitude,
    pickup_latitude,
    dropoff_longitude,
    dropoff_latitude,
    passenger_count,
    trip_distance,
    fare_amount,
    extra,
    tip_amount,
    tolls_amount,
    total_amount,
    payment_type,
    pickup_ntaname,
    dropoff_ntaname
FROM gcs('https://storage.googleapis.com/clickhouse-public-datasets/nyc-taxi/trips_{0..2}.gz', 'TabSeparatedWithNames')

Query id: e436cba2-89ca-41f4-9af3-8cc5c72ca4de

Ok.

0 rows in set. Elapsed: 8.565 sec. Processed 3.00 million rows, 244.69 MB (350.29 thousand rows/s., 28.57 MB/s.)
Peak memory usage: 252.58 MiB.
```
## Выборка
```clickhouse-node.ru-central1.internal :) select * from nyc_taxi.trips_small limit 5;

SELECT *
FROM nyc_taxi.trips_small
LIMIT 5

Query id: c8230c8c-6c2f-41d5-b5b7-8e2d4cf434ca

Row 1:
──────
trip_id:           1201746944 -- 1.20 billion
pickup_datetime:   2015-07-01 00:00:12
dropoff_datetime:  2015-07-01 00:08:33
pickup_longitude:  -73.9787368774414
pickup_latitude:   40.78765869140625
dropoff_longitude: -73.96562194824219
dropoff_latitude:  40.80792999267578
passenger_count:   1
trip_distance:     1.78
fare_amount:       8.5
extra:             0.5
tip_amount:        1.96
tolls_amount:      0
total_amount:      11.76
payment_type:      CSH
pickup_ntaname:    Upper West Side
dropoff_ntaname:   Morningside Heights

Row 2:
──────
trip_id:           1200864931 -- 1.20 billion
pickup_datetime:   2015-07-01 00:00:13
dropoff_datetime:  2015-07-01 00:14:41
pickup_longitude:  -73.99046325683594
pickup_latitude:   40.746116638183594
dropoff_longitude: -73.97918701171875
dropoff_latitude:  40.78467559814453
passenger_count:   5
trip_distance:     3.54
fare_amount:       13.5
extra:             0.5
tip_amount:        1
tolls_amount:      0
total_amount:      15.8
payment_type:      CSH
pickup_ntaname:    Midtown-Midtown South
dropoff_ntaname:   Upper West Side

Row 3:
──────
trip_id:           1200018648 -- 1.20 billion
pickup_datetime:   2015-07-01 00:00:16
dropoff_datetime:  2015-07-01 00:02:57
pickup_longitude:  -73.78358459472656
pickup_latitude:   40.648677825927734
dropoff_longitude: -73.80242919921875
dropoff_latitude:  40.64767837524414
passenger_count:   1
trip_distance:     1.45
fare_amount:       6
extra:             0.5
tip_amount:        0
tolls_amount:      0
total_amount:      7.3
payment_type:      CRE
pickup_ntaname:    Airport
dropoff_ntaname:   Airport

Row 4:
──────
trip_id:           1201452450 -- 1.20 billion
pickup_datetime:   2015-07-01 00:00:20
dropoff_datetime:  2015-07-01 00:11:07
pickup_longitude:  -73.98579406738281
pickup_latitude:   40.72777557373047
dropoff_longitude: -74.00482177734375
dropoff_latitude:  40.73748779296875
passenger_count:   5
trip_distance:     1.56
fare_amount:       8.5
extra:             0.5
tip_amount:        1.96
tolls_amount:      0
total_amount:      11.76
payment_type:      CSH
pickup_ntaname:    East Village
dropoff_ntaname:   West Village

Row 5:
──────
trip_id:           1202368372 -- 1.20 billion
pickup_datetime:   2015-07-01 00:00:40
dropoff_datetime:  2015-07-01 00:05:46
pickup_longitude:  -74.00206756591797
pickup_latitude:   40.73833084106445
dropoff_longitude: -74.00658416748047
dropoff_latitude:  40.74875259399414
passenger_count:   2
trip_distance:     1
fare_amount:       6
extra:             0.5
tip_amount:        0
tolls_amount:      0
total_amount:      7.3
payment_type:      CRE
pickup_ntaname:    West Village
dropoff_ntaname:   Hudson Yards-Chelsea-Flatiron-Union Square

5 rows in set. Elapsed: 0.008 sec.

```

## Отправьте скриншоты работающего инстанса ClickHouse, созданной виртуальной машины (если выполняете работу в ЯО) и результата запроса: select count() from trips where payment_type = 1.

```
clickhouse-node.ru-central1.internal :) select count(*) from nyc_taxi.trips_small where payment_type=1;

SELECT count(*)
FROM nyc_taxi.trips_small
WHERE payment_type = 1

Query id: d63de8ad-7a8f-4eea-b206-caef8552e4a2

   ┌─count()─┐
1. │ 1850287 │ -- 1.85 million
   └─────────┘

1 row in set. Elapsed: 0.012 sec. Processed 3.00 million rows, 3.00 MB (241.72 million rows/s., 241.72 MB/s.)
Peak memory usage: 465.18 KiB.

clickhouse-node.ru-central1.internal :)
```

### Проведите тестирование производительности и сохраните результаты.

```
root@clickhouse-node:/home/yc-user# echo "select * from system.numbers limit 1000000 offset 1000000" | clickhouse-benchmark -h localhost --port 9000 -i 10
Loaded 1 queries.

Queries executed: 10 (100%).

localhost:9000, queries: 10, QPS: 29.207, RPS: 58413620.933, MiB/s: 445.661, result RPS: 29206810.466, result MiB/s: 222.830.

0%              0.019 sec.
10%             0.019 sec.
20%             0.020 sec.
30%             0.020 sec.
40%             0.020 sec.
50%             0.020 sec.
60%             0.020 sec.
70%             0.021 sec.
80%             0.021 sec.
90%             0.021 sec.
95%             0.023 sec.
99%             0.023 sec.
99.9%           0.023 sec.
99.99%          0.023 sec.
```











