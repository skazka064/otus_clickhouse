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
