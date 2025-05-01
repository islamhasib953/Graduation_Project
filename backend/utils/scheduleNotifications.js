// const cron = require("node-cron");
// const moment = require("moment");
// const Medicine = require("../models/medicine.model");
// const UserVaccination = require("../models/UserVaccination.model");
// const Growth = require("../models/growth.model");
// const Appointment = require("../models/appointment.model");
// const Child = require("../models/child.model");
// const { sendNotification } = require("../controllers/notifications.controller");

// // تخزين مؤقت للأيام والأوقات التي تم إرسال الإشعارات لها
// const sentNotifications = new Set();

// const scheduleNotifications = () => {
//   // إشعارات الأدوية: التحقق كل دقيقة
//   cron.schedule("* * * * *", async () => {
//     try {
//       const now = moment();
//       const currentDay = now.format("dddd");
//       const currentTime = now.format("h:mm A");
//       const currentDate = now.startOf("day").toDate();
//       const notificationKey = `${currentDate.toISOString()}-${currentDay}-${currentTime}-medicine`;

//       if (sentNotifications.has(notificationKey)) {
//         return;
//       }

//       const medicines = await Medicine.find({
//         days: currentDay,
//         times: currentTime,
//       }).populate("childId");

//       for (const medicine of medicines) {
//         const userId = medicine.userId;
//         const childId = medicine.childId._id;
//         const childName = medicine.childId.name;

//         await sendNotification(
//           userId,
//           childId,
//           null,
//           `Medicine Reminder for ${childName}`,
//           `It's time to give ${childName} the medicine: ${medicine.name}.`,
//           "medicine",
//           "user"
//         );
//       }

//       if (medicines.length > 0) {
//         sentNotifications.add(notificationKey);
//       }

//       const yesterday = moment().subtract(1, "day").startOf("day").toDate();
//       for (const key of sentNotifications) {
//         const keyDate = new Date(key.split("-")[0]);
//         if (keyDate < yesterday) {
//           sentNotifications.delete(key);
//         }
//       }
//     } catch (error) {
//       console.error("Error in medicine notification cron job:", error);
//     }
//   });

//   // إشعارات التطعيمات: تذكير يومي في الوقت المحدد
//   cron.schedule("0 8 * * *", async () => {
//     try {
//       const now = moment();
//       const currentDate = now.startOf("day").toDate();
//       const notificationKey = `${currentDate.toISOString()}-vaccination-due`;

//       if (sentNotifications.has(notificationKey)) {
//         return;
//       }

//       const vaccinations = await UserVaccination.find({
//         dueDate: currentDate,
//         status: "Pending",
//       }).populate("childId vaccineInfoId");

//       for (const vaccination of vaccinations) {
//         const userId = vaccination.childId.parentId;
//         const childId = vaccination.childId._id;
//         const childName = vaccination.childId.name;
//         const vaccineDisease = vaccination.vaccineInfoId.disease;

//         await sendNotification(
//           userId,
//           childId,
//           null,
//           `Vaccination Reminder for ${childName}`,
//           `Today is the due date for ${childName}'s ${vaccineDisease} vaccination.`,
//           "vaccination",
//           "user"
//         );
//       }

//       if (vaccinations.length > 0) {
//         sentNotifications.add(notificationKey);
//       }
//     } catch (error) {
//       console.error("Error in vaccination notification cron job:", error);
//     }
//   });

//   // تذكير قبل يوم من التطعيم
//   cron.schedule("0 8 * * *", async () => {
//     try {
//       const tomorrow = moment().add(1, "day").startOf("day").toDate();
//       const notificationKey = `${moment()
//         .startOf("day")
//         .toDate()
//         .toISOString()}-vaccination-reminder`;

//       if (sentNotifications.has(notificationKey)) {
//         return;
//       }

//       const vaccinations = await UserVaccination.find({
//         dueDate: tomorrow,
//         status: "Pending",
//       }).populate("childId vaccineInfoId");

//       for (const vaccination of vaccinations) {
//         const userId = vaccination.childId.parentId;
//         const childId = vaccination.childId._id;
//         const childName = vaccination.childId.name;
//         const vaccineDisease = vaccination.vaccineInfoId.disease;

