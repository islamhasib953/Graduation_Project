const mongoose = require("mongoose");
const validator = require("validator");
const userRoles = require("../utils/userRoles");

const doctorSchema = new mongoose.Schema({
  firstName: {
    type: String,
    required: true,
    minlength: 2,
    maxlength: 255,
  },
  lastName: {
    type: String,
    required: true,
    minlength: 2,
    maxlength: 255,
  },
  gender: {
    type: String,
    enum: ["Male", "Female"],
    required: true,
  },
  phone: {
    type: String,
    required: true,
    unique: true,
    validate: {
      validator: function (value) {
        return /^01[0-2,5]\d{8}$/.test(value);
      },
      message: "Invalid Egyptian phone number",
    },
  },
  address: {
    type: String,
    required: true,
    minlength: 2,
    maxlength: 255,
  },
  email: {
    type: String,
    required: true,
    unique: true,
    minlength: 2,
    maxlength: 255,
    validate: [validator.isEmail, "Invalid Email"],
  },
  password: {
    type: String,
    required: true,
    minlength: 2,
    maxlength: 255,
  },
  token: {
    type: String,
    required: false,
  },
  role: {
    type: String,
    default: userRoles.DOCTOR,
  },
  avatar: {
    type: String,
    default: "uploads/doctor.jpg",
  },
  specialise: {
    type: String,
    required: true,
    minlength: 2,
    maxlength: 255,
    trim: true,
  },
  about: {
    type: String,
    required: true,
    minlength: 2,
    maxlength: 500,
    trim: true,
  },
  rate: {
    type: Number,
    required: true,
    min: 0,
    max: 5,
    default: 0,
  },
  availableDays: [
    {
      type: String,
      required: true,
      trim: true,
    },
  ],
  availableTimes: [
    {
      type: String,
      required: true,
      trim: true,
    },
  ],
  created_at: {
    type: Date,
    default: Date.now,
  },
});

module.exports = mongoose.model("Doctor", doctorSchema);


//***** */