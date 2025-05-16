// const cron = require("node-cron");
// const moment = require("moment");
// const Medicine = require("../models/medicine.model");
// const UserVaccination = require("../models/UserVaccination.model");
// const Growth = require("../models/growth.model");
// const Appointment = require("../models/appointment.model");
// const Child = require("../models/child.model");
// const Notification = require("../models/notification.model");
// const { sendNotification } = require("../controllers/notifications.controller");

// const scheduleNotifications = () => {
//   // إشعارات الأدوية: التحقق كل دقيقة
//   cron.schedule("* * * * *", async () => {
//     try {
//       const now = moment();
//       const currentDay = now.format("dddd");
//       const currentTime = now.format("h:mm A");
//       const currentDate = now.startOf("day").toDate();

//       console.log(
//         `Checking medicine notifications at ${currentTime} on ${currentDay}`
//       );

//       const medicines = await Medicine.find({
//         days: currentDay,
//       }).populate("childId");

//       if (medicines.length === 0) {
//         console.log("No medicines found for this day.");
//         return;
//       }

//       const currentMoment = moment(now.format("h:mm A"), "h:mm A");

//       for (const medicine of medicines) {
//         // التحقق من وجود userId و childId
//         if (!medicine.userId) {
//           console.error(`Medicine with ID ${medicine._id} has missing userId`);
//           continue;
//         }
//         if (!medicine.childId) {
//           console.error(
//             `Medicine with ID ${medicine._id} has invalid or missing childId: ${medicine.childId}`
//           );
//           continue;
//         }

//         const userId = medicine.userId;
//         const childId = medicine.childId._id;
//         const childName = medicine.childId.name;

//         for (const time of medicine.times) {
//           // التحقق من صلاحية تنسيق الوقت
//           const medicineTime = moment(time, "h:mm A", true);
//           if (!medicineTime.isValid()) {
//             console.error(
//               `Invalid time format for medicine ${medicine._id}: ${time}`
//             );
//             continue;
//           }

//           const notificationKey = `${currentDate.toISOString()}-${currentDay}-${
//             medicine._id
//           }-${time}-medicine`;

//           // التحقق من وجود إشعار تم إرساله
//           const existingNotification = await Notification.findOne({
//             userId,
//             childId,
//             type: "medicine",
//             title: `Medicine Reminder for ${childName}`,
//             sentAt: { $gte: moment().subtract(1, "week").toDate() },
//           });

//           if (existingNotification) {
//             console.log(`Notification already sent for ${notificationKey}`);
//             continue;
//           }

//           const timeDiffMinutes = Math.abs(
//             currentMoment.diff(medicineTime, "minutes")
//           );

//           if (timeDiffMinutes <= 5) {
//             try {
//               await sendNotification(
//                 userId,
//                 childId,
//                 null,
//                 `Medicine Reminder for ${childName}`,
//                 `It's time to give ${childName} the medicine: ${medicine.name}.`,
//                 "medicine",
//                 "patient"
//               );
//               console.log(
//                 `Medicine reminder sent successfully for ${childName} at ${currentTime}: ${medicine.name}`
//               );
//             } catch (error) {
//               console.error(
//                 `Failed to send medicine reminder for ${childName}: ${medicine.name}`,
//                 error
//               );
//             }
//           }
//         }
//       }
//     } catch (error) {
//       console.error("Error in medicine notification cron job:", error);
//     }
//   });
  
//   // إشعارات التطعيمات: التحقق كل دقيقة بناءً على الوقت (8:00 AM ±5 دقائق)
//   cron.schedule("* * * * *", async () => {
//     try {
//       const now = moment();
//       const currentTime = now.format("h:mm A");
//       const currentDate = now.startOf("day").toDate();

//       console.log(`Checking vaccination notifications at ${currentTime}`);

//       const currentMoment = moment(now.format("h:mm A"), "h:mm A");
//       const notificationTime = "8:00 AM";
//       const notificationMoment = moment(notificationTime, "h:mm A");
//       const timeDiffMinutes = Math.abs(
//         currentMoment.diff(notificationMoment, "minutes")
//       );

//       if (timeDiffMinutes > 5) {
//         return;
//       }

//       const vaccinations = await UserVaccination.find({
//         status: "Pending",
//       }).populate("childId vaccineInfoId");

//       if (vaccinations.length === 0) {
//         console.log("No pending vaccinations found.");
//         return;
//       }

