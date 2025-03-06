const WebSocket = require("ws");
const SensorData = require("../models/SensorData");

const wss = new WebSocket.Server({ port: 8080 });

wss.on("connection", (ws) => {
  console.log("✅ Client connected");

  setInterval(async () => {
    const latestData = await SensorData.find().sort({ timestamp: -1 }).limit(1);
    if (latestData.length > 0) {
      ws.send(JSON.stringify(latestData[0]));
    }
  }, 5000);

  ws.on("close", () => {
    console.log("❌ Client disconnected");
  });
});

module.exports = wss;
