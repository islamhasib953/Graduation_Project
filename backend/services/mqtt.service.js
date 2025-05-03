// const mqtt = require("mqtt");
// const SensorData = require("../models/sensorData.model");
// const Child = require("../models/child.model");
// require("dotenv").config();

// class MQTTService {
//   constructor(io) {
//     this.io = io;
//     this.client = mqtt.connect(
//       `mqtts://${process.env.MQTT_HOST}:${process.env.MQTT_PORT}`,
//       {
//         username: process.env.MQTT_USERNAME,
//         password: process.env.MQTT_PASSWORD,
//       }
//     );
//   }

//   connect() {
//     this.client.on("connect", () => {
//       console.log("Connected to MQTT Broker");
//       this.client.subscribe(process.env.MQTT_TOPIC, (err) => {
//         if (!err) {
//           console.log(`Subscribed to ${process.env.MQTT_TOPIC}`);
//         } else {
//           console.error("Subscription error:", err);
//         }
//       });
//     });

//     this.client.on("message", async (topic, message) => {
//       try {
//         const data = JSON.parse(message.toString());
//         console.log(`Received data on ${topic}:`, data);

//         // التحقق من وجود childId
//         const child = await Child.findById(data.childId);
//         if (!child) {
//           console.error(`Child with ID ${data.childId} not found`);
//           return;
//         }

//         // إنشاء سجل SensorData
//         const sensorData = new SensorData({ ...data });

//         await sensorData.save();
//         console.log("Sensor data saved:", sensorData);

//         // إرسال البيانات إلى العملاء عبر WebSocket
//         this.io.emit("sensorData", sensorData);
//       } catch (err) {
//         console.error("Error processing MQTT message:", err);
//       }
//     });

//     this.client.on("error", (err) => {
//       console.error("MQTT Error:", err);
//     });
//   }
// }

// module.exports = MQTTService;


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
        if (!err) console.log(`Subscribed to ${process.env.MQTT_TOPIC}`);
        else console.error("Subscription error:", err);
      });
    });

    this.client.on("message", async (topic, message) => {
      try {
        const data = JSON.parse(message.toString());
        console.log(`Received data on ${topic}:`, data);

        const child = await Child.findById(data.childId);
        if (!child) {
          console.error(
            `Child with ID ${data.childId} not found, skipping save`
          );
          return;
        }

        const sensorData = new SensorData({ ...data });
        await sensorData.save();
        console.log("Sensor data saved:", sensorData);

        // تمت إزالة إرسال البيانات الخام للفرونت
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