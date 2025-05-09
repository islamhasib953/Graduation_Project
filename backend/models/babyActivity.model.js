const mongoose = require("mongoose");

const babyActivitySchema = new mongoose.Schema({
  childId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: "Child",
    required: true,
  },
  activityStage: {
    type: String,
    enum: [
      "Resting",
      "Light Activity",
      "Moderate Activity",
      "Intense Activity",
      "Distress/Stress",
      "Insufficient Data",
    ],
    required: true,
  },
  bpm: { type: Number, required: false },
  avgGyro: { type: Number, required: false },
  avgAcc: { type: Number, required: false },
  spo2: { type: Number, required: false },
  temperature: { type: Number, required: false },
  ir: { type: Number, required: false },
  red: { type: Number, required: false },
  status: { type: String, required: false },
  validationStatus: {
    type: String,
    enum: ["Validated", "PartiallyValidated", "Invalid"],
    default: "Validated",
  },
  createdAt: { type: Date, default: Date.now },
});

module.exports = mongoose.model("BabyActivity", babyActivitySchema);
