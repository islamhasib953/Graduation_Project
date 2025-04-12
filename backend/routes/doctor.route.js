const express = require("express");
const router = express.Router();
const doctorController = require("../controllers/doctor.controller");
const verifyToken = require("../middlewares/virifyToken");

// هنضيف verifyToken لكل الـ Routes في الخطوة التانية
router.get("/", verifyToken, doctorController.getAllDoctors);
router.get("/:doctorId", verifyToken, doctorController.getSingleDoctor);
router.post("/:doctorId/book", verifyToken, doctorController.bookAppointment);
router.get(
  "/appointments/user",
  verifyToken,
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
  doctorController.rescheduleAppointment
);
router.delete(
  "/appointments/:appointmentId",
  verifyToken,
  doctorController.deleteAppointment
);
router.get(
  "/appointments/upcoming",
  verifyToken,
  doctorController.getUpcomingAppointments
);
router.get("/profile", verifyToken, doctorController.getDoctorProfile);
router.patch("/profile", verifyToken, doctorController.updateDoctorProfile);
router.post("/logout", verifyToken, doctorController.logoutDoctor);
router.post("/:doctorId/favorite", verifyToken, doctorController.addToFavorite);
router.delete(
  "/:doctorId/favorite",
  verifyToken,
  doctorController.removeFromFavorite
);

module.exports = router;
