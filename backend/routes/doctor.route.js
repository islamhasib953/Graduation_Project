// const express = require("express");
// const router = express.Router();

// const verifyToken = require("../middlewares/virifyToken");
// const allowedTo = require("../middlewares/allowedTo");
// const userRoles = require("../utils/userRoles");
// const doctorController = require("../controllers/doctor.controller");

// // Routes للدكتور نفسه (Profile, Logout) - مش محتاج childId
// router
//   .route("/profile")
//   .get(
//     verifyToken,
//     allowedTo(userRoles.ADMIN, userRoles.DOCTOR),
//     doctorController.getDoctorProfile
//   )
//   .patch(
//     verifyToken,
//     allowedTo(userRoles.ADMIN, userRoles.DOCTOR),
//     doctorController.updateDoctorProfile
//   )
//   .delete(
//     verifyToken,
//     allowedTo(userRoles.ADMIN, userRoles.DOCTOR),
//     doctorController.deleteDoctorProfile
//   );

// router.post(
//   "/logout",
//   verifyToken,
//   allowedTo(userRoles.ADMIN, userRoles.DOCTOR),
//   doctorController.logoutDoctor
// );

// // Route لتعديل الأيام والأوقات المتاحة (جديد)
// router.patch(
//   "/availability",
//   verifyToken,
//   allowedTo(userRoles.ADMIN, userRoles.DOCTOR),
//   doctorController.updateAvailability
// );

// // Route لجلب الحجوزات القادمة (ثابت)
// router.get(
//   "/appointments/upcoming",
//   verifyToken,
//   allowedTo(userRoles.ADMIN, userRoles.DOCTOR),
//   doctorController.getUpcomingAppointments
// );

// // Route لجلب السجل الطبي وبيانات النمو بتاعة الطفل (ثابت، لازم يكون قبل الـ Routes الديناميكية)
// router.post(
//   "/child/records",
//   verifyToken,
//   allowedTo(userRoles.ADMIN, userRoles.DOCTOR),
//   doctorController.getChildRecords
// );

// // Route لتحديث حالة الحجز (يحتوي على appointmentId)
// router.patch(
//   "/appointments/:appointmentId/status",
//   verifyToken,
//   allowedTo(userRoles.ADMIN, userRoles.DOCTOR),
//   doctorController.updateAppointmentStatus
// );

// // Route لجلب كل الحجوزات بتاعة اليوزر مع childId في الـ Path
// router.get(
//   "/appointments/user/:childId",
//   verifyToken,
//   allowedTo(userRoles.ADMIN, userRoles.PATIENT),
//   doctorController.getUserAppointments
// );

// // Route لجلب الدكاترة المفضلين مع childId في الـ Path (ثابت، لازم يكون قبل /:childId)
// router.get(
//   "/favorites/:childId",
//   verifyToken,
//   allowedTo(userRoles.ADMIN, userRoles.PATIENT),
//   doctorController.getFavoriteDoctors
// );

// // Route لعرض كل الدكاترة مع childId في الـ Path (ديناميكي)
// router.get(
//   "/:childId",
//   verifyToken,
//   allowedTo(userRoles.ADMIN, userRoles.DOCTOR, userRoles.PATIENT),
//   doctorController.getAllDoctors
// );

// // Routes لتفاصيل دكتور معين مع childId في الـ Path (ديناميكي)
// router
//   .route("/:childId/:doctorId")
//   .get(
//     verifyToken,
//     allowedTo(userRoles.ADMIN, userRoles.DOCTOR, userRoles.PATIENT),
//     doctorController.getSingleDoctor
//   );

// // Route لحجز موعد مع childId في الـ Path
// router.post(
//   "/:childId/:doctorId/book",
//   verifyToken,
//   allowedTo(userRoles.ADMIN, userRoles.PATIENT),
//   doctorController.bookAppointment
// );

// // Routes لإضافة وإزالة دكتور من المفضلة مع childId في الـ Path
// router
//   .route("/:childId/:doctorId/favorite")
//   .post(
//     verifyToken,
//     allowedTo(userRoles.ADMIN, userRoles.PATIENT),
//     doctorController.addToFavorite
//   )
//   .delete(
//     verifyToken,
//     allowedTo(userRoles.ADMIN, userRoles.PATIENT),
//     doctorController.removeFromFavorite
//   );

