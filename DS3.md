### Создайте новую базу данных и перейдите в неё.
```
CREATE DATABASE restaurant;
```
### Разработайте таблицу для бизнес-кейса "Меню ресторана" с минимум пятью полями. Наполните таблицу данными, используя модификаторы (например, Nullable, LowCardinality), где это необходимо. Не забудьте добавить комментарии к полям.

```
CREATE TABLE restaurant_menu
(
    `dish_id` UInt32 COMMENT 'Уникальный идентификатор блюда',
    `dish_name` LowCardinality(String) COMMENT 'Название блюда',
    `category` LowCardinality(String) COMMENT 'Категория блюда (закуски, основные блюда, десерты и т.д.)',
    `price` Decimal(10, 2) COMMENT 'Цена блюда в рублях',
    `is_available` Bool COMMENT 'Доступно ли блюдо для заказа',
    `cooking_time_min` Nullable(UInt16) COMMENT 'Время приготовления в минутах (Nullable для готовых блюд)',
    `calories` Nullable(UInt16) COMMENT 'Калорийность блюда (Nullable если не рассчитана)',
    `description` Nullable(String) COMMENT 'Описание блюда (Nullable для простых позиций)',
    `allergens` Array(LowCardinality(String)) COMMENT 'Массив аллергенов',
    `created_date` Date DEFAULT today() COMMENT 'Дата добавления блюда в меню',
    `last_updated` DateTime DEFAULT now() COMMENT 'Время последнего обновления записи'
)
ENGINE = MergeTree()
PARTITION BY toYYYYMM(created_date)
ORDER BY (category, dish_id)
SETTINGS index_granularity = 8192;
```
### Наполнение таблицы данными

```
INSERT INTO restaurant_menu VALUES
    (1, 'Цезарь с курицей', 'Салаты', 450.00, true, 15, 320, 'Классический салат с листьями айсберг, куриной грудкой, пармезаном и соусом цезарь', ['gluten','lactose'], '2024-01-15', now()),
    (2, 'Том Ям', 'Супы', 580.00, true, 20, 280, 'Острый тайский суп с креветками и кокосовым молоком', ['seafood','lactose'], '2024-01-15', now()),
    (3, 'Стейк Рибай', 'Горячие блюда', 1200.00, true, 25, 650, 'Стейк из мраморной говядины прожарки medium rare', ['none'], '2024-01-10', now()),
    (4, 'Бургер Чеддер', 'Сэндвичи', 390.00, false, 12, 520, 'Бургер с говяжьей котлетой, сыром чеддер и овощами', ['gluten','lactose'], '2024-01-12', now()),
    (5, 'Тирамису', 'Десерты', 350.00, true, NULL, 480, 'Классический итальянский десерт с кофе и маскарпоне', ['gluten','lactose','eggs'], '2024-01-08', now()),
    (6, 'Мохито', 'Напитки', 280.00, true, 5, 150, 'Освежающий коктейль с лаймом и мятой', ['none'], '2024-01-20', now()),
    (7, 'Оливье', 'Салаты', 320.00, true, 10, NULL, 'Традиционный салат оливье', ['eggs'], '2024-01-18', now()),
    (8, 'Борщ', 'Супы', 290.00, true, 15, 210, 'Украинский борщ со сметаной', ['none'], '2024-01-05', now());

```

- LowCardinality для dish_name и category - так как названия блюд и категории имеют ограниченное количество уникальных значений
- Nullable для cooking_time_min - для готовых блюд и напитков время приготовления неприминимо.
- Nullable для calories - калорийность может быть не расчитана для некоторых блюд.
- Nullable для description - не все блюда требуют подробного описания.
- Array(LowCardinality(String)) для allergens - эффективное хранение массива аллергенов с ограниченным набором значений
- Decimal для price - точное хранение денежных значений.
- Партиционирование по месяцу - для эффективного управления данными и удаления устаревших записей