//       for (const vaccination of vaccinations) {
//         const userId = vaccination.childId.parentId;
//         const childId = vaccination.childId._id;
//         const childName = vaccination.childId.name;
//         const vaccineDisease = vaccination.vaccineInfoId.disease;
//         const dueDate = moment(vaccination.dueDate).startOf("day").toDate();

//         const dueDateKey = `${currentDate.toISOString()}-${childId}-${
//           vaccination._id
//         }-vaccination-due`;

//         // التحقق من وجود إشعار تم إرساله لهذا التطعيم
//         const existingDueNotification = await Notification.findOne({
//           userId,
//           childId,
//           type: "vaccination",
//           title: `Vaccination Reminder for ${childName}`,
//           sentAt: { $gte: moment().subtract(1, "week").toDate() },
//         });

//         if (
//           moment(currentDate).isSame(dueDate, "day") &&
//           !existingDueNotification
//         ) {
//           try {
//             await sendNotification(
//               userId,
//               childId,
//               null,
//               `Vaccination Reminder for ${childName}`,
//               `Today is the due date for ${childName}'s ${vaccineDisease} vaccination.`,
//               "vaccination",
//               "patient"
//             );
//             console.log(
//               `Vaccination due reminder sent for ${childName}: ${vaccineDisease}`
//             );
//           } catch (error) {
//             console.error(
//               `Failed to send vaccination due reminder for ${childName}`,
//               error
//             );
//           }
//         }

//         const tomorrow = moment().add(1, "day").startOf("day").toDate();
//         const reminderKey = `${currentDate.toISOString()}-${childId}-${
//           vaccination._id
//         }-vaccination-reminder`;

//         const existingReminderNotification = await Notification.findOne({
//           userId,
//           childId,
//           type: "vaccination",
//           title: `Vaccination Reminder for ${childName}`,
//           sentAt: { $gte: moment().subtract(1, "week").toDate() },
//         });

//         if (
//           moment(tomorrow).isSame(dueDate, "day") &&
//           !existingReminderNotification
//         ) {
//           try {
//             await sendNotification(
//               userId,
//               childId,
//               null,
//               `Vaccination Reminder for ${childName}`,
//               `Reminder: Tomorrow is the due date for ${childName}'s ${vaccineDisease} vaccination.`,
//               "vaccination",
//               "patient"
//             );
//             console.log(
//               `Vaccination reminder sent for ${childName}: ${vaccineDisease}`
//             );
//           } catch (error) {
//             console.error(
//               `Failed to send vaccination reminder for ${childName}`,
//               error
//             );
//           }
//         }

//         const oneWeekAgo = moment().subtract(7, "days").startOf("day").toDate();
//         const daysLate = moment(currentDate).diff(moment(dueDate), "days");
//         if (
//           moment(currentDate).isAfter(dueDate, "day") &&
//           moment(currentDate).isBefore(moment(dueDate).add(7, "days"), "day")
//         ) {
//           const delayKey = `${currentDate.toISOString()}-${childId}-${
//             vaccination._id
//           }-vaccination-delayed`;

//           const existingDelayNotification = await Notification.findOne({
//             userId,
//             childId,
//             type: "vaccination",
//             title: `Delayed Vaccination for ${childName}`,
//             sentAt: { $gte: moment().subtract(1, "week").toDate() },
//           });

//           if (!existingDelayNotification) {
//             try {
//               await sendNotification(
//                 userId,
//                 childId,
//                 null,
//                 `Delayed Vaccination for ${childName}`,
//                 `${childName}'s ${vaccineDisease} vaccination is overdue by ${daysLate} day(s). Please schedule it soon.`,
//                 "vaccination",
//                 "patient"
//               );
//               console.log(
//                 `Delayed vaccination reminder sent for ${childName}: ${vaccineDisease}`
//               );
//             } catch (error) {
//               console.error(
//                 `Failed to send delayed vaccination reminder for ${childName}`,
//                 error
//               );
//             }
//           }
//         }

//         const missedKey = `${currentDate.toISOString()}-${childId}-${
//           vaccination._id
//         }-vaccination-missed`;

//         const existingMissedNotification = await Notification.findOne({
//           userId,
//           childId,
//           type: "vaccination",
//           title: `Missed Vaccination for ${childName}`,
//           sentAt: { $gte: moment().subtract(1, "week").toDate() },
//         });

