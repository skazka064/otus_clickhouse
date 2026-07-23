# Создание ВМ для Airflow

```
yc compute instance create \
  --name airflow-01 \
  --zone ru-central1-a \
  --network-interface subnet-name=otus-subnet,nat-ip-version=ipv4 \
  --create-boot-disk image-family=ubuntu-2204-lts,image-folder-id=standard-images,size=50 \
  --cores 2 \
  --core-fraction 100 \
  --memory 4 \
  --ssh-key .ssh/yc/id_rsa.pub
```

```

# 1. Обновление системы
sudo apt update && sudo apt upgrade -y

# 2. Установка Docker
sudo apt install -y apt-transport-https ca-certificates curl software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu jammy stable"
sudo apt update
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin

# 3. Добавление пользователя в группу docker
sudo usermod -aG docker $USER
newgrp docker

# 4. Скачивание docker-compose для Airflow
curl -LfO 'https://airflow.apache.org/docs/apache-airflow/stable/docker-compose.yaml'

# 5. Создание папок для DAG и логов
mkdir -p ./dags ./logs ./plugins ./config
echo -e "AIRFLOW_UID=50000" > .env
# Сгенерировали
python3 -c "from cryptography.fernet import Fernet; print(Fernet.generate_key().decode())"
# Добавили
echo "FERNET_KEY=ВАШ_СГЕНЕРИРОВАННЫЙ_КЛЮЧ" >> .env

# 6. Инициализация Airflow
docker compose up airflow-init

# 7. Запуск Airflow
docker compose up -d

```










