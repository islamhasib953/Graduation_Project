const mongoose = require("mongoose");

const calculateDueDate = async function (next) {
  if (this.isNew) {
    const child = await mongoose.model("Child").findById(this.childId);
    if (!child || !child.birthDate) {
      return next(new Error("Invalid child ID or missing birth date"));
    }

    const vaccineInfo = await mongoose
      .model("VaccineInfo")
      .findById(this.vaccineInfoId);
    if (!vaccineInfo || vaccineInfo.originalSchedule === undefined) {
      return next(new Error("Invalid vaccine information ID"));
    }

    const lastVaccination = await mongoose
      .model("UserVaccination")
      .findOne({ childId: this.childId })
      .sort({ dueDate: -1 })
      .select("delayDays");

    const lastDelayDays = lastVaccination ? lastVaccination.delayDays : 0;

    // ✅ Calculate `dueDate`
    this.dueDate = new Date(child.birthDate);
    this.dueDate.setMonth(
      this.dueDate.getMonth() + vaccineInfo.originalSchedule
    );
    this.dueDate.setDate(this.dueDate.getDate() + lastDelayDays);

    console.log("📌 Calculated dueDate:", this.dueDate);
  }
  next();
};

const updateDelayDays = async function (next) {
  try {
    if (this.isModified("actualDate") && this.actualDate) {
      const delay = Math.floor(
        (new Date(actualDate) - new Date(dueDate)) / (1000 * 60 * 60 * 24)
      );

      this.delayDays = delay > 0 ? delay : 0;

      if (delay > 0) {
        const futureVaccinations = await mongoose
          .model("UserVaccination")
          .find({
            childId: this.childId,
            dueDate: { $gt: this.dueDate },
          });

        for (let vaccination of futureVaccinations) {
          vaccination.dueDate = new Date(vaccination.dueDate);
          vaccination.dueDate.setDate(vaccination.dueDate.getDate() + delay);
          vaccination.delayDays += delay;
          await vaccination.save();
        }
      }
    }
    next();
  } catch (error) {
    next(error);
  }
};

module.exports = {
  calculateDueDate,
  updateDelayDays,
};
