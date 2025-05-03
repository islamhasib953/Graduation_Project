const mqtt = require("mqtt");
require("dotenv").config();

const client = mqtt.connect(
  `mqtts://${process.env.MQTT_HOST}:${process.env.MQTT_PORT}`,
  {
    username: process.env.MQTT_USERNAME,
    password: process.env.MQTT_PASSWORD,
  }
);

client.on("connect", () => {
  console.log("Connected to MQTT Broker");

  // قائمة بمعرفات الأطفال (childIds) - استبدلها بـ ObjectId من قاعدة البيانات
  const childIds = [
    "67fcede04bd15f8935785122", // استبدل بـ ObjectId حقيقي
  ];

  setInterval(() => {
    childIds.forEach((childId) => {
      const fakeData = {
        childId: childId,
        temperature: (Math.random() * (37.5 - 36.0) + 36.0).toFixed(2), // 36.0-37.5 °C
        heartRate: Math.floor(Math.random() * (120 - 70) + 70), // 70-120 bpm
        spo2: Math.floor(Math.random() * (100 - 95) + 95), // 95-100%
        latitude: (Math.random() * (30.1 - 30.0) + 30.0).toFixed(6), // منطقة جغرافية
        longitude: (Math.random() * (31.3 - 31.2) + 31.2).toFixed(6),
        gyroX: (Math.random() * 0.5 - 0.25).toFixed(2), // حركة خفيفة
        gyroY: (Math.random() * 0.5 - 0.25).toFixed(2),
        gyroZ: (Math.random() * 0.5 - 0.25).toFixed(2),
        timestamp: Date.now(),
      };

      client.publish(
        process.env.MQTT_TOPIC,
        JSON.stringify(fakeData),
        (err) => {
          if (err) {
            console.error(`Publish error for childId ${childId}:`, err);
          } else {
            console.log(
              `Published fake data for childId ${childId}:`,
              fakeData
            );
          }
        }
      );
    });
  }, 5000); // إرسال كل 5 ثوانٍ
});

client.on("error", (err) => {
  console.error("MQTT Error:", err);
});
