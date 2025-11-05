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




