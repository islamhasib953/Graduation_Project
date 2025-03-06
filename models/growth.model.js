const mongoose = require("mongoose");

const GrowthSchema = new mongoose.Schema({
  childId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: "Child",
    required: true,
  },
  parentId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: "User",
    required: true
  },
  weight: {
    type: Number,
    required: true,
  },
  height: {
    type: Number,
    required: true,
  },
  headCircumference: {
    type: Number,
    required: true,
  },
  date: {
    type: String,
    required: true,
  },
  time: {
    type: String,
    required: true,
  },
  notes: {
    type: String,
    default: "",
  },
  notesImage: {
    type: String,
    default: null,
    validate: {
      validator: function (value) {
        return /\.(jpg|jpeg|png|gif)$/i.test(value);
      },
      message: "Image must be a valid image file",
    },
  },
});

const Growth = mongoose.model("Growth", GrowthSchema);
module.exports = Growth;
