const mongoose = require("mongoose");

const VaccinationSchema = new mongoose.Schema({
  ageAfterBirth: {
    type: String,
    required: [true, "Age after birth is required"],
    trim: true,
  },
  dose: {
    type: String,
    required: [true, "Dose information is required"],
    minlength: [3, "Dose must be at least 3 characters"],
    maxlength: [50, "Dose cannot exceed 50 characters"],
    trim: true,
  },
  disease: {
    type: String,
    required: [true, "Disease name is required"],
    minlength: [3, "Disease name must be at least 3 characters"],
    maxlength: [100, "Disease name cannot exceed 100 characters"],
    trim: true,
  },
  vaccineAmount: {
    type: String,
    maxlength: [20, "Vaccine amount must be at most 20 characters"],
    trim: true,
  },
  administrationMethod: {
    type: String,
    required: [true, "Administration method is required"],
    trim: true,
  },
  description: {
    type: String,
    maxlength: [500, "Description cannot exceed 500 characters"],
    trim: true,
  },
  intervalMonths: { type: [Number], required: true },
});

module.exports = mongoose.model("Vaccination", VaccinationSchema);