//         await sendNotification(
//           userId,
//           childId,
//           null,
//           `Vaccination Reminder for ${childName}`,
//           `Reminder: ${childName}'s ${vaccineDisease} vaccination is due tomorrow.`,
//           "vaccination",
//           "user"
//         );
//       }

//       if (vaccinations.length > 0) {
//         sentNotifications.add(notificationKey);
//       }
//     } catch (error) {
//       console.error("Error in vaccination reminder cron job:", error);
//     }
//   });

//   // تنبيه التأخير في التطعيمات
//   cron.schedule("0 9 * * *", async () => {
//     try {
//       const today = moment().startOf("day").toDate();
//       const notificationKey = `${today.toISOString()}-vaccination-delayed`;

//       if (sentNotifications.has(notificationKey)) {
//         return;
//       }

//       const vaccinations = await UserVaccination.find({
//         dueDate: { $lt: today },
//         status: "Pending",  
//       }).populate("childId vaccineInfoId");

//       for (const vaccination of vaccinations) {
//         const userId = vaccination.childId.parentId;
//         const childId = vaccination.childId._id;
//         const childName = vaccination.childId.name;
//         const vaccineDisease = vaccination.vaccineInfoId.disease;

//         await sendNotification(
//           userId,
//           childId,
//           null,
//           `Delayed Vaccination for ${childName}`,
//           `${childName}'s ${vaccineDisease} vaccination is overdue. Please schedule it soon.`,
//           "vaccination",
//           "user"
//         );
//       }

//       if (vaccinations.length > 0) {
//         sentNotifications.add(notificationKey);
//       }
//     } catch (error) {
//       console.error("Error in delayed vaccination cron job:", error);
//     }
//   });

//   // إشعارات النمو
//   cron.schedule("0 10 * * *", async () => {
//     try {
//       const today = moment().startOf("day").toDate();
//       const yesterday = moment().subtract(1, "day").startOf("day").toDate();
//       const notificationKey = `${today.toISOString()}-growth`;

//       if (sentNotifications.has(notificationKey)) {
//         return;
//       }

//       const growthRecords = await Growth.find({
//         date: { $gte: yesterday, $lte: today },
//       }).populate("childId");

//       for (const record of growthRecords) {
//         const userId = record.parentId;
//         const childId = record.childId._id;
//         const childName = record.childId.name;

//         await sendNotification(
//           userId,
//           childId,
//           null,
//           `Growth Update for ${childName}`,
//           `A new growth record for ${childName} has been added: Height: ${record.height}, Weight: ${record.weight}.`,
//           "growth",
//           "user"
//         );

//         const standardHeight = record.ageInMonths * 2 + 50;
//         const heightDeviation = Math.abs(record.height - standardHeight);

//         if (heightDeviation > 10) {
//           await sendNotification(
//             userId,
//             childId,
//             null,
//             `Growth Alert for ${childName}`,
//             `The height of ${childName} (${record.height} cm) deviates significantly from the expected value (${standardHeight} cm) for their age.`,
//             "growth_alert",
//             "user"
//           );
//         }
//       }

//       if (growthRecords.length > 0) {
//         sentNotifications.add(notificationKey);
//       }
//     } catch (error) {
//       console.error("Error in growth notification cron job:", error);
//     }
//   });

//   // تذكير المواعيد قبل يوم
//   cron.schedule("0 8 * * *", async () => {
//     try {
//       const tomorrow = moment().add(1, "day").startOf("day").toDate();
//       const notificationKey = `${moment()
//         .startOf("day")
//         .toDate()
//         .toISOString()}-appointment-reminder`;

//       if (sentNotifications.has(notificationKey)) {
//         return;
//       }

//       const appointments = await Appointment.find({
//         date: tomorrow,
//         status: { $in: ["Pending", "Accepted"] },
//       }).populate("childId doctorId");

//       for (const appointment of appointments) {
//         const userId = appointment.userId;
//         const childId = appointment.childId._id;
//         const childName = appointment.childId.name;
//         const doctorId = appointment.doctorId._id;
//         const doctorName = appointment.doctorId.name;

