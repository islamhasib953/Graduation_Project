const mongoose = require("mongoose");

const sensorDataSchema = new mongoose.Schema({
  childId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: "Child",
    required: false,
  }, // ربط بالطفل
  deviceId: { type: String, required: false }, // اختياري لتحديد الجهاز
  temperature: { type: Number, required: false },
  heartRate: { type: Number, required: false },
  spo2: { type: Number, required: false },
  latitude: { type: Number, required: false },
  longitude: { type: Number, required: false },
  gyroX: { type: Number, required: false },
  gyroY: { type: Number, required: false },
  gyroZ: { type: Number, required: false },
  timestamp: { type: Number, required: false },
  createdAt: { type: Date, default: Date.now },
});

module.exports = mongoose.model("SensorData", sensorDataSchema);
