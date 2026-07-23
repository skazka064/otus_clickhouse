```
# 1. Добавьте официальный репозиторий
apt update && sudo apt upgrade -y
apt-get install -y apt-transport-https ca-certificates curl gnupg
curl -fsSL 'https://packages.clickhouse.com/rpm/lts/repodata/repomd.xml.key' | sudo gpg --dearmor -o /usr/share/keyrings/clickhouse-keyring.gpg
ARCH=$(dpkg --print-architecture)
dpkg --print-architecture
echo "deb [signed-by=/usr/share/keyrings/clickhouse-keyring.gpg arch=${ARCH}] https://packages.clickhouse.com/deb stable main" | sudo tee /etc/apt/sources.list.d/clickhouse.list
apt-get update
# 2. Установите сервер и клиент
sudo apt-get install -y clickhouse-server clickhouse-client

# 3. Запустите сервис
sudo systemctl start clickhouse-server
sudo systemctl enable clickhouse-server
