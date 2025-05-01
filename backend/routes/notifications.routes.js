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

// نقطة نهاية لإرسال إشعارات الـ Bracelet
router.post(
  "/bracelet",
  verifyToken,
  allowedTo(userRoles.PATIENT),
  async (req, res, next) => {
    const { childId, title, body } = req.body;
    const userId = req.user.id;

    if (!childId || !title || !body) {
      return res.status(400).json({
        status: "fail",
        message: "childId, title, and body are required",
      });
    }

    try {
      await notificationsController.sendNotification(
        userId,
        childId,
        null,
        title,
        body,
        "bracelet",
        "patient"
      );

      res.status(201).json({
        status: "success",
        message: "Bracelet notification sent successfully",
      });
    } catch (error) {
      console.error("Error sending bracelet notification:", error);
      res.status(500).json({
        status: "error",
        message: "Failed to send bracelet notification",
      });
    }
  }
);

// نقطة نهاية لإرسال إشعارات عامة (للأدمن فقط)
router.post(
  "/send-general",
  verifyToken,
  allowedTo(userRoles.ADMIN),
  async (req, res, next) => {
    const { title, body, target } = req.body;

    if (!title || !body || !target) {
      return res.status(400).json({
        status: "fail",
        message: "Title, body, and target are required",
      });
    }

    try {
      let fcmTokens = [];
      let notifications = [];

      if (target === "patient" || target === "all") {
        const users = await User.find().select("fcmToken _id");
        fcmTokens.push(
          ...users.map((user) => user.fcmToken).filter((token) => token)
        );
        notifications.push(
          ...users.map((user) => ({
            userId: user._id,
            title,
            body,
            type: "general",
            target: "patient",
            isRead: false,
          }))
        );
      }

      if (target === "doctor" || target === "all") {
        const doctors = await Doctor.find().select("fcmToken _id");
        fcmTokens.push(
          ...doctors.map((doctor) => doctor.fcmToken).filter((token) => token)
        );
        notifications.push(
          ...doctors.map((doctor) => ({
            doctorId: doctor._id,
            title,
            body,
            type: "general",
            target: "doctor",
            isRead: false,
          }))
        );
      }

      if (fcmTokens.length === 0) {
        return res.status(404).json({
          status: "fail",
          message: "No recipients found with FCM tokens",
        });
      }

      for (const notification of notifications) {
        await notificationsController.sendNotification(
          notification.userId || null,
          null,
          notification.doctorId || null,
          notification.title,
          notification.body,
          notification.type,
          notification.target
        );
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
