## Создание таблицы:
```sql
CREATE TABLE sales (
    id UInt32,
    product_id UInt32,
    quantity UInt32,
    price Float32,
    sale_date DateTime
) ENGINE = MergeTree()
ORDER BY (sale_date, product_id);

```
## Заполнение тестовыми данными (100 000 записей)
```
INSERT INTO sales 
SELECT 
    number AS id,
    (number % 100) + 1 AS product_id,  -- 100 различных продуктов
    (number % 100) + 1 AS quantity,     -- количество от 1 до 100
    (number % 1000) * 1.5 AS price,     -- цена от 0 до 1498.5
    toDateTime('2024-01-01 00:00:00') + (number % 1000000) AS sale_date
```

## Создание проекции (которая будет агрегировать данные по product_id и считать общую сумму продаж (количество и сумма по цене) за каждый продукт)
```
ALTER TABLE sales ADD PROJECTION sales_projection
(
    SELECT 
        product_id,
        sum(quantity) AS total_quantity,
        sum(quantity * price) AS total_sales,
        count() AS number_of_sales
    GROUP BY product_id
);
ALTER TABLE sales MATERIALIZE PROJECTION sales_projection;
```
## Создание материализованного представления:
```
-- Создание целевой таблицы для материализованного представления
CREATE TABLE sales_aggregated
(
    product_id UInt32,
    total_quantity UInt64,
    total_sales Float64,
    number_of_sales UInt64,
    updated_at DateTime DEFAULT now()
)
ENGINE = SummingMergeTree()
ORDER BY product_id;

-- Создание материализованного представления
CREATE MATERIALIZED VIEW sales_mv
TO sales_aggregated
AS
SELECT 
    product_id,
    sum(quantity) AS total_quantity,
    sum(quantity * price) AS total_sales,
    count() AS number_of_sales
FROM sales
GROUP BY product_id;
```

## Запросы к данным:

SELECT 
    product_id,
    sum(quantity) AS total_quantity,
    sum(quantity * price) AS total_sales
FROM sales
GROUP BY product_id;

## Сравнение производительности:
```
-- Включение таймингов
SET send_logs_level = 'trace';

-- Запрос 1: К основной таблице
SELECT 
    product_id,
    sum(quantity) AS total_quantity,
    sum(quantity * price) AS total_sales
FROM sales
GROUP BY product_id;

-- Запрос 2: С использованием проекции (оптимизатор должен выбрать её автоматически)
SELECT 
    product_id,
    sum(quantity) AS total_quantity,
    sum(quantity * price) AS total_sales
FROM sales
GROUP BY product_id;

-- Проверка, используется ли проекция
EXPLAIN SELECT 
    product_id,
    sum(quantity) AS total_quantity,
    sum(quantity * price) AS total_sales
FROM sales
GROUP BY product_id;

-- Запрос 3: К материализованному представлению
SELECT 
    product_id,
    total_quantity,
    total_sales
FROM sales_aggregated;
```
|query|query_duration_ms|read_rows|read_bytes|result_rows|
|-----|-----------------|---------|----------|-----------|
|SELECT 
    query,
    query_duration_ms,
    read_rows,
    read_bytes,
    result_rows
FROM system.query_log
WHERE type = 'QueryFinish'
  AND query LIKE '%sales%'
  AND event_time > now() - INTERVAL 1 HOUR
ORDER BY event_time DESC
LIMIT 13|9|2302|1044919|13|
|SELECT 
    query,
    query_duration_ms,
    read_rows,
    read_bytes,
    result_rows
FROM system.query_log
WHERE type = 'QueryFinish'
  AND query LIKE '%sales%'
  AND event_time > now() - INTERVAL 1 HOUR
ORDER BY event_time DESC
LIMIT 10|8|2300|1036717|10|
|SELECT 
    query,
    query_duration_ms,
    read_rows,
    read_bytes,
    result_rows
FROM system.query_log
WHERE type = 'QueryFinish'
  AND query LIKE '%sales%'
  AND event_time > now() - INTERVAL 1 HOUR
ORDER BY event_time DESC
LIMIT 10|12|2296|1035213|10|
|SELECT 
    product_id,
    total_quantity,
    total_sales
FROM sales_aggregated
LIMIT 0, 200|2|100|2000|100|
|EXPLAIN SELECT 
    product_id,
    sum(quantity) AS total_quantity,
    sum(quantity * price) AS total_sales
FROM sales
GROUP BY product_id|3|4|142|4|
|SELECT 
    product_id,
    sum(quantity) AS total_quantity,
    sum(quantity * price) AS total_sales
FROM sales
GROUP BY product_id
LIMIT 0, 200|5|200|7200|100|
|SELECT 
    product_id,
    sum(quantity) AS total_quantity,
    sum(quantity * price) AS total_sales
FROM sales
GROUP BY product_id
LIMIT 0, 200|5|200|7200|100|
|SELECT 
    product_id,
    total_quantity,
    total_sales
FROM sales_aggregated
ORDER BY product_id

LIMIT 0, 200|2|100|2000|100|
|INSERT INTO sales 
SELECT 
    number AS id,
    (number % 100) + 1 AS product_id,  -- 100 различных продуктов
    (number % 100) + 1 AS quantity,     -- количество от 1 до 100
    (number % 1000) * 1.5 AS price,     -- цена от 0 до 1498.5
    toDateTime('2024-01-01 00:00:00') + (number % 1000000) AS sale_date