// // Routes لتعديل وإلغاء الحجز مع childId في الـ Path
// router
//   .route("/appointments/:childId/:appointmentId")
//   .patch(
//     verifyToken,
//     allowedTo(userRoles.ADMIN, userRoles.PATIENT),
//     doctorController.rescheduleAppointment
//   )
//   .delete(
//     verifyToken,
//     allowedTo(userRoles.ADMIN, userRoles.PATIENT),
//     doctorController.deleteAppointment
//   );

// module.exports = router;

const express = require("express");
const router = express.Router();
const verifyToken = require("../middlewares/virifyToken");
const allowedTo = require("../middlewares/allowedTo");
const userRoles = require("../utils/userRoles");
const doctorController = require("../controllers/doctor.controller");
const Notification = require("../models/notification.model");
const appError = require("../utils/appError");
const { sendNotification } = require("../controllers/notifications.controller");

// Routes للدكتور نفسه (Profile, Logout)
router
  .route("/profile")
  .get(
    verifyToken,
    allowedTo(userRoles.ADMIN, userRoles.DOCTOR),
    doctorController.getDoctorProfile
  )
  .patch(
    verifyToken,
    allowedTo(userRoles.ADMIN, userRoles.DOCTOR),
    doctorController.updateDoctorProfile
  )
  .delete(
    verifyToken,
    allowedTo(userRoles.ADMIN, userRoles.DOCTOR),
    doctorController.deleteDoctorProfile
  );

router.post(
  "/logout",
  verifyToken,
  allowedTo(userRoles.ADMIN, userRoles.DOCTOR),
  doctorController.logoutDoctor
);

// Route لتعديل الأيام والأوقات المتاحة
router.patch(
  "/availability",
  verifyToken,
  allowedTo(userRoles.ADMIN, userRoles.DOCTOR),
  doctorController.updateAvailability
);

// Route لجلب الحجوزات القادمة
router.get(
  "/appointments/upcoming",
  verifyToken,
  allowedTo(userRoles.ADMIN, userRoles.DOCTOR),
  doctorController.getUpcomingAppointments
);

// Route لجلب السجل الطبي وبيانات النمو بتاعة الطفل
router.post(
  "/child/records",
  verifyToken,
  allowedTo(userRoles.ADMIN, userRoles.DOCTOR),
  doctorController.getChildRecords
);

// Route لتحديث حالة الحجز
router.patch(
  "/appointments/:appointmentId/status",
  verifyToken,
  allowedTo(userRoles.ADMIN, userRoles.DOCTOR),
  doctorController.updateAppointmentStatus
);

// Route لجلب كل الحجوزات بتاعة اليوزر مع childId
router.get(
  "/appointments/user/:childId",
  verifyToken,
  allowedTo(userRoles.ADMIN, userRoles.PATIENT),
  doctorController.getUserAppointments
);

// Route لجلب الدكاترة المفضلين مع childId
router.get(
  "/favorites/:childId",
  verifyToken,
  allowedTo(userRoles.ADMIN, userRoles.PATIENT),
  doctorController.getFavoriteDoctors
);

// Route لعرض كل الدكاترة مع childId
router.get(
  "/:childId",
  verifyToken,
  allowedTo(userRoles.ADMIN, userRoles.DOCTOR, userRoles.PATIENT),
  doctorController.getAllDoctors
);

// Routes لتفاصيل دكتور معين مع childId
router
  .route("/:childId/:doctorId")
  .get(
    verifyToken,
    allowedTo(userRoles.ADMIN, userRoles.DOCTOR, userRoles.PATIENT),
    doctorController.getSingleDoctor
  );

// Route لحجز موعد مع childId
router.post(
  "/:childId/:doctorId/book",
  verifyToken,
  allowedTo(userRoles.ADMIN, userRoles.PATIENT),
  async (req, res, next) => {
    try {
      const { childId, doctorId } = req.params;
      const { date, time } = req.body;
      const userId = req.user.id;

      const appointment = await require("../models/appointment.model").create({
        userId,
        childId,
        doctorId,
        date: new Date(date),
        time,
        status: "Pending",
      });

      // إشعار لليوزر
      await sendNotification(
        userId,
        childId,
        doctorId,
        "New Appointment Scheduled",
        `You have scheduled an appointment with Dr. on ${new Date(
          date
        ).toLocaleDateString()} at ${time}.`,
        "appointment",
        "user"
      );

      // إشعار للدكتور
      await sendNotification(
        null,
        childId,
        doctorId,
        "New Appointment Scheduled",
        `A new appointment has been scheduled with a patient on ${new Date(
          date
        ).toLocaleDateString()} at ${time}.`,
        "appointment",
        "doctor"
      );

      res.status(201).json({
        status: "success",
        message: "Appointment booked successfully",
        data: appointment,
      });
    } catch (error) {
      console.error("Error booking appointment:", error);
      return next(appError.create("Failed to book appointment", 500, "error"));
    }
  }
);

