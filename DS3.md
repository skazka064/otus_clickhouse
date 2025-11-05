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
SELECT category, count(*) as available_dishes
FROM restaurant_menu 
WHERE is_available = true
GROUP BY category;

-- Средняя цена по категориям
SELECT category, avg(price) as avg_price
FROM restaurant_menu 
GROUP BY category;

-- Блюда с аллергенами
SELECT dish_name, allergens
FROM restaurant_menu 
WHERE allergens != ['none'];
