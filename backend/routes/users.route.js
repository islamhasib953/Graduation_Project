const express = require("express");
const usersController = require("../controllers/users.controller");
const verifyToken = require("../middlewares/virifyToken");
const allowedTo = require("../middlewares/allowedTo");
const userRoles = require("../utils/userRoles");
const {
  validateRegister,
  validateLogin,
} = require("../middlewares/validationschema");
const {
  uploadToS3,
  getFromS3,
  deleteFromS3,
} = require("../middlewares/s3Middleware");

const router = express.Router();

router
  .route("/")
  .get(verifyToken, allowedTo(userRoles.ADMIN), usersController.getAllUsers);

router.route("/register").post(
  (req, res, next) => {
    req.modelName = "user";
    next();
  },
  uploadToS3,
  validateRegister,
  async (req, res, next) => {
    if (!req.s3Data) {
      req.body.avatar = `https://${process.env.AWS_S3_BUCKET}.s3.${process.env.AWS_REGION}.amazonaws.com/uploads/user-default.jpg`;
    } else {
      req.body.avatar = req.s3Data.url;
    }
    await usersController.register(req, res, next);
  }
);

router.route("/login").post(validateLogin, usersController.login);

router
  .route("/profile")
  .get(
    verifyToken,
    allowedTo(userRoles.PATIENT),
    getFromS3,
    usersController.getUserProfile
  )
  .patch(
    verifyToken,
    allowedTo(userRoles.PATIENT),
    (req, res, next) => {
      req.modelName = "user";
      next();
    },
    uploadToS3,
    deleteFromS3,
    async (req, res, next) => {
      if (req.s3Data) {
        req.body.avatar = req.s3Data.url;
      }
      await usersController.updateProfile(req, res, next);
    }
  )
  .delete(
    verifyToken,
    allowedTo(userRoles.PATIENT),
    deleteFromS3,
    usersController.deleteProfile
  );

router.post(
  "/logout",
  verifyToken,
  allowedTo(userRoles.PATIENT),
  usersController.logout
);

router.post(
  "/save-fcm-token",
  verifyToken,
  allowedTo(userRoles.PATIENT),
  usersController.saveFcmToken
);

module.exports = router;
