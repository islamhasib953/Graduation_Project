const mongoose = require("mongoose");

const memorySchema = new mongoose.Schema(
  {
    childId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "Child",
      required: true,
    },
    image: {
      type: String,
      default: "uploads/vaccination.jpg",
      validate: {
        validator: function (value) {
          return /\.(jpg|jpeg|png|gif)$/i.test(value);
        },
        message: "Image must be a valid image file",
      },
    },
    description: {
      type: String,
      trim: true,
      maxlength: [500, "Notes cannot exceed 500 characters"],
    },
    date: {
      type: Date,
      default: Date.now,
    },
    time: {
      type: String,
      required: true,
    },
    isFavorite: {
      type: Boolean,
      default: false,
    },
  },
  { timestamps: true }
);

const Memory = mongoose.model("Memory", memorySchema);
module.exports = Memory;
