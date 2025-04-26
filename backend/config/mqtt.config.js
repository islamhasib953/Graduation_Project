require("dotenv").config();

module.exports = {
  mqtt: {
    host: process.env.MQTT_HOST,
    port: process.env.MQTT_PORT,
    username: process.env.MQTT_USERNAME,
    password: process.env.MQTT_PASSWORD,
    topic: process.env.MQTT_TOPIC,
    protocol: "mqtts",
  },
};
