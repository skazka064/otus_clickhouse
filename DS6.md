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
```sql
select m.name, g.genre from imdb.movies m  left outer join imdb.genres g  on m.id=g.movie_id where g.movie_id=0 limit 5
```
|name|genre|
|----|-----|
|#28||
|Knigin von Honolulu, Die||
|Tou cuo ge qiang hua||
|"""Sound of Summer"""||
|Fu gui fu yun||

## Объединить каждую строку из таблицы “Фильмы” с каждой строкой из таблицы “Жанры”
```sql
select * from imdb.movies m  cross join imdb.genres g limit 5
```
|id|name|year|rank|movie_id|genre|
|--|----|----|----|--------|-----|
|349731|Vaiki Odunna Varathi|1986|0.0|124461|Fantasy|
|349731|Vaiki Odunna Varathi|1986|0.0|124463|Horror|
|349731|Vaiki Odunna Varathi|1986|0.0|124465|Comedy|
|349731|Vaiki Odunna Varathi|1986|0.0|124465|Short|
|349731|Vaiki Odunna Varathi|1986|0.0|124466|Drama|


## Найти жанры для каждого фильма, НЕ используя INNER JOIN
```sql
select m.name, g.genre from imdb.movies m  left semi join imdb.genres g  on m.id=g.movie_id limit 5
```
|name|genre|
|----|-----|
|Bostella, La|Comedy|
|Bostock's Circus Fording a Stream|Documentary|
|Bostock's Cup|Comedy|
|Bostock's Educated Bears|Documentary|
|Bostock's Educated Chimpanzee|Documentary|


## Найти всех актеров и актрис, снявшихся в фильме в N году
```sql
select a.first_name, a.last_name, r.created_at from imdb.actors a left semi join imdb.roles r on a.id=r.actor_id where toYear(r.created_at)='2026' order by a.id limit 5
```
|first_name|last_name|created_at|
|----------|---------|----------|
|Michael|'babeepower' Viera|2026-05-14 12:07:31|
|Eloy|'Chincheta'|2026-05-14 12:07:31|
|Dieguito|'El Cigala'|2026-05-14 12:07:31|
|Antonio|'El de Chipiona'|2026-05-14 12:07:31|
|José|'El Francés'|2026-05-14 12:07:31|

## Запросить все фильмы, у которых нет жанра, через ANTI JOIN
```sql
select m.name, g.genre from imdb.movies m  left anti join imdb.genres g  on m.id=g.movie_id limit 5
```
|name|genre|
|----|-----|
|"""Hritiers Duval, Les"""||
|"""Hritiers, Les"""||
|"""Htel de police"""||
|"""Htel du sicle"""||
|"""Hhlenkinder, Die"""||
