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
