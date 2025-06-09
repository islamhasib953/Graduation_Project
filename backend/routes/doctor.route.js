const express = require("express");
const router = express.Router();
const verifyToken = require("../middlewares/virifyToken");
const allowedTo = require("../middlewares/allowedTo");
const userRoles = require("../utils/userRoles");
const doctorController = require("../controllers/doctor.controller");
const {
  uploadToS3,
  getFromS3,
  deleteFromS3,
} = require("../middlewares/s3Middleware");

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
    deleteFromS3, // مسح الصورة القديمة
    uploadToS3, // رفع الصورة الجديدة
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
