# 1. Возьмите любой демонстрационный DATASET: https://clickhouse.com/docs/en/getting-started/example-datasets.
### Создал на хосте clickhouse-01 таблицу.

```
   CREATE TABLE amazon_reviews
(
    `review_date` Date,
    `marketplace` LowCardinality(String),
    `customer_id` UInt64,
    `review_id` String,
    `product_id` String,
    `product_parent` UInt64,
    `product_title` String,
    `product_category` LowCardinality(String),
    `star_rating` UInt8,
    `helpful_votes` UInt32,
    `total_votes` UInt32,
    `vine` Bool,
    `verified_purchase` Bool,
    `review_headline` String,
    `review_body` String,
    PROJECTION helpful_votes
    (
        SELECT *
        ORDER BY helpful_votes
    )
)
ENGINE = MergeTree
```

### Вставил данные из датасета

```
INSERT INTO amazon_reviews SELECT *
FROM s3('https://datasets-documentation.s3.eu-west-3.amazonaws.com/amazon_reviews/amazon_reviews_*.snappy.parquet') limit 1000
```

### Проверил

```
select * from amazon_reviews limit 3
```

|review_date|marketplace|customer_id|review_id|product_id|product_parent|product_title|product_category|star_rating|helpful_votes|total_votes|vine|verified_purchase|review_headline|review_body|
|-----------|-----------|-----------|---------|----------|--------------|-------------|----------------|-----------|-------------|-----------|----|-----------------|---------------|-----------|
|1995-06-24|US|53096571|RHL4UW17ZK72A|0521314925|980601331|Invention and Evolution:Design|Books|5|9|9|false|false|BUY THIS BOOK!|This is a beautiful book.|
|1995-06-24|US|53096571|R34N4QWDXX58WB|0870210092|442607382|Arming and Fitting of |Books|4|12|13|false|false|good enough|
|1995-07-07|US|53096573|RPLV77JZXG575|047194128X|377091465|Object-Oriented Type Systems|Books|4|4|4|false|false|Good techniques, well written.|The best 

### Затем посмотрел как создана таблица

```
clickhouse-01 :) show create table amazon_reviews;

SHOW CREATE TABLE amazon_reviews

Query id: e30e3933-a7d4-421e-90e4-ae70a08f2ccd

   ┌─statement──────────────────────────────────────┐
1. │ CREATE TABLE default.amazon_reviews           ↴│
   │↳(                                             ↴│
   │↳    `review_date` Date,                       ↴│
   │↳    `marketplace` LowCardinality(String),     ↴│
   │↳    `customer_id` UInt64,                     ↴│
   │↳    `review_id` String,                       ↴│
   │↳    `product_id` String,                      ↴│
   │↳    `product_parent` UInt64,                  ↴│
   │↳    `product_title` String,                   ↴│
   │↳    `product_category` LowCardinality(String),↴│
   │↳    `star_rating` UInt8,                      ↴│
   │↳    `helpful_votes` UInt32,                   ↴│
   │↳    `total_votes` UInt32,                     ↴│
   │↳    `vine` Bool,                              ↴│
   │↳    `verified_purchase` Bool,                 ↴│
   │↳    `review_headline` String,                 ↴│
   │↳    `review_body` String,                     ↴│
   │↳    PROJECTION helpful_votes                  ↴│
   │↳    (                                         ↴│
   │↳        SELECT *                              ↴│
   │↳        ORDER BY helpful_votes                ↴│
   │↳    )                                         ↴│
   │↳)                                             ↴│
   │↳ENGINE = MergeTree                            ↴│
   │↳ORDER BY (review_date, product_category)      ↴│
   │↳SETTINGS index_granularity = 8192              │
   └────────────────────────────────────────────────┘

1 row in set. Elapsed: 0.002 sec.

clickhouse-01 :)


```

### Проверяю настройку макросов

```
SELECT * FROM system.macros;
```
|macro|substitution|
|-----|------------|
|replica|clickhouse-01|
|shard|01|






### Создаю на clickhouse-01 таблицу с движком ReplicatedMergeTree

```

CREATE TABLE amazon_reviews_repl
(
    `review_date` Date,
    `marketplace` LowCardinality(String),
    `customer_id` UInt64,
    `review_id` String,
    `product_id` String,
    `product_parent` UInt64,
    `product_title` String,
    `product_category` LowCardinality(String),
    `star_rating` UInt8,
    `helpful_votes` UInt32,
    `total_votes` UInt32,
    `vine` Bool,
    `verified_purchase` Bool,
    `review_headline` String,
    `review_body` String,
    PROJECTION helpful_votes
    (
        SELECT *
        ORDER BY helpful_votes
    )
)
ENGINE = ReplicatedMergeTree(
    '/clickhouse/tables/amazon_reviews',  
    '{replica}'                                           
)
ORDER BY (review_date, product_category);

```

