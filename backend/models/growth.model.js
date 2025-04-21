const mongoose = require("mongoose");

const GrowthSchema = new mongoose.Schema(
  {
    parentId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "User",
      required: true,
    },
    childId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "Child",
      required: true,
    },
    weight: {
      type: Number,
      required: [true, "Weight is required"],
      min: [0, "Weight must be positive"],
    },
    height: {
      type: Number,
      required: [true, "Height is required"],
      min: [0, "Height must be positive"],
    },
    headCircumference: {
      type: Number,
      required: [true, "Head circumference is required"],
      min: [0, "Head circumference must be positive"],
    },
    date: {
      type: Date,
      required: [true, "Date is required"],
    },
    time: {
      type: String,
      required: [true, "Time is required"],
    },
    notes: {
      type: String,
    },
    notesImage: {
      type: String,
    },
    ageInMonths: {
      type: Number,
      min: [0, "Age in months must be positive"],
    },
  },
  { timestamps: true } // Ensure createdAt and updatedAt are added automatically
);

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
