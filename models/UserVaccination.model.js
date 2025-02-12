const mongoose = require("mongoose");

const UserVaccinationSchema = new mongoose.Schema({
  userId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: "User",
    required: true,
  },
  vaccinationId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: "Vaccination",
    required: true,
  },
  status: {
    type: String,
    enum: ["Taken", "Skipped", "Pending"],
    default: "Pending",
  },
  actualDate: {
    type: Date,
    validate: {
      validator: function (value) {
        return value instanceof Date;
      },
      message: "Invalid date format",
    },
  },
  actualTime: {
    type: String,
    validate: {
      validator: function (value) {
        return /^(0[0-9]|1[0-2]):[0-5][0-9]$/.test(value);
      },
      message: "Invalid time format",
    },
  },
  notes: {
    type: String,
    maxlength: 500,
    trim: true,
  },
  image: {
    type: String, // حفظ رابط الصورة
  },
  nextScheduledDate: {
    type: Date,
  },
});

// تحديث `nextScheduledDate` تلقائيًا بناءً على `actualDate`
UserVaccinationSchema.pre("save", async function (next) {
  if (this.isModified("actualDate") && this.actualDate) {
    // البحث عن تفاصيل التطعيم
    const vaccination = await mongoose
      .model("Vaccination")
      .findById(this.vaccinationId);
    if (vaccination) {
      const intervalMonths = 2; // مثال: الجرعة التالية بعد شهرين
      this.nextScheduledDate = new Date(this.actualDate);
      this.nextScheduledDate.setMonth(
        this.actualDate.getMonth() + intervalMonths
      );
    }
  }
  next();
});

module.exports = mongoose.model("UserVaccination", UserVaccinationSchema);
