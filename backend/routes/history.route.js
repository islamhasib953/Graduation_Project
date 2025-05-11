// const express = require("express");
// const { validationResult } = require("express-validator");
// const router = express.Router();

// const verifyToken = require("../middlewares/virifyToken");
// const checkOwnership = require("../middlewares/Ownership");
// const validationschema = require("../middlewares/validationschema");
// const historyController = require("../controllers/history.controller");
// const allowedTo = require("../middlewares/allowedTo");
// const userRoles = require("../utils/userRoles");


// //new**
// router.route("/filter/:childId").get(
//   // verifyToken,
//   // allowedTo(userRoles.ADMIN, userRoles.DOCTOR, userRoles.PATIENT),
//   historyController.filterHistory
// );

// router
//   .route("/:childId")
//   .get(
//     // verifyToken,
//     // allowedTo(userRoles.ADMIN, userRoles.DOCTOR, userRoles.PATIENT),
//     historyController.getAllHistory
//   )
//   .post(
//     verifyToken,
//     allowedTo(userRoles.ADMIN, userRoles.DOCTOR, userRoles.PATIENT),
//     validationschema.validateHistory,
//     historyController.createHistory
//   );

// router
//   .route("/:childId/:historyId")
//   .get(
//     // verifyToken,
//     // allowedTo(userRoles.ADMIN, userRoles.DOCTOR, userRoles.PATIENT),
//     historyController.getSingleHistory
//   )
//   .patch(
//     verifyToken,
//     allowedTo(userRoles.ADMIN, userRoles.DOCTOR, userRoles.PATIENT),
//     validationschema.validateHistory,
//     historyController.updateHistory
//   )
//   .delete(
//     verifyToken,
//     allowedTo(userRoles.ADMIN, userRoles.DOCTOR, userRoles.PATIENT),
//     historyController.deleteHistory
//   );

// module.exports = router;


const express = require("express");
const { validationResult } = require("express-validator");
const router = express.Router();
const verifyToken = require("../middlewares/virifyToken");
const validationschema = require("../middlewares/validationschema");
const historyController = require("../controllers/history.controller");
const allowedTo = require("../middlewares/allowedTo");
const userRoles = require("../utils/userRoles");
const upload = require("../utils/multer.config"); // استيراد Multer المركزي

router.route("/filter/:childId").get(historyController.filterHistory);

router
  .route("/:childId")
  .get(historyController.getAllHistory)
  .post(
    verifyToken,
    allowedTo(userRoles.ADMIN, userRoles.DOCTOR, userRoles.PATIENT),
    (req, res, next) => {
      req.modelName = "history"; // إضافة اسم الموديل
      next();
    },
    upload.single("notesImage"), // إضافة Multer لرفع الصورة
    validationschema.validateHistory,
    historyController.createHistory
  );

router
  .route("/:childId/:historyId")
  .get(historyController.getSingleHistory)
  .patch(
    verifyToken,
    allowedTo(userRoles.ADMIN, userRoles.DOCTOR, userRoles.PATIENT),
    (req, res, next) => {
      req.modelName = "history"; // إضافة اسم الموديل
      next();
    },
    upload.single("notesImage"), // إضافة Multer لرفع الصورة عند التحديث
    validationschema.validateHistory,
    historyController.updateHistory
  )
  .delete(
    verifyToken,
    allowedTo(userRoles.ADMIN, userRoles.DOCTOR, userRoles.PATIENT),
    historyController.deleteHistory
  );

module.exports = router;