//         if (
//           moment(currentDate).isAfter(moment(dueDate).add(7, "days"), "day") &&
//           !existingMissedNotification
//         ) {
//           try {
//             vaccination.status = "Missed";
//             await vaccination.save();
//             await sendNotification(
//               userId,
//               childId,
//               null,
//               `Missed Vaccination for ${childName}`,
//               `${childName}'s ${vaccineDisease} vaccination was missed. Please consult your doctor.`,
//               "vaccination",
//               "patient"
//             );
//             console.log(
//               `Missed vaccination notification sent for ${childName}: ${vaccineDisease}`
//             );
//           } catch (error) {
//             console.error(
//               `Failed to send missed vaccination notification for ${childName}`,
//               error
//             );
//           }
//         }
//       }
//     } catch (error) {
//       console.error("Error in vaccination notification cron job:", error);
//     }
//   });

//   // إشعارات النمو (الساعة 10:00 صباحًا)
//   cron.schedule("0 10 * * *", async () => {
//     try {
//       const today = moment().startOf("day").toDate();
//       const yesterday = moment().subtract(1, "day").startOf("day").toDate();

//       const existingNotification = await Notification.findOne({
//         type: "growth",
//         sentAt: { $gte: yesterday },
//       });

//       if (existingNotification) {
//         console.log("Growth notification already sent today");
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
//           "patient"
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
//             "patient"
//           );
//         }
//       }
//     } catch (error) {
//       console.error("Error in growth notification cron job:", error);
//     }
//   });

//   // تذكير المواعيد قبل يوم (الساعة 8:00 صباحًا ±5 دقائق) للمواعيد المقبولة فقط
//   cron.schedule("* * * * *", async () => {
//     try {
//       const now = moment();
//       const currentTime = now.format("h:mm A");
//       const currentDate = now.startOf("day").toDate();

//       const currentMoment = moment(now.format("h:mm A"), "h:mm A");
//       const notificationTime = "8:00 AM";
//       const notificationMoment = moment(notificationTime, "h:mm A");
//       const timeDiffMinutes = Math.abs(
//         currentMoment.diff(notificationMoment, "minutes")
//       );

//       if (timeDiffMinutes > 5) {
//         return;
//       }

//       const tomorrow = moment().add(1, "day").startOf("day").toDate();

//       const existingNotification = await Notification.findOne({
//         type: "appointment_reminder",
//         sentAt: { $gte: moment().subtract(1, "week").toDate() },
//       });

//       if (existingNotification) {
//         console.log("Appointment reminder already sent today");
//         return;
//       }

//       const appointments = await Appointment.find({
//         date: tomorrow,
//         status: "Accepted",
//       })
//         .populate("childId")
//         .populate("doctorId", "firstName lastName")
//         .populate("userId", "firstName lastName");

//       for (const appointment of appointments) {
//         const userId = appointment.userId;
//         const childId = appointment.childId._id;
//         const childName = appointment.childId.name;
//         const doctorId = appointment.doctorId._id;

//         await sendNotification(
//           userId,
//           childId,
//           doctorId,
//           `Appointment Reminder for ${childName}`,
//           `Reminder: You have an appointment for ${childName} with Dr. ${appointment.doctorId.firstName} ${appointment.doctorId.lastName} tomorrow at ${appointment.time}.`,
//           "appointment_reminder",
//           "patient"
//         );

//         if (doctorId) {
//           await sendNotification(
//             doctorId,
//             childId,
//             userId,
//             `Appointment Reminder for ${childName}`,
//             `Reminder: You have an appointment with ${childName} tomorrow at ${appointment.time}.`,
//             "appointment_reminder",
//             "doctor"
//           );
//         }
//       }
//     } catch (error) {
//       console.error("Error in appointment reminder cron job:", error);
//     }
//   });

//   // تنظيف الإشعارات القديمة (كل يوم في منتصف الليل)
//   cron.schedule("0 0 * * *", async () => {
//     const oneMonthAgo = moment().subtract(1, "month").toDate();
//     await Notification.deleteMany({ createdAt: { $lt: oneMonthAgo } });
//     console.log("Old notifications deleted (older than 1 month)");
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
const Notification = require("../models/notification.model");
const {
  sendNotificationCore,
} = require("../controllers/notifications.controller");