### Заливаю данные в реплицированную таблицу

```
clickhouse-01 :) INSERT INTO amazon_reviews_repl
:-] SELECT * FROM amazon_reviews;

INSERT INTO amazon_reviews_repl SELECT *
FROM amazon_reviews

Query id: f901042d-8a15-4ee6-80bd-8527742f8c21

Ok.

1000 rows in set. Elapsed: 0.046 sec. Processed 1.00 thousand rows, 729.50 KB (21.84 thousand rows/s., 15.94 MB/s.)
Peak memory usage: 8.82 MiB.
```

### Проверяю репликацию и вставку данных

```
clickhouse-01 :) SELECT
    database,
    table,
    engine,
    replica_name,
    total_replicas,
    active_replicas
FROM system.replicas
WHERE table = 'amazon_reviews_repl';

SELECT
    database,
    `table`,
    engine,
    replica_name,
    total_replicas,
    active_replicas
FROM system.replicas
WHERE `table` = 'amazon_reviews_repl'

Query id: daa4252a-ea22-4424-bb86-15ffe418ffe1

   ┌─database─┬─table───────────────┬─engine──────────────┬─replica_name──┬─total_replicas─┬─active_replicas─┐
1. │ default  │ amazon_reviews_repl │ ReplicatedMergeTree │ clickhouse-01 │              1 │               1 │
   └──────────┴─────────────────────┴─────────────────────┴───────────────┴────────────────┴─────────────────┘

1 row in set. Elapsed: 0.005 sec.

clickhouse-01 :) select * from amazon_reviews_repl limit 3

SELECT *
FROM amazon_reviews_repl
LIMIT 3

Query id: ca097a40-2fde-4afc-96a2-6e9f23b2860a

Row 1:
──────
review_date:       1995-06-24
marketplace:       US
customer_id:       53096571 -- 53.10 million
review_id:         RHL4UW17ZK72A
product_id:        0521314925
product_parent:    980601331 -- 980.60 million
product_title:     Invention and Evolution:Design in Nature and Engineering
................................
```

### Подключаюсь к clickhouse-02
### Проверяю настройку макросов
### Создаю такую же реплицированную таблицу
### Проверяю что данные подтянулись

```
clickhouse-02 :) SELECT * FROM system.macros;

SELECT *
FROM system.macros

Query id: 4c80cf81-18f1-4be7-b52d-aa3785097447

   ┌─macro───┬─substitution──┐
1. │ replica │ clickhouse-02 │
2. │ shard   │ 01            │
   └─────────┴───────────────┘

2 rows in set. Elapsed: 0.002 sec.

clickhouse-02 :) CREATE TABLE amazon_reviews_repl
:-] (
:-]     `review_date` Date,
:-]     `marketplace` LowCardinality(String),
:-]     `customer_id` UInt64,
:-]     `review_id` String,
:-]     `product_id` String,
:-]     `product_parent` UInt64,
:-]     `product_title` String,
:-]     `product_category` LowCardinality(String),
:-]     `star_rating` UInt8,
:-]     `helpful_votes` UInt32,
:-]     `total_votes` UInt32,
:-]     `vine` Bool,
:-]     `verified_purchase` Bool,
:-]     `review_headline` String,
:-]     `review_body` String,
:-]     PROJECTION helpful_votes
:-]     (
:-]         SELECT *
:-]         ORDER BY helpful_votes
:-]     )
:-] )
:-] ENGINE = ReplicatedMergeTree(
:-]     '/clickhouse/tables/amazon_reviews',  -- путь в ZooKeeper
:-]     '{replica}'                                            -- имя реплики
:-] )
:-] ORDER BY (review_date, product_category);

CREATE TABLE amazon_reviews_repl
(
    `review_date` Date,
    `marketplace` LowCardinality(String),
    `customer_id` UInt64,
    `review_id` String,
    `product_id` String,
    `product_parent` UInt64,
    `product_title` String,
    `product_category` LowCardinality(String),
    `star_rating` UInt8,
    `helpful_votes` UInt32,
    `total_votes` UInt32,
    `vine` Bool,
    `verified_purchase` Bool,
    `review_headline` String,
    `review_body` String,
    PROJECTION helpful_votes
    (
        SELECT *
        ORDER BY helpful_votes
    )
)
ENGINE = ReplicatedMergeTree('/clickhouse/tables/amazon_reviews', '{replica}')
ORDER BY (review_date, product_category)

Query id: fbb1c679-44a7-402d-b5b6-1082c573391c

Ok.

0 rows in set. Elapsed: 0.087 sec.

clickhouse-02 :) select * from amazon_reviews_repl limit 3

SELECT *
FROM amazon_reviews_repl
LIMIT 3

Query id: d84af5ad-e422-40e7-af1b-91a45dee4a42

Row 1:
──────
review_date:       1995-06-24
marketplace:       US
customer_id:       53096571 -- 53.10 million
review_id:         RHL4UW17ZK72A
product_id:        0521314925
product_parent:    980601331 -- 980.60 million
product_title:     Invention and Evolution:Design in Nature and Engineering
product_category:  Books
star_rating:       5



````

### Проделываю тоже самое с clickhouse-03

```

