// const express = require("express");
// const router = express.Router();
// const verifyToken = require("../middlewares/virifyToken");
// const allowedTo = require("../middlewares/allowedTo");
// const userRoles = require("../utils/userRoles");
// const doctorController = require("../controllers/doctor.controller");
// const Notification = require("../models/notification.model");
// const appError = require("../utils/appError");
// const { sendNotification } = require("../controllers/notifications.controller");

// // Routes للدكتور نفسه (Profile, Logout)
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

// // Route لتعديل الأيام والأوقات المتاحة
// router.patch(
//   "/availability",
//   verifyToken,
//   allowedTo(userRoles.ADMIN, userRoles.DOCTOR),
//   doctorController.updateAvailability
// );

// // Route لجلب الحجوزات القادمة
// router.get(
//   "/appointments/upcoming",
//   verifyToken,
//   allowedTo(userRoles.ADMIN, userRoles.DOCTOR),
//   doctorController.getUpcomingAppointments
// );

// // Route لجلب السجل الطبي وبيانات النمو بتاعة الطفل
// router.post(
//   "/child/records",
//   verifyToken,
//   allowedTo(userRoles.ADMIN, userRoles.DOCTOR),
//   doctorController.getChildRecords
// );

// // Route لتحديث حالة الحجز
// router.patch(
//   "/appointments/:appointmentId/status",
//   verifyToken,
//   allowedTo(userRoles.ADMIN, userRoles.DOCTOR),
//   doctorController.updateAppointmentStatus
// );

// // Route لجلب كل الحجوزات بتاعة اليوزر مع childId
// router.get(
//   "/appointments/user/:childId",
//   verifyToken,
//   allowedTo(userRoles.ADMIN, userRoles.PATIENT),
//   doctorController.getUserAppointments
// );

// // Route لجلب الدكاترة المفضلين مع childId
// router.get(
//   "/favorites/:childId",
//   verifyToken,
//   allowedTo(userRoles.ADMIN, userRoles.PATIENT),
//   doctorController.getFavoriteDoctors
// );

// // Route لعرض كل الدكاترة مع childId
// router.get(
//   "/:childId",
//   verifyToken,
//   allowedTo(userRoles.ADMIN, userRoles.DOCTOR, userRoles.PATIENT),
//   doctorController.getAllDoctors
// );

// // Routes لتفاصيل دكتور معين مع childId
// router
//   .route("/:childId/:doctorId")
//   .get(
//     verifyToken,
//     allowedTo(userRoles.ADMIN, userRoles.DOCTOR, userRoles.PATIENT),
//     doctorController.getSingleDoctor
//   );

// // Route لحجز موعد مع childId
// router.post(
//   "/:childId/:doctorId/book",
//   verifyToken,
//   allowedTo(userRoles.ADMIN, userRoles.PATIENT),
//   doctorController.bookAppointment
// );

// // Route لإضافة/إزالة دكتور من المفضلة باستخدام toggleFavoriteDoctor
// router.patch(
//   "/:childId/:doctorId/favorite",
//   verifyToken,
//   allowedTo(userRoles.ADMIN, userRoles.PATIENT),
//   doctorController.toggleFavoriteDoctor
// );

// // Routes لتعديل وإلغاء الحجز
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
//     doctorController.cancelAppointment
//   );

// // نقطة نهاية لحفظ FCM Token
// router.post(
//   "/save-fcm-token",
//   verifyToken,
//   allowedTo(userRoles.DOCTOR),
//   doctorController.saveFcmToken
// );

// module.exports = router;
  
const express = require("express");
const router = express.Router();
const verifyToken = require("../middlewares/virifyToken");
const allowedTo = require("../middlewares/allowedTo");
const userRoles = require("../utils/userRoles");
const doctorController = require("../controllers/doctor.controller");
const upload = require("../utils/multer.config"); // استيراد Multer المركزي

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
    (req, res, next) => {
      req.modelName = "doctor"; // إضافة اسم الموديل
      next();
    },
    upload.single("avatar"), // إضافة Multer لرفع الصورة عند التحديث
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

router.patch(
  "/availability",
  verifyToken,
  allowedTo(userRoles.ADMIN, userRoles.DOCTOR),
  doctorController.updateAvailability
);

router.get(
  "/appointments/upcoming",
  verifyToken,
  allowedTo(userRoles.ADMIN, userRoles.DOCTOR),
  doctorController.getUpcomingAppointments
);

router.post(
  "/child/records",
  verifyToken,
  allowedTo(userRoles.ADMIN, userRoles.DOCTOR),
  doctorController.getChildRecords
);

router.patch(
  "/appointments/:appointmentId/status",
  verifyToken,
  allowedTo(userRoles.ADMIN, userRoles.DOCTOR),
  doctorController.updateAppointmentStatus
);

router.get(
  "/appointments/user/:childId",
  verifyToken,
  allowedTo(userRoles.ADMIN, userRoles.PATIENT),
  doctorController.getUserAppointments
);

router.get(
  "/favorites/:childId",
  verifyToken,
  allowedTo(userRoles.ADMIN, userRoles.PATIENT),
  doctorController.getFavoriteDoctors
);

router.get(
  "/:childId",
  verifyToken,
  allowedTo(userRoles.ADMIN, userRoles.DOCTOR, userRoles.PATIENT),
  doctorController.getAllDoctors
);

router
  .route("/:childId/:doctorId")
  .get(
    verifyToken,
    allowedTo(userRoles.ADMIN, userRoles.DOCTOR, userRoles.PATIENT),
    doctorController.getSingleDoctor
  );

router.post(
  "/:childId/:doctorId/book",
  verifyToken,
  allowedTo(userRoles.ADMIN, userRoles.PATIENT),
  doctorController.bookAppointment
);

router.patch(
  "/:childId/:doctorId/favorite",
  verifyToken,
  allowedTo(userRoles.ADMIN, userRoles.PATIENT),
  doctorController.toggleFavoriteDoctor
);

router
  .route("/appointments/:childId/:appointmentId")
  .patch(
    verifyToken,
    allowedTo(userRoles.ADMIN, userRoles.PATIENT),
    doctorController.rescheduleAppointment
  )
  .delete(
    verifyToken,
    allowedTo(userRoles.ADMIN, userRoles.PATIENT),
    doctorController.cancelAppointment
  );

router.post(
  "/save-fcm-token",
  verifyToken,
  allowedTo(userRoles.DOCTOR),
  doctorController.saveFcmToken
);

module.exports = router;