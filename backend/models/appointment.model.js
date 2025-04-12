const mongoose = require("mongoose");

const appointmentSchema = new mongoose.Schema({
  userId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: "User",
    required: true,
  },
  doctorId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: "Doctor",
    required: true,
  },
  date: {
    type: String, // مثلاً "2025-04-21"
    required: true,
  },
  time: {
    type: String, // مثلاً "9:00 AM"
    required: true,
  },
  visitType: {
    type: String, // "On Clinic", "On Home", "Video Call"
    required: true,
  },
  status: {
    type: String,
    enum: ["Pending", "Accepted", "Closed"],
    default: "Pending",
  },
  created_at: {
    type: Date,
    default: Date.now,
  },
});

module.exports = mongoose.model("Appointment", appointmentSchema);
