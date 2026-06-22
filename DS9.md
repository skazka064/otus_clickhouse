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






### Создаю на clickhouse-01 таблицу с движком ReplacedMergeTree

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
```





























