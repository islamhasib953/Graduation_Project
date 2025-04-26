const mongoose = require("mongoose");

const sensorDataSchema = new mongoose.Schema({
  childId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: "Child",
    required: true,
  }, // ربط بالطفل
  deviceId: { type: String, required: false }, // اختياري لتحديد الجهاز
  temperature: { type: Number, required: true },
  heartRate: { type: Number, required: true },
  spo2: { type: Number, required: true },
  latitude: { type: Number, required: true },
  longitude: { type: Number, required: true },
  gyroX: { type: Number, required: true },
  gyroY: { type: Number, required: true },
  gyroZ: { type: Number, required: true },
  timestamp: { type: Number, required: true },
  createdAt: { type: Date, default: Date.now },
});

module.exports = mongoose.model("SensorData", sensorDataSchema);