### Протестируйте выполнение операций CRUD на созданной таблице.
### Добавьте несколько новых полей в таблицу и удалите два-три существующих.

-- Доступные блюда по категориям
```
SELECT category, count(*) as available_dishes
FROM restaurant_menu 
WHERE is_available = true
GROUP BY category;
```
-- Средняя цена по категориям
```
SELECT category, avg(price) as avg_price
FROM restaurant_menu 
GROUP BY category;
```
-- Блюда с аллергенами
```
SELECT dish_name, allergens
FROM restaurant_menu 
WHERE allergens != ['none'];
```

-- Тестируем вставку новых данных:
-- Вставка одиночной записи
```
INSERT INTO restaurant_menu VALUES 
(9, 'Греческий салат', 'Салаты', 380.00, true, 10, 290, 'Салат с овощами, оливками и фетой', ['lactose'], '2024-01-25', now());
```
-- Вставка нескольких записей
```
INSERT INTO restaurant_menu VALUES
(10, 'Лазанья', 'Горячие блюда', 620.00, true, 18, 480, 'Итальянская лазанья с мясным соусом', ['gluten','lactose'], '2024-01-25', now()),
(11, 'Морс клюквенный', 'Напитки', 180.00, true, NULL, 120, 'Натуральный клюквенный морс', ['none'], '2024-01-25', now());
```
-- Проверяем вставленные данные
```
SELECT * FROM restaurant_menu WHERE dish_id IN (9, 10, 11);
```
-- Агрегации


<table><tr><th colspan="5"><pre><code>SELECT <br>    category,<br>    count(*) as total_dishes,<br>    avg(price) as avg_price,<br>    min(price) as min_price,<br>    max(price) as max_price<br>FROM restaurant_menu <br>WHERE is_available = true<br>GROUP BY category</code></pre></th></tr><tr><th>category</th><th>total_dishes</th><th>avg_price</th><th>min_price</th><th>max_price</th></tr><tr class="odd"><td>Горячие блюда</td><td>2</td><td>910</td><td>620</td><td>1 200</td></tr>
<tr><td>Салаты</td><td>3</td><td>396,6666666667</td><td>320</td><td>450</td></tr>
<tr class="odd"><td>Супы</td><td>2</td><td>435</td><td>290</td><td>580</td></tr>
<tr><td>Напитки</td><td>1</td><td>180</td><td>180</td><td>180</td></tr>
<tr class="odd"><td>Десерты</td><td>1</td><td>350</td><td>350</td><td>350</td></tr>
</table>


-- Работа с массивами

<table><tr><th colspan="2"><pre><code>SELECT dish_name, allergens<br>FROM restaurant_menu <br>WHERE has(allergens, 'gluten')</code></pre></th></tr><tr><th>dish_name</th><th>allergens</th></tr><tr class="odd"><td>Тирамису</td><td>['gluten','lactose','eggs']</td></tr>
<tr><td>Цезарь с курицей</td><td>['gluten','lactose']</td></tr>
<tr class="odd"><td>Борщ</td><td>['gluten','lactose','eggs']</td></tr>
<tr><td>Бургер Чеддер</td><td>['gluten','lactose']</td></tr>
<tr class="odd"><td>Лазанья</td><td>['gluten','lactose']</td></tr>
</table>



-- Работа с NULL значениями

<table><tr><th colspan="2"><pre><code>SELECT dish_name, cooking_time_min<br>FROM restaurant_menu <br>WHERE cooking_time_min IS NULL</code></pre></th></tr><tr><th>dish_name</th><th>cooking_time_min</th></tr><tr class="odd"><td>Тирамису</td><td>&nbsp;</td></tr>
<tr><td>Морс клюквенный</td><td>&nbsp;</td></tr>
</table>


-- Поиск по тексту