//         // التحقق إن الموعد لسه موجود وصالح
//         const isValidAppointment =
//           appointment.status === "Pending" || appointment.status === "Accepted";
//         if (!isValidAppointment) {
//           continue;
//         }

//         // إشعار لليوزر
//         await sendNotification(
//           userId,
//           childId,
//           doctorId,
//           `Appointment Reminder for ${childName}`,
//           `Reminder: You have an appointment for ${childName} with Dr. ${doctorName} tomorrow at ${appointment.time}.`,
//           "appointment",
//           "user"
//         );

//         // إشعار للدكتور
//         await sendNotification(
//           null,
//           childId,
//           doctorId,
//           `Appointment Reminder for ${childName}`,
//           `Reminder: You have an appointment with ${childName} tomorrow at ${appointment.time}.`,
//           "appointment",
//           "doctor"
//         );
//       }

//       if (appointments.length > 0) {
//         sentNotifications.add(notificationKey);
//       }
//     } catch (error) {
//       console.error("Error in appointment reminder cron job:", error);
//     }
//   });
// };

// module.exports = scheduleNotifications;


const cron = require("node-cron");
const moment = require("moment");
const Medicine = require("../models/medicine.model");
const UserVaccination = require("../models/UserVaccination.model");
const Growth = require("../models/growth.model");
const Appointment = require("../models/appointment.model");
const Child = require("../models/child.model");
const { sendNotification } = require("../controllers/notifications.controller");

async function scheduleNotifications() {
  // Medication reminders (every minute)
  cron.schedule("* * * * *", async () => {
    try {
      const now = new Date();
      const currentDay = now.toLocaleString("en-US", { weekday: "long" });
      const currentTime = now.toTimeString().slice(0, 5);

      const medicines = await Medicine.find({
        days: currentDay,
        times: currentTime,
      }).populate("childId", "name parentId");

      for (const medicine of medicines) {
        const user = await User.findById(medicine.userId);
        if (user && user.fcmToken && medicine.childId) {
          await sendNotification(
            user._id,
            medicine.childId._id,
            null,
            "Medication Reminder",
            `Give ${medicine.childId.name} ${medicine.name} now.`,
            "medicine",
            "user"
          );
        }
      }
    } catch (error) {
      console.error("Error in medication reminder cron:", error);
    }
  });

  // Vaccination reminders (every day at 8:00 AM)
  cron.schedule("0 8 * * *", async () => {
    try {
      const today = new Date();
      today.setHours(0, 0, 0, 0);
      const tomorrow = new Date(today);
      tomorrow.setDate(tomorrow.getDate() + 1);

      const vaccinations = await UserVaccination.find({
        $or: [
          {
            dueDate: {
              $gte: today,
              $lt: new Date(today.getTime() + 24 * 60 * 60 * 1000),
            },
          }, // Today
          {
            dueDate: {
              $gte: tomorrow,
              $lt: new Date(tomorrow.getTime() + 24 * 60 * 60 * 1000),
            },
          }, // Tomorrow
        ],
        status: "pending",
      })
        .populate("childId", "name parentId")
        .populate("vaccineInfoId", "name");

      for (const vaccination of vaccinations) {
        const user = await User.findById(vaccination.childId.parentId);
        if (
          user &&
          user.fcmToken &&
          vaccination.childId &&
          vaccination.vaccineInfoId
        ) {
          const isToday =
            vaccination.dueDate >= today &&
            vaccination.dueDate <
              new Date(today.getTime() + 24 * 60 * 60 * 1000);
          const message = isToday
            ? `${vaccination.childId.name} due for ${vaccination.vaccineInfoId.name} today.`
            : `${vaccination.childId.name} due for ${vaccination.vaccineInfoId.name} tomorrow.`;

          await sendNotification(
            user._id,
            vaccination.childId._id,
            null,
            "Vaccination Reminder",
            message,
            "vaccination",
            "user"
          );
        }
      }
    } catch (error) {
      console.error("Error in vaccination reminder cron:", error);
    }
  });

  // Appointment reminders (every day at 8:00 AM)
  cron.schedule("0 8 * * *", async () => {
    try {
      const tomorrow = new Date();
      tomorrow.setDate(tomorrow.getDate() + 1);
      tomorrow.setHours(0, 0, 0, 0);
      const endOfTomorrow = new Date(tomorrow);
      endOfTomorrow.setDate(endOfTomorrow.getDate() + 1);

      const appointments = await Appointment.find({
        date: { $gte: tomorrow, $lt: endOfTomorrow },
      })
        .populate("userId", "firstName")
        .populate("childId", "name")
        .populate("doctorId", "firstName lastName");

      for (const appointment of appointments) {
        const user = await User.findById(appointment.userId._id);
        if (
          user &&
          user.fcmToken &&
          appointment.childId &&
          appointment.doctorId
        ) {
          await sendNotification(
            user._id,
            appointment.childId._id,
            appointment.doctorId._id,
            "Appointment Reminder",
            `With Dr. ${appointment.doctorId.firstName} tomorrow at ${appointment.time}.`,
            "appointment",
            "user"
          );
        }
      }
    } catch (error) {
      console.error("Error in appointment reminder cron:", error);
    }
  });

  // Growth deviation check (every month on the 1st at 9:00 AM)
  cron.schedule("0 9 1 * *", async () => {
    try {
      const children = await Child.find().populate("parentId", "firstName");
      const now = new Date();

      for (const child of children) {
        const birthDate = new Date(child.birthDate);
        const ageInMonths = Math.floor(
          (now - birthDate) / (1000 * 60 * 60 * 24 * 30)
        );

        if (ageInMonths < 0 || ageInMonths > 60) continue;

        const latestGrowth = await Growth.findOne({ childId: child._id })
          .sort({ date: -1 })
          .select("height");

        if (!latestGrowth) continue;

        const height = latestGrowth.height;

        const averageHeight = getAverageHeightForAge(ageInMonths, child.gender);
        const deviationThreshold = 10;

        if (
          Math.abs(height - averageHeight) > deviationThreshold &&
          child.parentId
        ) {
          const status = height > averageHeight ? "above" : "below";
          const user = await User.findById(child.parentId._id);

          if (user && user.fcmToken) {
            await sendNotification(
              user._id,
              child._id,
              null,
              "Growth Alert",
              `${child.name}'s height is ${status} average. Consult a doctor.`,
              "growth",
              "user"
            );
          }
        }
      }
    } catch (error) {
      console.error("Error in growth deviation cron:", error);
    }
  });
}

