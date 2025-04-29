const cron = require("node-cron");
const Medicine = require("../models/medicine.model");
const UserVaccination = require("../models/UserVaccination.model");
const Child = require("../models/child.model");
const { sendNotification } = require("../controllers/notifications.controller");
const moment = require("moment");

const scheduleNotifications = () => {
  // Schedule medicine notifications (every minute)
  cron.schedule("* * * * *", async () => {
    try {
      const now = moment();
      const currentTime = now.format("h:mm A");
      const currentDate = now.startOf("day").toDate();

      const medicines = await Medicine.find({
        schedule: currentTime,
        startDate: { $lte: currentDate },
        endDate: { $gte: currentDate },
      }).populate("childId");

      for (const medicine of medicines) {
        const child = medicine.childId;
        await sendNotification(
          child.parentId,
          medicine.childId,
          null,
          `Medicine Reminder for ${child.name}`,
          `It's time for ${child.name} to take ${medicine.name} (${medicine.dosage}).`,
          "medicine"
        );
      }
    } catch (error) {
      console.error("Error scheduling medicine notifications:", error);
    }
  });

  // Schedule vaccination notifications (every minute for exact due date)
  cron.schedule("* * * * *", async () => {
    try {
      const now = moment();
      const currentDateTime = now.toDate();
      const startOfMinute = moment(now).startOf("minute").toDate();
      const endOfMinute = moment(now).endOf("minute").toDate();

      const vaccinations = await UserVaccination.find({
        dueDate: {
          $gte: startOfMinute,
          $lte: endOfMinute,
        },
        status: "Pending",
      })
        .populate("childId")
        .populate("vaccineInfoId");

      for (const vaccination of vaccinations) {
        const child = vaccination.childId;
        const vaccineInfo = vaccination.vaccineInfoId;

        if (!child || !vaccineInfo) {
          console.warn(
            `Missing child or vaccine info for vaccination ID: ${vaccination._id}`
          );
          continue;
        }

        await sendNotification(
          child.parentId,
          vaccination.childId,
          null,
          `Vaccination Reminder for ${child.name}`,
          `It's time for ${child.name}'s ${
            vaccineInfo.disease
          } vaccination (Dose: ${vaccineInfo.doseName}). Dosage: ${
            vaccineInfo.dosageAmount
          }, Method: ${vaccineInfo.administrationMethod}.${
            vaccineInfo.description ? ` Note: ${vaccineInfo.description}` : ""
          }`,
          "vaccination"
        );
      }
    } catch (error) {
      console.error("Error scheduling vaccination notifications:", error);
    }
  });

  // Schedule vaccination reminders (1 day before, runs daily at 8 AM)
  cron.schedule("0 8 * * *", async () => {
    try {
      const tomorrow = moment().add(1, "day").startOf("day").toDate();
      const endOfTomorrow = moment(tomorrow).endOf("day").toDate();

      const vaccinations = await UserVaccination.find({
        dueDate: {
          $gte: tomorrow,
          $lte: endOfTomorrow,
        },
        status: "Pending",
      })
        .populate("childId")
        .populate("vaccineInfoId");

      for (const vaccination of vaccinations) {
        const child = vaccination.childId;
        const vaccineInfo = vaccination.vaccineInfoId;

        if (!child || !vaccineInfo) {
          console.warn(
            `Missing child or vaccine info for vaccination ID: ${vaccination._id}`
          );
          continue;
        }

        await sendNotification(
          child.parentId,
          vaccination.childId,
          null,
          `Upcoming Vaccination for ${child.name}`,
          `Reminder: ${child.name}'s ${
            vaccineInfo.disease
          } vaccination (Dose: ${
            vaccineInfo.doseName
          }) is scheduled for tomorrow at ${moment(vaccination.dueDate).format(
            "h:mm A"
          )}. Dosage: ${vaccineInfo.dosageAmount}, Method: ${
            vaccineInfo.administrationMethod
          }.${
            vaccineInfo.description ? ` Note: ${vaccineInfo.description}` : ""
          }`,
          "vaccination"
        );
      }
    } catch (error) {
      console.error("Error scheduling vaccination reminders:", error);
    }
  });

  // Schedule delayed vaccination notifications (runs daily at 9 AM)
  cron.schedule("0 9 * * *", async () => {
    try {
      const now = moment().startOf("day").toDate();

      const vaccinations = await UserVaccination.find({
        dueDate: { $lt: now }, // التطعيمات اللي موعدها خلّص
        status: "Pending", // ولم تُؤخذ بعد
      })
        .populate("childId")
        .populate("vaccineInfoId");

      for (const vaccination of vaccinations) {
        const child = vaccination.childId;
        const vaccineInfo = vaccination.vaccineInfoId;

        if (!child || !vaccineInfo) {
          console.warn(
            `Missing child or vaccine info for vaccination ID: ${vaccination._id}`
          );
          continue;
        }

        const daysDelayed = moment(now).diff(
          moment(vaccination.dueDate),
          "days"
        );

        await sendNotification(
          child.parentId,
          vaccination.childId,
          null,
          `Delayed Vaccination for ${child.name}`,
          `${child.name}'s ${vaccineInfo.disease} vaccination (Dose: ${
            vaccineInfo.doseName
          }) is delayed by ${daysDelayed} day(s). Please schedule it as soon as possible. Dosage: ${
            vaccineInfo.dosageAmount
          }, Method: ${vaccineInfo.administrationMethod}.${
            vaccineInfo.description ? ` Note: ${vaccineInfo.description}` : ""
          }`,
          "vaccination"
        );

        // تحديث حالة التطعيم لـ Missed لو التأخير أكتر من 7 أيام (اختياري)
        if (daysDelayed > 7) {
          vaccination.status = "Missed";
          await vaccination.save();
        }
      }
    } catch (error) {
      console.error(
        "Error scheduling delayed vaccination notifications:",
        error
      );
    }
  });
};

module.exports = scheduleNotifications;
