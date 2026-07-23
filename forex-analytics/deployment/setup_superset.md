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
pip install apache-superset

# Инициализация
superset db upgrade
export FLASK_APP=superset
superset fab create-admin
superset init

# Запуск (для теста)
superset run -p 8088 --host=0.0.0.0

```