<table><tr><th colspan="2"><pre><code>SELECT dish_name, description<br>FROM restaurant_menu <br>WHERE dish_name LIKE '%салат%' OR description LIKE '%салат%'<br></code></pre></th></tr><tr><th>dish_name</th><th>description</th></tr><tr class="odd"><td>Греческий салат</td><td>Салат с овощами, оливками и фетой</td></tr>
<tr><td>Цезарь с курицей</td><td>Классический салат с листьями айсберг, куриной грудкой, пармезаном и соусом цезарь</td></tr>
<tr class="odd"><td>Оливье</td><td>Традиционный салат оливье</td></tr>
</table>

-- Обновление цены для конкретного блюда
```
ALTER TABLE restaurant_menu 
UPDATE price = 420.00 
WHERE dish_id = 9;
```

-- Обновление статуса доступности
```
ALTER TABLE restaurant_menu 
UPDATE is_available = false 
WHERE dish_id = 6;
```

-- Обновление времени приготовления
```
ALTER TABLE restaurant_menu 
UPDATE cooking_time_min = 8 
WHERE dish_id = 1 AND category = 'Салаты';
```

-- Обновление с изменением массива аллергенов
```
ALTER TABLE restaurant_menu 
UPDATE allergens = ['gluten','lactose','eggs'] 
WHERE dish_id = 8;
```

-- Проверяем обновления



<table><tr><th colspan="6"><pre><code>SELECT dish_id, dish_name, price, is_available, cooking_time_min, allergens<br>FROM restaurant_menu <br>WHERE dish_id IN (1, 6, 8, 9)</code></pre></th></tr><tr><th>dish_id</th><th>dish_name</th><th>price</th><th>is_available</th><th>cooking_time_min</th><th>allergens</th></tr><tr class="odd"><td>9</td><td>Греческий салат</td><td>420</td><td>true</td><td>10</td><td>['lactose']</td></tr>
<tr><td>6</td><td>Мохито</td><td>280</td><td>false</td><td>5</td><td>['none']</td></tr>
<tr class="odd"><td>1</td><td>Цезарь с курицей</td><td>450</td><td>true</td><td>8</td><td>['gluten','lactose']</td></tr>
<tr><td>8</td><td>Борщ</td><td>290</td><td>true</td><td>15</td><td>['gluten','lactose','eggs']</td></tr>
</table>


-- Удаление записей

-- Удаление по условию (помечаем записи для удаления)
```
ALTER TABLE restaurant_menu 
DELETE WHERE dish_id = 4;
```

-- Удаление нескольких записей
```
ALTER TABLE restaurant_menu 
DELETE WHERE category = 'Напитки' AND is_available = false;
```

-- Удаление устаревших записей (если бы была логика архивации)
```
ALTER TABLE restaurant_menu 
DELETE WHERE created_date < '2024-01-01';
```

-- Проверяем удаление
```
SELECT dish_id, dish_name 
FROM restaurant_menu 
WHERE dish_id = 4;
```


### Выполните выборку данных (select) из любой таблицы из sample dataset

```
SELECT *
FROM nyc_taxi.trips_small
LIMIT 10;
```

