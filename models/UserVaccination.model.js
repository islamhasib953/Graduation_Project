const mongoose = require("mongoose");
const {
  calculateDueDate,
  updateDelayDays,
} = require("../utils/calculateVaccinationDate");

const UserVaccinationSchema = new mongoose.Schema(
  {
    childId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "Child",
      required: [true, "Child ID is required"],
    },
    vaccineInfoId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "VaccineInfo",
      required: [true, "Vaccine Info ID is required"],
    },
    dueDate: {
      type: Date,
      required: true,
    },
    actualDate: {
      type: Date,
      required: false,
    },
    // actualTime: {
    //   type: String,
    //   required: true,
    // },
    delayDays: {
      type: Number,
      default: 0,
      min: [0, "Delay days cannot be negative"],
    },
    status: {
      type: String,
      enum: ["Pending", "Taken", "Missed"],
      default: "Pending",
    },
    notes: {
      type: String,
      trim: true,
      maxlength: [500, "Notes cannot exceed 500 characters"],
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
  },
  { timestamps: true }
);

// ✅ Attach Middlewares
// UserVaccinationSchema.pre("validate", async function (next) {
//   if (!this.dueDate) {
//     await calculateDueDate.call(this, next);
//   }
//   next();
// });


// UserVaccinationSchema.pre("save", async function (next) {
//   await updateDelayDays.call(this, next);
// });

module.exports = mongoose.model("UserVaccination", UserVaccinationSchema);
