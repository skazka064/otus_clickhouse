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
    6  version: '3'
    7  services:
    8    zookeeper:
    9      image: confluentinc/cp-zookeeper:latest
   10      environment:
   11        ZOOKEEPER_CLIENT_PORT: 2181
   12        ZOOKEEPER_TICK_TIME: 2000
   13      ports:
   14        - "2181:2181"
   15    kafka:
   16      image: confluentinc/cp-kafka:latest
   17      depends_on:
   18        - zookeeper
   19      ports:
   20        - "9092:9092"
   21      environment:
   22        KAFKA_BROKER_ID: 1
   23        KAFKA_ZOOKEEPER_CONNECT: zookeeper:2181
   24        KAFKA_ADVERTISED_LISTENERS: PLAINTEXT://10.0.0.21:9092
   25        KAFKA_LISTENERS: PLAINTEXT://0.0.0.0:9092
   26        KAFKA_OFFSETS_TOPIC_REPLICATION_FACTOR: 1
   27        KAFKA_PROCESS_ROLES: broker
   28        KAFKA_NODE_ID: 1
   29        KAFKA_CONTROLLER_QUORUM_VOTERS: 1@kafka:9093
   30  EOF
```