<table><tr><th colspan="10"><pre><code>SELECT *<br>FROM nyc_taxi.trips_small<br>LIMIT 10</code></pre></th></tr><tr><th>trip_id</th><th>pickup_datetime</th><th>dropoff_datetime</th><th>pickup_longitude</th><th>pickup_latitude</th><th>dropoff_longitude</th><th>dropoff_latitude</th><th>passenger_count</th><th>trip_distance</th><th>fare_amount</th></tr><tr class="odd"><td>1 203 745 557</td><td>2015-07-01 03:00:09</td><td>2015-07-01 03:06:27</td><td>-73,975402832</td><td>40,7518997192</td><td>-73,9910583496</td><td>40,7507286072</td><td>5</td><td>1,12</td><td>6,5</td></tr>
<tr><td>1 201 746 944</td><td>2015-07-01 03:00:12</td><td>2015-07-01 03:08:33</td><td>-73,9787368774</td><td>40,7876586914</td><td>-73,9656219482</td><td>40,8079299927</td><td>1</td><td>1,78</td><td>8,5</td></tr>
<tr class="odd"><td>1 200 864 931</td><td>2015-07-01 03:00:13</td><td>2015-07-01 03:14:41</td><td>-73,9904632568</td><td>40,7461166382</td><td>-73,9791870117</td><td>40,7846755981</td><td>5</td><td>3,54</td><td>13,5</td></tr>
<tr><td>1 200 018 648</td><td>2015-07-01 03:00:16</td><td>2015-07-01 03:02:57</td><td>-73,7835845947</td><td>40,6486778259</td><td>-73,8024291992</td><td>40,6476783752</td><td>1</td><td>1,45</td><td>6</td></tr>
<tr class="odd"><td>1 201 452 450</td><td>2015-07-01 03:00:20</td><td>2015-07-01 03:11:07</td><td>-73,9857940674</td><td>40,7277755737</td><td>-74,0048217773</td><td>40,737487793</td><td>5</td><td>1,56</td><td>8,5</td></tr>
<tr><td>1 202 368 372</td><td>2015-07-01 03:00:40</td><td>2015-07-01 03:05:46</td><td>-74,0020675659</td><td>40,7383308411</td><td>-74,0065841675</td><td>40,748752594</td><td>2</td><td>1</td><td>6</td></tr>
<tr class="odd"><td>1 201 973 571</td><td>2015-07-01 03:00:51</td><td>2015-07-01 03:32:50</td><td>-73,9884414673</td><td>40,7641944885</td><td>-73,8775100708</td><td>40,8807144165</td><td>2</td><td>14,1</td><td>41,5</td></tr>
<tr><td>1 200 831 168</td><td>2015-07-01 03:01:06</td><td>2015-07-01 03:09:23</td><td>-73,9874801636</td><td>40,7434425354</td><td>-74,0057525635</td><td>40,7167930603</td><td>1</td><td>2,3</td><td>9</td></tr>
<tr class="odd"><td>1 201 362 116</td><td>2015-07-01 03:01:07</td><td>2015-07-01 03:03:31</td><td>-73,9926986694</td><td>40,758266449</td><td>-73,986289978</td><td>40,7607574463</td><td>1</td><td>0,6</td><td>4</td></tr>
<tr><td>1 201 215 784</td><td>2015-07-01 03:01:07</td><td>2015-07-01 03:08:07</td><td>-74,0136642456</td><td>40,7137794495</td><td>-74,0062637329</td><td>40,7080116272</td><td>2</td><td>1,1</td><td>6,5</td></tr>
</table>


### Материализуйте выбранную таблицу, создав её копию в виде отдельной таблицы.

```
CREATE TABLE nyc_taxi.trips_small_materialized (
    trip_id             UInt32,
    pickup_datetime     DateTime,
    dropoff_datetime    DateTime,
    pickup_longitude    Nullable(Float64),
    pickup_latitude     Nullable(Float64),
    dropoff_longitude   Nullable(Float64),
    dropoff_latitude    Nullable(Float64),
    passenger_count     UInt8,
    trip_distance       Float32,
    fare_amount         Float32,
    extra               Float32,
    tip_amount          Float32,
    tolls_amount        Float32,
    total_amount        Float32,
    payment_type        Enum('CSH' = 1, 'CRE' = 2, 'NOC' = 3, 'DIS' = 4, 'UNK' = 5),
    pickup_ntaname      LowCardinality(String),
    dropoff_ntaname     LowCardinality(String)
)
ENGINE = MergeTree
PRIMARY KEY (pickup_datetime, dropoff_datetime)
COMMENT 'Материализованная копия таблицы такси';
```

