const Notification = require("../models/notification.model");
const User = require("../models/user.model");
const Doctor = require("../models/doctor.model");
const Child = require("../models/child.model");
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
  type
) => {
  try {
    const user = await User.findById(userId);
    const child = await Child.findById(childId);
    const doctor = doctorId ? await Doctor.findById(doctorId) : null;

    if (!user || !child) {
      console.error("User or Child not found for notification");
      return;
    }

    const notification = new Notification({
      userId,
      childId,
      doctorId,
      title,
      body,
      type,
    });

    await notification.save();

    if (user.fcmToken) {
      await sendPushNotification(user.fcmToken, title, body, {
        childId: childId.toString(),
        type,
      });
    }

    if (doctor && doctor.fcmToken) {
      await sendPushNotification(doctor.fcmToken, title, body, {
        type: "doctor",
      });
    }
  } catch (error) {
    console.error("Error sending notification:", error);
  }
};

const getUserNotifications = asyncWrapper(async (req, res, next) => {
  const { childId } = req.params;
  const userId = req.user.id;

  const child = await Child.findOne({ _id: childId, parentId: userId });
  if (!child) {
    return next(
      appError.create(
        "Child not found or not associated with this user",
        404,
        httpStatusText.FAIL
      )
    );
  }

  const notifications = await Notification.find({ userId, childId })
    .sort({ createdAt: -1 })
    .limit(50);

  res.json({
    status: httpStatusText.SUCCESS,
    data: notifications,
  });
});

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

  const notifications = await Notification.find({ doctorId })
    .sort({ createdAt: -1 })
    .limit(50);

  res.json({
    status: httpStatusText.SUCCESS,
    data: notifications,
  });
});

const markAsRead = asyncWrapper(async (req, res, next) => {
  const { notificationId } = req.params;
  const userId = req.user.id;

  const notification = await Notification.findById(notificationId);
  if (!notification) {
    return next(
      appError.create("Notification not found", 404, httpStatusText.FAIL)
    );
  }

  if (
    notification.userId.toString() !== userId.toString() &&
    notification.doctorId?.toString() !== userId.toString()
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
  });
});

module.exports = {
  sendNotification,
  getUserNotifications,
  getDoctorNotifications,
  markAsRead,
};
