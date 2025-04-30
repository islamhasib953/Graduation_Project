const express = require("express");
const router = express.Router();
const verifyToken = require("../middlewares/virifyToken");
const allowedTo = require("../middlewares/allowedTo");
const userRoles = require("../utils/userRoles");
const notificationsController = require("../controllers/notifications.controller");

router.get(
  "/user/:childId",
  verifyToken,
  allowedTo(userRoles.PATIENT),
  notificationsController.getUserNotifications
);

router.get(
  "/doctor",
  verifyToken,
  allowedTo(userRoles.DOCTOR),
  notificationsController.getDoctorNotifications
);

router.patch(
  "/:notificationId/read",
  verifyToken,
  allowedTo(userRoles.PATIENT, userRoles.DOCTOR),
  notificationsController.markAsRead
);

module.exports = router;
