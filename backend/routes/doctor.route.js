const express = require("express");
const router = express.Router();
const doctorController = require("../controllers/doctor.controller");
const verifyToken = require("../middlewares/virifyToken");
const allowedTo = require("../middlewares/allowedTo");
const userRoles = require("../utils/userRoles");

// Route لجلب الـ Profile بتاع الدكتور (نحطه الأول عشان يتفحص قبل /:doctorId)
router.get(
  "/profile",
  verifyToken,
  allowedTo(userRoles.ADMIN, userRoles.DOCTOR),
  doctorController.getDoctorProfile
);

// Route لتعديل الـ Profile بتاع الدكتور
router.patch(
  "/profile",
  verifyToken,
  allowedTo(userRoles.ADMIN, userRoles.DOCTOR),
  doctorController.updateDoctorProfile
);

// باقي الـ Routes
router.get(
  "/",
  verifyToken,
  allowedTo(userRoles.ADMIN, userRoles.DOCTOR, userRoles.PATIENT),
  doctorController.getAllDoctors
);

// Route لجلب تفاصيل دكتور معين (نحطه بعد /profile عشان ما يتعارضش)
router.get(
  "/:doctorId",
  verifyToken,
  allowedTo(userRoles.ADMIN, userRoles.DOCTOR, userRoles.PATIENT),
  doctorController.getSingleDoctor
);

router.post(
  "/:doctorId/book",
  verifyToken,
  allowedTo(userRoles.ADMIN, userRoles.PATIENT),
  doctorController.bookAppointment
);

router.get(
  "/appointments/user",
  verifyToken,
  allowedTo(userRoles.ADMIN, userRoles.PATIENT),
  doctorController.getUserAppointments
);

router.patch(
  "/appointments/:appointmentId/status",
  verifyToken,
  doctorController.updateAppointmentStatus
);

router.patch(
  "/appointments/:appointmentId/reschedule",
  verifyToken,
  allowedTo(userRoles.ADMIN, userRoles.PATIENT),
  doctorController.rescheduleAppointment
);

router.delete(
  "/appointments/:appointmentId",
  verifyToken,
  allowedTo(userRoles.ADMIN, userRoles.PATIENT),
  doctorController.deleteAppointment
);

router.get(
  "/appointments/upcoming",
  verifyToken,
  doctorController.getUpcomingAppointments
);

router.post(
  "/logout",
  verifyToken,
  allowedTo(userRoles.ADMIN, userRoles.DOCTOR),
  doctorController.logoutDoctor
);

router.post("/:doctorId/favorite", verifyToken, doctorController.addToFavorite);

router.delete(
  "/:doctorId/favorite",
  verifyToken,
  allowedTo(userRoles.ADMIN, userRoles.PATIENT),
  doctorController.removeFromFavorite
);

module.exports = router;
