const mongoose = require("mongoose");

const sleepQualitySchema = new mongoose.Schema({
  childId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: "Child",
    required: true,
  },
  sleepStage: {
    type: String,
    enum: ["Deep Sleep", "Light Sleep", "REM", "Awake", "Sleep Disturbance"],
    required: true,
  },
  bpm: { type: Number, required: false },
  avgAcc: { type: Number, required: false },
  spo2: { type: Number, required: false },
  temperature: { type: Number, required: false },
  ir: { type: Number, required: false },
  red: { type: Number, required: false },
  avgGyro: { type: Number, required: false },
  status: { type: String, required: false },
  validationStatus: {
    type: String,
    enum: ["Validated", "PartiallyValidated", "Invalid"],
    default: "Validated",
  },
  timestamp: { type: Number, required: true },
  createdAt: { type: Date, default: Date.now },
});

module.exports = mongoose.model("SleepQuality", sleepQualitySchema);
