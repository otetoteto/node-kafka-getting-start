import { randomUUID } from "node:crypto";
import { createInterface } from "node:readline";
import { ProduceAcks, Producer, jsonSerializer, stringSerializer } from "@platformatic/kafka";
import type { Event } from "./type.ts";

const producer = new Producer({
  clientId: "producer",
  bootstrapBrokers: ["localhost:9092"],
  serializers: {
    key: stringSerializer,
    value: jsonSerializer<Event>,
  },
});

producer.on("error", (err) => {
  console.error("Producer error:", err);
  process.exit(1);
});

const shutdown = async () => {
  try {
    await producer.close();
    console.log("Producer closed.");
    process.exit(0);
  } catch (err) {
    console.error("Error during shutdown:", err);
    process.exit(1);
  }
};
process.on("SIGINT", shutdown);
process.on("SIGTERM", shutdown);

const readline = createInterface({
  input: process.stdin,
});

process.stdout.write("[enter message]: ");
for await (const line of readline) {
  const event: Event = {
    message: line.trim(),
    timestamp: Date.now(),
  };

  const result = await producer.send({
    messages: [{ topic: "events", key: randomUUID(), value: event }],
    acks: ProduceAcks.LEADER,
  });
  console.log("Message sent:", result);
  process.stdout.write("\n[enter message]: ");
}
