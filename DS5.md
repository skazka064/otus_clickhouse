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
