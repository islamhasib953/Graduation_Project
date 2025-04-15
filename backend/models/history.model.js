const mongoose = require("mongoose");

const HistorySchema = new mongoose.Schema(
  {
    childId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "Child",
      required: [true, "Child ID is required"],
    },
    diagnosis: {
      type: String,
      required: [true, "Diagnosis is required"],
      trim: true,
      minlength: [3, "Diagnosis must be at least 3 characters long"],
    },
    disease: {
      type: String,
      required: [true, "Disease is required"],
      trim: true,
      minlength: [3, "Disease must be at least 3 characters long"],
    },
    treatment: {
      type: String,
      required: [true, "Treatment is required"],
      trim: true,
      minlength: [5, "Treatment must be at least 5 characters long"],
    },
    notes: {
      type: String,
      trim: true,
      maxlength: [500, "Notes cannot exceed 500 characters"],
    },
    date: {
      type: Date,
      required: [true, "Date is required"],
      validate: {
        validator: function (value) {
          return value <= new Date();
        },
        message: "Date cannot be in the future",
      },
    },
    time: {
      type: String,
      required: [true, "Time is required"],
    },
    // doctor: {
    //   type: String,
    //   required: [true, "Doctor is required"],
    //   trim: true,
    // },
    doctorName: {
      type: String,
      required: [true, "Doctor name is required"], // الحقل إجباري
      trim: true,
      default: "Dr. Islam Hasib", // القيمة الافتراضية لو ما اتحطش قيمة
    },
    // doctorImage: {
    //   type: String,
    //   default: "uploads/default-doctor.jpg",
    //   validate: {
    //     validator: function (value) {
    //       return /\.(jpg|jpeg|png|gif)$/i.test(value);
    //     },
    //     message: "Doctor image must be a valid image file",
    //   },
    // },
    notesImage: {
      type: String,
      default: null,
      validate: {
        validator: function (value) {
          return !value || /\.(jpg|jpeg|png|gif)$/i.test(value);
        },
        message: "Notes image must be a valid image file",
      },
    },
  },
  { timestamps: true }
);

module.exports = mongoose.model("History", HistorySchema);
