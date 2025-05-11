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

  const childIds = ["67fcede04bd15f8935785122"];
  console.log("Child IDs:", childIds);

  setInterval(() => {
    childIds.forEach((childId) => {
      const isInvalid = Math.random() < 0.1;
      const statuses = ["active", "No finger detected", "error", "calibrating"];
      const randomStatus =
        statuses[Math.floor(Math.random() * statuses.length)];

      const fakeData = {
        childId: childId,
        temperature: isInvalid
          ? null
          : (Math.random() * (37.2 - 36.1) + 36.1).toFixed(2),
        bpm: isInvalid ? null : Math.floor(Math.random() * (110 - 70) + 70),
        spo2: isInvalid ? null : Math.floor(Math.random() * (100 - 95) + 95),
        ir: isInvalid ? null : Math.floor(Math.random() * (30 - 20) + 20),
        latitude: isInvalid
          ? null
          : (Math.random() * (30.1 - 30.0) + 30.0).toFixed(6),
        longitude: isInvalid
          ? null
          : (Math.random() * (31.3 - 31.2) + 31.2).toFixed(6),
        gyroX: (Math.random() * 0.5).toFixed(2),
        gyroY: (Math.random() * 0.5).toFixed(2),
        gyroZ: (Math.random() * 0.5).toFixed(2),
        accX: (Math.random() * 0.5).toFixed(2),
        accY: (Math.random() * 0.5).toFixed(2),
        accZ: (Math.random() * 1.0).toFixed(2),
        red: isInvalid
          ? null
          : Math.floor(Math.random() * (20000 - 1000) + 1000),
        status: randomStatus,
      };

      client.publish(
        process.env.MQTT_TOPIC || "sensors/data",
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
  }, 3000);
});

client.on("error", (err) => {
  console.error("MQTT Error:", err);
});