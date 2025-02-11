const express = require("express");
const usersController = require("../controllers/users.controller");
const verifyToken = require("../middlewares/virifyToken");
const allowedTo = require("../middlewares/allowedTo");
const userRoles = require("../utils/userRoles");
const checkOwnership = require("../middlewares/Ownership");

// ✅ Setup Multer for handling profile picture uploads
const multer = require("multer");
const appError = require("../utils/appError");

const diskStorage = multer.diskStorage({
  destination: function (req, file, cb) {
    cb(null, "uploads"); // Store uploaded images in the "uploads" folder
  },
  filename: function (req, file, cb) {
    const ext = file.mimetype.split("/")[1]; // Extract file extension
    const fileName = `user-${Date.now()}.${ext}`; // Create a unique filename
    cb(null, fileName);
  },
});

// ✅ Allow only image files
const fileFilter = (req, file, cb) => {
  const imageType = file.mimetype.split("/")[0]; // Get the file type
  if (imageType === "image") {
    cb(null, true);
  } else {
    return cb(appError.create("The file must be an image", 400), false);
  }
};

// ✅ Configure Multer
const upload = multer({
  storage: diskStorage,
  fileFilter: fileFilter,
});

const router = express.Router();

// ✅ Get all users (Only Admin can access this)
router
  .route("/")
  .get(verifyToken, allowedTo(userRoles.ADMIN), usersController.getAllUsers);

// ✅ Register a new user (Profile picture upload is optional)
router
  .route("/register")
  .post(upload.single("avatar"), usersController.registerUser);

// ✅ Login a user
router.route("/login").post(usersController.loginUser);

// ✅ Get, update, or delete a user (Only the account owner or Admin can modify the account)
router
  .route("/:userId")
  .get(verifyToken, checkOwnership, usersController.getUserById)
  .patch(verifyToken, checkOwnership, usersController.updateUser)
  .delete(verifyToken, checkOwnership, usersController.deleteUser);


module.exports = router;
