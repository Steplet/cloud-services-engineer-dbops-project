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


```sql
SELECT
    o.date_created AS order_date,
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
