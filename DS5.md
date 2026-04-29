# Пример01
У нас три вставки (-1,1) - старая версия (Sign=-1, Version=1)
                  (1,1) - новая версия с теми же данными (Sign =1 , Version =1)
                  (1,2) - еще одна новая версия (Sign =1, Version =2)
                  Цель: В итоге должна остаться только одна строка с максимальной версией (Version =2) и положительным Sign
                  Выбор: VersionedCollapsingMergeTree - Удалит пару (1,1) и (-1,1), но останется строка (1,2). Используется Version для корректного "схлопывания". Даже если вставка пришла в неправильном полядке, версия все исправит. Для удаления.
```sql
CREATE TABLE tbl1
(
    UserID UInt64,
    PageViews UInt8,
    Duration UInt8,
    Sign Int8,
    Version UInt8
)
ENGINE = VersionedCollapsingMergeTree(Sign, Version)
ORDER BY UserID;

INSERT INTO tbl1 VALUES (4324182021466249494, 5, 146, 1, 1);
INSERT INTO tbl1 VALUES (4324182021466249494, 5, 146, -1, 1),(4324182021466249494, 6, 185, 1, 2);
SELECT * FROM tbl1;
```
|UserID|PageViews|Duration|Sign|Version|
|------|---------|--------|----|-------|
|4324182021466249494|5|146|1|1|
|4324182021466249494|5|146|-1|1|
|4324182021466249494|6|185|1|2|

```sql
SELECT * FROM tbl1 final;
```
|UserID|PageViews|Duration|Sign|Version|
|------|---------|--------|----|-------|
|4324182021466249494|6|185|1|2|

# Пример02
Ну, по условию вывода select больше подходит SummingMergeTree(value) , т.к. при key=1, value=3 при вставках (1,1) (1,2) (2,1) т.е. value суммировалось 1+2=3

```sql
CREATE TABLE tbl2
(
    key UInt32,
    value UInt32
)
ENGINE = SummingMergeTree(value)
ORDER BY key;

INSERT INTO tbl2 Values(1,1),(1,2),(2,1);

select * from tbl2;
```
|key|value|
|---|-----|
|1|3|
|2|1|

# Пример03
Судя по задаче, необходимо заменить строку с id=23, т.к. с FINAL мы видим одну строку вместо двух. Значит ее надо заменить. Поскольку ClickHouse плохо справляется с частыми обновлениями, можно обновить столбец, вставив новую строку с такими же ключами сортировки, и ClickHouse удалит строки в фоновом режиме. 


```sql
CREATE TABLE tbl3
(
    `id` Int32,
    `status` String,
    `price` String,
    `comment` String
)
ENGINE = ReplacingMergeTree
PRIMARY KEY (id)
ORDER BY (id, status);

INSERT INTO tbl3 VALUES (23, 'success', '1000', 'Confirmed');
INSERT INTO tbl3 VALUES (23, 'success', '2000', 'Cancelled'); 

SELECT * from tbl3 WHERE id=23;

```
|id|status|price|comment|
|--|------|-----|-------|
|23|success|1000|Confirmed|
|23|success|2000|Cancelled|

```sql
SELECT * from tbl3 FINAL WHERE id=23;
```
|id|status|price|comment|
|--|------|-----|-------|
|23|success|2000|Cancelled|

# Пример04
Две сроки вставки. Они полностью уникальны по ключу сортировки ORDER BY (CounterID, StartDate). Нет дубликатов, нет числовых полей для суммировани, нет поля Sign, поэтому подойдет MergeTree

```sql
CREATE TABLE tbl4
(   CounterID UInt8,
    StartDate Date,
    UserID UInt64
) ENGINE = MergeTree
PARTITION BY toYYYYMM(StartDate) 
ORDER BY (CounterID, StartDate);

INSERT INTO tbl4 VALUES(0, '2019-11-11', 1);
INSERT INTO tbl4 VALUES(1, '2019-11-12', 1);
select * from tbl4;
```
|CounterID|StartDate|UserID|
|---------|---------|------|
|0|2019-11-11|1|
|1|2019-11-12|1|

# Пример05
AggregateFunction(uniq, UInt64) — это специальный тип данных, который хранит не само значение UserID, а промежуточное состояние хеш-таблицы для вычисления приблизительного количества уникальных пользователей. Поэтому - AggregatingMergeTree()
```sql
CREATE TABLE tbl5
(   CounterID UInt8,
    StartDate Date,
    UserID AggregateFunction(uniq, UInt64)
) ENGINE = AggregatingMergeTree()
PARTITION BY toYYYYMM(StartDate) 
ORDER BY (CounterID, StartDate);

INSERT INTO tbl5
select CounterID, StartDate, uniqState(UserID)
from tbl4
group by CounterID, StartDate;
INSERT INTO tbl5 VALUES (1,'2019-11-12',1);

SQL Error [53] [22000]: Code: 53. DB::Exception: Cannot convert UInt64 to AggregateFunction(uniq, UInt64): While executing ValuesBlockInputFormat. (TYPE_MISMATCH) (version 25.8.21.7 (official build))  (queryId= 7e65d97b-d34f-42b3-b883-762f9da9b467)
SELECT uniqMerge(UserID) AS state 
FROM tbl5 
GROUP BY CounterID, StartDate;
```
|state|
|-----|
|1|
|1|

# Пример06
 У нас есть поле sign — это ключевой индикатор. Поэтому - CollapsingMergeTree(sign)
```sql
CREATE TABLE tbl6
(
    `id` Int32,
    `status` String,
    `price` String,
    `comment` String,
    `sign` Int8
)
ENGINE = CollapsingMergeTree(sign)
PRIMARY KEY (id)
ORDER BY (id, status);

INSERT INTO tbl6 VALUES (23, 'success', '1000', 'Confirmed', 1);
INSERT INTO tbl6 VALUES (23, 'success', '1000', 'Confirmed', -1), (23, 'success', '2000', 'Cancelled', 1);
```

|id|status|price|comment|sign|
|--|------|-----|-------|----|
|23|success|1000|Confirmed|1|
|23|success|1000|Confirmed|-1|
|23|success|2000|Cancelled|1|


```sql
SELECT * FROM tbl6 FINAL;
```

|id|status|price|comment|sign|
|--|------|-----|-------|----|
|23|success|2000|Cancelled|1|

# no_problems










































