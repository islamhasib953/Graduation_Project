// const express = require("express");
// const usersController = require("../controllers/users.controller");
// const verifyToken = require("../middlewares/virifyToken");
// const allowedTo = require("../middlewares/allowedTo");
// const userRoles = require("../utils/userRoles");
// const { validateRegister, validateLogin } = require("../middlewares/validationschema");
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

// const upload = multer({
//   storage: diskStorage,
//   fileFilter,
//   limits: { fileSize: 5 * 1024 * 1024 }, // 5MB حد أقصى
// });

// const router = express.Router();

// router
//   .route("/")
//   .get(verifyToken, allowedTo(userRoles.ADMIN), usersController.getAllUsers);

// router
//   .route("/register")
//   .post(upload.single("avatar"), validateRegister, async (req, res, next) => {
//     if (!req.file) {
//       req.body.avatar = "Uploads/profile.jpg"; // صورة افتراضية
//     }
//     await usersController.registerUser(req, res, next);
//   });

// router.route("/login").post(validateLogin, usersController.loginUser);

// router
//   .route("/profile")
//   .get(
//     verifyToken,
//     allowedTo(userRoles.PATIENT),
//     usersController.getUserProfile
//   )
//   .patch(
//     verifyToken,
//     allowedTo(userRoles.PATIENT),
//     usersController.updateUserProfile
//   )
//   .delete(
//     verifyToken,
//     allowedTo(userRoles.PATIENT),
//     usersController.deleteUserProfile
//   );

// router.post(
//   "/logout",
//   verifyToken,
//   allowedTo(userRoles.PATIENT),
//   usersController.logoutUser
// );

// router.post(
//   "/save-fcm-token",
//   verifyToken,
//   allowedTo(userRoles.PATIENT),
//   usersController.saveFcmToken
// );

// module.exports = router;

const express = require("express");
const usersController = require("../controllers/users.controller");
const verifyToken = require("../middlewares/virifyToken");
const allowedTo = require("../middlewares/allowedTo");
const userRoles = require("../utils/userRoles");
const { validateRegister, validateLogin } = require("../middlewares/validationschema");
const upload = require("../utils/multer.config"); // استيراد Multer المركزي

const router = express.Router();

router
  .route("/")
  .get(verifyToken, allowedTo(userRoles.ADMIN), usersController.getAllUsers);

router
  .route("/register")
  .post(
    (req, res, next) => {
      req.modelName = "user"; // إضافة اسم الموديل
      next();
    },
    upload.single("avatar"), // استخدام Multer المركزي
    validateRegister,
    usersController.registerUser
  );

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
    (req, res, next) => {
      req.modelName = "user"; // إضافة اسم الموديل
      next();
    },
    upload.single("avatar"), // إضافة Multer لرفع الصورة عند التحديث
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
  usersController.saveFcmToken
);

module.exports = router;