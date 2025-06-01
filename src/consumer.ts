import { Consumer, jsonDeserializer, stringDeserializer } from "@platformatic/kafka";
import type { Event } from "./type.ts";

const consumer = new Consumer({
  groupId: "consumer-group",
  clientId: "consumer",
  bootstrapBrokers: ["localhost:9092"],
  deserializers: {
    key: stringDeserializer,
    value: jsonDeserializer<Event>,
  },
});

const stream = await consumer.consume({ topics: ["events"] });

for await (const message of stream) {
  console.log("Received message:", {
    topic: message.topic,
    partition: message.partition,
    offset: message.offset,
    headers: message.headers,
    key: message.key,
    value: message.value,
    timestamp: message.timestamp,
  });
  await message.commit();
}
