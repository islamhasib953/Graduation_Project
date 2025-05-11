const mongoose = require("mongoose");

const sensorDataSchema = new mongoose.Schema({
  childId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: "Child",
    required: false,
  },
  temperature: { type: Number, required: false },
  spo2: { type: Number, required: false },
  latitude: { type: Number, required: false },
  longitude: { type: Number, required: false },
  gyroX: { type: Number, required: false },
  gyroY: { type: Number, required: false },
  gyroZ: { type: Number, required: false },
  bpm: { type: Number, required: false },
  ir: { type: Number, required: false },
  red: { type: Number, required: false },
  accX: { type: Number, required: false },
  accY: { type: Number, required: false },
  accZ: { type: Number, required: false },
  status: { type: String, required: false },
  timestamp: { type: Number, required: false },
  createdAt: { type: Date, default: Date.now },
});

module.exports = mongoose.model("SensorData", sensorDataSchema);
