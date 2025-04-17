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
//   );

// router.post(
//   "/logout",
//   verifyToken,
//   allowedTo(userRoles.ADMIN, userRoles.DOCTOR),
//   doctorController.logoutDoctor
// );

// // Route لجلب الحجوزات القادمة (ثابت)
// router.get(
//   "/appointments/upcoming",
//   verifyToken,
//   allowedTo(userRoles.ADMIN, userRoles.DOCTOR),
//   doctorController.getUpcomingAppointments
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

// // Route لعرض كل الدكاترة مع childId في الـ Path (ديناميكي، لازم يكون الأخير)
// router.get(
//   "/:childId",
//   verifyToken,
//   allowedTo(userRoles.ADMIN, userRoles.DOCTOR, userRoles.PATIENT),
//   doctorController.getAllDoctors
// );

// // Routes لتفاصيل دكتور معين مع childId في الـ Path
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

// Routes للدكتور نفسه (Profile, Logout) - مش محتاج childId
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
  );

router.post(
  "/logout",
  verifyToken,
  allowedTo(userRoles.ADMIN, userRoles.DOCTOR),
  doctorController.logoutDoctor
);

// Route لجلب الحجوزات القادمة (ثابت)
router.get(
  "/appointments/upcoming",
  verifyToken,
  allowedTo(userRoles.ADMIN, userRoles.DOCTOR),
  doctorController.getUpcomingAppointments
);

// Route لجلب السجل الطبي وبيانات النمو بتاعة الطفل (ثابت، لازم يكون قبل الـ Routes الديناميكية)
router.post(
  "/child/records",
  verifyToken,
  allowedTo(userRoles.ADMIN, userRoles.DOCTOR),
  doctorController.getChildRecords
);

// Route لتحديث حالة الحجز (يحتوي على appointmentId)
router.patch(
  "/appointments/:appointmentId/status",
  verifyToken,
  allowedTo(userRoles.ADMIN, userRoles.DOCTOR),
  doctorController.updateAppointmentStatus
);

// Route لجلب كل الحجوزات بتاعة اليوزر مع childId في الـ Path
router.get(
  "/appointments/user/:childId",
  verifyToken,
  allowedTo(userRoles.ADMIN, userRoles.PATIENT),
  doctorController.getUserAppointments
);

// Route لجلب الدكاترة المفضلين مع childId في الـ Path (ثابت، لازم يكون قبل /:childId)
router.get(
  "/favorites/:childId",
  verifyToken,
  allowedTo(userRoles.ADMIN, userRoles.PATIENT),
  doctorController.getFavoriteDoctors
);

// Route لعرض كل الدكاترة مع childId في الـ Path (ديناميكي)
router.get(
  "/:childId",
  verifyToken,
  allowedTo(userRoles.ADMIN, userRoles.DOCTOR, userRoles.PATIENT),
  doctorController.getAllDoctors
);

// Routes لتفاصيل دكتور معين مع childId في الـ Path (ديناميكي)
router
  .route("/:childId/:doctorId")
  .get(
    verifyToken,
    allowedTo(userRoles.ADMIN, userRoles.DOCTOR, userRoles.PATIENT),
    doctorController.getSingleDoctor
  );

// Route لحجز موعد مع childId في الـ Path
router.post(
  "/:childId/:doctorId/book",
  verifyToken,
  allowedTo(userRoles.ADMIN, userRoles.PATIENT),
  doctorController.bookAppointment
);

// Routes لإضافة وإزالة دكتور من المفضلة مع childId في الـ Path
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

// Routes لتعديل وإلغاء الحجز مع childId في الـ Path
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
    doctorController.deleteAppointment
  );

module.exports = router;