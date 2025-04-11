const mqtt = require("mqtt");
const SensorData = require("../models/SensorData");
const processSensorData = require("../controllers/dataProcessing");

const client = mqtt.connect("mqtt://broker.hivemq.com");

client.on("connect", () => {
  console.log("✅ Connected to MQTT Broker");
  client.subscribe("health/sensors");
});

client.on("message", async (topic, message) => {
  try {
    const data = JSON.parse(message.toString());
    const validatedData = await processSensorData(data);

    if (validatedData) {
      await SensorData.create(validatedData);
      console.log("📥 Data stored successfully");
    }
  } catch (error) {
    console.error("❌ Error processing MQTT message:", error.message);
  }
});

module.exports = client;
