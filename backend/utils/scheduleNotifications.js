const cron = require("node-cron");
const Medicine = require("../models/medicine.model");
const UserVaccination = require("../models/UserVaccination.model");
const Child = require("../models/child.model");
const Growth = require("../models/growth.model");
const Appointment = require("../models/appointment.model");
const Doctor = require("../models/doctor.model");
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
        dueDate: { $lt: now },
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

  // Schedule growth notifications (runs daily at 10 AM to check for updates)
  cron.schedule("0 10 * * *", async () => {
    try {
      const today = moment().startOf("day").toDate();
      const yesterday = moment().subtract(1, "day").startOf("day").toDate();

      const growthRecords = await Growth.find({
        date: { $gte: yesterday, $lte: today },
      }).populate("childId");

      for (const record of growthRecords) {
        const child = record.childId;
        if (!child) {
          console.warn(`Missing child for growth record ID: ${record._id}`);
          continue;
        }

        // إرسال إشعار تحديث النمو
        await sendNotification(
          child.parentId,
          child._id,
          null,
          `Growth Update for ${child.name}`,
          `${child.name}'s growth updated: Height: ${record.height} cm, Weight: ${record.weight} kg, Head Circumference: ${record.headCircumference} cm.`,
          "growth"
        );

        // التحقق من الانحرافات (مثال: افتراض معايير مبسطة للطول بناءً على العمر)
        const ageInMonths = moment().diff(moment(child.birthDate), "months");
        const expectedHeight = ageInMonths * 0.5 + 50; // معادلة مبسطة: 50 سم عند الولادة + 0.5 سم لكل شهر
        const heightDeviation = Math.abs(record.height - expectedHeight);

        if (heightDeviation > 10) {
          // الانحراف أكثر من 10 سم
          await sendNotification(
            child.parentId,
            child._id,
            null,
            `Growth Alert for ${child.name}`,
            `${child.name}'s height (${record.height} cm) deviates significantly from the expected average (${expectedHeight} cm). Please consult a doctor.`,
            "growth_alert"
          );
        }
      }
    } catch (error) {
      console.error("Error scheduling growth notifications:", error);
    }
  });

  // Schedule appointment reminders (1 day before, runs daily at 8 AM)
  cron.schedule("0 8 * * *", async () => {
    try {
      const tomorrow = moment().add(1, "day").startOf("day").toDate();
      const endOfTomorrow = moment(tomorrow).endOf("day").toDate();

      const appointments = await Appointment.find({
        date: { $gte: tomorrow, $lte: endOfTomorrow },
        status: { $in: ["Pending", "Accepted"] },
      })
        .populate("childId")
        .populate("doctorId");

      for (const appointment of appointments) {
        const child = appointment.childId;
        const doctor = appointment.doctorId;

        if (!child || !doctor) {
          console.warn(
            `Missing child or doctor for appointment ID: ${appointment._id}`
          );
          continue;
        }

        // إشعار للمستخدم
        await sendNotification(
          appointment.userId,
          child._id,
          doctor._id,
          `Appointment Reminder for ${child.name}`,
          `You have an appointment with Dr. ${doctor.firstName} ${doctor.lastName} tomorrow at ${appointment.time}.`,
          "appointment_reminder"
        );
      }
    } catch (error) {
      console.error("Error scheduling appointment reminders:", error);
    }
  });
};

module.exports = scheduleNotifications;
