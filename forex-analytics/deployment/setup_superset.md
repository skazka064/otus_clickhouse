```
yc compute instance create \
  --name superset-01 \
  --zone ru-central1-a \
  --network-interface subnet-name=otus-subnet,nat-ip-version=ipv4 \
  --create-boot-disk image-family=ubuntu-2204-lts,image-folder-id=standard-images,size=50 \
  --cores 2 \
  --core-fraction 100 \
  --memory 4 \
  --ssh-key .ssh/yc/id_rsa.pub
```

```
# Установка Python и зависимостей
sudo apt update
sudo apt install -y python3-pip python3-venv

# Создание виртуального окружения
python3 -m venv superset_venv
source superset_venv/bin/activate

# Установка Superset
pip install rich
pip install apache-superset

# Инициализация
superset db upgrade
export FLASK_APP=superset
superset fab create-admin
superset init

повторная инициализация опционально(superset db upgrade)
```
### Создание администратора

```
export FLASK_APP=superset
superset fab create-admin
superset init
superset run -p 8088 --host=0.0.0.0 --with-threads
```

### Если надо переустановить

```
# Деактивация текущего окружения
deactivate

# Удаление старого окружения
rm -rf superset_venv

# Создание нового окружения
python3 -m venv superset_venv
source superset_venv/bin/activate

# Обновление pip и установка зависимостей
pip install --upgrade pip setuptools wheel

# Установка всех необходимых пакетов
pip install apache-superset clickhouse-connect rich

# Инициализация
superset db upgrade
export FLASK_APP=superset
superset fab create-admin
superset init

# Запуск
superset run -p 8088 --host=0.0.0.0 --with-threads
```

###Решение проблемы с SECRET_KEY

```
export SUPERSET_SECRET_KEY=$(openssl rand -base64 42) && \
superset db upgrade && \
superset fab create-admin && \
superset init && \
superset run -p 8088 --host=0.0.0.0 --with-threads
```
### Настройка для постоянной работы

```
cat > ~/superset_config.py <<EOF
import os
SECRET_KEY = os.environ.get('SUPERSET_SECRET_KEY') or '$(openssl rand -base64 42)'
SQLALCHEMY_DATABASE_URI = 'sqlite:////home/yc-user/superset.db?check_same_thread=false'
EOF

export SUPERSET_CONFIG_PATH=~/superset_config.py
```

### Проверка базы данных Superset
```
source superset_venv/bin/activate
export FLASK_APP=superset
export SUPERSET_SECRET_KEY=$(openssl rand -base64 42)
superset db upgrade
```
### Активация окружения

```
source superset_venv/bin/activate
```
