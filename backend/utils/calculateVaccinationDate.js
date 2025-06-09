// const mongoose = require("mongoose");

// /**
//  * Middleware to calculate dueDate based on child's birthDate, originalSchedule, and last delayDays.
//  */
// const calculateDueDate = async function (next) {
//   if (this.isNew) {
//     const child = await mongoose.model("Child").findById(this.childId);
//     if (!child || !child.birthDate) {
//       return next(new Error("Invalid child ID or missing birth date"));
//     }

//     const vaccineInfo = await mongoose
//       .model("VaccineInfo")
//       .findById(this.vaccineInfoId);
//     if (!vaccineInfo || vaccineInfo.originalSchedule === undefined) {
//       return next(new Error("Invalid vaccine information ID"));
//     }

//     // ✅ Fetch last delay for this specific child
//     const lastVaccination = await mongoose
//       .model("UserVaccination")
//       .findOne({ childId: this.childId })
//       .sort({ dueDate: -1 })
//       .select("delayDays");

//     const lastDelayDays = lastVaccination ? lastVaccination.delayDays : 0;

//     // ✅ Calculate `dueDate`
//     this.dueDate = new Date(child.birthDate);
//     this.dueDate.setMonth(
//       this.dueDate.getMonth() + vaccineInfo.originalSchedule
//     );
//     this.dueDate.setDate(this.dueDate.getDate() + lastDelayDays);

//     console.log("📌 Calculated dueDate:", this.dueDate);
//   }
//   next();
// };

// /**
//  * Middleware to update delayDays and calculate delay for the current vaccination.
//  */
// const updateDelayDays = async function (next) {
//   try {
//     if (this.isModified("actualDate") && this.actualDate) {
//       // إزالة الوقت من التواريخ عشان نحسب الفرق بالأيام فقط
//       const actual = new Date(this.actualDate);
//       const due = new Date(this.dueDate);

//       actual.setHours(0, 0, 0, 0);
//       due.setHours(0, 0, 0, 0);

//       // حساب التأخير بالأيام
//       const delay = Math.floor((actual - due) / (1000 * 60 * 60 * 24));

//       console.log(
//         `📌 Calculated delay for vaccination ${
//           this._id
//         }: ${delay} days (actual: ${actual.toISOString()}, due: ${due.toISOString()})`
//       );

//       this.delayDays = delay > 0 ? delay : 0;

//       // نترك تحديث التطعيمات المستقبلية للـ controller
//     }
//     next();
//   } catch (error) {
//     console.error(`📌 Error in updateDelayDays: ${error.message}`);
//     next(error);
//   }
// };

// module.exports = {
//   calculateDueDate,
//   updateDelayDays,
// };

const mongoose = require("mongoose");

/**
 * Middleware to calculate dueDate based on child's birthDate, originalSchedule, and last delayDays.
 */
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

    // ✅ Fetch last delay for this specific child
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

/**
 * Middleware to update delayDays and shift future vaccinations for the same child.
 */
const updateDelayDays = async function (next) {
  try {
    if (this.isModified("actualDate") && this.actualDate) {
      const delay = Math.floor(
        (new Date(actualDate) - new Date(dueDate)) / (1000 * 60 * 60 * 24)
      );

      this.delayDays = delay > 0 ? delay : 0;

      if (delay > 0) {
        // ✅ Fetch all future vaccinations for the child
        const futureVaccinations = await mongoose
          .model("UserVaccination")
          .find({
            childId: this.childId,
            dueDate: { $gt: this.dueDate },
          });

        // ✅ Update each future vaccination record manually
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
