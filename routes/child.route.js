const express = require("express");
const { validationResult } = require("express-validator");
const router = express.Router();

const verifyToken = require("../middlewares/virifyToken");
const checkOwnership = require("../middlewares/Ownership");
const childController = require("../controllers/child.controller");
const validationschema = require("../middlewares/validationschema");



router
  .route("/")
  // .get(verifyToken, checkOwnership, childController.getAllChildren)
  .post(
    verifyToken,
    checkOwnership,
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
    validationschema.validateChild,
    childController.updateChild
  )
  .delete(verifyToken, checkOwnership, childController.deleteChild);

module.exports = router;
