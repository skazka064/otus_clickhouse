```
yc compute instance create \
  --name clickhouse-01 \
  --zone ru-central1-a \
  --network-interface subnet-name=otus-subnet,nat-ip-version=ipv4 \
  --create-boot-disk image-family=ubuntu-2204-lts,image-folder-id=standard-images,size=100 \
  --cores 4 \
  --core-fraction 100 \
  --memory 8 \
  --ssh-key ~/.ssh/id_ed25519.pub
```

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
```

```
sudo nano /etc/clickhouse-server/users.d/default-password.xml
```

```xml
<clickhouse>
    <users>
        <default>
            <password>your_password</password>
        </default>
    </users>
</clickhouse>
```

```
sudo systemctl restart clickhouse-server
```
