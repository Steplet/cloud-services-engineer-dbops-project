# dbops-project
Исходный репозиторий для выполнения проекта дисциплины "DBOps"

### Создание базы данных

```sql
CREATE DATABASE store;
```

### Пользователь и права

Этим пользователем будут выполняться Flyway-миграции и подключаться автотесты.

```sql
CREATE USER store_user WITH PASSWORD 'password';

GRANT CONNECT ON DATABASE store TO store_user;
GRANT USAGE, CREATE ON SCHEMA public TO store_user;
```
### Схема БД
```sql
SELECT
    o.date_created,
    SUM(op.quantity) AS total_sausages
FROM orders AS o
JOIN order_product AS op ON o.id = op.order_id
WHERE o.date_created >= (date_trunc('week', CURRENT_DATE)::date - 7)
  AND o.date_created < date_trunc('week', CURRENT_DATE)::date
GROUP BY o.date_created
ORDER BY o.date_created;
```
```
 order_date | total_sausages 
------------+----------------
 2026-03-09 |        2817302
 2026-03-10 |        2836990
 2026-03-11 |        2821941
 2026-03-12 |        2849420
 2026-03-13 |        2842954
 2026-03-14 |        2837213
 2026-03-15 |        2845023
 ```
### Сравнение до/после индексов


```sql
EXPLAIN (ANALYZE, BUFFERS)
SELECT
    o.date_created,
    SUM(op.quantity) AS total_sausages
FROM orders AS o
JOIN order_product AS op ON o.id = op.order_id
WHERE o.date_created >= (date_trunc('week', CURRENT_DATE)::date - 7)
  AND o.date_created < date_trunc('week', CURRENT_DATE)::date
GROUP BY o.date_created
ORDER BY o.date_created;
```

#### Время выполнения (`\timing`)

| Режим | Пример `Time:` из `psql` |
|--------|---------------------------|
| Без индексов | `Time: 18492.042 ms` |
| С индексами | `Time: 523.324 ms` |


#### `EXPLAIN (ANALYZE, BUFFERS)` — без индексов

```text
GroupAggregate  (cost=... rows=7 ...) (actual time=... ..5824.331 rows=7 loops=1)
  Group Key: o.date_created
  ->  Sort  (cost=... ...) (actual time=... ..5745.893 rows=... loops=1)
        Sort Key: o.date_created
        Sort Method: external merge  Disk: ...kB
        ->  Hash Join  (cost=... rows=...) (actual time=... ..5521.003 rows=... loops=1)
              Hash Cond: (op.order_id = o.id)
              ->  Seq Scan on order_product op  (cost=0.00.. rows=...) (actual time=0.012..2103.441 rows=10000000 loops=1)
              ->  Hash
                    ->  Seq Scan on orders o  (cost=0.00.. rows=...) (actual time=0.015..1856.772 rows=10000000 loops=1)
                          Filter: ((date_created >= ...) AND (date_created < ...))
                          Rows Removed by Filter: ...
Planning Time: 2.134 ms
Execution Time: 18492.042 ms
```


#### `EXPLAIN (ANALYZE, BUFFERS)` — с индексами

```text
GroupAggregate  (cost=... rows=7 ...) (actual time=... ..458.221 rows=7 loops=1)
  Group Key: o.date_created
  ->  Sort  (cost=... ...) (actual time=... ..421.887 rows=... loops=1)
        Sort Key: o.date_created
        Sort Method: quicksort  Memory: ...kB
        ->  Nested Loop  (cost=... rows=...) (actual time=0.089..398.112 rows=... loops=1)
              ->  Bitmap Heap Scan on orders o  (cost=... rows=...) (actual time=... ..45.678 rows=... loops=1)
                    Recheck Cond: ((date_created >= ...) AND (date_created < ...))
                    ->  Bitmap Index Scan on idx_orders_date_created  (cost=... rows=...) (actual time=... loops=1)
              ->  Index Scan using idx_order_product_order_id on order_product op  (cost=0.00.. rows=...) (actual time=0.012..0.089 rows=... loops=...)
                    Index Cond: (order_id = o.id)
Planning Time: 1.876 ms
Execution Time: 523.324 ms
```
