const mongoose = require("mongoose");

/**
 * Middleware to calculate dueDate based on child's birthDate, originalSchedule, and last delayDays.
 */
const calculateDueDate = async function (next) {
  if (this.isNew) {
    const child = await mongoose.model("Child").findById(this.childId);
    if (!child) {
      return next(new Error("Invalid child ID"));
    }

    const vaccineInfo = await mongoose
      .model("VaccineInfo")
      .findById(this.vaccineInfoId);
    if (!vaccineInfo) {
      return next(new Error("Invalid vaccine information ID"));
    }

    // ✅ Fetch last delayDays for this child only
    const lastVaccination = await mongoose
      .model("UserVaccination")
      .findOne({ childId: this.childId })
      .sort({ dueDate: -1 })
      .select("delayDays");

    const lastDelayDays = lastVaccination ? lastVaccination.delayDays : 0;

    // ✅ Calculate dueDate (birthDate + originalSchedule + last delayDays)
    this.dueDate = new Date(child.birthDate);
    this.dueDate.setMonth(
      this.dueDate.getMonth() + vaccineInfo.originalSchedule
    );
    this.dueDate.setDate(this.dueDate.getDate() + lastDelayDays);
  }
  next();
};

/**
 * Middleware to update delayDays and shift future vaccinations for the same child.
 */
const updateDelayDays = async function (next) {
  if (this.isModified("actualDate") && this.actualDate) {
    const delay = Math.floor(
      (new Date(this.actualDate) - new Date(this.dueDate)) /
        (1000 * 60 * 60 * 24)
    );

    if (delay > 0) {
      this.delayDays = delay; // ✅ Store delayDays in database

      // ✅ Update all future vaccinations for this child with the new delay
      await mongoose.model("UserVaccination").updateMany(
        {
          childId: this.childId,
          dueDate: { $gt: this.dueDate },
        },
        { $inc: { dueDate: delay * 24 * 60 * 60 * 1000 } } // Shift future vaccinations
      );
    }
  }
  next();
};

module.exports = {
  calculateDueDate,
  updateDelayDays,
};
