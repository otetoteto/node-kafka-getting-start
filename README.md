# Getting Started with Kafka

## setup

```sh
# setup container
docker compose up -d

# create topic
docker compose exec kafka kafka-topics --bootstrap-server localhost:9092 --create --topic events --partitions 1 --replication-factor 1

# start producer process
node src/producer.ts

# start consumer process
node src/consumer.ts
```