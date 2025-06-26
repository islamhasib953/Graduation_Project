const mongoose = require("mongoose");

const vaccineInfoSchema = new mongoose.Schema(
  {
    ageVaccine: {
      type: String,
      required: [true, "Age vaccine is required"],
      trim: true,
    },
    originalSchedule: {
      type: Number,
      required: [true, "Original schedule (in months) is required"],
    },
    doseName: {
      type: String,
      required: [true, "Dose number is required"],
      min: [1, "Dose number must be at least 1"],
    },
    disease: {
      type: String,
      required: [true, "Disease name is required"],
      trim: true,
    },
    dosageAmount: {
      type: String,
      required: [true, "Dosage amount is required"],
      trim: true,
    },
    administrationMethod: {
      type: String,
      required: [true, "Administration method is required"],
    },
    description: {
      type: String,
      trim: true,
      maxlength: [500, "Description cannot exceed 500 characters"],
    },
  },
  { timestamps: true }
);

module.exports = mongoose.model("VaccineInfo", vaccineInfoSchema);