```
INSERT INTO nyc_taxi.trips_small_materialized 

SELECT 
   *
FROM nyc_taxi.trips_small;
```
-- Проверяем количество записей
```
SELECT 
    'Исходная таблица' as table_name,
    count(*) as row_count
FROM nyc_taxi.trips_small
UNION ALL
SELECT 
    'Материализованная таблица' as table_name,
    count(*) as row_count
FROM nyc_taxi.trips_small_materialized;
```

<table><tr><th colspan="2"><pre><code>SELECT <br>    'Исходная таблица' as table_name,<br>    count(*) as row_count<br>FROM nyc_taxi.trips_small<br>UNION ALL<br>SELECT <br>    'Материализованная таблица' as table_name,<br>    count(*) as row_count<br>FROM nyc_taxi.trips_small_materialized</code></pre></th></tr><tr><th>table_name</th><th>row_count</th></tr><tr class="odd"><td>Материализованная таблица</td><td>3 000 317</td></tr>
<tr><td>Исходная таблица</td><td>3 000 317</td></tr>
</table>

-- Создаем материализованное представление для новых вставок
```
CREATE MATERIALIZED VIEW nyc_taxi.trips_small_mv TO nyc_taxi.trips_small_materialized AS
SELECT 
    *
FROM nyc_taxi.trips_small;
```

-- 1. Чтение из материализованной таблицы
```
SELECT 
   *
FROM nyc_taxi.trips_small_materialized LIMIT 4;
```

<table><tr><th colspan="17"><pre><code>SELECT <br>   *<br>FROM nyc_taxi.trips_small_materialized LIMIT 4</code></pre></th></tr><tr><th>trip_id</th><th>pickup_datetime</th><th>dropoff_datetime</th><th>pickup_longitude</th><th>pickup_latitude</th><th>dropoff_longitude</th><th>dropoff_latitude</th><th>passenger_count</th><th>trip_distance</th><th>fare_amount</th><th>extra</th><th>tip_amount</th><th>tolls_amount</th><th>total_amount</th><th>payment_type</th><th>pickup_ntaname</th><th>dropoff_ntaname</th></tr><tr class="odd"><td>1 203 745 557</td><td>2015-07-01 03:00:09</td><td>2015-07-01 03:06:27</td><td>-73,975402832</td><td>40,7518997192</td><td>-73,9910583496</td><td>40,7507286072</td><td>5</td><td>1,12</td><td>6,5</td><td>0,5</td><td>2,34</td><td>0</td><td>10,14</td><td>CSH</td><td>Turtle Bay-East Midtown</td><td>Midtown-Midtown South</td></tr>
<tr><td>1 201 746 944</td><td>2015-07-01 03:00:12</td><td>2015-07-01 03:08:33</td><td>-73,9787368774</td><td>40,7876586914</td><td>-73,9656219482</td><td>40,8079299927</td><td>1</td><td>1,78</td><td>8,5</td><td>0,5</td><td>1,96</td><td>0</td><td>11,76</td><td>CSH</td><td>Upper West Side</td><td>Morningside Heights</td></tr>
<tr class="odd"><td>1 200 864 931</td><td>2015-07-01 03:00:13</td><td>2015-07-01 03:14:41</td><td>-73,9904632568</td><td>40,7461166382</td><td>-73,9791870117</td><td>40,7846755981</td><td>5</td><td>3,54</td><td>13,5</td><td>0,5</td><td>1</td><td>0</td><td>15,8</td><td>CSH</td><td>Midtown-Midtown South</td><td>Upper West Side</td></tr>
<tr><td>1 200 018 648</td><td>2015-07-01 03:00:16</td><td>2015-07-01 03:02:57</td><td>-73,7835845947</td><td>40,6486778259</td><td>-73,8024291992</td><td>40,6476783752</td><td>1</td><td>1,45</td><td>6</td><td>0,5</td><td>0</td><td>0</td><td>7,3</td><td>CRE</td><td>Airport</td><td>Airport</td></tr>
</table>

