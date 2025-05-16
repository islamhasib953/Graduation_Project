const mongoose = require("mongoose");
const validator = require("validator");
const userRoles = require("../utils/userRoles");

const doctorSchema = new mongoose.Schema(
  {
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
      enum: [userRoles.DOCTOR],
      default: userRoles.DOCTOR,
      required: true,
    },
    fcmToken: { type: String, default: null },
    avatar: {
      type: String,
      default: "uploads/doctor-default.jpg",
      validate: {
        validator: function (value) {
          return !value || /\.(jpg|jpeg|png|gif)$/i.test(value);
        },
        message: "Avatar must be a valid image file",
      },
    },
    specialise: {
      type: String,
      required: false,
      minlength: 2,
      maxlength: 255,
      trim: true,
    },
    about: {
      type: String,
      required: false,
      minlength: 2,
      maxlength: 500,
      trim: true,
    },
    rate: {
      type: Number,
      required: false,
      min: 0,
      max: 5,
      default: 0,
    },
    availableDays: [
      {
        type: String,
        required: false,
        trim: true,
      },
    ],
    availableTimes: [
      {
        type: String,
        required: false,
        trim: true,
      },
    ],
  },
  { timestamps: true }
);

module.exports = mongoose.model("Doctor", doctorSchema);