clickhouse-03 :) SELECT * FROM system.macros;

SELECT *
FROM system.macros

Query id: 2c8d9773-1fbf-4d85-a906-adfd586cb9c6

   ┌─macro───┬─substitution──┐
1. │ replica │ clickhouse-03 │
2. │ shard   │ 01            │
   └─────────┴───────────────┘

2 rows in set. Elapsed: 0.002 sec.

clickhouse-03 :) CREATE TABLE amazon_reviews_repl
:-] (
:-]     `review_date` Date,
:-]     `marketplace` LowCardinality(String),
:-]     `customer_id` UInt64,
:-]     `review_id` String,
:-]     `product_id` String,
:-]     `product_parent` UInt64,
:-]     `product_title` String,
:-]     `product_category` LowCardinality(String),
:-]     `star_rating` UInt8,
:-]     `helpful_votes` UInt32,
:-]     `total_votes` UInt32,
:-]     `vine` Bool,
:-]     `verified_purchase` Bool,
:-]     `review_headline` String,
:-]     `review_body` String,
:-]     PROJECTION helpful_votes
:-]     (
:-]         SELECT *
:-]         ORDER BY helpful_votes
:-]     )
:-] )
:-] ENGINE = ReplicatedMergeTree(
:-]     '/clickhouse/tables/amazon_reviews',  -- путь в ZooKeeper
:-]     '{replica}'                                            -- имя реплики
:-] )
:-] ORDER BY (review_date, product_category);

CREATE TABLE amazon_reviews_repl
(
    `review_date` Date,
    `marketplace` LowCardinality(String),
    `customer_id` UInt64,
    `review_id` String,
    `product_id` String,
    `product_parent` UInt64,
    `product_title` String,
    `product_category` LowCardinality(String),
    `star_rating` UInt8,
    `helpful_votes` UInt32,
    `total_votes` UInt32,
    `vine` Bool,
    `verified_purchase` Bool,
    `review_headline` String,
    `review_body` String,
    PROJECTION helpful_votes
    (
        SELECT *
        ORDER BY helpful_votes
    )
)
ENGINE = ReplicatedMergeTree('/clickhouse/tables/amazon_reviews', '{replica}')
ORDER BY (review_date, product_category)

Query id: b4477904-cd7d-4359-b68d-3dd2fcce43c8

Ok.

0 rows in set. Elapsed: 0.073 sec.

clickhouse-03 :) select * from amazon_reviews_repl limit 3

SELECT *
FROM amazon_reviews_repl
LIMIT 3

Query id: 07f9c7b9-8e3f-44f2-8591-6f451e0c8bde

Row 1:
──────
review_date:       1995-06-24
marketplace:       US
customer_id:       53096571 -- 53.10 million
review_id:         RHL4UW17ZK72A
product_id:        0521314925
product_parent:    980601331 -- 980.60 million
product_title:     Invention and Evolution:Design in Nature and Engineering
product_category:  Books
star_rating:       5
helpful_votes:     9
total_votes:       9
vine:              false
verified_purchase: false
review_headline:   BUY THIS BOOK!
review_body:       This is a beautiful book.  French talks about energy, form, mechanism, and economy in natural and man-made things.  He compares birds to planes in terms of fuel-capacity, energy  conversion efficiency, drag, etc.  He compares suspension   bridges and dinosaurs.  He p
rovides examples of neat   inventions and the thought that has gone into them (every-  thing from steam-catapults to toy cars to grommets).  This  is &quot;How Things Work&quot; for the non-moron crowd.

