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