const scheduleNotifications = () => {
  // إشعارات الأدوية: التحقق كل دقيقة
  cron.schedule("* * * * *", async () => {
    try {
      const now = moment();
      const currentDay = now.format("dddd");
      const currentTime = now.format("h:mm A");
      const currentDate = now.startOf("day").toDate();

      console.log(
        `Checking medicine notifications at ${currentTime} on ${currentDay}`
      );

      const medicines = await Medicine.find({
        days: currentDay,
      }).populate("childId");

      if (medicines.length === 0) {
        console.log("No medicines found for this day.");
        return;
      }

      const currentMoment = moment(now.format("h:mm A"), "h:mm A");

      for (const medicine of medicines) {
        // التحقق من وجود userId و childId
        if (!medicine.userId) {
          console.error(`Medicine with ID ${medicine._id} has missing userId`);
          continue;
        }
        if (!medicine.childId) {
          console.error(
            `Medicine with ID ${medicine._id} has invalid or missing childId: ${medicine.childId}`
          );
          continue;
        }

        const userId = medicine.userId;
        const childId = medicine.childId._id;
        const childName = medicine.childId.name;

        for (const time of medicine.times) {
          // تحويل الوقت من تنسيق ISO 8601 إلى h:mm A
          let medicineTime;
          try {
            // محاولة تحويل الوقت من ISO 8601
            medicineTime = moment(time, "YYYY-MM-DDTHH:mm:ss.SSS", true);
            if (!medicineTime.isValid()) {
              // إذا كان التنسيق مش ISO، جرب تنسيق h:mm A
              medicineTime = moment(time, "h:mm A", true);
            }
            if (!medicineTime.isValid()) {
              console.error(
                `Invalid time format for medicine ${medicine._id}: ${time}`
              );
              continue;
            }
            // تحويل الوقت إلى تنسيق h:mm A للمقارنة
            medicineTime = moment(medicineTime.format("h:mm A"), "h:mm A");
          } catch (error) {
            console.error(
              `Error parsing time for medicine ${medicine._id}: ${time}`,
              error
            );
            continue;
          }

          const notificationKey = `${currentDate.toISOString()}-${currentDay}-${
            medicine._id
          }-${time}-medicine`;

          // التحقق من وجود إشعار تم إرساله
          const existingNotification = await Notification.findOne({
            userId,
            childId,
            type: "medicine",
            title: `Medicine Reminder for ${childName}`,
            sentAt: { $gte: moment().subtract(1, "week").toDate() },
          });

          if (existingNotification) {
            console.log(`Notification already sent for ${notificationKey}`);
            continue;
          }

          const timeDiffMinutes = Math.abs(
            currentMoment.diff(medicineTime, "minutes")
          );

          if (timeDiffMinutes <= 5) {
            try {
              await sendNotificationCore(
                userId,
                childId,
                null,
                `Medicine Reminder for ${childName}`,
                `It's time to give ${childName} the medicine: ${medicine.name}.`,
                "medicine",
                "patient"
              );
              console.log(
                `Medicine reminder sent successfully for ${childName} at ${currentTime}: ${medicine.name}`
              );
            } catch (error) {
              console.error(
                `Failed to send medicine reminder for ${childName}: ${medicine.name}`,
                error
              );
            }
          }
        }
      }
    } catch (error) {
      console.error("Error in medicine notification cron job:", error);
    }
  });

  // إشعارات التطعيمات: التحقق كل دقيقة بناءً على الوقت (8:00 AM ±5 دقائق)
  cron.schedule("* * * * *", async () => {
    try {
      const now = moment();
      const currentTime = now.format("h:mm A");
      const currentDate = now.startOf("day").toDate();

      console.log(`Checking vaccination notifications at ${currentTime}`);

      const currentMoment = moment(now.format("h:mm A"), "h:mm A");
      const notificationTime = "8:00 AM";
      const notificationMoment = moment(notificationTime, "h:mm A");
      const timeDiffMinutes = Math.abs(
        currentMoment.diff(notificationMoment, "minutes")
      );

      if (timeDiffMinutes > 5) {
        return;
      }

      const vaccinations = await UserVaccination.find({
        status: "Pending",
      }).populate("childId vaccineInfoId");

      if (vaccinations.length === 0) {
        console.log("No pending vaccinations found.");
        return;
      }

      for (const vaccination of vaccinations) {
        const userId = vaccination.childId.parentId;
        const childId = vaccination.childId._id;
        const childName = vaccination.childId.name;
        const vaccineDisease = vaccination.vaccineInfoId.disease;
        const dueDate = moment(vaccination.dueDate).startOf("day").toDate();

        const dueDateKey = `${currentDate.toISOString()}-${childId}-${
          vaccination._id
        }-vaccination-due`;

        // التحقق من وجود إشعار تم إرساله لهذا التطعيم
        const existingDueNotification = await Notification.findOne({
          userId,
          childId,
          type: "vaccination",
          title: `Vaccination Reminder for ${childName}`,
          sentAt: { $gte: moment().subtract(1, "week").toDate() },
        });

        if (
          moment(currentDate).isSame(dueDate, "day") &&
          !existingDueNotification
        ) {
          try {
            await sendNotificationCore(
              userId,
              childId,
              null,
              `Vaccination Reminder for ${childName}`,
              `Today is the due date for ${childName}'s ${vaccineDisease} vaccination.`,
              "vaccination",
              "patient"
            );
            console.log(
              `Vaccination due reminder sent for ${childName}: ${vaccineDisease}`
            );
          } catch (error) {
            console.error(
              `Failed to send vaccination due reminder for ${childName}`,
              error
            );
          }
        }

        const tomorrow = moment().add(1, "day").startOf("day").toDate();
        const reminderKey = `${currentDate.toISOString()}-${childId}-${
          vaccination._id
        }-vaccination-reminder`;

        const existingReminderNotification = await Notification.findOne({
          userId,
          childId,
          type: "vaccination",
          title: `Vaccination Reminder for ${childName}`,
          sentAt: { $gte: moment().subtract(1, "week").toDate() },
        });

        if (
          moment(tomorrow).isSame(dueDate, "day") &&
          !existingReminderNotification
        ) {
          try {
            await sendNotificationCore(
              userId,
              childId,
              null,
              `Vaccination Reminder for ${childName}`,
              `Reminder: Tomorrow is the due date for ${childName}'s ${vaccineDisease} vaccination.`,
              "vaccination",
              "patient"
            );
            console.log(
              `Vaccination reminder sent for ${childName}: ${vaccineDisease}`
            );
          } catch (error) {
            console.error(
              `Failed to send vaccination reminder for ${childName}`,
              error
            );
          }
        }

        const oneWeekAgo = moment().subtract(7, "days").startOf("day").toDate();
        const daysLate = moment(currentDate).diff(moment(dueDate), "days");
        if (
          moment(currentDate).isAfter(dueDate, "day") &&
          moment(currentDate).isBefore(moment(dueDate).add(7, "days"), "day")
        ) {
          const delayKey = `${currentDate.toISOString()}-${childId}-${
            vaccination._id
          }-vaccination-delayed`;

          const existingDelayNotification = await Notification.findOne({
            userId,
            childId,
            type: "vaccination",
            title: `Delayed Vaccination for ${childName}`,
            sentAt: { $gte: moment().subtract(1, "week").toDate() },
          });

          if (!existingDelayNotification) {
            try {
              await sendNotificationCore(
                userId,
                childId,
                null,
                `Delayed Vaccination for ${childName}`,
                `${childName}'s ${vaccineDisease} vaccination is overdue by ${daysLate} day(s). Please schedule it soon.`,
                "vaccination",
                "patient"
              );
              console.log(
                `Delayed vaccination reminder sent for ${childName}: ${vaccineDisease}`
              );
            } catch (error) {
              console.error(
                `Failed to send delayed vaccination reminder for ${childName}`,
                error
              );
            }
          }
        }

        const missedKey = `${currentDate.toISOString()}-${childId}-${
          vaccination._id
        }-vaccination-missed`;

        const existingMissedNotification = await Notification.findOne({
          userId,
          childId,
          type: "vaccination",
          title: `Missed Vaccination for ${childName}`,
          sentAt: { $gte: moment().subtract(1, "week").toDate() },
        });

        if (
          moment(currentDate).isAfter(moment(dueDate).add(7, "days"), "day") &&
          !existingMissedNotification
        ) {
          try {
            vaccination.status = "Missed";
            await vaccination.save();
            await sendNotificationCore(
              userId,
              childId,
              null,
              `Missed Vaccination for ${childName}`,
              `${childName}'s ${vaccineDisease} vaccination was missed. Please consult your doctor.`,
              "vaccination",
              "patient"
            );
            console.log(
              `Missed vaccination notification sent for ${childName}: ${vaccineDisease}`
            );
          } catch (error) {
            console.error(
              `Failed to send missed vaccination notification for ${childName}`,
              error
            );
          }
        }
      }
    } catch (error) {
      console.error("Error in vaccination notification cron job:", error);
    }
  });

  // إشعارات النمو (الساعة 10:00 صباحًا)
  cron.schedule("0 10 * * *", async () => {
    try {
      const today = moment().startOf("day").toDate();
      const yesterday = moment().subtract(1, "day").startOf("day").toDate();

      const existingNotification = await Notification.findOne({
        type: "growth",
        sentAt: { $gte: yesterday },
      });

      if (existingNotification) {
        console.log("Growth notification already sent today");
        return;
      }

      const growthRecords = await Growth.find({
        date: { $gte: yesterday, $lte: today },
      }).populate("childId");

      for (const record of growthRecords) {
        const userId = record.parentId;
        const childId = record.childId._id;
        const childName = record.childId.name;

        await sendNotificationCore(
          userId,
          childId,
          null,
          `Growth Update for ${childName}`,
          `A new growth record for ${childName} has been added: Height: ${record.height}, Weight: ${record.weight}.`,
          "growth",
          "patient"
        );

        const standardHeight = record.ageInMonths * 2 + 50;
        const heightDeviation = Math.abs(record.height - standardHeight);

        if (heightDeviation > 10) {
          await sendNotificationCore(
            userId,
            childId,
            null,
            `Growth Alert for ${childName}`,
            `The height of ${childName} (${record.height} cm) deviates significantly from the expected value (${standardHeight} cm) for their age.`,
            "growth_alert",
            "patient"
          );
        }
      }
    } catch (error) {
      console.error("Error in growth notification cron job:", error);
    }
  });

  // تذكير المواعيد قبل يوم (الساعة 8:00 صباحًا ±5 دقائق) للمواعيد المقبولة فقط
  cron.schedule("* * * * *", async () => {
    try {
      const now = moment();
      const currentTime = now.format("h:mm A");
      const currentDate = now.startOf("day").toDate();

      const currentMoment = moment(now.format("h:mm A"), "h:mm A");
      const notificationTime = "8:00 AM";
      const notificationMoment = moment(notificationTime, "h:mm A");
      const timeDiffMinutes = Math.abs(
        currentMoment.diff(notificationMoment, "minutes")
      );

      if (timeDiffMinutes > 5) {
        return;
      }

      const tomorrow = moment().add(1, "day").startOf("day").toDate();

      const existingNotification = await Notification.findOne({
        type: "appointment_reminder",
        sentAt: { $gte: moment().subtract(1, "week").toDate() },
      });

      if (existingNotification) {
        console.log("Appointment reminder already sent today");
        return;
      }

      const appointments = await Appointment.find({
        date: tomorrow,
        status: "Accepted",
      })
        .populate("childId")
        .populate("doctorId", "firstName lastName")
        .populate("userId", "firstName lastName");

      for (const appointment of appointments) {
        const userId = appointment.userId;
        const childId = appointment.childId._id;
        const childName = appointment.childId.name;
        const doctorId = appointment.doctorId._id;

        await sendNotificationCore(
          userId,
          childId,
          doctorId,
          `Appointment Reminder for ${childName}`,
          `Reminder: You have an appointment for ${childName} with Dr. ${appointment.doctorId.firstName} ${appointment.doctorId.lastName} tomorrow at ${appointment.time}.`,
          "appointment_reminder",
          "patient"
        );

        if (doctorId) {
          await sendNotificationCore(
            doctorId,
            childId,
            userId,
            `Appointment Reminder for ${childName}`,
            `Reminder: You have an appointment with ${childName} tomorrow at ${appointment.time}.`,
            "appointment_reminder",
            "doctor"
          );
        }
      }
    } catch (error) {
      console.error("Error in appointment reminder cron job:", error);
    }
  });

  // تنظيف الإشعارات القديمة (كل يوم في منتصف الليل)
  cron.schedule("0 0 * * *", async () => {
    const oneMonthAgo = moment().subtract(1, "month").toDate();
    await Notification.deleteMany({ createdAt: { $lt: oneMonthAgo } });
    console.log("Old notifications deleted (older than 1 month)");
  });
};

module.exports = scheduleNotifications;