## Попрактикуйтесь с партициями: выполните операции ATTACH, DETACH и DROP. После этого добавьте новые данные в первоначально созданную таблицу.

```


CREATE DATABASE stackoverflow



CREATE TABLE 
(
    `Id` Int32 CODEC(Delta(4), ZSTD(1)),
    `PostTypeId` Enum8('Question' = 1, 'Answer' = 2, 'Wiki' = 3, 'TagWikiExcerpt' = 4, 'TagWiki' = 5, 'ModeratorNomination' = 6, 'WikiPlaceholder' = 7, 'PrivilegeWiki' = 8),
    `AcceptedAnswerId` UInt32,
    `CreationDate` DateTime64(3, 'UTC'),
    `Score` Int32,
    `ViewCount` UInt32 CODEC(Delta(4), ZSTD(1)),
    `Body` String,
    `OwnerUserId` Int32,
    `OwnerDisplayName` String,
    `LastEditorUserId` Int32,
    `LastEditorDisplayName` String,
    `LastEditDate` DateTime64(3, 'UTC') CODEC(Delta(8), ZSTD(1)),
    `LastActivityDate` DateTime64(3, 'UTC'),
    `Title` String,
    `Tags` String,
    `AnswerCount` UInt16 CODEC(Delta(2), ZSTD(1)),
    `CommentCount` UInt8,
    `FavoriteCount` UInt8,
    `ContentLicense` LowCardinality(String),
    `ParentId` String,
    `CommunityOwnedDate` DateTime64(3, 'UTC'),
    `ClosedDate` DateTime64(3, 'UTC')
)
ENGINE = MergeTree
PARTITION BY toYear(CreationDate)
ORDER BY (PostTypeId, toDate(CreationDate), CreationDate)

INSERT INTO stackoverflow.posts SELECT * FROM s3('https://datasets-documentation.s3.eu-west-3.amazonaws.com/stackoverflow/parquet/posts/*.parquet') WHERE toYear(CreationDate) IN (2021,2022,2023) LIMIT 300
```

-- Информация о партициях
```
SELECT 
    partition,
    count() as parts,
    sum(rows) as rows,
    formatReadableSize(sum(data_compressed_bytes)) as compressed_size,
    formatReadableSize(sum(data_uncompressed_bytes)) as uncompressed_size
FROM system.parts 
WHERE table = 'posts' AND active
GROUP BY partition
ORDER BY partition;
```

<table><tr><th colspan="5"><pre><code>-- Информация о партициях<br>SELECT <br>    partition,<br>    count() as parts,<br>    sum(rows) as rows,<br>    formatReadableSize(sum(data_compressed_bytes)) as compressed_size,<br>    formatReadableSize(sum(data_uncompressed_bytes)) as uncompressed_size<br>FROM system.parts <br>WHERE table = 'posts' AND active<br>GROUP BY partition<br>ORDER BY partition<br></code></pre></th></tr><tr><th>partition</th><th>parts</th><th>rows</th><th>compressed_size</th><th>uncompressed_size</th></tr><tr class="odd"><td>2008</td><td>2</td><td>11 000</td><td>5.15 MiB</td><td>8.98 MiB</td></tr>
<tr><td>2009</td><td>2</td><td>100 010</td><td>41.68 MiB</td><td>75.32 MiB</td></tr>
<tr class="odd"><td>2010</td><td>1</td><td>10</td><td>6.00 KiB</td><td>7.32 KiB</td></tr>
<tr><td>2012</td><td>1</td><td>100</td><td>35.11 KiB</td><td>61.68 KiB</td></tr>
<tr class="odd"><td>2021</td><td>2</td><td>1 100</td><td>1015.26 KiB</td><td>2.04 MiB</td></tr>
<tr><td>2022</td><td>1</td><td>300</td><td>135.71 KiB</td><td>255.17 KiB</td></tr>
</table>

















