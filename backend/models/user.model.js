const mongoose = require("mongoose");
const validator = require("validator");
const userRoles = require("../utils/userRoles");

const userSchema = new mongoose.Schema({
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
    enum: [userRoles.ADMIN, userRoles.PATIENT], // التعديل هنا: استبعدنا DOCTOR لأنه دلوقتي في موديل منفصل
    default: userRoles.PATIENT, // التأكد إن الـ default مش معلّق
    required: true, // جعلناه إجباري
  },
  avatar: {
    type: String,
    default: "uploads/profile.jpg",
  },
  favorite: [
    {
      type: mongoose.Schema.Types.ObjectId,
      ref: "Doctor",
      required: false,
    },
  ],
  created_at: {
    type: Date,
    default: Date.now,
  },
});

module.exports = mongoose.model("User", userSchema);
