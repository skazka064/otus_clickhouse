### Установите ClickHouse
```bash
# Установить необходимые пакеты
apt-get install -y apt-transport-https ca-certificates curl gnupg
# Скачайте GPG-ключ ClickHouse и сохраните его в хранилище ключей
curl -fsSL 'https://packages.clickhouse.com/rpm/lts/repodata/repomd.xml.key' | sudo gpg --dearmor -o /usr/share/keyrings/clickhouse-keyring.gpg
# Получите архитектуру системы
ARCH=$(dpkg --print-architecture)
# Добавьте репозиторий ClickHouse в источники apt
echo "deb [signed-by=/usr/share/keyrings/clickhouse-keyring.gpg arch=${ARCH}] https://packages.clickhouse.com/deb stable main" | sudo tee /etc/apt/sources.list.d/clickhouse.list
# Обновите списки пакетов apt
sudo apt-get update
apt-get install -y clickhouse-server clickhouse-client
service clickhouse-server start
```
