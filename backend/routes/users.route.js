const express = require("express");
const usersController = require("../controllers/users.controller");
const verifyToken = require("../middlewares/virifyToken");
const allowedTo = require("../middlewares/allowedTo");
const userRoles = require("../utils/userRoles");
const checkOwnership = require("../middlewares/Ownership");
const {
  validateRegister,
  validateLogin,
  validateUpdateUser,
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

const upload = multer({ storage: diskStorage, fileFilter });

const router = express.Router();

router
  .route("/")
  .get(verifyToken, allowedTo(userRoles.ADMIN), usersController.getAllUsers);

router
  .route("/register")
  .post(
    upload.single("avatar"),
    validateRegister,
    usersController.registerUser
  );

router.route("/login").post(validateLogin, usersController.loginUser);

router
  .route("/profile")
  .get(
    verifyToken,
    allowedTo(userRoles.ADMIN, userRoles.PATIENT),
    usersController.getUserProfile
  )
  .patch(
    verifyToken,
    allowedTo(userRoles.ADMIN, userRoles.PATIENT),
    usersController.updateUserProfile
  )
  .delete(
    verifyToken,
    allowedTo(userRoles.ADMIN, userRoles.PATIENT),
    usersController.deleteUserProfile
  );

router.post(
  "/logout",
  verifyToken,
  allowedTo(userRoles.ADMIN, userRoles.PATIENT),
  usersController.logoutUser
);

// router
//   .route("/:userId")
//   .get(verifyToken, checkOwnership, usersController.getUserById)
//   .patch(
//     verifyToken,
//     checkOwnership,
//     validateUpdateUser,
//     usersController.updateUser
//   )
//   .delete(verifyToken, checkOwnership, usersController.deleteUser);


/////////////////////////////////////////////////////////////////////////////////
// module.exports = router;


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

// module.exports = router;