// Dummy function for average height (replace with actual data)
function getAverageHeightForAge(ageInMonths, gender) {
  const heightTable = {
    male: {
      0: 49.9,
      1: 54.7,
      2: 58.4,
      3: 61.4,
      6: 67.6,
      12: 75.7,
      24: 87.1,
      36: 96.1,
      48: 103.3,
      60: 109.4,
    },
    female: {
      0: 49.1,
      1: 53.7,
      2: 57.1,
      3: 59.8,
      6: 65.7,
      12: 74.0,
      24: 85.7,
      36: 95.1,
      48: 102.7,
      60: 108.4,
    },
  };

  const genderTable = heightTable[gender.toLowerCase()] || heightTable.male;
  const ages = Object.keys(genderTable)
    .map(Number)
    .sort((a, b) => a - b);

  if (ageInMonths <= ages[0]) return genderTable[ages[0]];
  if (ageInMonths >= ages[ages.length - 1])
    return genderTable[ages[ages.length - 1]];

  const lowerAge = ages.find((age) => age <= ageInMonths);
  const upperAge = ages.find((age) => age > ageInMonths);

  if (!lowerAge || !upperAge) return genderTable[lowerAge || upperAge];

  const lowerHeight = genderTable[lowerAge];
  const upperHeight = genderTable[upperAge];
  const ageDiff = upperAge - lowerAge;
  const heightDiff = upperHeight - lowerHeight;
  const ageFraction = (ageInMonths - lowerAge) / ageDiff;

  return lowerHeight + heightDiff * ageFraction;
}

module.exports = { scheduleNotifications };