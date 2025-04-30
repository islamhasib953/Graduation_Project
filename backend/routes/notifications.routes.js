const express = require("express");
const router = express.Router();
const verifyToken = require("../middlewares/virifyToken");
const allowedTo = require("../middlewares/allowedTo");
const userRoles = require("../utils/userRoles");
const notificationsController = require("../controllers/notifications.controller");
const User = require("../models/user.model");
const Doctor = require("../models/doctor.model");
const { sendPushNotification } = require("../config/firebase-config");

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

// نقطة نهاية لإرسال إشعارات عامة (للأدمن فقط)
router.post(
  "/send-general",
  verifyToken,
  allowedTo(userRoles.ADMIN),
  async (req, res, next) => {
    const { title, body, target } = req.body; // target: "users", "doctors", or "all"

    if (!title || !body || !target) {
      return res.status(400).json({
        status: "fail",
        message: "Title, body, and target are required",
      });
    }

    try {
      let fcmTokens = [];

      if (target === "users" || target === "all") {
        const users = await User.find().select("fcmToken");
        fcmTokens.push(
          ...users.map((user) => user.fcmToken).filter((token) => token)
        );
      }

      if (target === "doctors" || target === "all") {
        const doctors = await Doctor.find().select("fcmToken");
        fcmTokens.push(
          ...doctors.map((doctor) => doctor.fcmToken).filter((token) => token)
        );
      }

      if (fcmTokens.length === 0) {
        return res.status(404).json({
          status: "fail",
          message: "No recipients found with FCM tokens",
        });
      }

      // إرسال الإشعار لكل المستلمين
      for (const token of fcmTokens) {
        await sendPushNotification(token, title, body, { type: "general" });
      }

      res.status(200).json({
        status: "success",
        message: "General notification sent successfully",
      });
    } catch (error) {
      console.error("Error sending general notification:", error);
      res.status(500).json({
        status: "error",
        message: "Failed to send general notification",
      });
    }
  }
);

module.exports = router;
