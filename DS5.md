```sql

CREATE TABLE tbl1
(
    UserID UInt64,
    PageViews UInt8,
    Duration UInt8,
    Sign Int8,
    Version UInt8
)
ENGINE = ReplacingMergeTree()
ORDER BY UserID;


INSERT INTO tbl1 VALUES (4324182021466249494, 5, 146, -1, 1);

INSERT INTO tbl1 VALUES (4324182021466249494, 5, 146, 1, 1),(4324182021466249494, 6, 185, 1, 2);

SELECT * FROM tbl1;
```

<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8"/><style>
table {border: medium solid #6495ed;border-collapse: collapse;width: 100%;} th{font-family: monospace;border: thin solid #6495ed;padding: 5px;background-color: #D0E3FA;}th{text-align: left;}td{font-family: sans-serif;border: thin solid #6495ed;padding: 5px;text-align: center;}.odd{background:#e8edff;}img{padding:5px; border:solid; border-color: #dddddd #aaaaaa #aaaaaa #dddddd; border-width: 1px 2px 2px 1px; background-color:white;}</style>
</head>
<body>
<table><tr><th colspan="5"><pre><code>SELECT * FROM tbl1</code></pre></th></tr><tr><th>UserID</th><th>PageViews</th><th>Duration</th><th>Sign</th><th>Version</th></tr><tr class="odd"><td>4 324 182 021 466 249 494</td><td>6</td><td>185</td><td>1</td><td>2</td></tr>
<tr><td>4 324 182 021 466 249 494</td><td>5</td><td>146</td><td>-1</td><td>1</td></tr>
</table></body></html>
