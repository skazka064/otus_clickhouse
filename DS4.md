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
