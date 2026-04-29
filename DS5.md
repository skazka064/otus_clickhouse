# Пример01
У нас три вставки (-1,1) - старая версия (Sign=-1, Version=1)
                  (1,1) - новая версия с теми же данными (Sign =1 , Version =1)
                  (1,2) - еще одна новая версия (Sign =1, Version =2)
                  Цель: В итоге должна остаться только одна строка с максимальной версией (Version =2) и положительным Sign
                  Выбор: VersionedCollapsingMergeTree - Удалит пару (1,1) и (-1,1), но останется строка (1,2). Используется Version для корректного "схлопывания". Даже если вставка пришла в неправильном полядке, версия все исправит
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







