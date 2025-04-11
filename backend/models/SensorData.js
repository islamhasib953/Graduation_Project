const mongoose = require("mongoose");

const SensorDataSchema = new mongoose.Schema({
  heartRate: Number,
  temperature: Number,
  oxygenLevel: Number,
  gps: {
    lat: Number,
    lon: Number,
  },
  gyro: {
    x: Number,
    y: Number,
    z: Number,
  },
  timestamp: { type: Date, default: Date.now },
});

module.exports = mongoose.model("SensorData", SensorDataSchema);
