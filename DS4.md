# Создаем таблицу transactions
```
clickhouse-node.ru-central1.internal :) CREATE TABLE transactions (
:-]     transaction_id UInt32,
:-]     user_id UInt32,
:-]     product_id UInt32,
:-]     quantity UInt8,
:-]     price Float32,
:-]     transaction_date Date
:-] ) ENGINE = MergeTree()
:-] ORDER BY (transaction_id);

CREATE TABLE transactions
(
    `transaction_id` UInt32,
    `user_id` UInt32,
    `product_id` UInt32,
    `quantity` UInt8,
    `price` Float32,
    `transaction_date` Date
)
ENGINE = MergeTree
ORDER BY transaction_id

Query id: 72ad99ed-aa8d-4f85-b2e6-58ad72071c0a

Ok.

0 rows in set. Elapsed: 0.088 sec.

clickhouse-node.ru-central1.internal :)
```
# Вставляем тестовые данные
```
INSERT INTO transactions VALUES
(1, 101, 1, 2, 49.99, '2024-01-15'),
(2, 102, 2, 1, 199.99, '2024-01-16'),
(3, 103, 1, 3, 49.99, '2024-01-17'),
(4, 101, 3, 1, 299.50, '2024-01-18'),
(5, 104, 2, 2, 199.99, '2024-01-19'),
(6, 105, 4, 5, 9.99, '2024-01-20'),
(7, 102, 5, 1, 599.00, '2024-01-21'),
(8, 106, 3, 1, 299.50, '2024-01-22'),
(9, 107, 1, 1, 49.99, '2024-01-23'),
(10, 101, 6, 2, 149.75, '2024-01-24');
```