FROM numbers(100000)|20|200000|2000000|100100|
|SELECT 
    product_id,
    total_quantity,
    total_sales
FROM sales_aggregated
ORDER BY product_id
LIMIT 0, 200|1|0|0|0|
|SELECT 
    product_id,
    total_quantity,
    total_sales
FROM sales_aggregated
ORDER BY product_id
LIMIT 0, 200|1|0|0|0|
|SELECT name AS TABLE_SCHEM, '' AS TABLE_CATALOG FROM system.databases WHERE name LIKE 'sales_aggregated'|1|10|155|0|
|SELECT '' AS TABLE_CAT, t.database AS TABLE_SCHEM, t.name AS TABLE_NAME, if(t.is_temporary = 1, concat('Temporary', t.engine), t.engine) AS TABLE_TYPE, t.comment AS REMARKS, CAST(null as Nullable(String)) AS TYPE_CAT, d.engine AS TYPE_SCHEM, CAST(null as Nullable(String)) AS TYPE_NAME, CAST(null as Nullable(String)) AS SELF_REFERENCING_COL_NAME, CAST(null as Nullable(String)) AS REF_GENERATION FROM system.tables t JOIN system.databases d ON system.tables.database = system.databases.name WHERE t.database LIKE 'default' AND t.name LIKE 'sales_aggregated' AND ( (t.engine IN ('ReplicatedMergeTree','SharedCoalescingMergeTree','Null','WindowView','TimeSeries','FuzzJSON','ReplicatedAggregatingMergeTree','GenerateRandom','Memory','PostgreSQL','LiveView','DeltaLakeAzure','AzureBlobStorage','VersionedCollapsingMergeTree','IcebergHDFS','MySQL','SQLite','Executable','IcebergAzure','Buffer','SharedReplacingMergeTree','SharedMergeTree','Log','SharedVersionedCollapsingMergeTree','SharedAggregatingMergeTree','CoalescingMergeTree','FuzzQuery','MaterializedPostgreSQL','ReplicatedCollapsingMergeTree','SummingMergeTree','SharedSet','Hive','EmbeddedRocksDB','MongoDB','MergeTree','SharedGraphiteMergeTree','YTsaurus','SharedJoin','File','IcebergLocal','S3','Dictionary','Set','ArrowFlight','SharedCollapsingMergeTree','Kafka','ReplicatedVersionedCollapsingMergeTree','FileLog','ReplicatedSummingMergeTree','URL','IcebergS3','Hudi','DeltaLakeS3','StripeLog','DeltaLake','ReplacingMergeTree','NATS','COSN','JDBC','AzureQueue','SharedSummingMergeTree','Loop','CollapsingMergeTree','ExecutablePool','ReplicatedGraphiteMergeTree','HDFS','Redis','S3Queue','AggregatingMergeTree','Join','ReplicatedReplacingMergeTree','View','OSS','RabbitMQ','GraphiteMergeTree','KeeperMap','ODBC','Merge','GCS','Alias','Distributed','Iceberg','TinyLog','MaterializedView','ReplicatedCoalescingMergeTree','DeltaLakeLocal')) OR (t.engine NOT IN ('ReplicatedMergeTree','SharedCoalescingMergeTree','Null','WindowView','TimeSeries','FuzzJSON','ReplicatedAggregatingMergeTree','GenerateRandom','Memory','PostgreSQL','LiveView','DeltaLakeAzure','AzureBlobStorage','VersionedCollapsingMergeTree','IcebergHDFS','MySQL','SQLite','Executable','IcebergAzure','Buffer','SharedReplacingMergeTree','SharedMergeTree','Log','SharedVersionedCollapsingMergeTree','SharedAggregatingMergeTree','CoalescingMergeTree','FuzzQuery','MaterializedPostgreSQL','ReplicatedCollapsingMergeTree','SummingMergeTree','SharedSet','Hive','EmbeddedRocksDB','MongoDB','MergeTree','SharedGraphiteMergeTree','YTsaurus','SharedJoin','File','IcebergLocal','S3','Dictionary','Set','ArrowFlight','SharedCollapsingMergeTree','Kafka','ReplicatedVersionedCollapsingMergeTree','FileLog','ReplicatedSummingMergeTree','URL','IcebergS3','Hudi','DeltaLakeS3','StripeLog','DeltaLake','ReplacingMergeTree','NATS','COSN','JDBC','AzureQueue','SharedSummingMergeTree','Loop','CollapsingMergeTree','ExecutablePool','ReplicatedGraphiteMergeTree','HDFS','Redis','S3Queue','AggregatingMergeTree','Join','ReplicatedReplacingMergeTree','View','OSS','RabbitMQ','GraphiteMergeTree','KeeperMap','ODBC','Merge','GCS','Alias','Distributed','Iceberg','TinyLog','MaterializedView','ReplicatedCoalescingMergeTree','DeltaLakeLocal') AND NOT t.engine LIKE 'System%' AND NOT t.engine LIKE 'Async%' AND t.is_temporary = 0) OR (t.engine LIKE 'System%' OR t.engine LIKE 'Async%') OR (t.is_temporary = 1))|5|11|367|1|















