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
# Рассчитайте общий доход от всех операций