Row 2:
──────
review_date:       1995-06-24
marketplace:       US
customer_id:       53096571 -- 53.10 million
review_id:         R34N4QWDXX58WB
product_id:        0870210092
product_parent:    442607382 -- 442.61 million
product_title:     Arming and Fitting of English Ships of War, 1600-1815
product_category:  Books
star_rating:       4
helpful_votes:     12
total_votes:       13
vine:              false
verified_purchase: false
review_headline:   good enough to understand all of Pat O'brien
review_body:       Nice diags, lucid explanations of rigging, guns, hull, etc. A lot of the pics also appear in &quot;Nelson's Navy&quot;, so if you  have that, don't bother.

Row 3:
──────
review_date:       1995-07-07
marketplace:       US
customer_id:       53096573 -- 53.10 million
review_id:         RPLV77JZXG575
product_id:        047194128X
product_parent:    377091465 -- 377.09 million
product_title:     Object-Oriented Type Systems
product_category:  Books
star_rating:       4
helpful_votes:     4
total_votes:       4
vine:              false
verified_purchase: false
review_headline:   Good techniques, well written.
review_body:       The best (and possibly only) book I've seen on the topic. I very much liked their approach of starting with a simplified language and adding the necessary features.  The algorithms are useful, well presented, and their  assumptions are laid out clearly.

3 rows in set. Elapsed: 0.005 sec. Processed 1.00 thousand rows, 729.50 KB (209.68 thousand rows/s., 152.96 MB/s.)
Peak memory usage: 1.42 MiB.

clickhouse-03 :)


```

### Выполните запросы и отдайте результаты как 2 файла:

### https://github.com/skazka064/otus_clickhouse/blob/main/repl_data.json

### https://github.com/skazka064/otus_clickhouse/blob/main/data.json

### Добавьте или выберите колонку с типом Date в таблице, добавьте TTL на таблицу «хранить последние 7 дней». 

```
 ALTER TABLE amazon_reviews_repl ON CLUSTER cluster_3_replicas
:-] MODIFY TTL review_date + INTERVAL 7 DAY;

ALTER TABLE amazon_reviews_repl ON CLUSTER cluster_3_replicas
    (MODIFY TTL review_date + toIntervalDay(7))

Query id: cc9e53c3-6428-4fd5-86bf-0f740b1b2ac3

   ┌─host──────────┬─port─┬─status─┬─error─┬─num_hosts_remaining─┬─num_hosts_active─┐
1. │ clickhouse-03 │ 9000 │      0 │       │                   2 │                0 │
2. │ clickhouse-02 │ 9000 │      0 │       │                   1 │                0 │
3. │ clickhouse-01 │ 9000 │      0 │       │                   0 │                0 │
   └───────────────┴──────┴────────┴───────┴─────────────────────┴──────────────────┘

SHOW CREATE TABLE amazon_reviews_repl

Query id: 56668d9e-ec4c-4404-bf4f-b74e10dbfc27

   ┌─statement──────────────────────────────────────────────────────────────────────┐
1. │ CREATE TABLE default.amazon_reviews_repl                                      ↴│
   │↳(                                                                             ↴│
   │↳    `review_date` Date,                                                       ↴│
   │↳    `marketplace` LowCardinality(String),                                     ↴│
   │↳    `customer_id` UInt64,                                                     ↴│
   │↳    `review_id` String,                                                       ↴│
   │↳    `product_id` String,                                                      ↴│
   │↳    `product_parent` UInt64,                                                  ↴│
   │↳    `product_title` String,                                                   ↴│
   │↳    `product_category` LowCardinality(String),                                ↴│
   │↳    `star_rating` UInt8,                                                      ↴│
   │↳    `helpful_votes` UInt32,                                                   ↴│
   │↳    `total_votes` UInt32,                                                     ↴│
   │↳    `vine` Bool,                                                              ↴│
   │↳    `verified_purchase` Bool,                                                 ↴│
   │↳    `review_headline` String,                                                 ↴│
   │↳    `review_body` String,                                                     ↴│
   │↳    PROJECTION helpful_votes                                                  ↴│
   │↳    (                                                                         ↴│
   │↳        SELECT *                                                              ↴│
   │↳        ORDER BY helpful_votes                                                ↴│
   │↳    )                                                                         ↴│
   │↳)                                                                             ↴│
   │↳ENGINE = ReplicatedMergeTree('/clickhouse/tables/amazon_reviews', '{replica}')↴│
   │↳ORDER BY (review_date, product_category)                                      ↴│
   │↳TTL review_date + toIntervalDay(7)                                            ↴│
   │↳SETTINGS index_granularity = 8192                                              │
   └────────────────────────────────────────────────────────────────────────────────┘

