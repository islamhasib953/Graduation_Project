// // const express = require("express");
// // const usersController = require("../controllers/users.controller");
// // const verifyToken = require("../middlewares/virifyToken");
// // const allowedTo = require("../middlewares/allowedTo");
// // const userRoles = require("../utils/userRoles");
// // const checkOwnership = require("../middlewares/Ownership");
// // const {
// //   validateRegister,
// //   validateLogin,
// //   validateUpdateUser,
// // } = require("../middlewares/validationschema");

// // const multer = require("multer");
// // const appError = require("../utils/appError");
// // const fs = require("fs");
// // const path = require("path");

// // const diskStorage = multer.diskStorage({
// //   destination: (req, file, cb) => {
// //     const uploadPath = path.join(__dirname, "..", "Uploads");
// //     if (!fs.existsSync(uploadPath)) {
// //       fs.mkdirSync(uploadPath, { recursive: true });
// //     }
// //     cb(null, uploadPath);
// //   },
// //   filename: (req, file, cb) => {
// //     const ext = file.mimetype.split("/")[1];
// //     cb(null, `user-${Date.now()}.${ext}`);
// //   },
// // });

// // const fileFilter = (req, file, cb) => {
// //   file.mimetype.startsWith("image")
// //     ? cb(null, true)
// //     : cb(appError.create("The file must be an image", 400), false);
// // };

// // const upload = multer({ storage: diskStorage, fileFilter });

// // const router = express.Router();

// // router
// //   .route("/")
// //   .get(verifyToken, allowedTo(userRoles.ADMIN), usersController.getAllUsers);

// // router
// //   .route("/register")
// //   .post(
// //     upload.single("avatar"),
// //     validateRegister,
// //     usersController.registerUser
// //   );

// // router.route("/login").post(validateLogin, usersController.loginUser);

// // router
// //   .route("/profile")
// //   .get(
// //     verifyToken,
// //     allowedTo(userRoles.ADMIN, userRoles.PATIENT),
// //     usersController.getUserProfile
// //   )
// //   .patch(
// //     verifyToken,
// //     allowedTo(userRoles.ADMIN, userRoles.PATIENT),
// //     usersController.updateUserProfile
// //   )
// //   .delete(
// //     verifyToken,
// //     allowedTo(userRoles.ADMIN, userRoles.PATIENT),
// //     usersController.deleteUserProfile
// //   );

// // router.post(
// //   "/logout",
// //   verifyToken,
// //   allowedTo(userRoles.ADMIN, userRoles.PATIENT),
// //   usersController.logoutUser
// // );

// // // router
// // //   .route("/:userId")
// // //   .get(verifyToken, checkOwnership, usersController.getUserById)
// // //   .patch(
// // //     verifyToken,
// // //     checkOwnership,
// // //     validateUpdateUser,
// // //     usersController.updateUser
// // //   )
// // //   .delete(verifyToken, checkOwnership, usersController.deleteUser);


// /////////////////////////////////////////////////////////////////////////////////
// // module.exports = router;


// const express = require("express");
// const usersController = require("../controllers/users.controller");
// const verifyToken = require("../middlewares/virifyToken");
// const allowedTo = require("../middlewares/allowedTo");
// const userRoles = require("../utils/userRoles");
// const checkOwnership = require("../middlewares/Ownership");
// const {
//   validateRegister,
//   validateLogin,
//   validateUpdateUser,
// } = require("../middlewares/validationschema");

// const multer = require("multer");
// const appError = require("../utils/appError");
// const fs = require("fs");
// const path = require("path");

// const diskStorage = multer.diskStorage({
//   destination: (req, file, cb) => {
//     const uploadPath = path.join(__dirname, "..", "Uploads");
//     if (!fs.existsSync(uploadPath)) {
//       fs.mkdirSync(uploadPath, { recursive: true });
//     }
//     cb(null, uploadPath);
//   },
//   filename: (req, file, cb) => {
//     const ext = file.mimetype.split("/")[1];
//     cb(null, `user-${Date.now()}.${ext}`);
//   },
// });

// const fileFilter = (req, file, cb) => {
//   file.mimetype.startsWith("image")
//     ? cb(null, true)
//     : cb(appError.create("The file must be an image", 400), false);
// };

// const upload = multer({ storage: diskStorage, fileFilter });

// const router = express.Router();

// router
//   .route("/")
//   .get(verifyToken, allowedTo(userRoles.ADMIN), usersController.getAllUsers);

// router
//   .route("/register")
//   .post(
//     upload.single("avatar"),
//     validateRegister,
//     usersController.registerUser
//   );

// router.route("/login").post(validateLogin, usersController.loginUser);

// router
//   .route("/profile")
//   .get(
//     verifyToken,
//     allowedTo(userRoles.ADMIN, userRoles.PATIENT),
//     usersController.getUserProfile
//   )
//   .patch(
//     verifyToken,
//     allowedTo(userRoles.ADMIN, userRoles.PATIENT),
//     usersController.updateUserProfile
//   )
//   .delete(
//     verifyToken,
//     allowedTo(userRoles.ADMIN, userRoles.PATIENT),
//     usersController.deleteUserProfile
//   );

