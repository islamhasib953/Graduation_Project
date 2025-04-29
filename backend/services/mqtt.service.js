const mqtt = require("mqtt");
const SensorData = require("../models/sensorData.model");
const Child = require("../models/child.model");
require("dotenv").config();

class MQTTService {
  constructor(io) {
    this.io = io;
    this.client = mqtt.connect(
      `mqtts://${process.env.MQTT_HOST}:${process.env.MQTT_PORT}`,
      {
        username: process.env.MQTT_USERNAME,
        password: process.env.MQTT_PASSWORD,
      }
    );
  }

  connect() {
    this.client.on("connect", () => {
      console.log("Connected to MQTT Broker");
      this.client.subscribe(process.env.MQTT_TOPIC, (err) => {
        if (!err) {
          console.log(`Subscribed to ${process.env.MQTT_TOPIC}`);
        } else {
          console.error("Subscription error:", err);
        }
      });
    });

    this.client.on("message", async (topic, message) => {
      try {
        const data = JSON.parse(message.toString());
        console.log(`Received data on ${topic}:`, data);

        // التحقق من وجود childId
        const child = await Child.findById(data.childId);
        if (!child) {
          console.error(`Child with ID ${data.childId} not found`);
          return;
        }

        // إنشاء سجل SensorData
        const sensorData = new SensorData({
          childId: data.childId,
          deviceId: data.deviceId || null, // اختياري
          temperature: data.temperature,
          heartRate: data.heartRate,
          spo2: data.spo2,
          latitude: data.latitude,
          longitude: data.longitude,
          gyroX: data.gyroX,
          gyroY: data.gyroY,
          gyroZ: data.gyroZ,
          timestamp: data.timestamp,
        });

        await sensorData.save();
        console.log("Sensor data saved:", sensorData);

        // إرسال البيانات إلى العملاء عبر WebSocket
        this.io.emit("sensorData", sensorData);
      } catch (err) {
        console.error("Error processing MQTT message:", err);
      }
    });

    this.client.on("error", (err) => {
      console.error("MQTT Error:", err);
    });
  }
}

module.exports = MQTTService;
