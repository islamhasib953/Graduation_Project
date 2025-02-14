const mongoose = require("mongoose");

const MedicineSchema = new mongoose.Schema(
  {
    childId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "Child",
      required: true,
    },
    name: { type: String, required: true },
    description: {
      type: String,
      trim: true,
      maxlength: [500, "Notes cannot exceed 500 characters"],
    },
    days: { type: [String], required: true }, // Array of selected days
    times: { type: [String], required: true }, // Array of times (e.g., "8 AM", "4 PM")
  },
  { timestamps: true }
);

module.exports = mongoose.model("Medicine", MedicineSchema);
