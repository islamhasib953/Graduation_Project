const mongoose = require("mongoose");

const notificationSchema = new mongoose.Schema(
  {
    userId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "User",
      required: false,
    },
    childId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "Child",
      required: false,
    },
    doctorId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "Doctor",
      required: false,
    },
    title: {
      type: String,
      required: true,
    },
    message: {
      type: String,
      required: true,
    },
    type: {
      type: String,
      enum: [
        "medicine",
        "vaccination",
        "growth",
        "growth_alert",
        "appointment",
        "appointment_reminder",
        "favorite",
        "general",
        "profile",
        "logout",
        "doctor",
      ],
      required: true,
    },
    recipientId: {
      type: mongoose.Schema.Types.ObjectId,
      required: false, // اختياري للتوافق مع الإشعارات القديمة
    },
    recipientType: {
      type: String,
      enum: ["patient", "doctor"],
      required: false, // اختياري للتوافق مع الإشعارات القديمة
    },
  },
  { timestamps: true }
);

module.exports = mongoose.model("Notification", notificationSchema);
