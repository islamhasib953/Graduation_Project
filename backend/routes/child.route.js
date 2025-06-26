const express = require("express");
const { validationResult } = require("express-validator");
const router = express.Router();
const verifyToken = require("../middlewares/virifyToken");
const checkOwnership = require("../middlewares/Ownership");
const childController = require("../controllers/child.controller");
const validationschema = require("../middlewares/validationschema");
const {
  uploadToS3,
  getFromS3,
  deleteFromS3,
} = require("../middlewares/s3Middleware");

router
  .route("/")
  .post(
    verifyToken,
    checkOwnership,
    (req, res, next) => {
      req.modelName = "child";
      next();
    },
    uploadToS3,
    validationschema.validateChild,
    childController.createChild
  )
  .get(
    verifyToken,
    checkOwnership,
    validationschema.validateChild,
    childController.getChildrenForUser
  );

router
  .route("/:childId")
  .get(verifyToken, checkOwnership, childController.getSingleChild)
  .patch(
    verifyToken,
    checkOwnership,
    (req, res, next) => {
      req.modelName = "child";
      next();
    },
    uploadToS3,
    deleteFromS3,
    validationschema.validateChild,
    childController.updateChild
  )
  .delete(verifyToken, checkOwnership, childController.deleteChild);

module.exports = router;
