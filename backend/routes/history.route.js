const express = require("express");
const { validationResult } = require("express-validator");
const router = express.Router();
const verifyToken = require("../middlewares/virifyToken");
const validationschema = require("../middlewares/validationschema");
const historyController = require("../controllers/history.controller");
const allowedTo = require("../middlewares/allowedTo");
const userRoles = require("../utils/userRoles");
const { uploadToS3, deleteFromS3 } = require("../middlewares/s3Middleware");

router.route("/filter/:childId").get(historyController.filterHistory);

router
  .route("/:childId")
  .get(historyController.getAllHistory)
  .post(
    verifyToken,
    allowedTo(userRoles.ADMIN, userRoles.DOCTOR, userRoles.PATIENT),
    (req, res, next) => {
      req.modelName = "history";
      next();
    },
    uploadToS3,
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
      req.modelName = "history";
      next();
    },
    deleteFromS3,
    uploadToS3,
    validationschema.validateHistory,
    historyController.updateHistory
  )
  .delete(
    verifyToken,
    allowedTo(userRoles.ADMIN, userRoles.DOCTOR, userRoles.PATIENT),
    historyController.deleteHistory
  );

module.exports = router;
