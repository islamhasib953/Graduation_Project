const mongoose = require("mongoose");

const ChildSchema = new mongoose.Schema(
  {
    name: { type: String, required: [true, "Name is required"], trim: true },
    gender: {
      type: String,
      enum: ["Boy", "Girl"],
      required: [true, "Gender is required"],
    },
    birthDate: { type: Date, required: [true, "Birth date is required"] },
    heightAtBirth: { type: Number, min: [0, "Height must be positive"] },
    weightAtBirth: { type: Number, min: [0, "Weight must be positive"] },
    bloodType: {
      type: String,
      match: [/^(A|B|AB|O)[+-]$/, "Invalid blood type"],
    },
    parentId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "User",
      required: true,
    },
    photo: {
      type: String,
      default: "uploads/vaccination.jpg",
      validate: {
        validator: function (value) {
          return /\.(jpg|jpeg|png|gif)$/i.test(value);
        },
        message: "Image must be a valid image file",
      },
    },
    favorite: [
      {
        type: mongoose.Schema.Types.ObjectId,
        ref: "Doctor",
        required: false,
      },
    ], // حقل جديد لتخزين الدكاترة المفضلة لكل طفل
  },
  { timestamps: true }
);

module.exports = mongoose.model("Child", ChildSchema);
