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
    required: true,
  },
  weight: { type: Number, required: true },
  height: { type: Number, required: true },
  headCircumference: { type: Number, required: true },
  date: { type: Date, required: true },
  time: { type: String, required: true },
  notes: { type: String, default: "" },
  notesImage: {
    type: String,
    default: null,
    validate: {
      validator: function (v) {
        return !v || /\.(jpg|jpeg|png|gif)$/i.test(v);
      },
      message: "Image must be a valid file",
    },
  },
  ageInMonths: { type: Number },
});

GrowthSchema.pre("save", async function (next) {
  const child = await mongoose.model("Child").findById(this.childId);
  if (child) {
    const birthDate = new Date(child.birthDate);
    const recordDate = new Date(this.date);
    this.ageInMonths = Math.floor(
      (recordDate - birthDate) / (1000 * 60 * 60 * 24 * 30)
    );
  }
  next();
});

const Growth = mongoose.model("Growth", GrowthSchema);
module.exports = Growth;
