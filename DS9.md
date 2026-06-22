# 1. Возьмите любой демонстрационный DATASET: https://clickhouse.com/docs/en/getting-started/example-datasets.
### Создал на хосте clickhouse-01 таблицу.

```
   CREATE TABLE amazon_reviews
(
    `review_date` Date,
    `marketplace` LowCardinality(String),
    `customer_id` UInt64,
    `review_id` String,
    `product_id` String,
    `product_parent` UInt64,
    `product_title` String,
    `product_category` LowCardinality(String),
    `star_rating` UInt8,
    `helpful_votes` UInt32,
    `total_votes` UInt32,
    `vine` Bool,
    `verified_purchase` Bool,
    `review_headline` String,
    `review_body` String,
    PROJECTION helpful_votes
    (
        SELECT *
        ORDER BY helpful_votes
    )
)
ENGINE = MergeTree
```

### Вставил данные из датасета

```
INSERT INTO amazon_reviews SELECT *
FROM s3('https://datasets-documentation.s3.eu-west-3.amazonaws.com/amazon_reviews/amazon_reviews_*.snappy.parquet') limit 1000
```

### Проверил

```
select * from amazon_reviews limit 3
```

|review_date|marketplace|customer_id|review_id|product_id|product_parent|product_title|product_category|star_rating|helpful_votes|total_votes|vine|verified_purchase|review_headline|review_body|
|-----------|-----------|-----------|---------|----------|--------------|-------------|----------------|-----------|-------------|-----------|----|-----------------|---------------|-----------|
|1995-06-24|US|53096571|RHL4UW17ZK72A|0521314925|980601331|Invention and Evolution:Design in Nature and Engineering|Books|5|9|9|false|false|BUY THIS BOOK!|This is a beautiful book.  French talks about energy, form, mechanism, and economy in natural and man-made things.  He compares birds to planes in terms of fuel-capacity, energy  conversion efficiency, drag, etc.  He compares suspension   bridges and dinosaurs.  He provides examples of neat   inventions and the thought that has gone into them (every-  thing from steam-catapults to toy cars to grommets).  This  is &quot;How Things Work&quot; for the non-moron crowd.|
|1995-06-24|US|53096571|R34N4QWDXX58WB|0870210092|442607382|Arming and Fitting of English Ships of War, 1600-1815|Books|4|12|13|false|false|good enough to understand all of Pat O'brien|Nice diags, lucid explanations of rigging, guns, hull, etc. A lot of the pics also appear in &quot;Nelson's Navy&quot;, so if you  have that, don't bother.|
|1995-07-07|US|53096573|RPLV77JZXG575|047194128X|377091465|Object-Oriented Type Systems|Books|4|4|4|false|false|Good techniques, well written.|The best (and possibly only) book I've seen on the topic. I very much liked their approach of starting with a simplified language and adding the necessary features.  The algorithms are useful, well presented, and their  assumptions are laid out clearly.|