// Routes لإضافة وإزالة دكتور من المفضلة
router
  .route("/:childId/:doctorId/favorite")
  .post(
    verifyToken,
    allowedTo(userRoles.ADMIN, userRoles.PATIENT),
    doctorController.addToFavorite
  )
  .delete(
    verifyToken,
    allowedTo(userRoles.ADMIN, userRoles.PATIENT),
    doctorController.removeFromFavorite
  );

// Routes لتعديل وإلغاء الحجز
router
  .route("/appointments/:childId/:appointmentId")
  .patch(
    verifyToken,
    allowedTo(userRoles.ADMIN, userRoles.PATIENT),
    async (req, res, next) => {
      try {
        const { childId, appointmentId } = req.params;
        const { date, time } = req.body;
        const userId = req.user.id;

        const appointment =
          await require("../models/appointment.model").findOneAndUpdate(
            { _id: appointmentId, childId, userId },
            { date: new Date(date), time, status: "Pending" },
            { new: true }
          );

        if (!appointment) {
          return next(appError.create("Appointment not found", 404, "fail"));
        }

        // إشعار لليوزر
        await sendNotification(
          userId,
          childId,
          appointment.doctorId,
          "Appointment Rescheduled",
          `Your appointment for your child has been rescheduled to ${new Date(
            date
          ).toLocaleDateString()} at ${time}.`,
          "appointment",
          "user"
        );

        // إشعار للدكتور
        await sendNotification(
          null,
          childId,
          appointment.doctorId,
          "Appointment Rescheduled",
          `An appointment with a patient has been rescheduled to ${new Date(
            date
          ).toLocaleDateString()} at ${time}.`,
          "appointment",
          "doctor"
        );

        res.status(200).json({
          status: "success",
          message: "Appointment rescheduled successfully",
          data: appointment,
        });
      } catch (error) {
        console.error("Error rescheduling appointment:", error);
        return next(
          appError.create("Failed to reschedule appointment", 500, "error")
        );
      }
    }
  )
  .delete(
    verifyToken,
    allowedTo(userRoles.ADMIN, userRoles.PATIENT),
    async (req, res, next) => {
      try {
        const { childId, appointmentId } = req.params;
        const userId = req.user.id;

        const appointment =
          await require("../models/appointment.model").findOneAndDelete({
            _id: appointmentId,
            childId,
            userId,
          });

        if (!appointment) {
          return next(appError.create("Appointment not found", 404, "fail"));
        }

        // إشعار لليوزر
        await sendNotification(
          userId,
          childId,
          appointment.doctorId,
          "Appointment Cancelled",
          `Your appointment for your child has been cancelled.`,
          "appointment",
          "user"
        );

        // إشعار للدكتور
        await sendNotification(
          null,
          childId,
          appointment.doctorId,
          "Appointment Cancelled",
          `An appointment with a patient has been cancelled.`,
          "appointment",
          "doctor"
        );

        res.status(200).json({
          status: "success",
          message: "Appointment cancelled successfully",
        });
      } catch (error) {
        console.error("Error cancelling appointment:", error);
        return next(
          appError.create("Failed to cancel appointment", 500, "error")
        );
      }
    }
  );

// نقطة نهاية لحفظ FCM Token
router.post(
  "/save-fcm-token",
  verifyToken,
  allowedTo(userRoles.DOCTOR),
  async (req, res, next) => {
    const { fcmToken } = req.body;
    const doctorId = req.user.id;

    if (!fcmToken) {
      return next(appError.create("FCM Token is required", 400, "fail"));
    }

    try {
      const doctor = await require("../models/doctor.model").findByIdAndUpdate(
        doctorId,
        { fcmToken },
        { new: true }
      );
      if (!doctor) {
        return next(appError.create("Doctor not found", 404, "fail"));
      }
      res.status(200).json({
        status: "success",
        message: "FCM Token saved successfully",
      });
    } catch (error) {
      console.error("Error saving FCM Token:", error);
      return next(appError.create("Server error", 500, "error"));
    }
  }
);

module.exports = router;