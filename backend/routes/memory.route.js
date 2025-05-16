// const express = require("express");
// const { validationResult } = require("express-validator");
// const router = express.Router();

// const memoryController = require("../controllers/memory.controller");
// const validationschema = require("../middlewares/validationschema");
// const verifyToken = require("../middlewares/virifyToken");
// const allowedTo = require("../middlewares/allowedTo");
// const userRoles = require("../utils/userRoles");
// const checkOwnership = require("../middlewares/Ownership");

// router
//   .route("/:childId")
//   .get(
//     verifyToken,
//     allowedTo(userRoles.ADMIN, userRoles.PATIENT),
//     memoryController.getAllMemories
//   )
//   .post(
//     verifyToken,
//     allowedTo(userRoles.ADMIN, userRoles.PATIENT),
//     validationschema.validateMemory,
//     memoryController.createMemory
//   );

// router
//   .route("/:childId/:memoryId")
//   // .get(verifyToken, checkOwnership, memoryController.getSingleMemory)
//   .patch(
//     verifyToken,
//     checkOwnership,
//     validationschema.validateMemory,
//     memoryController.updateMemory
//   )
//   .delete(verifyToken, checkOwnership, memoryController.deleteMemory);

// router
//   .route("/favorites/:childId")
//   .get(verifyToken, checkOwnership, memoryController.getFavoriteMemories);

// router
//   .route("/favorites/:childId/:memoryId")
//   .patch(verifyToken, checkOwnership, memoryController.toggleFavoriteMemory);

// module.exports = router;


const express = require("express");
const { validationResult } = require("express-validator");
const router = express.Router();
const memoryController = require("../controllers/memory.controller");
const validationschema = require("../middlewares/validationschema");
const verifyToken = require("../middlewares/virifyToken");
const allowedTo = require("../middlewares/allowedTo");
const userRoles = require("../utils/userRoles");
const checkOwnership = require("../middlewares/Ownership");
const upload = require("../utils/multer.config"); // استيراد Multer المركزي

router
  .route("/:childId")
  .get(
    verifyToken,
    allowedTo(userRoles.ADMIN, userRoles.PATIENT),
    memoryController.getAllMemories
  )
  .post(
    verifyToken,
    allowedTo(userRoles.ADMIN, userRoles.PATIENT),
    (req, res, next) => {
      req.modelName = "memory"; // إضافة اسم الموديل
      next();
    },
    upload.single("image"), // إضافة Multer لرفع الصورة
    validationschema.validateMemory,
    memoryController.createMemory
  );

router
  .route("/:childId/:memoryId")
  .patch(
    verifyToken,
    checkOwnership,
    (req, res, next) => {
      req.modelName = "memory"; // إضافة اسم الموديل
      next();
    },
    upload.single("image"), // إضافة Multer لرفع الصورة عند التحديث
    validationschema.validateMemory,
    memoryController.updateMemory
  )
  .delete(verifyToken, checkOwnership, memoryController.deleteMemory);

router
  .route("/favorites/:childId")
  .get(verifyToken, checkOwnership, memoryController.getFavoriteMemories);

router
  .route("/favorites/:childId/:memoryId")
  .patch(verifyToken, checkOwnership, memoryController.toggleFavoriteMemory);

module.exports = router;