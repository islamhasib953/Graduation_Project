// const mqtt = require("mqtt");
// require("dotenv").config();

// const client = mqtt.connect(
//   `mqtts://${process.env.MQTT_HOST}:${process.env.MQTT_PORT}`,
//   {
//     username: process.env.MQTT_USERNAME,
//     password: process.env.MQTT_PASSWORD,
//   }
// );

// client.on("connect", () => {
//   console.log("Connected to MQTT Broker");

//   // قائمة بمعرفات الأطفال (childIds) - استبدلها بـ ObjectId من قاعدة البيانات
//   const childIds = [
//     "67fcede04bd15f8935785122", // استبدل بـ ObjectId حقيقي
//   ];

//   setInterval(() => {
//     childIds.forEach((childId) => {
//       const fakeData = {
//         childId: childId,
//         temperature: (Math.random() * (37.5 - 36.0) + 36.0).toFixed(2), // 36.0-37.5 °C
//         heartRate: Math.floor(Math.random() * (120 - 70) + 70), // 70-120 bpm
//         spo2: Math.floor(Math.random() * (100 - 95) + 95), // 95-100%
//         latitude: (Math.random() * (30.1 - 30.0) + 30.0).toFixed(6), // منطقة جغرافية
//         longitude: (Math.random() * (31.3 - 31.2) + 31.2).toFixed(6),
//         gyroX: (Math.random() * 0.5 - 0.25).toFixed(2), // حركة خفيفة
//         gyroY: (Math.random() * 0.5 - 0.25).toFixed(2),
//         gyroZ: (Math.random() * 0.5 - 0.25).toFixed(2),
//         timestamp: Date.now(),
//       };

//       client.publish(
//         process.env.MQTT_TOPIC,
//         JSON.stringify(fakeData),
//         (err) => {
//           if (err) {
//             console.error(`Publish error for childId ${childId}:`, err);
//           } else {
//             console.log(
//               `Published fake data for childId ${childId}:`,
//               fakeData
//             );
//           }
//         }
//       );
//     });
//   }, 5000); // إرسال كل 5 ثوانٍ
// });

// client.on("error", (err) => {
//   console.error("MQTT Error:", err);
// });

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
    // "68271e6816742b112f001f24", // استبدل بـ ObjectId حقيقي
    "685326112c28c7e0cf89ea64",
  ];

  setInterval(() => {
    childIds.forEach((childId) => {
const fakeData = {
  childId: childId,
  temperature: Math.random() * (37.2 - 36.1) + 36.1,
  bpm: Math.floor(Math.random() * (95 - 60) + 60),
  spo2: Math.floor(Math.random() * (100 - 95) + 95),
  ir: Math.floor(Math.random() * (22 - 14) + 14),
  latitude: Math.random() * (30.1 - 30.0) + 30.0,
  longitude: Math.random() * (31.3 - 31.2) + 31.2,
  gyroX: Math.random() * (300 - 50) + 50, // 50-300
  gyroY: Math.random() * (300 - 50) + 50,
  gyroZ: Math.random() * (300 - 50) + 50,
  accX: Math.random() * (1.0 - 0.1) + 0.1, // 0.1-1.0
  accY: Math.random() * (1.0 - 0.1) + 0.1,
  accZ: Math.random() * (1.0 - 0.1) + 0.1,
  red: Math.floor(Math.random() * 100),
  status: "active",
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
  }, 10000); // إرسال كل 5 ثوانٍ
});

client.on("error", (err) => {
  console.error("MQTT Error:", err);
});
