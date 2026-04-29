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









































