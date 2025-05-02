const Notification = require("../models/notification.model");
const User = require("../models/user.model");
const Doctor = require("../models/doctor.model");
const asyncWrapper = require("../middlewares/asyncWrapper");
const httpStatusText = require("../utils/httpStatusText");
const appError = require("../utils/appError");
const userRoles = require("../utils/userRoles");
const { sendPushNotification } = require("../config/firebase-config");

const sendNotification = async (
  userId,
  childId,
  doctorId,
  title,
  body,
  type,
  target
) => {
  try {
    let fcmToken = null;
    let recipientId = null;
    let role = null;

    if (userId && target === "patient") {
      const user = await User.findById(userId).select("fcmToken");
      if (user && user.fcmToken) {
        fcmToken = user.fcmToken;
        recipientId = userId;
        role = userRoles.PATIENT;
      }
    } else if (doctorId && target === "doctor") {
      const doctor = await Doctor.findById(doctorId).select("fcmToken");
      if (doctor && doctor.fcmToken) {
        fcmToken = doctor.fcmToken;
        recipientId = doctorId;
        role = userRoles.DOCTOR;
      }
    }

    if (!recipientId) {
      console.warn("No recipient found for notification");
      return;
    }

    // التحقق من وجود إشعار متكرر في آخر دقيقة
    const existingNotification = await Notification.findOne({
      userId: role === userRoles.PATIENT ? recipientId : null,
      doctorId: role === userRoles.DOCTOR ? recipientId : doctorId || null,
      childId: childId || null,
      title,
      body,
      type,
      target,
      createdAt: { $gte: new Date(Date.now() - 60 * 1000) },
    });

    if (existingNotification) {
      console.log("Notification already exists, skipping...");
      return;
    }

    const notification = new Notification({
      userId: role === userRoles.PATIENT ? recipientId : null,
      childId: childId || null,
      doctorId: role === userRoles.DOCTOR ? recipientId : doctorId || null,
      title,
      body,
      type,
      target,
      isRead: false,
    });

    await notification.save();
    console.log(`Notification stored: ${title} - ${body}`);

    if (fcmToken) {
      await sendPushNotification(fcmToken, title, body, {
        type,
        childId: childId ? childId.toString() : null,
        doctorId: doctorId ? doctorId.toString() : null,
        target,
      });
      console.log(`Push notification sent to ${target}: ${title}`);
    }
  } catch (error) {
    console.error("Error sending notification:", error);
  }
};

// جلب الإشعارات للمستخدم (الوالد)
const getUserNotifications = asyncWrapper(async (req, res, next) => {
  const userId = req.user.id;
  const { childId } = req.params;

  if (req.user.role !== userRoles.PATIENT) {
    return next(
      appError.create(
        "Unauthorized: Only patients can view their notifications",
        403,
        httpStatusText.FAIL
      )
    );
  }

  const notifications = await Notification.find({
    userId,
    childId,
    target: "patient",
  })
    .sort({ createdAt: -1 })
    .select("title body type target isRead createdAt");

  res.json({
    status: httpStatusText.SUCCESS,
    data: notifications,
  });
});

// جلب الإشعارات للدكتور
const getDoctorNotifications = asyncWrapper(async (req, res, next) => {
  const doctorId = req.user.id;

  if (req.user.role !== userRoles.DOCTOR) {
    return next(
      appError.create(
        "Unauthorized: Only doctors can view their notifications",
        403,
        httpStatusText.FAIL
      )
    );
  }

  const notifications = await Notification.find({
    doctorId,
    target: "doctor",
  })
    .sort({ createdAt: -1 })
    .select("title body type target isRead createdAt childId");

  res.json({
    status: httpStatusText.SUCCESS,
    data: notifications,
  });
});

const markAsRead = asyncWrapper(async (req, res, next) => {
  const { notificationId } = req.params;
  const userId = req.user.id;
  const role = req.user.role;

  const notification = await Notification.findById(notificationId);
  if (!notification) {
    return next(
      appError.create("Notification not found", 404, httpStatusText.FAIL)
    );
  }

  if (
    (role === userRoles.PATIENT &&
      notification.userId?.toString() !== userId.toString()) ||
    (role === userRoles.DOCTOR &&
      notification.doctorId?.toString() !== userId.toString())
  ) {
    return next(
      appError.create(
        "Unauthorized: You cannot mark this notification as read",
        403,
        httpStatusText.FAIL
      )
    );
  }

  notification.isRead = true;
  await notification.save();

  res.json({
    status: httpStatusText.SUCCESS,
    message: "Notification marked as read",
    data: {
      notificationId: notification._id,
      isRead: notification.isRead,
    },
  });
});

module.exports = {
  sendNotification,
  getUserNotifications,
  getDoctorNotifications,
  markAsRead,
};