1 row in set. Elapsed: 0.002 sec.

clickhouse-01 :)

```
### Создал replicated таблицу на всех нодах

```
CREATE TABLE test_local ON CLUSTER cluster_2S_2R (
    dummy UInt8,
    hostname String DEFAULT hostName()
) ENGINE = ReplicatedMergeTree(
    '/clickhouse/tables/{shard}/test_local',
    '{replica}'
) ORDER BY dummy;
```
### Создал Distributed таблицу для test_local

```
CREATE TABLE test_distributed_full_2 ON CLUSTER cluster_2S_2R (
    dummy UInt8,
    hostname String DEFAULT hostName()
) ENGINE = Distributed('cluster_2S_2R', 'default', 'test_local', rand());
```
### Вставил данные

```
clickhouse-01 :) INSERT INTO test_distributed_full_2 (dummy)
:-] SELECT number % 20
:-] FROM numbers(1000);

INSERT INTO test_distributed_full_2 (dummy) SELECT number % 20
FROM numbers(1000)

Query id: 30407416-f42f-45c1-9e08-bb73a998a3d1

Ok.

1490 rows in set. Elapsed: 0.017 sec. Processed 1.00 thousand rows, 8.00 KB (57.78 thousand rows/s., 462.26 KB/s.)
Peak memory usage: 3.40 MiB.
```

### Смотрим как данные распределились по шардам

```

clickhouse-01 :) SELECT
:-]     _shard_num,
:-]     hostname,
:-]     COUNT(*) as rows
:-] FROM test_distributed_full_2
:-] GROUP BY _shard_num, hostname
:-] ORDER BY _shard_num, hostname;

SELECT
    _shard_num,
    hostname,
    COUNT(*) AS rows
FROM test_distributed_full_2
GROUP BY
    _shard_num,
    hostname
ORDER BY
    _shard_num ASC,
    hostname ASC

Query id: 64c1285b-964d-44c1-a1e0-cc6586aa0ceb

   ┌─_shard_num─┬─hostname──────┬─rows─┐
1. │          1 │ clickhouse-01 │  490 │
2. │          2 │ clickhouse-01 │  510 │
   └────────────┴───────────────┴──────┘

2 rows in set. Elapsed: 0.010 sec. Processed 1.00 thousand rows, 15.00 KB (100.13 thousand rows/s., 1.50 MB/s.)
Peak memory usage: 652.07 KiB.
```

### Проверяем на каждой ноде количество вставленных данных

```
clickhouse-01 :) SELECT hostName(), COUNT(*) FROM test_local;

SELECT
    hostName(),
    COUNT(*)
FROM test_local

Query id: d465c660-81e4-483a-b93b-a2abbec2012b

   ┌─hostName()────┬─COUNT()─┐
1. │ clickhouse-01 │     490 │
   └───────────────┴─────────┘

1 row in set. Elapsed: 0.003 sec.

clickhouse-02 :) SELECT hostName(), COUNT(*) FROM test_local;

SELECT
    hostName(),
    COUNT(*)
FROM test_local

Query id: a25bb00d-9272-4376-b484-0e2898c2a344

   ┌─hostName()────┬─COUNT()─┐
1. │ clickhouse-02 │     490 │
   └───────────────┴─────────┘

1 row in set. Elapsed: 0.002 sec.

clickhouse-02 :)


clickhouse-03 :) SELECT hostName(), COUNT(*) FROM test_local;

SELECT
    hostName(),
    COUNT(*)
FROM test_local

Query id: 6c4b5c62-2d1c-4e9c-9e5d-25c7816c8336

   ┌─hostName()────┬─COUNT()─┐
1. │ clickhouse-03 │     510 │
   └───────────────┴─────────┘

1 row in set. Elapsed: 0.003 sec.

clickhouse-03 :)


clickhouse-04 :) SELECT hostName(), COUNT(*) FROM test_local;

SELECT
    hostName(),
    COUNT(*)
FROM test_local

Query id: 8cc29d15-8f86-43e0-9d11-9bf647e018a4

   ┌─hostName()────┬─COUNT()─┐
1. │ clickhouse-04 │     510 │
   └───────────────┴─────────┘

1 row in set. Elapsed: 0.003 sec.

clickhouse-04 :)


```






