// router.post(
//   "/logout",
//   verifyToken,
//   allowedTo(userRoles.ADMIN, userRoles.PATIENT),
//   usersController.logoutUser
// );

// // نقطة نهاية لحفظ FCM Token
// router.post(
//   "/save-fcm-token",
//   verifyToken,
//   allowedTo(userRoles.PATIENT),
//   async (req, res, next) => {
//     const { fcmToken } = req.body;
//     const userId = req.user.id;

//     if (!fcmToken) {
//       return next(appError.create("FCM Token is required", 400, "fail"));
//     }

//     try {
//       const user = await require("../models/user.model").findByIdAndUpdate(
//         userId,
//         { fcmToken },
//         { new: true }
//       );
//       if (!user) {
//         return next(appError.create("User not found", 404, "fail"));
//       }
//       res.status(200).json({
//         status: "success",
//         message: "FCM Token saved successfully",
//       });
//     } catch (error) {
//       console.error("Error saving FCM Token:", error);
//       return next(appError.create("Server error", 500, "error"));
//     }
//   }
// );

// module.exports = router;


const express = require("express");
const usersController = require("../controllers/users.controller");
const verifyToken = require("../middlewares/virifyToken");
const allowedTo = require("../middlewares/allowedTo");
const userRoles = require("../utils/userRoles");
const {
  validateRegister,
  validateLogin,
} = require("../middlewares/validationschema");

const multer = require("multer");
const appError = require("../utils/appError");
const fs = require("fs");
const path = require("path");

const diskStorage = multer.diskStorage({
  destination: (req, file, cb) => {
    const uploadPath = path.join(__dirname, "..", "Uploads");
    if (!fs.existsSync(uploadPath)) {
      fs.mkdirSync(uploadPath, { recursive: true });
    }
    cb(null, uploadPath);
  },
  filename: (req, file, cb) => {
    const ext = file.mimetype.split("/")[1];
    cb(null, `user-${Date.now()}.${ext}`);
  },
});

const fileFilter = (req, file, cb) => {
  file.mimetype.startsWith("image")
    ? cb(null, true)
    : cb(appError.create("The file must be an image", 400), false);
};

const upload = multer({
  storage: diskStorage,
  fileFilter,
  limits: { fileSize: 5 * 1024 * 1024 }, // 5MB حد أقصى
});

const router = express.Router();

router
  .route("/")
  .get(verifyToken, allowedTo(userRoles.ADMIN), usersController.getAllUsers);

router
  .route("/register")
  .post(upload.single("avatar"), validateRegister, async (req, res, next) => {
    if (!req.file) {
      req.body.avatar = "Uploads/profile.jpg"; // صورة افتراضية
    }
    await usersController.registerUser(req, res, next);
  });

router.route("/login").post(validateLogin, usersController.loginUser);

router
  .route("/profile")
  .get(
    verifyToken,
    allowedTo(userRoles.PATIENT),
    usersController.getUserProfile
  )
  .patch(
    verifyToken,
    allowedTo(userRoles.PATIENT),
    usersController.updateUserProfile
  )
  .delete(
    verifyToken,
    allowedTo(userRoles.PATIENT),
    usersController.deleteUserProfile
  );

router.post(
  "/logout",
  verifyToken,
  allowedTo(userRoles.PATIENT),
  usersController.logoutUser
);

router.post(
  "/save-fcm-token",
  verifyToken,
  allowedTo(userRoles.PATIENT),
  async (req, res, next) => {
    const { fcmToken } = req.body;
    const userId = req.user.id;

    if (!fcmToken) {
      return next(appError.create("FCM Token is required", 400, "fail"));
    }

    try {
      const User = require("../models/user.model");
      const user = await User.findById(userId);

      if (!user) {
        return next(appError.create("User not found", 404, "fail"));
      }

      // التحقق من تكرار fcmToken
      if (user.fcmToken === fcmToken) {
        return res.status(200).json({
          status: "success",
          message: "FCM Token is already up to date",
        });
      }

      // تنظيف fcmToken من مستخدمين آخرين
      await User.updateMany(
        { fcmToken, _id: { $ne: userId } },
        { fcmToken: null }
      );

      user.fcmToken = fcmToken;
      await user.save();

      // إرسال إشعار لتأكيد التحديث
      const {
        sendNotification,
      } = require("../controllers/notifications.controller");
      await sendNotification(
        userId,
        null,
        null,
        "FCM Token Updated",
        "Your notification settings have been updated successfully.",
        "profile",
        "user"
      );

      res.status(200).json({
        status: "success",
        message: "FCM Token saved successfully",
      });
    } catch (error) {
      console.error("Error saving FCM Token:", error);
      return next(appError.create("Server error", 500, "error"));
    }
  }
);

module.exports = router;