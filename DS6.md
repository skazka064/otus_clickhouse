# Используя изученные материалы, построить запросы, отвечающие на следующие задачи:
## Найти жанры для каждого фильма
```sql
select m.name, g.genre from imdb.movies m  inner join imdb.genres g  on m.id=g.movie_id limit 5
```
|name|genre|
|----|-----|
|Legend of the Ruby Silver, The|Adventure|
|Legend of the Spirit Dog|Drama|
|Legend of the Tamworth Two, The|Comedy|
|Legend of the Tamworth Two, The|Drama|
|Legend of the Tamworth Two, The|Family|


## Запросить все фильмы, у которых нет жанра
## Объединить каждую строку из таблицы “Фильмы” с каждой строкой из таблицы “Жанры”
## Найти жанры для каждого фильма, НЕ используя INNER JOIN
## Найти всех актеров и актрис, снявшихся в фильме в N году
## Запросить все фильмы, у которых нет жанра, через ANTI JOIN

