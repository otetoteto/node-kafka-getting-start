# Getting Started with Kafka

## setup

```sh
# setup container
docker compose up -d

# create topic
docker compose exec kafka kafka-topics --bootstrap-server kafka:9092 --create --topic events --partitions 1 --replication-factor 1

# start producer process
node src/producer.ts

# start consumer process
node src/consumer.ts
```


## cdc

```sh
# setup container
docker compose up -d

# create kafka connector
curl -X POST -H "Content-Type: application/json" --data @mysql/mysql-connector.json http://localhost:8083/connectors

# listen to message
docker compose exec kafka kafka-console-consumer \
  --bootstrap-server kafka:9092 \
  --topic cdc.testdb.order_events \
  --from-beginning
```