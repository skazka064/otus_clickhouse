### Очистка БД
```
sqlite3 /root/.superset/superset.db "DELETE FROM databases;"
sqlite3 /root/.superset/superset.db ".tables"
sqlite3 /root/.superset/superset.db "SELECT * FROM database;"
sqlite3 /root/.superset/superset.db "SELECT * FROM dbs;"
sqlite3 /root/.superset/superset.db "DELETE FROM dbs;"
sqlite3 /root/.superset/superset.db "SELECT * FROM dbs;"
```

### 1. Активация виртуального окружения и сброс пароля

```
source /home/yc-user/superset_venv/bin/activate
export FLASK_APP=superset
export SUPERSET_SECRET_KEY=$(openssl rand -base64 42)
superset fab reset-password
```

### 2.(опционально)  Если сброс не работает, создайте нового администратора

```
source /home/yc-user/superset_venv/bin/activate
export FLASK_APP=superset
export SUPERSET_SECRET_KEY=$(openssl rand -base64 42)
superset fab create-admin
```

### 3. Перезапуск Superset

```
pkill -f superset
source /home/yc-user/superset_venv/bin/activate
export FLASK_APP=superset
export SUPERSET_SECRET_KEY=$(openssl rand -base64 42)
superset run -p 8088 --host=0.0.0.0 --with-threads --debug
```