```
clickhouse-node.ru-central1.internal :) select * from transactions

SELECT *
FROM transactions

Query id: e17b4e69-1cca-485f-b892-0a02d9fd50fd

    ┌─transaction_id─┬─user_id─┬─product_id─┬─quantity─┬──price─┬─transaction_date─┐
 1. │              1 │     101 │          1 │        2 │  49.99 │       2024-01-15 │
 2. │              2 │     102 │          2 │        1 │ 199.99 │       2024-01-16 │
 3. │              3 │     103 │          1 │        3 │  49.99 │       2024-01-17 │
 4. │              4 │     101 │          3 │        1 │  299.5 │       2024-01-18 │
 5. │              5 │     104 │          2 │        2 │ 199.99 │       2024-01-19 │
 6. │              6 │     105 │          4 │        5 │   9.99 │       2024-01-20 │
 7. │              7 │     102 │          5 │        1 │    599 │       2024-01-21 │
 8. │              8 │     106 │          3 │        1 │  299.5 │       2024-01-22 │
 9. │              9 │     107 │          1 │        1 │  49.99 │       2024-01-23 │
10. │             10 │     101 │          6 │        2 │ 149.75 │       2024-01-24 │
    └────────────────┴─────────┴────────────┴──────────┴────────┴──────────────────┘

10 rows in set. Elapsed: 0.003 sec.

```
# Агрегатные функции
## Рассчитайте общий доход от всех операций
```
clickhouse-node.ru-central1.internal :) SELECT
    SUM(quantity * price) AS total_revenue
FROM transactions;

SELECT SUM(quantity * price) AS total_revenue
FROM transactions

Query id: 2c97fac2-b550-4aa6-aaea-7358f1d76451

   ┌─────total_revenue─┐
1. │ 2447.360025405884 │
   └───────────────────┘

1 row in set. Elapsed: 0.005 sec.

clickhouse-node.ru-central1.internal :)
```
## Найдите средний доход с одной сделки.
```
clickhouse-node.ru-central1.internal :) SELECT avg(quantity * price) AS avg FROM transactions

SELECT avg(quantity * price) AS avg
FROM transactions

Query id: 1eeeba59-3e65-4415-a84d-2e05fcfa1dd4

   ┌────────────────avg─┐
1. │ 244.73600254058837 │
   └────────────────────┘

1 row in set. Elapsed: 0.016 sec.

```
## Определите общее количество проданной продукции
```
clickhouse-node.ru-central1.internal :) select  sum(quantity) AS TOTAL from transactions;

SELECT sum(quantity) AS TOTAL
FROM transactions

Query id: 8d9dc976-4a81-4cd2-adfc-6931ea55b330

   ┌─TOTAL─┐
1. │    19 │
   └───────┘

1 row in set. Elapsed: 0.004 sec.
```
## Подсчитайте количество уникальных пользователей, совершивших покупку.
```
clickhouse-node.ru-central1.internal :) select count(distinct user_id) AS uniq from transactions

SELECT countDistinct(user_id) AS uniq
FROM transactions

Query id: 224d3f96-7b37-4bfe-a45f-6677900c2e39

   ┌─uniq─┐
1. │    7 │
   └──────┘

1 row in set. Elapsed: 0.009 sec.

```
# Функции для работы с типами данных
## Преобразуйте `transaction_date` в строку формата `YYYY-MM-DD`.
```
clickhouse-node.ru-central1.internal :) SELECT
    transaction_id,
    toString(transaction_date) AS date_string
FROM transactions

SELECT
    transaction_id,
    toString(transaction_date) AS date_string
FROM transactions

Query id: 410b5cc2-93b0-4156-af26-8aead97d573c

    ┌─transaction_id─┬─date_string─┐
 1. │              1 │ 2024-01-15  │
 2. │              2 │ 2024-01-16  │
 3. │              3 │ 2024-01-17  │
 4. │              4 │ 2024-01-18  │
 5. │              5 │ 2024-01-19  │
 6. │              6 │ 2024-01-20  │
 7. │              7 │ 2024-01-21  │
 8. │              8 │ 2024-01-22  │
 9. │              9 │ 2024-01-23  │
10. │             10 │ 2024-01-24  │
    └────────────────┴─────────────┘

10 rows in set. Elapsed: 0.022 sec.
```
## Извлеките год и месяц из `transaction_date`.
```
clickhouse-node.ru-central1.internal :) SELECT
    transaction_id,
    toYear(transaction_date) AS year,
    toMonth(transaction_date) AS month
FROM transactions
LIMIT 4;

SELECT
    transaction_id,
    toYear(transaction_date) AS year,
    toMonth(transaction_date) AS month
FROM transactions
LIMIT 4

Query id: af4fa694-fd85-47da-8afe-f357104aa8c0

   ┌─transaction_id─┬─year─┬─month─┐
1. │              1 │ 2024 │     1 │
2. │              2 │ 2024 │     1 │
3. │              3 │ 2024 │     1 │
4. │              4 │ 2024 │     1 │
   └────────────────┴──────┴───────┘

4 rows in set. Elapsed: 0.009 sec.
```
## Округлите `price` до ближайшего целого числа.
```
clickhouse-node.ru-central1.internal :) SELECT
    transaction_id,
    price,
    round(price) AS rounded_price
FROM transactions

SELECT
    transaction_id,
    price,
    round(price) AS rounded_price
FROM transactions

Query id: 5f1a7b6f-c077-47a8-b98e-0115234049c8

    ┌─transaction_id─┬──price─┬─rounded_price─┐
 1. │              1 │  49.99 │            50 │
 2. │              2 │ 199.99 │           200 │
 3. │              3 │  49.99 │            50 │
 4. │              4 │  299.5 │           300 │
 5. │              5 │ 199.99 │           200 │
 6. │              6 │   9.99 │            10 │
 7. │              7 │    599 │           599 │
 8. │              8 │  299.5 │           300 │
 9. │              9 │  49.99 │            50 │
10. │             10 │ 149.75 │           150 │
    └────────────────┴────────┴───────────────┘

10 rows in set. Elapsed: 0.011 sec.
```
## Преобразуйте `transaction_id` в строку.
```
clickhouse-node.ru-central1.internal :) SELECT
    toString(transaction_id) AS transaction_id_str,
    user_id
FROM transactions

SELECT
    toString(transaction_id) AS transaction_id_str,
    user_id
FROM transactions

Query id: 9baf7b8e-7e52-4df1-a1a4-32c7e122090d

    ┌─transaction_id_str─┬─user_id─┐
 1. │ 1                  │     101 │
 2. │ 2                  │     102 │
 3. │ 3                  │     103 │
 4. │ 4                  │     101 │
 5. │ 5                  │     104 │
 6. │ 6                  │     105 │
 7. │ 7                  │     102 │
 8. │ 8                  │     106 │
 9. │ 9                  │     107 │
10. │ 10                 │     101 │
    └────────────────────┴─────────┘

10 rows in set. Elapsed: 0.003 sec.
```
# User-Defined Functions (UDFs)
## Создайте простую UDF для расчета общей стоимости транзакции.
## Используйте созданную UDF для расчета общей цены для каждой транзакции.
```

clickhouse-node.ru-central1.internal :) CREATE FUNCTION calculate_total AS (qty, prc) -> qty * prc;

CREATE FUNCTION calculate_total AS (qty, prc) -> (qty * prc)

Query id: ff7b7563-0199-4608-8f43-5a7148ce20af

Ok.

0 rows in set. Elapsed: 0.009 sec.

clickhouse-node.ru-central1.internal :) SELECT
    transaction_id,
    quantity,
    price,
    calculate_total(quantity, price) AS total_price
FROM transactions;

SELECT
    transaction_id,
    quantity,
    price,
    calculate_total(quantity, price) AS total_price
FROM transactions

Query id: a8fd51d8-3fbd-4f53-9278-b8abe0030b1e

    ┌─transaction_id─┬─quantity─┬──price─┬────────total_price─┐
 1. │              1 │        2 │  49.99 │   99.9800033569336 │
 2. │              2 │        1 │ 199.99 │ 199.99000549316406 │
 3. │              3 │        3 │  49.99 │  149.9700050354004 │
 4. │              4 │        1 │  299.5 │              299.5 │
 5. │              5 │        2 │ 199.99 │  399.9800109863281 │
 6. │              6 │        5 │   9.99 │  49.94999885559082 │
 7. │              7 │        1 │    599 │                599 │
 8. │              8 │        1 │  299.5 │              299.5 │
 9. │              9 │        1 │  49.99 │   49.9900016784668 │
10. │             10 │        2 │ 149.75 │              299.5 │
    └────────────────┴──────────┴────────┴────────────────────┘

10 rows in set. Elapsed: 0.003 sec.
```
## Создайте UDF для классификации транзакций на «высокоценные» и «малоценные» на основе порогового значения (например, 100).
## Примените UDF для категоризации каждой транзакции
```
clickhouse-node.ru-central1.internal :) CREATE FUNCTION classify_transaction AS (total_value, threshold) ->
    if(total_value >= threshold, 'высокоценная', 'малоценная');

CREATE FUNCTION classify_transaction AS (total_value, threshold) -> if(total_value >= threshold, 'высокоценная', 'малоценная')

Query id: 7a7f4fc2-99c4-468b-88a1-4f5878ebc16d

Ok.

0 rows in set. Elapsed: 0.011 sec.

clickhouse-node.ru-central1.internal :) SELECT
    transaction_id,
    quantity,
    price,
    calculate_total(quantity, price) AS total_price,
    classify_transaction(calculate_total(quantity, price), 100) AS transaction_category
FROM transactions;

SELECT
    transaction_id,
    quantity,
    price,
    calculate_total(quantity, price) AS total_price,
    classify_transaction(calculate_total(quantity, price), 100) AS transaction_category
FROM transactions

Query id: a0695db1-217d-4be2-947f-7a82498e813d

    ┌─transaction_id─┬─quantity─┬──price─┬────────total_price─┬─transaction_category─┐
 1. │              1 │        2 │  49.99 │   99.9800033569336 │ малоценная           │
 2. │              2 │        1 │ 199.99 │ 199.99000549316406 │ высокоценная         │
 3. │              3 │        3 │  49.99 │  149.9700050354004 │ высокоценная         │
 4. │              4 │        1 │  299.5 │              299.5 │ высокоценная         │
 5. │              5 │        2 │ 199.99 │  399.9800109863281 │ высокоценная         │
 6. │              6 │        5 │   9.99 │  49.94999885559082 │ малоценная           │
 7. │              7 │        1 │    599 │                599 │ высокоценная         │
 8. │              8 │        1 │  299.5 │              299.5 │ высокоценная         │
 9. │              9 │        1 │  49.99 │   49.9900016784668 │ малоценная           │
10. │             10 │        2 │ 149.75 │              299.5 │ высокоценная         │
    └────────────────┴──────────┴────────┴────────────────────┴──────────────────────┘

10 rows in set. Elapsed: 0.043 sec.


```








