// const asyncWrapper = require("../middlewares/asyncWrapper");
// const Notification = require("../models/notification.model");
// const User = require("../models/user.model");
// const Doctor = require("../models/doctor.model");
// const Child = require("../models/child.model");
// const httpStatusText = require("../utils/httpStatusText");
// const appError = require("../utils/appError");
// const { sendPushNotification } = require("../config/firebase-config");

// const getUserNotifications = asyncWrapper(async (req, res, next) => {
//   const { childId } = req.params;
//   const userId = req.user.id;

//   const child = await Child.findOne({ _id: childId, parentId: userId });
//   if (!child) {
//     return next(
//       appError.create(
//         "Child not found or unauthorized",
//         404,
//         httpStatusText.FAIL
//       )
//     );
//   }

//   const notifications = await Notification.find({ userId, childId }).sort({
//     createdAt: -1,
//   });
//   res.status(200).json({ status: httpStatusText.SUCCESS, data: notifications });
// });

// const getDoctorNotifications = asyncWrapper(async (req, res, next) => {
//   const doctorId = req.user.id;

//   const notifications = await Notification.find({ doctorId }).sort({
//     createdAt: -1,
//   });
//   res.status(200).json({ status: httpStatusText.SUCCESS, data: notifications });
// });

// const markAsRead = asyncWrapper(async (req, res, next) => {
//   const { notificationId } = req.params;

//   const notification = await Notification.findById(notificationId);
//   if (!notification) {
//     return next(
//       appError.create("Notification not found", 404, httpStatusText.FAIL)
//     );
//   }

//   if (
//     (notification.userId && notification.userId.toString() !== req.user.id) ||
//     (notification.doctorId && notification.doctorId.toString() !== req.user.id)
//   ) {
//     return next(
//       appError.create(
//         "Unauthorized to mark this notification as read",
//         403,
//         httpStatusText.FAIL
//       )
//     );
//   }

//   notification.isRead = true;
//   await notification.save();

//   res
//     .status(200)
//     .json({
//       status: httpStatusText.SUCCESS,
//       message: "Notification marked as read",
//     });
// });

// const sendNotification = asyncWrapper(
//   async (userId, childId, doctorId, title, body, type, target) => {
//     let fcmToken = null;
//     let recipient = null;

//     if (target === "patient" && userId) {
//       recipient = await User.findById(userId).select("fcmToken");
//       fcmToken = recipient?.fcmToken;
//     } else if (target === "doctor" && doctorId) {
//       recipient = await Doctor.findById(doctorId).select("fcmToken");
//       fcmToken = recipient?.fcmToken;
//     }

//     const notificationData = {
//       userId: userId || null,
//       childId: childId || null,
//       doctorId: doctorId || null,
//       title,
//       body,
//       type,
//       target,
//       isRead: false,
//       status: "pending", // إضافة حقل الحالة
//     };

//     const notification = new Notification(notificationData);
//     await notification.save();

//     if (!fcmToken) {
//       console.warn(
//         `No FCM token found for ${target} (ID: ${userId || doctorId})`
//       );
//       notification.status = "failed";
//       await notification.save();
//       return;
//     }

//     try {
//       await sendPushNotification(fcmToken, title, body, {
//         type,
//         childId: childId?.toString() || "",
//       });
//       notification.status = "sent";
//       await notification.save();
//       console.log(
//         `Notification sent to ${target} (ID: ${userId || doctorId}): ${title}`
//       );
//     } catch (error) {
//       notification.status = "failed";
//       await notification.save();
//       console.error(
//         `Failed to send notification to ${target} (ID: ${userId || doctorId}):`,
//         error
//       );
//       throw error; // إرجاع الخطأ للتعامل معه في الدالة المستدعية
//     }
//   }
// );

// module.exports = {
//   getUserNotifications,
//   getDoctorNotifications,
//   markAsRead,
//   sendNotification,
// };


const asyncWrapper = require("../middlewares/asyncWrapper");
const Notification = require("../models/notification.model");
const User = require("../models/user.model");
const Doctor = require("../models/doctor.model");
const Child = require("../models/child.model");
const httpStatusText = require("../utils/httpStatusText");
const appError = require("../utils/appError");
const { sendPushNotification } = require("../config/firebase-config");

// الدالة الداخلية بدون asyncWrapper
const sendNotificationCore = async (
  userId,
  childId,
  doctorId,
  title,
  body,
  type,
  target
) => {
  let fcmToken = null;
  let recipient = null;

  if (target === "patient" && userId) {
    recipient = await User.findById(userId).select("fcmToken");
    fcmToken = recipient?.fcmToken;
  } else if (target === "doctor" && doctorId) {
    recipient = await Doctor.findById(doctorId).select("fcmToken");
    fcmToken = recipient?.fcmToken;
  }

  const notificationData = {
    userId: userId || null,
    childId: childId || null,
    doctorId: doctorId || null,
    title,
    body,
    type,
    target,
    isRead: false,
    status: "pending",
  };

  const notification = new Notification(notificationData);
  await notification.save();

  if (!fcmToken) {
    console.warn(
      `No FCM token found for ${target} (ID: ${userId || doctorId})`
    );
    notification.status = "failed";
    await notification.save();
    return;
  }

  try {
    await sendPushNotification(fcmToken, title, body, {
      type,
      childId: childId?.toString() || "",
    });
    notification.status = "sent";
    await notification.save();
    console.log(
      `Notification sent to ${target} (ID: ${userId || doctorId}): ${title}`
    );
  } catch (error) {
    notification.status = "failed";
    await notification.save();
    console.error(
      `Failed to send notification to ${target} (ID: ${userId || doctorId}):`,
      error
    );
    throw error;
  }
};

// الدالة الملفوفة للـ routes
const sendNotification = asyncWrapper(sendNotificationCore);

const getUserNotifications = asyncWrapper(async (req, res, next) => {
  const { childId } = req.params;
  const userId = req.user.id;

  const child = await Child.findOne({ _id: childId, parentId: userId });
  if (!child) {
    return next(
      appError.create(
        "Child not found or unauthorized",
        404,
        httpStatusText.FAIL
      )
    );
  }

  const notifications = await Notification.find({ userId, childId }).sort({
    createdAt: -1,
  });
  res.status(200).json({ status: httpStatusText.SUCCESS, data: notifications });
});

const getDoctorNotifications = asyncWrapper(async (req, res, next) => {
  const doctorId = req.user.id;

  const notifications = await Notification.find({ doctorId }).sort({
    createdAt: -1,
  });
  res.status(200).json({ status: httpStatusText.SUCCESS, data: notifications });
});

const markAsRead = asyncWrapper(async (req, res, next) => {
  const { notificationId } = req.params;

  const notification = await Notification.findById(notificationId);
  if (!notification) {
    return next(
      appError.create("Notification not found", 404, httpStatusText.FAIL)
    );
  }

  if (
    (notification.userId && notification.userId.toString() !== req.user.id) ||
    (notification.doctorId && notification.doctorId.toString() !== req.user.id)
  ) {
    return next(
      appError.create(
        "Unauthorized to mark this notification as read",
        403,
        httpStatusText.FAIL
      )
    );
  }

  notification.isRead = true;
  await notification.save();

  res.status(200).json({
    status: httpStatusText.SUCCESS,
    message: "Notification marked as read",
  });
});

module.exports = {
  getUserNotifications,
  getDoctorNotifications,
  markAsRead,
  sendNotification,
  sendNotificationCore, // تصدير الدالة الجديدة
};