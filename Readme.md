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

