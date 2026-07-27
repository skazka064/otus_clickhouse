yc compute instance create \
  --name kafka-01 \
  --zone ru-central1-a \
  --network-interface subnet-name=otus-subnet,nat-ip-version=ipv4 \
  --create-boot-disk image-family=ubuntu-2204-lts,image-folder-id=standard-images,size=30 \
  --cores 2 \
  --core-fraction 100 \
  --memory 4 \
  --ssh-key .ssh/yc/id_rsa.pub

```
   cat > docker-compose.yml << 'EOF'
    version: '3'
services:
  zookeeper-kafka:
    image: confluentinc/cp-zookeeper:latest
    container_name: zookeeper-kafka
    hostname: zookeeper-kafka
    environment:
      ZOOKEEPER_CLIENT_PORT: 2182
      ZOOKEEPER_TICK_TIME: 2000
    ports:
      - "2182:2182"
    restart: unless-stopped

  kafka:
    image: confluentinc/cp-kafka:7.4.0
    container_name: kafka
    hostname: kafka
    depends_on:
      - zookeeper-kafka
    environment:
      KAFKA_BROKER_ID: 1
      KAFKA_ZOOKEEPER_CONNECT: zookeeper-kafka:2182
      KAFKA_ADVERTISED_LISTENERS: PLAINTEXT://10.0.0.21:9092
      KAFKA_LISTENERS: PLAINTEXT://0.0.0.0:9092
      KAFKA_OFFSETS_TOPIC_REPLICATION_FACTOR: 1
      KAFKA_AUTO_CREATE_TOPICS_ENABLE: "true"
      KAFKA_LISTENER_SECURITY_PROTOCOL_MAP: PLAINTEXT:PLAINTEXT
    ports:
      - "9092:9092"
    restart: unless-stopped

  kafka-ui:
    image: provectuslabs/kafka-ui:latest
    container_name: kafka-ui
    hostname: kafka-ui
    depends_on:
      - kafka
    environment:
      KAFKA_CLUSTERS_0_NAME: local
      KAFKA_CLUSTERS_0_BOOTSTRAPSERVERS: kafka:9092
      KAFKA_CLUSTERS_0_ZOOKEEPER: zookeeper-kafka:2182
    ports:
      - "8089:8080"
    restart: unless-stopped

   30  EOF
```
### Продюссер
```
root@kafka:/home/yc-user# cat producer_finnhub.py
#!/usr/bin/env python3
import json
import websocket
from kafka import KafkaProducer
from datetime import datetime

# ===== Настройки Kafka =====
producer = KafkaProducer(
    bootstrap_servers='10.0.0.21:9092',
    value_serializer=lambda v: v.encode('utf-8')
)

# ===== Бесплатный ключ Finnhub =====
API_KEY = 'd9ermlpr01qq0pmhoaa0d9ermlpr01qq0pmhoaag'

def send_to_kafka(symbol, bid, ask, timestamp):
    csv_line = f"{symbol},{bid:.6f},{ask:.6f},{timestamp}\n"
    producer.send('forex_ticks', csv_line)
    print(f" Sent: {csv_line.strip()}")

def on_message(ws, message):
    try:
        data = json.loads(message)
        if 'data' in data:
            for item in data['data']:
                symbol = item.get('s', '')
                price = item.get('p', 0.0)
                if symbol and price:
                    ts = datetime.now().strftime('%Y-%m-%d %H:%M:%S')
                    # Формат: OANDA:EUR_USD → EUR/USD
                    clean_symbol = symbol.replace('OANDA:', '').replace('_', '/')
                    bid = float(price) * 0.999
                    ask = float(price) * 1.001
                    send_to_kafka(clean_symbol, bid, ask, ts)
    except Exception as e:
        print(f" Error: {e}")

def on_error(ws, error):
    print(f" WebSocket error: {error}")

def on_close(ws, close_status_code, close_msg):
    print(" WebSocket closed")

def on_open(ws):
    print(" Connected to Finnhub!")
    pairs = ['OANDA:EUR_USD', 'OANDA:GBP_USD', 'OANDA:USD_JPY']
    for pair in pairs:
        ws.send(json.dumps({'type': 'subscribe', 'symbol': pair}))
        print(f" Subscribed to {pair}")

# ===== Запуск =====
if __name__ == '__main__':
    print(" Starting Finnhub WebSocket Producer (Forex)...")
    ws = websocket.WebSocketApp(
        f'wss://ws.finnhub.io?token={API_KEY}',
        on_open=on_open,
        on_message=on_message,
        on_error=on_error,
        on_close=on_close
    )
    ws.run_forever()
```

### Включение
docker-compose up -d
python3 producer_finnhub.py










